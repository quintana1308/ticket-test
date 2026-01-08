<?php
/**
 * Template de Configuración - Plugin WhatsApp
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

if (!defined('OSTADMININC')) die('Access Denied');
?>

<div class="whatsapp-config-container">
    <h2><i class="icon-whatsapp"></i> Configuración Plugin WhatsApp</h2>
    
    <?php if ($errors): ?>
        <div class="whatsapp-notification error">
            <strong>Errores de configuración:</strong>
            <ul>
                <?php foreach ($errors as $field => $error): ?>
                    <li><?= Format::htmlchars($error) ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    <?php endif; ?>
    
    <?php if ($success): ?>
        <div class="whatsapp-notification success">
            Configuración guardada correctamente.
        </div>
    <?php endif; ?>
    
    <form method="post" action="<?= $form_action ?>" id="whatsapp-config-form">
        <?= csrf_token() ?>
        
        <!-- Configuración Básica -->
        <div class="whatsapp-config-section">
            <h3>Configuración Básica</h3>
            
            <div class="whatsapp-config-field">
                <label for="enabled">
                    <input type="checkbox" name="enabled" id="enabled" value="1" 
                           <?= $config['enabled'] ? 'checked' : '' ?>>
                    Habilitar Plugin WhatsApp
                </label>
                <div class="help-text">Activar/desactivar toda la funcionalidad WhatsApp</div>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="api_token">Token API WaAPI.app *</label>
                <input type="password" name="api_token" id="api_token" 
                       value="<?= Format::htmlchars($config['api_token']) ?>" required>
                <div class="help-text">Token de autenticación de tu cuenta WaAPI.app</div>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="instance_id">Instance ID *</label>
                <input type="text" name="instance_id" id="instance_id" 
                       value="<?= Format::htmlchars($config['instance_id']) ?>" required>
                <div class="help-text">ID de tu instancia WhatsApp en WaAPI.app</div>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="webhook_secret">Webhook Secret *</label>
                <input type="password" name="webhook_secret" id="webhook_secret" 
                       value="<?= Format::htmlchars($config['webhook_secret']) ?>" required>
                <div class="help-text">Clave secreta para validar webhooks</div>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="business_phone">Número WhatsApp Business *</label>
                <input type="text" name="business_phone" id="business_phone" 
                       value="<?= Format::htmlchars($config['business_phone']) ?>" 
                       placeholder="+54 9 11 1234-5678" required>
                <div class="help-text">Número de WhatsApp Business asociado a la instancia</div>
            </div>
            
            <div class="whatsapp-config-field">
                <button type="button" class="btn-test-whatsapp">
                    Probar Conexión
                </button>
            </div>
        </div>
        
        <!-- Configuración de Tickets -->
        <div class="whatsapp-config-section">
            <h3>Configuración de Tickets</h3>
            
            <div class="whatsapp-config-field">
                <label for="default_dept_id">Departamento por Defecto</label>
                <select name="default_dept_id" id="default_dept_id">
                    <option value="">Seleccionar departamento</option>
                    <?php foreach ($departments as $dept): ?>
                        <option value="<?= $dept->getId() ?>" 
                                <?= $config['default_dept_id'] == $dept->getId() ? 'selected' : '' ?>>
                            <?= Format::htmlchars($dept->getName()) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
                <div class="help-text">Departamento donde se crearán los tickets de WhatsApp</div>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="auto_create_users">
                    <input type="checkbox" name="auto_create_users" id="auto_create_users" value="1"
                           <?= $config['auto_create_users'] ? 'checked' : '' ?>>
                    Crear usuarios automáticamente
                </label>
                <div class="help-text">Crear usuarios nuevos cuando envíen mensajes por primera vez</div>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="rate_limit">Límite de Mensajes por Minuto</label>
                <input type="number" name="rate_limit" id="rate_limit" 
                       value="<?= $config['rate_limit'] ?: 50 ?>" min="1" max="1000">
                <div class="help-text">Máximo de mensajes por minuto por número de teléfono</div>
            </div>
        </div>
        
        <!-- Configuración de Notificaciones -->
        <div class="whatsapp-config-section">
            <h3>Configuración de Notificaciones</h3>
            
            <div class="whatsapp-config-field">
                <label for="notify_ticket_created">
                    <input type="checkbox" name="notify_ticket_created" id="notify_ticket_created" value="1"
                           <?= $config['notify_ticket_created'] ? 'checked' : '' ?>>
                    Notificar creación de tickets
                </label>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="notify_ticket_assigned">
                    <input type="checkbox" name="notify_ticket_assigned" id="notify_ticket_assigned" value="1"
                           <?= $config['notify_ticket_assigned'] ? 'checked' : '' ?>>
                    Notificar asignación de tickets
                </label>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="notify_ticket_resolved">
                    <input type="checkbox" name="notify_ticket_resolved" id="notify_ticket_resolved" value="1"
                           <?= $config['notify_ticket_resolved'] ? 'checked' : '' ?>>
                    Notificar resolución de tickets
                </label>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="notify_ticket_closed">
                    <input type="checkbox" name="notify_ticket_closed" id="notify_ticket_closed" value="1"
                           <?= $config['notify_ticket_closed'] ? 'checked' : '' ?>>
                    Notificar cierre de tickets
                </label>
            </div>
        </div>
        
        <!-- Configuración Avanzada -->
        <div class="whatsapp-config-section">
            <h3>Configuración Avanzada</h3>
            
            <div class="whatsapp-config-field">
                <label for="webhook_url">URL del Webhook (Solo lectura)</label>
                <input type="text" name="webhook_url" id="webhook_url" 
                       value="<?= $webhook_url ?>" readonly>
                <div class="help-text">Configura esta URL en tu cuenta WaAPI.app</div>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="debug_mode">
                    <input type="checkbox" name="debug_mode" id="debug_mode" value="1"
                           <?= $config['debug_mode'] ? 'checked' : '' ?>>
                    Modo Debug
                </label>
                <div class="help-text">Habilitar logs detallados para depuración</div>
            </div>
            
            <div class="whatsapp-config-field">
                <label for="message_retention_days">Días de Retención de Mensajes</label>
                <input type="number" name="message_retention_days" id="message_retention_days" 
                       value="<?= $config['message_retention_days'] ?: 365 ?>" min="30" max="3650">
                <div class="help-text">Días que se mantendrán los mensajes en la base de datos</div>
            </div>
        </div>
        
        <div class="whatsapp-config-section">
            <input type="submit" value="Guardar Configuración" class="btn-whatsapp">
            <a href="<?= $cancel_url ?>" class="btn btn-secondary">Cancelar</a>
        </div>
    </form>
</div>

<!-- Estadísticas -->
<?php if ($config['enabled']): ?>
<div class="whatsapp-config-section">
    <h3>Estadísticas WhatsApp</h3>
    <div id="whatsapp-stats-container" class="whatsapp-stats-grid">
        <div class="whatsapp-stat-card whatsapp-pulse">
            <h3>...</h3>
            <p>Cargando estadísticas...</p>
        </div>
    </div>
</div>
<?php endif; ?>

<script>
$(document).ready(function() {
    // Mostrar/ocultar secciones según estado del plugin
    $('#enabled').change(function() {
        if ($(this).is(':checked')) {
            $('.whatsapp-config-section:not(:first)').show();
        } else {
            $('.whatsapp-config-section:not(:first)').hide();
        }
    }).trigger('change');
    
    // Formatear número de teléfono automáticamente
    $('#business_phone').on('input', function() {
        var value = $(this).val().replace(/[^\d+]/g, '');
        if (value && !value.startsWith('+')) {
            value = '+' + value;
        }
        $(this).val(value);
    });
});
</script>
