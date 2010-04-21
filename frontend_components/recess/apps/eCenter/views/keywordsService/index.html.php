<?php 
Layout::extend('layouts/keywordsService');
$title = 'Index';
?>

<h3><?php echo Html::anchor(Url::action('keywords_serviceController::newForm'), 'Create New keywords_service') ?></h3>

<?php if(isset($flash)): ?>
	<div class="error">
	<?php echo $flash; ?>
	</div>
<?php endif; ?>

<?php foreach($keywordsServiceSet as $keywordsService): ?>
	<?php Part::draw('keywordsService/details', $keywordsService) ?>
	<hr />
<?php endforeach; ?>