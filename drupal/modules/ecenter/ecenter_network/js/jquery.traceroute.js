/**
 * @file jquery.traceroute.js
 *
 * A jQuery plugin that creates a visual representation of a traceroute.
 *
 * Created by David Eads (davideads__at__gmail_com), 2011 for the US
 * Department of Energy E-Center Project (https://ecenter.fnal.gov).
 * 
 * Released under the Fermitools license (modified BSD). See LICENSE.txt for 
 * more information.
 *
 * Requires jQuery 1.3+ (http://jquery.com)
 * Requires the E-Center fork of RaphaelJS 1.5 (https://github.com/ecenter/raphael)
 *
 * Usage and behavior:
 *
 * Invoke with $('#drawing-target-selector').traceroute(data, options)
 * 
 * Data must be an array representation of a diffed traceroute of the following
 * form:
 *
 * [ { 'match': { 'forward' : [hop,] , 'reverse' : [hop,] } },
 *   { 'diff' : { 'forward' : [hop, hop2, ...], 'reverse' : [hop, hop2, ...]} },
 *   ...]
 *
 * Each item of the array is an object which represents a section of the path.
 * The object's key is used to differentiate between two types of sections:
 *
 *  - A traceroute match (forward and reverse hops correspond to the same 
 *    device, location, or interface) with a single forward hop and/or a 
 *    single reverse hop.
 *  - A traceroute diff (forward and reverse hops diverge for this section
 *    of the path) with one or more forward and/or reverse hops. 
 *
 * Because of the complicated and data-dependent nature of the drawing routine,
 * no effort has been made to generalize the plugin to support configurable
 * rendering callbacks or similar customization tricks. 
 *
 * See $.fn.traceroute.defaults for an overview of traceroute options.
 */
(function($) {

/**
 * Raphael plugin to create equilateral triangle
 * 
 * @param x
 *   x-coordinate of triangle center.
 * @param y
 *   y-coordinate of triangle center.
 * @param size
 *   Triangle size (tip to opposite side)
 */
Raphael.fn.triangle = function(x, y, size) {
  var path = ["M", x - (size / 2), y - (size / 2)];
  path = path.concat(["L", (x + (size / 2)), y]);
  path = path.concat(["L", (x - (size / 2)), (y + (size / 2))]);
  return this.path(path.concat(["z"]).join(" "));
};

/** 
 * Raphael plugin to create slightly elliptical half circle
 *
 * @param x
 *   x-coordinate of half-circle center.
 * @param y
 *   y-coordinate of half-circle's flat segment.
 * @param radius
 *   Radius of half circle.
 * @param flip
 *   If true, drawn half circle downwards rather than upwards.
 */
Raphael.fn.halfCircle = function(x, y, radius, flip) {
  var flip = (flip) ? 0 : 1;
  var path = ["M", x - radius, y, "A", radius, radius * .9, 0, 0, flip, x + radius, y, "z"];
  return this.path(path.join(" ")); 
}

/**
 * Traceroute plugin 
 *
 * @param data
 *   Traceroute array (see introductory documentation).
 * @param options
 *   Plugin options
 */
$.fn.traceroute = function(data, options) {
  var options = $.extend(true, {}, $.fn.traceroute.defaults, options);
  return this.each(function(i) {
    var traceroutes = $(this).data('traceroute') || {};
    if (traceroutes[options.tracerouteName] == undefined) {
      traceroutes[options.tracerouteName] = new $.traceroute(this, data, options);
      $(this).data('traceroute', traceroutes);
      traceroutes[options.tracerouteName].draw();
    }
  });
};

/**
 * Traceroute object constructor
 *
 * @param el 
 *   Element
 * @param options
 *   Options
 * @param data
 *   Traceroute data
 */
$.traceroute = function(el, data, options) {
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
    'reverseYOffset' : parseInt(options.marker.radius) + (parseInt(options.marker.style['stroke-width']) / 2)
      + (parseInt(options.label.style['font-size']) / 2) 
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
        var label = paper.text(boxOffset + this.marker.xOffset, labelOffset, hop.hub_name)
          .attr(this.options.label.style); 
        
        var bbox = label.getBBox();
        var labelWidth = (bbox.width > markerWidth) ? bbox.width : markerWidth;
        var labelCenterOffset = (bbox.width > markerWidth) ? 0 : (markerWidth - bbox.width) / 2;

        labelBox = paper.rect(bbox.x - this.options.labelBox.paddingX - labelCenterOffset, 
            bbox.y - this.options.labelBox.paddingY, labelWidth + (this.options.labelBox.paddingX * 2),
            bbox.height + (this.options.labelBox.paddingY * 2))
          .attr(this.options.labelBox.style);

        set.push(label, labelBox);
        
        // Draw marker
        if (row_type == 'match') {
          var flip = (direction != 'forward') ? true : false;
          var marker = paper.halfCircle(boxOffset + this.marker.xOffset, markerYOffset,
            this.options.marker.radius, flip)
        } else {
          // Note the fudge factor
          var marker = paper.circle(boxOffset + this.marker.xOffset, markerYOffset, 
            this.options.marker.radius * 1.15)
        }
        marker.attr(this.options.marker.style);
        set.push(marker);
        
        labelBox.toFront();
        label.toFront();

        //set.hover($.traceroute.hoverOver, $.traceroute.hoverOut);

        $.extend(hop, {'type' : row_type, 'direction' : direction, 'ttl' : i, 
          'xOffset' : boxOffset + this.marker.xOffset, 'yOffset' : markerYOffset });

        var directionOffset = (direction == 'forward') ? -this.options.link.offset : this.options.link.offset;
      
        // Draw lines backwards
        if (lastHops[direction]) {
          var l = lastHops[direction], 
              o = lastHops[oppositeDirection];
         
          // Skip link
          if (direction == 'reverse' && hop.ttl > (l.ttl + 1)) {
            var path = ["M", l.xOffset, l.yOffset + directionOffset, "C",  l.xOffset,
              this.height, hop.xOffset, this.height, hop.xOffset, hop.yOffset + directionOffset];
            var link = paper.path(path.join(' ')).attr(this.options.link.style);

            // Use bbox to align arrow instead of more complex mathematical
            // tricks to find intersection with bezier curve.
            var link_bbox = link.getBBox();
            var arrow = paper.triangle(link_bbox.x + (link_bbox.width / 2), 
                link_bbox.y + link_bbox.height, this.options.arrow.size)
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
              if (direction == 'reverse') {
                var arrowYOffset = l.yOffset - ((l.yOffset - hop.yOffset) / 2) + (parseInt(this.options.arrow.size) / 2);
              }
              else {
                var arrowYOffset = l.yOffset - ((l.yOffset - hop.yOffset) / 2) - (parseInt(this.options.arrow.size) / 2);
              }
              var rotation = (180 / Math.PI) * Math.atan( (l.yOffset - hop.yOffset) / (l.xOffset - hop.xOffset));
            }

            var arrow = paper.triangle(arrowXOffset, arrowYOffset, this.options.arrow.size)
              .attr(this.options.arrow.style);

            if (direction == 'reverse') {
              arrow.rotate(180 + rotation, true);
            }
            arrow.toBack();
          }
          link.toBack();
        }
        lastHops[direction] = hop;

        for (behavior in this.options.behavior) {
          var callback = this.options.behavior[behavior];
          set[behavior].call(set, callback);
        }

      }
    }
  }
}

// Defaults
$.fn.traceroute.defaults = {
  // Attach multiple traceroutes to the same selector by specifying an
  // alternate name
  'tracerouteName' : 'default',

  // Style for drawing container
  'container' : {
    'width' : '100%',
    'height' : '70px'
  },

  // Width, offset from vertical center, and style for link connector lines
  'link' : {
    'width' : 60,
    'offset' : 4,
    'style' : {
      'fill' : 'transparent',
      'stroke' : '#cccccc',
      'stroke-width' : 3
    }
  },

  // Size and style for link arrows
  'arrow' : {
    'size' : 10,
    'style' : {
      'fill' : '#bbbbbb',
      'stroke' : '#ffffff',
      'stroke-width' : 1
    }
  },

  // Radius and styles for hop markers
  'marker' : {
    'radius' : 11,
    'style' : {
      'stroke' : '#888888',
      'fill' : '#ffffff',
      'stroke-width' : 3
    },
    'overStyle' : {
      'stroke': '#00aa00'
    }
  },

  // Set style of hop label
  'label' : {
    'style' : {
      'fill' : '#444444',
      'font-weight' : 'bold',
      'font-size' : '11px',
      'font-family' : 'Helvetica, Arial, sans-serif'
    },
    'overStyle' : {
      'fill' : '#00aa00'
    }
  },

  // Set padding and style of box behind label
  'labelBox' : {
    'paddingX' : 2,
    'paddingY' : 2,
    'style' : {
      'fill' : '#ffffff',
      'stroke' : 'none',
      'stroke-width' : 0
    }
  },
  
  // Bind callbacks to events fired on each set of hops
  'behavior' : {
    // Uncomment to debug
    //'mouseover'  : function() { console.log('over'); },
    //'mouseout'  : function() { console.log('out'); },
    //'click'  : function() { console.log('click'); },
  }
};

})(jQuery);
