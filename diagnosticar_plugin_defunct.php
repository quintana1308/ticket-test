<?php
/**
 * Diagnóstico específico para plugin "Defunct - missing"
 * Verifica por qué osTicket no puede cargar el plugin WhatsApp
 */

// Incluir bootstrap de osTicket
require_once dirname(__FILE__) . '/main.inc.php';

echo "<h2>Diagnóstico Plugin Defunct - Missing</h2>";

// 1. Verificar registro en base de datos
echo "<h3>1. Registro en Base de Datos</h3>";
$plugin_query = db_query("SELECT * FROM ost_plugin WHERE install_path = 'whatsapp'");
if (db_num_rows($plugin_query) > 0) {
    $plugin_data = db_fetch_assoc($plugin_query);
    echo "<p>✓ Plugin registrado en BD:</p>";
    echo "<ul>";
    echo "<li><strong>ID:</strong> " . $plugin_data['id'] . "</li>";
    echo "<li><strong>Nombre:</strong> " . htmlspecialchars($plugin_data['name']) . "</li>";
    echo "<li><strong>Ruta:</strong> " . htmlspecialchars($plugin_data['install_path']) . "</li>";
    echo "<li><strong>Versión:</strong> " . htmlspecialchars($plugin_data['version']) . "</li>";
    echo "<li><strong>Activo:</strong> " . ($plugin_data['isactive'] ? 'Sí' : 'No') . "</li>";
    echo "</ul>";
} else {
    echo "<p style='color: red;'>✗ Plugin no encontrado en BD</p>";
}

// 2. Verificar estructura de archivos
echo "<h3>2. Estructura de Archivos del Plugin</h3>";
$plugin_dir = INCLUDE_DIR . 'plugins/whatsapp/';
echo "<p><strong>Directorio base:</strong> $plugin_dir</p>";

$required_files = [
    'plugin.php' => 'Archivo principal del plugin',
    'config.php' => 'Configuración del plugin'
];

foreach ($required_files as $file => $desc) {
    $file_path = $plugin_dir . $file;
    $exists = file_exists($file_path);
    $readable = $exists ? is_readable($file_path) : false;
    $size = $exists ? filesize($file_path) : 0;
    
    echo "<p><strong>$file</strong> ($desc):</p>";
    echo "<ul>";
    echo "<li>Existe: " . ($exists ? "✓ Sí" : "✗ No") . "</li>";
    echo "<li>Legible: " . ($readable ? "✓ Sí" : "✗ No") . "</li>";
    echo "<li>Tamaño: " . ($exists ? number_format($size) . " bytes" : "N/A") . "</li>";
    echo "</ul>";
}

// 3. Intentar cargar el plugin manualmente
echo "<h3>3. Prueba de Carga Manual del Plugin</h3>";
$plugin_file = $plugin_dir . 'plugin.php';

if (file_exists($plugin_file)) {
    echo "<p>Intentando cargar plugin.php...</p>";
    
    // Capturar errores
    ob_start();
    $error_occurred = false;
    
    try {
        // Incluir el archivo del plugin
        include_once $plugin_file;
        
        // Verificar si la clase existe
        if (class_exists('WhatsAppPlugin')) {
            echo "<p style='color: green;'>✓ Clase WhatsAppPlugin encontrada</p>";
            
            // Intentar instanciar
            try {
                $plugin_instance = new WhatsAppPlugin();
                echo "<p style='color: green;'>✓ Plugin instanciado correctamente</p>";
                
                // Verificar método getInfo
                if (method_exists($plugin_instance, 'getInfo')) {
                    $info = $plugin_instance->getInfo();
                    echo "<p style='color: green;'>✓ Método getInfo() funciona</p>";
                    echo "<ul>";
                    echo "<li><strong>Nombre:</strong> " . htmlspecialchars($info['name']) . "</li>";
                    echo "<li><strong>Versión:</strong> " . htmlspecialchars($info['version']) . "</li>";
                    echo "<li><strong>Descripción:</strong> " . htmlspecialchars($info['description']) . "</li>";
                    echo "</ul>";
                } else {
                    echo "<p style='color: red;'>✗ Método getInfo() no encontrado</p>";
                }
                
            } catch (Exception $e) {
                echo "<p style='color: red;'>✗ Error instanciando plugin: " . htmlspecialchars($e->getMessage()) . "</p>";
                $error_occurred = true;
            }
            
        } else {
            echo "<p style='color: red;'>✗ Clase WhatsAppPlugin no encontrada</p>";
            $error_occurred = true;
        }
        
    } catch (ParseError $e) {
        echo "<p style='color: red;'>✗ Error de sintaxis en plugin.php: " . htmlspecialchars($e->getMessage()) . "</p>";
        $error_occurred = true;
    } catch (Error $e) {
        echo "<p style='color: red;'>✗ Error fatal: " . htmlspecialchars($e->getMessage()) . "</p>";
        $error_occurred = true;
    } catch (Exception $e) {
        echo "<p style='color: red;'>✗ Excepción: " . htmlspecialchars($e->getMessage()) . "</p>";
        $error_occurred = true;
    }
    
    $output = ob_get_clean();
    echo $output;
    
} else {
    echo "<p style='color: red;'>✗ Archivo plugin.php no encontrado</p>";
}

// 4. Verificar dependencias
echo "<h3>4. Verificación de Dependencias</h3>";
$dependencies = [
    'class.plugin.php' => INCLUDE_DIR . 'class.plugin.php',
    'class.signal.php' => INCLUDE_DIR . 'class.signal.php',
    'class.ticket.php' => INCLUDE_DIR . 'class.ticket.php'
];

foreach ($dependencies as $name => $path) {
    $exists = file_exists($path);
    echo "<p><strong>$name:</strong> " . ($exists ? "✓ Disponible" : "✗ Faltante") . "</p>";
}

// 5. Verificar clases base
echo "<h3>5. Verificación de Clases Base</h3>";
$base_classes = ['Plugin', 'PluginConfig', 'Signal'];

foreach ($base_classes as $class) {
    $exists = class_exists($class);
    echo "<p><strong>Clase $class:</strong> " . ($exists ? "✓ Disponible" : "✗ No disponible") . "</p>";
}

echo "<hr>";
echo "<h3>Recomendaciones</h3>";
echo "<ol>";
echo "<li>Si hay errores de sintaxis, corregir el archivo plugin.php</li>";
echo "<li>Si faltan dependencias, verificar que los archivos base de osTicket estén presentes</li>";
echo "<li>Si las clases base no están disponibles, verificar la carga del bootstrap</li>";
echo "<li>Considerar recrear el plugin con estructura más simple</li>";
echo "</ol>";
?>
