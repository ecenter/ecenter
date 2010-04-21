<?php
Part::input($keyword, 'keyword');
?>
  <fieldset>
  <h3><?php echo Html::anchor(Url::action('keywordController::details', $keyword->keyword), 'keyword #' . $keyword->keyword) ?></h3>
  <p>
 	  <strong>Keyword</strong>: <?php echo $keyword->keyword; ?><br />
 	  
  </p>

  </fieldset>
