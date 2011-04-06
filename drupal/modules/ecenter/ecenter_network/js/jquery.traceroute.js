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

  var marker_center_offset = this.options.marker.radius + 
    (this.options.marker.style.strokeWidth / 2);
  var marker_right_offset = 2 * marker_center_offset;
  var link_length = this.options.link.length + marker_right_offset;
  var links = svg.group('links');
  var nodes = svg.group('nodes');
  var x_offset = -link_length;
  var last_match = {}; var last_diff = {};


  for (var i = 0; i < data.length; i++) {
    var row = data[i];
    var row_type = (row.match != undefined) ? 'match' : 'diff';
    var step = row[row_type];

    var node_group = svg.group(nodes, 'step-' + i, {'class' : row_type});

    if (row_type == 'diff') {
      var longest_direction = (step.forward.length > step.reverse.length) ? 'forward' : 'reverse';
      var last_diff_x = 0;
      var adjusted_link_length = link_length - 10;
    }

    // Draw markers and labels
    for (var direction in {forward: 1, reverse: 1}) {
      // @TODO make configurable
      var y_offset = (row_type == 'diff' && direction == 'reverse') ? 35 : 0;

      for (var j = 0; j < step[direction].length; j++) {
        var hop = step[direction][j];
        
        if (row_type == 'match') {
          // Only increment x counter once on matches
          if (direction == 'forward') {
            x_offset += link_length;
          }
          label_offset = x_offset;
          marker_offset = marker_center_offset + label_offset;
          last_diff = {};
          last_match[direction] = { step: step, group: node_group, x_offset: x_offset };
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
          last_match = {};
          last_diff[direction] = { step: step, group: node_group, x_offset: marker_offset };
        }
        
        // Drawing routines 
        // @TODO make configurable callback?
        var hop_id = row_type + '-' + direction + '-' + hop.hop_id;
        
        var hop_class = row_type + '-' + direction + '-' + hop.hub_name;
        
        var node = svg.group(node_group, hop_id, {'class' : hop_class});
        
        var marker = svg.circle(node, marker_offset, 70 - y_offset, this.options.marker.radius, 
          this.options.marker.style);
        
        var label_height_adjust = (direction == 'reverse') ? -20 - y_offset: 20;
        var label = svg.text(node, label_offset, 73 + label_height_adjust, 
          hop.hub_name, this.options.label.style);
      }
    }

    // Draw connectors
    if (row_type == 'match' && !isEmpty(last_diff)) {
       
    }

    if (row_type == 'match' && !isEmpty(last_match)) {
       
    }
  }
}

function isEmpty(obj) {
  for (var prop in obj) {
    if (obj.hasOwnProperty(prop)) {
      return false;
    }
  }
  return true;
}

})(jQuery);
