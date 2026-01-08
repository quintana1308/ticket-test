<?php
/**
 * Sistema de Plantillas WhatsApp para osTicket
 * 
 * Maneja plantillas de mensajes, formateo HTML a texto y variables dinámicas
 * 
 * @author quintana1308 <andres.leguizamon@sistemasadn.com>
 * @version 1.0.0
 * @date Enero 2026
 */

class WhatsAppTemplateManager {
    
    private $config;
    private $cache = array();
    
    public function __construct($config) {
        $this->config = $config;
    }
    
    /**
     * Obtener plantilla por código
     */
    public function getTemplate($code, $dept_id = null) {
        $cache_key = $code . '_' . ($dept_id ?: 'global');
        
        if (isset($this->cache[$cache_key])) {
            return $this->cache[$cache_key];
        }
        
        $sql = 'SELECT * FROM ost_whatsapp_templates 
                WHERE code = %s AND enabled = 1 
                AND (dept_id = %d OR dept_id IS NULL)
                ORDER BY dept_id DESC LIMIT 1';
        
        $res = db_query($sql, $code, $dept_id ?: 0);
        
        if ($res && db_num_rows($res)) {
            $template = db_fetch_array($res);
            $this->cache[$cache_key] = $template;
            return $template;
        }
        
        return null;
    }
    
    /**
     * Procesar plantilla con variables
     */
    public function processTemplate($template, $variables = array()) {
        if (!$template || !isset($template['message'])) {
            return '';
        }
        
        $message = $template['message'];
        
        // Procesar variables básicas
        foreach ($variables as $key => $value) {
            if (is_scalar($value)) {
                $message = str_replace("%{$key}", $value, $message);
            } elseif (is_object($value)) {
                $message = $this->processObjectVariables($message, $key, $value);
            } elseif (is_array($value)) {
                $message = $this->processArrayVariables($message, $key, $value);
            }
        }
        
        // Procesar variables del sistema
        $message = $this->processSystemVariables($message);
        
        // Formatear para WhatsApp
        $message = $this->formatForWhatsApp($message);
        
        return $message;
    }
    
    /**
     * Procesar variables de objeto
     */
    private function processObjectVariables($message, $prefix, $object) {
        $pattern = "/\%\{" . preg_quote($prefix) . "\.([^}]+)\}/";
        
        return preg_replace_callback($pattern, function($matches) use ($object) {
            $property = $matches[1];
            return $this->getObjectProperty($object, $property);
        }, $message);
    }
    
    /**
     * Procesar variables de array
     */
    private function processArrayVariables($message, $prefix, $array) {
        $pattern = "/\%\{" . preg_quote($prefix) . "\.([^}]+)\}/";
        
        return preg_replace_callback($pattern, function($matches) use ($array) {
            $key = $matches[1];
            return isset($array[$key]) ? $array[$key] : '';
        }, $message);
    }
    
    /**
     * Obtener propiedad de objeto
     */
    private function getObjectProperty($object, $property) {
        // Mapear propiedades comunes de osTicket
        $property_map = array(
            'name' => 'getName',
            'number' => 'getNumber', 
            'subject' => 'getSubject',
            'email' => 'getEmail',
            'created' => 'getCreateDate',
            'updated' => 'getUpdateDate',
            'status' => 'getStatus',
            'priority' => 'getPriority',
            'dept' => 'getDept',
            'assignee' => 'getAssignee',
            'user' => 'getUser',
            'staff' => 'getStaff'
        );
        
        if (isset($property_map[$property])) {
            $method = $property_map[$property];
            if (method_exists($object, $method)) {
                $result = $object->$method();
                
                // Si el resultado es otro objeto, obtener su nombre
                if (is_object($result) && method_exists($result, 'getName')) {
                    return $result->getName();
                } elseif (is_object($result) && method_exists($result, '__toString')) {
                    return (string) $result;
                }
                
                return $result;
            }
        }
        
        // Intentar acceso directo a propiedad
        if (isset($object->$property)) {
            return $object->$property;
        }
        
        return '';
    }
    
    /**
     * Procesar variables del sistema
     */
    private function processSystemVariables($message) {
        $system_vars = array(
            '%{system.name}' => $this->config->get('helpdesk_title', 'osTicket'),
            '%{system.url}' => $this->config->get('helpdesk_url', ''),
            '%{system.email}' => $this->config->get('default_email', ''),
            '%{date}' => date('d/m/Y'),
            '%{time}' => date('H:i'),
            '%{datetime}' => date('d/m/Y H:i'),
            '%{year}' => date('Y')
        );
        
        foreach ($system_vars as $var => $value) {
            $message = str_replace($var, $value, $message);
        }
        
        return $message;
    }
    
    /**
     * Formatear mensaje para WhatsApp
     */
    public function formatForWhatsApp($content) {
        // Si el contenido es HTML, convertir a texto
        if ($this->isHtml($content)) {
            $content = $this->htmlToWhatsApp($content);
        }
        
        // Limpiar espacios extra
        $content = preg_replace('/\n{3,}/', "\n\n", $content);
        $content = trim($content);
        
        // Limitar longitud del mensaje (WhatsApp tiene límite de ~4096 caracteres)
        if (strlen($content) > 4000) {
            $content = substr($content, 0, 3997) . '...';
        }
        
        return $content;
    }
    
    /**
     * Verificar si el contenido es HTML
     */
    private function isHtml($content) {
        return $content !== strip_tags($content);
    }
    
    /**
     * Convertir HTML a formato WhatsApp
     */
    private function htmlToWhatsApp($html) {
        // Mapear elementos HTML a formato WhatsApp
        $replacements = array(
            // Encabezados
            '/<h[1-6][^>]*>(.*?)<\/h[1-6]>/is' => "*$1*\n\n",
            
            // Texto en negrita
            '/<(strong|b)[^>]*>(.*?)<\/(strong|b)>/is' => "*$2*",
            
            // Texto en cursiva
            '/<(em|i)[^>]*>(.*?)<\/(em|i)>/is' => "_$2_",
            
            // Texto tachado
            '/<(strike|s|del)[^>]*>(.*?)<\/(strike|s|del)>/is' => "~$2~",
            
            // Código
            '/<(code|tt)[^>]*>(.*?)<\/(code|tt)>/is' => "```$2```",
            
            // Bloques de código
            '/<pre[^>]*>(.*?)<\/pre>/is' => "```\n$1\n```",
            
            // Enlaces
            '/<a[^>]*href=["\']([^"\']*)["\'][^>]*>(.*?)<\/a>/is' => "$2 ($1)",
            
            // Listas
            '/<li[^>]*>(.*?)<\/li>/is' => "• $1\n",
            '/<\/?(ul|ol)[^>]*>/i' => "\n",
            
            // Párrafos y saltos de línea
            '/<\/p>/i' => "\n\n",
            '/<p[^>]*>/i' => "",
            '/<br[^>]*\/?>/i' => "\n",
            
            // Divisiones
            '/<\/div>/i' => "\n",
            '/<div[^>]*>/i' => "",
            
            // Tablas (simplificado)
            '/<\/tr>/i' => "\n",
            '/<\/td>/i' => " | ",
            '/<t[dhr][^>]*>/i' => "",
            '/<\/?(table|tbody|thead)[^>]*>/i' => "\n",
            
            // Otros elementos de bloque
            '/<\/?(blockquote|address)[^>]*>/i' => "\n",
            
            // Elementos inline que se eliminan
            '/<\/?(span|font)[^>]*>/i' => "",
        );
        
        // Aplicar reemplazos
        $text = $html;
        foreach ($replacements as $pattern => $replacement) {
            $text = preg_replace($pattern, $replacement, $text);
        }
        
        // Eliminar cualquier HTML restante
        $text = strip_tags($text);
        
        // Decodificar entidades HTML
        $text = html_entity_decode($text, ENT_QUOTES, 'UTF-8');
        
        // Limpiar espacios y saltos de línea extra
        $text = preg_replace('/[ \t]+/', ' ', $text);
        $text = preg_replace('/\n[ \t]+/', "\n", $text);
        $text = preg_replace('/[ \t]+\n/', "\n", $text);
        $text = preg_replace('/\n{3,}/', "\n\n", $text);
        
        return trim($text);
    }
    
    /**
     * Crear plantilla
     */
    public function createTemplate($data) {
        $sql = 'INSERT INTO ost_whatsapp_templates 
                (name, code, subject, message, variables, event_trigger, dept_id, enabled, created) 
                VALUES (%s, %s, %s, %s, %s, %s, %d, %d, NOW())';
        
        $variables = isset($data['variables']) ? json_encode($data['variables']) : null;
        $dept_id = isset($data['dept_id']) ? $data['dept_id'] : null;
        $enabled = isset($data['enabled']) ? $data['enabled'] : 1;
        
        return db_query($sql, 
            $data['name'], 
            $data['code'], 
            $data['subject'], 
            $data['message'], 
            $variables, 
            $data['event_trigger'], 
            $dept_id, 
            $enabled
        );
    }
    
    /**
     * Actualizar plantilla
     */
    public function updateTemplate($id, $data) {
        $sql = 'UPDATE ost_whatsapp_templates SET 
                name = %s, subject = %s, message = %s, variables = %s, 
                event_trigger = %s, dept_id = %d, enabled = %d, updated = NOW() 
                WHERE id = %d';
        
        $variables = isset($data['variables']) ? json_encode($data['variables']) : null;
        $dept_id = isset($data['dept_id']) ? $data['dept_id'] : null;
        $enabled = isset($data['enabled']) ? $data['enabled'] : 1;
        
        return db_query($sql, 
            $data['name'], 
            $data['subject'], 
            $data['message'], 
            $variables, 
            $data['event_trigger'], 
            $dept_id, 
            $enabled, 
            $id
        );
    }
    
    /**
     * Eliminar plantilla
     */
    public function deleteTemplate($id) {
        $sql = 'DELETE FROM ost_whatsapp_templates WHERE id = %d';
        return db_query($sql, $id);
    }
    
    /**
     * Listar plantillas
     */
    public function listTemplates($dept_id = null, $enabled_only = true) {
        $sql = 'SELECT * FROM ost_whatsapp_templates WHERE 1=1';
        $params = array();
        
        if ($dept_id !== null) {
            $sql .= ' AND (dept_id = %d OR dept_id IS NULL)';
            $params[] = $dept_id;
        }
        
        if ($enabled_only) {
            $sql .= ' AND enabled = 1';
        }
        
        $sql .= ' ORDER BY name ASC';
        
        $templates = array();
        $res = db_query($sql, ...$params);
        
        while ($row = db_fetch_array($res)) {
            $templates[] = $row;
        }
        
        return $templates;
    }
    
    /**
     * Obtener variables disponibles para una plantilla
     */
    public function getAvailableVariables($event_trigger) {
        $variables = array();
        
        switch ($event_trigger) {
            case 'ticket.created':
                $variables = array(
                    'ticket.number', 'ticket.subject', 'ticket.created', 'ticket.dept.name',
                    'user.name', 'user.email', 'user.phone'
                );
                break;
                
            case 'threadentry.created':
                $variables = array(
                    'ticket.number', 'ticket.subject', 'staff.name', 'staff.email',
                    'message.content', 'message.created'
                );
                break;
                
            case 'ticket.assigned':
                $variables = array(
                    'ticket.number', 'ticket.subject', 'staff.name', 'staff.email',
                    'ticket.assignee.name'
                );
                break;
                
            case 'ticket.resolved':
            case 'ticket.closed':
                $variables = array(
                    'ticket.number', 'ticket.subject', 'ticket.updated', 
                    'staff.name', 'staff.email'
                );
                break;
                
            default:
                $variables = array(
                    'system.name', 'system.url', 'date', 'time', 'datetime'
                );
        }
        
        // Agregar variables del sistema siempre disponibles
        $system_variables = array(
            'system.name', 'system.url', 'system.email', 
            'date', 'time', 'datetime', 'year'
        );
        
        return array_unique(array_merge($variables, $system_variables));
    }
    
    /**
     * Validar plantilla
     */
    public function validateTemplate($data) {
        $errors = array();
        
        if (empty($data['name'])) {
            $errors['name'] = 'Nombre de plantilla es requerido';
        }
        
        if (empty($data['code'])) {
            $errors['code'] = 'Código de plantilla es requerido';
        } elseif (!preg_match('/^[a-z_]+$/', $data['code'])) {
            $errors['code'] = 'Código debe contener solo letras minúsculas y guiones bajos';
        }
        
        if (empty($data['message'])) {
            $errors['message'] = 'Contenido del mensaje es requerido';
        }
        
        // Verificar que el código sea único
        if (!empty($data['code'])) {
            $sql = 'SELECT id FROM ost_whatsapp_templates WHERE code = %s';
            $params = array($data['code']);
            
            if (isset($data['id'])) {
                $sql .= ' AND id != %d';
                $params[] = $data['id'];
            }
            
            $existing = db_query($sql, ...$params);
            if ($existing && db_num_rows($existing)) {
                $errors['code'] = 'Este código ya está en uso';
            }
        }
        
        return $errors;
    }
    
    /**
     * Previsualizar plantilla
     */
    public function previewTemplate($template, $sample_data = array()) {
        // Datos de muestra para previsualización
        $default_sample = array(
            'ticket' => (object) array(
                'number' => 'T123456',
                'subject' => 'Consulta de ejemplo',
                'created' => date('d/m/Y H:i'),
                'updated' => date('d/m/Y H:i'),
                'dept' => (object) array('name' => 'Soporte Técnico')
            ),
            'user' => (object) array(
                'name' => 'Juan Pérez',
                'email' => 'juan@ejemplo.com',
                'phone' => '+54 9 11 1234-5678'
            ),
            'staff' => (object) array(
                'name' => 'Ana García',
                'email' => 'ana@empresa.com'
            ),
            'message' => array(
                'content' => 'Este es un mensaje de ejemplo para la previsualización.',
                'created' => date('d/m/Y H:i')
            )
        );
        
        $sample_data = array_merge($default_sample, $sample_data);
        
        return $this->processTemplate($template, $sample_data);
    }
}
