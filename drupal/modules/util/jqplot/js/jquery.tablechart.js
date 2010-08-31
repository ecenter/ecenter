// A very light wrapper around jqplot that scrapes tables for data to plot

(function($) {
$.fn.tablechart = function(options) {
  var o = $.extend(true, {}, $.fn.tablechart.defaults, options);

  this.each(function(i) {
    var tables, chart;
    var series = [];

    // If element is not a table, look for them
    if (!$.nodeName(this, 'table')) {
      tables = $('table', this); 
    } else {
      tables = $(this);
    }

    // Get each table, add the series
    tables.each(function(i) {
      series.push($.fn.tablechart.scrapeTable($(this)));
    });

    chartId = $.uuid('chart-');
    chartContainer = $('<div>').attr('id', chartId);

    if (o.height) { chartContainer.height(o.height); }
    if (o.width) { chartContainer.width(o.width); }

    // Attach chart
    if (!o.append) {
      tables.before(chartContainer);
    }
    else {
      $(o.appendSelector).append(chartContainer);
    }

    // Hide tables
    if (o.hideTables) {
      tables.hide();
    }

    // Draw the chart
    if (series.length) {
      chart = $.jqplot(chartId, series, o.plotOptions);
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

  table.find('tbody tr').each(function(i) {
    var val = 0, xval = 0, data = [];
    $(this).find('th').each(function(j) {
      xval = $.fn.tablechart.parseValue(this);
    });
    $(this).find('td').each(function(j) {
      series.push([xval, $.fn.tablechart.parseValue(this)]);
    });
  });

  return series;
}

// Potentially vestigal function
$.fn.tablechart.parseValue = function(element) {
  return parseFloat($(element).text());
}

// Defaults
$.fn.tablechart.defaults = {
  hideTables: false,
  append: false,
  height: false,
  width: false,
  appendElement: null,
  plotOptions: {
    series: []
  }
};
})(jQuery);
