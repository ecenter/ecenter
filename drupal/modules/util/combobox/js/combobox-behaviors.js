Drupal.behaviors.Combobox = function(context) {
  var c = Drupal.settings.Combobox || [];
  for (var id in c){
    select = $('#' + c[id]);
    if (select.css('display') != 'none') {
      select.combobox();
    }
  }
}
