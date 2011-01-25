// $Id$

/**
 * @file ecenter_network_behavior_select.js
 * Selection behavior for E-Center weathermap. 
 *
 * Because of the funky way that the OpenLayers library handles multiple
 * controls, we need a single control that handles ALL the behavior for
 * hover and click events associated with map features on a given layer.
 */
Drupal.behaviors.ecenter_network_behavior_select = function(context) {
  var layers, data = $(context).data('openlayers');
  if (data && data.map.behaviors['ecenter_network_behavior_select']) {
    var map = data.openlayers;
    var options = data.map.behaviors['ecenter_network_behavior_select'];
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

    // Define feature select events for selected layers.
    // Our system is so different, it almost makes sense to not subclass
    // SelectFeature at all...
    ecenterSelect = new OpenLayers.Control.SelectFeature(layers,
      {
        ecenterID: 'ecenter_network_select',
        callbacks: {
          over: Drupal.ecenterSelect.over,
          out: Drupal.ecenterSelect.out,
          click: Drupal.ecenterSelect.click,
          clickout: Drupal.ecenterSelect.clickout
        },
        selectStyle: {
          strokeColor: '#0000aa',
          pointRadius: 7,
          strokeWidth: 3,
          fontColor: '#0000aa',
          zIndex: 1000
        },
        highlight: function(feature) {},
        unhighlight: function(feature) {}
      }
    );

    // Actiate the popups
    map.addControl(ecenterSelect);
    ecenterSelect.activate();
  }
}

Drupal.ecenterSelect = {};

Drupal.ecenterSelect.click = function(feature) {
  var layer = feature.layer;
  var selected = (OpenLayers.Util.indexOf(
    feature.layer.selectedFeatures, feature) > -1);
  if (selected) {
    this.unselect(feature);
    Drupal.ecenterSelect.out(feature); // Unhighlight
    $('#network-map').trigger('ecenterfeatureunselect', [feature, feature.layer]);
  } else {
    this.select(feature);
    $('#network-map').trigger('ecenterfeatureselect', [feature, feature.layer]);
  }
}

Drupal.ecenterSelect.over = function(feature) {
  var layer = feature.layer;
  feature._prevHighlighter = feature._lastHighlighter;
  feature._lastHighlighter = this.id;
  var style = $.extend({}, feature.style, this.selectStyle);
  layer.drawFeature(feature, style);
  this.events.triggerEvent("ecenterfeatureover", {feature : feature});
}

Drupal.ecenterSelect.out = function(feature) {
  var layer = feature.layer;
  var selected = (OpenLayers.Util.indexOf(
    feature.layer.selectedFeatures, feature) > -1);
  if (!selected) {
    feature._lastHighlighter = feature._prevHighlighter;
    delete feature._prevHighlighter;
    layer.drawFeature(feature, feature.style || feature.layer.style ||
        "default");
  }
}
