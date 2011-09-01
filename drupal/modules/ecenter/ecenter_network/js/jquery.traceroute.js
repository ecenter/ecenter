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
    'size' : (2 * parseInt(options.marker.radius + options.markerBackground.radiusAdjust)) + parseInt(options.markerBackground.style['stroke-width']),
    'xOffset' : options.link.width / 2,
    'forwardYOffset' : parseInt(options.marker.radius + options.markerBackground.radiusAdjust) + (parseInt(options.markerBackground.style['stroke-width']) / 2),
    'reverseYOffset' : parseInt(options.marker.radius + options.markerBackground.radiusAdjust) + (parseInt(options.markerBackground.style['stroke-width']) / 2) + (parseInt(options.label.style['font-size']) / 2) 
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

$.traceroute.prototype.draw = function() {
  var paper = this.paper, 
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
        oppositeDirection = (direction == 'forward') ? 'reverse' : 'forward'; 

      if (step[direction].length == 0) {
        continue;
      }

      for (var j = 0; j < step[direction].length; j++) {
        var hop = step[direction][j],
          labelOffset = yOffset + this.label.yOffset,
          set = paper.set(hop.hub),
          markerRadius = this.options.marker.radius;

        if (direction == 'forward' && step['reverse'].length) {
          var markerYOffset = yOffset + this.marker.forwardYOffset;
        } else if (direction == 'reverse' && row_type == 'match') {
          var markerYOffset = yOffset + this.marker.reverseYOffset;
        }
        else {
          markerRadius = markerRadius * 1.35;
          var markerYOffset = yOffset + this.label.yOffset;
        }
        
        if (row_type == 'match') {
          // Only increment x counter once on matches
          if (direction == 'forward' || !step['forward']) {
            boxOffset +=  this.bbox.width;
          }
        } else {
          // ...
          if (direction == longestDirection) {
            boxOffset += this.bbox.width;
          }
          else {
            boxOffset += adjustedBoxWidth;
          }
        }
 
        if (!set.length) {
          set = paper.set(hop.hub);
          label = paper.text(boxOffset + this.marker.xOffset, labelOffset, hop.hub).attr(this.options.label.style); 
          var bbox = label.getBBox();
          labelBox = paper.rect(bbox.x - (2 * this.options.labelBox.padding), bbox.y - this.options.labelBox.padding, bbox.width + (this.options.labelBox.padding * 4), bbox.height + (this.options.labelBox.padding * 2)).attr(this.options.labelBox.style);
          set.push(label, labelBox); 
        }

        var markerBackground = paper.circle(boxOffset + this.marker.xOffset, markerYOffset, markerRadius + this.options.markerBackground.radiusAdjust).attr(this.options.markerBackground.style);
        markerBackground.toBack();
        var marker = paper.circle(boxOffset + this.marker.xOffset, markerYOffset, markerRadius)
          .attr(this.options.marker.style);
        
        set.push(marker);
        
        labelBox.toFront();
        label.toFront();

        // Problematic to do this many times...
        set.hover($.traceroute.hoverOver, $.traceroute.hoverOut);

        $.extend(hop, {'type' : row_type, 'direction' : direction, 'ttl' : i, 'xOffset' : boxOffset + this.marker.xOffset, 'yOffset' : markerYOffset });
      
        // Draw lines backwards
        if (lastHops[direction]) {
          var l = lastHops[direction], 
              o = lastHops[oppositeDirection];
          
          if (direction == 'reverse' && hop.ttl > (l.ttl + 1)) {
            var link = paper.path("M"+ l.xOffset +' '+ (l.yOffset + offset) +'C '+ l.xOffset +' '+ this.height +' '+ hop.xOffset +' '+ this.height +' '+ hop.xOffset +' '+ (hop.yOffset + offset)).attr(this.options.link.style);
            link.toBack();
          }
          else {
            var offset = (direction == 'forward') ? -this.options.link.offset : this.options.link.offset;
            var link = paper.path("M"+ l.xOffset +' '+ (l.yOffset + offset) +'L'+ hop.xOffset +' '+ (hop.yOffset + offset)).attr(this.options.link.style);
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
    'offset' : 3,
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
      'stroke' : '#888888',
      'fill' : '#ffffff',
      'stroke-width' : 3
    },
    'overStyle' : {
      'stroke': '#00aa00'
    }
  },
  'markerBackground' : {
    'radiusAdjust' : 6,
    'style' : {
      'stroke' : 'none',
      'stroke-width' : 0,
      'fill' : '#ffffff',
    },
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
    'padding' : 2,
    'style' : {
      'fill' : '#ffffff',
      'stroke' : 'none',
      'stroke-width' : 0
    }
  }
};

})(jQuery);
