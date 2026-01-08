@echo off
echo ========================================
echo Script de Aplicacion de Permisos Diferenciados
echo osTicket - Commit 3fa9383
echo ========================================
echo.

REM Verificar si estamos en el directorio correcto
if not exist "include\class.ticket.php" (
    echo ERROR: No se encuentra el archivo include\class.ticket.php
    echo Asegurese de ejecutar este script desde el directorio raiz de osTicket
    pause
    exit /b 1
)

echo [1/3] Creando backup de archivos originales...
if not exist "backup_pre_permisos" mkdir backup_pre_permisos

copy "include\class.ticket.php" "backup_pre_permisos\class.ticket.php.bak" >nul 2>&1
copy "include\class.staff.php" "backup_pre_permisos\class.staff.php.bak" >nul 2>&1
copy "include\ajax.tickets.php" "backup_pre_permisos\ajax.tickets.php.bak" >nul 2>&1
copy "include\staff\templates\status-options.tmpl.php" "backup_pre_permisos\status-options.tmpl.php.bak" >nul 2>&1
copy "include\staff\ticket-open.inc.php" "backup_pre_permisos\ticket-open.inc.php.bak" >nul 2>&1
copy "include\staff\ticket-view.inc.php" "backup_pre_permisos\ticket-view.inc.php.bak" >nul 2>&1

echo Backup creado en: backup_pre_permisos\
echo.

echo [2/3] Intentando aplicar parche automaticamente...
if exist "permisos-diferenciados.patch" (
    git apply permisos-diferenciados.patch >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo ✓ Parche aplicado exitosamente!
        echo.
        echo [3/3] Verificando archivos modificados...
        echo ✓ include\class.ticket.php
        echo ✓ include\class.staff.php  
        echo ✓ include\ajax.tickets.php
        echo ✓ include\staff\templates\status-options.tmpl.php
        echo ✓ include\staff\ticket-open.inc.php
        echo ✓ include\staff\ticket-view.inc.php
        echo.
        echo ========================================
        echo ✓ APLICACION COMPLETADA EXITOSAMENTE
        echo ========================================
        echo.
        echo Recomendaciones post-aplicacion:
        echo 1. Verificar que no hay errores PHP en los logs
        echo 2. Probar funcionalidad con usuario analista
        echo 3. Probar funcionalidad con usuario supervisor
        echo 4. Revisar permisos en Admin Panel ^> Staff ^> Roles
        echo.
    ) else (
        echo ✗ Error al aplicar el parche automaticamente
        echo.
        echo Posibles causas:
        echo - La version de osTicket ha cambiado significativamente
        echo - Los archivos ya fueron modificados manualmente
        echo - Conflictos en el codigo
        echo.
        echo SOLUCION: Aplicar cambios manualmente usando:
        echo DOCUMENTACION_PERMISOS_DIFERENCIADOS.md
        echo.
    )
) else (
    echo ✗ No se encuentra el archivo permisos-diferenciados.patch
    echo.
    echo Para generar el parche ejecute:
    echo git format-patch -1 3fa9383 --stdout ^> permisos-diferenciados.patch
    echo.
    echo O aplique los cambios manualmente usando:
    echo DOCUMENTACION_PERMISOS_DIFERENCIADOS.md
    echo.
)

echo Presione cualquier tecla para continuar...
pause >nul
