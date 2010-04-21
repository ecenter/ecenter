<?php
Part::input($eventtype, 'eventtype');
?>
  <fieldset>
  <h3><?php echo Html::anchor(Url::action('eventtypeController::details', $eventtype->ref_id), 'eventtype #' . $eventtype->ref_id) ?></h3>
  <p>
 	  <strong>Eventtype</strong>: <?php echo $eventtype->eventtype; ?><br />
 	  <strong>Service</strong>:<?php echo Html::anchor(Url::action('serviceController::details', $eventtype->service),  $eventtype->service) ?><br />

  </p>

  </fieldset>
