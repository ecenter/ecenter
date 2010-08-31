Drupal.behaviors.jqPlot = function(context) {
  for (var selector in Drupal.settings.jqPlot) {
    var settings = Drupal.settings.jqPlot[selector];

    // @TODO Use something other than eval
    if (settings.plotOptions != undefined) {
      if (settings.plotOptions.axes != undefined) {
        if (settings.plotOptions.axes.xaxis != undefined && settings.plotOptions.axes.xaxis.renderer) {
          settings.plotOptions.axes.xaxis.renderer = eval(settings.plotOptions.axes.xaxis.renderer);
        }
        if (settings.plotOptions.axes.yaxis != undefined && settings.plotOptions.axes.yaxis.renderer) {
          settings.plotOptions.axes.yaxis.renderer = eval(settings.plotOptions.axes.yaxis.renderer);
        }
        if (settings.plotOptions.axes.xaxis != undefined && settings.plotOptions.axes.xaxis.labelRenderer) {
          settings.plotOptions.axes.xaxis.labelRenderer = eval(settings.plotOptions.axes.xaxis.labelRenderer);
        }
        if (settings.plotOptions.axes.yaxis != undefined && settings.plotOptions.axes.yaxis.labelRenderer) {
          settings.plotOptions.axes.yaxis.labelRenderer = eval(settings.plotOptions.axes.yaxis.labelRenderer);
        }
      }
    }

    $(selector).tablechart(settings);
  }
}
