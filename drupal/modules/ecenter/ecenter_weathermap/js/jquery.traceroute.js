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
  'tracerouteLength' : NULL, // Set this to require traceRoute 
  'link' : {
    'linkLength' : 12,
    'style' : { 
      'fillStyle' : '#555555',
     }
  }
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
      'strokeStyle' : '#555555',
      'fillStyle' : '#ffffff',
      'shadowOffsetX' : 3,
      'shadowOffsetY' : 3,
      'shadowBlur' : 1,
      'shadowColor' : '#000000',
      'lineWidth' : 4
    }
  }
};

// Traceroute constructor
function TraceRoute(el, data, options) {
  this.el = el;
  this.options = options;
  this.data = data;

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

  var canv = document.createElement('canvas');
  $(canv).addClass('traceroute-graph');
  $(this.el).append(canv);
  if ($.browser.msie) {
    canv = window.G_vmlCanvasManager.initElement(canv);
  }

  this.segmentHeightInc = ((o.hopRadius * 2) + o.hopStrokeWidth) + o.linkLength;
  this.hopX = this.hopHeightInc = o.hopRadius + (o.hopStrokeWidth / 2);
  this.hopAsymX = this.hopX + o.extraHopMargin;
  this.segmentH = o.linkLength + (2 * o.hopRadius);
  
  cvWidth = ((o.hopRadius * 2) + o.hopStrokeWidth) + o.extraHopMargin;
  cvHeight = this.segmentHeightInc * this.maxLength

  canv.width = cvWidth;
  canv.height = cvHeight;

  this.cv = canv;
  this.ctx = canv.getContext('2d');
}

TraceRoute.prototype.drawTraceroute = function(traceroute) {
  var o = this.options;
  var canvas_height = 0;

  var extraInc = 0;

  for (var i = 0; i < this.data.length; i++) {

    var row = this.data[i];

    if (row.match != undefined) {
      var hopY = (this.segmentHeightInc * (i + extraInc)) + this.hopHeightInc;

      if (i < this.data.length - 1) {
        this.drawSegment(5, hopY, o.linkWidth, this.segmentH, '#bbbbbb');
      }

      this.drawHop(this.hopX, hopY, o.hopRadius, o.hopStrokeWidth, o.hopStrokeColor, o.hopFillColor);
    }

    if (row.diff != undefined) {
      for (var j = 0; j < row.diff.forward.length; j++) {
        var hopY = (this.segmentHeightInc * (i + j)) + this.hopHeightInc;
        this.drawSegment(5, hopY, o.linkWidth, this.segmentH, '#bbbbbb');
        this.drawHop(this.hopX, hopY, o.hopRadius, o.hopStrokeWidth, o.hopStrokeColor, o.hopFillColor);
      }
      for (var k = 0; k < row.diff.reverse.length; k++) {
        var hopY = (this.segmentHeightInc * (i + k)) + this.hopHeightInc;
        this.drawHop(this.hopAsymX, hopY, o.hopRadius, o.hopStrokeWidth, o.hopStrokeColor, o.hopFillColor);
      }
      if (j > 1 || k > 1) {
        extraInc = (k > j) ? k - 1 : j - 1; 
      } else {
        extraInc = 0;
      }
    }

  }

}

TraceRoute.prototype.drawHop = function(x, y, r, options) {
  this.ctx.beginPath();
  this.ctx.arc(x, y, r, 0, Math.PI*2, true);
  for (option in options) {
    this.ctx[option] = options[option];
  }
  this.ctx.closePath();
  this.ctx.fill();
  this.ctx.stroke();
}

TraceRoute.prototype.drawSegment = function(x, y, w, h, options) {
  this.ctx.beginPath();
  this.ctx.rect(x,y,w,h);
  for (option in options) {
    this.ctx[option] = options[option];
  }
  this.ctx.closePath();
  this.ctx.fill();
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

