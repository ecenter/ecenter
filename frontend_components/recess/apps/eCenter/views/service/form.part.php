<?php
Part::input($form, 'ModelForm');
Part::input($title, 'string');
?>
<?php $form->begin(); ?>
	<fieldset>
		<legend><?php echo $title ?></legend>
		<?php $form->input('service'); ?>		
		
		<input type="submit" value="Save" />
	</fieldset>
<?php $form->end(); ?>