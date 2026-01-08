<?php
/**
 * Integración WaAPI.app para Plugin WhatsApp osTicket
 * 
 * Maneja toda la comunicación con la API de WaAPI.app incluyendo
 * envío de mensajes, manejo de webhooks y gestión de archivos multimedia
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

class WaAPIIntegration {
    
    private $config;
    private $api_url;
    private $token;
    private $instance_id;
    private $webhook_secret;
    private $timeout;
    private $retry_attempts;
    
    /**
     * Constructor
     */
    public function __construct($config) {
        $this->config = $config;
        $this->api_url = 'https://waapi.app/api/v1/';
        $this->token = $config->get('api_token');
        $this->instance_id = $config->get('instance_id');
        $this->webhook_secret = $config->get('webhook_secret');
        $this->timeout = 30;
        $this->retry_attempts = 3;
    }
    
    /**
     * Enviar mensaje de texto
     */
    public function sendMessage($phone, $message, $options = array()) {
        $endpoint = "instances/{$this->instance_id}/client/action/send-message";
        
        $data = array(
            'chatId' => $this->formatPhoneNumber($phone),
            'message' => $message
        );
        
        // Opciones adicionales
        if (isset($options['quotedMessageId'])) {
            $data['quotedMessageId'] = $options['quotedMessageId'];
        }
        
        return $this->makeRequest('POST', $endpoint, $data);
    }
    
    /**
     * Enviar archivo multimedia
     */
    public function sendMedia($phone, $file_path, $caption = '', $options = array()) {
        $endpoint = "instances/{$this->instance_id}/client/action/send-media";
        
        // Leer archivo y convertir a base64
        if (!file_exists($file_path)) {
            throw new Exception("Archivo no encontrado: $file_path");
        }
        
        $file_content = file_get_contents($file_path);
        $file_base64 = base64_encode($file_content);
        $filename = basename($file_path);
        $mimetype = $this->getMimeType($file_path);
        
        $data = array(
            'chatId' => $this->formatPhoneNumber($phone),
            'media' => array(
                'file' => $file_base64,
                'filename' => $filename,
                'caption' => $caption
            )
        );
        
        // Opciones adicionales
        if (isset($options['quotedMessageId'])) {
            $data['quotedMessageId'] = $options['quotedMessageId'];
        }
        
        return $this->makeRequest('POST', $endpoint, $data);
    }
    
    /**
     * Enviar archivo desde URL
     */
    public function sendMediaFromUrl($phone, $media_url, $caption = '', $filename = null) {
        $endpoint = "instances/{$this->instance_id}/client/action/send-media";
        
        $data = array(
            'chatId' => $this->formatPhoneNumber($phone),
            'media' => array(
                'url' => $media_url,
                'caption' => $caption
            )
        );
        
        if ($filename) {
            $data['media']['filename'] = $filename;
        }
        
        return $this->makeRequest('POST', $endpoint, $data);
    }
    
    /**
     * Obtener estado de la instancia
     */
    public function getInstanceStatus() {
        $endpoint = "instances/{$this->instance_id}/status";
        return $this->makeRequest('GET', $endpoint);
    }
    
    /**
     * Configurar webhook
     */
    public function setupWebhook($webhook_url, $events = array('message', 'ack', 'ready')) {
        $endpoint = "instances/{$this->instance_id}/webhook";
        
        $data = array(
            'webhook' => $webhook_url,
            'events' => $events
        );
        
        return $this->makeRequest('POST', $endpoint, $data);
    }
    
    /**
     * Obtener información del contacto
     */
    public function getContactInfo($phone) {
        $endpoint = "instances/{$this->instance_id}/client/action/get-contact";
        
        $data = array(
            'chatId' => $this->formatPhoneNumber($phone)
        );
        
        return $this->makeRequest('POST', $endpoint, $data);
    }
    
    /**
     * Marcar mensaje como leído
     */
    public function markAsRead($phone, $message_id) {
        $endpoint = "instances/{$this->instance_id}/client/action/mark-chat-read";
        
        $data = array(
            'chatId' => $this->formatPhoneNumber($phone),
            'messageId' => $message_id
        );
        
        return $this->makeRequest('POST', $endpoint, $data);
    }
    
    /**
     * Obtener estado de mensaje
     */
    public function getMessageStatus($message_id) {
        $endpoint = "instances/{$this->instance_id}/client/action/get-message-status";
        
        $data = array(
            'messageId' => $message_id
        );
        
        return $this->makeRequest('POST', $endpoint, $data);
    }
    
    /**
     * Descargar archivo multimedia
     */
    public function downloadMedia($media_url, $save_path = null) {
        try {
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $media_url);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 60);
            curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                'Authorization: Bearer ' . $this->token
            ));
            
            $file_content = curl_exec($ch);
            $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            if ($http_code !== 200) {
                throw new Exception("Error descargando archivo: HTTP $http_code");
            }
            
            if ($save_path) {
                // Crear directorio si no existe
                $dir = dirname($save_path);
                if (!is_dir($dir)) {
                    mkdir($dir, 0755, true);
                }
                
                file_put_contents($save_path, $file_content);
                return $save_path;
            }
            
            return $file_content;
        } catch (Exception $e) {
            throw new Exception("Error descargando media: " . $e->getMessage());
        }
    }
    
    /**
     * Procesar webhook entrante
     */
    public function processWebhook($payload, $signature = null) {
        // Validar signature si se proporciona
        if ($signature && !$this->validateWebhookSignature($payload, $signature)) {
            throw new Exception("Signature de webhook inválida");
        }
        
        $data = json_decode($payload, true);
        
        if (!$data) {
            throw new Exception("Payload de webhook inválido");
        }
        
        // Validar que sea de nuestra instancia
        if (!isset($data['instance_id']) || $data['instance_id'] !== $this->instance_id) {
            throw new Exception("Webhook de instancia incorrecta");
        }
        
        return $this->handleWebhookEvent($data);
    }
    
    /**
     * Validar signature del webhook
     */
    public function validateWebhookSignature($payload, $signature) {
        $expected = hash_hmac('sha256', $payload, $this->webhook_secret);
        return hash_equals($signature, $expected);
    }
    
    /**
     * Manejar evento de webhook
     */
    private function handleWebhookEvent($data) {
        $event = $data['event'];
        $event_data = $data['data'];
        
        switch ($event) {
            case 'message':
                return $this->handleIncomingMessage($event_data);
                
            case 'ack':
                return $this->handleMessageAck($event_data);
                
            case 'ready':
                return $this->handleInstanceReady($event_data);
                
            case 'disconnected':
                return $this->handleInstanceDisconnected($event_data);
                
            default:
                // Evento no manejado
                return array('status' => 'ignored', 'event' => $event);
        }
    }
    
    /**
     * Manejar mensaje entrante
     */
    private function handleIncomingMessage($data) {
        // Extraer información del mensaje
        $message_info = array(
            'id' => $data['key']['id'],
            'from' => $data['key']['remoteJid'],
            'fromMe' => $data['key']['fromMe'],
            'timestamp' => $data['messageTimestamp'],
            'pushName' => isset($data['pushName']) ? $data['pushName'] : null,
            'type' => 'text',
            'content' => '',
            'media' => null
        );
        
        // Ignorar mensajes enviados por nosotros
        if ($message_info['fromMe']) {
            return array('status' => 'ignored', 'reason' => 'message_from_me');
        }
        
        // Procesar contenido según tipo de mensaje
        if (isset($data['message']['conversation'])) {
            // Mensaje de texto
            $message_info['content'] = $data['message']['conversation'];
        } elseif (isset($data['message']['extendedTextMessage'])) {
            // Mensaje de texto extendido
            $message_info['content'] = $data['message']['extendedTextMessage']['text'];
        } elseif (isset($data['message']['imageMessage'])) {
            // Mensaje de imagen
            $message_info['type'] = 'image';
            $message_info['content'] = isset($data['message']['imageMessage']['caption']) 
                ? $data['message']['imageMessage']['caption'] : '';
            $message_info['media'] = array(
                'url' => $data['message']['imageMessage']['url'],
                'mimetype' => $data['message']['imageMessage']['mimetype'],
                'filename' => 'image_' . time() . '.jpg'
            );
        } elseif (isset($data['message']['documentMessage'])) {
            // Mensaje de documento
            $message_info['type'] = 'document';
            $message_info['content'] = isset($data['message']['documentMessage']['caption']) 
                ? $data['message']['documentMessage']['caption'] : '';
            $message_info['media'] = array(
                'url' => $data['message']['documentMessage']['url'],
                'mimetype' => $data['message']['documentMessage']['mimetype'],
                'filename' => $data['message']['documentMessage']['title'],
                'size' => $data['message']['documentMessage']['fileLength']
            );
        } elseif (isset($data['message']['audioMessage'])) {
            // Mensaje de audio
            $message_info['type'] = 'audio';
            $message_info['media'] = array(
                'url' => $data['message']['audioMessage']['url'],
                'mimetype' => $data['message']['audioMessage']['mimetype'],
                'filename' => 'audio_' . time() . '.ogg'
            );
        } elseif (isset($data['message']['videoMessage'])) {
            // Mensaje de video
            $message_info['type'] = 'video';
            $message_info['content'] = isset($data['message']['videoMessage']['caption']) 
                ? $data['message']['videoMessage']['caption'] : '';
            $message_info['media'] = array(
                'url' => $data['message']['videoMessage']['url'],
                'mimetype' => $data['message']['videoMessage']['mimetype'],
                'filename' => 'video_' . time() . '.mp4'
            );
        }
        
        return array(
            'status' => 'processed',
            'event' => 'incoming_message',
            'data' => $message_info
        );
    }
    
    /**
     * Manejar confirmación de mensaje (ACK)
     */
    private function handleMessageAck($data) {
        $ack_info = array(
            'message_id' => $data['key']['id'],
            'to' => $data['key']['remoteJid'],
            'ack' => $data['ack'],
            'ack_string' => $this->getAckString($data['ack'])
        );
        
        return array(
            'status' => 'processed',
            'event' => 'message_ack',
            'data' => $ack_info
        );
    }
    
    /**
     * Manejar instancia lista
     */
    private function handleInstanceReady($data) {
        return array(
            'status' => 'processed',
            'event' => 'instance_ready',
            'data' => $data
        );
    }
    
    /**
     * Manejar instancia desconectada
     */
    private function handleInstanceDisconnected($data) {
        return array(
            'status' => 'processed',
            'event' => 'instance_disconnected',
            'data' => $data
        );
    }
    
    /**
     * Realizar petición HTTP a la API
     */
    private function makeRequest($method, $endpoint, $data = null, $attempt = 1) {
        $url = $this->api_url . $endpoint;
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, $this->timeout);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            'Authorization: Bearer ' . $this->token,
            'Content-Type: application/json'
        ));
        
        if ($method === 'POST' && $data) {
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
        
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            throw new Exception("Error cURL: $error");
        }
        
        $result = json_decode($response, true);
        
        // Manejar errores HTTP
        if ($http_code >= 400) {
            $error_message = isset($result['message']) ? $result['message'] : "HTTP Error $http_code";
            
            // Reintentar en caso de errores temporales
            if ($http_code >= 500 && $attempt < $this->retry_attempts) {
                sleep(pow(2, $attempt)); // Backoff exponencial
                return $this->makeRequest($method, $endpoint, $data, $attempt + 1);
            }
            
            throw new Exception("Error API WaAPI: $error_message (HTTP $http_code)");
        }
        
        return array(
            'success' => true,
            'data' => $result,
            'http_code' => $http_code
        );
    }
    
    /**
     * Formatear número de teléfono para WhatsApp
     */
    private function formatPhoneNumber($phone) {
        // Remover caracteres no numéricos
        $clean = preg_replace('/[^0-9]/', '', $phone);
        
        // Si ya tiene el formato @c.us, devolverlo tal como está
        if (strpos($phone, '@c.us') !== false) {
            return $phone;
        }
        
        // Agregar formato WhatsApp
        return $clean . '@c.us';
    }
    
    /**
     * Obtener tipo MIME de archivo
     */
    private function getMimeType($file_path) {
        if (function_exists('finfo_file')) {
            $finfo = finfo_open(FILEINFO_MIME_TYPE);
            $mime = finfo_file($finfo, $file_path);
            finfo_close($finfo);
            return $mime;
        } elseif (function_exists('mime_content_type')) {
            return mime_content_type($file_path);
        } else {
            // Fallback basado en extensión
            $ext = strtolower(pathinfo($file_path, PATHINFO_EXTENSION));
            $mime_types = array(
                'jpg' => 'image/jpeg',
                'jpeg' => 'image/jpeg',
                'png' => 'image/png',
                'gif' => 'image/gif',
                'pdf' => 'application/pdf',
                'doc' => 'application/msword',
                'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'txt' => 'text/plain',
                'zip' => 'application/zip'
            );
            
            return isset($mime_types[$ext]) ? $mime_types[$ext] : 'application/octet-stream';
        }
    }
    
    /**
     * Convertir código ACK a string descriptivo
     */
    private function getAckString($ack) {
        $ack_strings = array(
            0 => 'pending',
            1 => 'sent',
            2 => 'delivered',
            3 => 'read'
        );
        
        return isset($ack_strings[$ack]) ? $ack_strings[$ack] : 'unknown';
    }
    
    /**
     * Verificar si el número es válido para WhatsApp
     */
    public function isValidWhatsAppNumber($phone) {
        $clean = preg_replace('/[^0-9]/', '', $phone);
        
        // Validar longitud
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
     * Obtener estadísticas de la instancia
     */
    public function getInstanceStats() {
        try {
            $status = $this->getInstanceStatus();
            
            if ($status['success']) {
                return array(
                    'connected' => $status['data']['status'] === 'ready',
                    'phone' => isset($status['data']['phone']) ? $status['data']['phone'] : null,
                    'battery' => isset($status['data']['battery']) ? $status['data']['battery'] : null,
                    'last_seen' => isset($status['data']['lastSeen']) ? $status['data']['lastSeen'] : null
                );
            }
            
            return array('connected' => false);
        } catch (Exception $e) {
            return array('connected' => false, 'error' => $e->getMessage());
        }
    }
    
    /**
     * Limpiar número de teléfono
     */
    public function cleanPhoneNumber($phone) {
        // Remover caracteres especiales y espacios
        $clean = preg_replace('/[^0-9]/', '', $phone);
        
        // Remover código de país duplicado si existe
        if (strlen($clean) > 10 && substr($clean, 0, 2) === '54' && substr($clean, 2, 1) === '9') {
            // Número argentino con formato 549...
            return $clean;
        }
        
        return $clean;
    }
}
