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
  'tracerouteLength' : null, // Set this to require traceRoute 
  'link' : {
    'linkLength' : 12,
    'linkWidth' : 4,
    'style' : { 
      'fillStyle' : '#555555',
     }
  },
  'arrow' : {
    'size' : 6,
    'style' : {
      'fillStyle' : '#555555',
    }
  },
  'hop' : {
    'extraMargin' : 30,
    'radius' : 9,
    'style' : {
      'strokeStyle' : '#0000ff',
      'fillStyle' : '#ffffff',
      'lineWidth' : 4,
      //'shadowOffsetX' : 1,
      //'shadowOffsetY' : 1,
      //'shadowBlur' : 3,
      //'shadowColor' : '#555555',
    }
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

  // Position container
  $(this.el).css({
    'position' : 'relative',
  });

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
  this.hopX = this.hopHeightInc = o.hop.radius + (o.hop.style.lineWidth / 2);
  this.hopAsymX = this.hopX + o.hop.extraMargin;
  this.segmentHeightInc = o.link.linkLength + o.hop.radius;

  linkCenter = (o.hop.radius / 2) - (o.link.linkWidth / 3);
  this.forwardLinkX = Math.ceil(linkCenter);
  this.reverseLinkX = Math.floor(linkCenter + o.hop.radius);
  this.singleLinkX = o.hop.radius - (o.link.linkWidth / 3);
 
  // Set size for both canvases
  hopCanvas.width = linkCanvas.width = ((o.hop.radius * 2) + o.hop.style.lineWidth) + o.hop.extraMargin;
  hopCanvas.height = linkCanvas.height = this.segmentHeightInc * o.tracerouteLength

  $(this.el).css({
    'position' : 'relative',
    'height' : hopCanvas.height,
    'width' : hopCanvas.width,
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
  var extraInc = 0;
  var old_row = false;

  for (var i = 0; i < this.data.length; i++) {

    var row = this.data[i];

    if (row.match != undefined) {
      hopY = (this.segmentHeightInc * (i + extraInc));
      hopStyle = (row.hopStyle != undefined) ? row.hopStyle : o.hop.style;
      this.drawHop(this.hopX, hopY, o.hop.radius, hopStyle);

      if (old_row && old_row.match != undefined) {
        var linkStyle = (row.linkStyle != undefined) ? row.linkStyle : o.link.style;
        linkY = hopY - (this.segmentHeightInc);
        this.drawSegment(this.forwardLinkX, hopY, o.link.linkWidth, this.segmentHeightInc, 0, linkStyle);
        this.drawSegment(this.reverseLinkX, hopY, o.link.linkWidth, this.segmentHeightInc, 0, linkStyle);
      }
    }

    if (row.diff != undefined) {

      // A little convoluted?
      longestSegment = (row.diff.forward.length > row.diff.reverse.length) ? 'forward' : 'reverse';
      shortestSegment = (row.diff.forward.length > row.diff.reverse.length) ? 'reverse' : 'forward';
      longestSegmentLength = (row.diff[longestSegment].length * this.segmentH);
      shortSegmentLength = (longestSegmentLength - (row.diff[shortestSegment].length * ((o.hop.radius * 2) - 1))) / row.diff[shortestSegment].length;

      


      for (var j = 0; j < row.diff.forward.length; j++) {
        hop = row.diff.forward[j];
        hopStyle = (row.hopStyle != undefined) ? hop.hopStyle : o.hop.style;

        if (shortestSegment == 'forward') {
          var hopY = ((this.segmentHeightInc * i) + this.hopHeightInc) + shortSegmentLength;
        } else {
          var hopY = (this.segmentHeightInc * (i + j)) + this.hopHeightInc;
        }

        this.drawHop(this.hopX, hopY, o.hop.radius, hopStyle);
        //this.drawSegment(this.singleLinkX, hopY, o.link.linkWidth, this.segmentH, 0, linkStyle);
      }

      for (var k = 0; k < row.diff.reverse.length; k++) {
        hop = row.diff.reverse[k];
        hopStyle = (row.hopStyle != undefined) ? hop.hopStyle : o.hop.style;

        if (shortestSegment == 'reverse') {
          var hopY = ((this.segmentHeightInc * i) + this.hopHeightInc) + shortSegmentLength;
        } else {
          var hopY = (this.segmentHeightInc * (i + j)) + this.hopHeightInc;
        }

        this.drawHop(this.hopAsymX, hopY, o.hop.radius, hopStyle);
      }

      if (j > 1 || k > 1) {
        extraInc = (k > j) ? k - 1 : j - 1; 
      } else {
        extraInc = 0;
      }

    }

    // Save last row...
    old_row = row;
  }
}

TraceRoute.prototype.drawHop = function(x, y, r, options) {
  ctx = this.hopContext;
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI*2, true);
  for (option in options) {
    ctx[option] = options[option];
  }
  ctx.closePath();
  ctx.fill();
  ctx.stroke();
}

TraceRoute.prototype.drawSegment = function(x, y, w, h, rotation, options) {
  ctx = this.linkContext;
  ctx.beginPath();
  ctx.rect(x,y,w,h);
  for (option in options) {
    ctx[option] = options[option];
  }
  ctx.closePath();
  ctx.fill();
}

})(jQuery);

/*
  var cv = $(this.cv);
  var ctx = this.ctx;

  // Set canvas size
  var num_hops = this.hops.size();
  var cv_height = (num_hops * ((options.hopRadius * 2) + options.hopStrokeWidth)) + (options.linkLength * (num_hops - 1));
  var cv_width = (options.hopRadius * 2) + options.hopStrokeWidth;
  cv.attr('width', cv_width).attr('height', cv_height);
  cv.css('position', 'absolute');

  this.drawHop(5, 5, 10, 4, '#000000', '#cccccc');


  // Some calculations
  var width = cv_width + options.labelWidth + options.labelMargin;

  // Initialize container
  var container = $('<div class="traceroute-graph-wrapper">');
  console.log(container);
  container.css('position', 'relative');
  //container.height(cv_height).width(width);

  // Initialize label container
  var label_container = $('<div class="traceroute-labels">');
  label_container.css('position', 'absolute');
  label_container.css('left', 0);
  //label_container.height(cv_height).width(width);

  container.append(cv).append(label_container);

  if (options.labelLocation == 'left') {
    cv.css('right', 0);
    label_container.addClass('labels-left');
    var label_css = {'padding-right': cv_width + options.labelMargin};
  } else {
    cv.css('left', 0);
    label_container.addClass('labels-right');
    var label_css = {'padding-left': cv_width + options.labelMargin};
  }

  var segment_x = options.hopRadius + (options.hopStrokeWidth / 2) - (options.linkWidth / 2);
  var hop_x = options.hopRadius + (options.hopStrokeWidth / 2);
  var segment_h = options.linkLength + (2 * options.hopRadius);

  var trace = this;

  this.hops.each(function(i) {
    var hop_y = (((options.hopRadius * 2) + options.hopStrokeWidth + options.linkLength) * i) + options.hopRadius + (options.hopStrokeWidth / 2);
    if (i < (num_hops - 1)) {
      trace.drawSegment(segment_x, hop_y, options.linkWidth, segment_h, '#bbbbbb');
    }
    trace.drawHop(hop_x, hop_y, options.hopRadius, options.hopStrokeWidth, options.hopStrokeColor, options.hopFillColor);

    var label_y = (((options.hopRadius * 2) + options.hopStrokeWidth + options.linkLength) * i);
    var name = $('.' + options.nameClass, this).text()

    var label_wrapper = $('<div class="traceroute-label-wrapper">');
    var label = $('<div class="traceroute-label">');
    label.text(name);
    label_wrapper.append(label);
    label_wrapper.width(options.labelWidth);
    label_wrapper.css(label_css);
    label_wrapper.css({'position' : 'absolute', 'top' : label_y});
    label_container.append(label_wrapper);
    label_wrapper.append(this);
    label_wrapper.data('HopData', this);

    // Replace with better hover
    label.hover(function() {
      hopdata = label.data('HopData');
      $(hopdata).css({
        'position': 'absolute',
        'top': 450,
        'left': 300,
        'z-index': 10,
        'background-color': '#ffffff'
      });
      $(hopdata).show();
    }, function() {
      hopdata = label.data('HopData');
      $(hopdata).hide();
    });

  });

*/
  // Set canvas size
  /*var num_hops = this.hops.size();
  var cv_height = (num_hops * ((options.hopRadius * 2) + options.hopStrokeWidth)) + (options.linkLength * (num_hops - 1));
  var cv_width = (options.hopRadius * 2) + options.hopStrokeWidth;
  cv.attr('width', cv_width).attr('height', cv_height);
  cv.css('position', 'absolute');

  this.drawHop(5, 5, 10, 4, '#000000', '#cccccc');


  // Some calculations
  var width = cv_width + options.labelWidth + options.labelMargin;

  // Initialize container
  var container = $('<div class="traceroute-graph-wrapper">');
  console.log(container);
  container.css('position', 'relative');
  //container.height(cv_height).width(width);

  // Initialize label container
  var label_container = $('<div class="traceroute-labels">');
  label_container.css('position', 'absolute');
  label_container.css('left', 0);
  //label_container.height(cv_height).width(width);

  container.append(cv).append(label_container);

  if (options.labelLocation == 'left') {
    cv.css('right', 0);
    label_container.addClass('labels-left');
    var label_css = {'padding-right': cv_width + options.labelMargin};
  } else {
    cv.css('left', 0);
    label_container.addClass('labels-right');
    var label_css = {'padding-left': cv_width + options.labelMargin};
  }

  var segment_x = options.hopRadius + (options.hopStrokeWidth / 2) - (options.linkWidth / 2);
  var hop_x = options.hopRadius + (options.hopStrokeWidth / 2);
  var segment_h = options.linkLength + (2 * options.hopRadius);

  var trace = this;

  this.hops.each(function(i) {
    var hop_y = (((options.hopRadius * 2) + options.hopStrokeWidth + options.linkLength) * i) + options.hopRadius + (options.hopStrokeWidth / 2);
    if (i < (num_hops - 1)) {
      trace.drawSegment(segment_x, hop_y, options.linkWidth, segment_h, '#bbbbbb');
    }
    trace.drawHop(hop_x, hop_y, options.hopRadius, options.hopStrokeWidth, options.hopStrokeColor, options.hopFillColor);

    var label_y = (((options.hopRadius * 2) + options.hopStrokeWidth + options.linkLength) * i);
    var name = $('.' + options.nameClass, this).text()

    var label_wrapper = $('<div class="traceroute-label-wrapper">');
    var label = $('<div class="traceroute-label">');
    label.text(name);
    label_wrapper.append(label);
    label_wrapper.width(options.labelWidth);
    label_wrapper.css(label_css);
    label_wrapper.css({'position' : 'absolute', 'top' : label_y});
    label_container.append(label_wrapper);
    label_wrapper.append(this);
    label_wrapper.data('HopData', this);

    // Replace with better hover
    label.hover(function() {
      hopdata = label.data('HopData');
      $(hopdata).css({
        'position': 'absolute',
        'top': 450,
        'left': 300,
        'z-index': 10,
        'background-color': '#ffffff'
      });
      $(hopdata).show();
    }, function() {
      hopdata = label.data('HopData');
      $(hopdata).hide();
    });

  });*/

