# 📱 WaAPI.app - Especificaciones de Integración

## 🔗 Información de la API

**URL Base:** `https://waapi.app/api/v1/`  
**Documentación:** https://waapi.readme.io  
**Método de Autenticación:** Bearer Token  
**Formato de Datos:** JSON

## 📋 Endpoints Principales

### 1. Envío de Mensajes
```http
POST /instances/{instance_id}/client/action/send-message
Authorization: Bearer {token}
Content-Type: application/json

{
    "chatId": "5491234567890@c.us",
    "message": "Hola, tu ticket #12345 ha sido creado exitosamente."
}
```

### 2. Envío de Archivos
```http
POST /instances/{instance_id}/client/action/send-media
Authorization: Bearer {token}
Content-Type: application/json

{
    "chatId": "5491234567890@c.us",
    "media": {
        "file": "base64_encoded_file",
        "filename": "documento.pdf",
        "caption": "Adjunto del ticket #12345"
    }
}
```

### 3. Configuración de Webhook
```http
POST /instances/{instance_id}/webhook
Authorization: Bearer {token}
Content-Type: application/json

{
    "webhook": "https://tu-osticket.com/include/plugins/whatsapp/webhook.php",
    "events": ["message", "ack", "ready"]
}
```

## 📨 Estructura de Webhooks Entrantes

### Mensaje de Texto
```json
{
    "event": "message",
    "instance_id": "tu_instancia_id",
    "data": {
        "key": {
            "remoteJid": "5491234567890@c.us",
            "fromMe": false,
            "id": "mensaje_id_unico"
        },
        "message": {
            "conversation": "Hola, necesito ayuda con mi pedido"
        },
        "messageTimestamp": 1641234567,
        "pushName": "Juan Pérez"
    }
}
```

### Mensaje con Archivo
```json
{
    "event": "message",
    "instance_id": "tu_instancia_id",
    "data": {
        "key": {
            "remoteJid": "5491234567890@c.us",
            "fromMe": false,
            "id": "mensaje_id_unico"
        },
        "message": {
            "documentMessage": {
                "url": "https://waapi.app/media/documento.pdf",
                "mimetype": "application/pdf",
                "title": "factura.pdf",
                "fileLength": 12345
            }
        },
        "messageTimestamp": 1641234567,
        "pushName": "Juan Pérez"
    }
}
```

### Confirmación de Entrega (ACK)
```json
{
    "event": "ack",
    "instance_id": "tu_instancia_id",
    "data": {
        "key": {
            "remoteJid": "5491234567890@c.us",
            "fromMe": true,
            "id": "mensaje_id_unico"
        },
        "ack": 2,
        "ackString": "delivered"
    }
}
```

## 🔐 Configuraciones de Seguridad

### Validación de Webhook
```php
function validateWebhook($signature, $payload, $secret) {
    $expected = hash_hmac('sha256', $payload, $secret);
    return hash_equals($signature, $expected);
}
```

### Rate Limiting
- **Límite por minuto:** 60 mensajes
- **Límite por hora:** 1000 mensajes  
- **Límite diario:** 10000 mensajes

## 📞 Formato de Números de Teléfono

### Formato Internacional
```
Correcto: 5491234567890@c.us
Incorrecto: +54 9 11 2345-6789
```

### Validación de Números
```php
function validatePhoneNumber($phone) {
    // Remover caracteres no numéricos
    $clean = preg_replace('/[^0-9]/', '', $phone);
    
    // Validar longitud (8-15 dígitos)
    if (strlen($clean) < 8 || strlen($clean) > 15) {
        return false;
    }
    
    // Agregar formato WhatsApp
    return $clean . '@c.us';
}
```

## ⚙️ Configuraciones del Plugin

### Variables de Entorno Requeridas
```php
define('WAAPI_BASE_URL', 'https://waapi.app/api/v1/');
define('WAAPI_INSTANCE_ID', 'tu_instancia_id');
define('WAAPI_TOKEN', 'tu_token_secreto');
define('WAAPI_WEBHOOK_SECRET', 'tu_webhook_secret');
```

### Configuraciones Opcionales
```php
define('WAAPI_TIMEOUT', 30); // segundos
define('WAAPI_RETRY_ATTEMPTS', 3);
define('WAAPI_RATE_LIMIT', 50); // mensajes por minuto
```

## 🚨 Manejo de Errores

### Códigos de Error Comunes
- **400:** Bad Request - Datos inválidos
- **401:** Unauthorized - Token inválido
- **429:** Too Many Requests - Rate limit excedido
- **500:** Internal Server Error - Error del servidor

### Estrategia de Reintentos
```php
function sendMessageWithRetry($phone, $message, $maxRetries = 3) {
    for ($i = 0; $i < $maxRetries; $i++) {
        $result = sendMessage($phone, $message);
        
        if ($result['success']) {
            return $result;
        }
        
        // Esperar antes del siguiente intento
        sleep(pow(2, $i)); // Backoff exponencial
    }
    
    return ['success' => false, 'error' => 'Max retries exceeded'];
}
```

## 📊 Monitoreo y Logs

### Métricas a Monitorear
- Mensajes enviados/recibidos por hora
- Tasa de éxito de envío
- Tiempo de respuesta de API
- Errores por tipo

### Estructura de Logs
```json
{
    "timestamp": "2026-01-08T15:41:00Z",
    "level": "INFO",
    "event": "message_sent",
    "ticket_id": 12345,
    "phone": "549xxxxxxxx@c.us",
    "message_id": "waapi_msg_id",
    "response_time": 250
}
```

## 🔄 Estados de Mensajes

### Estados Posibles
1. **SENT** - Enviado a WaAPI
2. **DELIVERED** - Entregado al dispositivo
3. **READ** - Leído por el usuario
4. **FAILED** - Error en el envío

### Mapeo de Estados ACK
```php
$ackStates = [
    0 => 'PENDING',   // Mensaje pendiente
    1 => 'SENT',      // Enviado al servidor
    2 => 'DELIVERED', // Entregado al dispositivo
    3 => 'READ'       // Leído por el usuario
];
```

## 🛠️ Herramientas de Desarrollo

### SDK PHP Recomendado
```bash
composer require waapi/php-sdk
```

### Ejemplo de Uso Básico
```php
use WaAPI\Client;

$client = new Client([
    'base_url' => 'https://waapi.app/api/v1/',
    'instance_id' => 'tu_instancia',
    'token' => 'tu_token'
]);

$response = $client->sendMessage([
    'chatId' => '5491234567890@c.us',
    'message' => 'Hola desde osTicket!'
]);
```

---

**Nota:** Esta documentación debe actualizarse según las especificaciones exactas de tu instancia de WaAPI.app.
