<?php 
Layout::extend('layouts/keyword');
$title = 'Index';
?>

<h3><?php echo Html::anchor(Url::action('keywordController::newForm'), 'Create New keyword') ?></h3>

<?php if(isset($flash)): ?>
	<div class="error">
	<?php echo $flash; ?>
	</div>
<?php endif; ?>

<?php foreach($keywordSet as $keyword): ?>
	<?php Part::draw('keyword/details', $keyword) ?>
	<hr />
<?php endforeach; ?>