# 🔧 Guía de Recuperación de Permisos Diferenciados

## 📁 Archivos Creados para la Recuperación

Este paquete de recuperación incluye los siguientes archivos:

### 📋 Documentación
- **`DOCUMENTACION_PERMISOS_DIFERENCIADOS.md`** - Documentación completa con todos los cambios detallados
- **`README_RECUPERACION_PERMISOS.md`** - Esta guía de uso

### 🔄 Archivos de Aplicación
- **`permisos-diferenciados.patch`** - Archivo de parche para aplicación automática
- **`aplicar_permisos_diferenciados.bat`** - Script automatizado de aplicación
- **`verificar_permisos_diferenciados.bat`** - Script de verificación post-aplicación

## 🚀 Proceso de Recuperación Post-Actualización

### Opción 1: Aplicación Automática (Recomendada)

1. **Hacer backup completo** de tu instalación osTicket actualizada
2. **Ejecutar el script de aplicación:**
   ```cmd
   aplicar_permisos_diferenciados.bat
   ```
3. **Verificar la aplicación:**
   ```cmd
   verificar_permisos_diferenciados.bat
   ```

### Opción 2: Aplicación Manual

1. **Abrir** `DOCUMENTACION_PERMISOS_DIFERENCIADOS.md`
2. **Seguir** las instrucciones paso a paso en "Cambios Detallados por Archivo"
3. **Verificar** usando el script de verificación

### Opción 3: Aplicación con Git (Si tienes Git disponible)

1. **Aplicar el parche directamente:**
   ```bash
   git apply permisos-diferenciados.patch
   ```
2. **Si hay conflictos:**
   ```bash
   git apply --reject permisos-diferenciados.patch
   ```
3. **Resolver conflictos manualmente** usando la documentación

## ✅ Lista de Verificación Post-Recuperación

Después de aplicar los cambios, verificar:

- [ ] No hay errores PHP en los logs de Apache/Nginx
- [ ] Los analistas pueden cambiar tickets a "Resolved"
- [ ] Los analistas NO pueden cambiar tickets a "Closed"
- [ ] Los analistas NO pueden modificar tickets ya "Resolved"
- [ ] Los supervisores pueden usar ambos estados
- [ ] La interfaz muestra las opciones correctas según el rol

## 🧪 Pruebas Recomendadas

### Como Analista:
1. Crear ticket nuevo → Cambiar a "Resolved" ✓
2. Intentar cambiar a "Closed" → Debe fallar ✗
3. Intentar modificar ticket ya "Resolved" → Debe fallar ✗

### Como Supervisor:
1. Cambiar tickets a cualquier estado ✓
2. Modificar tickets ya resueltos ✓

## 🆘 Solución de Problemas

### Error: "No se puede aplicar el parche"
- **Causa:** La nueva versión de osTicket cambió significativamente
- **Solución:** Usar aplicación manual con la documentación

### Error: "Función no definida"
- **Causa:** Falta definir `PERM_RESOLVE`
- **Solución:** Verificar `include/class.ticket.php` línea ~108-119

### Error: "Los analistas ven opciones incorrectas"
- **Causa:** Falta validación en templates
- **Solución:** Verificar `include/staff/templates/status-options.tmpl.php`

## 📞 Información de Contacto

**Desarrollador Original:** quintana1308  
**Email:** andres.leguizamon@sistemasadn.com  
**Commit de Referencia:** 3fa9383

## 🔄 Mantenimiento Futuro

### Antes de cada actualización de osTicket:
1. Hacer backup de estos archivos de recuperación
2. Documentar cualquier cambio adicional realizado
3. Probar la recuperación en entorno de desarrollo

### Después de cada actualización:
1. Ejecutar `aplicar_permisos_diferenciados.bat`
2. Ejecutar `verificar_permisos_diferenciados.bat`
3. Realizar pruebas funcionales
4. Actualizar documentación si es necesario

---

**⚠️ IMPORTANTE:** 
- Siempre hacer backup antes de aplicar cambios
- Probar en entorno de desarrollo primero
- Verificar logs de errores después de la aplicación
- Mantener estos archivos actualizados con cualquier modificación futura
