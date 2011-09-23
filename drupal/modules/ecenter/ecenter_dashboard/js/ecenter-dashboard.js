(function($) {

Drupal.behaviors.siteView = function(context) {
  if (Drupal.settings.ecenterNetwork == undefined
      || Drupal.settings.ecenterNetwork.siteData == undefined 
      || Drupal.settings.ecenterNetwork.siteData.destinations == undefined) {
    return;
  }

  var data = Drupal.settings.ecenterNetwork.siteData;
  var destinationsLength = data.destinations.length;

  var node_radius = 9;
  var stroke_width = 5;
  var width = 340;
  var height = 240;
  var cx = width / 2;
  var cy = height / 2;
  var text_offset = node_radius + stroke_width + 2;
  var radius = (width > height) ? cy - node_radius - (stroke_width / 2)
    : cx - node_radius - (stroke_width / 2);

  var paper = Raphael('site-view-svg', width, height);
  var increment = 2 * (Math.PI / destinationsLength);
  var angle = 0;

  var destination_sets = [];

  // Loop through destinations again and draw
  for (i = 0; i < destinationsLength; i++) {
    var destination = data.destinations[i];

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
        'font-size' : '12pt'
      });

    if (flip == 1) {
      text.attr({'text-anchor' : 'start'});
    } else {
      text.attr({'text-anchor' : 'end'});
    }

    if (
      destination.data.traceroute != undefined &&
      ((destination.data.traceroute.forward != undefined &&
      (destination.data.traceroute.forward.snmp.utilization.value > 95 ||
      destination.data.traceroute.forward.snmp.errors.value > 0 ||
      destination.data.traceroute.forward.snmp.drops.value > 0)) ||
      (destination.data.traceroute.reverse != undefined &&
      (destination.data.traceroute.reverse.snmp.utilization.value > 95 ||
      destination.data.traceroute.reverse.snmp.errors.value > 0 ||
      destination.data.traceroute.reverse.snmp.drops.value > 0)))
    ) {
      node.attr({'stroke': '#cc0000'});
      text.attr({'fill': '#cc0000'});
    }
    else if (
      destination.data.traceroute != undefined &&
      ((destination.data.traceroute.forward != undefined && 
      (destination.data.traceroute.forward.snmp.utilization.value > 75)) ||
      (destination.data.traceroute.reverse != undefined &&
      (destination.data.traceroute.reverse.snmp.utilization.value > 75)))
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
        bbox_x - 1,
        node_box.y - (stroke_width / 2) - 1, 
        bbox_width + 2,
        node_box.height + stroke_width + 2
      )
      .attr({
        'stroke' : '#ffffff',
        'stroke-width' : '0px',
        'fill': '#ffffff', 
        'fill-opacity': 0.3,
      })
      .hover(function() {
          this.attr({'fill-opacity': 0});
        }, function() {
          this.attr({'fill-opacity': 0.3});
        }
      );

    $(rect[0]).qtip({
      content: destination.markup,
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
      'font-size' : '13pt',
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
