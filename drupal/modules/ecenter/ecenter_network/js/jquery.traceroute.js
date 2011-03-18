// jQuery plugin to create a "subway map" of a traceroute

/**
 * This plugin takes a specially formed array and turns it into a traceroute
 * "subway map".
 *
 * History
 *
 * - 0.1: Got basic diff drawing and parsing working. Vertical "subway map"
 *   detailed hop labels.
 * - 0.2: Current iteration: Horizontal subway map, significantly smaller
 *   implementations.
 * - Future: More configurable and generic plugin:
 *
 * Configurable callbacks could include:
 *    
 * - Increment/calculate next hop location
 * - What to do in various diff conditions
 */
(function($) {

$.fn.traceroute = function(data, options) {
  var options = $.extend(true, {}, $.fn.traceroute.defaults, options);
  return this.each(function(i) {
    var trace = $(this).data('TraceRoute');
    if (trace == undefined) {
      trace = new TraceRoute(this, data, options);
      $(this).data('TraceRoute', trace);
    }
    else {
      trace.redraw(data, options);
    }
  });
};

// Defaults
$.fn.traceroute.defaults = {
  'tracerouteLength' : null,
  'drawArrows' : true,
  'append' : true,
  'link' : {
    'linkLength' : 45,
    'style' : {
      'lineWidth' : 5,
      'strokeStyle' : '#aaaaaa'
    }
  },
  'arrow' : {
    'arrowHeight' : 6,
    'arrowWidth' : 8,
    'style' : {
      'fillStyle' : '#666666'
    }
  },
  'hop' : {
    'extraMargin' : 6,
    'radius' : 8,
    'style' : {
      'strokeStyle' : '#0000ff',
      'fillStyle' : '#ffffff',
      'lineWidth' : 4
    }
  },
  'label' : {
    'width' : 50,
    'top_margin' : 4,
  }
};

// Traceroute constructor
function TraceRoute(el, data, options) {
  this.el = el;
  this.options = options;
  this.data = data;

  // Get traceroute length if not provided; we need it to size the canvas
  if (this.options.tracerouteLength || this.options.tracerouteLength < 1) {
    this.options.tracerouteLength = this.tracerouteLength();
  }

  // Initialize canvas
  this.initCanvas();

  // Create labels (need to create these first, to precalculate width)
  this.createLabels();

  // Draw traceroute
  this.drawTraceroute();

}

TraceRoute.prototype.createLabels = function() {
  for (var i = 0; i < this.data.length; i++) {
    var row = this.data[i];
  }
}

TraceRoute.prototype.initCanvas = function() {
  var o = this.options;

  // Create canvases
  var hopCanvas = document.createElement('canvas');
  var linkCanvas = document.createElement('canvas');

  // Create canvases for IE
  if ($.browser.msie) {
    hopCanvas = window.G_vmlCanvasManager.initElement(hopCanvas);
    linkCanvas = window.G_vmlCanvasManager.initElement(linkCanvas);
  }

  // Default "layer" CSS settings
  canvasCss = {
    'position' : 'absolute',
    'left' : 0,
    'top' : 0,
    'z-index' : 0,
  };

  // Layer canvases onto target
  $(linkCanvas).addClass('traceroute-links').css(canvasCss);
  $(hopCanvas).addClass('traceroute-links').css($.extend(canvasCss, {'z-index' : 1}));

  // Calculate constants
  this.hopRadius = o.hop.radius + (o.hop.style.lineWidth / 2);
  this.hopSize = this.hopRadius * 2;
  this.segmentLength = o.link.linkLength + this.hopSize;
  this.hopAsymOffset = this.hopSize + o.hop.extraMargin;

  linkCenter = (o.hop.radius / 2) + (o.link.style.lineWidth / 3);
  this.forwardLinkX = linkCenter;
  this.reverseLinkX = linkCenter + o.hop.radius;
  this.singleLinkX = this.hopRadius;

  // Set size for both canvases
  hopCanvas.height = linkCanvas.height = (this.hopSize * 2) + o.hop.extraMargin;
  hopCanvas.width = linkCanvas.width = (o.link.linkLength * (o.tracerouteLength - 1)) + (this.hopSize * o.tracerouteLength);

  // Position container
  //this.containerHeight = (o.label.hei * 2) + hopCanvas.width;
  this.containerHeight = hopCanvas.height;

  $(this.el).css({
    'position' : 'relative',
    'width' : hopCanvas.width,
    'height' : this.containerHeight + 'px'
  })
  .append(linkCanvas)
  .append(hopCanvas);

  // Provide canvases as part of traceroute object
  this.hopCanvas = hopCanvas;
  this.hopContext = hopCanvas.getContext('2d');
  this.linkCanvas = linkCanvas;
  this.linkContext = linkCanvas.getContext('2d');

}

// Calculate traceroute length
TraceRoute.prototype.tracerouteLength = function() {
  var count = 0;
  for (var i = 0; i < this.data.length; i++) {
    var row = this.data[i];
    if (row.match != undefined) {
      count += 1;
    }
    if (row.diff != undefined) {
      count += (row.diff.reverse.length > row.diff.forward.length) ? row.diff.reverse.length : row.diff.forward.length;
    }
  }
  return count;
}

// Draw traceroute chart
TraceRoute.prototype.drawTraceroute = function(traceroute) {
  var o = this.options;
  var extra_inc = 0;
  var old_row = false;
  var old_match_row = false;
  var last_match = {x : 0, y : 0};
  var last_reverse_diff_x = {x : 0, y : 0};
  var last_forward_diff_y = {x : 0, y : 0};

  for (var i = 0; i < this.data.length; i++) {
    var row = this.data[i];

    // Row contains matching hops
    if (row.match != undefined) {
      hopStyle = (row.hopStyle != undefined) ? row.hopStyle : o.hop.style;
      hopX = (this.segmentLength * (i + extra_inc)) + this.hopRadius;

      this.drawHop(hopX, this.hopRadius, o.hop.radius, hopStyle);

      // If an old row exists, draw backwards lines running to it
      if (old_row) {
        linkStyle = (row.linkStyle != undefined) ? row.linkStyle : o.link.style;
        arrowStyle = (row.arrowStyle != undefined) ? row.arrowStyle : o.arrow.style;

        // If the old row was another matching hop, just draw regular lines back
        if (old_row.match != undefined) {
          if (old_row.match.reverse != undefined) {
            this.drawSegment(last_match.x, this.forwardLinkX, hopX, this.forwardLinkX, linkStyle, arrowStyle);
            this.drawSegment(hopX, this.reverseLinkX, last_match.x, this.reverseLinkX, linkStyle, arrowStyle);
            
          } else {
            this.drawSegment(last_match.x, this.singleLinkX, hopX, this.singleLinkX, linkStyle, arrowStyle);
          }
        }

        // The old row had asymmetry, but contributed no hops in the reverse direction (a skip)
        if (old_row.diff != undefined && !old_row.diff.reverse.length) {
          this.drawSegment(last_forward_diff.x, this.forwardLinkX, hopX, this.forwardLinkX, linkStyle, arrowStyle);
          this.drawCurve(this.hopAsymOffset, this.reverseLinkX, hopX, last_match.y, linkStyle, arrowStyle);
        }

        // The old row contributed hops in the reverse direction
        /*if (old_row.diff != undefined && old_row.diff.reverse.length) {
          forwardY  = (last_forward_diff_y > last_match_y) ? last_forward_diff_y : last_match_y;
          this.drawSegment(this.forwardLinkX, forwardY, this.forwardLinkX, hopY, linkStyle, arrowStyle);
          this.drawSegment(this.hopRadius, hopY, this.hopAsymOffset, last_reverse_diff_y, linkStyle, arrowStyle);
        }*/

      }
      last_match.x = hopX;
      this.drawHopLabel(row.match.forward[0], hopX - (this.options.label.width / 2), this.hopSize + this.options.label.top_margin);
    }

    /*if (row.diff != undefined) {

      // Calculate position / segment length
      mostHops = (row.diff.forward.length > row.diff.reverse.length) ? 'forward' : 'reverse';
      leastHops = (row.diff.forward.length > row.diff.reverse.length) ? 'reverse' : 'forward';
      longestSegment = (o.link.linkLength * (row.diff[mostHops].length + 1)) + (this.hopSize * row.diff[mostHops].length);
      adjustedLinkLength = (longestSegment - (row.diff[leastHops].length * this.hopSize)) / (row.diff[leastHops].length + 1);
      adjustedSegmentHeight = adjustedLinkLength + this.hopSize;

      // Forward
      for (var j = 0; j < row.diff.forward.length; j++) {

        hop = row.diff.forward[j];
        hopStyle = (row.hopStyle != undefined) ? hop.hopStyle : o.hop.style;

        if (leastHops == 'forward') {
          lastHopY = last_match_y + (adjustedSegmentHeight * j);
          hopY = last_match_y + (adjustedSegmentHeight * (j + 1));
        }
        else {
          lastHopY = last_match_y + (this.segmentLength * j);
          hopY = last_match_y + (this.segmentLength * (j + 1));
        }
        last_forward_diff_y = hopY;

        this.drawHop(this.hopRadius, hopY, o.hop.radius, hopStyle);

        linkStyle = (hop.linkStyle != undefined) ? hop.linkStyle : o.link.style;
        arrowStyle = (hop.arrowStyle != undefined) ? hop.arrowStyle : o.arrow.style;
        this.drawSegment(this.forwardLinkX, lastHopY, this.forwardLinkX, hopY, linkStyle, arrowStyle);

        this.drawHopLabel(hop, 0, hopY - this.hopSize);
      }

      // Reverse
      for (var k = 0; k < row.diff.reverse.length; k++) {
        hop = row.diff.reverse[k];
        hopStyle = (row.hopStyle != undefined) ? hop.hopStyle : o.hop.style;
        linkStyle = (hop.linkStyle != undefined) ? hop.linkStyle : o.link.style;
        arrowStyle = (hop.arrowStyle != undefined) ? hop.arrowStyle : o.arrow.style;

        if (leastHops == 'reverse') {
          lastHopY = last_match_y + (adjustedSegmentHeight * k);
          hopY = last_match_y + (adjustedSegmentHeight * (k + 1));
        }
        else {
          lastHopY = last_match_y + (this.segmentLength * k);
          hopY = last_match_y + (this.segmentLength * (k + 1));
        }
        last_reverse_diff_y = hopY;

        this.drawHop(this.hopAsymOffset, hopY, o.hop.radius, hopStyle);
        this.drawHopLabel(hop, o.label.width + this.hopAsymOffset + this.hopSize, hopY - this.hopSize, 'right');

        if (k == 0) {
          this.drawSegment(this.hopAsymOffset, hopY, this.hopRadius, last_match_y, linkStyle, arrowStyle);
        } else {
          this.drawSegment(this.hopAsymOffset, hopY, this.hopAsymOffset, lastHopY, linkStyle, arrowStyle);
        }
      }

      // Set extra increment for next match
      if (j > 1 || k > 1) {
        extra_inc += (k > j) ? k - 1 : j - 1;
      }

    }*/

    // Save last row...
    old_row = row;
  }
}

TraceRoute.prototype.drawHop = function(x, y, r, options) {
  ctx = this.hopContext;
  ctx.save();
  ctx.translate(x, y);
  ctx.beginPath();
  ctx.arc(0, 0, r, 0, Math.PI*2, true);
  for (option in options) {
    ctx[option] = options[option];
  }
  ctx.closePath();
  ctx.fill();
  ctx.stroke();
  ctx.restore();
}

TraceRoute.prototype.drawCurve = function(x, xOffset, y1, y2, options, arrow_options) {
  ctx = this.linkContext;
  o = this.options;

  ctx.save();
  ctx.beginPath();
  ctx.moveTo(x, y1);
  ctx.bezierCurveTo(x + xOffset, y1, x + xOffset, y2, x, y2); 
  for (option in options) {
    ctx[option] = options[option];
  }
  ctx.stroke();
  ctx.restore();

  // Draw arrow on line
  ctx.save();
  arrowY = y1 + (o.arrow.arrowHeight / 2) + ((y2 - y1)/2);

  // Simplified version of Bezier algorithm, with t=0.5 (because we're positioning halfway)
  offset = (1.5*Math.pow((0.5), 2)*xOffset) + (1.5*Math.pow(0.5,2)*xOffset) + x;

  arrowStartX = offset - (o.arrow.arrowWidth / 2);
  arrowEndX = offset + (o.arrow.arrowWidth / 2);
  ctx.beginPath();
  ctx.moveTo(arrowStartX, arrowY);
  ctx.lineTo(arrowEndX, arrowY);
  ctx.lineTo(offset, arrowY - o.arrow.arrowHeight);
  for (option in arrow_options) {
    ctx[option] = arrow_options[option];
  }
  ctx.fill();
  ctx.restore();

}

TraceRoute.prototype.drawSegment = function(x1, y1, x2, y2, options, arrow_options) {
  ctx = this.linkContext;
  o = this.options; // Needed for arrow drawing

  ctx.save();

  // Draw line
  ctx.beginPath();
  ctx.moveTo(x1, y1);
  ctx.lineTo(x2, y2);
  for (option in options) {
    ctx[option] = options[option];
  }
  ctx.stroke();

  if (arrow_options != undefined) {
    arrowX = o.arrow.arrowWidth / 2;
    deltaY = y2 - y1;
    deltaX = x2 - x1;

    ctx.translate(x1, y1);

    rotation = (2 * Math.PI) - Math.tan(deltaX/deltaY);
    // NaN in horizontal case
    if (rotation) {
      ctx.rotate(rotation);
    }

    hypotenuse = Math.sqrt(Math.pow(deltaY, 2) + Math.pow(deltaX, 2));
    ctx.beginPath();

    // @TODO Draw arrows for diagonal lines
    if (deltaX === 0) {

      // "Forward" traceroutes
      if (deltaY > 0) {
        arrowY = (hypotenuse / 2) - (o.arrow.arrowHeight / 2);
        ctx.moveTo(-arrowX, arrowY);
        ctx.lineTo(arrowX, arrowY);
        ctx.lineTo(0, arrowY + o.arrow.arrowHeight);
      }
      else {
        arrowY = (-hypotenuse / 2) + (o.arrow.arrowHeight / 2);
        ctx.moveTo(-arrowX, arrowY);
        ctx.lineTo(arrowX, arrowY);
        ctx.lineTo(0, arrowY - o.arrow.arrowHeight);
      }

      for (option in arrow_options) {
        ctx[option] = arrow_options[option];
      }

    }

    ctx.fill();

  }
  ctx.restore();
}

TraceRoute.prototype.drawHopLabel = function(hop, x, y, align) {
  var o = this.options;

  label = '<div class="trace-label" id="trace-hop-label-' + hop.id + '" hopid="' + hop.id + '">';
  label += hop.hub;
  label += '</div>';
  label = $(label);

  //if (hop_data.data) {
  //  label.addClass('has-chart');
  //}

  label_width = o.label.width;
  css = {
    'z-index' : 50,
    'width' : label_width + 'px',
    'position' : 'absolute',
    'left' : x,
    'top' : y,
    'text-align' : 'center',
  };
  label.css(css);
  $(this.el).append(label);

  // Attach label behavior
  this.hopBehavior(label);
}

// @TODO Provide generic behavior and override elsewhere
TraceRoute.prototype.hopBehavior = function(el) {
  $(el).hover(function() {
    var hopid = $(this).attr('hopid');
    var hop = Drupal.settings.ecenterNetwork.seriesLookupByID[hopid];
    var tc = $('#utilization-tables').data('tablechart');
    var lh = tc['default'].chart.plugins.linehighlighter;
    lh.highlightSeries(hop.sidx, tc['default'].chart);

    var length = tc['default'].chart.seriesColors.length;
    var sidx = hop.sidx % length;
    var background_color = tc['default'].chart.seriesColors[sidx];

    $(this)
      .addClass('highlight')
      .css({'background-color' : background_color });

    var ol = $('#openlayers-map-auto-id-0').data('openlayers');
    var map = ol.openlayers;
    var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop(); 
    var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
    var feature = layer.getFeatureBy('ecenterID', hop.hub);
    
    control.callbacks.over.call(control, feature);

  }, function() {
    var hopid = $(this).attr('hopid');
    var hop = Drupal.settings.ecenterNetwork.seriesLookupByID[hopid];
    var tc = $('#utilization-tables').data('tablechart');
    var lh = tc['default'].chart.plugins.linehighlighter;
    lh.unhighlightSeries(hop.sidx, tc['default'].chart);

    $(this)
      .removeClass('highlight')
      .css({'background-color' : 'transparent'});
    
    var ol = $('#openlayers-map-auto-id-0').data('openlayers');
    var map = ol.openlayers;
    var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop(); 
    var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
    var feature = layer.getFeatureBy('ecenterID', hop.hub);
    
    control.callbacks.out.call(control, feature);
  });
}

// @TODO: DRY violation
TraceRoute.prototype.redraw = function(data, options) {
  this.options = options;
  this.data = data;

  $(this.hopCanvas).remove();
  $(this.linkCanvas).remove();

  // @TODO not really generic
  $('.trace-label', this.el).remove();

  // Get traceroute length if not provided; we need it to size the canvas
  if (this.options.tracerouteLength || this.options.tracerouteLength < 1) {
    this.options.tracerouteLength = this.tracerouteLength();
  }

  // Initialize canvas
  this.initCanvas();

  // Draw traceroute
  this.drawTraceroute();
}

})(jQuery);
