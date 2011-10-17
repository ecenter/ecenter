// $Id$

/**
 * @file ecenter_network_behavior_curves.js
 */

Drupal.behaviors.ecenter_network_behavior_curves = function(context) {
  var layers, data = $(context).data('openlayers');
  if (data && data.map.behaviors['ecenter_network_behavior_curves']) {
    var map = data.openlayers;
    var options = data.map.behaviors['ecenter_network_behavior_curves'];
    var layers = [];

    for (var i in options.layers) {
      var selectedLayer = map.getLayersBy('drupalID', options.layers[i]);
      if (typeof selectedLayer[0] != 'undefined') {
        layers.push(selectedLayer[0]);
      }
    }

    for (var i in layers) {
      var old_feature;
      var features = [];

      for (var j in layers[i].features) {
        if (old_feature) {
          var feature = layers[i].features[j];
          var curve = new Curve(old_feature, feature, 2.25, options.divisions,
            options.arrows);
          var line = new OpenLayers.Geometry.LineString(curve.points);
          features.push(new OpenLayers.Feature.Vector(line, null, options.style));

          // Draw arrows
          if (curve.points != undefined) {
            var midIdx = Math.floor(curve.points.length / 2);
            var p1 = curve.points[midIdx];
            var p2 = curve.points[midIdx + 1];
            
            // Rotate "backwards"
            var rot = 2 * Math.PI - Math.tan((p2.y - p1.y) / (p2.x - p1.x));
            
            // Account for horizontal direction by rotating 90 degs one way or other
            var angle = (p1.x > p2.x) ? rot - Math.PI / 2 : rot + Math.PI / 2;

            var arrow_style = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['default']);
            arrow_style.graphicName = 'triangle';
            arrow_style.pointRadius = 4;
            arrow_style.fillColor = '#0000cc';
            arrow_style.fillOpacity = 1;
            arrow_style.strokeWidth = 0.5;
            arrow_style.strokeColor = '#ffffff';
            arrow_style.strokeOpacity = 1;
            arrow_style.rotation = (angle * 180) / Math.PI;
            arrow_style.graphicZIndex = 0;

            var arrow = new OpenLayers.Feature.Vector(p1, null, arrow_style);
            features.push(arrow);
          }
        }
        old_feature = layers[i].features[j];
      }

      layers[i].addFeatures(features);
      layers[i].redraw();
    }
  }
}

/**
 * A convenience class to construct the points in a bezier curve
 */
Curve = function(from, to, index, steps, arrows) {
  this.points = [];
  this.index = index;
  this.steps = steps;
  this.arrows = arrows;
  this.from = {x: from.geometry.x, y: from.geometry.y};
  this.to = {x: to.geometry.x, y: to.geometry.y};
  this.angle = Math.PI * (1 + (0.25 * index)) / 8;
  this.scale = (1.5 + 0.5 * index) / 8;

  this.getControlPoints();
  this.getBezier();
}

/**
 * Generate points for bezier curve
 */
Curve.prototype.getBezier = function() {
  var div = 1 / this.steps;
  var points = [];

  var i = 0;
  for (var t = 0; t <= 1; t += div) {

    // Coefficients
    var B0 = Math.pow(t, 3);
    var B1 = 3 * Math.pow(t, 2) * (1 - t);
    var B2 = 3 * t * Math.pow((1 - t), 2);
    var B3 = Math.pow((1 - t), 3);

    var x = (this.to.x * B0) + (this.c1.x * B1) + (this.c2.x * B2) + (this.from.x * B3);
    var y = (this.to.y * B0) + (this.c1.y * B1) + (this.c2.y * B2) + (this.from.y * B3);

    this.points.push(new OpenLayers.Geometry.Point(x, y));
  }
  this.points.push(new OpenLayers.Geometry.Point(this.to.x, this.to.y));
}

/**
 * Generate control points
 */
Curve.prototype.getControlPoints = function() {
  var dirX = this.to.x - this.from.x;
  var dirY = this.to.y - this.from.y;

  var mag = Math.sqrt(dirX*dirX + dirY*dirY);

  // Line has no length
  if (mag === 0) {
    this.c1 = this.to;
    this.c2 = this.from;
    return;
  }

  // Determine how far away the control points should be from end points.
  var length = mag * this.scale;

  // Normalize vector
  dirX /= mag;
  dirY /= mag;

  // 2d rotation by 30 degrees
  var sin =  Math.sin(this.angle);
  var cos = Math.cos(this.angle);

  var rotX = cos * dirX - sin * dirY; //x' = cos(t)*x - sin(t)*y
  var rotY = sin * dirX + cos * dirY; //y' = sin(t)*x + cos(t)*y
  var rotNegX = cos * -dirX - sin * dirY; //x' = cos(-t)*-x - sin(-t)*-y
  var rotNegY = sin * dirX - cos * dirY; //y' = sin(-t)*-x + cos(-t)*-y

  // Get one leg of the arrow
  var x1 = rotX*length + this.from.x;
  var y1 = rotY*length + this.from.y;

  // Get parallel leg of arrow
  var x2 = rotNegX*length + this.to.x;
  var y2 = rotNegY*length + this.to.y;

  /* Weird code: this is used for flipping the bezier curve making the order
   * of to and from irrelevant.*/
  if (dirX < 0 || (dirX === 0 && dirY < 0)) {
    x2 = -rotX*length + this.to.x;
    y2 = -rotY*length + this.to.y;

    // Get parallel leg of arrow
    x1 = -rotNegX*length + this.from.x;
    y1 = -rotNegY*length + this.from.y;
  }

  this.c1 = {x: x2, y: y2};
  this.c2 = {x: x1, y: y1};
}
