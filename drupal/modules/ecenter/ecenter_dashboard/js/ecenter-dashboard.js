(function($) {

Drupal.behaviors.siteView = function(context) {
  if (Drupal.settings.ecenterNetwork == undefined
      || Drupal.settings.ecenterNetwork.siteData == undefined 
      || Drupal.settings.ecenterNetwork.siteData.destinations == undefined) {
    return;
  }

  var data = Drupal.settings.ecenterNetwork.siteData;

  var node_radius = 9;
  var stroke_width = 5;
  var width = 340;
  var height = 220;
  var cx = width / 2;
  var cy = height / 2;
  var text_offset = node_radius + stroke_width + 2;
  var radius = (width > height) ? cy - node_radius - (stroke_width / 2)
    : cx - node_radius - (stroke_width / 2);

  var paper = Raphael('site-view-svg', width, height);

  // Loop through destinations to find length
  // Object.keys would work if supported by IE versions < 9
  var destinations = [];
  for (dst in data.destinations) {
    if (data.destinations.hasOwnProperty(dst)) {
      var destination = data.destinations[dst];
      destination.hub = dst;
      destinations.push(destination);
    }
  }

  var increment = 2 * (Math.PI / destinations.length);
  var angle = 0;

  var destination_sets = [];

  // Loop through destinations again and draw
  for (i = 0; i < destinations.length; i++) {
    var destination = destinations[i];

    var destinationX = cx - (radius * Math.sin(angle));
    var destinationY = cy - (radius * Math.cos(angle));

    var line = paper
      .path("M"+ cx + " " + cy + "L" + destinationX + " " + destinationY)
      .attr({
        'stroke-width' : 3,
        'stroke': '#cccccc'
      });

    var flip = 1;
    if (-1 * angle > Math.PI) {
      var flip = -1;
    }

    var node = paper
      .circle(destinationX, destinationY, node_radius)
      .attr({
        'fill' : '#ffffff',
        'stroke-width' : stroke_width,
        'stroke' : '#00cc00'
      });
    var text = paper
      .text((flip * text_offset) + destinationX, destinationY, destination.hub)
      .attr({
        'font-weight' : 'bold',
        'font-size' : '13pt'
      });

    if (flip == 1) {
      text.attr({'text-anchor' : 'start'});
    } else {
      text.attr({'text-anchor' : 'end'});
    }

    if (
      (destination.forward != undefined &&
      (destination.forward.data.utilization.value > 95 ||
      destination.forward.data.errors.value > 0 ||
      destination.forward.data.drops.value > 0)) ||
      (destination.reverse != undefined &&
      (destination.reverse.data.utilization.value > 95 ||
      destination.reverse.data.errors.value > 0 ||
      destination.reverse.data.drops.value > 0))
    ) {
      node.attr({'stroke': '#cc0000'});
      text.attr({'fill': '#cc0000'});
    }
    else if (
      (destination.forward != undefined && 
      (destination.forward.data.utilization.value > 75)) ||
      (destination.reverse != undefined &&
      (destination.reverse.data.utilization.value > 75))
    ) {
      node.attr({'stroke': '#ff7700'});
      text.attr({'fill': '#ff7700'});
    }
 
    var node_box = node.getBBox();
    var text_box = text.getBBox();

    var bbox_width = text_box.width + node_box.width + text_offset;

    if (flip == 1) {
      var bbox_x = node_box.x - (stroke_width / 2);
    } else {
      var bbox_x = text_box.x - (stroke_width / 2); 
    }

    // Hover bounding box
    var rect = paper
      .rect(
        bbox_x,
        node_box.y - (stroke_width / 2), 
        bbox_width,
        node_box.height + stroke_width
      )
      .attr({
        'stroke' : '#ffffff',
        'stroke-width' : 0,
        'fill': '#ffffff', 
        'fill-opacity': 0.3,
      })
      .hover(function() {
          this.attr({'fill-opacity': 0});
        }, function() {
          this.attr({'fill-opacity': 0.3});
        }
      );

    var content = null;
    if (destination.forward != undefined && destination.reverse != undefined) {
      var content = destination.forward.themed + destination.reverse.themed;
    }
    else if (destination.forward != undefined) {
      var content = destination.forward.themed;
    }
    else if (destination.reverse != undefined) {
      var content = destination.reverse.themed;
    }

    if (content) {
      $(rect[0]).qtip({
        content: content,
        show: 'mouseover',
        hide: {
          fixed: true
        },
        position: {
          corner: {
            tooltip: 'topLeft'
          },
          adjust: {
            x: 2 * text_box.width
          }
        },
        style: {
          background: 'rgba(255, 255, 255, 0.75)'
        }
      });
    }

    var set = paper.set()
      .push(node)
      .push(text)
      .push(rect);

    angle = angle - increment;
  }

  var source = paper.set();

  var text = paper
    .text(cx, cy, data.source)
    .attr({
      'font-size' : '15pt',
      'font-weight' : 'bold'
    });

  var text_box = text.getBBox();

  var node = paper
    .circle(cx, cy, text_box.width / 1.3)
    .attr({
      'fill' : '#dddddd',
      'stroke-width' : stroke_width,
      'stroke' : '#999999',
    });

  source.push(node);
  source.push(text);
  text.toFront();

}

})(jQuery);
