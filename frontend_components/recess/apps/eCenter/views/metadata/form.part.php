<?php
Part::input($form, 'ModelForm');
Part::input($title, 'string');
?>
<?php $form->begin(); ?>
	<fieldset>
		<legend><?php echo $title ?></legend>
		<?php $form->input('metadata'); ?>		
				<p>
			<label for="<?php echo $form->metaid->getName(); ?>">Metaid</label><br />
			<?php $form->input('metaid'); ?>
		</p>
		<p>
			<label for="<?php echo $form->service->getName(); ?>">Service</label><br />
			<?php $form->input('service'); ?>
		</p>
		<p>
			<label for="<?php echo $form->subject->getName(); ?>">Subject</label><br />
			<?php $form->input('subject'); ?>
		</p>
		<p>
			<label for="<?php echo $form->parameters->getName(); ?>">Parameters</label><br />
			<?php $form->input('parameters'); ?>
		</p>

		<input type="submit" value="Save" />
	</fieldset>
<?php $form->end(); ?>