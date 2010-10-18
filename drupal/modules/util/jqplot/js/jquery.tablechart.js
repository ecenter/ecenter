// A very light wrapper around jqplot that scrapes tables for data to plot

(function($) {
$.fn.tablechart = function(options) {
  var o = $.extend(true, {}, $.fn.tablechart.defaults, options);

  this.each(function(i) {
    chart = $(this).data('TableChart');
    if (chart == undefined) {
      tablechart = new TableChart(this, o);
      $(this).data('TableChart', tablechart);
    } else {
      chart.draw();
    }
  });

  return this;
};

// Defaults
$.fn.tablechart.defaults = {
  hideTables: false,
  hideChart: false,
  append: false,
  height: false,
  width: false,
  appendElement: null,
  plotOptions: {
    series: []
  }
};

function TableChart(el, options) {
  this.options = options;
  this.el = el;

  this.chartId = $.uuid('chart-');
  this.chartContainer = $('<div class="tablechart">').attr('id', this.chartId);

  if (options.height) { this.chartContainer.height(options.height); }
  if (options.width) { this.chartContainer.width(options.width); }

  // Attach chart
  $(el).prepend(this.chartContainer);

  this.draw();

  if (this.options.hideChart) {
    $('.tablechart').hide();
  }

}

TableChart.prototype.draw = function() {
  var tables;
  var series = [];
  var series_opts = [];
  var tablechart = this;

  // If element is not a table, look for them
  if (!$.nodeName(this.el, 'table')) {
    tables = $('table', this.el);
  } else {
    tables = $(this.el);
  }

  // Get each table, add the series
  tables.each(function(i) {
    series.push(tablechart.scrapeTable($(this)));
    // Extract 
    if ($.metadata) {
      metadata = $(this).metadata();
      if (metadata) {
        series_opts[i] = metadata;
      }
    }
  });

  // Extend series options with metadata from table
  additional_opts = {series: series_opts}
  $.extend(true, this.options.plotOptions, additional_opts);

  // Hide tables
  if (this.options.hideTables) {
    tables.hide();
  }

  // Draw the chart
  if (series.length > 0) {
    this.chart = $.jqplot(this.chartId, series, this.options.plotOptions);
  }
}

/**
 * Scrape "2-d" table for series and data values.
 * - Table must have series labels as table header columns in the table header.
 * - Table must use th tag as first element in tbody rows to provide x axis 
 *   values.
 *
 * Returns an associative array with 'labels' and 'data'.
 */
TableChart.prototype.scrapeTable = function(table) {
  var series = [];
  var labels = [];
  var tablechart = this;
  var j = 0;

  table.find('tbody tr').each(function(i) {
    var val = 0, xval = 0, data = [];
    $(this).find('th').each(function(j) {
      xval = tablechart.parseValue(this);
    });
    $(this).find('td').each(function(j) {
      series.push([xval, tablechart.parseValue(this)]);
    });
  });

  return series;
}

// Potentially vestigal function
TableChart.prototype.parseValue = function(element) {
  return parseFloat($(element).text());
}

})(jQuery);
