<?php
/**
 * Script de Instalación - Plugin WhatsApp para osTicket
 * 
 * Ejecuta las migraciones de base de datos y configura el plugin
 * para su primer uso
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

// Verificar que se ejecute desde línea de comandos o con permisos admin
if (php_sapi_name() !== 'cli' && !isset($_SESSION['admin'])) {
    die('Este script solo puede ejecutarse desde línea de comandos o por administradores');
}

// Incluir archivos de osTicket
require_once dirname(dirname(dirname(dirname(__FILE__)))) . '/main.inc.php';

class WhatsAppPluginInstaller {
    
    private $plugin_dir;
    private $migration_dir;
    private $errors = array();
    private $warnings = array();
    
    public function __construct() {
        $this->plugin_dir = dirname(__FILE__);
        $this->migration_dir = $this->plugin_dir . '/migrations/';
    }
    
    /**
     * Ejecutar instalación completa
     */
    public function install() {
        echo "=== Instalador Plugin WhatsApp para osTicket ===\n";
        echo "Iniciando instalación...\n\n";
        
        // Forzar salida inmediata
        if (ob_get_level()) ob_end_flush();
        flush();
        
        // Verificar requisitos del sistema
        if (!$this->checkRequirements()) {
            $this->showErrors();
            return false;
        }
        
        // Ejecutar migraciones de base de datos
        if (!$this->runMigrations()) {
            $this->showErrors();
            return false;
        }
        
        // Crear directorios necesarios
        if (!$this->createDirectories()) {
            $this->showErrors();
            return false;
        }
        
        // Configurar permisos de archivos
        if (!$this->setPermissions()) {
            $this->showWarnings();
        }
        
        // Registrar plugin en osTicket
        if (!$this->registerPlugin()) {
            $this->showErrors();
            return false;
        }
        
        echo "\n=== Instalación Completada Exitosamente ===\n";
        echo "El plugin WhatsApp ha sido instalado correctamente.\n\n";
        echo "Próximos pasos:\n";
        echo "1. Ir a Admin Panel > Manage > Plugins\n";
        echo "2. Activar 'WhatsApp Integration Plugin'\n";
        echo "3. Configurar credenciales de WaAPI.app\n";
        echo "4. Probar la integración\n\n";
        
        if (!empty($this->warnings)) {
            $this->showWarnings();
        }
        
        return true;
    }
    
    /**
     * Verificar requisitos del sistema
     */
    private function checkRequirements() {
        echo "Verificando requisitos del sistema...\n";
        $passed = true;
        
        // Verificar versión PHP
        if (version_compare(PHP_VERSION, '7.4.0', '<')) {
            $this->errors[] = 'PHP 7.4 o superior requerido. Versión actual: ' . PHP_VERSION;
            $passed = false;
        } else {
            echo "✓ PHP " . PHP_VERSION . " OK\n";
        }
        
        // Verificar extensiones PHP requeridas
        $required_extensions = array('curl', 'json', 'openssl', 'hash');
        foreach ($required_extensions as $ext) {
            if (!extension_loaded($ext)) {
                $this->errors[] = "Extensión PHP '$ext' no está disponible";
                $passed = false;
            } else {
                echo "✓ Extensión $ext OK\n";
            }
        }
        
        // Verificar conexión a base de datos
        try {
            db_query('SELECT 1');
            echo "✓ Conexión a base de datos OK\n";
        } catch (Exception $e) {
            $this->errors[] = 'Error conectando a base de datos: ' . $e->getMessage();
            $passed = false;
        }
        
        // Verificar permisos de escritura
        if (!is_writable($this->plugin_dir)) {
            $this->warnings[] = 'Directorio del plugin no tiene permisos de escritura: ' . $this->plugin_dir;
        } else {
            echo "✓ Permisos de escritura OK\n";
        }
        
        // Verificar que osTicket esté instalado
        if (!defined('OSTINSTALLED') || !OSTINSTALLED) {
            $this->errors[] = 'osTicket no está instalado correctamente';
            $passed = false;
        } else {
            echo "✓ osTicket instalado OK\n";
        }
        
        return $passed;
    }
    
    /**
     * Ejecutar migraciones de base de datos
     */
    private function runMigrations() {
        echo "\nEjecutando migraciones de base de datos...\n";
        
        if (!is_dir($this->migration_dir)) {
            $this->errors[] = 'Directorio de migraciones no encontrado: ' . $this->migration_dir;
            return false;
        }
        
        // Obtener archivos de migración ordenados
        $migrations = glob($this->migration_dir . '*.sql');
        sort($migrations);
        
        if (empty($migrations)) {
            $this->warnings[] = 'No se encontraron archivos de migración';
            return true;
        }
        
        foreach ($migrations as $migration_file) {
            $migration_name = basename($migration_file);
            echo "Ejecutando migración: $migration_name\n";
            
            try {
                $sql = file_get_contents($migration_file);
                if (empty($sql)) {
                    $this->warnings[] = "Archivo de migración vacío: $migration_name";
                    continue;
                }
                
                // Dividir en statements individuales
                $statements = $this->splitSqlStatements($sql);
                
                foreach ($statements as $statement) {
                    $statement = trim($statement);
                    if (empty($statement) || strpos($statement, '--') === 0) {
                        continue; // Saltar comentarios y líneas vacías
                    }
                    
                    db_query($statement);
                }
                
                echo "✓ $migration_name ejecutada exitosamente\n";
                
            } catch (Exception $e) {
                $this->errors[] = "Error ejecutando migración $migration_name: " . $e->getMessage();
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Crear directorios necesarios
     */
    private function createDirectories() {
        echo "\nCreando directorios necesarios...\n";
        
        $directories = array(
            ROOT_DIR . 'attachments/whatsapp/',
            $this->plugin_dir . '/logs/',
            $this->plugin_dir . '/cache/',
            $this->plugin_dir . '/temp/'
        );
        
        foreach ($directories as $dir) {
            if (!is_dir($dir)) {
                if (!mkdir($dir, 0755, true)) {
                    $this->errors[] = "No se pudo crear directorio: $dir";
                    return false;
                }
                echo "✓ Directorio creado: $dir\n";
            } else {
                echo "✓ Directorio existe: $dir\n";
            }
        }
        
        return true;
    }
    
    /**
     * Configurar permisos de archivos
     */
    private function setPermissions() {
        echo "\nConfigurando permisos de archivos...\n";
        
        $file_permissions = array(
            $this->plugin_dir . '/webhook.php' => 0644,
            $this->plugin_dir . '/plugin.php' => 0644,
            $this->plugin_dir . '/config.php' => 0644
        );
        
        $dir_permissions = array(
            $this->plugin_dir . '/logs/' => 0755,
            $this->plugin_dir . '/cache/' => 0755,
            $this->plugin_dir . '/temp/' => 0755,
            ROOT_DIR . 'attachments/whatsapp/' => 0755
        );
        
        $success = true;
        
        // Configurar permisos de archivos
        foreach ($file_permissions as $file => $perm) {
            if (file_exists($file)) {
                if (!chmod($file, $perm)) {
                    $this->warnings[] = "No se pudieron configurar permisos para: $file";
                    $success = false;
                } else {
                    echo "✓ Permisos configurados: $file\n";
                }
            }
        }
        
        // Configurar permisos de directorios
        foreach ($dir_permissions as $dir => $perm) {
            if (is_dir($dir)) {
                if (!chmod($dir, $perm)) {
                    $this->warnings[] = "No se pudieron configurar permisos para: $dir";
                    $success = false;
                } else {
                    echo "✓ Permisos configurados: $dir\n";
                }
            }
        }
        
        return $success;
    }
    
    /**
     * Registrar plugin en osTicket
     */
    private function registerPlugin() {
        echo "\nRegistrando plugin en osTicket...\n";
        
        try {
            // Verificar si el plugin ya está registrado
            $sql = 'SELECT id FROM ost_plugin WHERE name = %s';
            $existing = db_query($sql, 'WhatsApp Integration');
            
            if ($existing && db_num_rows($existing)) {
                echo "✓ Plugin ya está registrado\n";
                return true;
            }
            
            // Registrar nuevo plugin
            $sql = 'INSERT INTO ost_plugin (name, install_path, isphar, isactive, version, created, updated) 
                    VALUES (%s, %s, 0, 0, %s, NOW(), NOW())';
            
            $install_path = 'whatsapp/plugin.php';
            $version = '1.0.0';
            
            if (!db_query($sql, 'WhatsApp Integration', $install_path, $version)) {
                $this->errors[] = 'Error registrando plugin en base de datos';
                return false;
            }
            
            echo "✓ Plugin registrado exitosamente\n";
            return true;
            
        } catch (Exception $e) {
            $this->errors[] = 'Error registrando plugin: ' . $e->getMessage();
            return false;
        }
    }
    
    /**
     * Dividir SQL en statements individuales
     */
    private function splitSqlStatements($sql) {
        // Remover comentarios de línea
        $sql = preg_replace('/--.*$/m', '', $sql);
        
        // Dividir por punto y coma, pero no dentro de strings
        $statements = array();
        $current = '';
        $in_string = false;
        $string_char = '';
        
        for ($i = 0; $i < strlen($sql); $i++) {
            $char = $sql[$i];
            
            if (!$in_string && ($char === '"' || $char === "'")) {
                $in_string = true;
                $string_char = $char;
            } elseif ($in_string && $char === $string_char) {
                $in_string = false;
            } elseif (!$in_string && $char === ';') {
                $statements[] = trim($current);
                $current = '';
                continue;
            }
            
            $current .= $char;
        }
        
        if (!empty(trim($current))) {
            $statements[] = trim($current);
        }
        
        return array_filter($statements);
    }
    
    /**
     * Mostrar errores
     */
    private function showErrors() {
        if (!empty($this->errors)) {
            echo "\n❌ ERRORES ENCONTRADOS:\n";
            foreach ($this->errors as $error) {
                echo "   • $error\n";
            }
            echo "\n";
        }
    }
    
    /**
     * Mostrar advertencias
     */
    private function showWarnings() {
        if (!empty($this->warnings)) {
            echo "\n⚠️  ADVERTENCIAS:\n";
            foreach ($this->warnings as $warning) {
                echo "   • $warning\n";
            }
            echo "\n";
        }
    }
    
    /**
     * Desinstalar plugin
     */
    public function uninstall($keep_data = true) {
        echo "=== Desinstalador Plugin WhatsApp ===\n";
        
        if ($keep_data) {
            echo "Desinstalando plugin (manteniendo datos)...\n";
        } else {
            echo "Desinstalando plugin (eliminando todos los datos)...\n";
        }
        
        try {
            // Desactivar plugin
            $sql = 'UPDATE ost_plugin SET isactive = 0 WHERE name = %s';
            db_query($sql, 'WhatsApp Integration');
            
            if (!$keep_data) {
                // Eliminar datos del plugin
                $tables = array(
                    'ost_whatsapp_messages',
                    'ost_whatsapp_attachments', 
                    'ost_whatsapp_templates',
                    'ost_whatsapp_users',
                    'ost_whatsapp_config'
                );
                
                foreach ($tables as $table) {
                    db_query("DROP TABLE IF EXISTS `$table`");
                    echo "✓ Tabla eliminada: $table\n";
                }
                
                // Limpiar campos agregados a tablas existentes
                $this->cleanupExistingTables();
            }
            
            echo "✓ Plugin desinstalado exitosamente\n";
            return true;
            
        } catch (Exception $e) {
            echo "❌ Error desinstalando: " . $e->getMessage() . "\n";
            return false;
        }
    }
    
    /**
     * Limpiar campos agregados a tablas existentes
     */
    private function cleanupExistingTables() {
        $cleanup_queries = array(
            'ALTER TABLE ost_ticket DROP COLUMN IF EXISTS whatsapp_phone',
            'ALTER TABLE ost_ticket DROP COLUMN IF EXISTS communication_channel', 
            'ALTER TABLE ost_ticket DROP COLUMN IF EXISTS whatsapp_enabled',
            'ALTER TABLE ost_ticket DROP COLUMN IF EXISTS whatsapp_last_message',
            'ALTER TABLE ost_user DROP COLUMN IF EXISTS whatsapp_phone',
            'ALTER TABLE ost_user DROP COLUMN IF EXISTS whatsapp_verified',
            'ALTER TABLE ost_user DROP COLUMN IF EXISTS whatsapp_opt_in',
            'ALTER TABLE ost_department DROP COLUMN IF EXISTS whatsapp_enabled',
            'ALTER TABLE ost_department DROP COLUMN IF EXISTS whatsapp_auto_reply',
            'ALTER TABLE ost_department DROP COLUMN IF EXISTS whatsapp_template_id',
            'ALTER TABLE ost_thread_entry DROP COLUMN IF EXISTS whatsapp_message_id',
            'ALTER TABLE ost_thread_entry DROP COLUMN IF EXISTS whatsapp_status'
        );
        
        foreach ($cleanup_queries as $query) {
            try {
                db_query($query);
            } catch (Exception $e) {
                // Ignorar errores de columnas que no existen
            }
        }
    }
}

// Ejecutar instalador si se llama desde línea de comandos
if (php_sapi_name() === 'cli') {
    $installer = new WhatsAppPluginInstaller();
    
    $action = isset($argv[1]) ? $argv[1] : 'install';
    
    switch ($action) {
        case 'install':
            $installer->install();
            break;
            
        case 'uninstall':
            $keep_data = !isset($argv[2]) || $argv[2] !== '--remove-data';
            $installer->uninstall($keep_data);
            break;
            
        default:
            echo "Uso: php install.php [install|uninstall] [--remove-data]\n";
            echo "  install     - Instalar plugin (por defecto)\n";
            echo "  uninstall   - Desinstalar plugin manteniendo datos\n";
            echo "  uninstall --remove-data - Desinstalar eliminando todos los datos\n";
            break;
    }
}
?>
