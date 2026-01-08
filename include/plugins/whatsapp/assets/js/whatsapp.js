/**
 * JavaScript para Plugin WhatsApp osTicket
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

(function($) {
    'use strict';
    
    // Namespace para el plugin WhatsApp
    window.WhatsAppPlugin = {
        
        // Configuración
        config: {
            apiUrl: 'include/plugins/whatsapp/',
            testEndpoint: 'test-connection.php',
            templateEndpoint: 'templates.php'
        },
        
        // Inicialización
        init: function() {
            this.bindEvents();
            this.initializeComponents();
            this.loadWhatsAppIndicators();
        },
        
        // Vincular eventos
        bindEvents: function() {
            // Botón de prueba de conexión
            $(document).on('click', '.btn-test-whatsapp', this.testConnection);
            
            // Formulario de configuración
            $(document).on('submit', '#whatsapp-config-form', this.saveConfiguration);
            
            // Validación de número de teléfono
            $(document).on('blur', 'input[name="whatsapp_phone"]', this.validatePhoneNumber);
            
            // Plantillas de mensajes
            $(document).on('click', '.btn-edit-template', this.editTemplate);
            $(document).on('click', '.btn-preview-template', this.previewTemplate);
            
            // Modal de plantillas
            $(document).on('click', '.whatsapp-modal-close', this.closeModal);
            $(document).on('click', '.whatsapp-modal', function(e) {
                if (e.target === this) {
                    WhatsAppPlugin.closeModal();
                }
            });
            
            // Cambio de canal de comunicación
            $(document).on('change', 'select[name="communication_channel"]', this.handleChannelChange);
        },
        
        // Inicializar componentes
        initializeComponents: function() {
            // Inicializar tooltips
            if ($.fn.tooltip) {
                $('[data-toggle="tooltip"]').tooltip();
            }
            
            // Cargar estadísticas si estamos en la página de configuración
            if ($('#whatsapp-stats-container').length) {
                this.loadStats();
            }
            
            // Inicializar editor de plantillas
            this.initializeTemplateEditor();
        },
        
        // Cargar indicadores WhatsApp en lista de tickets
        loadWhatsAppIndicators: function() {
            $('.ticket-list tr').each(function() {
                var $row = $(this);
                var ticketId = $row.data('ticket-id');
                
                if (ticketId) {
                    // Verificar si el ticket tiene WhatsApp habilitado
                    $.get('ajax.php/whatsapp/ticket-info/' + ticketId)
                        .done(function(data) {
                            if (data.whatsapp_enabled) {
                                $row.find('.ticket-number').prepend(
                                    '<span class="whatsapp-indicator" title="Ticket WhatsApp"></span>'
                                );
                            }
                        });
                }
            });
        },
        
        // Probar conexión con WaAPI
        testConnection: function(e) {
            e.preventDefault();
            
            var $btn = $(this);
            var originalText = $btn.text();
            
            $btn.text('Probando...').prop('disabled', true);
            
            // Obtener configuración del formulario
            var config = {
                api_token: $('input[name="api_token"]').val(),
                instance_id: $('input[name="instance_id"]').val(),
                webhook_secret: $('input[name="webhook_secret"]').val()
            };
            
            $.post(WhatsAppPlugin.config.apiUrl + WhatsAppPlugin.config.testEndpoint, config)
                .done(function(response) {
                    if (response.success) {
                        WhatsAppPlugin.showNotification('success', 'Conexión exitosa con WaAPI.app');
                        
                        // Mostrar información adicional
                        if (response.info) {
                            var info = '<ul>';
                            for (var key in response.info) {
                                info += '<li><strong>' + key + ':</strong> ' + response.info[key] + '</li>';
                            }
                            info += '</ul>';
                            
                            WhatsAppPlugin.showModal('Información de Conexión', info);
                        }
                    } else {
                        WhatsAppPlugin.showNotification('error', 'Error: ' + response.message);
                    }
                })
                .fail(function() {
                    WhatsAppPlugin.showNotification('error', 'Error de conexión al servidor');
                })
                .always(function() {
                    $btn.text(originalText).prop('disabled', false);
                });
        },
        
        // Guardar configuración
        saveConfiguration: function(e) {
            e.preventDefault();
            
            var $form = $(this);
            var $submitBtn = $form.find('input[type="submit"]');
            var originalText = $submitBtn.val();
            
            $submitBtn.val('Guardando...').prop('disabled', true);
            
            $.post($form.attr('action'), $form.serialize())
                .done(function(response) {
                    if (response.success) {
                        WhatsAppPlugin.showNotification('success', 'Configuración guardada correctamente');
                    } else {
                        WhatsAppPlugin.showNotification('error', 'Error: ' + response.message);
                    }
                })
                .fail(function() {
                    WhatsAppPlugin.showNotification('error', 'Error guardando configuración');
                })
                .always(function() {
                    $submitBtn.val(originalText).prop('disabled', false);
                });
        },
        
        // Validar número de teléfono
        validatePhoneNumber: function() {
            var $input = $(this);
            var phone = $input.val();
            
            if (!phone) return;
            
            // Expresión regular para validar números WhatsApp
            var phoneRegex = /^\+?[1-9]\d{1,14}$/;
            
            if (phoneRegex.test(phone.replace(/\s+/g, ''))) {
                $input.removeClass('error').addClass('valid');
                $input.next('.validation-message').remove();
            } else {
                $input.removeClass('valid').addClass('error');
                
                if (!$input.next('.validation-message').length) {
                    $input.after('<div class="validation-message error">Formato de número inválido</div>');
                }
            }
        },
        
        // Editar plantilla
        editTemplate: function(e) {
            e.preventDefault();
            
            var templateId = $(this).data('template-id');
            
            $.get(WhatsAppPlugin.config.apiUrl + WhatsAppPlugin.config.templateEndpoint, {
                action: 'get',
                id: templateId
            })
            .done(function(template) {
                WhatsAppPlugin.showTemplateEditor(template);
            })
            .fail(function() {
                WhatsAppPlugin.showNotification('error', 'Error cargando plantilla');
            });
        },
        
        // Previsualizar plantilla
        previewTemplate: function(e) {
            e.preventDefault();
            
            var templateId = $(this).data('template-id');
            
            $.post(WhatsAppPlugin.config.apiUrl + WhatsAppPlugin.config.templateEndpoint, {
                action: 'preview',
                id: templateId
            })
            .done(function(response) {
                if (response.success) {
                    WhatsAppPlugin.showModal('Previsualización de Plantilla', 
                        '<div class="whatsapp-template-preview">' + 
                        response.preview.replace(/\n/g, '<br>') + 
                        '</div>');
                } else {
                    WhatsAppPlugin.showNotification('error', 'Error: ' + response.message);
                }
            })
            .fail(function() {
                WhatsAppPlugin.showNotification('error', 'Error generando previsualización');
            });
        },
        
        // Mostrar editor de plantillas
        showTemplateEditor: function(template) {
            var html = `
                <form id="template-editor-form">
                    <input type="hidden" name="id" value="${template.id || ''}">
                    
                    <div class="whatsapp-config-field">
                        <label>Nombre:</label>
                        <input type="text" name="name" value="${template.name || ''}" required>
                    </div>
                    
                    <div class="whatsapp-config-field">
                        <label>Código:</label>
                        <input type="text" name="code" value="${template.code || ''}" required>
                        <div class="help-text">Solo letras minúsculas y guiones bajos</div>
                    </div>
                    
                    <div class="whatsapp-config-field">
                        <label>Evento:</label>
                        <select name="event_trigger" required>
                            <option value="">Seleccionar evento</option>
                            <option value="ticket.created" ${template.event_trigger === 'ticket.created' ? 'selected' : ''}>Ticket Creado</option>
                            <option value="threadentry.created" ${template.event_trigger === 'threadentry.created' ? 'selected' : ''}>Respuesta Creada</option>
                            <option value="ticket.assigned" ${template.event_trigger === 'ticket.assigned' ? 'selected' : ''}>Ticket Asignado</option>
                            <option value="ticket.resolved" ${template.event_trigger === 'ticket.resolved' ? 'selected' : ''}>Ticket Resuelto</option>
                            <option value="ticket.closed" ${template.event_trigger === 'ticket.closed' ? 'selected' : ''}>Ticket Cerrado</option>
                        </select>
                    </div>
                    
                    <div class="whatsapp-config-field">
                        <label>Mensaje:</label>
                        <textarea name="message" required>${template.message || ''}</textarea>
                        <div class="help-text">Usa variables como %{ticket.number}, %{user.name}, etc.</div>
                    </div>
                    
                    <div class="whatsapp-config-field">
                        <label>
                            <input type="checkbox" name="enabled" ${template.enabled ? 'checked' : ''}> 
                            Habilitada
                        </label>
                    </div>
                </form>
            `;
            
            this.showModal('Editor de Plantilla', html, [
                {
                    text: 'Cancelar',
                    class: 'btn-secondary',
                    click: this.closeModal
                },
                {
                    text: 'Guardar',
                    class: 'btn-whatsapp',
                    click: this.saveTemplate
                }
            ]);
        },
        
        // Guardar plantilla
        saveTemplate: function() {
            var $form = $('#template-editor-form');
            
            $.post(WhatsAppPlugin.config.apiUrl + WhatsAppPlugin.config.templateEndpoint, $form.serialize())
                .done(function(response) {
                    if (response.success) {
                        WhatsAppPlugin.showNotification('success', 'Plantilla guardada correctamente');
                        WhatsAppPlugin.closeModal();
                        location.reload(); // Recargar para mostrar cambios
                    } else {
                        WhatsAppPlugin.showNotification('error', 'Error: ' + response.message);
                    }
                })
                .fail(function() {
                    WhatsAppPlugin.showNotification('error', 'Error guardando plantilla');
                });
        },
        
        // Manejar cambio de canal de comunicación
        handleChannelChange: function() {
            var channel = $(this).val();
            var $whatsappFields = $('.whatsapp-specific-fields');
            
            if (channel === 'whatsapp' || channel === 'hybrid') {
                $whatsappFields.show().addClass('whatsapp-fade-in');
            } else {
                $whatsappFields.hide().removeClass('whatsapp-fade-in');
            }
        },
        
        // Inicializar editor de plantillas
        initializeTemplateEditor: function() {
            // Agregar contador de caracteres a textareas
            $('textarea[name="message"]').on('input', function() {
                var length = $(this).val().length;
                var $counter = $(this).next('.char-counter');
                
                if (!$counter.length) {
                    $counter = $('<div class="char-counter"></div>');
                    $(this).after($counter);
                }
                
                $counter.text(length + '/4000 caracteres');
                
                if (length > 4000) {
                    $counter.addClass('error');
                } else {
                    $counter.removeClass('error');
                }
            });
        },
        
        // Cargar estadísticas
        loadStats: function() {
            $.get('ajax.php/whatsapp/stats')
                .done(function(stats) {
                    var html = '';
                    
                    for (var key in stats) {
                        html += `
                            <div class="whatsapp-stat-card">
                                <h3>${stats[key].value}</h3>
                                <p>${stats[key].label}</p>
                            </div>
                        `;
                    }
                    
                    $('#whatsapp-stats-container').html(html);
                })
                .fail(function() {
                    $('#whatsapp-stats-container').html('<p>Error cargando estadísticas</p>');
                });
        },
        
        // Mostrar notificación
        showNotification: function(type, message) {
            var $notification = $(`
                <div class="whatsapp-notification ${type} whatsapp-fade-in">
                    ${message}
                    <button type="button" class="close" onclick="$(this).parent().remove()">×</button>
                </div>
            `);
            
            // Insertar al inicio del contenido principal
            $('.main-content, .content, #content').first().prepend($notification);
            
            // Auto-ocultar después de 5 segundos
            setTimeout(function() {
                $notification.fadeOut(function() {
                    $(this).remove();
                });
            }, 5000);
        },
        
        // Mostrar modal
        showModal: function(title, content, buttons) {
            var buttonsHtml = '';
            
            if (buttons) {
                buttonsHtml = '<div class="whatsapp-modal-footer">';
                buttons.forEach(function(btn) {
                    buttonsHtml += `<button type="button" class="btn ${btn.class}" onclick="WhatsAppPlugin.${btn.click.name}()">${btn.text}</button> `;
                });
                buttonsHtml += '</div>';
            }
            
            var modalHtml = `
                <div class="whatsapp-modal whatsapp-fade-in">
                    <div class="whatsapp-modal-content">
                        <div class="whatsapp-modal-header">
                            <h2>${title}</h2>
                            <span class="whatsapp-modal-close">&times;</span>
                        </div>
                        <div class="whatsapp-modal-body">
                            ${content}
                        </div>
                        ${buttonsHtml}
                    </div>
                </div>
            `;
            
            $('body').append(modalHtml);
        },
        
        // Cerrar modal
        closeModal: function() {
            $('.whatsapp-modal').fadeOut(function() {
                $(this).remove();
            });
        },
        
        // Formatear número de teléfono
        formatPhoneNumber: function(phone) {
            // Remover caracteres no numéricos excepto +
            phone = phone.replace(/[^\d+]/g, '');
            
            // Agregar + si no lo tiene
            if (!phone.startsWith('+')) {
                phone = '+' + phone;
            }
            
            return phone;
        },
        
        // Validar configuración
        validateConfiguration: function() {
            var errors = [];
            
            var apiToken = $('input[name="api_token"]').val();
            if (!apiToken) {
                errors.push('Token API es requerido');
            }
            
            var instanceId = $('input[name="instance_id"]').val();
            if (!instanceId) {
                errors.push('Instance ID es requerido');
            }
            
            var businessPhone = $('input[name="business_phone"]').val();
            if (!businessPhone) {
                errors.push('Número WhatsApp Business es requerido');
            } else if (!this.validatePhoneFormat(businessPhone)) {
                errors.push('Formato de número WhatsApp Business inválido');
            }
            
            return errors;
        },
        
        // Validar formato de teléfono
        validatePhoneFormat: function(phone) {
            var phoneRegex = /^\+?[1-9]\d{1,14}$/;
            return phoneRegex.test(phone.replace(/\s+/g, ''));
        },
        
        // Actualizar estado de mensaje
        updateMessageStatus: function(messageId, status) {
            var $statusElement = $(`[data-message-id="${messageId}"] .whatsapp-message-status`);
            
            if ($statusElement.length) {
                $statusElement.removeClass('sent delivered read failed')
                           .addClass(status);
                
                var statusText = {
                    'sent': 'Enviado',
                    'delivered': 'Entregado', 
                    'read': 'Leído',
                    'failed': 'Fallido'
                };
                
                $statusElement.attr('title', statusText[status] || status);
            }
        }
    };
    
    // Inicializar cuando el documento esté listo
    $(document).ready(function() {
        WhatsAppPlugin.init();
    });
    
    // Exponer funciones globales para uso en templates
    window.testWhatsAppConnection = WhatsAppPlugin.testConnection;
    window.editWhatsAppTemplate = WhatsAppPlugin.editTemplate;
    window.previewWhatsAppTemplate = WhatsAppPlugin.previewTemplate;
    
})(jQuery);
