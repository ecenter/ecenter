<?php 
Layout::extend('layouts/user');
$title = 'Details of user #' . $user->user ;
?>

<?php Part::draw('user/details', $user) ?>

<?php echo Html::anchor(Url::action('userController::index'), 'Back to list of users') ?>
<hr />