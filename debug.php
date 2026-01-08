<?php
// Archivo temporal para debug
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

echo "<h2>Diagnóstico de osTicket</h2>";

// Verificar PHP
echo "<h3>Información de PHP:</h3>";
echo "Versión PHP: " . PHP_VERSION . "<br>";
echo "MySQLi cargado: " . (extension_loaded('mysqli') ? 'SÍ' : 'NO') . "<br>";

// Verificar conexión a MariaDB
echo "<h3>Prueba de Conexión a MariaDB:</h3>";
try {
    $connection = new mysqli('localhost', 'sistemas', 'adn', 'os_ticket', 3309);
    if ($connection->connect_error) {
        echo "❌ Error de conexión: " . $connection->connect_error . "<br>";
    } else {
        echo "✅ Conexión exitosa a MariaDB en puerto 3309<br>";
        echo "Versión del servidor: " . $connection->server_info . "<br>";
        $connection->close();
    }
} catch (Exception $e) {
    echo "❌ Excepción: " . $e->getMessage() . "<br>";
}

// Verificar permisos de archivos
echo "<h3>Permisos de Archivos:</h3>";
$config_file = 'include/ost-config.php';
echo "Archivo ost-config.php existe: " . (file_exists($config_file) ? 'SÍ' : 'NO') . "<br>";
echo "Archivo ost-config.php escribible: " . (is_writable($config_file) ? 'SÍ' : 'NO') . "<br>";

// Verificar directorio setup
echo "Directorio setup existe: " . (is_dir('setup') ? 'SÍ' : 'NO') . "<br>";

echo "<h3>Extensiones PHP Requeridas:</h3>";
$required_extensions = ['mysqli', 'gd', 'iconv', 'xml', 'json', 'mbstring'];
foreach ($required_extensions as $ext) {
    echo "$ext: " . (extension_loaded($ext) ? '✅' : '❌') . "<br>";
}
?>
