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
      traceroutes[options.tracerouteName].draw(data);
    }
  });
};

// Defaults
$.fn.traceroute.defaults = {
  'tracerouteName' : 'default',
  'tracerouteLength' : null,
  'drawArrows' : true,
  'append' : true,
  'link' : {
    'length' : 60,
    'style' : {
      'stroke' : '#aaaaaa',
      'strokeWidth' : 4,
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
      'strokeWidth' : 4,
    }
  },
  'label' : {
    'style' : {
      'fontSize' : '13px',
      'fill' : '#000000',
      'fontFamily' : '"Droid Sans", Verdana, sans-serif'
    },
  },
  'description' : {
    'style' : {
      'fontSize' : '10px',
      'fill' : '#444444',
      'fontFamily' : '"Droid Sans", Verdana, sans-serif'
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

  var node_center_offset = this.options.hop.radius + (this.options.hop.style.strokeWidth / 2);
  var node_right_offset = 2 * node_center_offset;
  var link_length = this.options.link.length + node_right_offset;
  var last_step = { x : 0, y: 0 };

  var links = svg.group('links');
  var nodes = svg.group('nodes');

  for (var i in data) {
    var step = data[i];
    
    if (step.match != undefined) {
      var g = svg.group(nodes, 'match-' + step.match.forward[0].hub_name);
      
      step.x = (i > 0) ? last_step.x + link_length : 0;
      var node_x = step.x + node_center_offset;

      //var node_x = node_center_offset + (i * link_length);
      var node_options = $.extend(this.options.hop.style, {
        id: 'hop-' + step.match.forward[0].hub_name}
      );
      var node = svg.circle(
        g, node_x, 95, 
        this.options.hop.radius,
        node_options
      );
   
      // Create labels
      // @TODO center text
      var out_label = svg.text(g, step.x, 125, 
        step.match.forward[0].hub_name, this.options.label.style);
    
      var in_label = svg.text(g, step.x, 72, 
        step.match.reverse[0].hub_name, this.options.label.style);
      
      // Draw lines backwards to last step
      if (last_step) {
        if (last_step.match != undefined) {
          var link_start = last_step.x + node_center_offset;
          var link_end = step.x + node_center_offset;
          svg.line(links, link_start, 90, link_end, 90, this.options.link.style);
          svg.line(links, link_start, 98, link_end, 98, this.options.link.style);
        }
      }
    }

    if (step.diff != undefined) {
      step.x = 20;
      last_step = step;
    }

    var last_step = step;
  }

}

})(jQuery);
