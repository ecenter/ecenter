Drupal.behaviors.Combobox = function(context) {
  var c = Drupal.settings.Combobox || [];
  for (var id in c){
    settings = c[id];
    select = $('#' + settings.id);
    if (select.css('display') != 'none') {
      select.combobox(settings);
    }
  }
}
