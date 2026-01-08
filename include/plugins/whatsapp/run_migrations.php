<?php
/**
 * Script Ejecutable de Migraciones - Plugin WhatsApp
 * 
 * Ejecuta las migraciones de base de datos del plugin WhatsApp
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

// Incluir archivos de osTicket
require_once dirname(dirname(dirname(dirname(__FILE__)))) . '/main.inc.php';

echo "=== Ejecutor de Migraciones Plugin WhatsApp ===\n";
echo "Iniciando ejecución de migraciones...\n\n";

try {
    // Verificar conexión a base de datos
    echo "Verificando conexión a base de datos...\n";
    $test = db_query('SELECT 1');
    if (!$test) {
        throw new Exception('No se pudo conectar a la base de datos');
    }
    echo "✓ Conexión a base de datos OK\n\n";
    
    // Directorio de migraciones
    $migration_dir = dirname(__FILE__) . '/migrations/';
    
    if (!is_dir($migration_dir)) {
        throw new Exception('Directorio de migraciones no encontrado: ' . $migration_dir);
    }
    
    // Obtener archivos de migración
    $migrations = glob($migration_dir . '*.sql');
    sort($migrations);
    
    if (empty($migrations)) {
        echo "No se encontraron archivos de migración.\n";
        exit(0);
    }
    
    echo "Encontradas " . count($migrations) . " migraciones:\n";
    foreach ($migrations as $migration) {
        echo "  - " . basename($migration) . "\n";
    }
    echo "\n";
    
    // Ejecutar cada migración
    foreach ($migrations as $migration_file) {
        $migration_name = basename($migration_file);
        echo "Ejecutando: $migration_name\n";
        
        $sql_content = file_get_contents($migration_file);
        if (empty($sql_content)) {
            echo "⚠️  Archivo vacío: $migration_name\n";
            continue;
        }
        
        // Dividir en statements individuales
        $statements = explode(';', $sql_content);
        
        foreach ($statements as $statement) {
            $statement = trim($statement);
            
            // Saltar comentarios y líneas vacías
            if (empty($statement) || 
                strpos($statement, '--') === 0 || 
                strpos($statement, '/*') === 0) {
                continue;
            }
            
            try {
                db_query($statement);
            } catch (Exception $e) {
                // Ignorar errores de "tabla ya existe" y similares
                if (strpos($e->getMessage(), 'already exists') !== false ||
                    strpos($e->getMessage(), 'Duplicate column') !== false) {
                    echo "⚠️  Ya existe: " . substr($statement, 0, 50) . "...\n";
                    continue;
                } else {
                    throw $e;
                }
            }
        }
        
        echo "✓ $migration_name ejecutada exitosamente\n";
    }
    
    echo "\n=== Migraciones Completadas ===\n";
    echo "Todas las migraciones se ejecutaron correctamente.\n\n";
    
    // Verificar tablas creadas
    echo "Verificando tablas creadas:\n";
    $tables = array(
        'ost_whatsapp_config',
        'ost_whatsapp_users', 
        'ost_whatsapp_messages',
        'ost_whatsapp_templates',
        'ost_whatsapp_attachments'
    );
    
    foreach ($tables as $table) {
        $result = db_query("SHOW TABLES LIKE '$table'");
        if ($result && db_num_rows($result)) {
            echo "✓ Tabla $table creada\n";
        } else {
            echo "❌ Tabla $table NO encontrada\n";
        }
    }
    
    echo "\n=== Instalación Completa ===\n";
    echo "El plugin WhatsApp está listo para usar.\n";
    echo "Próximos pasos:\n";
    echo "1. Ir a Admin Panel > Manage > Plugins\n";
    echo "2. Activar 'WhatsApp Integration Plugin'\n";
    echo "3. Configurar credenciales de WaAPI.app\n";
    echo "4. Probar la integración\n\n";
    
} catch (Exception $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
