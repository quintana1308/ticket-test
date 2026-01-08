<?php
/**
 * Test directo del plugin WhatsApp sin bootstrap de osTicket
 * Para verificar si el archivo plugin.php tiene errores de sintaxis
 */

echo "<h2>Test Directo del Plugin WhatsApp</h2>";

// 1. Verificar que el archivo existe
$plugin_file = dirname(__FILE__) . '/include/plugins/whatsapp/plugin.php';
echo "<h3>1. Verificación de Archivo</h3>";
echo "<p><strong>Ruta:</strong> $plugin_file</p>";

if (file_exists($plugin_file)) {
    echo "<p style='color: green;'>✓ Archivo existe</p>";
    echo "<p><strong>Tamaño:</strong> " . number_format(filesize($plugin_file)) . " bytes</p>";
    echo "<p><strong>Última modificación:</strong> " . date('Y-m-d H:i:s', filemtime($plugin_file)) . "</p>";
} else {
    echo "<p style='color: red;'>✗ Archivo no encontrado</p>";
    exit;
}

// 2. Verificar sintaxis PHP
echo "<h3>2. Verificación de Sintaxis PHP</h3>";
$syntax_check = shell_exec("php -l \"$plugin_file\" 2>&1");
if (strpos($syntax_check, 'No syntax errors') !== false) {
    echo "<p style='color: green;'>✓ Sintaxis PHP correcta</p>";
} else {
    echo "<p style='color: red;'>✗ Error de sintaxis:</p>";
    echo "<pre>" . htmlspecialchars($syntax_check) . "</pre>";
}

// 3. Intentar incluir el archivo directamente
echo "<h3>3. Test de Inclusión Directa</h3>";
ob_start();
$error_occurred = false;

try {
    // Definir constantes mínimas necesarias
    if (!defined('INCLUDE_DIR')) {
        define('INCLUDE_DIR', dirname(__FILE__) . '/include/');
    }
    
    // Intentar incluir el archivo
    $result = include $plugin_file;
    
    if ($result === false) {
        echo "<p style='color: red;'>✗ Error incluyendo archivo</p>";
        $error_occurred = true;
    } elseif (is_object($result)) {
        echo "<p style='color: green;'>✓ Archivo incluido correctamente</p>";
        echo "<p><strong>Tipo de objeto:</strong> " . get_class($result) . "</p>";
        
        // Verificar métodos del plugin
        if (method_exists($result, 'getInfo')) {
            $info = $result->getInfo();
            echo "<p style='color: green;'>✓ Método getInfo() funciona</p>";
            echo "<ul>";
            echo "<li><strong>Nombre:</strong> " . htmlspecialchars($info['name']) . "</li>";
            echo "<li><strong>Versión:</strong> " . htmlspecialchars($info['version']) . "</li>";
            echo "<li><strong>Descripción:</strong> " . htmlspecialchars($info['description']) . "</li>";
            echo "</ul>";
        } else {
            echo "<p style='color: red;'>✗ Método getInfo() no encontrado</p>";
        }
    } else {
        echo "<p style='color: orange;'>⚠ Archivo incluido pero no retorna objeto esperado</p>";
        echo "<p><strong>Tipo retornado:</strong> " . gettype($result) . "</p>";
    }
    
} catch (ParseError $e) {
    echo "<p style='color: red;'>✗ Error de sintaxis: " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p><strong>Línea:</strong> " . $e->getLine() . "</p>";
    $error_occurred = true;
} catch (Error $e) {
    echo "<p style='color: red;'>✗ Error fatal: " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p><strong>Línea:</strong> " . $e->getLine() . "</p>";
    $error_occurred = true;
} catch (Exception $e) {
    echo "<p style='color: red;'>✗ Excepción: " . htmlspecialchars($e->getMessage()) . "</p>";
    $error_occurred = true;
}

$output = ob_get_clean();
echo $output;

// 4. Mostrar contenido del archivo (primeras líneas)
echo "<h3>4. Contenido del Archivo (primeras 20 líneas)</h3>";
$lines = file($plugin_file);
echo "<pre>";
for ($i = 0; $i < min(20, count($lines)); $i++) {
    echo sprintf("%3d: %s", $i + 1, htmlspecialchars($lines[$i]));
}
echo "</pre>";

// 5. Verificar registro en base de datos
echo "<h3>5. Estado en Base de Datos</h3>";
try {
    // Conectar a la base de datos usando configuración de osTicket
    $config_file = dirname(__FILE__) . '/include/ost-config.php';
    if (file_exists($config_file)) {
        include_once $config_file;
        
        if (defined('DBHOST') && defined('DBNAME') && defined('DBUSER') && defined('DBPASS')) {
            $mysqli = new mysqli(DBHOST, DBUSER, DBPASS, DBNAME);
            
            if ($mysqli->connect_error) {
                echo "<p style='color: red;'>✗ Error conectando a BD: " . $mysqli->connect_error . "</p>";
            } else {
                echo "<p style='color: green;'>✓ Conectado a base de datos</p>";
                
                $result = $mysqli->query("SELECT * FROM ost_plugin WHERE install_path = 'whatsapp'");
                if ($result && $result->num_rows > 0) {
                    $plugin_data = $result->fetch_assoc();
                    echo "<p style='color: green;'>✓ Plugin registrado en BD</p>";
                    echo "<ul>";
                    echo "<li><strong>ID:</strong> " . $plugin_data['id'] . "</li>";
                    echo "<li><strong>Nombre:</strong> " . htmlspecialchars($plugin_data['name']) . "</li>";
                    echo "<li><strong>Activo:</strong> " . ($plugin_data['isactive'] ? 'Sí' : 'No') . "</li>";
                    echo "</ul>";
                } else {
                    echo "<p style='color: red;'>✗ Plugin no encontrado en BD</p>";
                }
                
                $mysqli->close();
            }
        } else {
            echo "<p style='color: red;'>✗ Configuración de BD no encontrada</p>";
        }
    } else {
        echo "<p style='color: red;'>✗ Archivo de configuración no encontrado</p>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>Error verificando BD: " . htmlspecialchars($e->getMessage()) . "</p>";
}

echo "<hr>";
echo "<h3>Recomendaciones</h3>";
echo "<ol>";
echo "<li>Si hay errores de sintaxis, corregir el archivo plugin.php</li>";
echo "<li>Si el archivo está correcto pero osTicket no lo detecta, limpiar cache</li>";
echo "<li>Verificar permisos de archivo en el servidor</li>";
echo "<li>Reiniciar servicio web si es necesario</li>";
echo "</ol>";
?>
