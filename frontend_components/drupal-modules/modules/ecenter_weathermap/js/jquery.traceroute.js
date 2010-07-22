// jQuery plugin to create a "subway map" of a traceroute
(function($) {

$.fn.traceroute = function(options) {
  var opt = $.extend(true, {}, $.fn.traceroute.defaults, options);

  return this.each(function(i) {
    trace = new TraceRoute(this, opt);
  });

};

// Defaults
$.fn.traceroute.defaults = {
  'linkLength' : 12,
  'linkWidth' : 9,
  'linkColor' : '#cccccc',
  'hopRadius' : 6,
  'labelLocation' : 'right', // 'left',
  'labelWidth' : 200,
  'labelMargin' : 5,
  'hopStrokeColor' : '#555555',
  'hopFillColor' : '#ffffff',
  'hopStrokeWidth' : 4,
  'wrapperClass' : 'hop-wrapper',
  'infoClass' : 'hop-info',
  'nameClass' : 'hop-name',
  'dataClass' : 'hop-data'
};

// Traceroute constructor
function TraceRoute(el, options) {
  var trace = this;
  var options = this.options = options;
  this.el = el;

  // Get individual hops
  var hops = this.hops = $('.' + options.wrapperClass, el);
  hops.hide();
  var num_hops = this.hops.size();

  var canv = document.createElement('canvas');
  // borrowed from flot by Ole Laursen
  if ($.browser.msie) {
    window.G_vmlCanvasManager.init_(document);
    canv = window.G_vmlCanvasManager.initElement(canv);
  }

  // Initialize canvas
  //var cv = this.cv = $('<canvas class="traceroute-graph">');

  var cv = $(canv);
  cv.addClass('traceroute-graph');
  var ctx = this.ctx = cv.get(0).getContext('2d');

  // Set canvas size
  var cv_height = (num_hops * ((options.hopRadius * 2) + options.hopStrokeWidth)) + (options.linkLength * (num_hops - 1));
  var cv_width = (options.hopRadius * 2) + options.hopStrokeWidth;
  cv.attr('width', cv_width).attr('height', cv_height);
  cv.css('position', 'absolute');

  // Some calculations
  var width = cv_width + options.labelWidth + options.labelMargin;

  // Initialize container
  var container = this.container = $('<div class="traceroute-graph-wrapper">');
  container.css('position', 'relative');
  container.height(cv_height).width(width);

  // Initialize label container
  var label_container = this.label_container = $('<div class="traceroute-labels">');
  label_container.css('position', 'absolute');
  label_container.css('left', 0);
  label_container.height(cv_height).width(width);

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

  this.hops.each(function(i) {
    var hop_y = (((options.hopRadius * 2) + options.hopStrokeWidth + options.linkLength) * i) + options.hopRadius + (options.hopStrokeWidth / 2);
    if (i < (num_hops - 1)) {
      trace.drawSegment(segment_x, hop_y, options.linkWidth, segment_h, '#bbbbbb');
    }
    trace.drawHop(hop_x, hop_y, options.hopRadius, options.hopStrokeWidth, options.hopStrokeColor, options.hopFillColor);

    var label_y = (((options.hopRadius * 2) + options.hopStrokeWidth + options.linkLength) * i);
    var name = $('.' + options.nameClass, this).text()

    var label = $('<div class="traceroute-label">');
    label.text(name);
    label.width(options.labelWidth);
    label.css({'position' : 'absolute', 'top' : label_y});
    label.css(label_css);


    label_container.append(label);
    label.data('HopData', this);

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

  // Add canvas
  $(el).before(container);

  $(this.el).data('TraceRoute', this);
}

TraceRoute.prototype.drawHop = function(x, y, r, strokeWidth, strokeColor, fillColor) {
  this.ctx.beginPath();
  this.ctx.arc(x, y, r, 0, Math.PI*2, true);
  this.ctx.fillStyle = fillColor;
  this.ctx.strokeStyle = strokeColor;
  this.ctx.lineWidth = strokeWidth;
  this.ctx.closePath();
  this.ctx.fill();
  this.ctx.stroke();
}

TraceRoute.prototype.drawSegment = function(x,y,w,h, color) {
  this.ctx.beginPath();
  this.ctx.rect(x,y,w,h);
  this.ctx.fillStyle = color;
  this.ctx.closePath();
  this.ctx.fill();
}

})(jQuery);
