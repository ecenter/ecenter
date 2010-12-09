Drupal.behaviors.Combobox = function(context) {
  var c = Drupal.settings.Combobox || {};
  for (var id in c){
    select = $('#' + id);
    if (select.css('display') != 'none') {
      select.combobox();
    }
  }
  // Huh?
  /*if (Drupal.settings.ahah != undefined) {
    Drupal.behaviors.ahah(context);
  }*/
}
