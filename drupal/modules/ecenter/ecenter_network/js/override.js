(function($) {

/**
 * Override tablechart attachMethod
 */
$.fn.tablechart.defaults.attachMethod = function(container) {
  $('.chart-title', this.el).after(container);
}

/**
 * Utility function: Scrape single table for values
 */
$.tablechart.scrapeSingle = function(table) {
  var series = [],
      options = this.options,
      tablechart = this,
      seriesOptions = {},
      bandHigh = [],
      bandLow = [];

  if (options.headerSeriesLabels) {
    $(table).find('thead th:gt(0)').each(function(i) {
      seriesOptions.label = $(this).text();
    });
  }

  $(table).find('tbody tr').each(function(j) {
    var x = 0, y = 0, max, min;
    $(this).find('th').each(function() {
      x = options.parseX.call(tablechart, this);
    });
    $(this).find('td').each(function(i) {
      if (i == 0) {
        if (!series[0]) {
          series[0] = [];
        }
        y = options.parseY.call(tablechart, this);
        series[0].push([x, y]);
      }
      else if (i == 1) {
        min = options.parseY.call(tablechart, this);
      }
      else if (i == 2) {
        max = options.parseY.call(tablechart, this);
      }
    });
    if (min && max) {
      bandLow.push( [x, min] );
      bandHigh.push( [x, max] );
    }
  });

  if (bandHigh.length && bandLow.length) {
    seriesOptions = { 'rendererOptions' : { 'bandData' : [bandLow, bandHigh] } };
  }

  return { 'series' : series, 'options' : seriesOptions };
}

$.jqplot.Highlighter.errorTooltip = function(str, seriesIndex, pointIndex, plot) {
  var series = plot.series[seriesIndex];
  if (typeof series.rendererOptions.bandData !== 'undefined' && series.rendererOptions.bandData.length) {
    lowValue = series.rendererOptions.bandData[0][pointIndex],
    highValue = series.rendererOptions.bandData[1][pointIndex];
    str += '<span class="max-err">Err max: '+ highValue[1] +'</span>';
    str += '<span class="min-err">Err min: '+ lowValue[1] +'</span>';
  }
  return str;
}

})(jQuery);
