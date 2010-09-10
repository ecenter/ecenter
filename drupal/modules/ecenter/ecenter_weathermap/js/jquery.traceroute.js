// jQuery plugin to create a "subway map" of a traceroute

/**

This plugin takes a specially formed array and turns it into a traceroute
"subway map".

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
    'linkLength' : 28,
    'style' : {
      'lineWidth' : 4,
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
    'extraMargin' : 30,
    'radius' : 8,
    'style' : {
      'strokeStyle' : '#0000ff',
      'fillStyle' : '#ffffff',
      'lineWidth' : 3
    }
  },
  'label' : {
    'width' : 180,
    'side_padding' : 6,
    'top_padding' : 9,
    'font_size' : '11px'
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
    //console.log(row);
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
    'left' : o.label.width,
    'top' : 0,
    'z-index' : 0,
  };

  // Layer canvases onto target
  $(linkCanvas).addClass('traceroute-links').css(canvasCss);
  $(hopCanvas).addClass('traceroute-links').css($.extend(canvasCss, {'z-index' : 1}));

  // Calculate constants
  this.hopRadius = o.hop.radius + (o.hop.style.lineWidth / 2);
  this.hopSize = this.hopRadius * 2;
  this.segmentHeight = o.link.linkLength + this.hopSize;
  this.hopAsymOffset = this.hopSize + o.hop.extraMargin;

  linkCenter = (o.hop.radius / 2) + (o.link.style.lineWidth / 3);
  this.forwardLinkX = linkCenter;
  this.reverseLinkX = linkCenter + o.hop.radius;
  this.singleLinkX = this.hopRadius;

  // Set size for both canvases
  hopCanvas.width = linkCanvas.width = (this.hopSize * 2) + o.hop.extraMargin;
  hopCanvas.height = linkCanvas.height = (o.link.linkLength * (o.tracerouteLength - 1)) + (this.hopSize * o.tracerouteLength);

  // Position container
  this.containerWidth = (o.label.width * 2) + hopCanvas.width;

  $(this.el).css({
    'position' : 'relative',
    'height' : hopCanvas.height,
    'width' : this.containerWidth + 'px'
  }).append(linkCanvas).append(hopCanvas);

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
  var last_match_y = 0;
  var last_reverse_diff_y = 0;
  var last_forward_diff_y = 0;

  for (var i = 0; i < this.data.length; i++) {
    var row = this.data[i];

    // Row contains matching hops
    if (row.match != undefined) {
      hopStyle = (row.hopStyle != undefined) ? row.hopStyle : o.hop.style;
      hopY = (this.segmentHeight * (i + extra_inc)) + this.hopRadius;

      this.drawHop(this.hopRadius, hopY, o.hop.radius, hopStyle);

      // If an old row exists, draw backwards lines running to it
      if (old_row) {
        linkStyle = (row.linkStyle != undefined) ? row.linkStyle : o.link.style;
        arrowStyle = (row.arrowStyle != undefined) ? row.arrowStyle : o.arrow.style;

        // If the old row was another matching hop, just draw regular lines back
        if (old_row.match != undefined) {
          if (old_row.match.reverse != undefined) {
            this.drawSegment(this.forwardLinkX, last_match_y, this.forwardLinkX, hopY, linkStyle, arrowStyle);
            this.drawSegment(this.reverseLinkX, hopY, this.reverseLinkX, last_match_y, linkStyle, arrowStyle);
          } else {
            this.drawSegment(this.singleLinkX, last_match_y, this.singleLinkX, hopY, linkStyle, arrowStyle);
          }
        }

        // The old row had asymmetry, but contributed no hops in the reverse direction (a skip)
        if (old_row.diff != undefined && !old_row.diff.reverse.length) {
          this.drawSegment(this.forwardLinkX, last_forward_diff_y, this.forwardLinkX, hopY, linkStyle, arrowStyle);
          this.drawCurve(this.reverseLinkX, this.hopAsymOffset, last_match_y, hopY, linkStyle, arrowStyle);
        }

        // The old row contributed hops in the reverse direction
        if (old_row.diff != undefined && old_row.diff.reverse.length) {
          this.drawSegment(this.forwardLinkX, last_forward_diff_y, this.forwardLinkX, hopY, linkStyle, arrowStyle);
          this.drawSegment(this.hopRadius, hopY, this.hopAsymOffset, last_reverse_diff_y, linkStyle, arrowStyle);
        }

      }
      last_match_y = hopY;

      this.drawHopLabel(row.match.forward[0], 0, hopY - this.hopSize);
    }

    if (row.diff != undefined) {

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
          lastHopY = last_match_y + (this.segmentHeight * j);
          hopY = last_match_y + (this.segmentHeight * (j + 1));
        }
        last_forward_diff_y = hopY;

        this.drawHop(this.hopRadius, hopY, o.hop.radius, hopStyle);

        linkStyle = (hop.linkStyle != undefined) ? hop.linkStyle : o.link.style;
        arrowStyle = (hop.arrowStyle != undefined) ? hop.arrowStyle : o.arrow.style;
        this.drawSegment(this.forwardLinkX, lastHopY, this.forwardLinkX, hopY, linkStyle, arrowStyle);

        //console.log(hop);
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
          lastHopY = last_match_y + (this.segmentHeight * k);
          hopY = last_match_y + (this.segmentHeight * (k + 1));
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

    }

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
    ctx.rotate(rotation);

    hypotenuse = Math.sqrt(Math.pow(deltaY, 2) + Math.pow(deltaX, 2));
    ctx.beginPath();

    //console.log(rotation % Math.PI);
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

TraceRoute.prototype.drawHopLabel = function(hop_data, x, y, align) {
  var o = this.options;

  label = '<div class="trace-label" hopid="' + hop_data.hop.hop_id + '">';
  label += (hop_data.hop.nodename) ? '<div class="hostname">' + hop_data.hop.nodename + '</div>' : '';
  label += '<div class="hop-secondary">';
  label += '<span class="hop-ip">' + hop_data.hop.hop_ip + '</span>';
  label += (hop_data.hop.hub) ? ' <span class="hop-hub">(' + hop_data.hop.hub + ')</span>' : '';
  label += '</div>';
  label = $(label);

  if (hop_data.data) {
    label.addClass('has-chart');
  }
  label_width = o.label.width - o.label.side_padding;
  css = {
    'width' : label_width + 'px',
    'position' : 'absolute',
    //'padding-top' : o.label.top_padding + 'px',
    'left' : x,
    'top' : y,
    //'font-size' : o.label.font_size,
  };
  if (align == 'right') {
    $.extend(css, {
      'padding-left' : o.label.side_padding + 'px',
      'text-align' : 'left'
    });
  } else {
    $.extend(css, {
      'padding-right' : o.label.side_padding + 'px',
      'text-align' : 'right'
    });
  }

  label.css(css);
  $(this.el).append(label);

  // Attach label behavior
  this.hopBehavior(label);
}

TraceRoute.prototype.hopBehavior = function(el) {
  var offset = $(this.el).offset();
  var containerWidth = this.containerWidth;
  el.hover(function() {
    hopid = $(this).attr('hopid');
    container = $('#hop-' + hopid);
    container.css({
      'position' : 'absolute',
      'z-index' : 1,
      'left' : containerWidth,
      'top' : offset.top
    });
    chart = container.data('TableChart');
    if (chart) {
      container.fadeIn('fast');
      $('.tablechart', container).show();
      chart.draw();
    }
    //console.log($('.tablecontainer', container));
    //console.log($('.tablecontainer', container).data('TableChart'));
  }, function() {
    hopid = $(this).attr('hopid');
    container = $('#hop-' + hopid);
    container.fadeOut('fast');
  });
}

// @TODO: DRY violation
TraceRoute.prototype.redraw = function(data, options) {
  this.options = options;
  this.data = data;

  $(this.hopCanvas).remove();
  $(this.linkCanvas).remove();

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
