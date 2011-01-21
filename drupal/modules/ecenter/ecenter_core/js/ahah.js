/**
 * Handler for the form redirection error.
 */
Drupal.ahah.prototype.error = function (response, uri) {
  if (!reponse.aborted) {
    alert(Drupal.ahahError(response, uri));
  }

  // Resore the previous action and target to the form.
  $(this.element).parent('form').attr( { action: this.form_action, target: this.form_target} );
  // Remove the progress element.
  if (this.progress.element) {
    $(this.progress.element).remove();
  }
  if (this.progress.object) {
    this.progress.object.stopMonitoring();
  }
  // Undo hide.
  $(this.wrapper).show();
  // Re-enable the element.
  $(this.element).removeClass('progess-disabled').attr('disabled', false);
};
