# Documentación: Permisos Diferenciados para Estados Resolved y Closed

## 📋 Información General

**Commit:** 3fa9383  
**Fecha:** 8 de diciembre de 2025  
**Autor:** quintana1308 <andres.leguizamon@sistemasadn.com>  
**Descripción:** Implementar permisos diferenciados para estados Resolved y Closed de tickets

## 🎯 Objetivo del Sistema

Este sistema implementa un control granular de permisos que permite:

1. **Analistas** pueden resolver tickets (estado "Resolved") pero no cerrarlos definitivamente
2. **Supervisores/Administradores** pueden tanto resolver como cerrar tickets
3. **Restricción especial:** Los analistas no pueden modificar tickets ya resueltos por otros

## 📁 Archivos Modificados

### 1. `include/class.ticket.php`
- **Líneas modificadas:** ~108-119 (zona de definición de permisos)
- **Cambio principal:** Agregar nuevo permiso `PERM_RESOLVE`

### 2. `include/class.staff.php`
- **Cambio:** Registro del nuevo permiso en el sistema de roles

### 3. `include/ajax.tickets.php`
- **Cambio:** Validación de permisos en operaciones AJAX de cambio de estado

### 4. `include/staff/templates/status-options.tmpl.php`
- **Cambio:** Filtrado de opciones de estado según permisos del usuario

### 5. `include/staff/ticket-open.inc.php`
- **Cambio:** Lógica de permisos en vista de ticket abierto

### 6. `include/staff/ticket-view.inc.php`
- **Cambio:** Lógica de permisos en vista detallada de ticket

## 🔧 Cambios Detallados por Archivo

### A. `include/class.ticket.php`

#### Agregar después de la línea donde se define `PERM_CLOSE`:
```php
const PERM_RESOLVE = 'ticket.resolve';
```

#### En la función que registra permisos, agregar:
```php
'ticket.resolve' => array(
    'title' => __('Resolve'),
    'desc'  => __('Ability to resolve tickets'),
    'primary' => true,
),
```

### B. `include/ajax.tickets.php`

#### Buscar la validación de permisos para cambio de estado y reemplazar:

**ANTES:**
```php
if (!$thisstaff->hasPerm(Ticket::PERM_CLOSE, false))
    continue;
```

**DESPUÉS:**
```php
// Verificar permisos específicos para cada estado
if ($s->getState() == 'closed') {
    if ($s->getId() == 2) { // Estado "Resolved"
        if (!$thisstaff->hasPerm(Ticket::PERM_RESOLVE, false))
            continue;
    } else { // Estado "Closed" u otros estados cerrados
        if (!$thisstaff->hasPerm(Ticket::PERM_CLOSE, false))
            continue;
    }
}
```

### C. `include/staff/templates/status-options.tmpl.php`

#### Buscar el bucle de estados y agregar validación:

**Buscar:**
```php
foreach (TicketStatusList::getStatuses(
    array('states' => $states)) as $s) {
    if (!$s->isEnabled()) continue;
```

**Agregar después de `if (!$s->isEnabled()) continue;`:**
```php
// Verificar permisos específicos para cada estado
if ($s->getState() == 'closed') {
    if ($s->getId() == 2) { // Estado "Resolved"
        if (!$thisstaff->hasPerm(Ticket::PERM_RESOLVE, false))
            continue;
    } else { // Estado "Closed" u otros estados cerrados
        if (!$thisstaff->hasPerm(Ticket::PERM_CLOSE, false))
            continue;
    }
}
```

### D. `include/staff/ticket-view.inc.php`

#### 1. Cambio en la sección de visualización de estado (línea ~321):

**ANTES:**
```php
if ($role->hasPerm(Ticket::PERM_CLOSE)) {?>
```

**DESPUÉS:**
```php
// Verificar permisos y restricciones para analistas
$canChangeStatus = ($role->hasPerm(Ticket::PERM_CLOSE) || $role->hasPerm(Ticket::PERM_RESOLVE));

// Restricción especial: Analistas no pueden cambiar estado de tickets ya resueltos
if ($role->hasPerm(Ticket::PERM_RESOLVE) && !$role->hasPerm(Ticket::PERM_CLOSE)) {
    // Es un analista (solo tiene PERM_RESOLVE)
    $currentStatus = $ticket->getStatus();
    if ($currentStatus && $currentStatus->getId() == 2) { // Ticket ya está "Resolved"
        $canChangeStatus = false; // No mostrar enlace de cambio de estado
    }
}

if ($canChangeStatus) {?>
```

#### 2. Cambio en sección de respuesta (línea ~1103):

**ANTES:**
```php
if ($role->hasPerm(Ticket::PERM_CLOSE) && !$outstanding)
```

**DESPUÉS:**
```php
// Restricción para analistas en tickets ya resueltos
$allowStateChange = true;
if ($role->hasPerm(Ticket::PERM_RESOLVE) && !$role->hasPerm(Ticket::PERM_CLOSE)) {
    // Es un analista (solo tiene PERM_RESOLVE)
    $currentStatus = $ticket->getStatus();
    if ($currentStatus && $currentStatus->getId() == 2) { // Ticket ya está "Resolved"
        $allowStateChange = false; // No permitir cambio de estado
    }
}

if (($role->hasPerm(Ticket::PERM_CLOSE) || $role->hasPerm(Ticket::PERM_RESOLVE)) && !$outstanding && $allowStateChange)
```

#### 3. Agregar validación en bucle de estados (después de `if (!$s->isEnabled()) continue;`):
```php
// Verificar permisos específicos para cada estado
if ($s->getState() == 'closed') {
    if ($s->getId() == 2) { // Estado "Resolved"
        if (!$role->hasPerm(Ticket::PERM_RESOLVE))
            continue;
    } else { // Estado "Closed" u otros estados cerrados
        if (!$role->hasPerm(Ticket::PERM_CLOSE))
            continue;
    }
}
```

#### 4. Cambio en sección de notas (línea ~1194):

**ANTES:**
```php
if ($ticket->isCloseable() === true
    && $role->hasPerm(Ticket::PERM_CLOSE))
```

**DESPUÉS:**
```php
// Restricción para analistas en tickets ya resueltos
$allowStateChange = true;
if ($role->hasPerm(Ticket::PERM_RESOLVE) && !$role->hasPerm(Ticket::PERM_CLOSE)) {
    // Es un analista (solo tiene PERM_RESOLVE)
    $currentStatus = $ticket->getStatus();
    if ($currentStatus && $currentStatus->getId() == 2) { // Ticket ya está "Resolved"
        $allowStateChange = false; // No permitir cambio de estado
    }
}

if ($ticket->isCloseable() === true
    && ($role->hasPerm(Ticket::PERM_CLOSE) || $role->hasPerm(Ticket::PERM_RESOLVE))
    && $allowStateChange)
```

### E. `include/staff/ticket-open.inc.php`

#### Aplicar los mismos cambios que en `ticket-view.inc.php` para las secciones correspondientes.

## 🚀 Instrucciones de Aplicación Post-Actualización

### Método 1: Aplicación Automática con Parche

1. **Verificar que existe el archivo de parche:**
   ```bash
   ls -la permisos-diferenciados.patch
   ```

2. **Aplicar el parche:**
   ```bash
   git apply permisos-diferenciados.patch
   ```

3. **Si hay conflictos, aplicar manualmente:**
   ```bash
   git apply --reject permisos-diferenciados.patch
   ```

### Método 2: Aplicación Manual

1. **Hacer backup de la instalación actual**
2. **Actualizar osTicket a la nueva versión**
3. **Aplicar cada cambio siguiendo esta documentación paso a paso**
4. **Verificar funcionamiento en entorno de pruebas**

## ✅ Lista de Verificación Post-Aplicación

- [ ] El nuevo permiso `PERM_RESOLVE` está definido en `class.ticket.php`
- [ ] Los analistas pueden ver solo la opción "Resolved" en estados cerrados
- [ ] Los supervisores pueden ver tanto "Resolved" como "Closed"
- [ ] Los analistas no pueden cambiar estado de tickets ya resueltos
- [ ] Las validaciones AJAX funcionan correctamente
- [ ] No hay errores PHP en los logs

## 🔍 Pruebas Recomendadas

### Como Analista (solo PERM_RESOLVE):
1. Crear un ticket nuevo
2. Verificar que puede cambiar a "Resolved"
3. Verificar que NO puede cambiar a "Closed"
4. Intentar cambiar estado de un ticket ya "Resolved" (debe fallar)

### Como Supervisor (PERM_CLOSE):
1. Verificar que puede cambiar a cualquier estado
2. Verificar que puede modificar tickets ya resueltos

## 📞 Contacto y Soporte

**Desarrollador:** quintana1308  
**Email:** andres.leguizamon@sistemasadn.com  
**Fecha de creación:** 29 de diciembre de 2025

## 📝 Notas Adicionales

- **ID del Estado "Resolved":** 2
- **Estados con state='closed':** Resolved, Closed
- **Restricción clave:** Analistas no pueden modificar tickets ID estado = 2
- **Compatibilidad:** Mantiene funcionalidad existente para usuarios con PERM_CLOSE

---

**⚠️ IMPORTANTE:** Siempre hacer backup completo antes de aplicar estos cambios en producción.
