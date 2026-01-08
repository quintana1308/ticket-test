<?php
/**
 * Diagnóstico específico para detectar por qué osTicket no encuentra el plugin WhatsApp
 */

// Incluir bootstrap de osTicket
require_once dirname(__FILE__) . '/main.inc.php';

echo "<h2>Diagnóstico Detallado del Plugin WhatsApp</h2>";

// 1. Verificar directorio de plugins
$plugins_dir = INCLUDE_DIR . 'plugins/';
echo "<h3>1. Directorio de Plugins</h3>";
echo "<p><strong>Ruta:</strong> " . $plugins_dir . "</p>";
echo "<p><strong>Existe:</strong> " . (is_dir($plugins_dir) ? "✓ Sí" : "✗ No") . "</p>";
echo "<p><strong>Legible:</strong> " . (is_readable($plugins_dir) ? "✓ Sí" : "✗ No") . "</p>";

// 2. Listar contenido del directorio plugins
echo "<h3>2. Contenido del Directorio Plugins</h3>";
if (is_dir($plugins_dir)) {
    $items = scandir($plugins_dir);
    echo "<ul>";
    foreach ($items as $item) {
        if ($item != '.' && $item != '..') {
            $full_path = $plugins_dir . $item;
            $type = is_dir($full_path) ? "📁 Directorio" : "📄 Archivo";
            echo "<li>$type: $item</li>";
        }
    }
    echo "</ul>";
} else {
    echo "<p style='color: red;'>No se puede acceder al directorio de plugins</p>";
}

// 3. Verificar directorio WhatsApp específicamente
$whatsapp_dir = $plugins_dir . 'whatsapp/';
echo "<h3>3. Directorio WhatsApp Plugin</h3>";
echo "<p><strong>Ruta:</strong> " . $whatsapp_dir . "</p>";
echo "<p><strong>Existe:</strong> " . (is_dir($whatsapp_dir) ? "✓ Sí" : "✗ No") . "</p>";
echo "<p><strong>Legible:</strong> " . (is_readable($whatsapp_dir) ? "✓ Sí" : "✗ No") . "</p>";

// 4. Verificar archivos del plugin
echo "<h3>4. Archivos del Plugin WhatsApp</h3>";
$required_files = [
    'plugin.php' => 'Archivo principal del plugin',
    'config.php' => 'Configuración del plugin',
    'info.php' => 'Información del plugin (nuevo)',
    'manifest.json' => 'Manifiesto del plugin (nuevo)'
];

foreach ($required_files as $file => $description) {
    $file_path = $whatsapp_dir . $file;
    $exists = file_exists($file_path);
    $readable = $exists ? is_readable($file_path) : false;
    $size = $exists ? filesize($file_path) : 0;
    
    echo "<p><strong>$file</strong> ($description):</p>";
    echo "<ul>";
    echo "<li>Existe: " . ($exists ? "✓ Sí" : "✗ No") . "</li>";
    echo "<li>Legible: " . ($readable ? "✓ Sí" : "✗ No") . "</li>";
    echo "<li>Tamaño: " . ($exists ? number_format($size) . " bytes" : "N/A") . "</li>";
    echo "</ul>";
}

// 5. Verificar si osTicket puede escanear plugins
echo "<h3>5. Capacidad de osTicket para Detectar Plugins</h3>";
try {
    // Intentar usar la función interna de osTicket para escanear plugins
    if (class_exists('Plugin')) {
        echo "<p>✓ Clase Plugin disponible</p>";
        
        // Verificar método de escaneo
        if (method_exists('Plugin', 'scan')) {
            echo "<p>✓ Método Plugin::scan() disponible</p>";
            
            // Intentar escanear
            try {
                $plugins = Plugin::scan();
                echo "<p>✓ Escaneo exitoso. Plugins encontrados: " . count($plugins) . "</p>";
                
                if (!empty($plugins)) {
                    echo "<ul>";
                    foreach ($plugins as $plugin_path => $plugin_info) {
                        echo "<li>" . basename($plugin_path) . "</li>";
                    }
                    echo "</ul>";
                }
            } catch (Exception $e) {
                echo "<p style='color: red;'>✗ Error en escaneo: " . htmlspecialchars($e->getMessage()) . "</p>";
            }
        } else {
            echo "<p style='color: orange;'>⚠ Método Plugin::scan() no disponible</p>";
        }
    } else {
        echo "<p style='color: red;'>✗ Clase Plugin no disponible</p>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>Error verificando capacidades: " . htmlspecialchars($e->getMessage()) . "</p>";
}

// 6. Verificar permisos específicos
echo "<h3>6. Verificación de Permisos</h3>";
$test_file = $whatsapp_dir . 'test_write.tmp';
if (is_writable($whatsapp_dir)) {
    echo "<p>✓ Directorio escribible</p>";
    
    // Intentar crear archivo temporal
    if (file_put_contents($test_file, 'test')) {
        echo "<p>✓ Puede crear archivos</p>";
        unlink($test_file); // Limpiar
    } else {
        echo "<p style='color: red;'>✗ No puede crear archivos</p>";
    }
} else {
    echo "<p style='color: orange;'>⚠ Directorio no escribible (puede ser normal)</p>";
}

echo "<hr>";
echo "<h3>Recomendaciones</h3>";
echo "<ol>";
echo "<li>Verifica que todos los archivos del plugin tengan permisos de lectura</li>";
echo "<li>Limpia el cache de osTicket (Admin Panel → Settings → System)</li>";
echo "<li>Reinicia el servicio web en Plesk</li>";
echo "<li>Verifica los logs de error del servidor web</li>";
echo "</ol>";
?>
