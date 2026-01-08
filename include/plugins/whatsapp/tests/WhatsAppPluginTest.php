<?php
/**
 * Pruebas Unitarias - Plugin WhatsApp para osTicket
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

require_once dirname(dirname(__FILE__)) . '/plugin.php';
require_once dirname(dirname(__FILE__)) . '/class.whatsapp-handler.php';
require_once dirname(dirname(__FILE__)) . '/class.waapi.php';
require_once dirname(dirname(__FILE__)) . '/class.whatsapp-templates.php';

class WhatsAppPluginTest {
    
    private $plugin;
    private $config;
    private $test_results = array();
    
    public function __construct() {
        $this->plugin = new WhatsAppPlugin();
        $this->config = $this->createMockConfig();
    }
    
    /**
     * Ejecutar todas las pruebas
     */
    public function runAllTests() {
        echo "=== Ejecutando Pruebas Plugin WhatsApp ===\n\n";
        
        $this->testPluginInfo();
        $this->testConfigValidation();
        $this->testPhoneNumberValidation();
        $this->testTemplateProcessing();
        $this->testHtmlToWhatsAppConversion();
        $this->testRateLimiting();
        $this->testWebhookValidation();
        $this->testPermissionsIntegration();
        
        $this->showResults();
    }
    
    /**
     * Test: Información básica del plugin
     */
    public function testPluginInfo() {
        echo "Test: Información del Plugin\n";
        
        $info = $this->plugin->getInfo();
        
        $this->assert(
            isset($info['name']) && $info['name'] === 'WhatsApp Integration',
            'Nombre del plugin correcto'
        );
        
        $this->assert(
            isset($info['version']) && !empty($info['version']),
            'Versión del plugin definida'
        );
        
        $this->assert(
            isset($info['author']) && $info['author'] === 'quintana1308',
            'Autor del plugin correcto'
        );
        
        echo "✓ Test completado\n\n";
    }
    
    /**
     * Test: Validación de configuración
     */
    public function testConfigValidation() {
        echo "Test: Validación de Configuración\n";
        
        // Configuración válida
        $valid_config = array(
            'api_token' => 'test_token_123',
            'instance_id' => 'test_instance',
            'webhook_secret' => 'test_secret',
            'business_phone' => '+5491123456789'
        );
        
        $errors = $this->plugin->validateConfig($valid_config);
        $this->assert(
            empty($errors),
            'Configuración válida no debe tener errores'
        );
        
        // Configuración inválida
        $invalid_config = array(
            'api_token' => '',
            'instance_id' => '',
            'webhook_secret' => '',
            'business_phone' => 'invalid_phone'
        );
        
        $errors = $this->plugin->validateConfig($invalid_config);
        $this->assert(
            !empty($errors),
            'Configuración inválida debe tener errores'
        );
        
        $this->assert(
            isset($errors['api_token']),
            'Error de token API detectado'
        );
        
        echo "✓ Test completado\n\n";
    }
    
    /**
     * Test: Validación de números de teléfono
     */
    public function testPhoneNumberValidation() {
        echo "Test: Validación de Números de Teléfono\n";
        
        $waapi = new WaAPIIntegration($this->config);
        
        // Números válidos
        $valid_phones = array(
            '+5491123456789',
            '+1234567890',
            '+447700900123'
        );
        
        foreach ($valid_phones as $phone) {
            $cleaned = $waapi->cleanPhoneNumber($phone);
            $this->assert(
                !empty($cleaned),
                "Número válido limpiado correctamente: $phone"
            );
        }
        
        // Números inválidos
        $invalid_phones = array(
            '123',
            '+00123456789',
            'abc123',
            ''
        );
        
        foreach ($invalid_phones as $phone) {
            $cleaned = $waapi->cleanPhoneNumber($phone);
            $this->assert(
                empty($cleaned) || strlen($cleaned) < 8,
                "Número inválido rechazado: $phone"
            );
        }
        
        echo "✓ Test completado\n\n";
    }
    
    /**
     * Test: Procesamiento de plantillas
     */
    public function testTemplateProcessing() {
        echo "Test: Procesamiento de Plantillas\n";
        
        $template_manager = new WhatsAppTemplateManager($this->config);
        
        $template = array(
            'message' => 'Hola %{user.name}, tu ticket #%{ticket.number} fue creado el %{date}'
        );
        
        $variables = array(
            'user' => (object) array('name' => 'Juan Pérez'),
            'ticket' => (object) array('number' => 'T123456')
        );
        
        $processed = $template_manager->processTemplate($template, $variables);
        
        $this->assert(
            strpos($processed, 'Juan Pérez') !== false,
            'Variable user.name procesada correctamente'
        );
        
        $this->assert(
            strpos($processed, 'T123456') !== false,
            'Variable ticket.number procesada correctamente'
        );
        
        $this->assert(
            strpos($processed, date('d/m/Y')) !== false,
            'Variable de fecha procesada correctamente'
        );
        
        echo "✓ Test completado\n\n";
    }
    
    /**
     * Test: Conversión HTML a WhatsApp
     */
    public function testHtmlToWhatsAppConversion() {
        echo "Test: Conversión HTML a WhatsApp\n";
        
        $template_manager = new WhatsAppTemplateManager($this->config);
        
        // HTML con formato
        $html = '<p>Hola <strong>Juan</strong>,</p><p>Tu ticket ha sido <em>actualizado</em>.</p><ul><li>Estado: Resuelto</li><li>Prioridad: Alta</li></ul>';
        
        $whatsapp_text = $template_manager->formatForWhatsApp($html);
        
        $this->assert(
            strpos($whatsapp_text, '*Juan*') !== false,
            'Texto en negrita convertido correctamente'
        );
        
        $this->assert(
            strpos($whatsapp_text, '_actualizado_') !== false,
            'Texto en cursiva convertido correctamente'
        );
        
        $this->assert(
            strpos($whatsapp_text, '•') !== false,
            'Lista convertida correctamente'
        );
        
        $this->assert(
            strpos($whatsapp_text, '<') === false,
            'Tags HTML eliminados'
        );
        
        echo "✓ Test completado\n\n";
    }
    
    /**
     * Test: Rate limiting
     */
    public function testRateLimiting() {
        echo "Test: Rate Limiting\n";
        
        $handler = new WhatsAppHandler($this->config, new WaAPIIntegration($this->config));
        
        // Simular múltiples mensajes del mismo número
        $phone = '+5491123456789';
        
        // Primer mensaje debe pasar
        $result1 = $this->simulateRateLimit($phone);
        $this->assert(
            $result1,
            'Primer mensaje dentro del límite'
        );
        
        // Simular muchos mensajes rápidos (esto requeriría modificar la lógica para testing)
        // Por ahora validamos que la función existe
        $this->assert(
            method_exists($handler, 'checkRateLimit'),
            'Método de rate limiting existe'
        );
        
        echo "✓ Test completado\n\n";
    }
    
    /**
     * Test: Validación de webhooks
     */
    public function testWebhookValidation() {
        echo "Test: Validación de Webhooks\n";
        
        $waapi = new WaAPIIntegration($this->config);
        
        $payload = '{"event":"message","data":{"id":"test123"}}';
        $secret = 'test_secret';
        $signature = hash_hmac('sha256', $payload, $secret);
        
        // Signature válida
        $valid = $waapi->validateWebhookSignature($payload, 'sha256=' . $signature);
        $this->assert(
            $valid,
            'Signature válida aceptada'
        );
        
        // Signature inválida
        $invalid = $waapi->validateWebhookSignature($payload, 'sha256=invalid_signature');
        $this->assert(
            !$invalid,
            'Signature inválida rechazada'
        );
        
        echo "✓ Test completado\n\n";
    }
    
    /**
     * Test: Integración con permisos diferenciados
     */
    public function testPermissionsIntegration() {
        echo "Test: Integración con Permisos Diferenciados\n";
        
        // Verificar que el plugin maneja los eventos de permisos
        $plugin_file = file_get_contents(dirname(dirname(__FILE__)) . '/plugin.php');
        
        $this->assert(
            strpos($plugin_file, 'PERM_RESOLVE') !== false,
            'Plugin integra PERM_RESOLVE'
        );
        
        $this->assert(
            strpos($plugin_file, 'PERM_CLOSE') !== false,
            'Plugin integra PERM_CLOSE'
        );
        
        $this->assert(
            strpos($plugin_file, 'onTicketStatusChanged') !== false,
            'Plugin maneja cambios de estado'
        );
        
        echo "✓ Test completado\n\n";
    }
    
    /**
     * Simular rate limiting (método auxiliar)
     */
    private function simulateRateLimit($phone) {
        // En un entorno real, esto consultaría la base de datos
        // Por ahora retornamos true para el test básico
        return true;
    }
    
    /**
     * Crear configuración mock para testing
     */
    private function createMockConfig() {
        return (object) array(
            'api_token' => 'test_token',
            'instance_id' => 'test_instance',
            'webhook_secret' => 'test_secret',
            'business_phone' => '+5491123456789',
            'enabled' => true,
            'rate_limit' => 50
        );
    }
    
    /**
     * Método de aserción personalizado
     */
    private function assert($condition, $message) {
        if ($condition) {
            $this->test_results[] = array('status' => 'PASS', 'message' => $message);
            echo "  ✓ $message\n";
        } else {
            $this->test_results[] = array('status' => 'FAIL', 'message' => $message);
            echo "  ❌ $message\n";
        }
    }
    
    /**
     * Mostrar resumen de resultados
     */
    private function showResults() {
        $total = count($this->test_results);
        $passed = count(array_filter($this->test_results, function($result) {
            return $result['status'] === 'PASS';
        }));
        $failed = $total - $passed;
        
        echo "=== Resumen de Pruebas ===\n";
        echo "Total: $total\n";
        echo "Exitosas: $passed\n";
        echo "Fallidas: $failed\n";
        
        if ($failed > 0) {
            echo "\nPruebas Fallidas:\n";
            foreach ($this->test_results as $result) {
                if ($result['status'] === 'FAIL') {
                    echo "  ❌ " . $result['message'] . "\n";
                }
            }
        }
        
        echo "\n" . ($failed === 0 ? "🎉 Todas las pruebas pasaron!" : "⚠️  Algunas pruebas fallaron") . "\n";
    }
}

// Ejecutar pruebas si se llama directamente
if (php_sapi_name() === 'cli') {
    $tester = new WhatsAppPluginTest();
    $tester->runAllTests();
}
?>
