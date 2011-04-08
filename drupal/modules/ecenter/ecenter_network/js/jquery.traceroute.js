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
  'diff_y_offset' : 20,
  'container' : {
    'style' : {
      'width' : '100%', // Width of canvas
      'height' : '100'  // Height of canvas
    }
  },
  'link' : {
    'match_offset' : 4,
    'length' : 55,
    'style' : {
      'fill' : 'transparent',
      'stroke' : '#aaaaaa',
      'strokeWidth' : 4,
    }
  },
  'arrow' : {
    'show' : true,
    'height' : 10,
    'width' : 10,
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
      'strokeWidth' : 4
    }
  },
  'label' : {
    'margin' : 14,
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
  $(el)
    .css(options.container.style)
    .svg();
}

$.traceroute.prototype.draw = function(data) {
  var svg = $(this.el).svg('get');

  var surface = svg.rect(0, 0, '100%', '100%', 
    {id: 'surface', 'fill': 'transparent'}
  );

  // Calculate some measurements
  
  // Marker offsets
  var marker_center_offset = this.options.marker.radius + 
    (this.options.marker.style.strokeWidth / 2);
  
  var link_length = this.options.link.length + (2* marker_center_offset);

  // Start at a negative distance so first iteration starts at 0
  var x_offset = -link_length;
  
  // Always vertically center markers
  var y_offset = this.options.container.style.height / 2;
  
  // Set up groups to hold graphical elements
  var links = svg.group('links');
  var nodes = svg.group('nodes');

  // Last hop tracks the last hop in the forward and reverse directions, 
  // irrespective of the current step. This allows us to always draw backwards
  // to the appropriate marker.
  var last_hop = {};

  for (var i = 0; i < data.length; i++) {
    var row = data[i];
    var row_type = (row.match != undefined) ? 'match' : 'diff';
    var step = row[row_type];

    var node_group = svg.group(nodes, 'step-' + i, {'class' : row_type});

    if (row_type == 'diff') {
      var longest_direction = (step.forward.length > step.reverse.length) ? 'forward' : 'reverse';
      var last_diff_x = 0;
      var adjusted_link_length = link_length - 30; // @TODO properly calculate
    }

    // Draw markers and labels
    for (var direction in {forward: 1, reverse: 1}) {
      var y_adjust = (row_type == 'diff' && direction == 'reverse') ? y_offset - this.options.diff_y_offset : y_offset;

      for (var j = 0; j < step[direction].length; j++) {
        var hop = step[direction][j];
        
        $.extend(hop, {'ttl' : i, 'type' : row_type, 'direction' : direction, 'y_offset': y_adjust});

        if (row_type == 'match') {
          // Only increment x counter once on matches
          if (direction == 'forward') {
            x_offset += link_length;
          }
          label_offset = x_offset;
          marker_offset = marker_center_offset + label_offset;
          $.extend(hop, {'x_offset' : x_offset});
        } else {
          // Increment global x_offset when working in longest direction
          if (direction == longest_direction) {
            x_offset += link_length;
            last_diff_x = x_offset;
          }
          else {
            // @TODO test this...
            last_diff_x = (j > 0) ? last_diff_x + adjusted_link_length : x_offset + adjusted_link_length;
          }
          label_offset = last_diff_x;
          marker_offset = marker_center_offset + label_offset;
          $.extend(hop, {'x_offset' : last_diff_x});
        }
        
        // Drawing routines 
        var hop_id = row_type + '-' + direction + '-' + hop.hop_id;
        var hop_class = 'node ' + row_type + '-' + direction + '-' + hop.hub_name;
        
        var node = svg.group(node_group, hop_id, {'class' : hop_class});
        var marker = svg.circle(node, marker_offset, y_adjust, this.options.marker.radius, 
          this.options.marker.style);
        
        var label_y = (direction == 'reverse') ? 
          y_adjust - this.options.label.margin : 
          y_adjust + parseInt(this.options.label.style.fontSize) 
            + this.options.label.margin;
        var label = svg.text(node, label_offset, label_y, 
          hop.hub_name, this.options.label.style);

        var line_offset = 0;
        if (last_hop != undefined && last_hop[direction] != undefined) {
          // Last hop in the same direction as this hop
          var last_sibling = last_hop[direction];

          var startx = last_sibling.x_offset + marker_center_offset;
          var endx = marker_offset;
          
          if (direction == 'forward') {
            
            // Offset link y-position for parallel forward and reverse "rails"
            if (last_sibling.ttl + 1 == i && last_sibling.type == 'match' && hop.type == 'match') {
              var line_offset = this.options.link.match_offset;
            }

            var link = svg.group(links);
            var line = svg.line(link, 
                startx, y_adjust + line_offset, 
                endx, y_adjust + line_offset, 
                this.options.link.style);

            // Draw arrow
            var arrow_start = startx + link_length - (this.options.arrow.width / 2);
            var arrow_end = arrow_start + this.options.arrow.width;
            var arrow_top = y_adjust + (this.options.arrow.height / 2);
            var arrow_bottom = y_adjust - (this.options.arrow.height / 2);
            var arrow = svg.polygon(link, [[arrow_start, arrow_top], [arrow_start, arrow_bottom], [arrow_end, y_adjust]],
                this.options.arrow.style);
          
          } else {
          
            // Non-skip differences: The current TTL is 1 ahead of previous sibling hop's TTL
            if (last_sibling.ttl + 1 == i || (last_sibling.type == 'diff' && hop.type == 'diff')) {
              // Offset link y-position for parallel forward and reverse "rails"
              if (hop.type == 'match' && last_sibling.type == 'match') {
                line_offset = 4;
              }
              var link = svg.line(links, startx, last_hop[direction].y_offset - line_offset, endx, y_adjust - line_offset, this.options.link.style);
            }
            // Skip links 
            else {
              // @TODO remove fudge factor
              var control_y = y_adjust - (1.75 * this.options.diff_y_offset);
              var path = svg.createPath();
              svg.path(links, path.move(startx, y_adjust).curveC([[startx, control_y, endx, control_y, endx, y_adjust]]), this.options.link.style);
            }
          
          }
        }
        last_hop[direction] = hop;
      }
    }
  }
}

})(jQuery);
