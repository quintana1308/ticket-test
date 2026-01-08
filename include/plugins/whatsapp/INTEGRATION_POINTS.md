# 🔗 Puntos de Integración No Invasivos - Plugin WhatsApp

## 📋 Filosofía de Integración

El plugin WhatsApp está diseñado para integrarse con osTicket usando **únicamente hooks y eventos públicos**, sin modificar el código core del sistema. Esto garantiza que el plugin sobreviva a todas las actualizaciones de osTicket.

## 🎯 Hooks y Eventos de osTicket Utilizados

### 1. Eventos de Tickets

#### `ticket.created`
```php
Signal::connect('ticket.created', array($this, 'onTicketCreated'));

function onTicketCreated($ticket) {
    // Solo procesar si el ticket fue creado por WhatsApp
    if ($ticket->getSource() == 'WhatsApp') {
        $this->sendWelcomeMessage($ticket);
    }
}
```

#### `threadentry.created`
```php
Signal::connect('threadentry.created', array($this, 'onReplyCreated'));

function onReplyCreated($entry) {
    $thread = $entry->getThread();
    if ($thread->getObjectType() == 'T') { // Ticket
        $ticket = $thread->getObject();
        if ($ticket->whatsapp_enabled) {
            $this->sendReplyToWhatsApp($ticket, $entry);
        }
    }
}
```

#### `ticket.assigned`
```php
Signal::connect('ticket.assigned', array($this, 'onTicketAssigned'));

function onTicketAssigned($ticket, $staff) {
    if ($ticket->whatsapp_enabled) {
        $this->notifyAssignment($ticket, $staff);
    }
}
```

#### `ticket.status.changed`
```php
Signal::connect('ticket.status.changed', array($this, 'onStatusChanged'));

function onStatusChanged($ticket, $old_status, $new_status) {
    if ($ticket->whatsapp_enabled) {
        // Integrar con sistema de permisos diferenciados
        $this->handleStatusChangeNotification($ticket, $old_status, $new_status);
    }
}
```

### 2. Eventos de Usuario

#### `user.created`
```php
Signal::connect('user.created', array($this, 'onUserCreated'));

function onUserCreated($user) {
    // Si el usuario fue creado desde WhatsApp, asociar número
    if (isset($_SESSION['whatsapp_phone'])) {
        $this->associatePhoneWithUser($user, $_SESSION['whatsapp_phone']);
    }
}
```

#### `user.updated`
```php
Signal::connect('user.updated', array($this, 'onUserUpdated'));

function onUserUpdated($user) {
    // Sincronizar cambios de número WhatsApp
    $this->syncWhatsAppUserData($user);
}
```

### 3. Eventos del Sistema

#### `system.install`
```php
Signal::connect('system.install', array($this, 'onSystemInstall'));

function onSystemInstall() {
    // Ejecutar migraciones del plugin si es necesario
    $this->runMigrations();
}
```

## 🔧 Integración con Sistema de Permisos Diferenciados

### Respeto a PERM_RESOLVE vs PERM_CLOSE

```php
function handleStatusChangeNotification($ticket, $old_status, $new_status) {
    global $thisstaff;
    
    // Obtener el rol del staff que hizo el cambio
    $role = $thisstaff->getRole();
    
    // Verificar permisos según el sistema existente
    if ($new_status->getId() == 2) { // Estado "Resolved"
        if ($role->hasPerm(Ticket::PERM_RESOLVE)) {
            $this->sendResolvedNotification($ticket);
        }
    } elseif ($new_status->getState() == 'closed' && $new_status->getId() != 2) {
        if ($role->hasPerm(Ticket::PERM_CLOSE)) {
            $this->sendClosedNotification($ticket);
        }
    }
}
```

### Restricciones para Analistas

```php
function validateAnalystRestrictions($ticket, $staff) {
    $role = $staff->getRole();
    
    // Si es analista (solo PERM_RESOLVE, no PERM_CLOSE)
    if ($role->hasPerm(Ticket::PERM_RESOLVE) && !$role->hasPerm(Ticket::PERM_CLOSE)) {
        $currentStatus = $ticket->getStatus();
        
        // Restricción: Analistas no pueden modificar tickets ya resueltos
        if ($currentStatus && $currentStatus->getId() == 2) {
            return false; // No permitir modificaciones
        }
    }
    
    return true;
}
```

## 🔌 Puntos de Extensión del Plugin

### 1. API Controller Extension

```php
// Extender TicketApiController para manejar creación desde WhatsApp
class WhatsAppTicketController extends TicketApiController {
    
    function createFromWhatsApp($phone, $message, $attachments = []) {
        // Usar API interna de osTicket para crear ticket
        $data = $this->prepareTicketData($phone, $message, $attachments);
        return parent::create($data);
    }
    
    private function prepareTicketData($phone, $message, $attachments) {
        return [
            'source' => 'WhatsApp',
            'message' => $message,
            'attachments' => $attachments,
            // Otros campos requeridos
        ];
    }
}
```

### 2. User Form Extension

```php
// Agregar campo WhatsApp al formulario de usuario
Signal::connect('user.form.render', function($form) {
    $form->addField('whatsapp_phone', new TextboxField([
        'label' => 'Número WhatsApp',
        'configuration' => [
            'placeholder' => '+54 9 11 1234-5678',
            'validator' => 'phone'
        ]
    ]));
});
```

### 3. Ticket View Extension

```php
// Agregar información WhatsApp en vista de ticket
Signal::connect('ticket.view.render', function($ticket, $options) {
    if ($ticket->whatsapp_enabled) {
        echo '<div class="whatsapp-info">';
        echo '<i class="icon-whatsapp"></i> ';
        echo 'WhatsApp: ' . $ticket->whatsapp_phone;
        echo '</div>';
    }
});
```

## 📊 Integración con Reportes

### Custom Reports Extension

```php
// Agregar reportes WhatsApp al sistema
Signal::connect('reports.custom', function($reports) {
    $reports['whatsapp_activity'] = [
        'name' => 'Actividad WhatsApp',
        'description' => 'Estadísticas de mensajes WhatsApp',
        'callback' => array('WhatsAppReports', 'getActivityReport')
    ];
});
```

## 🔄 Workflow de Integración

### 1. Mensaje Entrante (WhatsApp → osTicket)

```
1. Webhook recibe mensaje de WaAPI.app
2. Plugin valida y procesa mensaje
3. Busca usuario existente o crea nuevo
4. Determina si es ticket nuevo o respuesta
5. Usa TicketApiController para crear/actualizar
6. Dispara eventos normales de osTicket
7. Otros plugins pueden reaccionar normalmente
```

### 2. Mensaje Saliente (osTicket → WhatsApp)

```
1. Agente responde en osTicket normalmente
2. Hook 'threadentry.created' captura respuesta
3. Plugin valida si ticket tiene WhatsApp habilitado
4. Verifica permisos del agente (PERM_RESOLVE/PERM_CLOSE)
5. Formatea mensaje para WhatsApp
6. Envía vía WaAPI.app
7. Actualiza estado en base de datos
```

## 🛡️ Validaciones de Seguridad No Invasivas

### Rate Limiting

```php
function checkRateLimit($phone) {
    $count = db_count('SELECT COUNT(*) FROM ost_whatsapp_messages 
                      WHERE phone_number = %s 
                      AND created > DATE_SUB(NOW(), INTERVAL 1 MINUTE)', $phone);
    
    return $count < $this->config->get('rate_limit', 10);
}
```

### Webhook Validation

```php
function validateWebhook($signature, $payload) {
    $expected = hash_hmac('sha256', $payload, $this->config->get('webhook_secret'));
    return hash_equals($signature, $expected);
}
```

## 🔧 Configuración Dinámica

### Plugin Configuration Interface

```php
class WhatsAppPluginConfig extends PluginConfig {
    
    function getOptions() {
        return [
            'api_token' => new TextboxField([
                'label' => 'Token API WaAPI.app',
                'required' => true,
                'configuration' => ['size' => 60]
            ]),
            'instance_id' => new TextboxField([
                'label' => 'Instance ID',
                'required' => true
            ]),
            'webhook_secret' => new TextboxField([
                'label' => 'Webhook Secret',
                'required' => true,
                'configuration' => ['size' => 40]
            ]),
            'business_phone' => new PhoneField([
                'label' => 'Número WhatsApp Business',
                'required' => true
            ]),
            'default_dept' => new ChoiceField([
                'label' => 'Departamento por Defecto',
                'choices' => Dept::getDepartments()
            ]),
            'rate_limit' => new TextboxField([
                'label' => 'Límite de Mensajes por Minuto',
                'default' => 10,
                'configuration' => ['validator' => 'number']
            ])
        ];
    }
}
```

## 📝 Logging No Invasivo

### Custom Log Handler

```php
class WhatsAppLogger {
    
    static function log($level, $message, $context = []) {
        // Usar sistema de logs de osTicket
        $log = new SystemLog();
        $log->log($level, '[WhatsApp] ' . $message, $context);
        
        // También guardar en tabla específica del plugin
        db_query('INSERT INTO ost_whatsapp_logs (level, message, context, created) 
                  VALUES (%s, %s, %s, NOW())', 
                 $level, $message, json_encode($context));
    }
}
```

## 🎨 UI Extensions

### CSS/JS Injection

```php
// Inyectar estilos y scripts solo cuando sea necesario
Signal::connect('admin.page.header', function() {
    if (strpos($_SERVER['REQUEST_URI'], 'tickets.php') !== false) {
        echo '<link rel="stylesheet" href="' . PLUGIN_URL . 'whatsapp/assets/css/whatsapp.css">';
        echo '<script src="' . PLUGIN_URL . 'whatsapp/assets/js/whatsapp.js"></script>';
    }
});
```

## ✅ Ventajas de esta Arquitectura

1. **Supervivencia a Actualizaciones**: Cero modificaciones al core
2. **Compatibilidad Total**: Funciona con sistema de permisos existente
3. **Modularidad**: Plugin se puede activar/desactivar sin afectar osTicket
4. **Extensibilidad**: Otros plugins pueden integrarse con este
5. **Mantenibilidad**: Código separado y organizado
6. **Testabilidad**: Se puede probar independientemente

## 🔄 Proceso de Activación/Desactivación

### Activación
```php
function activate() {
    // Registrar todos los hooks
    $this->registerHooks();
    
    // Ejecutar migraciones si es necesario
    $this->runMigrations();
    
    // Configurar webhook en WaAPI.app
    $this->setupWebhook();
}
```

### Desactivación
```php
function deactivate() {
    // Desregistrar hooks
    $this->unregisterHooks();
    
    // Desactivar webhook (mantener datos)
    $this->disableWebhook();
}
```

---

**Nota:** Esta arquitectura garantiza que el plugin WhatsApp funcione como un componente completamente independiente, respetando la integridad del sistema osTicket y manteniéndose compatible con todas las funcionalidades existentes, incluyendo el sistema de permisos diferenciados implementado.
