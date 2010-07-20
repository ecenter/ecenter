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
  var o = $.extend(true, {}, $.fn.traceroute.defaults, options);

  this.each(function(i) {
    $('.' + o.infoClass).hide();
    $('.' + o.dataClass).hide();

    /*var hops = $('.' + o.nameClass);
    var cv_height = ((o.hopRadius * 2) + o.linkLength) * hops.size();
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
    });*/

    $(this).prepend(cv);
  });

  return this;
};

// Defaults
$.fn.traceroute.defaults = {
  'height' : 500,
  'width' : 100,
  'linkLength' : 40,
  'linkWidth' : 10,
  'hopRadius' : 10,
  'hopStrokeColor' : '#cccccc',
  'hopStrokeWidth' : 8,
  'infoClass' : 'hop-info',
  'nameClass' : 'hop-name',
  'dataClass' : 'hop-data',
};

$.fn.traceroute.circle = function(ctx, x, y, r, width, color) {
  console.log(ctx);
  //ctx.save();
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI*2, true);
  //ctx.strokeStyle = color;
  ctx.lineWidth = width;
  ctx.closePath();
  ctx.stroke();
  //ctx.restore();
}

})(jQuery);
