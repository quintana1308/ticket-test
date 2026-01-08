# 📱 Plan de Desarrollo - Plugin WhatsApp para osTicket

## 📋 Información del Proyecto

**Proyecto:** Plugin WhatsApp para osTicket  
**Objetivo:** Integrar WhatsApp como canal de comunicación principal reemplazando email  
**Servicio:** WaAPI.app (https://waapi.app/)  
**Arquitectura:** Plugin independiente no invasivo  
**Compatibilidad:** osTicket v1.18.2 + Sistema de permisos diferenciados (commit 3fa9383)

## 🎯 Objetivos Principales

1. **Comunicación Bidireccional**: Clientes crean tickets y reciben respuestas por WhatsApp
2. **Integración No Invasiva**: Plugin que sobrevive actualizaciones de osTicket
3. **Compatibilidad Total**: Funciona con sistema de permisos diferenciados existente
4. **Experiencia Unificada**: WhatsApp como canal principal, sin dependencia de email

---

## 🚀 FASE 1: PREPARACIÓN E INFRAESTRUCTURA
**Duración:** 3-5 días  
**Prioridad:** Crítica

### 1.1 Configuración del Entorno
- [ ] **Entorno de Desarrollo**
  - Clonar instalación osTicket actual
  - Configurar base de datos de desarrollo
  - Verificar funcionamiento del sistema de permisos diferenciados
  - Configurar herramientas de debugging PHP

- [ ] **Configuración WaAPI.app**
  - Verificar acceso a instancia WaAPI.app
  - Obtener tokens de API y configuraciones
  - Probar endpoints básicos de WaAPI
  - Configurar webhook URL de prueba
  - Documentar límites y restricciones de la API

- [ ] **Análisis de Integración osTicket**
  - Estudiar sistema de plugins de osTicket
  - Mapear hooks y eventos disponibles
  - Identificar puntos de integración no invasivos
  - Documentar estructura de base de datos actual

### 1.2 Diseño de Arquitectura
- [ ] **Estructura del Plugin**
  ```
  include/plugins/whatsapp/
  ├── plugin.php                    # Controlador principal
  ├── config.php                    # Configuración del plugin
  ├── class.waapi.php               # SDK WaAPI.app
  ├── class.whatsapp-handler.php    # Procesador de mensajes
  ├── webhook.php                   # Receptor webhooks
  ├── install.php                   # Instalador
  ├── migrations/                   # Scripts BD
  ├── templates/                    # Interfaces
  └── assets/                       # CSS/JS/Imágenes
  ```

- [ ] **Diseño de Base de Datos**
  - Tablas para configuración WhatsApp
  - Asociación usuarios-números telefónicos
  - Log de mensajes y estados
  - Integración con tablas existentes de osTicket

### 1.3 Documentación Técnica Inicial
- [ ] Especificaciones de API WaAPI.app
- [ ] Mapeo de eventos osTicket
- [ ] Diagrama de flujo de datos
- [ ] Plan de migraciones de BD

---

## 🔧 FASE 2: DESARROLLO DEL NÚCLEO DEL PLUGIN
**Duración:** 7-10 días  
**Prioridad:** Alta

### 2.1 Estructura Base del Plugin
- [ ] **Archivo Principal (plugin.php)**
  ```php
  class WhatsAppPlugin extends Plugin {
      var $config_class = 'WhatsAppPluginConfig';
      
      function bootstrap() {
          // Registrar hooks de osTicket
          Signal::connect('ticket.created', array($this, 'onTicketCreated'));
          Signal::connect('threadentry.created', array($this, 'onReplyCreated'));
          Signal::connect('user.created', array($this, 'onUserCreated'));
      }
  }
  ```

- [ ] **Configuración del Plugin (config.php)**
  - Clase WhatsAppPluginConfig extends PluginConfig
  - Campos de configuración (API tokens, números, etc.)
  - Validaciones de configuración
  - Interfaz de administración

- [ ] **Integración WaAPI (class.waapi.php)**
  ```php
  class WaAPIIntegration {
      private $api_url = 'https://waapi.app/api/v1/';
      private $token;
      
      public function sendMessage($phone, $message, $attachments = [])
      public function processWebhook($data)
      public function validateWebhook($signature, $payload)
      public function getMessageStatus($messageId)
  }
  ```

### 2.2 Sistema de Hooks No Invasivo
- [ ] **Eventos de Tickets**
  - `ticket.created` → Notificar creación por WhatsApp
  - `threadentry.created` → Enviar respuestas por WhatsApp
  - `ticket.assigned` → Notificar asignación
  - `ticket.status.changed` → Notificar cambios de estado

- [ ] **Eventos de Usuario**
  - `user.created` → Asociar número WhatsApp
  - `user.updated` → Actualizar datos WhatsApp

- [ ] **Integración con Permisos Diferenciados**
  - Respetar PERM_RESOLVE vs PERM_CLOSE
  - Notificaciones según rol del agente
  - Restricciones para analistas en tickets resueltos

### 2.3 Manejador de Mensajes
- [ ] **Clase WhatsAppHandler (class.whatsapp-handler.php)**
  ```php
  class WhatsAppHandler {
      public function processIncomingMessage($data)
      public function createTicketFromWhatsApp($phone, $message, $attachments)
      public function updateTicketFromWhatsApp($ticketId, $message)
      public function associateUserWithPhone($userId, $phone)
      public function validatePhoneNumber($phone)
  }
  ```

---

## 📨 FASE 3: RECEPCIÓN DE MENSAJES WHATSAPP
**Duración:** 5-7 días  
**Prioridad:** Alta

### 3.1 Webhook Endpoint
- [ ] **Archivo webhook.php**
  - Validación de seguridad (tokens, signatures)
  - Rate limiting para prevenir spam
  - Logging de todas las interacciones
  - Manejo de errores y excepciones

- [ ] **Procesamiento de Mensajes Entrantes**
  ```php
  // Flujo de procesamiento
  1. Validar webhook de WaAPI.app
  2. Extraer datos del mensaje (teléfono, contenido, adjuntos)
  3. Identificar usuario existente o crear nuevo
  4. Determinar si es ticket nuevo o respuesta a existente
  5. Crear/actualizar ticket en osTicket
  6. Enviar confirmación por WhatsApp
  ```

### 3.2 Gestión de Usuarios y Números
- [ ] **Asociación Automática**
  - Buscar usuario existente por número de teléfono
  - Crear usuario automáticamente si no existe
  - Validar formato de números internacionales
  - Manejo de números duplicados

- [ ] **Base de Datos**
  ```sql
  CREATE TABLE ost_whatsapp_users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT,
      phone_number VARCHAR(20) ENCRYPTED,
      verified BOOLEAN DEFAULT FALSE,
      first_message_date DATETIME,
      last_message_date DATETIME,
      created DATETIME,
      FOREIGN KEY (user_id) REFERENCES ost_user(id)
  );
  ```

### 3.3 Creación de Tickets desde WhatsApp
- [ ] **Lógica de Creación**
  - Usar API interna de osTicket (TicketApiController)
  - Asignar departamento por defecto o por reglas
  - Establecer prioridad automática
  - Marcar origen como "WhatsApp"
  - Asociar con usuario identificado

- [ ] **Manejo de Adjuntos**
  - Descargar archivos desde WaAPI.app
  - Validar tipos de archivo permitidos
  - Almacenar en sistema de archivos de osTicket
  - Asociar con ticket creado

---

## 📤 FASE 4: ENVÍO DE RESPUESTAS POR WHATSAPP
**Duración:** 5-7 días  
**Prioridad:** Alta

### 4.1 Interceptación de Respuestas
- [ ] **Hook en Creación de Respuestas**
  ```php
  Signal::connect('threadentry.created', function($entry) {
      if ($entry->getThread()->getObjectType() == 'T') { // Ticket
          $ticket = $entry->getThread()->getObject();
          $whatsapp = new WhatsAppHandler();
          $whatsapp->sendReplyToWhatsApp($ticket, $entry);
      }
  });
  ```

- [ ] **Validaciones de Envío**
  - Verificar que el ticket tiene número WhatsApp asociado
  - Respetar configuración de canal de comunicación
  - Validar permisos del agente (PERM_RESOLVE/PERM_CLOSE)
  - Evitar loops de mensajes automáticos

### 4.2 Formateo de Mensajes
- [ ] **Plantillas de Mensajes**
  ```php
  // Plantillas configurables
  - Confirmación de ticket creado
  - Respuesta de agente
  - Cambio de estado
  - Cierre de ticket
  - Mensaje de bienvenida
  ```

- [ ] **Conversión de Contenido**
  - HTML a texto plano para WhatsApp
  - Manejo de emojis y caracteres especiales
  - Límites de longitud de mensaje
  - División de mensajes largos

### 4.3 Manejo de Estados y Notificaciones
- [ ] **Estados de Mensaje**
  - Enviado, Entregado, Leído, Fallido
  - Almacenamiento en base de datos
  - Reintento automático en caso de fallo
  - Notificación a agentes sobre estado

- [ ] **Integración con Sistema de Permisos**
  - Analistas: Solo pueden resolver (PERM_RESOLVE)
  - Supervisores: Pueden resolver y cerrar (PERM_CLOSE)
  - Restricción: Analistas no modifican tickets ya resueltos

---

## 🎨 FASE 5: INTERFAZ DE USUARIO Y CONFIGURACIÓN
**Duración:** 4-6 días  
**Prioridad:** Media

### 5.1 Panel de Configuración del Plugin
- [ ] **Interfaz de Administración**
  ```php
  // Campos de configuración
  - Token API WaAPI.app
  - URL del webhook
  - Número de WhatsApp Business
  - Departamento por defecto
  - Plantillas de mensajes
  - Configuraciones de seguridad
  ```

- [ ] **Validaciones en Tiempo Real**
  - Probar conexión con WaAPI.app
  - Validar formato de números
  - Verificar webhook URL accesible
  - Test de envío de mensaje

### 5.2 Modificaciones en Interfaz de Tickets
- [ ] **Vista de Ticket**
  - Mostrar número de WhatsApp del cliente
  - Indicador de canal de comunicación (WhatsApp/Email)
  - Estado de último mensaje WhatsApp
  - Botón para cambiar a comunicación WhatsApp

- [ ] **Lista de Tickets**
  - Icono identificador de tickets WhatsApp
  - Columna de canal de comunicación
  - Filtro por canal (WhatsApp/Email/Todos)

### 5.3 Templates y Assets
- [ ] **Plantillas PHP**
  ```
  templates/
  ├── config.tmpl.php          # Configuración del plugin
  ├── ticket-whatsapp.tmpl.php # Vista de ticket con WhatsApp
  ├── message-status.tmpl.php  # Estado de mensajes
  └── user-phone.tmpl.php      # Asociación usuario-teléfono
  ```

- [ ] **Recursos Frontend**
  ```
  assets/
  ├── css/whatsapp.css         # Estilos del plugin
  ├── js/whatsapp.js           # JavaScript del plugin
  └── images/
      ├── whatsapp-icon.png    # Icono WhatsApp
      ├── status-sent.png      # Estados de mensaje
      └── status-delivered.png
  ```

---

## 🗄️ FASE 6: MIGRACIONES Y BASE DE DATOS
**Duración:** 2-3 días  
**Prioridad:** Media

### 6.1 Scripts de Migración
- [ ] **001_create_whatsapp_tables.sql**
  ```sql
  -- Tabla de configuración del plugin
  CREATE TABLE ost_whatsapp_config (
      id INT AUTO_INCREMENT PRIMARY KEY,
      api_token VARCHAR(255) ENCRYPTED,
      webhook_url VARCHAR(255),
      business_phone VARCHAR(20),
      default_dept_id INT,
      created DATETIME,
      updated DATETIME
  );

  -- Tabla de usuarios WhatsApp
  CREATE TABLE ost_whatsapp_users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT,
      phone_number VARCHAR(20) ENCRYPTED,
      verified BOOLEAN DEFAULT FALSE,
      first_contact DATETIME,
      last_contact DATETIME,
      message_count INT DEFAULT 0,
      created DATETIME,
      FOREIGN KEY (user_id) REFERENCES ost_user(id)
  );

  -- Tabla de mensajes WhatsApp
  CREATE TABLE ost_whatsapp_messages (
      id INT AUTO_INCREMENT PRIMARY KEY,
      ticket_id INT,
      thread_entry_id INT,
      phone_number VARCHAR(20),
      direction ENUM('incoming', 'outgoing'),
      message_content TEXT,
      message_type ENUM('text', 'image', 'document', 'audio'),
      waapi_message_id VARCHAR(100),
      status ENUM('sent', 'delivered', 'read', 'failed'),
      error_message TEXT,
      created DATETIME,
      delivered_at DATETIME,
      read_at DATETIME,
      FOREIGN KEY (ticket_id) REFERENCES ost_ticket(ticket_id),
      FOREIGN KEY (thread_entry_id) REFERENCES ost_thread_entry(id)
  );
  ```

- [ ] **002_add_whatsapp_fields.sql**
  ```sql
  -- Agregar campos a tabla de tickets
  ALTER TABLE ost_ticket 
  ADD COLUMN whatsapp_phone VARCHAR(20),
  ADD COLUMN communication_channel ENUM('email', 'whatsapp', 'hybrid') DEFAULT 'email',
  ADD COLUMN whatsapp_enabled BOOLEAN DEFAULT FALSE;

  -- Agregar índices para optimización
  CREATE INDEX idx_whatsapp_phone ON ost_ticket(whatsapp_phone);
  CREATE INDEX idx_communication_channel ON ost_ticket(communication_channel);
  CREATE INDEX idx_waapi_message_id ON ost_whatsapp_messages(waapi_message_id);
  ```

### 6.2 Sistema de Instalación/Desinstalación
- [ ] **install.php**
  ```php
  class WhatsAppInstaller {
      public function install() {
          // Ejecutar migraciones
          // Crear configuración por defecto
          // Registrar plugin en sistema
          // Verificar dependencias
      }
      
      public function checkRequirements() {
          // PHP >= 7.4
          // cURL extension
          // OpenSSL extension
          // Permisos de escritura
      }
  }
  ```

- [ ] **uninstall.php**
  ```php
  class WhatsAppUninstaller {
      public function uninstall($keep_data = true) {
          // Desactivar hooks
          // Eliminar configuración (opcional)
          // Mantener datos de mensajes (opcional)
          // Limpiar archivos temporales
      }
  }
  ```

---

## 🧪 FASE 7: PRUEBAS Y VALIDACIÓN
**Duración:** 5-7 días  
**Prioridad:** Alta

### 7.1 Pruebas Unitarias
- [ ] **Clases del Plugin**
  ```php
  // Tests para cada clase
  - WhatsAppPluginTest.php
  - WaAPIIntegrationTest.php
  - WhatsAppHandlerTest.php
  - WebhookTest.php
  ```

- [ ] **Casos de Prueba**
  - Envío de mensajes exitoso
  - Manejo de errores de API
  - Validación de números de teléfono
  - Creación de tickets desde WhatsApp
  - Asociación usuario-teléfono

### 7.2 Pruebas de Integración
- [ ] **Flujos Completos**
  - Cliente envía mensaje → Ticket creado → Agente responde → Cliente recibe
  - Múltiples mensajes del mismo cliente → Actualización de ticket existente
  - Archivos adjuntos → Descarga y almacenamiento correcto
  - Cambios de estado → Notificaciones automáticas

- [ ] **Compatibilidad con Permisos Diferenciados**
  - Analista resuelve ticket → Notificación WhatsApp
  - Analista intenta cerrar → Restricción aplicada
  - Supervisor cierra ticket → Proceso completo
  - Analista no puede modificar ticket resuelto

### 7.3 Pruebas de Seguridad
- [ ] **Validaciones de Seguridad**
  - Webhook signature validation
  - Rate limiting efectivo
  - Sanitización de inputs
  - Prevención de inyección SQL
  - Encriptación de números telefónicos

### 7.4 Pruebas de Rendimiento
- [ ] **Carga y Volumen**
  - 100 mensajes simultáneos
  - Manejo de archivos grandes
  - Respuesta bajo carga
  - Memoria y CPU usage

---

## 📚 FASE 8: DOCUMENTACIÓN Y CAPACITACIÓN
**Duración:** 3-4 días  
**Prioridad:** Media

### 8.1 Documentación Técnica
- [ ] **README.md del Plugin**
  - Descripción y características
  - Requisitos del sistema
  - Instrucciones de instalación
  - Configuración paso a paso
  - Troubleshooting común

- [ ] **Documentación de API**
  - Métodos públicos del plugin
  - Hooks disponibles
  - Eventos personalizados
  - Ejemplos de uso

### 8.2 Guías de Usuario
- [ ] **Manual de Administrador**
  - Configuración inicial
  - Gestión de plantillas de mensajes
  - Monitoreo y logs
  - Mantenimiento del plugin

- [ ] **Manual de Agente**
  - Uso de WhatsApp en tickets
  - Diferencias con email
  - Mejores prácticas
  - Resolución de problemas

### 8.3 Documentación de Mantenimiento
- [ ] **Guía de Actualizaciones**
  - Proceso de actualización del plugin
  - Compatibilidad con nuevas versiones osTicket
  - Backup y restauración
  - Migración de datos

---

## 🚀 FASE 9: DESPLIEGUE Y PUESTA EN PRODUCCIÓN
**Duración:** 2-3 días  
**Prioridad:** Crítica

### 9.1 Preparación del Entorno de Producción
- [ ] **Configuración del Servidor**
  - Verificar requisitos PHP y extensiones
  - Configurar SSL para webhooks
  - Establecer permisos de archivos
  - Configurar logs y monitoreo

- [ ] **Configuración WaAPI.app Producción**
  - Migrar de instancia de prueba a producción
  - Configurar webhook URL definitiva
  - Validar límites y quotas
  - Establecer monitoreo de API

### 9.2 Instalación del Plugin
- [ ] **Proceso de Instalación**
  ```bash
  # Pasos de instalación
  1. Backup completo de osTicket
  2. Subir archivos del plugin
  3. Ejecutar install.php
  4. Configurar plugin en admin panel
  5. Probar funcionalidad básica
  6. Activar para usuarios piloto
  ```

- [ ] **Validación Post-Instalación**
  - Verificar todas las migraciones aplicadas
  - Probar webhook endpoint
  - Enviar mensaje de prueba
  - Verificar logs sin errores

### 9.3 Migración Gradual
- [ ] **Plan de Migración**
  - Fase 1: Usuarios piloto (5-10 usuarios)
  - Fase 2: Departamento específico
  - Fase 3: Todos los usuarios nuevos
  - Fase 4: Migración completa

- [ ] **Monitoreo Inicial**
  - Logs de errores en tiempo real
  - Métricas de rendimiento
  - Feedback de usuarios
  - Ajustes necesarios

---

## 📊 CRONOGRAMA DE IMPLEMENTACIÓN

### **Semana 1: Preparación**
- Días 1-2: Configuración entorno y WaAPI.app
- Días 3-5: Análisis y diseño de arquitectura

### **Semana 2-3: Desarrollo Núcleo**
- Días 6-10: Estructura base del plugin
- Días 11-15: Sistema de hooks y manejadores

### **Semana 4: Recepción de Mensajes**
- Días 16-20: Webhook y procesamiento entrante

### **Semana 5: Envío de Respuestas**
- Días 21-25: Interceptación y envío por WhatsApp

### **Semana 6: Interfaz y BD**
- Días 26-28: Interfaz de usuario
- Días 29-30: Migraciones de base de datos

### **Semana 7: Pruebas**
- Días 31-35: Pruebas completas y validación

### **Semana 8: Documentación y Despliegue**
- Días 36-38: Documentación
- Días 39-40: Despliegue y puesta en producción

---

## ⚠️ CONSIDERACIONES CRÍTICAS

### **Seguridad**
- Encriptación de números telefónicos en BD
- Validación estricta de webhooks
- Rate limiting para prevenir spam
- Logs seguros sin datos sensibles

### **Rendimiento**
- Procesamiento asíncrono de mensajes
- Cache de configuraciones
- Optimización de consultas BD
- Manejo eficiente de archivos adjuntos

### **Compatibilidad**
- No modificar core de osTicket
- Usar solo hooks y eventos públicos
- Mantener compatibilidad con permisos diferenciados
- Preparar para futuras versiones osTicket

### **Mantenimiento**
- Sistema de logs detallado
- Monitoreo de API WaAPI.app
- Backup automático de configuraciones
- Documentación de troubleshooting

---

## 📞 CONTACTO Y SOPORTE

**Desarrollador:** quintana1308  
**Email:** andres.leguizamon@sistemasadn.com  
**Proyecto:** Plugin WhatsApp osTicket  
**Fecha:** Enero 2026

---

**⚠️ NOTA IMPORTANTE:** Este plugin está diseñado para ser completamente independiente del core de osTicket, garantizando que todas las funcionalidades WhatsApp sobrevivan a las actualizaciones del sistema principal.
