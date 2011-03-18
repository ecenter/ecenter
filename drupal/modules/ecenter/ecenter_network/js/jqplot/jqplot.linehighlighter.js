/**
 * Line highlighter plugin for jqPlot
 *
 * Copyright (c) 2010 Fermi National Accelerator Laboratory
 * Developed by David Eads (davideads__at__gmail__dot__com)
 *
 * Available under the Fermitools license (modified BSD)
 * http://fermitools.fnal.gov/about/terms.html
 *
 * The line highlighter plugin uses pixel detection to determine if the user
 * is hovering over one or more series in a line chart and does something in
 * response.  This plugin emulates the behavior of highlighting for filled
 * line charts or the highlight plugin for data points.  However, the line
 * need not be filled, and the cursor need not be near a data point for
 * detection to work.
 *
 * This is my first jqplot plugin.  It only works with line charts drawn with
 * the line renderer, and does not attempt to account for OHLC-style charts --
 * your mileage with OHLC charts may vary.
 */

(function($) {
  $.jqplot.eventListenerHooks.push(['jqplotMouseMove', handleMove]);

  $.jqplot.LineHighlighter = function(options) {
    // Group: Properties
    //
    // prop: show
    // true to highlight a line
    this.show = $.jqplot.config.enablePlugins;
    // prop: threshold
    // Detection threshold -- how far must the cursor from a series to make it
    // highlight?  Due to the inner workings of the Canvas element, the
    // detection "reticule" is a  2*threshold x 2*threshold sized box.
    // For current purposes, this should be good enough for setting detection
    // sensitivity.
    this.threshold = 3;
    // prop: size adjust
    // Number of pixels to add (or subtract, if negative) from the original
    // line width when drawing the highlight line.
    this.sizeAdjust = 2;
    // prop: colors
    // An array of highlight colors -- the colors correspond to the series
    // index.  If no colors are provided, or no color exists for a given series
    // index, jqPlot's auto-calculated colors will be used.
    this.colors = null;

    $.extend(true, this, options);
  }

  // called with scope of plot
  $.jqplot.LineHighlighter.init = function (target, data, opts){
    var options = opts || {};
    // add a highlighter attribute to the plot
    this.plugins.linehighlighter = new $.jqplot.LineHighlighter(options.linehighlighter);
  };

  // called within scope of series
  $.jqplot.LineHighlighter.parseOptions = function (defaults, options) {
    // Add a showHighlight option to the series
    // and set it to true by default.
    this.highlightSeries = true;
    this.sizeAdjust = false;
  };

  // Called within context of plot:
  // Create a canvas which we can draw on. Insert it before the eventCanvas, so
  // eventCanvas will still capture events.
  //
  // @TODO Will configuration order affect this? Do we also need to detect and/or
  // account for highlight canvas or other canvases?
  $.jqplot.LineHighlighter.postPlotDraw = function() {
    this.plugins.linehighlighter.highlightCanvas = new $.jqplot.GenericCanvas();
    this.eventCanvas._elem.before(this.plugins.linehighlighter.highlightCanvas.createElement(this._gridPadding, 'jqplot-linehighlight-canvas', this._plotDimensions));
  };

  // Register plugins
  $.jqplot.preInitHooks.push($.jqplot.LineHighlighter.init);
  $.jqplot.preParseSeriesOptionsHooks.push($.jqplot.LineHighlighter.parseOptions);
  $.jqplot.postDrawHooks.push($.jqplot.LineHighlighter.postPlotDraw);

  // Highlight a series:  Provided as a plugin method
  $.jqplot.LineHighlighter.prototype.highlightSeries = function(sidx, plot, options) {
    var o = options || {};
    var s = plot.series[sidx];
    var lh = plot.plugins.linehighlighter;
    var hc = lh.highlightCanvas;
    var hctx = hc.setContext();

    // Handle options: 
    var sizeAdjust = (s.sizeAdjust !== false) ? s.sizeAdjust : lh.sizeAdjust;
    var series_color = (lh.colors && lh.colors[sidx] != undefined) ? lh.colors[sidx] : s.seriesColors[sidx];
    var opts = $.extend(true, {}, {color: series_color, lineWidth: s.lineWidth + sizeAdjust}, o);

    // Render line
    s.renderer.shapeRenderer.draw(hctx, s.gridData, opts);
    s.isHighlightingLine = true;
  }

  // Unhighlight a series (technically, this unhighlights ALL series)
  $.jqplot.LineHighlighter.prototype.unhighlightSeries = function(sidx, plot) {
    var s = plot.series[sidx];
    var hc = plot.plugins.linehighlighter.highlightCanvas;
    var hctx = hc.setContext();

    hctx.clearRect(0, 0, hctx.canvas.width, hctx.canvas.height);
    s.isHighlightingLine = false;
  }

  function handleMove(ev, gridpos, datapos, neighbor, plot) {
    var lh = plot.plugins.linehighlighter;

    // Plugin is disabled
    if (!lh.show) {
      return;
    }

    var hc = lh.highlightCanvas;
    var c = plot.plugins.cursor;


    var series = plot.series;
    var i, k, s, xleft, ytop, xright, ybottom;
    var imagedata, series_ctx;

    var threshold = lh.threshold;
    var boxW = boxH = threshold * 2;

    // Bail if zooming (which is already rather slow)
    if (c && c._zoom.started) {
      return;
    }

    for (k=plot.seriesStack.length-1; k>=0; k--) {
      i = plot.seriesStack[k];
      s = series[i];

      // Don't allow this series to be highlighted
      if (!s.highlightSeries) {
        continue;
      }

      switch (s.renderer.constructor) {
        case $.jqplot.LineRenderer:
          series_ctx = s.canvas.setContext();

          xleft = gridpos.x - threshold;
          ytop = gridpos.y - threshold;
          xright = gridpos.x + threshold;
          ybottom = gridpos.y + threshold;

          // Account for edges

          // Left edge
          if (xleft < 1) {
            boxW = threshold + xleft + 1;
            xleft = 1;
          }

          // Top edge
          if (ytop < 1) {
            boxH = threshold + ytop + 1;
            ytop = 1;
          }

          // Right edge
          if (xright >= series_ctx.canvas.width) {
            boxW = threshold - (xright - series_ctx.canvas.width);
            if (boxW < 1) {
              xleft = xleft - 1;
              boxW = 1;
            }
          }

          // Bottom edge
          if (ybottom >= series_ctx.canvas.height) {
            boxH = threshold - (ybottom - series_ctx.canvas.height);
            if (boxH < 1) {
              ytop = ytop - 1;
              boxH = 1;
            }
          }

          imagedata = series_ctx.getImageData(xleft, ytop, boxW, boxH);
          max = Math.max.apply(Math, imagedata.data);

          if (!max && s.isHighlightingLine) {
            lh.unhighlightSeries(i, plot);
            hc._elem.trigger('jqplotUnhighlightSeries', i, plot);
          }
          if (max > 0 && !s.isHighlightingLine) {
            lh.highlightSeries(i, plot);
            hc._elem.trigger('jqplotHighlightSeries', i, plot);
          }

          break;
      }
    }
  }
})(jQuery);
