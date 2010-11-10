Drupal.behaviors.jqPlot = function(context) {
  var replace = ['renderer', 'markerRenderer', 'labelRenderer', 'parseX',
    'parseY', 'scrapeSingle', 'scrapeMultiple', 'processSeries'];

  $.each(Drupal.settings.jqPlot, function(selector, settings) {
    settings = Drupal.jqPlot.replaceFunctions(settings, replace);
    $(selector).tablechart(settings);
  });
}

Drupal.jqPlot = {};

Drupal.jqPlot.replaceFunctions = function(obj, replace) {
  $.each(obj, function(key, val) {
    if (typeof val == 'object') {
      obj[key] = Drupal.jqPlot.replaceFunctions(val, replace);
    }
    else if (typeof val == 'string' && $.inArray(key, replace) > -1) {
      namespaces = val.split(".");
      func = namespaces.pop();
      context = window;
      for (var i = 0; i < namespaces.length; i++) {
        context = context[namespaces[i]];
      }
      obj[key] = context[func];
    }
  });
  return obj;
}
