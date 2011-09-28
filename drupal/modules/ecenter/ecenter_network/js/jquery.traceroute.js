/**
 * This plugin takes a specially formed array and turns it into a traceroute
 * "subway map".
 */
(function($) {

// Raphael plugin to create triangle
Raphael.fn.triangle = function(x, y, size) {
  var path = ["M", x - (size / 2), y - (size / 2)];
  path = path.concat(["L", (x + (size / 2)), y]);
  path = path.concat(["L", (x - (size / 2)), (y + (size / 2))]);
  return this.path(path.concat(["z"]).join(" "));
};

Raphael.fn.halfCircle = function(x, y, radius, flip) {
  var flip = (flip) ? 0 : 1;
  var path = ["M", x - radius, y, "A", radius, radius * .9, 0, 0, flip, x + radius, y, "z"];
  return this.path(path.join(" ")); 
}

// @TODO account for redrawing
$.fn.traceroute = function(data, options) {
  var options = $.extend(true, {}, $.fn.traceroute.defaults, options);
  return this.each(function(i) {
    var traceroutes = $(this).data('traceroute') || {};
    if (traceroutes[options.tracerouteName] == undefined) {
      traceroutes[options.tracerouteName] = new $.traceroute(this, options, data);
      $(this).data('traceroute', traceroutes);
      traceroutes[options.tracerouteName].draw();
    }
  });
};

/**
 * Traceroute constructor
 * @param el 
 *   Element
 * @param options
 *   Options
 * @param data
 *   Traceroute data
 */
$.traceroute = function(el, options, data) {
  // Properties
  this.el = el;
  this.options = options;
  this.data = data;
  this.tracerouteDirections = { 'forward' : false, 'reverse' : false };
  
  this.paper = Raphael(el, options.container.width, options.container.height);
  this.paper.tracerouteOptions = options; // Needed for event handlers scoped to Raphael object

  // Container dimensions
  this.height = $(this.paper.canvas).height();
  this.width = $(this.paper.canvas).width();

  // Marker dimensions
  this.marker = { 
    'size' : (2 * parseInt(options.marker.radius)) + parseInt(options.marker.style['stroke-width']),
    'xOffset' : options.link.width / 2,
    'forwardYOffset' : parseInt(options.marker.radius) + (parseInt(options.marker.style['stroke-width']) / 2),
    'reverseYOffset' : parseInt(options.marker.radius) + (parseInt(options.marker.style['stroke-width']) / 2) + (parseInt(options.label.style['font-size']) / 2) 
  };

  this.label = {
    'yOffset' : (this.marker.size / 2) + (parseInt(options.label.style['font-size']) / 4)
  };

  
  // Marker + label bounding box dimensions 
  this.bbox = { 'height' : this.marker.size, 'width' : options.link.width };

  // Check for directions present in traceroute (if only one or other, drawing will
  // be different).
  for (var direction in this.tracerouteDirections) {
    for (var j = 0, dataLen = data.length; j < dataLen; j++) {
      var row = data[j];
      var row_type = (row.match != undefined) ? 'match' : 'diff';
      var step = row[row_type];

      if (step[direction] != undefined) {
        this.tracerouteDirections[direction] = true;
        break;
      }
    }
  }
  
  // Y offset
  this.diffYOffset = this.height - (this.bbox.height * 1.5);
}

// Callback for hover 'over' event
$.traceroute.hoverOver = function() {
  for (var i = 0, ii = this.groups.length; i < ii; ++i) {
    var set = this.paper.groups[this.groups[i]];
    for (var j = 0, jj = set.items.length; j < jj; ++j) {
      var element = set.items[j];
      switch (element.type) {
        case 'circle':
        case 'path':
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
        case 'path':
          element.attr(this.paper.tracerouteOptions.marker.style);
          break;
        case 'text':
          element.attr(this.paper.tracerouteOptions.label.style);
          break;
      }
    }
  }
}

$.traceroute.prototype.draw = function() {
  var set, 
    paper = this.paper, 
    data = this.data, 
    boxOffset = -this.bbox.width,
    lastHops = { 'forward': false, 'reverse' : false };

  for (var i = 0; i < data.length; i++) {
    var row = data[i],
      row_type = (row.match != undefined) ? 'match' : 'diff',
      step = row[row_type];

    if (row_type == 'diff') {
      var longestDirection = (step.forward.length > step.reverse.length) ?
        'forward' : 'reverse';
      var shortestDirection = (step.forward.length > step.reverse.length) ?
        'reverse' : 'forward';
      var lastDiffX = 0;
      if (step[shortestDirection].length) {
        var adjustedBoxWidth = (step[longestDirection].length * this.options.link.width) / step[shortestDirection].length;
      }
      else {
        var adjustedBoxWidth = step[longestDirection].length * this.options.link.width;
      }
    }

    for (direction in this.tracerouteDirections) {
      var yOffset = (i > 0 && row_type == 'diff' && direction == 'reverse') ? 
        this.diffYOffset : 0,
        oppositeDirection = (direction == 'forward') ? 'reverse' : 'forward',
        markerWidth = (this.options.marker.radius * 2) + this.options.marker.style['stroke-width']; 

      if (step[direction].length == 0) {
        continue;
      }

      for (var j = 0; j < step[direction].length; j++) {
        var hop = step[direction][j],
          labelOffset = yOffset + this.label.yOffset,
          set = paper.set(hop.hub);

        if (direction == 'forward' && step['reverse'].length) {
          var markerYOffset = yOffset + this.marker.forwardYOffset;
        } else if (direction == 'reverse' && row_type == 'match') {
          var markerYOffset = yOffset + this.marker.reverseYOffset;
        }
        else {
          var markerYOffset = yOffset + this.label.yOffset;
        }
        
        if (row_type == 'match') {
          // Only increment x counter once on matches
          if (direction == 'forward' || !step['forward']) {
            boxOffset +=  this.bbox.width;
          }
        } else {
          if (direction == longestDirection) {
            boxOffset += this.bbox.width;
          }
          else {
            boxOffset += adjustedBoxWidth;
          }
        }
 
        // Draw label
        set = paper.set(hop.hub);
        var label = paper.text(boxOffset + this.marker.xOffset, labelOffset, hop.hub)
          .attr(this.options.label.style); 
        
        var bbox = label.getBBox();
        var labelWidth = (bbox.width > markerWidth) ? bbox.width : markerWidth;
        var labelCenterOffset = (bbox.width > markerWidth) ? 0 : (markerWidth - bbox.width) / 2;

        labelBox = paper.rect(bbox.x - this.options.labelBox.paddingX - labelCenterOffset, bbox.y - this.options.labelBox.paddingY, labelWidth + (this.options.labelBox.paddingX * 2), bbox.height + (this.options.labelBox.paddingY * 2))
          .attr(this.options.labelBox.style);

        set.push(label, labelBox);
        
        // Draw marker
        if (row_type == 'match') {
          var flip = (direction != 'forward') ? true : false;
          var marker = paper.halfCircle(boxOffset + this.marker.xOffset, markerYOffset, this.options.marker.radius, flip)
        } else {
          // Note the fudge factor
          var marker = paper.circle(boxOffset + this.marker.xOffset, markerYOffset, this.options.marker.radius * 1.15)
        }
        marker.attr(this.options.marker.style);
        set.push(marker);
        
        labelBox.toFront();
        label.toFront();

        set.hover($.traceroute.hoverOver, $.traceroute.hoverOut);

        $.extend(hop, {'type' : row_type, 'direction' : direction, 'ttl' : i, 'xOffset' : boxOffset + this.marker.xOffset, 'yOffset' : markerYOffset });

        var directionOffset = (direction == 'forward') ? -this.options.link.offset : this.options.link.offset;
      
        // Draw lines backwards
        if (lastHops[direction]) {
          var l = lastHops[direction], 
              o = lastHops[oppositeDirection];
         
          // Skip link
          if (direction == 'reverse' && hop.ttl > (l.ttl + 1)) {
            var path = ["M", l.xOffset, l.yOffset + directionOffset, "C",  l.xOffset, this.height, hop.xOffset, this.height, hop.xOffset, hop.yOffset + directionOffset];
            var link = paper.path(path.join(' ')).attr(this.options.link.style);

            var link_bbox = link.getBBox();
            var arrow = paper.triangle(link_bbox.x + (link_bbox.width / 2), link_bbox.y + link_bbox.height, this.options.arrow.size)
              .attr(this.options.arrow.style)
              .rotate(180, true);
            arrow.toBack();
          }
          else {
            var arrowXOffset = (direction == 'forward') ? this.options.arrow.size / 8 : - this.options.arrow.size / 8;
            arrowXOffset += l.xOffset + ((hop.xOffset - l.xOffset) / 2);

            var path = ["M", l.xOffset, l.yOffset + directionOffset, "L", hop.xOffset, hop.yOffset + directionOffset];
            var link = paper.path(path.join(" ")).attr(this.options.link.style);

            var arrowYOffset = hop.yOffset + directionOffset;
            var rotation = 0;
            
            if (l.yOffset != hop.yOffset) {
              arrowYOffset = (parseInt(this.options.arrow.size) / 2) + l.yOffset - ((l.yOffset - hop.yOffset) / 2);
              rotation = (180 / Math.PI) * Math.atan( (l.yOffset - hop.yOffset) / (l.xOffset - hop.xOffset));
            }

            var arrow = paper.triangle(arrowXOffset, arrowYOffset, this.options.arrow.size).attr(this.options.arrow.style);
            if (direction == 'reverse') {
              arrow.rotate(180 + rotation, true);
            }
            arrow.toBack();
          }
          link.toBack();
        }
        lastHops[direction] = hop;
      }
    }
  }
}

// Defaults
$.fn.traceroute.defaults = {
  'tracerouteName' : 'default',
  'container' : {
    'width' : '100%',
    'height' : '70px'
  },
  'link' : {
    'width' : 65,
    'offset' : 4,
    'style' : {
      'fill' : 'transparent',
      'stroke' : '#cccccc',
      'stroke-width' : 3
    }
  },
  'arrow' : {
    'size' : 10,
    'style' : {
      'fill' : '#bbbbbb',
      'stroke' : '#ffffff',
      'stroke-width' : 1
    }
  },
  'marker' : {
    'radius' : 12,
    'style' : {
      'stroke' : '#888888',
      'fill' : '#ffffff',
      'stroke-width' : 3
    },
    'overStyle' : {
      'stroke': '#00aa00'
    }
  },
  'label' : {
    'style' : {
      'fill' : '#444444',
      'font-weight' : 'bold',
      'font-size' : '12px',
      'font-family' : 'Helvetica, Arial, sans-serif'
    },
    'overStyle' : {
      'fill' : '#00aa00'
    }
  },
  'labelBox' : {
    'paddingX' : 2,
    'paddingY' : 2,
    'style' : {
      'fill' : '#ffffff',
      'stroke' : 'none',
      'stroke-width' : 0
    }
  }
};

})(jQuery);
