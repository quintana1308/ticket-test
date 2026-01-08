<?php
/**
 * Template Vista de Ticket con WhatsApp - Plugin WhatsApp
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

if (!defined('OSTSCPINC')) die('Access Denied');
?>

<?php if ($ticket->whatsapp_enabled): ?>
<div class="whatsapp-ticket-info">
    <div class="whatsapp-info">
        <i class="icon-whatsapp"></i>
        <strong>WhatsApp:</strong> 
        <?= Format::htmlchars($ticket->whatsapp_phone) ?>
        
        <span class="whatsapp-status <?= $ticket->whatsapp_last_message ? 'active' : 'inactive' ?>">
            <?= $ticket->whatsapp_last_message ? 'Activo' : 'Inactivo' ?>
        </span>
        
        <?php if ($ticket->whatsapp_last_message): ?>
            <span class="last-message-time">
                Último mensaje: <?= Format::datetime($ticket->whatsapp_last_message) ?>
            </span>
        <?php endif; ?>
    </div>
    
    <!-- Botones de acción WhatsApp -->
    <div class="whatsapp-actions">
        <?php if ($ticket->communication_channel !== 'whatsapp'): ?>
            <button type="button" class="btn btn-sm btn-whatsapp" onclick="enableWhatsApp(<?= $ticket->getId() ?>)">
                Habilitar WhatsApp
            </button>
        <?php else: ?>
            <button type="button" class="btn btn-sm btn-secondary" onclick="disableWhatsApp(<?= $ticket->getId() ?>)">
                Deshabilitar WhatsApp
            </button>
        <?php endif; ?>
        
        <button type="button" class="btn btn-sm btn-info" onclick="showWhatsAppHistory(<?= $ticket->getId() ?>)">
            Ver Historial
        </button>
    </div>
</div>

<!-- Historial de mensajes WhatsApp -->
<?php if (!empty($whatsapp_messages)): ?>
<div class="whatsapp-message-history">
    <h4>Historial de Mensajes WhatsApp</h4>
    
    <div class="whatsapp-messages-container">
        <?php foreach ($whatsapp_messages as $message): ?>
            <div class="whatsapp-message <?= $message['direction'] ?>" data-message-id="<?= $message['waapi_message_id'] ?>">
                <div class="message-header">
                    <span class="message-direction">
                        <?= $message['direction'] === 'incoming' ? 'Recibido' : 'Enviado' ?>
                    </span>
                    <span class="message-time">
                        <?= Format::datetime($message['created']) ?>
                    </span>
                    
                    <?php if ($message['direction'] === 'outgoing'): ?>
                        <span class="whatsapp-message-status <?= $message['status'] ?>">
                            <span class="status-icon"></span>
                            <?= ucfirst($message['status']) ?>
                        </span>
                    <?php endif; ?>
                </div>
                
                <div class="message-content">
                    <?php if ($message['message_type'] === 'text'): ?>
                        <?= Format::htmlchars($message['message_content']) ?>
                    <?php else: ?>
                        <div class="media-message">
                            <i class="icon-<?= $message['message_type'] ?>"></i>
                            <?= ucfirst($message['message_type']) ?>: <?= Format::htmlchars($message['media_filename']) ?>
                            
                            <?php if ($message['media_url']): ?>
                                <a href="<?= $message['media_url'] ?>" target="_blank" class="btn btn-xs btn-secondary">
                                    Ver archivo
                                </a>
                            <?php endif; ?>
                        </div>
                    <?php endif; ?>
                </div>
                
                <?php if ($message['error_message']): ?>
                    <div class="message-error">
                        <i class="icon-warning"></i>
                        Error: <?= Format::htmlchars($message['error_message']) ?>
                    </div>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>
    </div>
</div>
<?php endif; ?>

<script>
function enableWhatsApp(ticketId) {
    if (confirm('¿Habilitar comunicación por WhatsApp para este ticket?')) {
        $.post('ajax.php/whatsapp/enable-ticket', {
            ticket_id: ticketId
        })
        .done(function(response) {
            if (response.success) {
                location.reload();
            } else {
                alert('Error: ' + response.message);
            }
        })
        .fail(function() {
            alert('Error de conexión');
        });
    }
}

function disableWhatsApp(ticketId) {
    if (confirm('¿Deshabilitar comunicación por WhatsApp para este ticket?')) {
        $.post('ajax.php/whatsapp/disable-ticket', {
            ticket_id: ticketId
        })
        .done(function(response) {
            if (response.success) {
                location.reload();
            } else {
                alert('Error: ' + response.message);
            }
        })
        .fail(function() {
            alert('Error de conexión');
        });
    }
}

function showWhatsAppHistory(ticketId) {
    $.get('ajax.php/whatsapp/message-history/' + ticketId)
        .done(function(data) {
            WhatsAppPlugin.showModal('Historial Completo WhatsApp', data);
        })
        .fail(function() {
            alert('Error cargando historial');
        });
}
</script>

<style>
.whatsapp-ticket-info {
    background: #f8f9fa;
    border: 1px solid #25D366;
    border-radius: 6px;
    padding: 15px;
    margin: 15px 0;
}

.whatsapp-actions {
    margin-top: 10px;
}

.whatsapp-actions .btn {
    margin-right: 8px;
}

.whatsapp-message-history {
    margin-top: 20px;
    border: 1px solid #ddd;
    border-radius: 6px;
    padding: 15px;
}

.whatsapp-messages-container {
    max-height: 400px;
    overflow-y: auto;
    border: 1px solid #eee;
    border-radius: 4px;
    padding: 10px;
}

.whatsapp-message {
    margin-bottom: 15px;
    padding: 10px;
    border-radius: 6px;
    border-left: 4px solid;
}

.whatsapp-message.incoming {
    background: #e3f2fd;
    border-left-color: #2196f3;
}

.whatsapp-message.outgoing {
    background: #f1f8e9;
    border-left-color: #25D366;
}

.message-header {
    font-size: 12px;
    color: #666;
    margin-bottom: 8px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.message-direction {
    font-weight: bold;
}

.message-content {
    font-size: 14px;
    line-height: 1.4;
    white-space: pre-wrap;
}

.media-message {
    display: flex;
    align-items: center;
    gap: 8px;
}

.message-error {
    background: #ffebee;
    color: #c62828;
    padding: 5px 8px;
    border-radius: 3px;
    margin-top: 5px;
    font-size: 12px;
}

.last-message-time {
    font-size: 11px;
    color: #888;
    margin-left: 10px;
}
</style>
<?php endif; ?>
