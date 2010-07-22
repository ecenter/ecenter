Drupal.behaviors.jqPlot = function(context) {
  for (var selector in Drupal.settings.jqPlot) {
    var settings = Drupal.settings.jqPlot[selector];

    // @TODO this is super hacky
    if (settings.plotOptions != undefined) {
      if (settings.plotOptions.axes != undefined) {
        if (settings.plotOptions.axes.xaxis != undefined && settings.plotOptions.axes.xaxis.renderer) {
          settings.plotOptions.axes.xaxis.renderer = eval(settings.plotOptions.axes.xaxis.renderer); 
        }
        if (settings.plotOptions.axes.yaxis != undefined && settings.plotOptions.axes.yaxis.renderer) {
          settings.plotOptions.axes.yaxis.renderer = eval(settings.plotOptions.axes.yaxis.renderer); 
        }
      }
    }

    $(selector).tablechart(settings);
  }
}
