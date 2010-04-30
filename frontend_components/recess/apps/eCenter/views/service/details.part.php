<?php
Part::input($service, 'service');
?>
 	<fieldset>
	<h3><?php echo Html::anchor(Url::action('serviceController::details', $service->service), 'service #' . $service->service) ?></h3>
	<p>
	<ul>
          <li><strong>Name:</strong><?php  echo $service->name ?>
	  <li><strong>Type:</strong><?php  echo $service->type ?>
	  <li><strong>URL:</strong><a href="<?php   
	                      preg_match('@^(http|tcp)://([^:]+)?@i', $service->url, $matches);
	                      $url =  ($matches && $matches[1] == 'http')?$service->url:
	                                  $matches?'http://' . $matches[2]:
		                             'http://' .  $service->url; 
				echo $url;  ?>"> <?php  echo $service->url ?></a>
	 <li><strong>Description:</strong><?php  echo $service->comments ?>
	 <li><strong>Keywords:</strong>
	   <ul>
	       <?php 
	               foreach($service->keywords_services as $keysvc) {
		          echo '<li><em>' .  Html::anchor(Url::action('keywordController::details',  $keysvc->keyword), 'keyword= ' . $keysvc->keyword) . '</em>';
		       }
	       ?>
	   </ul>
	  <li><strong>Eventtypes:</strong>
	   <ul>
	       <?php 
	               foreach($service->eventtypes as $evnt) {
		          echo '<li><em>' . Html::anchor(Url::action('eventtypeController::details', $evnt->ref_id ), 'eventtype= ' . $evnt->eventtype). '</em>';
		       }
	       ?>
	   </ul>
	    <?php if ($service->metadatas) {
	            echo '<li><strong>Metadata:</strong><ul>';
	            foreach($service->metadatas as $md) {
		         echo '<li><em>' . Html::anchor(Url::action('metadataController::details', $md->metadata), 'metadata=' . $md->metaid) . '</em>';
		    }
	            echo '</ul>';
		 }
	    ?>
	    </ul>
	</p>
	</fieldset>
 
