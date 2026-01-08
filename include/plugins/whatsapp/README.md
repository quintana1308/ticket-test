# 📱 Plugin WhatsApp para osTicket

## 📋 Descripción

Plugin completo para integrar WhatsApp como canal principal de comunicación en osTicket usando WaAPI.app. Diseñado para ser completamente no invasivo y sobrevivir actualizaciones del sistema principal.

## ✨ Características Principales

- **Comunicación Bidireccional**: Clientes crean tickets y reciben respuestas por WhatsApp
- **Integración No Invasiva**: Plugin que sobrevive actualizaciones de osTicket
- **Compatibilidad Total**: Funciona con sistema de permisos diferenciados existente
- **Experiencia Unificada**: WhatsApp como canal principal, sin dependencia de email
- **Sistema de Plantillas**: Mensajes personalizables para diferentes eventos
- **Manejo de Adjuntos**: Soporte completo para archivos multimedia
- **Rate Limiting**: Protección contra spam y uso excesivo
- **Logs Detallados**: Sistema completo de auditoría y monitoreo

## 🔧 Requisitos del Sistema

- **osTicket**: v1.18.2 o superior
- **PHP**: 7.4 o superior
- **Extensiones PHP**: curl, json, openssl, hash
- **Base de Datos**: MySQL 5.7+ o MariaDB 10.2+
- **Cuenta WaAPI.app**: Instancia activa con API habilitada

## 📦 Instalación

### 1. Descargar Plugin

```bash
cd /path/to/osticket/include/plugins/
git clone https://github.com/quintana1308/osticket-whatsapp-plugin.git whatsapp
```

### 2. Ejecutar Migraciones de Base de Datos

```bash
cd whatsapp
php run_migrations.php
```

### 3. Activar Plugin

1. Ir a **Admin Panel > Manage > Plugins**
2. Buscar "WhatsApp Integration"
3. Hacer clic en "Enable"

### 4. Configurar Credenciales

1. Ir a **Admin Panel > Manage > Plugins > WhatsApp Integration**
2. Completar configuración de WaAPI.app:
   - API Token
   - Instance ID
   - Webhook Secret
   - Número WhatsApp Business

### 5. Probar Integración

Usar el botón "Probar Conexión" en la configuración del plugin.

## ⚙️ Configuración

### Configuración Básica

| Campo | Descripción | Requerido |
|-------|-------------|-----------|
| API Token | Token de autenticación WaAPI.app | 
| Instance ID | ID de instancia WhatsApp | 
| Webhook Secret | Clave secreta para validar webhooks | 
| Business Phone | Número WhatsApp Business | 

### Configuración de Tickets

- **Departamento por Defecto**: Donde se crearán tickets WhatsApp
- **Crear Usuarios Automáticamente**: Auto-crear usuarios nuevos
- **Rate Limit**: Límite de mensajes por minuto

### Configuración de Notificaciones

- Notificar creación de tickets
- Notificar asignación de tickets  
- Notificar resolución de tickets
- Notificar cierre de tickets

## 🔗 Configuración WaAPI.app

### 1. Webhook URL

Configurar en WaAPI.app:
```
https://tu-osticket.com/include/plugins/whatsapp/webhook.php
```

### 2. Eventos a Escuchar

- `message` - Mensajes entrantes
- `ack` - Confirmaciones de entrega
- `ready` - Instancia lista
- `disconnected` - Desconexión

## 📋 Uso del Plugin

### Para Clientes

1. **Enviar Mensaje**: Escribir al número WhatsApp Business
2. **Crear Ticket**: Automáticamente se crea ticket en osTicket
3. **Recibir Respuestas**: Agentes responden por WhatsApp
4. **Seguimiento**: Todas las interacciones quedan registradas

### Para Agentes

1. **Ver Tickets WhatsApp**: Identificados con icono especial
2. **Responder**: Usar interfaz normal de osTicket
3. **Cambiar Estado**: Notificaciones automáticas por WhatsApp
4. **Ver Historial**: Historial completo de mensajes WhatsApp

### Para Administradores

1. **Configurar Plugin**: Panel de configuración completo
2. **Gestionar Plantillas**: Personalizar mensajes automáticos
3. **Ver Estadísticas**: Reportes de actividad WhatsApp
4. **Monitorear Logs**: Sistema completo de auditoría

## 🎨 Plantillas de Mensajes

### Plantillas Incluidas

- **ticket_created**: Confirmación de ticket creado
- **agent_reply**: Respuesta de agente
- **ticket_assigned**: Notificación de asignación
- **ticket_resolved**: Notificación de resolución
- **ticket_closed**: Notificación de cierre

### Variables Disponibles

- `%{ticket.number}` - Número de ticket
- `%{ticket.subject}` - Asunto del ticket
- `%{user.name}` - Nombre del usuario
- `%{staff.name}` - Nombre del agente
- `%{system.name}` - Nombre del sistema
- `%{date}` - Fecha actual
- `%{time}` - Hora actual

### Ejemplo de Plantilla

```
¡Hola %{user.name}! 

Tu ticket #%{ticket.number} ha sido creado exitosamente.

 Asunto: %{ticket.subject}
 Fecha: %{ticket.created}

Te mantendremos informado sobre el progreso.
¡Gracias por contactarnos!
```

## 🔒 Seguridad

### Validación de Webhooks

- Verificación de signature HMAC-SHA256
- Validación de origen de requests
- Rate limiting por IP y número de teléfono

### Protección de Datos

- Encriptación de números telefónicos en BD
- Sanitización de inputs
- Prevención de inyección SQL
- Logs seguros sin datos sensibles

### Permisos

- Integración con sistema de permisos diferenciados
- Respeto a PERM_RESOLVE y PERM_CLOSE
- Validación de permisos en cada acción

## 📊 Monitoreo y Logs

### Logs del Sistema

```bash
# Ver logs del plugin
tail -f include/plugins/whatsapp/logs/webhook.log

# Ver logs de osTicket
tail -f /var/log/osticket/system.log | grep WhatsApp
```

### Estadísticas Disponibles

- Total de mensajes enviados/recibidos
- Tickets creados por WhatsApp
- Usuarios activos por WhatsApp
- Tiempo de respuesta promedio

## 🛠️ Desarrollo y Testing

### Ejecutar Pruebas

```bash
cd include/plugins/whatsapp/tests/
php WhatsAppPluginTest.php
```

### Estructura del Código

```
whatsapp/
├── plugin.php                    # Controlador principal
├── config.php                    # Configuración del plugin
├── class.waapi.php               # SDK WaAPI.app
├── class.whatsapp-handler.php    # Procesador de mensajes
├── class.whatsapp-templates.php  # Sistema de plantillas
├── webhook.php                   # Receptor webhooks
├── install.php                   # Instalador
├── run_migrations.php            # Ejecutor de migraciones
├── migrations/                   # Scripts BD
├── templates/                    # Interfaces
├── assets/                       # CSS/JS/Imágenes
└── tests/                        # Pruebas unitarias
```

### API Interna

```php
// Enviar mensaje WhatsApp
$handler = new WhatsAppHandler($config, $waapi);
$handler->sendWhatsAppMessage($phone, $message, $ticket);

// Procesar plantilla
$template_manager = new WhatsAppTemplateManager($config);
$message = $template_manager->processTemplate($template, $variables);

// Validar número
$waapi = new WaAPIIntegration($config);
$is_valid = $waapi->isValidWhatsAppNumber($phone);
```

## 🔧 Troubleshooting

### Problemas Comunes

**1. Webhook no recibe mensajes**
```bash
# Verificar URL webhook
curl -X POST https://tu-osticket.com/include/plugins/whatsapp/webhook.php?health

# Verificar logs
tail -f include/plugins/whatsapp/logs/webhook.log
```

**2. Mensajes no se envían**
```bash
# Probar conexión WaAPI
php -r "
require 'class.waapi.php';
$waapi = new WaAPIIntegration(\$config);
var_dump(\$waapi->testConnection());
"
```

**3. Permisos de archivos**
```bash
# Configurar permisos
chmod 755 include/plugins/whatsapp/
chmod 644 include/plugins/whatsapp/*.php
chmod 755 include/plugins/whatsapp/logs/
```

### Logs de Debug

Habilitar modo debug en configuración del plugin para logs detallados.

## 🏗️ Arquitectura del Plugin

### Componentes Principales

1. **WhatsAppPlugin** - Controlador principal y manejo de hooks
2. **WhatsAppHandler** - Procesamiento de mensajes y lógica de negocio
3. **WaAPIIntegration** - SDK para comunicación con WaAPI.app
4. **WhatsAppTemplateManager** - Sistema de plantillas y formateo
5. **WhatsAppLogger** - Sistema de logging personalizado

### Flujo de Datos

```
Cliente WhatsApp → WaAPI.app → Webhook → WhatsAppHandler → osTicket
osTicket → WhatsAppHandler → WaAPI.app → Cliente WhatsApp
```

### Integración con osTicket

- **Hooks utilizados**: ticket.created, threadentry.created, ticket.status.changed
- **Eventos personalizados**: whatsapp.message.received, whatsapp.message.sent
- **Compatibilidad**: Sistema de permisos diferenciados (PERM_RESOLVE/PERM_CLOSE)

## 📞 Soporte

- **Desarrollador**: quintana1308
- **Email**: andres.leguizamon@sistemasadn.com
- **GitHub**: https://github.com/quintana1308/osticket-whatsapp-plugin
- **Documentación**: https://github.com/quintana1308/osticket-whatsapp-plugin/wiki

## 📄 Licencia

Este plugin está licenciado bajo MIT License. Ver archivo `LICENSE` para más detalles.

## 🤝 Contribuir

1. Fork del repositorio
2. Crear branch para feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push al branch (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📝 Changelog

### v1.0.0 (Enero 2026)
- Lanzamiento inicial
- Integración completa con WaAPI.app
- Sistema de plantillas avanzado
- Compatibilidad con permisos diferenciados
- Interfaz de administración completa
- Pruebas unitarias y de integración
- Documentación técnica completa

---
