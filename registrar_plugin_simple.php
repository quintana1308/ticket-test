<?php
/**
 * Script simplificado para registrar el plugin WhatsApp en osTicket
 * Versión sin funciones problemáticas que causan error 500
 */

// Incluir bootstrap de osTicket
require_once dirname(__FILE__) . '/main.inc.php';

echo "<h2>Registro Manual del Plugin WhatsApp</h2>";

try {
    // Verificar si el plugin ya está registrado
    $existing = db_query("SELECT * FROM ost_plugin WHERE install_path = 'whatsapp'");
    
    if (db_num_rows($existing) > 0) {
        echo "<p style='color: orange;'>⚠ El plugin WhatsApp ya está registrado en la base de datos.</p>";
        
        // Mostrar información del plugin existente
        $plugin_data = db_fetch_assoc($existing);
        echo "<h3>Plugin Existente:</h3>";
        echo "<ul>";
        echo "<li><strong>ID:</strong> " . $plugin_data['id'] . "</li>";
        echo "<li><strong>Nombre:</strong> " . htmlspecialchars($plugin_data['name']) . "</li>";
        echo "<li><strong>Ruta:</strong> " . htmlspecialchars($plugin_data['install_path']) . "</li>";
        echo "<li><strong>Versión:</strong> " . htmlspecialchars($plugin_data['version']) . "</li>";
        echo "<li><strong>Activo:</strong> " . ($plugin_data['isactive'] ? 'Sí' : 'No') . "</li>";
        echo "</ul>";
        
        // Opción para activar si está inactivo
        if (!$plugin_data['isactive']) {
            echo "<p><strong>Acción recomendada:</strong> El plugin existe pero está inactivo.</p>";
            echo "<form method='post'>";
            echo "<input type='hidden' name='action' value='activate'>";
            echo "<input type='hidden' name='plugin_id' value='" . $plugin_data['id'] . "'>";
            echo "<button type='submit' style='background: green; color: white; padding: 10px;'>Activar Plugin</button>";
            echo "</form>";
        }
        
    } else {
        echo "<p>ℹ El plugin no está registrado. Procediendo con el registro...</p>";
        
        // Registrar el plugin en la base de datos usando sintaxis simple
        $plugin_path = 'whatsapp';
        $plugin_name = 'WhatsApp Integration';
        $plugin_version = '1.0.0';
        $install_date = date('Y-m-d H:i:s');
        
        // Usar sintaxis SQL simple sin funciones problemáticas
        $sql = "INSERT INTO ost_plugin (name, install_path, version, isactive, installed) VALUES (
            '$plugin_name', 
            '$plugin_path', 
            '$plugin_version', 
            1, 
            '$install_date'
        )";
        
        $result = db_query($sql);
        
        if ($result) {
            $plugin_id = db_insert_id();
            echo "<p style='color: green;'>✓ Plugin registrado exitosamente con ID: $plugin_id</p>";
            
            echo "<h3>Plugin Registrado:</h3>";
            echo "<ul>";
            echo "<li><strong>Nombre:</strong> $plugin_name</li>";
            echo "<li><strong>Versión:</strong> $plugin_version</li>";
            echo "<li><strong>Ruta:</strong> $plugin_path</li>";
            echo "<li><strong>Estado:</strong> Instalado y Activo</li>";
            echo "</ul>";
            
        } else {
            echo "<p style='color: red;'>✗ Error registrando el plugin</p>";
            if (function_exists('db_error')) {
                echo "<p>Error: " . db_error() . "</p>";
            }
        }
    }
    
    // Procesar acciones POST
    if (isset($_POST['action']) && $_POST['action'] == 'activate' && isset($_POST['plugin_id'])) {
        $plugin_id = (int)$_POST['plugin_id'];
        $update_sql = "UPDATE ost_plugin SET isactive = 1 WHERE id = $plugin_id";
        $update_result = db_query($update_sql);
        
        if ($update_result) {
            echo "<p style='color: green;'>✓ Plugin activado exitosamente</p>";
        } else {
            echo "<p style='color: red;'>✗ Error activando plugin</p>";
        }
    }
    
} catch (Exception $e) {
    echo "<p style='color: red;'>Error: " . htmlspecialchars($e->getMessage()) . "</p>";
}

echo "<hr>";
echo "<h3>Verificación Final</h3>";
echo "<p>Después de ejecutar este script:</p>";
echo "<ol>";
echo "<li>Ve a <strong>Admin Panel → Manage → Plugins</strong></li>";
echo "<li>El plugin 'WhatsApp Integration' debería aparecer en la lista</li>";
echo "<li>Si aparece como 'Installed', puedes configurarlo</li>";
echo "<li>Si no aparece, verifica los logs de error del servidor</li>";
echo "</ol>";

echo "<p><a href='scp/plugins.php' style='background: blue; color: white; padding: 10px; text-decoration: none;'>Ir al Panel de Plugins</a></p>";
?>
