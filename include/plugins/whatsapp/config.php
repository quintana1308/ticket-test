<?php
/**
 * Configuración del Plugin WhatsApp para osTicket
 * 
 * Maneja toda la configuración del plugin incluyendo credenciales WaAPI.app,
 * configuraciones de departamento, plantillas y opciones avanzadas
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

require_once INCLUDE_DIR . 'class.plugin.php';
require_once INCLUDE_DIR . 'class.forms.php';

class WhatsAppPluginConfig extends PluginConfig {
    
    /**
     * Configuraciones por defecto del plugin
     */
    var $defaults = array(
        'enabled' => false,
        'api_token' => '',
        'instance_id' => '',
        'webhook_url' => '',
        'webhook_secret' => '',
        'business_phone' => '',
        'default_dept_id' => 0,
        'rate_limit' => 50,
        'auto_create_users' => true,
        'auto_reply_enabled' => true,
        'debug_mode' => false,
        'message_retention_days' => 90,
        'max_attachment_size' => 16777216, // 16MB
        'allowed_file_types' => 'jpg,jpeg,png,gif,pdf,doc,docx,txt,zip',
        'welcome_template' => 'welcome',
        'ticket_created_template' => 'ticket_created',
        'agent_reply_template' => 'agent_reply',
        'ticket_resolved_template' => 'ticket_resolved',
        'ticket_closed_template' => 'ticket_closed'
    );
    
    /**
     * Obtener opciones de configuración del plugin
     */
    function getOptions() {
        // Obtener lista de departamentos para selector
        $departments = array(0 => '-- Seleccionar Departamento --');
        foreach (Dept::getDepartments() as $id => $name) {
            $departments[$id] = $name;
        }
        
        // Obtener plantillas disponibles
        $templates = $this->getAvailableTemplates();
        
        return array(
            // Configuración General
            'general_section' => new SectionBreakField(array(
                'label' => 'Configuración General'
            )),
            
            'enabled' => new BooleanField(array(
                'label' => 'Habilitar Plugin WhatsApp',
                'default' => false,
                'configuration' => array(
                    'desc' => 'Activar/desactivar la integración WhatsApp'
                )
            )),
            
            'debug_mode' => new BooleanField(array(
                'label' => 'Modo Debug',
                'default' => false,
                'configuration' => array(
                    'desc' => 'Habilitar logs detallados para debugging'
                )
            )),
            
            // Configuración WaAPI.app
            'waapi_section' => new SectionBreakField(array(
                'label' => 'Configuración WaAPI.app'
            )),
            
            'api_token' => new TextboxField(array(
                'label' => 'Token API WaAPI.app',
                'required' => true,
                'configuration' => array(
                    'size' => 60,
                    'length' => 255,
                    'placeholder' => 'Ingrese su token de API de WaAPI.app',
                    'desc' => 'Token de autenticación para la API de WaAPI.app'
                )
            )),
            
            'instance_id' => new TextboxField(array(
                'label' => 'Instance ID',
                'required' => true,
                'configuration' => array(
                    'size' => 40,
                    'length' => 100,
                    'placeholder' => 'ID de su instancia WaAPI',
                    'desc' => 'Identificador único de su instancia WhatsApp en WaAPI.app'
                )
            )),
            
            'webhook_secret' => new TextboxField(array(
                'label' => 'Webhook Secret',
                'required' => true,
                'configuration' => array(
                    'size' => 40,
                    'length' => 255,
                    'placeholder' => 'Secreto para validar webhooks',
                    'desc' => 'Clave secreta para validar la autenticidad de los webhooks'
                )
            )),
            
            'business_phone' => new PhoneField(array(
                'label' => 'Número WhatsApp Business',
                'required' => true,
                'configuration' => array(
                    'placeholder' => '+54 9 11 1234-5678',
                    'desc' => 'Número de WhatsApp Business configurado en WaAPI.app'
                )
            )),
            
            'webhook_url' => new TextboxField(array(
                'label' => 'URL del Webhook',
                'configuration' => array(
                    'size' => 80,
                    'length' => 255,
                    'readonly' => true,
                    'default' => $this->getWebhookUrl(),
                    'desc' => 'URL que debe configurar en WaAPI.app para recibir webhooks'
                )
            )),
            
            // Configuración de Tickets
            'tickets_section' => new SectionBreakField(array(
                'label' => 'Configuración de Tickets'
            )),
            
            'default_dept_id' => new ChoiceField(array(
                'label' => 'Departamento por Defecto',
                'choices' => $departments,
                'default' => 0,
                'configuration' => array(
                    'desc' => 'Departamento donde se crearán los tickets de WhatsApp por defecto'
                )
            )),
            
            'auto_create_users' => new BooleanField(array(
                'label' => 'Crear Usuarios Automáticamente',
                'default' => true,
                'configuration' => array(
                    'desc' => 'Crear automáticamente usuarios para números WhatsApp desconocidos'
                )
            )),
            
            'auto_reply_enabled' => new BooleanField(array(
                'label' => 'Respuestas Automáticas',
                'default' => true,
                'configuration' => array(
                    'desc' => 'Enviar mensajes automáticos usando plantillas configuradas'
                )
            )),
            
            // Configuración de Seguridad
            'security_section' => new SectionBreakField(array(
                'label' => 'Configuración de Seguridad'
            )),
            
            'rate_limit' => new TextboxField(array(
                'label' => 'Límite de Mensajes por Minuto',
                'default' => 50,
                'configuration' => array(
                    'size' => 10,
                    'validator' => 'number',
                    'desc' => 'Número máximo de mensajes por minuto por usuario'
                )
            )),
            
            'max_attachment_size' => new ChoiceField(array(
                'label' => 'Tamaño Máximo de Archivos',
                'choices' => array(
                    '1048576' => '1 MB',
                    '5242880' => '5 MB',
                    '10485760' => '10 MB',
                    '16777216' => '16 MB',
                    '33554432' => '32 MB'
                ),
                'default' => '16777216',
                'configuration' => array(
                    'desc' => 'Tamaño máximo permitido para archivos adjuntos'
                )
            )),
            
            'allowed_file_types' => new TextboxField(array(
                'label' => 'Tipos de Archivo Permitidos',
                'default' => 'jpg,jpeg,png,gif,pdf,doc,docx,txt,zip',
                'configuration' => array(
                    'size' => 60,
                    'placeholder' => 'jpg,jpeg,png,pdf,doc,docx',
                    'desc' => 'Extensiones de archivo permitidas (separadas por comas)'
                )
            )),
            
            // Configuración de Plantillas
            'templates_section' => new SectionBreakField(array(
                'label' => 'Plantillas de Mensajes'
            )),
            
            'welcome_template' => new ChoiceField(array(
                'label' => 'Plantilla de Bienvenida',
                'choices' => $templates,
                'default' => 'welcome',
                'configuration' => array(
                    'desc' => 'Mensaje enviado al primer contacto del usuario'
                )
            )),
            
            'ticket_created_template' => new ChoiceField(array(
                'label' => 'Plantilla Ticket Creado',
                'choices' => $templates,
                'default' => 'ticket_created',
                'configuration' => array(
                    'desc' => 'Mensaje enviado cuando se crea un nuevo ticket'
                )
            )),
            
            'agent_reply_template' => new ChoiceField(array(
                'label' => 'Plantilla Respuesta Agente',
                'choices' => $templates,
                'default' => 'agent_reply',
                'configuration' => array(
                    'desc' => 'Formato para respuestas de agentes'
                )
            )),
            
            'ticket_resolved_template' => new ChoiceField(array(
                'label' => 'Plantilla Ticket Resuelto',
                'choices' => $templates,
                'default' => 'ticket_resolved',
                'configuration' => array(
                    'desc' => 'Mensaje enviado cuando se resuelve un ticket'
                )
            )),
            
            'ticket_closed_template' => new ChoiceField(array(
                'label' => 'Plantilla Ticket Cerrado',
                'choices' => $templates,
                'default' => 'ticket_closed',
                'configuration' => array(
                    'desc' => 'Mensaje enviado cuando se cierra un ticket'
                )
            )),
            
            // Configuración de Mantenimiento
            'maintenance_section' => new SectionBreakField(array(
                'label' => 'Mantenimiento'
            )),
            
            'message_retention_days' => new TextboxField(array(
                'label' => 'Días de Retención de Mensajes',
                'default' => 90,
                'configuration' => array(
                    'size' => 10,
                    'validator' => 'number',
                    'desc' => 'Días que se conservan los mensajes antes de ser archivados'
                )
            ))
        );
    }
    
    /**
     * Obtener opciones del formulario
     */
    function getFormOptions() {
        return array(
            'title' => 'Configuración Plugin WhatsApp',
            'instructions' => 'Configure la integración WhatsApp con WaAPI.app. Asegúrese de tener una instancia activa en WaAPI.app antes de continuar.',
            'layout' => 'vertical'
        );
    }
    
    /**
     * Validaciones antes de guardar configuración
     */
    function pre_save(&$config, &$errors) {
        // Validar token API
        if (empty($config['api_token'])) {
            $errors['api_token'] = 'El token API de WaAPI.app es requerido';
        }
        
        // Validar instance ID
        if (empty($config['instance_id'])) {
            $errors['instance_id'] = 'El Instance ID es requerido';
        }
        
        // Validar webhook secret
        if (empty($config['webhook_secret'])) {
            $errors['webhook_secret'] = 'El Webhook Secret es requerido';
        } elseif (strlen($config['webhook_secret']) < 16) {
            $errors['webhook_secret'] = 'El Webhook Secret debe tener al menos 16 caracteres';
        }
        
        // Validar número de teléfono business
        if (empty($config['business_phone'])) {
            $errors['business_phone'] = 'El número WhatsApp Business es requerido';
        } elseif (!$this->validatePhoneNumber($config['business_phone'])) {
            $errors['business_phone'] = 'Formato de número WhatsApp inválido';
        }
        
        // Validar rate limit
        if (!is_numeric($config['rate_limit']) || $config['rate_limit'] < 1) {
            $errors['rate_limit'] = 'El límite de mensajes debe ser un número mayor a 0';
        }
        
        // Validar días de retención
        if (!is_numeric($config['message_retention_days']) || $config['message_retention_days'] < 1) {
            $errors['message_retention_days'] = 'Los días de retención deben ser un número mayor a 0';
        }
        
        // Validar tipos de archivo
        if (!empty($config['allowed_file_types'])) {
            $types = explode(',', $config['allowed_file_types']);
            foreach ($types as $type) {
                $type = trim($type);
                if (!preg_match('/^[a-zA-Z0-9]+$/', $type)) {
                    $errors['allowed_file_types'] = 'Tipos de archivo inválidos. Use solo letras y números separados por comas';
                    break;
                }
            }
        }
        
        // Si está habilitado, probar conexión con WaAPI
        if ($config['enabled'] && !empty($config['api_token']) && !empty($config['instance_id'])) {
            if (!$this->testWaAPIConnection($config)) {
                $errors['api_token'] = 'No se pudo conectar con WaAPI.app. Verifique sus credenciales';
            }
        }
        
        return count($errors) === 0;
    }
    
    /**
     * Validar formato de número de teléfono WhatsApp
     */
    private function validatePhoneNumber($phone) {
        // Remover caracteres no numéricos
        $clean = preg_replace('/[^0-9]/', '', $phone);
        
        // Validar longitud (8-15 dígitos según estándar internacional)
        if (strlen($clean) < 8 || strlen($clean) > 15) {
            return false;
        }
        
        // Validar que no empiece con 00
        if (substr($clean, 0, 2) === '00') {
            return false;
        }
        
        return true;
    }
    
    /**
     * Probar conexión con WaAPI.app
     */
    private function testWaAPIConnection($config) {
        try {
            $url = 'https://waapi.app/api/v1/instances/' . $config['instance_id'] . '/status';
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 10);
            curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                'Authorization: Bearer ' . $config['api_token'],
                'Content-Type: application/json'
            ));
            
            $response = curl_exec($ch);
            $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            return $http_code === 200;
        } catch (Exception $e) {
            return false;
        }
    }
    
    /**
     * Obtener URL del webhook
     */
    private function getWebhookUrl() {
        $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'];
        $path = dirname($_SERVER['REQUEST_URI']);
        
        // Construir URL del webhook
        $webhook_url = $protocol . '://' . $host . rtrim($path, '/') . '/include/plugins/whatsapp/webhook.php';
        
        return $webhook_url;
    }
    
    /**
     * Obtener plantillas disponibles
     */
    private function getAvailableTemplates() {
        $templates = array('' => '-- Sin plantilla --');
        
        try {
            $sql = 'SELECT code, name FROM ost_whatsapp_templates WHERE enabled = 1 ORDER BY name';
            $res = db_query($sql);
            
            while ($row = db_fetch_array($res)) {
                $templates[$row['code']] = $row['name'];
            }
        } catch (Exception $e) {
            // Si no existen las tablas aún, usar plantillas por defecto
            $templates = array(
                '' => '-- Sin plantilla --',
                'welcome' => 'Bienvenida',
                'ticket_created' => 'Ticket Creado',
                'agent_reply' => 'Respuesta de Agente',
                'ticket_resolved' => 'Ticket Resuelto',
                'ticket_closed' => 'Ticket Cerrado'
            );
        }
        
        return $templates;
    }
    
    /**
     * Obtener configuración con valores por defecto
     */
    function get($key, $default = null) {
        $value = parent::get($key, $default);
        
        // Si no hay valor, usar el default definido
        if ($value === null && isset($this->defaults[$key])) {
            return $this->defaults[$key];
        }
        
        return $value;
    }
    
    /**
     * Verificar si el plugin está completamente configurado
     */
    function isConfigured() {
        $required = array('api_token', 'instance_id', 'webhook_secret', 'business_phone');
        
        foreach ($required as $field) {
            if (!$this->get($field)) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Obtener configuración para WaAPI client
     */
    function getWaAPIConfig() {
        return array(
            'api_token' => $this->get('api_token'),
            'instance_id' => $this->get('instance_id'),
            'webhook_secret' => $this->get('webhook_secret'),
            'base_url' => 'https://waapi.app/api/v1/',
            'timeout' => 30,
            'retry_attempts' => 3
        );
    }
    
    /**
     * Obtener configuración de rate limiting
     */
    function getRateLimitConfig() {
        return array(
            'messages_per_minute' => (int) $this->get('rate_limit', 50),
            'burst_limit' => (int) $this->get('rate_limit', 50) * 2,
            'window_size' => 60 // segundos
        );
    }
    
    /**
     * Obtener configuración de archivos
     */
    function getFileConfig() {
        return array(
            'max_size' => (int) $this->get('max_attachment_size', 16777216),
            'allowed_types' => explode(',', $this->get('allowed_file_types', 'jpg,jpeg,png,gif,pdf,doc,docx,txt,zip')),
            'upload_path' => ROOT_DIR . 'attachments/whatsapp/'
        );
    }
}
