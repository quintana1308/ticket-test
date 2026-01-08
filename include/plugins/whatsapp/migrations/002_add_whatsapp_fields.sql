-- =====================================================
-- Plugin WhatsApp para osTicket - Migración 002
-- Agregar campos WhatsApp a tablas existentes
-- Fecha: Enero 2026
-- Autor: quintana1308
-- =====================================================

-- Agregar campos WhatsApp a la tabla de tickets
ALTER TABLE `ost_ticket` 
ADD COLUMN `whatsapp_phone` VARCHAR(20) DEFAULT NULL COMMENT 'Número WhatsApp del cliente',
ADD COLUMN `communication_channel` ENUM('email', 'whatsapp', 'hybrid') DEFAULT 'email' COMMENT 'Canal principal de comunicación',
ADD COLUMN `whatsapp_enabled` BOOLEAN DEFAULT FALSE COMMENT 'Comunicación WhatsApp habilitada para este ticket',
ADD COLUMN `whatsapp_last_message` DATETIME DEFAULT NULL COMMENT 'Último mensaje WhatsApp en este ticket';

-- Agregar campos WhatsApp a la tabla de usuarios
ALTER TABLE `ost_user` 
ADD COLUMN `whatsapp_phone` VARCHAR(20) DEFAULT NULL COMMENT 'Número WhatsApp principal del usuario',
ADD COLUMN `whatsapp_verified` BOOLEAN DEFAULT FALSE COMMENT 'Número WhatsApp verificado',
ADD COLUMN `whatsapp_opt_in` BOOLEAN DEFAULT TRUE COMMENT 'Usuario acepta recibir mensajes WhatsApp';

-- Agregar campos WhatsApp a la tabla de departamentos
ALTER TABLE `ost_department` 
ADD COLUMN `whatsapp_enabled` BOOLEAN DEFAULT TRUE COMMENT 'Departamento acepta tickets por WhatsApp',
ADD COLUMN `whatsapp_auto_reply` BOOLEAN DEFAULT TRUE COMMENT 'Enviar respuesta automática por WhatsApp',
ADD COLUMN `whatsapp_template_id` INT DEFAULT NULL COMMENT 'Plantilla por defecto para este departamento';

-- Agregar campos WhatsApp a la tabla de thread entries
ALTER TABLE `ost_thread_entry` 
ADD COLUMN `whatsapp_message_id` INT DEFAULT NULL COMMENT 'ID del mensaje WhatsApp asociado',
ADD COLUMN `whatsapp_status` ENUM('pending', 'sent', 'delivered', 'read', 'failed') DEFAULT NULL COMMENT 'Estado del mensaje WhatsApp';

-- Crear índices para optimizar consultas
CREATE INDEX `idx_ticket_whatsapp_phone` ON `ost_ticket` (`whatsapp_phone`);
CREATE INDEX `idx_ticket_communication_channel` ON `ost_ticket` (`communication_channel`);
CREATE INDEX `idx_ticket_whatsapp_enabled` ON `ost_ticket` (`whatsapp_enabled`);
CREATE INDEX `idx_user_whatsapp_phone` ON `ost_user` (`whatsapp_phone`);
CREATE INDEX `idx_user_whatsapp_verified` ON `ost_user` (`whatsapp_verified`);
CREATE INDEX `idx_dept_whatsapp_enabled` ON `ost_department` (`whatsapp_enabled`);
CREATE INDEX `idx_thread_entry_whatsapp` ON `ost_thread_entry` (`whatsapp_message_id`);

-- Agregar foreign keys para mantener integridad
ALTER TABLE `ost_department` 
ADD CONSTRAINT `fk_dept_whatsapp_template` 
FOREIGN KEY (`whatsapp_template_id`) REFERENCES `ost_whatsapp_templates`(`id`) ON DELETE SET NULL;

ALTER TABLE `ost_thread_entry` 
ADD CONSTRAINT `fk_thread_whatsapp_message` 
FOREIGN KEY (`whatsapp_message_id`) REFERENCES `ost_whatsapp_messages`(`id`) ON DELETE SET NULL;

-- Crear triggers para mantener sincronización
DELIMITER //

-- Trigger para actualizar último mensaje WhatsApp en ticket
CREATE TRIGGER `tr_whatsapp_message_update_ticket` 
AFTER INSERT ON `ost_whatsapp_messages`
FOR EACH ROW
BEGIN
    IF NEW.ticket_id IS NOT NULL THEN
        UPDATE `ost_ticket` 
        SET `whatsapp_last_message` = NEW.created,
            `whatsapp_enabled` = TRUE
        WHERE `ticket_id` = NEW.ticket_id;
    END IF;
END//

-- Trigger para actualizar contador de mensajes en usuario WhatsApp
CREATE TRIGGER `tr_whatsapp_message_count_update` 
AFTER INSERT ON `ost_whatsapp_messages`
FOR EACH ROW
BEGIN
    UPDATE `ost_whatsapp_users` 
    SET `message_count` = `message_count` + 1,
        `last_contact` = NEW.created
    WHERE `phone_number` = NEW.phone_number;
END//

-- Trigger para sincronizar número WhatsApp entre user y whatsapp_users
CREATE TRIGGER `tr_user_whatsapp_sync` 
AFTER UPDATE ON `ost_user`
FOR EACH ROW
BEGIN
    IF NEW.whatsapp_phone != OLD.whatsapp_phone AND NEW.whatsapp_phone IS NOT NULL THEN
        INSERT INTO `ost_whatsapp_users` (`user_id`, `phone_number`, `phone_hash`, `verified`)
        VALUES (NEW.id, NEW.whatsapp_phone, SHA2(NEW.whatsapp_phone, 256), NEW.whatsapp_verified)
        ON DUPLICATE KEY UPDATE 
            `phone_number` = NEW.whatsapp_phone,
            `phone_hash` = SHA2(NEW.whatsapp_phone, 256),
            `verified` = NEW.whatsapp_verified;
    END IF;
END//

DELIMITER ;

-- Crear procedimientos almacenados útiles
DELIMITER //

-- Procedimiento para obtener estadísticas WhatsApp
CREATE PROCEDURE `sp_whatsapp_stats`(IN days_back INT)
BEGIN
    SELECT 
        'Mensajes Totales' as metric,
        COUNT(*) as value
    FROM `ost_whatsapp_messages` 
    WHERE created >= DATE_SUB(NOW(), INTERVAL days_back DAY)
    
    UNION ALL
    
    SELECT 
        'Mensajes Entrantes' as metric,
        COUNT(*) as value
    FROM `ost_whatsapp_messages` 
    WHERE direction = 'incoming' 
        AND created >= DATE_SUB(NOW(), INTERVAL days_back DAY)
    
    UNION ALL
    
    SELECT 
        'Mensajes Salientes' as metric,
        COUNT(*) as value
    FROM `ost_whatsapp_messages` 
    WHERE direction = 'outgoing' 
        AND created >= DATE_SUB(NOW(), INTERVAL days_back DAY)
    
    UNION ALL
    
    SELECT 
        'Tickets WhatsApp' as metric,
        COUNT(DISTINCT ticket_id) as value
    FROM `ost_whatsapp_messages` 
    WHERE ticket_id IS NOT NULL 
        AND created >= DATE_SUB(NOW(), INTERVAL days_back DAY)
    
    UNION ALL
    
    SELECT 
        'Usuarios Activos' as metric,
        COUNT(DISTINCT phone_number) as value
    FROM `ost_whatsapp_messages` 
    WHERE created >= DATE_SUB(NOW(), INTERVAL days_back DAY);
END//

-- Procedimiento para limpiar mensajes antiguos
CREATE PROCEDURE `sp_whatsapp_cleanup`(IN days_to_keep INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE msg_id INT;
    DECLARE cur CURSOR FOR 
        SELECT id FROM `ost_whatsapp_messages` 
        WHERE created < DATE_SUB(NOW(), INTERVAL days_to_keep DAY)
        AND status IN ('delivered', 'read');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;
    
    -- Eliminar adjuntos de mensajes antiguos
    DELETE FROM `ost_whatsapp_attachments` 
    WHERE message_id IN (
        SELECT id FROM `ost_whatsapp_messages` 
        WHERE created < DATE_SUB(NOW(), INTERVAL days_to_keep DAY)
        AND status IN ('delivered', 'read')
    );
    
    -- Eliminar mensajes antiguos
    DELETE FROM `ost_whatsapp_messages` 
    WHERE created < DATE_SUB(NOW(), INTERVAL days_to_keep DAY)
    AND status IN ('delivered', 'read');
    
    COMMIT;
    
    SELECT ROW_COUNT() as messages_deleted;
END//

DELIMITER ;

-- Crear función para validar números WhatsApp
DELIMITER //

CREATE FUNCTION `fn_validate_whatsapp_phone`(phone VARCHAR(20)) 
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE clean_phone VARCHAR(20);
    DECLARE phone_length INT;
    
    -- Limpiar el número (solo dígitos)
    SET clean_phone = REGEXP_REPLACE(phone, '[^0-9]', '');
    SET phone_length = CHAR_LENGTH(clean_phone);
    
    -- Validar longitud (8-15 dígitos según estándar internacional)
    IF phone_length < 8 OR phone_length > 15 THEN
        RETURN FALSE;
    END IF;
    
    -- Validar que no empiece con 00
    IF LEFT(clean_phone, 2) = '00' THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END//

DELIMITER ;

-- Actualizar tickets existentes que tengan comunicación por WhatsApp
UPDATE `ost_ticket` t
INNER JOIN `ost_whatsapp_messages` wm ON t.ticket_id = wm.ticket_id
SET t.communication_channel = 'whatsapp',
    t.whatsapp_enabled = TRUE,
    t.whatsapp_phone = wm.phone_number,
    t.whatsapp_last_message = (
        SELECT MAX(created) 
        FROM `ost_whatsapp_messages` 
        WHERE ticket_id = t.ticket_id
    )
WHERE t.communication_channel = 'email';

-- Comentarios finales
-- Esta migración integra WhatsApp con las tablas existentes de osTicket
-- Agrega campos necesarios sin modificar la estructura original
-- Incluye triggers y procedimientos para automatizar tareas comunes
