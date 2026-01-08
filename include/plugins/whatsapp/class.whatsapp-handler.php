<?php
/**
 * Manejador de Mensajes WhatsApp para osTicket
 * 
 * Procesa mensajes entrantes y salientes, maneja la lógica de negocio
 * del plugin y coordina la integración con osTicket
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

require_once INCLUDE_DIR . 'api.tickets.php';
require_once 'class.whatsapp-templates.php';

class WhatsAppHandler {
    
    private $config;
    private $waapi;
    private $logger;
    private $template_manager;
    
    public function __construct($config, $waapi) {
        $this->config = $config;
        $this->waapi = $waapi;
        $this->logger = new WhatsAppLogger();
        $this->template_manager = new WhatsAppTemplateManager($config);
    }
    
    /**
     * Procesar mensaje entrante desde WhatsApp
     */
    public function processIncomingMessage($message_data) {
        try {
            // Validar rate limiting
            if (!$this->checkRateLimit($message_data['from'])) {
                $this->logger->log('WARNING', 'Rate limit excedido', ['phone' => $message_data['from']]);
                return false;
            }
            
            // Buscar o crear usuario
            $user = $this->findOrCreateUser($message_data);
            
            // Buscar ticket existente o crear nuevo
            $ticket = $this->findOrCreateTicket($user, $message_data);
            
            // Crear entrada en el hilo del ticket
            $this->createThreadEntry($ticket, $message_data);
            
            // Descargar archivos adjuntos si los hay
            if ($message_data['media']) {
                $this->handleMediaAttachment($ticket, $message_data);
            }
            
            // Enviar confirmación automática si es ticket nuevo
            if ($ticket && $ticket->getId()) {
                $this->sendTicketCreatedNotification($ticket);
            }
            
            return true;
            
        } catch (Exception $e) {
            $this->logger->log('ERROR', 'Error procesando mensaje entrante: ' . $e->getMessage(), [
                'phone' => $message_data['from'],
                'message_id' => $message_data['id']
            ]);
            return false;
        }
    }
    
    /**
     * Manejar ticket creado
     */
    public function handleTicketCreated($ticket) {
        if ($ticket->whatsapp_enabled) {
            $this->sendTicketCreatedNotification($ticket);
        }
    }
    
    /**
     * Manejar respuesta creada
     */
    public function handleReplyCreated($ticket, $entry) {
        // Verificar que el ticket tenga WhatsApp habilitado
        if (!$ticket->whatsapp_enabled || !$ticket->whatsapp_phone) {
            return false;
        }
        
        // Obtener plantilla de respuesta de agente
        $template = $this->template_manager->getTemplate('agent_reply', $ticket->getDeptId());
        $message = $this->template_manager->processTemplate($template, [
            'ticket' => $ticket,
            'staff' => $entry->getStaff(),
            'message' => ['content' => $entry->getBody()]
        ]);
        
        // Enviar mensaje por WhatsApp
        $result = $this->waapi->sendMessage($ticket->whatsapp_phone, $message);
        
        if ($result['success']) {
            // Actualizar entrada con ID del mensaje WhatsApp
            $this->updateThreadEntryWithWhatsApp($entry, $result['data']);
            
            // Registrar mensaje en log
            $this->logWhatsAppMessage($ticket, $ticket->whatsapp_phone, 'outgoing', 'text', $message, $result['data']);
        }
        
        return $result['success'];
    }
    
    /**
     * Manejar ticket asignado
     */
    public function handleTicketAssigned($ticket, $staff) {
        if (!$ticket->whatsapp_enabled) return false;
        
        $template = $this->template_manager->getTemplate('ticket_assigned', $ticket->getDeptId());
        if (!$template) return false;
        
        $message = $this->template_manager->processTemplate($template, [
            'ticket' => $ticket,
            'staff' => $staff
        ]);
        
        return $this->sendWhatsAppMessage($ticket->whatsapp_phone, $message, $ticket);
    }
    
    /**
     * Manejar ticket resuelto (integración con PERM_RESOLVE)
     */
    public function handleTicketResolved($ticket, $staff) {
        if (!$ticket->whatsapp_enabled) return false;
        
        $template = $this->template_manager->getTemplate('ticket_resolved', $ticket->getDeptId());
        if (!$template) return false;
        
        $message = $this->template_manager->processTemplate($template, [
            'ticket' => $ticket,
            'staff' => $staff
        ]);
        
        return $this->sendWhatsAppMessage($ticket->whatsapp_phone, $message, $ticket);
    }
    
    /**
     * Manejar ticket cerrado (integración con PERM_CLOSE)
     */
    public function handleTicketClosed($ticket, $staff) {
        if (!$ticket->whatsapp_enabled) return false;
        
        $template = $this->template_manager->getTemplate('ticket_closed', $ticket->getDeptId());
        if (!$template) return false;
        
        $message = $this->template_manager->processTemplate($template, [
            'ticket' => $ticket,
            'staff' => $staff
        ]);
        
        return $this->sendWhatsAppMessage($ticket->whatsapp_phone, $message, $ticket);
    }
    
    /**
     * Buscar o crear usuario desde número WhatsApp
     */
    private function findOrCreateUser($message_data) {
        $phone = $this->waapi->cleanPhoneNumber($message_data['from']);
        
        // Buscar usuario existente por número WhatsApp
        $sql = 'SELECT u.* FROM ost_user u 
                JOIN ost_whatsapp_users wu ON u.id = wu.user_id 
                WHERE wu.phone_hash = %s';
        
        $user = User::lookup(db_query($sql, hash('sha256', $phone)));
        
        if (!$user && $this->config->get('auto_create_users')) {
            // Crear nuevo usuario
            $user_data = [
                'name' => $message_data['pushName'] ?: 'Usuario WhatsApp',
                'email' => $phone . '@whatsapp.local',
                'whatsapp_phone' => $phone
            ];
            
            $user = User::fromVars($user_data);
            
            if ($user) {
                // Asociar con WhatsApp
                $this->associateUserWithPhone($user, $phone, $message_data['pushName']);
            }
        }
        
        return $user;
    }
    
    /**
     * Buscar o crear ticket
     */
    private function findOrCreateTicket($user, $message_data) {
        if (!$user) return null;
        
        $phone = $this->waapi->cleanPhoneNumber($message_data['from']);
        
        // Buscar ticket abierto existente para este usuario
        $sql = 'SELECT * FROM ost_ticket 
                WHERE user_id = %d 
                AND whatsapp_phone = %s 
                AND status_id NOT IN (SELECT id FROM ost_ticket_status WHERE state = "closed")
                ORDER BY created DESC LIMIT 1';
        
        $res = db_query($sql, $user->getId(), $phone);
        $ticket = $res ? Ticket::lookup(db_result($res)) : null;
        
        if (!$ticket) {
            // Crear nuevo ticket
            $ticket_data = [
                'user_id' => $user->getId(),
                'subject' => $this->generateTicketSubject($message_data),
                'message' => $message_data['content'],
                'source' => 'WhatsApp',
                'whatsapp_phone' => $phone,
                'whatsapp_enabled' => true,
                'communication_channel' => 'whatsapp',
                'dept_id' => $this->config->get('default_dept_id') ?: 1
            ];
            
            // Usar API de osTicket para crear ticket
            $ticket = Ticket::open($ticket_data);
        }
        
        return $ticket;
    }
    
    /**
     * Crear entrada en hilo de ticket
     */
    private function createThreadEntry($ticket, $message_data) {
        if (!$ticket) return null;
        
        $thread = $ticket->getThread();
        
        $entry_data = [
            'type' => 'M', // Message
            'poster' => $ticket->getUser()->getName(),
            'body' => $message_data['content'],
            'format' => 'text'
        ];
        
        $entry = $thread->addMessage($entry_data);
        
        if ($entry) {
            // Registrar mensaje en log WhatsApp
            $this->logWhatsAppMessage($ticket, $message_data['from'], 'incoming', 
                $message_data['type'], $message_data['content'], $message_data);
        }
        
        return $entry;
    }
    
    /**
     * Enviar mensaje WhatsApp
     */
    private function sendWhatsAppMessage($phone, $message, $ticket = null) {
        try {
            $result = $this->waapi->sendMessage($phone, $message);
            
            if ($result['success'] && $ticket) {
                $this->logWhatsAppMessage($ticket, $phone, 'outgoing', 'text', $message, $result['data']);
            }
            
            return $result['success'];
        } catch (Exception $e) {
            $this->logger->log('ERROR', 'Error enviando mensaje WhatsApp: ' . $e->getMessage(), [
                'phone' => $phone,
                'ticket_id' => $ticket ? $ticket->getId() : null
            ]);
            return false;
        }
    }
    
    
    /**
     * Registrar mensaje en log WhatsApp
     */
    private function logWhatsAppMessage($ticket, $phone, $direction, $type, $content, $waapi_data) {
        $sql = 'INSERT INTO ost_whatsapp_messages 
                (ticket_id, phone_number, direction, message_type, message_content, 
                 waapi_message_id, status, created) 
                VALUES (%d, %s, %s, %s, %s, %s, %s, NOW())';
        
        $message_id = isset($waapi_data['id']) ? $waapi_data['id'] : null;
        $status = $direction === 'outgoing' ? 'sent' : 'received';
        
        db_query($sql, $ticket->getId(), $phone, $direction, $type, $content, $message_id, $status);
    }
    
    /**
     * Validar rate limiting
     */
    private function checkRateLimit($phone) {
        $limit = $this->config->get('rate_limit', 50);
        
        $sql = 'SELECT COUNT(*) FROM ost_whatsapp_messages 
                WHERE phone_number = %s 
                AND direction = "incoming" 
                AND created > DATE_SUB(NOW(), INTERVAL 1 MINUTE)';
        
        $count = db_result(db_query($sql, $phone));
        
        return $count < $limit;
    }
    
    /**
     * Asociar usuario con número WhatsApp
     */
    public function associateUserWithPhone($user, $phone, $display_name = null) {
        $sql = 'INSERT INTO ost_whatsapp_users 
                (user_id, phone_number, phone_hash, display_name, verified, created) 
                VALUES (%d, %s, %s, %s, 1, NOW()) 
                ON DUPLICATE KEY UPDATE 
                display_name = VALUES(display_name), 
                last_contact = NOW()';
        
        return db_query($sql, $user->getId(), $phone, hash('sha256', $phone), $display_name);
    }
    
    /**
     * Generar asunto para ticket
     */
    private function generateTicketSubject($message_data) {
        $content = $message_data['content'];
        
        if (strlen($content) > 50) {
            return substr($content, 0, 47) . '...';
        }
        
        return $content ?: 'Consulta por WhatsApp';
    }
    
    /**
     * Validar número de teléfono
     */
    public function validatePhoneNumber($phone) {
        return $this->waapi->isValidWhatsAppNumber($phone);
    }
    
    /**
     * Manejar archivo multimedia adjunto
     */
    private function handleMediaAttachment($ticket, $message_data) {
        if (!$message_data['media']) return false;
        
        try {
            $media = $message_data['media'];
            $filename = $media['filename'] ?: 'attachment_' . time();
            $upload_dir = ROOT_DIR . 'attachments/whatsapp/';
            
            // Crear directorio si no existe
            if (!is_dir($upload_dir)) {
                mkdir($upload_dir, 0755, true);
            }
            
            $file_path = $upload_dir . $filename;
            
            // Descargar archivo desde WaAPI
            $this->waapi->downloadMedia($media['url'], $file_path);
            
            // Crear registro de archivo en osTicket
            $file_data = array(
                'name' => $filename,
                'type' => $media['mimetype'],
                'size' => filesize($file_path),
                'data' => file_get_contents($file_path)
            );
            
            // Asociar con ticket
            $attachment = AttachmentFile::create($file_data);
            if ($attachment) {
                $ticket->getThread()->attachments->add($attachment);
            }
            
            return true;
        } catch (Exception $e) {
            $this->logger->log('ERROR', 'Error manejando archivo adjunto: ' . $e->getMessage());
            return false;
        }
    }
    
    /**
     * Enviar notificación de ticket creado
     */
    private function sendTicketCreatedNotification($ticket) {
        if (!$ticket->whatsapp_enabled || !$ticket->whatsapp_phone) {
            return false;
        }
        
        $template = $this->template_manager->getTemplate('ticket_created', $ticket->getDeptId());
        if (!$template) return false;
        
        $message = $this->template_manager->processTemplate($template, array(
            'ticket' => $ticket,
            'user' => $ticket->getUser()
        ));
        
        return $this->sendWhatsAppMessage($ticket->whatsapp_phone, $message, $ticket);
    }
    
    /**
     * Actualizar entrada de hilo con información WhatsApp
     */
    private function updateThreadEntryWithWhatsApp($entry, $waapi_data) {
        $sql = 'UPDATE ost_thread_entry SET 
                whatsapp_message_id = (SELECT id FROM ost_whatsapp_messages WHERE waapi_message_id = %s LIMIT 1),
                whatsapp_status = %s 
                WHERE id = %d';
        
        $message_id = isset($waapi_data['id']) ? $waapi_data['id'] : null;
        $status = 'sent';
        
        return db_query($sql, $message_id, $status, $entry->getId());
    }
    
    /**
     * Reemplazar variables de objeto en plantilla
     */
    private function replaceObjectVariables($message, $key, $object) {
        $pattern = "/\%\{" . preg_quote($key) . "\.([^}]+)\}/";
        
        return preg_replace_callback($pattern, function($matches) use ($object) {
            $property = $matches[1];
            
            // Mapear propiedades comunes
            switch ($property) {
                case 'name':
                    return method_exists($object, 'getName') ? $object->getName() : '';
                case 'number':
                    return method_exists($object, 'getNumber') ? $object->getNumber() : '';
                case 'subject':
                    return method_exists($object, 'getSubject') ? $object->getSubject() : '';
                case 'created':
                    return method_exists($object, 'getCreateDate') ? $object->getCreateDate() : '';
                case 'updated':
                    return method_exists($object, 'getUpdateDate') ? $object->getUpdateDate() : '';
                default:
                    return '';
            }
        }, $message);
    }
    
    /**
     * Sincronizar datos WhatsApp del usuario
     */
    public function syncWhatsAppUserData($user) {
        if ($user->whatsapp_phone) {
            $this->associateUserWithPhone($user, $user->whatsapp_phone);
        }
    }
    
    /**
     * Obtener reporte de actividad WhatsApp
     */
    public function getActivityReport($days = 30) {
        $sql = 'SELECT 
                    DATE(created) as date,
                    direction,
                    COUNT(*) as count
                FROM ost_whatsapp_messages 
                WHERE created >= DATE_SUB(NOW(), INTERVAL %d DAY)
                GROUP BY DATE(created), direction
                ORDER BY date DESC';
        
        $result = array();
        $res = db_query($sql, $days);
        
        while ($row = db_fetch_array($res)) {
            $result[] = $row;
        }
        
        return $result;
    }
}
