Drupal.behaviors.QuickSelect = function(context) {
  var qs = Drupal.settings.QuickSelect;
  for (var selector in qs){
    selector_id = '#' + selector;
    // If the selector already has been converted to a quickselect, don't
    // apply quickselect to the hidden input it created!
    if ($(selector_id).attr('type') != 'hidden') {
      $(selector_id).quickselect(qs[selector]);
    }
    // Compatibility with AHAH -- most events still don't bind properly
    if (Drupal.settings.ahah[selector]) {
      Drupal.settings.ahah[selector + '_quickselect'] = Drupal.settings.ahah[selector];
      Drupal.settings.ahah[selector + '_quickselect']['selector'] = selector_id + '_quickselect';
      delete Drupal.settings.ahah[selector];
    }
  }
  // Argh!
  Drupal.behaviors.ahah(context);
}
