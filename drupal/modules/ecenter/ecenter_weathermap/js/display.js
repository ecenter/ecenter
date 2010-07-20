// @TODO Currently REALLY ROUGH!!!
/*Drupal.behaviors.EcenterTraceroute = function(context) {
   $('.hop-wrapper div').hide(); 
   $('.hop-wrapper').hover(function() {
     $('div', $(this)).show();
   }, function() {
     $('div', $(this)).hide();
   });
}*/

// A very light wrapper around jqplot that scrapes tables for data to plot

(function($) {

$.fn.traceroute = function(options) {
  var opt = $.extend(true, {}, $.fn.traceroute.defaults, options);

  return this.each(function(i) {
    trace = new TraceRoute(this, opt);
    //trace.draw();
  });

};

// Defaults
$.fn.traceroute.defaults = {
  'height' : 500,
  'width' : 100,
  'linkLength' : 10,
  'linkWidth' : 10,
  'hopRadius' : 5,
  'hopStrokeColor' : '#cccccc',
  'hopStrokeWidth' : 4,
  'wrapperClass' : 'hop-wrapper',
  'infoClass' : 'hop-info',
  'nameClass' : 'hop-name',
  'dataClass' : 'hop-data',
};

// Traceroute constructor
function TraceRoute(el, options) {
  var trace = this;
  var options = this.options = options;
  this.el = el;

  // Get individual hops
  this.hops = $('.' + options.wrapperClass, el);
  var num_hops = this.hops.size();

  // Initialize canvas
  var cv = this.cv = $('<canvas>');
  this.ctx = cv.get(0).getContext('2d');


  // Size canvas
  var cv_height = ((options.hopRadius * 2) + (options.hopStrokeWidth/2) + options.linkLength) * num_hops;
  this.cv.attr('width', options.width);
  this.cv.attr('height', cv_height);

  this.hops.each(function(i) {
    var hop_offset = (((options.hopRadius * 2) + (options.hopStrokeWidth/2) + options.linkLength) * i) + options.hopRadius + (options.hopStrokeWidth/2);
    trace.drawCircle(15, hop_offset, options.hopRadius, options.hopStrokeWidth, '#999999');
    
    if (i < (num_hops - 1)) {
      trace.drawSegment(10, hop_offset + 7, 5, 10, '#bbbbbb');
    }
    
  });

  // Add canvas
  $(el).prepend(this.cv);

  $(this.el).data('TraceRoute', this);
}

TraceRoute.prototype.drawCircle = function(x, y, r, width, color) {
  this.ctx.beginPath();
  this.ctx.arc(x, y, r, 0, Math.PI*2, true);
  this.ctx.strokeStyle = color;
  this.ctx.lineWidth = width;
  this.ctx.closePath();
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

/*
    $('.' + o.infoClass).hide();
    $('.' + o.dataClass).hide();

    /*var hops = $('.' + o.nameClass);
    var cv = $('<canvas>').css('background-color', '#eeeeee').width(o.width).height(cv_height);
    var ctx = cv[0].getContext('2d');


    y = 0;
    x = o.hopRadius + o.hopStrokeWidth;
    hops.each(function(i) {
      y = (o.linkLength * i) + o.hopRadius + o.hopStrokeWidth;
      ctx.beginPath();
      ctx.strokeStyle = o.hopStrokeColor;
      ctx.lineWidth = 4;
      ctx.arc(20, y, 5, 0, Math.PI*2, true);
      ctx.closePath();
      ctx.stroke();
      //$.fn.traceroute.circle(ctx, 10, 20, o.hopRadius, o.hopStrokeColor, o.hopStrokeWidth);
    });

    $(this).prepend(cv);
*/
