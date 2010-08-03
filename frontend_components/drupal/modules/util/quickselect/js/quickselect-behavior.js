Drupal.behaviors.QuickSelect = function(context) {
  var qs = Drupal.settings.QuickSelect;
  for (var selector in qs){
    selector_id = '#' + selector;
    // If the selector already has been converted to a quickselect, don't
    // apply quickselect to the hidden input it created!
    if ($(selector_id).attr('type') != 'hidden') {
      $(selector_id).quickselect(qs[selector]);
    }
  }
  if (Drupal.settings.ahah != undefined) {
    Drupal.behaviors.ahah(context);
  }
}
