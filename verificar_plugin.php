<?php
/**
 * Script para verificar que el plugin WhatsApp sea detectado por osTicket
 */

// Incluir bootstrap de osTicket
require_once dirname(__FILE__) . '/main.inc.php';

echo "<h2>Verificación del Plugin WhatsApp</h2>";

// Verificar que el archivo plugin.php existe
$plugin_file = INCLUDE_DIR . 'plugins/whatsapp/plugin.php';
echo "<p><strong>Archivo plugin.php:</strong> ";
if (file_exists($plugin_file)) {
    echo "<span style='color: green;'>✓ Encontrado</span></p>";
} else {
    echo "<span style='color: red;'>✗ No encontrado</span></p>";
    exit;
}

// Verificar que el archivo es legible
echo "<p><strong>Permisos de lectura:</strong> ";
if (is_readable($plugin_file)) {
    echo "<span style='color: green;'>✓ Legible</span></p>";
} else {
    echo "<span style='color: red;'>✗ No legible</span></p>";
}

// Intentar cargar el plugin
echo "<p><strong>Carga del plugin:</strong> ";
try {
    // Verificar si las clases necesarias están disponibles
    if (!class_exists('Plugin')) {
        echo "<span style='color: red;'>✗ Error: Clase Plugin no encontrada</span></p>";
        echo "<p><em>Esto es normal - el plugin se carga automáticamente por osTicket</em></p>";
    } else {
        $plugin = include $plugin_file;
        if ($plugin instanceof Plugin) {
            echo "<span style='color: green;'>✓ Plugin cargado correctamente</span></p>";
            
            // Mostrar información del plugin
            $info = $plugin->getInfo();
            echo "<h3>Información del Plugin:</h3>";
            echo "<ul>";
            echo "<li><strong>Nombre:</strong> " . htmlspecialchars($info['name']) . "</li>";
            echo "<li><strong>Versión:</strong> " . htmlspecialchars($info['version']) . "</li>";
            echo "<li><strong>Descripción:</strong> " . htmlspecialchars($info['description']) . "</li>";
            echo "<li><strong>Autor:</strong> " . htmlspecialchars($info['author']) . "</li>";
            echo "</ul>";
            
        } else {
            echo "<span style='color: red;'>✗ Error: El archivo no retorna una instancia de Plugin</span></p>";
        }
    }
} catch (Exception $e) {
    echo "<span style='color: red;'>✗ Error cargando plugin: " . htmlspecialchars($e->getMessage()) . "</span></p>";
} catch (Error $e) {
    echo "<span style='color: red;'>✗ Error fatal: " . htmlspecialchars($e->getMessage()) . "</span></p>";
}

// Verificar plugins disponibles en osTicket
echo "<h3>Plugins Detectados por osTicket:</h3>";
try {
    $plugins = Plugin::allInstalled();
    if (empty($plugins)) {
        echo "<p>No hay plugins instalados.</p>";
    } else {
        echo "<ul>";
        foreach ($plugins as $plugin) {
            $info = $plugin->getInfo();
            echo "<li>" . htmlspecialchars($info['name']) . " v" . htmlspecialchars($info['version']) . "</li>";
        }
        echo "</ul>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>Error obteniendo plugins: " . htmlspecialchars($e->getMessage()) . "</p>";
}

echo "<hr>";
echo "<p><strong>Siguiente paso:</strong> Ve a Admin Panel → Manage → Plugins para instalar el plugin WhatsApp.</p>";
?>
