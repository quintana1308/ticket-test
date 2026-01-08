<?php
/**
 * Webhook Endpoint para Plugin WhatsApp osTicket
 * 
 * Recibe webhooks de WaAPI.app y procesa mensajes entrantes de WhatsApp
 * Endpoint: /include/plugins/whatsapp/webhook.php
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

// Configurar headers de respuesta
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Signature');

// Manejar preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Solo permitir POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit();
}

try {
    // Incluir archivos necesarios de osTicket
    require_once dirname(dirname(dirname(__FILE__))) . '/main.inc.php';
    require_once 'config.php';
    require_once 'class.waapi.php';
    require_once 'class.whatsapp-handler.php';
    
    // Verificar que osTicket esté inicializado
    if (!defined('OSTINSTALLED') || !$ost) {
        throw new Exception('osTicket no está inicializado correctamente');
    }
    
    // Obtener payload del webhook
    $input = file_get_contents('php://input');
    if (empty($input)) {
        throw new Exception('Payload vacío');
    }
    
    // Obtener signature del header
    $signature = isset($_SERVER['HTTP_X_SIGNATURE']) ? $_SERVER['HTTP_X_SIGNATURE'] : null;
    
    // Log del webhook recibido
    error_log("[WhatsApp Webhook] Recibido: " . substr($input, 0, 200) . "...");
    
    // Inicializar configuración del plugin
    $config = new WhatsAppPluginConfig('whatsapp');
    
    // Verificar que el plugin esté habilitado
    if (!$config->get('enabled')) {
        throw new Exception('Plugin WhatsApp deshabilitado');
    }
    
    // Verificar que esté configurado
    if (!$config->isConfigured()) {
        throw new Exception('Plugin WhatsApp no está configurado correctamente');
    }
    
    // Inicializar WaAPI client
    $waapi = new WaAPIIntegration($config);
    
    // Validar signature del webhook
    if ($signature && !$waapi->validateWebhookSignature($input, $signature)) {
        http_response_code(401);
        echo json_encode(['error' => 'Signature inválida']);
        exit();
    }
    
    // Rate limiting básico por IP
    if (!checkWebhookRateLimit($_SERVER['REMOTE_ADDR'])) {
        http_response_code(429);
        echo json_encode(['error' => 'Rate limit excedido']);
        exit();
    }
    
    // Procesar webhook
    $result = $waapi->processWebhook($input, $signature);
    
    // Si es un mensaje entrante, procesarlo con el handler
    if ($result['event'] === 'incoming_message') {
        $handler = new WhatsAppHandler($config, $waapi);
        $processed = $handler->processIncomingMessage($result['data']);
        
        if ($processed) {
            // Log exitoso
            error_log("[WhatsApp Webhook] Mensaje procesado exitosamente: " . $result['data']['id']);
            
            // Respuesta exitosa
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'message' => 'Mensaje procesado correctamente',
                'webhook_id' => $result['data']['id']
            ]);
        } else {
            // Error procesando mensaje
            error_log("[WhatsApp Webhook] Error procesando mensaje: " . $result['data']['id']);
            
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Error procesando mensaje'
            ]);
        }
    } elseif ($result['event'] === 'message_ack') {
        // Actualizar estado de mensaje enviado
        updateMessageStatus($result['data']);
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'ACK procesado correctamente'
        ]);
    } else {
        // Otros eventos (ready, disconnected, etc.)
        error_log("[WhatsApp Webhook] Evento recibido: " . $result['event']);
        
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Evento procesado',
            'event' => $result['event']
        ]);
    }
    
} catch (Exception $e) {
    // Log del error
    error_log("[WhatsApp Webhook] Error: " . $e->getMessage());
    error_log("[WhatsApp Webhook] Stack trace: " . $e->getTraceAsString());
    
    // Respuesta de error
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Error interno del servidor',
        'message' => $e->getMessage()
    ]);
}

/**
 * Verificar rate limiting para webhooks
 */
function checkWebhookRateLimit($ip, $limit = 100, $window = 60) {
    $cache_key = "whatsapp_webhook_rate_" . md5($ip);
    $cache_file = sys_get_temp_dir() . "/" . $cache_key;
    
    $current_time = time();
    $requests = array();
    
    // Leer requests existentes
    if (file_exists($cache_file)) {
        $data = file_get_contents($cache_file);
        if ($data) {
            $requests = json_decode($data, true) ?: array();
        }
    }
    
    // Filtrar requests dentro de la ventana de tiempo
    $requests = array_filter($requests, function($timestamp) use ($current_time, $window) {
        return ($current_time - $timestamp) < $window;
    });
    
    // Verificar límite
    if (count($requests) >= $limit) {
        return false;
    }
    
    // Agregar request actual
    $requests[] = $current_time;
    
    // Guardar en cache
    file_put_contents($cache_file, json_encode($requests));
    
    return true;
}

/**
 * Actualizar estado de mensaje enviado
 */
function updateMessageStatus($ack_data) {
    try {
        $sql = 'UPDATE ost_whatsapp_messages SET 
                status = %s,
                delivered_at = CASE WHEN %s >= 2 THEN NOW() ELSE delivered_at END,
                read_at = CASE WHEN %s = 3 THEN NOW() ELSE read_at END
                WHERE waapi_message_id = %s';
        
        $status_map = array(
            0 => 'pending',
            1 => 'sent', 
            2 => 'delivered',
            3 => 'read'
        );
        
        $status = isset($status_map[$ack_data['ack']]) ? $status_map[$ack_data['ack']] : 'unknown';
        
        db_query($sql, $status, $ack_data['ack'], $ack_data['ack'], $ack_data['message_id']);
        
        error_log("[WhatsApp Webhook] Estado actualizado: " . $ack_data['message_id'] . " -> " . $status);
        
    } catch (Exception $e) {
        error_log("[WhatsApp Webhook] Error actualizando estado: " . $e->getMessage());
    }
}

/**
 * Función de utilidad para logging seguro
 */
function logWebhookActivity($event, $data, $level = 'INFO') {
    $log_entry = array(
        'timestamp' => date('Y-m-d H:i:s'),
        'level' => $level,
        'event' => $event,
        'ip' => $_SERVER['REMOTE_ADDR'],
        'user_agent' => isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : 'Unknown',
        'data' => $data
    );
    
    // Log a archivo específico del plugin
    $log_file = dirname(__FILE__) . '/logs/webhook.log';
    $log_dir = dirname($log_file);
    
    if (!is_dir($log_dir)) {
        mkdir($log_dir, 0755, true);
    }
    
    file_put_contents($log_file, json_encode($log_entry) . "\n", FILE_APPEND | LOCK_EX);
}

/**
 * Validar que el request viene de WaAPI.app
 */
function validateWebhookOrigin() {
    $allowed_ips = array(
        // IPs de WaAPI.app (actualizar según documentación)
        '127.0.0.1', // localhost para testing
    );
    
    $client_ip = $_SERVER['REMOTE_ADDR'];
    
    // Si está detrás de proxy, obtener IP real
    if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $forwarded_ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        $client_ip = trim($forwarded_ips[0]);
    } elseif (isset($_SERVER['HTTP_X_REAL_IP'])) {
        $client_ip = $_SERVER['HTTP_X_REAL_IP'];
    }
    
    // En producción, descomentar esta validación
    // return in_array($client_ip, $allowed_ips);
    
    return true; // Permitir todos por ahora
}

/**
 * Sanitizar datos de entrada
 */
function sanitizeWebhookData($data) {
    if (is_array($data)) {
        return array_map('sanitizeWebhookData', $data);
    } elseif (is_string($data)) {
        return htmlspecialchars(trim($data), ENT_QUOTES, 'UTF-8');
    }
    
    return $data;
}

/**
 * Generar respuesta de error estandarizada
 */
function webhookError($code, $message, $details = null) {
    http_response_code($code);
    
    $response = array(
        'success' => false,
        'error' => $message,
        'timestamp' => date('c')
    );
    
    if ($details) {
        $response['details'] = $details;
    }
    
    echo json_encode($response);
    exit();
}

/**
 * Verificar salud del sistema
 */
function checkSystemHealth() {
    $checks = array();
    
    // Verificar conexión a base de datos
    try {
        db_query('SELECT 1');
        $checks['database'] = true;
    } catch (Exception $e) {
        $checks['database'] = false;
    }
    
    // Verificar permisos de escritura
    $temp_file = sys_get_temp_dir() . '/whatsapp_webhook_test_' . time();
    $checks['filesystem'] = file_put_contents($temp_file, 'test') !== false;
    if ($checks['filesystem']) {
        unlink($temp_file);
    }
    
    // Verificar memoria disponible
    $memory_limit = ini_get('memory_limit');
    $memory_usage = memory_get_usage(true);
    $checks['memory'] = $memory_usage < (0.8 * $memory_limit); // 80% del límite
    
    return $checks;
}

// Endpoint de salud (GET request)
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['health'])) {
    $health = checkSystemHealth();
    $all_healthy = !in_array(false, $health, true);
    
    http_response_code($all_healthy ? 200 : 503);
    echo json_encode(array(
        'status' => $all_healthy ? 'healthy' : 'unhealthy',
        'checks' => $health,
        'timestamp' => date('c')
    ));
    exit();
}

// Endpoint de información (GET request)
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['info'])) {
    echo json_encode(array(
        'plugin' => 'WhatsApp Integration',
        'version' => '1.0.0',
        'endpoint' => $_SERVER['REQUEST_URI'],
        'methods' => array('POST'),
        'timestamp' => date('c')
    ));
    exit();
}
?>
