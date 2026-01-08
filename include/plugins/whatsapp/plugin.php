<?php
/**
 * Plugin WhatsApp para osTicket
 * 
 * Integra WhatsApp como canal principal de comunicación usando WaAPI.app
 * Diseñado para ser completamente no invasivo y sobrevivir actualizaciones
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

require_once INCLUDE_DIR . 'class.plugin.php';
require_once INCLUDE_DIR . 'class.signal.php';
require_once INCLUDE_DIR . 'class.ticket.php';
require_once 'config.php';
require_once 'class.waapi.php';
require_once 'class.whatsapp-handler.php';

class WhatsAppPlugin extends Plugin {
    
    var $config_class = 'WhatsAppPluginConfig';
    
    /**
     * Información básica del plugin
     */
    function getInfo() {
        return array(
            'name' => 'WhatsApp Integration',
            'version' => '1.0.0',
            'description' => 'Integra WhatsApp como canal principal de comunicación usando WaAPI.app',
            'url' => 'https://github.com/quintana1308/osticket-whatsapp-plugin',
            'author' => 'quintana1308',
            'author_email' => 'aquintana@sistemasadn.com'
        );
    }
    
    /**
     * Inicialización del plugin
     * Se ejecuta cuando el plugin es cargado
     */
    function init() {
        // Cargar configuración del plugin
        $this->loadConfig();
        
        // Registrar hooks solo si el plugin está habilitado
        if ($this->isEnabled()) {
            $this->registerHooks();
        }
    }
    
    /**
     * Bootstrap del plugin
     * Se ejecuta cuando el plugin está activo
     */
    function bootstrap() {
        // Verificar que WaAPI esté configurado correctamente
        if (!$this->isConfigured()) {
            return false;
        }
        
        // Inicializar componentes del plugin
        $this->initializeComponents();
        
        // Registrar manejadores de eventos
        $this->registerEventHandlers();
        
        return true;
    }
    
    /**
     * Verificar si el plugin está habilitado
     */
    private function isEnabled() {
        $config = $this->getConfig();
        return $config && $config->get('enabled', false);
    }
    
    /**
     * Verificar si el plugin está configurado correctamente
     */
    private function isConfigured() {
        $config = $this->getConfig();
        
        if (!$config) return false;
        
        $required = ['api_token', 'instance_id', 'webhook_secret', 'business_phone'];
        
        foreach ($required as $field) {
            if (!$config->get($field)) {
                error_log("[WhatsApp Plugin] Configuración incompleta: falta $field");
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Cargar configuración del plugin
     */
    private function loadConfig() {
        // La configuración se carga automáticamente por la clase padre
        // Aquí podemos hacer validaciones adicionales si es necesario
    }
    
    /**
     * Inicializar componentes del plugin
     */
    private function initializeComponents() {
        // Inicializar WaAPI client
        $this->waapi = new WaAPIIntegration($this->getConfig());
        
        // Inicializar manejador de mensajes WhatsApp
        $this->handler = new WhatsAppHandler($this->getConfig(), $this->waapi);
        
        // Registrar logger personalizado
        $this->logger = new WhatsAppLogger();
    }
    
    /**
     * Registrar hooks de osTicket
     */
    private function registerHooks() {
        // Hooks de tickets
        Signal::connect('ticket.created', array($this, 'onTicketCreated'));
        Signal::connect('threadentry.created', array($this, 'onReplyCreated'));
        Signal::connect('ticket.assigned', array($this, 'onTicketAssigned'));
        Signal::connect('ticket.status.changed', array($this, 'onTicketStatusChanged'));
        
        // Hooks de usuarios
        Signal::connect('user.created', array($this, 'onUserCreated'));
        Signal::connect('user.updated', array($this, 'onUserUpdated'));
        
        // Hooks del sistema
        Signal::connect('system.install', array($this, 'onSystemInstall'));
        
        // Hooks de interfaz
        Signal::connect('admin.page.header', array($this, 'onAdminPageHeader'));
        Signal::connect('staff.page.header', array($this, 'onStaffPageHeader'));
    }
    
    /**
     * Registrar manejadores de eventos específicos
     */
    private function registerEventHandlers() {
        // Manejador para formularios de usuario
        Signal::connect('user.form.render', array($this, 'onUserFormRender'));
        
        // Manejador para vista de tickets
        Signal::connect('ticket.view.render', array($this, 'onTicketViewRender'));
        
        // Manejador para reportes personalizados
        Signal::connect('reports.custom', array($this, 'onCustomReports'));
    }
    
    /**
     * Evento: Ticket creado
     */
    function onTicketCreated($ticket) {
        try {
            // Solo procesar si el ticket fue creado por WhatsApp
            if ($ticket->getSource() == 'WhatsApp' || $ticket->whatsapp_enabled) {
                $this->handler->handleTicketCreated($ticket);
                $this->logger->log('INFO', "Ticket creado por WhatsApp: #{$ticket->getNumber()}", [
                    'ticket_id' => $ticket->getId(),
                    'phone' => $ticket->whatsapp_phone
                ]);
            }
        } catch (Exception $e) {
            $this->logger->log('ERROR', "Error procesando ticket creado: " . $e->getMessage(), [
                'ticket_id' => $ticket->getId(),
                'exception' => $e->getTraceAsString()
            ]);
        }
    }
    
    /**
     * Evento: Respuesta creada (threadentry)
     */
    function onReplyCreated($entry) {
        try {
            $thread = $entry->getThread();
            
            // Solo procesar si es un ticket con WhatsApp habilitado
            if ($thread->getObjectType() == 'T') {
                $ticket = $thread->getObject();
                
                if ($ticket && $ticket->whatsapp_enabled) {
                    // Verificar que no sea un mensaje entrante de WhatsApp (evitar loops)
                    if (!$entry->whatsapp_message_id) {
                        $this->handler->handleReplyCreated($ticket, $entry);
                        $this->logger->log('INFO', "Respuesta enviada por WhatsApp: #{$ticket->getNumber()}", [
                            'ticket_id' => $ticket->getId(),
                            'entry_id' => $entry->getId(),
                            'staff_id' => $entry->getStaffId()
                        ]);
                    }
                }
            }
        } catch (Exception $e) {
            $this->logger->log('ERROR', "Error procesando respuesta: " . $e->getMessage(), [
                'entry_id' => $entry->getId(),
                'exception' => $e->getTraceAsString()
            ]);
        }
    }
    
    /**
     * Evento: Ticket asignado
     */
    function onTicketAssigned($ticket, $staff) {
        try {
            if ($ticket->whatsapp_enabled) {
                $this->handler->handleTicketAssigned($ticket, $staff);
                $this->logger->log('INFO', "Ticket asignado notificado por WhatsApp: #{$ticket->getNumber()}", [
                    'ticket_id' => $ticket->getId(),
                    'staff_id' => $staff->getId(),
                    'phone' => $ticket->whatsapp_phone
                ]);
            }
        } catch (Exception $e) {
            $this->logger->log('ERROR', "Error notificando asignación: " . $e->getMessage(), [
                'ticket_id' => $ticket->getId(),
                'staff_id' => $staff->getId()
            ]);
        }
    }
    
    /**
     * Evento: Estado de ticket cambiado
     * Integra con sistema de permisos diferenciados (PERM_RESOLVE/PERM_CLOSE)
     */
    function onTicketStatusChanged($ticket, $old_status, $new_status) {
        try {
            if (!$ticket->whatsapp_enabled) return;
            
            global $thisstaff;
            
            // Verificar permisos según el sistema de permisos diferenciados
            if ($thisstaff && $thisstaff->getRole()) {
                $role = $thisstaff->getRole();
                
                // Integración con sistema de permisos diferenciados
                if ($new_status->getId() == 2) { // Estado "Resolved"
                    if ($role->hasPerm(Ticket::PERM_RESOLVE)) {
                        $this->handler->handleTicketResolved($ticket, $thisstaff);
                        $this->logger->log('INFO', "Ticket resuelto notificado por WhatsApp: #{$ticket->getNumber()}", [
                            'ticket_id' => $ticket->getId(),
                            'staff_id' => $thisstaff->getId(),
                            'permission' => 'PERM_RESOLVE'
                        ]);
                    }
                } elseif ($new_status->getState() == 'closed' && $new_status->getId() != 2) {
                    if ($role->hasPerm(Ticket::PERM_CLOSE)) {
                        $this->handler->handleTicketClosed($ticket, $thisstaff);
                        $this->logger->log('INFO', "Ticket cerrado notificado por WhatsApp: #{$ticket->getNumber()}", [
                            'ticket_id' => $ticket->getId(),
                            'staff_id' => $thisstaff->getId(),
                            'permission' => 'PERM_CLOSE'
                        ]);
                    }
                }
            }
        } catch (Exception $e) {
            $this->logger->log('ERROR', "Error notificando cambio de estado: " . $e->getMessage(), [
                'ticket_id' => $ticket->getId(),
                'old_status' => $old_status->getId(),
                'new_status' => $new_status->getId()
            ]);
        }
    }
    
    /**
     * Evento: Usuario creado
     */
    function onUserCreated($user) {
        try {
            // Si el usuario fue creado desde WhatsApp, asociar número
            if (isset($_SESSION['whatsapp_phone'])) {
                $phone = $_SESSION['whatsapp_phone'];
                $this->handler->associateUserWithPhone($user, $phone);
                unset($_SESSION['whatsapp_phone']);
                
                $this->logger->log('INFO', "Usuario asociado con WhatsApp", [
                    'user_id' => $user->getId(),
                    'phone' => $phone
                ]);
            }
        } catch (Exception $e) {
            $this->logger->log('ERROR', "Error asociando usuario con WhatsApp: " . $e->getMessage(), [
                'user_id' => $user->getId()
            ]);
        }
    }
    
    /**
     * Evento: Usuario actualizado
     */
    function onUserUpdated($user) {
        try {
            // Sincronizar cambios de número WhatsApp
            $this->handler->syncWhatsAppUserData($user);
        } catch (Exception $e) {
            $this->logger->log('ERROR', "Error sincronizando datos WhatsApp del usuario: " . $e->getMessage(), [
                'user_id' => $user->getId()
            ]);
        }
    }
    
    /**
     * Evento: Instalación del sistema
     */
    function onSystemInstall() {
        // Ejecutar migraciones del plugin si es necesario
        $this->runMigrations();
    }
    
    /**
     * Evento: Header de página de administración
     */
    function onAdminPageHeader() {
        // Inyectar CSS/JS solo en páginas relevantes
        if (strpos($_SERVER['REQUEST_URI'], 'tickets.php') !== false ||
            strpos($_SERVER['REQUEST_URI'], 'users.php') !== false ||
            strpos($_SERVER['REQUEST_URI'], 'plugins.php') !== false) {
            
            $plugin_url = $this->getPluginUrl();
            echo '<link rel="stylesheet" href="' . $plugin_url . 'assets/css/whatsapp.css">';
            echo '<script src="' . $plugin_url . 'assets/js/whatsapp.js"></script>';
        }
    }
    
    /**
     * Evento: Header de página de staff
     */
    function onStaffPageHeader() {
        // Similar al admin, pero para páginas de staff
        if (strpos($_SERVER['REQUEST_URI'], 'tickets.php') !== false) {
            $plugin_url = $this->getPluginUrl();
            echo '<link rel="stylesheet" href="' . $plugin_url . 'assets/css/whatsapp.css">';
            echo '<script src="' . $plugin_url . 'assets/js/whatsapp.js"></script>';
        }
    }
    
    /**
     * Evento: Renderizar formulario de usuario
     */
    function onUserFormRender($form) {
        // Agregar campo WhatsApp al formulario de usuario
        $form->addField('whatsapp_phone', new TextboxField(array(
            'label' => 'Número WhatsApp',
            'configuration' => array(
                'placeholder' => '+54 9 11 1234-5678',
                'size' => 20,
                'length' => 20
            )
        )));
    }
    
    /**
     * Evento: Renderizar vista de ticket
     */
    function onTicketViewRender($ticket, $options) {
        // Mostrar información WhatsApp en vista de ticket
        if ($ticket->whatsapp_enabled && $ticket->whatsapp_phone) {
            echo '<div class="whatsapp-info">';
            echo '<i class="icon-whatsapp"></i> ';
            echo '<strong>WhatsApp:</strong> ' . Format::htmlchars($ticket->whatsapp_phone);
            echo ' <span class="whatsapp-status">Activo</span>';
            echo '</div>';
        }
    }
    
    /**
     * Evento: Reportes personalizados
     */
    function onCustomReports($reports) {
        $reports['whatsapp_activity'] = array(
            'name' => 'Actividad WhatsApp',
            'description' => 'Estadísticas de mensajes y tickets WhatsApp',
            'callback' => array($this, 'generateWhatsAppReport')
        );
    }
    
    /**
     * Generar reporte de actividad WhatsApp
     */
    function generateWhatsAppReport($period = 30) {
        return $this->handler->getActivityReport($period);
    }
    
    /**
     * Ejecutar migraciones del plugin
     */
    private function runMigrations() {
        try {
            $migration_dir = dirname(__FILE__) . '/migrations/';
            $migrations = glob($migration_dir . '*.sql');
            
            foreach ($migrations as $migration) {
                $sql = file_get_contents($migration);
                if ($sql) {
                    db_query($sql);
                    $this->logger->log('INFO', "Migración ejecutada: " . basename($migration));
                }
            }
        } catch (Exception $e) {
            $this->logger->log('ERROR', "Error ejecutando migraciones: " . $e->getMessage());
        }
    }
    
    /**
     * Obtener URL base del plugin
     */
    private function getPluginUrl() {
        return ROOT_PATH . 'include/plugins/whatsapp/';
    }
    
    /**
     * Método para desinstalar el plugin
     */
    function uninstall() {
        // Desregistrar hooks
        $this->unregisterHooks();
        
        // Limpiar configuración (opcional)
        // Los datos se mantienen por defecto
        
        return true;
    }
    
    /**
     * Desregistrar hooks
     */
    private function unregisterHooks() {
        // osTicket maneja esto automáticamente cuando el plugin se desactiva
    }
    
    /**
     * Validar configuración del plugin
     */
    function validateConfig($config) {
        $errors = array();
        
        // Validar token API
        if (!$config['api_token']) {
            $errors['api_token'] = 'Token API de WaAPI.app es requerido';
        }
        
        // Validar instance ID
        if (!$config['instance_id']) {
            $errors['instance_id'] = 'Instance ID de WaAPI.app es requerido';
        }
        
        // Validar webhook secret
        if (!$config['webhook_secret']) {
            $errors['webhook_secret'] = 'Webhook Secret es requerido';
        }
        
        // Validar número de teléfono business
        if (!$config['business_phone']) {
            $errors['business_phone'] = 'Número WhatsApp Business es requerido';
        } elseif (!$this->handler->validatePhoneNumber($config['business_phone'])) {
            $errors['business_phone'] = 'Formato de número WhatsApp inválido';
        }
        
        return $errors;
    }
}

/**
 * Logger personalizado para el plugin WhatsApp
 */
class WhatsAppLogger {
    
    function log($level, $message, $context = array()) {
        // Usar sistema de logs de osTicket
        if (class_exists('SystemLog')) {
            SystemLog::log($level, '[WhatsApp] ' . $message, $context);
        } else {
            error_log("[WhatsApp] [$level] $message");
        }
        
        // También guardar en tabla específica del plugin
        try {
            db_query('INSERT INTO ost_whatsapp_logs (level, message, context, created) 
                      VALUES (%s, %s, %s, NOW())', 
                     $level, $message, json_encode($context));
        } catch (Exception $e) {
            error_log("[WhatsApp Logger] Error guardando log: " . $e->getMessage());
        }
    }
}

// Registrar el plugin en osTicket
return new WhatsAppPlugin();
