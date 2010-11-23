// $Id$

/**
 * @file ecenter_weathermap_behavior_curves.js
 */

Drupal.behaviors.ecenter_weathermap_behavior_curves = function(context) {
  var layers, data = $(context).data('openlayers');
  if (data && data.map.behaviors['ecenter_weathermap_behavior_curves']) {
    var map = data.openlayers;
    var options = data.map.behaviors['ecenter_weathermap_behavior_curves'];
    var layers = [];

    // For backwards compatiability, if layers is not
    // defined, then include all vector layers
    if (typeof options.layers == 'undefined' || options.layers.length == 0) {
      layers = map.getLayersByClass('OpenLayers.Layer.Vector');
    }
    else {
      for (var i in options.layers) {
        var selectedLayer = map.getLayersBy('drupalID', options.layers[i]);
        if (typeof selectedLayer[0] != 'undefined') {
          layers.push(selectedLayer[0]);
        }
      }
    }

    var style_green = {
      //strokeColor: "#00FF00",
      strokeWidth: 0,
      pointRadius: 2
    };

    for (var i in layers) {
      //console.log(layers[i]);
      var old_feature;
      var features = [];
      for (var j in layers[i].features) {
        if (old_feature) {
          var feature = layers[i].features[j];
          var curve = new Curve(old_feature, feature, 1);
        }
        old_feature = layers[i].features[j];
      }
      layers[i].addFeatures(features);
      layers[i].redraw();
    }
  }
}

/*Curve = function(from, to, index, steps, flip) {
  this.index = index || 0;
  this.flip = flip || false;
  this.steps = steps || 20;
  this.c1 = {x: 0, y: 0};
  this.c2 = {x: 0, y: 0};
  this.points = [];
  this.from = {x: from.geometry.x, y: from.geometry.y};
  this.to = {x: to.geometry.x, y: to.geometry.y};
  this.angle = Math.PI * (1 + (0.25 * index)) / 8;
  this.scale = (1.5 + 0.5 * index) / 8;

  this.getControlPoints();
  this.getBezier();

  console.log(this);
  //this.generateLineSegments();
}

Curve.prototype.getControlPoints = function() {
  var x1, y1, x2, y2;

  var dirX = this.to.x - this.from.x;
  var dirY = this.to.y - this.from.y;

  var mag = Math.sqrt((dirX * dirX) + (dirY * dirY));
  var length = mag * this.scale;

  dirX = dirX / mag;
  dirY = dirY / mag;

  sin = Math.sin(this.angle);
  cos = Math.cos(this.angle);

  var rotX = cos * dirX - sin * dirY;
  var rotY = sin * dirX + cos * dirY;
  var rotNegX = cos * -dirX - sin * dirY;
  var rotNegY = sin * dirX - cos * dirY;

  // Flip control points for "backwards" curves
  if (!this.flip && (dirX < 0 || (!dirX && dirY < 0))) {
    x1 = -rotX * length + this.to.x;
    y1 = -rotY * length + this.to.y;
    x2 = -rotNegX * length + this.from.x;
    y1 = -rotNegY * length + this.from.y;
  }
  else {
    x1 = rotNegX * length + this.to.x;
    y1 = rotNegY * length + this.to.y;
    x2 = rotX * length + this.from.x;
    y2 = rotY * length + this.from.y;
  }

  this.c1 = { x: x1, y: y1 };
  this.c2 = { x: x2, y: y2 };
}

Curve.prototype.getBezier = function() {
  var div = 1 / this.steps;

  for (var t = 0; t <= 1; t += div) {

    // Coefficients
    var B0 = Math.pow(t, 3);
    var B1 = 3 * Math.pow(t, 2) * (1 - t);
    var B2 = 3 * t * Math.pow((1 - t), 2);
    var B3 = Math.pow((1 - t), 3);

    var x = (this.from.x * B0) + (this.c1.x * B1) + (this.c2.x * B2) + (this.to.x * B3);
    var y = (this.from.y * B0) + (this.c1.y * B1) + (this.c2.y * B2) + (this.to.y * B3);

    if (x == NaN || y == NaN) {
      console.log('NAN');
      console.log({x: x, y: y});
    }

    this.points.push({x: x, y: y});
  }
  this.points.push(this.from); // I don't really understand why I need this
}*/



