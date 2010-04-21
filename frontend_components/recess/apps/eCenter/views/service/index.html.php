<?php 
Layout::extend('layouts/service');
$title = 'Index';
?>

 
<?php if(isset($flash)): ?>
	<div class="error">
	<?php echo $flash; ?>
	</div>
<?php endif; ?>
<ul>
<?php $type_tmp = $serviceSet[0]->type;
      echo '<li><strong>' .  $type_tmp  .':</strong><ul>';
      foreach($serviceSet as $service) {
          if($service->type != $type_tmp  ) {
              echo '</ul><li><strong>' . $service->type .':</strong><ul>';
	      $type_tmp = $service->type;
	  }
	  
	  echo '<li>' . Html::anchor(Url::action('serviceController::details', $service->service), $service->service);
          echo ' <em><a href="' . $service->url . '">' . $service->name . '</a></em> ' . $service->comments;
      } 
      echo '</ul></ul>';
?>
