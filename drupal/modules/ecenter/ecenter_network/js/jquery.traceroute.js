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
    var traceroutes = $(this).data('traceroute') || {};
    if (traceroutes[options.tracerouteName] == undefined) {
      traceroutes[options.tracerouteName] = new $.traceroute(this, options);
      $(this).data('traceroute', traceroutes);
    }
    traceroutes[options.tracerouteName].draw(data);
  });
};

// Defaults
$.fn.traceroute.defaults = {
  'tracerouteName' : 'default',
  'tracerouteLength' : null,
  'drawArrows' : true,
  'append' : true,
  'link' : {
    'length' : 45,
    'style' : {
      'stroke' : '#aaaaaa',
      'strokeWidth' : 5
    }
  },
  'arrow' : {
    'height' : 6,
    'width' : 8,
    'style' : {
      'fill' : '#666666'
    }
  },
  'hop' : {
    'margin' : 6,
    'radius' : 8,
    'style' : {
      'stroke' : '#0000ff',
      'fill' : '#ffffff',
      'strokeWidth' : 4
    }
  },
  'label' : {
    'width' : 63,
    'top_margin' : 4,
    'style' : {
      'fontSize' : '12px',
      'fill' : '#000000',
      'fontFamily' : 'Verdana'
    }
  }
};

// Traceroute constructor
$.traceroute = function(el, options, data) {
  this.el = el;
  this.options = options;
  $(el).css({
    width: '100%',
    height: '200px',
  })
  .svg();
}

$.traceroute.prototype.draw = function(data) {
  var svg = $(this.el).svg('get');

  var surface = svg.rect(0, 0, '100%', '100%', 
    {id: 'surface', 'fill': 'transparent'}
  );

  for (var i in data) {
    var step = data[i];
    
    if (step.match != undefined) {
      // Position node
      var node_y = this.options.hop.radius + this.options.hop.style.strokeWidth + 
        i * (this.options.link.length + (2 * (this.options.hop.radius + this.options.hop.style.strokeWidth)));
      
      var node_options = $.extend(this.options.hop.style, {id: 'hop-' + step.match.forward[0].hub_name});
      var node = svg.circle(
        node_y, 155, 
        this.options.hop.radius,
        node_options
      );
   
      // @TODO replace with theme functions, use svg lib's chaining...
      var out_label = svg.text(step.match.forward[0].hub_name + ' (' + step.match.forward[0].hop_id + ')', this.options.label.style); 
    }
  }

}

})(jQuery);
