<?php
/**
 * Plugin WhatsApp Simplificado para osTicket
 * Versión básica que evita dependencias complejas
 */

// Solo incluir si no está ya incluido
if (!class_exists('Plugin')) {
    require_once INCLUDE_DIR . 'class.plugin.php';
}

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
     */
    function init() {
        // Inicialización básica
        return true;
    }
    
    /**
     * Bootstrap del plugin
     */
    function bootstrap() {
        // Bootstrap básico
        return true;
    }
    
    /**
     * Desinstalar el plugin
     */
    function uninstall() {
        return true;
    }
}

/**
 * Configuración básica del plugin
 */
class WhatsAppPluginConfig extends PluginConfig {
    
    function getOptions() {
        return array(
            'enabled' => new BooleanField(array(
                'label' => 'Habilitar Plugin',
                'default' => false,
                'configuration' => array(
                    'desc' => 'Habilitar integración WhatsApp'
                )
            )),
            'api_token' => new TextboxField(array(
                'label' => 'API Token WaAPI.app',
                'configuration' => array(
                    'size' => 60,
                    'length' => 100,
                    'desc' => 'Token de API de WaAPI.app'
                )
            )),
            'instance_id' => new TextboxField(array(
                'label' => 'Instance ID',
                'configuration' => array(
                    'size' => 40,
                    'length' => 50,
                    'desc' => 'ID de instancia WhatsApp'
                )
            )),
            'business_phone' => new TextboxField(array(
                'label' => 'Número WhatsApp Business',
                'configuration' => array(
                    'size' => 20,
                    'length' => 20,
                    'desc' => 'Número de teléfono WhatsApp Business'
                )
            )),
            'webhook_secret' => new TextboxField(array(
                'label' => 'Webhook Secret',
                'configuration' => array(
                    'size' => 40,
                    'length' => 100,
                    'desc' => 'Clave secreta para webhooks'
                )
            ))
        );
    }
}

// Registrar el plugin
return new WhatsAppPlugin();
?>
