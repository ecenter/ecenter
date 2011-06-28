(function($) {

Drupal.behaviors.siteView = function(context) {
  var data = Drupal.settings.ecenterNetwork.siteData;

  if (data.destinations == undefined) {
    return;
  }
 
  var node_radius = 9;
  var stroke_width = 5;
  var width = 350;
  var height = 250;
  var cx = width / 2;
  var cy = height / 2;
  var text_offset = node_radius + stroke_width + 2;
  var radius = (width > height) ? cy - node_radius - (stroke_width / 2) 
    : cx - node_radius - (stroke_width / 2);

  var paper = Raphael('dashboard-site_view', width, height); 

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

    console.log(angle);
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
      .text( (flip * text_offset) + destinationX, destinationY, destination.hub)
      //.attr({'text-anchor' : 'start'});

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

    // Hover bounding box
    var rect = paper
      .rect(
        node_box.x - (stroke_width / 2), 
        node_box.y - (stroke_width / 2), 
        text_box.x + text_box.width + stroke_width - node_box.x, 
        node_box.height + stroke_width
      )
      .attr({
        'stroke-width' : 0,
        'fill': '#000000', 
        'fill-opacity': 0.3,
      })
      .hover(function() {
          this.attr({'fill-opacity': 0});
        }, function() {
          this.attr({'fill-opacity': 0.3});
        }
      );

    var content = '';
    if (destination.forward != undefined && destination.reverse != undefined) {
      content = destination.forward.themed + destination.reverse.themed;
    }
    else if (destination.forward != undefined) {
      content = destination.forward.themed;
    }
    else {
      content = destination.reverse.themed;
    }

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
          x: 2 * text_box.width + 10
        }
      },
      style: {
        background: 'rgba(255, 255, 255, 0.6)'
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
  var text_box = text.getBBox();

  var node = paper
    .circle(cx, cy, text_box.width / 1.4)
    .attr({
      'fill' : '#ffffff',
      'stroke-width' : stroke_width,
      'stroke' : '#0000aa',
    });

  source.push(node);
  source.push(text);
  text.toFront();

}

})(jQuery);
