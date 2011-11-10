Drupal.behaviors.Combobox = function(context) {
  var c = Drupal.settings.Combobox || [];
  for (var id in c){
    settings = c[id];
    select = $('#' + settings.id);
    var processed = select.data('ComboboxProcessed');
    if (!processed) {
      if (select.css('display') != 'none') {
        select.combobox(settings);
      }
      select.data('ComboboxProcessed', true);
     }
   }
  $('.form-combobox select').each(function() {
    var processed = $(this).data('ComboboxProcessed');
    if (!processed) {
      $(this).combobox();
      $(this).data('ComboboxProcessed', true);
    }
  });
}
