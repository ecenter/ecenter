<?php
Part::input($form, 'ModelForm');
Part::input($title, 'string');
?>
<?php $form->begin(); ?>
	<fieldset>
		<legend><?php echo $title ?></legend>
		<?php $form->input('ref_id'); ?>		
				<p>
			<label for="<?php echo $form->keyword->getName(); ?>">Keyword</label><br />
			<?php $form->input('keyword'); ?>
		</p>
		<p>
			<label for="<?php echo $form->service->getName(); ?>">Service</label><br />
			<?php $form->input('service'); ?>
		</p>

		<input type="submit" value="Save" />
	</fieldset>
<?php $form->end(); ?>