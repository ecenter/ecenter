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
    }
    else {
      //trace.redraw(data);
    }
  });
};

// Defaults
$.fn.traceroute.defaults = {
  'tracerouteLength' : null,
  'link' : {
    'linkLength' : 18,
    'style' : {
      'lineWidth' : 4,
      'strokeStyle' : '#555555',
    }
  },
  'arrow' : {
    'arrowHeight' : 8,
    'arrowWidth' : 8,
    'style' : {
      'fillStyle' : '#000000'
    }
  },
  'hop' : {
    'extraMargin' : 20,
    'radius' : 9,
    'style' : {
      'strokeStyle' : '#0000ff',
      'fillStyle' : '#ffffff',
      'lineWidth' : 4
    }
  },
  'label' : {
    'width' : 120,
    'side_padding' : 6,
    'top_padding' : 12,
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

  // Draw traceroute
  this.drawTraceroute();

  // Save
  $(this.el).data('TraceRoute', this);

  return this;
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
 
  // Set size for both canvases
  hopCanvas.width = linkCanvas.width = (this.hopSize * 2) + o.hop.extraMargin;
  hopCanvas.height = linkCanvas.height = (o.link.linkLength * (o.tracerouteLength - 1)) + (this.hopSize * o.tracerouteLength);

  // Position container
  container_width = (o.label.width * 2) + hopCanvas.width;
  $(this.el).css({
    'position' : 'relative',
    'height' : hopCanvas.height,
    'width' : container_width + 'px'
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
  var last_diff_y = 0;

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

        // Always draw forward segment back to previous hop
        this.drawSegment(this.forwardLinkX, hopY, -this.segmentHeight, 0, linkStyle, arrowStyle);

        // If the old row was another matching hop, just draw regular lines back
        if (old_row.match != undefined) {
          this.drawSegment(this.reverseLinkX, hopY, -this.segmentHeight, 0, linkStyle, arrowStyle, 'reverse');
        }

        // The old row had asymmetry, draw a segment back to the last asymmetrical hop
        if (old_row.diff != undefined && last_diff_y) {
          segment = hopY - last_diff_y;
          segmentLength = Math.sqrt((segment * segment) + (o.hop.extraMargin * o.hop.extraMargin));
          rotation = Math.tan((o.hop.extraMargin + this.forwardLinkX) / segment); 
          this.drawSegment(this.reverseLinkX, hopY, -segmentLength, rotation, linkStyle, arrowStyle, 'reverse');
        }

        // The old row had asymmetry, but contributed no hops
        if (old_row.diff != undefined && !last_diff_y) {
          this.drawCurve(this.reverseLinkX, this.reverseLinkX + o.hop.extraMargin, last_match_y, hopY, linkStyle, arrowStyle);
        }

      }
      last_match_y = hopY;
      this.drawHopLabel(row.match.forward.hop, 0, hopY - this.hopSize);
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
          hopY = last_match_y + (adjustedSegmentHeight * (j + 1));
          link_height = adjustedSegmentHeight;
        }
        else {
          hopY = last_match_y + (this.segmentHeight * (j + 1));
          link_height = this.segmentHeight;
        }

        this.drawHop(this.hopRadius, hopY, o.hop.radius, hopStyle);

        linkStyle = (hop.linkStyle != undefined) ? hop.linkStyle : o.link.style;
        arrowStyle = (hop.arrowStyle != undefined) ? hop.arrowStyle : o.arrow.style;
        this.drawSegment(this.forwardLinkX, hopY, -link_height, 0, linkStyle, arrowStyle);

        this.drawHopLabel(hop.hop, 0, hopY - this.hopSize);

      }

      // Reverse
      for (var k = 0; k < row.diff.reverse.length; k++) {
        hop = row.diff.reverse[k];
        hopStyle = (row.hopStyle != undefined) ? hop.hopStyle : o.hop.style;
        linkStyle = (hop.linkStyle != undefined) ? hop.linkStyle : o.link.style;
        arrowStyle = (hop.arrowStyle != undefined) ? hop.arrowStyle : o.arrow.style;

        if (leastHops == 'reverse') {
          hopY = last_match_y + (adjustedSegmentHeight * (k + 1));
        }
        else {
          hopY = last_match_y + (this.segmentHeight * (k + 1));
        }
        last_diff_y = hopY;

        this.drawHop(this.hopAsymOffset, hopY, o.hop.radius, hopStyle);
        this.drawHopLabel(hop.hop, o.label.width + this.hopAsymOffset + this.hopSize, hopY - this.hopSize, 'right');

        // Every asymetrical hop will have a line back to a match
        segment = hopY - last_match_y;
        segmentLength = Math.sqrt((segment * segment) + (o.hop.extraMargin * o.hop.extraMargin));
        rotation = (2 * Math.PI) - Math.tan((o.hop.extraMargin + this.forwardLinkX) / segment); 
        this.drawSegment(this.hopAsymOffset, hopY, -segmentLength, rotation, linkStyle, arrowStyle, 'reverse');
      }

      if (!row.diff.reverse.length) {
        last_diff_y = 0;
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

  /*arrowY = (h / 2) + (o.arrow.arrowHeight / 2);
  ctx.moveTo(-arrowX, arrowY);
  ctx.lineTo(arrowX, arrowY);
  ctx.lineTo(0, arrowY - o.arrow.arrowHeight);*/

  // Draw arrow on line
  ctx.save();
  arrowY = y1 + (o.arrow.arrowHeight / 2) + ((y2 - y1)/2);
  offset = xOffset + (x/2.5);
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


TraceRoute.prototype.drawSegment = function(x, y, h, rotation, options, arrow_options, direction) {
  ctx = this.linkContext;
  o = this.options; // Needed for arrow drawing

  ctx.save();

  // Draw line
  ctx.beginPath();
  ctx.translate(x, y);
  ctx.rotate(rotation);
  ctx.lineTo(0, 0);
  ctx.lineTo(0, h);
  for (option in options) {
    ctx[option] = options[option];
  }
  ctx.stroke();
  ctx.fill();

  // Draw arrow on line
  ctx.beginPath();
  arrowX = o.arrow.arrowWidth / 2;
  
  if (direction == 'reverse') {
    arrowY = (h / 2) + (o.arrow.arrowHeight / 2);
    ctx.moveTo(-arrowX, arrowY);
    ctx.lineTo(arrowX, arrowY);
    ctx.lineTo(0, arrowY - o.arrow.arrowHeight);
  } else {
    arrowY = (h / 2) - (o.arrow.arrowHeight / 2);
    ctx.moveTo(-arrowX, arrowY);
    ctx.lineTo(arrowX, arrowY);
    ctx.lineTo(0, arrowY + o.arrow.arrowHeight);
  }

  for (option in arrow_options) {
    ctx[option] = arrow_options[option];
  }
  ctx.fill();

  ctx.restore();
  
}

TraceRoute.prototype.drawHopLabel = function(hop, x, y, align) {
  var o = this.options;
  label = $('<div class="label">' + hop.hop_id + ' (' + hop.hop_ip + ')</div>');
  label_width = o.label.width - o.label.side_padding;
  css = {
    'width' : label_width + 'px',
    'position' : 'absolute',
    'padding-top' : o.label.top_padding + 'px',
    'left' : x,
    'top' : y,
    'font-size' : o.label.font_size,
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
}

})(jQuery);
