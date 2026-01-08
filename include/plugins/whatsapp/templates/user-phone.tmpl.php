<?php
/**
 * Template Campos WhatsApp Usuario - Plugin WhatsApp
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

if (!defined('OSTSCPINC') && !defined('OSTCLIENTINC')) die('Access Denied');
?>

<div class="whatsapp-user-section">
    <h4><i class="icon-whatsapp"></i> Información WhatsApp</h4>
    
    <div class="whatsapp-user-field">
        <label for="whatsapp_phone">Número WhatsApp:</label>
        <input type="text" 
               name="whatsapp_phone" 
               id="whatsapp_phone"
               value="<?= Format::htmlchars($user->whatsapp_phone ?: '') ?>"
               placeholder="+54 9 11 1234-5678"
               class="form-control">
        
        <?php if ($user->whatsapp_phone): ?>
            <span class="verification-status <?= $user->whatsapp_verified ? 'verified' : 'unverified' ?>">
                <?= $user->whatsapp_verified ? 'Verificado' : 'No verificado' ?>
            </span>
        <?php endif; ?>
        
        <div class="help-text">
            Número de WhatsApp para recibir notificaciones y comunicación directa
        </div>
    </div>
    
    <div class="whatsapp-user-field">
        <label>
            <input type="checkbox" 
                   name="whatsapp_opt_in" 
                   value="1" 
                   <?= $user->whatsapp_opt_in ? 'checked' : '' ?>>
            Acepto recibir mensajes por WhatsApp
        </label>
        <div class="help-text">
            Autorización para enviar notificaciones y respuestas por WhatsApp
        </div>
    </div>
    
    <?php if ($user->whatsapp_phone && $show_stats): ?>
        <div class="whatsapp-user-stats">
            <h5>Estadísticas WhatsApp</h5>
            <div class="stats-grid">
                <div class="stat-item">
                    <span class="stat-value"><?= $whatsapp_stats['message_count'] ?: 0 ?></span>
                    <span class="stat-label">Mensajes</span>
                </div>
                <div class="stat-item">
                    <span class="stat-value"><?= $whatsapp_stats['ticket_count'] ?: 0 ?></span>
                    <span class="stat-label">Tickets</span>
                </div>
                <div class="stat-item">
                    <span class="stat-value">
                        <?= $whatsapp_stats['last_contact'] ? 
                            Format::relativeTime($whatsapp_stats['last_contact']) : 'Nunca' ?>
                    </span>
                    <span class="stat-label">Último contacto</span>
                </div>
            </div>
        </div>
    <?php endif; ?>
</div>

<script>
$(document).ready(function() {
    // Validación en tiempo real del número WhatsApp
    $('#whatsapp_phone').on('input blur', function() {
        var phone = $(this).val();
        var $field = $(this).closest('.whatsapp-user-field');
        
        // Remover mensajes previos
        $field.find('.validation-message').remove();
        
        if (phone) {
            // Formatear número automáticamente
            phone = phone.replace(/[^\d+]/g, '');
            if (phone && !phone.startsWith('+')) {
                phone = '+' + phone;
            }
            $(this).val(phone);
            
            // Validar formato
            var phoneRegex = /^\+[1-9]\d{1,14}$/;
            if (phoneRegex.test(phone)) {
                $(this).removeClass('error').addClass('valid');
                $field.append('<div class="validation-message success">✓ Formato válido</div>');
            } else {
                $(this).removeClass('valid').addClass('error');
                $field.append('<div class="validation-message error">❌ Formato inválido. Use formato internacional: +54911234567</div>');
            }
        } else {
            $(this).removeClass('valid error');
        }
    });
    
    // Verificar número WhatsApp
    $('#whatsapp_phone').on('blur', function() {
        var phone = $(this).val();
        if (phone && $(this).hasClass('valid')) {
            verifyWhatsAppNumber(phone);
        }
    });
});

function verifyWhatsAppNumber(phone) {
    $.post('ajax.php/whatsapp/verify-number', {
        phone: phone
    })
    .done(function(response) {
        var $field = $('#whatsapp_phone').closest('.whatsapp-user-field');
        $field.find('.verification-result').remove();
        
        if (response.success) {
            if (response.exists) {
                $field.append('<div class="verification-result success">✓ Número WhatsApp válido</div>');
            } else {
                $field.append('<div class="verification-result warning">⚠️ Número no encontrado en WhatsApp</div>');
            }
        }
    })
    .fail(function() {
        // Silencioso en caso de error de verificación
    });
}
</script>

<style>
.whatsapp-user-section {
    background: #f8f9fa;
    border: 1px solid #25D366;
    border-radius: 6px;
    padding: 20px;
    margin: 15px 0;
}

.whatsapp-user-section h4 {
    margin-top: 0;
    color: #25D366;
    border-bottom: 2px solid #25D366;
    padding-bottom: 8px;
}

.whatsapp-user-field {
    margin-bottom: 15px;
}

.whatsapp-user-field label {
    display: block;
    font-weight: bold;
    margin-bottom: 5px;
    color: #333;
}

.whatsapp-user-field input[type="text"] {
    width: 100%;
    max-width: 300px;
    padding: 8px 12px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 14px;
}

.whatsapp-user-field input[type="text"].valid {
    border-color: #28a745;
    background-color: #f8fff8;
}

.whatsapp-user-field input[type="text"].error {
    border-color: #dc3545;
    background-color: #fff8f8;
}

.verification-status {
    display: inline-block;
    margin-left: 10px;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 11px;
    color: white;
}

.verification-status.verified {
    background: #28a745;
}

.verification-status.unverified {
    background: #ffc107;
    color: #333;
}

.help-text {
    font-size: 12px;
    color: #666;
    margin-top: 5px;
    font-style: italic;
}

.validation-message {
    font-size: 12px;
    margin-top: 5px;
    padding: 4px 8px;
    border-radius: 3px;
}

.validation-message.success {
    background: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
}

.validation-message.error {
    background: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
}

.validation-message.warning {
    background: #fff3cd;
    color: #856404;
    border: 1px solid #ffeaa7;
}

.whatsapp-user-stats {
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid #ddd;
}

.whatsapp-user-stats h5 {
    margin: 0 0 10px 0;
    color: #333;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 15px;
}

.stat-item {
    text-align: center;
    background: white;
    padding: 10px;
    border-radius: 4px;
    border: 1px solid #eee;
}

.stat-value {
    display: block;
    font-size: 18px;
    font-weight: bold;
    color: #25D366;
}

.stat-label {
    display: block;
    font-size: 12px;
    color: #666;
    margin-top: 2px;
}

@media (max-width: 768px) {
    .stats-grid {
        grid-template-columns: 1fr;
    }
    
    .whatsapp-user-field input[type="text"] {
        max-width: 100%;
    }
}
</style>
