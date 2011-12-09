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
 *
 * The E-Center fork of RaphaelJS enables complex interaction by allowing
 * named groups. This plugin wraps that functionality in a further layer
 * of synthetic events triggered from the top level drawing node. These
 * events occur in the context of the $.traceroute object and use an
 * 'element' prefix to distinguish them from actual events on the top level
 * of the canvas element. An example event binding:
 *
 * $(traceroute.paper.canvas).bind('elementclick', function(e, element) {
 *   console.log(this.options); // Traceroute object options
 *   console.log(this.paper);   // Traceroute object Raphael object
 *   console.log(element);      // Element object
 * });
 *
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
      traceroutes[options.tracerouteName].drawLegend();
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
  this.height = $(this.el).height();
  this.width = $(this.el).width();

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

$.traceroute.prototype.draw = function() {
  var set,
    paper = this.paper,
    data = this.data,
    boxOffset = -this.bbox.width,
    lastHops = { 'forward': false, 'reverse' : false };

  for (var i = 0; i < data.length; i++) {
    var row = data[i],
      row_type = (row.match != undefined) ? 'match' : 'diff',
      step = row[row_type],
      onlyReverse = false;

    if (typeof step.forward == 'undefined' || !step.forward.length) {
      onlyReverse = true;
    }

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

      if (typeof step[direction] == 'undefined' || step[direction].length == 0) {
        continue;
      }

      for (var j = 0; j < step[direction].length; j++) {
        var hop = step[direction][j],
          labelOffset = yOffset + this.label.yOffset,
          markerWidth = 0;

        var set_id = i + '_' + hop.hub_name;
        set = paper.set(set_id);

        if (direction == 'forward' && typeof step.reverse != 'undefined' && step.reverse.length) {
          var markerYOffset = yOffset + this.marker.forwardYOffset;
        } else if (direction == 'reverse' && typeof step.forward != 'undefined' && row_type == 'match') {
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

        // Draw marker
        if (row_type == 'match' && typeof step[oppositeDirection] != 'undefined') {
          var flip = (direction != 'forward') ? true : false;
          var marker = paper.halfCircle(boxOffset + this.marker.xOffset, markerYOffset,
            this.options.marker.radius, flip);
          markerWidth = this.options.marker.radius * 2.2;
        } else {
          // Note the fudge factor
          var marker = paper.circle(boxOffset + this.marker.xOffset, markerYOffset,
            this.options.marker.radius * 1.15);
          markerWidth = this.options.marker.radius * 2.5;
        }
        marker.attr(this.options.marker.style);
        marker['tracerouteDirection'] = direction;
        marker['tracerouteType'] = row_type;
        marker['tracerouteOnlyReverse'] = onlyReverse;

        set.push(marker);

        var bbox = label.getBBox();
        var labelWidth = (bbox.width > markerWidth) ? bbox.width : markerWidth;

        var labelCenterOffset = (bbox.width > markerWidth) ? 0 : (markerWidth - bbox.width) / 2;

        labelBox = paper.rect(bbox.x - this.options.labelBox.paddingX - labelCenterOffset,
            bbox.y - this.options.labelBox.paddingY, labelWidth + (this.options.labelBox.paddingX * 2),
            bbox.height + (this.options.labelBox.paddingY * 2))
          .attr(this.options.labelBox.style);

        label['tracerouteDirection'] = direction;
        label['tracerouteType'] = row_type;
        label['tracerouteOnlyReverse'] = onlyReverse;
        labelBox['tracerouteDirection'] = direction;
        labelBox['tracerouteType'] = row_type;
        labelBox['tracerouteOnlyReverse'] = onlyReverse;

        set.push(label, labelBox);

        labelBox.toFront();
        label.toFront();

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

$.traceroute.prototype.drawLegend = function() {
  var traceroute = this;
  $('<div class="traceroute-legend"></div>')
    .prependTo( $( traceroute.el ) )
    .append(function() {
      var legend = '<div class="traceroute-legend-element traceroute-legend-title">'+ Drupal.t('Traceroute (logical)') +'</div>';
      if (traceroute.tracerouteDirections.forward) {
        legend += '<div class="traceroute-legend-element traceroute-legend-forward"><span class="marker"></span><span class="label">'+ Drupal.t('Forward') +'</span></div>';
      }
      if (traceroute.tracerouteDirections.reverse) {
        legend += '<div class="traceroute-legend-element traceroute-legend-reverse"><span class="marker"></span><span class="label">' + Drupal.t('Reverse') +'</span></div>';
      }
      legend += '<div class="traceroute-legend-element traceroute-legend-help">'+ Drupal.t('Click nodes to see detail') +'</div>';
      return legend;
    });
}

// Defaults
$.fn.traceroute.defaults = {
  // Attach multiple traceroutes to the same selector by specifying an
  // alternate name
  'tracerouteName' : 'default',

  // Style for drawing container
  'container' : {
    'width' : '100%',
    'height' : '60px'
  },

  // Width, offset from vertical center, and style for link connector lines
  'link' : {
    'width' : 60,
    'offset' : 3,
    'style' : {
      'fill' : 'transparent',
      'stroke' : '#cccccc',
      'stroke-width' : 4
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
    'radius' : 12,
    'style' : {
      'stroke' : '#aaaaaa',
      'fill' : '#ffffff',
      'stroke-width' : 4
    },
    'overStyle' : {
      'stroke': '#00aa00'
    }
  },

  // Set style of hop label
  'label' : {
    'style' : {
      'fill' : '#555555',
      'font-weight' : 'bold',
      'font-size' : '11px',
      'font-family' : 'Helvetica, Arial, sans-serif'
    },
    'overStyle' : {
      'fill' : '#000000'
    }
  },

  // Set padding and style of box behind label
  'labelBox' : {
    'paddingX' : 1,
    'paddingY' : 1,
    'style' : {
      'fill' : '#ffffff',
      'stroke' : 'none',
      'stroke-width' : 0
    }
  },

  // Bind callbacks to events fired on each set of hops
  'behavior' : {}
};

// Create synthetic events from real Raphael events
var events = 'click dblclick mousedown mousemove mouseout mouseover mouseup touchstart touchmove touchend orientationchange touchcancel gesturestart gesturechange gestureend'.split(' ');
for (var i = 0, length = events.length; i < length; i++) {
  var evt = events[i];
  $.fn.traceroute.defaults.behavior[evt] = function(e) {
    $(this.paper.canvas).trigger('element' + e.type, this);
  }
}

})(jQuery);
