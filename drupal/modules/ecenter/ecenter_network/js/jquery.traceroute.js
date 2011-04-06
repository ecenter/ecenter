/**
 * This plugin takes a specially formed array and turns it into a traceroute
 * "subway map".
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
    'length' : 55,
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
  'marker' : {
    'radius' : 7,
    'style' : {
      'class' : 'marker',
      'stroke' : '#0000ff',
      'fill' : '#ffffff',
      'strokeWidth' : 4,
    }
  },
  'label' : {
    'style' : {
      'class' : 'label',
      'fontSize' : '11px',
      'fill' : '#000000',
      'fontFamily' : '"Droid Sans", Verdana, sans-serif'
    },
  },
};

// Traceroute constructor
$.traceroute = function(el, options, data) {
  this.el = el;
  this.options = options;
  $(el).css({
    'width' : '100%',
    'height' : '100px',
    'background-color' : '#eeeeee'
  })
  .svg();
}

$.traceroute.prototype.draw = function(data) {
  var svg = $(this.el).svg('get');

  var surface = svg.rect(0, 0, '100%', '100%', 
    {id: 'surface', 'fill': 'transparent'}
  );

  var node_center_offset = this.options.marker.radius + 
    (this.options.marker.style.strokeWidth / 2);
  var node_right_offset = 2 * node_center_offset;
  var link_length = this.options.link.length + node_right_offset;
  var last_step = { x : 0, y : 0 };

  var links = svg.group('links');
  var nodes = svg.group('nodes');

  for (var i = 0; i < data.length; i++) {
    var step = data[i];
   
    var step_type = (step.match != undefined) ? 'match' : 'diff';

    // Draw markers and labels
    for (var direction in {forward: 1, reverse: 1}) {
      for (var j = 0; j < step[step_type][direction].length; j++) {
        // @TODO make this into configurable callback with calculated position?
        var hop = step[step_type][direction][j];
        var hop_id = step_type + '-' + direction + '-' + hop.hop_id;
        var hop_class = step_type + '-' + direction + '-' + hop.hub_name;
        var node = svg.group(nodes, hop_id, {'class' : hop_class});
        var height_adjust = (direction == 'reverse') ? 20 : -20;
        var marker = svg.circle(node, node_center_offset + (link_length * i), 50, this.options.marker.radius, 
          this.options.marker.style);
        var label = svg.text(node, link_length * i, 53 + height_adjust, 
          hop.hub_name, this.options.label.style);
      }
    }

    // Draw lines between nodes

    // Forward

    // Reverse
    /*for (var j = 0; j < step.forward.length; j++) {
      
    }*/

    /*if (step.match != undefined) {
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
      last_step = step;
    }

    if (step.diff != undefined) {
      var most_hops = (step.diff.forward.length > step.diff.reverse.length) ? 
        'forward' : 'reverse';
      var longest_segment = (link_length * (step.diff[most_hops].length + 1));
  
      for (j in step.diff.forward) {
        step.x = last_step.x + link_length;
        var node_x = step.x + node_center_offset;
        var node_options = $.extend(this.options.hop.style, {
          id: 'hop-' + step.diff.forward[j].hub_name}
        );
        var node = svg.circle(
          g, node_x, 95, 
          this.options.hop.radius,
          node_options
        );
        last_step = step;
      }
   
      // Create labels
      // @TODO center text
      //var out_label = svg.text(g, step.x, 125, 
      //  step.diff.forward[0].hub_name, this.options.label.style);
    
      //var in_label = svg.text(g, step.x, 72, 
      //  step.diff.forward[0].hub_name, this.options.label.style);
    
    }*/

    /*if (step.diff != undefined) {
      var most_hops = (step.diff.forward.length > step.diff.reverse.length) ? 
        'forward' : 'reverse';
      var least_hops = (step.diff.forward.length > step.diff.reverse.length) ? 
        'reverse' : 'forward';
      var longest_segment = (link_length * (step.diff[most_hops].length + 1));
      var adjusted_link_length = longest_segment / (step.diff[least_hops].length + 1);

      // Forward
      for (j in step.diff.forward) {

        var g = svg.group(nodes, {});

        var hop = step.diff.forward[j];
        if (most_hops == 'forward') {
          if (last_step.forward_step == undefined) {
            step.forward_step = { x : last_step.x + link_length, y: 95};
          } else {
            step.forward_step = { x : last_step.forward_step.x + link_length, y: 95};
          }
          $.extend(step, step.forward_step);
        } else {
          if (last_step.forward_step == undefined) {
            step.forward_step = { x : last_step.x + adjusted_link_length, y: 95};
          } else {
            step.forward_step = { x : last_step.forward_step.x + adjusted_link_length, y: 95};
          }
        }
        svg.circle(g, step.forward_step.x + node_center_offset, step.forward_step.y, this.options.hop.radius, this.options.hop.style);
        
        var label = svg.text(g, step.forward_step.x, 125, 
          step.diff.forward[j].hub_name, this.options.label.style);
      }

      // Forward
      for (j in step.diff.reverse) {

        var g = svg.group(nodes, {});

        var hop = step.diff.reverse[j];
        if (most_hops == 'forward') {
          if (last_step.reverse_step == undefined) {
            step.reverse_step = { x : last_step.x + link_length, y: 75};
          } else {
            step.reverse_step = { x : last_step.reverse_step.x + link_length, y: 75};
          }
          $.extend(step, step.reverse_step);
        } else {
          if (last_step.reverse_step == undefined) {
            step.reverse_step = { x : last_step.x + adjusted_link_length, y: 75};
          } else {
            step.reverse_step = { x : last_step.reverse_step.x + adjusted_link_length, y: 75};
          }
        }
        svg.circle(g, step.reverse_step.x + node_center_offset, step.reverse_step.y, this.options.hop.radius, this.options.hop.style);
        
        var label = svg.text(g, step.reverse_step.x, 45, 
          step.diff.reverse[j].hub_name, this.options.label.style);
      }
      last_step = step;
    }*/
  }
}

})(jQuery);
