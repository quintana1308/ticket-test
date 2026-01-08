@echo off
echo ========================================
echo Script de Verificacion de Permisos Diferenciados
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

echo Verificando implementacion de permisos diferenciados...
echo.

REM Verificar PERM_RESOLVE en class.ticket.php
findstr /C:"PERM_RESOLVE" "include\class.ticket.php" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✓ PERM_RESOLVE definido en class.ticket.php
) else (
    echo ✗ PERM_RESOLVE NO encontrado en class.ticket.php
)

REM Verificar validaciones en ajax.tickets.php
findstr /C:"Estado \"Resolved\"" "include\ajax.tickets.php" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✓ Validaciones de permisos en ajax.tickets.php
) else (
    echo ✗ Validaciones NO encontradas en ajax.tickets.php
)

REM Verificar cambios en status-options.tmpl.php
findstr /C:"Verificar permisos específicos" "include\staff\templates\status-options.tmpl.php" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✓ Validaciones en status-options.tmpl.php
) else (
    echo ✗ Validaciones NO encontradas en status-options.tmpl.php
)

REM Verificar cambios en ticket-view.inc.php
findstr /C:"canChangeStatus" "include\staff\ticket-view.inc.php" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✓ Logica de permisos en ticket-view.inc.php
) else (
    echo ✗ Logica NO encontrada en ticket-view.inc.php
)

REM Verificar cambios en ticket-open.inc.php
findstr /C:"allowStateChange" "include\staff\ticket-open.inc.php" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✓ Logica de permisos en ticket-open.inc.php
) else (
    echo ✗ Logica NO encontrada en ticket-open.inc.php
)

echo.
echo ========================================
echo Verificacion completada
echo ========================================
echo.
echo Si alguna verificacion fallo (✗), revise:
echo 1. DOCUMENTACION_PERMISOS_DIFERENCIADOS.md
echo 2. Aplique los cambios manualmente
echo 3. Verifique que no hay errores de sintaxis PHP
echo.
echo Presione cualquier tecla para continuar...
pause >nul
