/**
 * This plugin takes a specially formed array and turns it into a traceroute
 * "subway map".
 */
(function($) {

// @TODO account for redrawing
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

// Traceroute constructor
$.traceroute = function(el, options, data) {
  this.el = el;
  this.options = options;
  this.paper = Raphael(el, options.container.width, options.container.height);
  this.paper.tracerouteOptions = options;
}

// Callback for hover 'over' event
$.traceroute.hoverOver = function() {
  for (var i = 0, ii = this.groups.length; i < ii; ++i) {
    var set = this.paper.groups[this.groups[i]];
    for (var j = 0, jj = set.items.length; j < jj; ++j) {
      var element = set.items[j];
      switch (element.type) {
        case 'circle':
          element.attr(this.paper.tracerouteOptions.marker.overStyle);
          break;
        case 'text':
          element.attr(this.paper.tracerouteOptions.label.overStyle);
          break;
      }
    }
  }
}

// Callback for hover 'out' event
$.traceroute.hoverOut = function() {
  for (var i = 0, ii = this.groups.length; i < ii; ++i) {
    var set = this.paper.groups[this.groups[i]];
    for (var j = 0, jj = set.items.length; j < jj; ++j) {
      var element = set.items[j];
      switch (element.type) {
        case 'circle':
          element.attr(this.paper.tracerouteOptions.marker.style);
          break;
        case 'text':
          element.attr(this.paper.tracerouteOptions.label.style);
          break;
      }
    }
  }
}

$.traceroute.prototype.draw = function(data) {
  var paper = this.paper;

  // Marker offsets 
  var marker_center_offset = this.options.marker.radius +
    (this.options.marker.style['stroke-width'] / 2);
  
  var link_length = parseInt(this.options.link.length) + (2 * marker_center_offset);

  // Start at a negative distance so first iteration starts at 0
  var x_offset = -link_length;

  // Always vertically center markers
  var y_offset = parseInt(this.options.container.height) / 1.75;
  
  // Last hop tracks the last hop in the forward and reverse directions,
  // irrespective of the current step. This allows us to always draw backwards
  // to the appropriate marker.
  var last_hop = {'forward': null, 'reverse' : null};

  for (var i = 0; i < data.length; i++) {
    var row = data[i];
    var row_type = (row.match != undefined) ? 'match' : 'diff';
    var step = row[row_type];

    // Reuse last_hop variable to loop over forward and reverse directions
    for (direction in last_hop) {
      var y_adjust = (i > 0 && row_type == 'diff' && direction == 'reverse') ? 
        y_offset - this.options.diff_y_offset : y_offset;

      if (step[direction] == undefined) {
        continue;
      }

      for (var j = 0; j < step[direction].length; j++) {
        var hop = step[direction][j];
        $.extend(hop, {'ttl' : i, 'type' : row_type, 'direction' : direction, 'y_offset': y_adjust});

        if (row_type == 'match') {
          // Only increment x counter once on matches
          if (direction == 'forward' || !step['forward']) {
            x_offset += link_length;
          }
          label_offset = x_offset;
          marker_offset = marker_center_offset + label_offset + (this.options.label.width / 4);
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
          marker_offset = marker_center_offset + label_offset + (this.options.label.width / 4);
          $.extend(hop, {'x_offset' : last_diff_x});
        }

        var marker = paper.circle(marker_offset, y_adjust, this.options.marker.radius)
          .attr(this.options.marker.style);
        
        var fontSize = parseInt(this.options.label.style['font-size']);

        var label_y = (direction == 'reverse') ?
          y_adjust - this.options.label.margin - (2 * this.options.label.padding_y):
          y_adjust + fontSize + this.options.label.margin + (2 * this.options.label.padding_y);

        // @TODO center text...
        var label_text = paper.text(label_offset, label_y, hop.hop_ip).attr(this.options.label.style);

        var set = paper.set(hop.hub)
          .push(marker, label_text)
          .hover($.traceroute.hoverOver, $.traceroute.hoverOut);

        /*var label_background = paper.rect(background,
          label_offset, label_y - font_size - this.options.label.padding_y,
          this.options.label.width, font_size + (3 * this.options.label.padding_y),
          this.options.label_background.style);*/
        //.hover($.traceroute.hoverOver, $.traceroute.hoverOut);
      }
    }
  }
}

// Defaults
$.fn.traceroute.defaults = {
  'tracerouteName' : 'default',
  'diffYOffset' : 25,
  'container' : {
    'width' : '100%',
    'height' : '200px'
  },
  'link' : {
    'match_offset' : 9,
    'length' : 55,
    'style' : {
      'fill' : 'transparent',
      'stroke' : '#dddddd',
      'stroke-width' : 3
    }
  },
  'arrow' : {
    'height' : 12,
    'width' : 12,
    'style' : {
      'fill' : '#aaaaaa',
      'stroke' : '#ffffff',
      'stroke-width' : 1
    }
  },
  'marker' : {
    'radius' : 10,
    'style' : {
      'stroke' : '#aaaaaa',
      'fill' : '#ffffff',
      'stroke-width' : 4
    },
    'overStyle' : {
      'stroke': '#00aa00',
    }
  },
  'hub_label' : {
    'style' : {
      'fill' : '#444444',
      'font-weight' : 'bold',
      'font-size' : '10px',
      'font-family' : '"Anonymous Pro", "Courier New", courier, monospace'
    }
  },
  'hub_label_background' : {
    'style' : {
      'fill' : '#ffffff',
      'fillOpacity' : 0.80
    }
  },
  'label' : {
    'width' : 75,
    'margin' : 17,
    'padding_x' : 2,
    'padding_y' : 2,
    'style' : {
      'font-size' : '10px',
      'fill' : '#000000',
      'font-family' : '"Anonymous Pro", "Courier New", courier, monospace',
    },
    'overStyle' : {
      'fill' : '#00aa00',
    }
  },
  'label_background' : {
    'style' : {
      'fill' : '#ffffff',
      'stroke-width' : 0,
    }
  }
};

})(jQuery);
