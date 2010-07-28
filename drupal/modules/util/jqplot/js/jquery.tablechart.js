// A very light wrapper around jqplot that scrapes tables for data to plot

(function($) {
$.fn.tablechart = function(options) {
  var o = $.extend(true, {}, $.fn.tablechart.defaults, options);

  this.each(function(i) {
    var table = $(this);
    var tabledata = $.fn.tablechart.scrapeTable(table);

    if (tabledata.data.length) {
      var chart = table.data('chart');

      // Get and redraw chart, or create a new one
      if (chart != undefined) {
        for (i in tabledata.data) {
          //chart.series[i].data = series[i];
        }
        chart.replot({resetAxes: true});
      } else {
        // Push scraped labels into series options 
        $.extend(true, o.plotOptions.series, tabledata.labels);

        chartId = $.uuid('chart-');
        chartContainer = $('<div>').attr('id', chartId);

        if (o.height) { chartContainer.height(o.height); }
        if (o.width) { chartContainer.width(o.width); }

        // Attach chart
        if (!o.append) {
          table.before(chartContainer);
        }
        else {
          $(o.appendSelector).append(chartContainer);
        }
        if (o.hideTable) {
          table.hide();
        }

        // Draw, store chart
        chart = $.jqplot(chartId, tabledata.data, o.plotOptions);
        table.data('chart', chart);
      }
    }

  });

  return this;
};

/**
 * Scrape "2-d" table for series and data values.
 * - Table must have series labels as table header columns in the table header.
 * - Table must use th tag as first element in tbody rows to provide x axis 
 *   values.
 *
 * Returns an associative array with 'labels' and 'data'.
 */
$.fn.tablechart.scrapeTable = function(table) {
  var series = [];
  var labels = [];
  var j = 0;

  table.find('thead th').each(function(i) {
    if (i > 0) {
      series[i-1] = [];
    }
    labels.push({label: $(this).text()});
  });

  table.find('tbody tr').each(function(i) {
    var val = 0, xval = 0, data = [];
    $(this).find('th').each(function(j) {
      xval = $.fn.tablechart.parseTH(this);
    });
    $(this).find('td').each(function(j) {
      series[j].push([xval, $.fn.tablechart.parseTD(this)]);
    });
  });

  return {
    labels: labels,
    data: series
  };
}

// Defaults
$.fn.tablechart.defaults = {
  hideTable: false,
  append: false,
  height: false,
  width: false,
  appendElement: null,
  plotOptions: {
    series: []
  }
};

$.fn.tablechart.parseTH = function(element) {
  return $(element).text();
}

$.fn.tablechart.parseTD = function(element) {
  return parseFloat($(element).text());
}


})(jQuery);

