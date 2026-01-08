<?php
global $thisstaff, $ticket;

$role = $ticket ? $ticket->getRole($thisstaff) : $thisstaff->getRole();
// Verificar si el usuario tiene al menos uno de los permisos para cambiar estado
if ($role && !$role->hasPerm(Ticket::PERM_CLOSE) && !$role->hasPerm(Ticket::PERM_RESOLVE))
    return;

// Restricción especial: Analistas no pueden cambiar estado de tickets ya resueltos
if ($ticket && $role && $role->hasPerm(Ticket::PERM_RESOLVE) && !$role->hasPerm(Ticket::PERM_CLOSE)) {
    // Es un analista (solo tiene PERM_RESOLVE)
    $currentStatus = $ticket->getStatus();
    if ($currentStatus && $currentStatus->getId() == 2) { // Ticket ya está "Resolved"
        return; // No mostrar opciones de cambio de estado
    }
}

// Map states to actions
$actions= array(
        'closed' => array(
            'icon'  => 'icon-ok-circle',
            'action' => 'close',
            'href' => 'tickets.php'
            ),
        'open' => array(
            'icon'  => 'icon-undo',
            'action' => 'reopen'
            ),
        );

$states = array('open');
if (!$ticket || $ticket->isCloseable())
    $states[] = 'closed';

$statusId = $ticket ? $ticket->getStatusId() : 0;
$nextStatuses = array();
foreach (TicketStatusList::getStatuses(
            array('states' => $states)) as $status) {
    if (!isset($actions[$status->getState()])
            || $statusId == $status->getId())
        continue;
    
    // Verificar permisos específicos para cada estado
    if ($status->getState() == 'closed') {
        // Para estados cerrados, verificar si es "Resolved" o "Closed"
        if ($status->getId() == 2) { // Estado "Resolved"
            if (!$role->hasPerm(Ticket::PERM_RESOLVE))
                continue;
        } else { // Estado "Closed" u otros estados cerrados
            if (!$role->hasPerm(Ticket::PERM_CLOSE))
                continue;
        }
    }
    
    $nextStatuses[] = $status;
}

if (!$nextStatuses)
    return;
?>

<span
    class="action-button"
    data-dropdown="#action-dropdown-statuses" data-placement="bottom" data-toggle="tooltip" title="<?php echo __('Change Status'); ?>">
    <i class="icon-caret-down pull-right"></i>
    <a class="tickets-action"
        aria-label="<?php echo __('Change Status'); ?>"
        href="#statuses"><i
        class="icon-flag"></i></a>
</span>
<div id="action-dropdown-statuses"
    class="action-dropdown anchor-right">
    <ul <?php if (count($nextStatuses) > 20) echo 'style="height:500px;overflow-y:scroll"'; ?>>
<?php foreach ($nextStatuses as $status) { ?>
        <li>
            <a class="no-pjax <?php
                echo $ticket? 'ticket-action' : 'tickets-action'; ?>"
                href="<?php
                    echo sprintf('#%s/status/%s/%d',
                            $ticket ? ('tickets/'.$ticket->getId()) : 'tickets',
                            $actions[$status->getState()]['action'],
                            $status->getId()); ?>"
                <?php
                if (isset($actions[$status->getState()]['href']))
                    echo sprintf('data-redirect="%s"',
                            $actions[$status->getState()]['href']);

                ?>
                ><i class="<?php
                        echo $actions[$status->getState()]['icon'] ?: 'icon-tag';
                    ?>"></i> <?php
                        echo __($status->getName()); ?></a>
        </li>
    <?php
    } ?>
    </ul>
</div>
