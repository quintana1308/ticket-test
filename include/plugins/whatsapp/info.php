<?php
/**
 * Información del Plugin WhatsApp para osTicket
 * Este archivo ayuda a osTicket a detectar y mostrar el plugin
 */

return array(
    'name' => 'WhatsApp Integration',
    'version' => '1.0.0',
    'description' => 'Integra WhatsApp como canal principal de comunicación usando WaAPI.app',
    'author' => 'quintana1308',
    'author_email' => 'aquintana@sistemasadn.com',
    'url' => 'https://github.com/quintana1308/osticket-whatsapp-plugin',
    'plugin' => 'plugin.php',
    'config' => 'config.php',
    'requires' => array(
        'osticket' => '1.15.0'
    ),
    'install' => 'install.php'
);
?>
