-- =====================================================
-- Plugin WhatsApp para osTicket - Migración 001
-- Creación de tablas principales del plugin
-- Fecha: Enero 2026
-- Autor: quintana1308
-- =====================================================

-- Tabla de configuración del plugin WhatsApp
CREATE TABLE IF NOT EXISTS `ost_whatsapp_config` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `api_token` VARCHAR(255) NOT NULL COMMENT 'Token de API WaAPI.app (encriptado)',
    `instance_id` VARCHAR(100) NOT NULL COMMENT 'ID de instancia WaAPI.app',
    `webhook_url` VARCHAR(255) NOT NULL COMMENT 'URL del webhook para recibir mensajes',
    `webhook_secret` VARCHAR(255) NOT NULL COMMENT 'Secret para validar webhooks',
    `business_phone` VARCHAR(20) NOT NULL COMMENT 'Número de WhatsApp Business',
    `default_dept_id` INT DEFAULT NULL COMMENT 'Departamento por defecto para tickets WhatsApp',
    `enabled` BOOLEAN DEFAULT TRUE COMMENT 'Plugin habilitado/deshabilitado',
    `rate_limit` INT DEFAULT 50 COMMENT 'Límite de mensajes por minuto',
    `auto_create_users` BOOLEAN DEFAULT TRUE COMMENT 'Crear usuarios automáticamente',
    `created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`default_dept_id`) REFERENCES `ost_department`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Configuración del plugin WhatsApp';

-- Tabla para asociar usuarios con números de WhatsApp
CREATE TABLE IF NOT EXISTS `ost_whatsapp_users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL COMMENT 'ID del usuario en osTicket',
    `phone_number` VARCHAR(20) NOT NULL COMMENT 'Número de teléfono en formato WhatsApp',
    `phone_hash` VARCHAR(64) NOT NULL COMMENT 'Hash del número para búsquedas rápidas',
    `display_name` VARCHAR(100) DEFAULT NULL COMMENT 'Nombre mostrado en WhatsApp',
    `verified` BOOLEAN DEFAULT FALSE COMMENT 'Número verificado',
    `first_contact` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Primer contacto por WhatsApp',
    `last_contact` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Último contacto por WhatsApp',
    `message_count` INT DEFAULT 0 COMMENT 'Total de mensajes enviados/recibidos',
    `status` ENUM('active', 'blocked', 'inactive') DEFAULT 'active' COMMENT 'Estado del contacto',
    `created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_user_phone` (`user_id`, `phone_hash`),
    INDEX `idx_phone_hash` (`phone_hash`),
    INDEX `idx_last_contact` (`last_contact`),
    FOREIGN KEY (`user_id`) REFERENCES `ost_user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Asociación usuarios-números WhatsApp';

-- Tabla de mensajes WhatsApp (log completo)
CREATE TABLE IF NOT EXISTS `ost_whatsapp_messages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` INT DEFAULT NULL COMMENT 'ID del ticket asociado',
    `thread_entry_id` INT DEFAULT NULL COMMENT 'ID de la entrada del hilo',
    `user_id` INT DEFAULT NULL COMMENT 'ID del usuario',
    `phone_number` VARCHAR(20) NOT NULL COMMENT 'Número de teléfono',
    `direction` ENUM('incoming', 'outgoing') NOT NULL COMMENT 'Dirección del mensaje',
    `message_type` ENUM('text', 'image', 'document', 'audio', 'video', 'location', 'contact') DEFAULT 'text' COMMENT 'Tipo de mensaje',
    `message_content` TEXT COMMENT 'Contenido del mensaje',
    `media_url` VARCHAR(500) DEFAULT NULL COMMENT 'URL del archivo multimedia',
    `media_filename` VARCHAR(255) DEFAULT NULL COMMENT 'Nombre del archivo',
    `media_mimetype` VARCHAR(100) DEFAULT NULL COMMENT 'Tipo MIME del archivo',
    `media_size` INT DEFAULT NULL COMMENT 'Tamaño del archivo en bytes',
    `waapi_message_id` VARCHAR(100) DEFAULT NULL COMMENT 'ID del mensaje en WaAPI',
    `waapi_instance_id` VARCHAR(100) DEFAULT NULL COMMENT 'ID de instancia WaAPI',
    `status` ENUM('pending', 'sent', 'delivered', 'read', 'failed') DEFAULT 'pending' COMMENT 'Estado del mensaje',
    `error_message` TEXT DEFAULT NULL COMMENT 'Mensaje de error si falló',
    `retry_count` INT DEFAULT 0 COMMENT 'Número de reintentos',
    `created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `sent_at` DATETIME DEFAULT NULL COMMENT 'Momento de envío',
    `delivered_at` DATETIME DEFAULT NULL COMMENT 'Momento de entrega',
    `read_at` DATETIME DEFAULT NULL COMMENT 'Momento de lectura',
    INDEX `idx_ticket_id` (`ticket_id`),
    INDEX `idx_phone_number` (`phone_number`),
    INDEX `idx_waapi_message_id` (`waapi_message_id`),
    INDEX `idx_direction_status` (`direction`, `status`),
    INDEX `idx_created` (`created`),
    FOREIGN KEY (`ticket_id`) REFERENCES `ost_ticket`(`ticket_id`) ON DELETE SET NULL,
    FOREIGN KEY (`thread_entry_id`) REFERENCES `ost_thread_entry`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`user_id`) REFERENCES `ost_user`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Log de mensajes WhatsApp';

-- Tabla de plantillas de mensajes WhatsApp
CREATE TABLE IF NOT EXISTS `ost_whatsapp_templates` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT 'Nombre de la plantilla',
    `code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Código único de la plantilla',
    `subject` VARCHAR(255) DEFAULT NULL COMMENT 'Asunto del mensaje',
    `message` TEXT NOT NULL COMMENT 'Contenido de la plantilla',
    `variables` JSON DEFAULT NULL COMMENT 'Variables disponibles en la plantilla',
    `event_trigger` VARCHAR(50) DEFAULT NULL COMMENT 'Evento que dispara la plantilla',
    `dept_id` INT DEFAULT NULL COMMENT 'Departamento específico (NULL = todos)',
    `enabled` BOOLEAN DEFAULT TRUE COMMENT 'Plantilla habilitada',
    `created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_code` (`code`),
    INDEX `idx_event_trigger` (`event_trigger`),
    FOREIGN KEY (`dept_id`) REFERENCES `ost_department`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Plantillas de mensajes WhatsApp';

-- Tabla de archivos adjuntos WhatsApp
CREATE TABLE IF NOT EXISTS `ost_whatsapp_attachments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `message_id` INT NOT NULL COMMENT 'ID del mensaje WhatsApp',
    `file_id` INT DEFAULT NULL COMMENT 'ID del archivo en osTicket',
    `waapi_media_id` VARCHAR(100) DEFAULT NULL COMMENT 'ID del media en WaAPI',
    `original_url` VARCHAR(500) DEFAULT NULL COMMENT 'URL original del archivo',
    `local_path` VARCHAR(500) DEFAULT NULL COMMENT 'Ruta local del archivo',
    `filename` VARCHAR(255) NOT NULL COMMENT 'Nombre del archivo',
    `mimetype` VARCHAR(100) NOT NULL COMMENT 'Tipo MIME',
    `size` INT DEFAULT NULL COMMENT 'Tamaño en bytes',
    `download_status` ENUM('pending', 'downloaded', 'failed') DEFAULT 'pending' COMMENT 'Estado de descarga',
    `created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_message_id` (`message_id`),
    INDEX `idx_file_id` (`file_id`),
    FOREIGN KEY (`message_id`) REFERENCES `ost_whatsapp_messages`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`file_id`) REFERENCES `ost_file`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Archivos adjuntos de WhatsApp';

-- Insertar plantillas por defecto
INSERT INTO `ost_whatsapp_templates` (`name`, `code`, `subject`, `message`, `variables`, `event_trigger`, `enabled`) VALUES
('Ticket Creado', 'ticket_created', 'Ticket Creado', 
'¡Hola %{user.name}! 👋\n\nTu ticket #%{ticket.number} ha sido creado exitosamente.\n\n📋 *Asunto:* %{ticket.subject}\n🏢 *Departamento:* %{ticket.dept.name}\n⏰ *Fecha:* %{ticket.created}\n\nTe mantendremos informado sobre el progreso. ¡Gracias por contactarnos!',
'["user.name", "ticket.number", "ticket.subject", "ticket.dept.name", "ticket.created"]',
'ticket.created', 1),

('Respuesta de Agente', 'agent_reply', 'Nueva Respuesta', 
'📨 *Nueva respuesta en tu ticket #%{ticket.number}*\n\n👤 *De:* %{staff.name}\n💬 *Mensaje:*\n%{message.content}\n\n---\nPuedes responder directamente a este mensaje.',
'["ticket.number", "staff.name", "message.content"]',
'threadentry.created', 1),

('Ticket Resuelto', 'ticket_resolved', 'Ticket Resuelto', 
'✅ *Tu ticket #%{ticket.number} ha sido resuelto*\n\n📋 *Asunto:* %{ticket.subject}\n👤 *Resuelto por:* %{staff.name}\n⏰ *Fecha:* %{ticket.updated}\n\nSi necesitas ayuda adicional, no dudes en contactarnos. ¡Gracias!',
'["ticket.number", "ticket.subject", "staff.name", "ticket.updated"]',
'ticket.resolved', 1),

('Ticket Cerrado', 'ticket_closed', 'Ticket Cerrado', 
'🔒 *Tu ticket #%{ticket.number} ha sido cerrado*\n\n📋 *Asunto:* %{ticket.subject}\n👤 *Cerrado por:* %{staff.name}\n⏰ *Fecha:* %{ticket.updated}\n\n¡Gracias por usar nuestro servicio de soporte!',
'["ticket.number", "ticket.subject", "staff.name", "ticket.updated"]',
'ticket.closed', 1),

('Bienvenida', 'welcome', 'Bienvenido', 
'¡Hola! 👋 Bienvenido a nuestro soporte por WhatsApp.\n\nPuedes escribirnos tu consulta y crearemos un ticket para darte seguimiento personalizado.\n\n🕒 *Horario de atención:* Lunes a Viernes 9:00 - 18:00\n⏱️ *Tiempo de respuesta:* Máximo 2 horas\n\n¡Estamos aquí para ayudarte!',
'[]',
'user.first_contact', 1);

-- Insertar configuración por defecto
INSERT INTO `ost_whatsapp_config` (`api_token`, `instance_id`, `webhook_url`, `webhook_secret`, `business_phone`, `enabled`) VALUES
('CONFIGURAR_TOKEN_WAAPI', 'CONFIGURAR_INSTANCE_ID', 'https://tu-osticket.com/include/plugins/whatsapp/webhook.php', 'CONFIGURAR_WEBHOOK_SECRET', 'CONFIGURAR_NUMERO_BUSINESS', FALSE);

-- Crear índices adicionales para optimización
CREATE INDEX `idx_whatsapp_users_status` ON `ost_whatsapp_users` (`status`, `last_contact`);
CREATE INDEX `idx_whatsapp_messages_status_created` ON `ost_whatsapp_messages` (`status`, `created`);
CREATE INDEX `idx_whatsapp_messages_retry` ON `ost_whatsapp_messages` (`status`, `retry_count`) WHERE `status` = 'failed';

-- Crear vistas útiles para reportes
CREATE OR REPLACE VIEW `view_whatsapp_stats` AS
SELECT 
    DATE(created) as date,
    direction,
    status,
    COUNT(*) as message_count,
    COUNT(DISTINCT phone_number) as unique_contacts
FROM `ost_whatsapp_messages` 
WHERE created >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(created), direction, status
ORDER BY date DESC;

CREATE OR REPLACE VIEW `view_whatsapp_active_conversations` AS
SELECT 
    wu.phone_number,
    wu.display_name,
    wu.last_contact,
    COUNT(wm.id) as message_count,
    MAX(wm.created) as last_message,
    t.ticket_id,
    t.number as ticket_number,
    t.status_id
FROM `ost_whatsapp_users` wu
LEFT JOIN `ost_whatsapp_messages` wm ON wu.phone_number = wm.phone_number
LEFT JOIN `ost_ticket` t ON wm.ticket_id = t.ticket_id
WHERE wu.status = 'active' 
    AND wu.last_contact >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY wu.phone_number, t.ticket_id
ORDER BY last_message DESC;

-- Comentarios finales
-- Esta migración crea la estructura base para el plugin WhatsApp
-- Incluye tablas para configuración, usuarios, mensajes, plantillas y adjuntos
-- También crea vistas útiles para reportes y monitoreo
