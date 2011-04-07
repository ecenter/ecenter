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
      'fill' : 'transparent',
      'stroke' : '#aaaaaa',
      'strokeWidth' : 3,
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
    'radius' : 8,
    'style' : {
      'class' : 'marker',
      'stroke' : '#0000ff',
      'fill' : '#ffffff',
      'strokeWidth' : 4
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

  var marker_center_offset = this.options.marker.radius + 
    (this.options.marker.style.strokeWidth / 2);
  var marker_right_offset = 2 * marker_center_offset;
  var link_length = this.options.link.length + marker_right_offset;
  var links = svg.group('links');
  var nodes = svg.group('nodes');
  var x_offset = -link_length;
  var last_hop = {};

  for (var i = 0; i < data.length; i++) {
    var row = data[i];
    var row_type = (row.match != undefined) ? 'match' : 'diff';
    var step = row[row_type];

    var node_group = svg.group(nodes, 'step-' + i, {'class' : row_type});

    if (row_type == 'diff') {
      var longest_direction = (step.forward.length > step.reverse.length) ? 
        'forward' : 'reverse';
      var last_diff_x = 0;
      var adjusted_link_length = link_length - 30; // @TODO properly calculate
    }


    // Draw markers and labels
    for (var direction in {forward: 1, reverse: 1}) {
      // @TODO make configurable
      var y_offset = (row_type == 'diff' && direction == 'reverse') ? 25 : 0;

      for (var j = 0; j < step[direction].length; j++) {
        var hop = step[direction][j];
        
        $.extend(hop, {'ttl' : i, 'type' : row_type, 
          'direction' : direction, 'y_offset': y_offset});

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
            last_diff_x = (j > 0) ? last_diff_x + adjusted_link_length : 
              x_offset + adjusted_link_length;
          }
          label_offset = last_diff_x;
          marker_offset = marker_center_offset + label_offset;
          $.extend(hop, {'x_offset' : last_diff_x});
        }
        
        // Drawing routines 
        var hop_id = row_type + '-' + direction + '-' + hop.hop_id;
        
        var hop_class = 'node ' + row_type + '-' + direction + '-' + hop.hub_name;
        
        var node = svg.group(node_group, hop_id, {'class' : hop_class});
        
        var marker = svg.circle(node, marker_offset, 70 - y_offset, 
          this.options.marker.radius, this.options.marker.style);
        
        var label_height_adjust = (direction == 'reverse') ? -20 - y_offset: 20;
        var label = svg.text(node, label_offset, 73 + label_height_adjust, 
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
              var line_offset = 4;
            }

            var link = svg.group(links);
            
            var line = svg.line(link, startx, 
              70 + line_offset - last_hop[direction].y_offset, endx, 
              70 + line_offset - y_offset, this.options.link.style);

            // Arrows
            var arrowx = startx + ((endx - startx)/2);
            var arrow = svg.polygon(link, [[arrowx - 5, 70 + line_offset + 4],
              [arrowx + 5, 70 + line_offset], [arrowx - 5, 70 + line_offset - 4]],
              this.options.arrow.style);
        
          } else {
          
            // Non-skip differences: The current TTL is 1 ahead of previous sibling hop's TTL
            if (last_sibling.ttl + 1 == i || (last_sibling.type == 'diff' && hop.type == 'diff')) {
              // Offset link y-position for parallel forward and reverse "rails"
              if (hop.type == 'match' && last_sibling.type == 'match') {
                line_offset = -4;
              }
              var link = svg.line(links, startx,
                70 + line_offset - last_hop[direction].y_offset, endx, 
                70 + line_offset - y_offset, this.options.link.style);
              
              // Arrows
              var arrowx = startx + ((endx - startx)/2);
              var arrow = svg.polygon(link, [[arrowx - 5, 70 + line_offset + 4],
                [arrowx + 5, 70 + line_offset], [arrowx - 5, 70 + line_offset - 4]],
                this.options.arrow.style);
            }
            // Skip links 
            else {
              var path = svg.createPath();
              svg.path(links, 
                path.move(startx, 70).curveC([[startx, 45, endx, 45, endx, 70]]),
                this.options.link.style);
            }
          
          }
        }
        last_hop[direction] = hop;
      }
    }
  }
  
  // Bind behaviors
  $('.match, .diff .node', svg.root()).bind({
    'mouseover' : function() {
      console.log('over', this); 
    },
    'mouseout' : function() {
      console.log('out', this);
    }
  });
}

})(jQuery);
