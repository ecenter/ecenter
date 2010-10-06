// $Id$

/**
 * @file ecenter_weathermap_behavior_select.js
 * Selection behavior for E-Center weathermap. 
 *
 * Because of the funky way that the OpenLayers library handles multiple
 * controls, we need a single control that handles ALL the behavior for
 * hover and click events associated with map features on a given layer.
 */
Drupal.behaviors.ecenter_weathermap_behavior_weathermap_select = function(context) {
  var layers, data = $(context).data('openlayers');
  if (data && data.map.behaviors['ecenter_weathermap_behavior_weathermap_select']) {
    var map = data.openlayers;
    var options = data.map.behaviors['ecenter_weathermap_behavior_weathermap_select'];
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
          console.log(selectedLayer);
          layers.push(selectedLayer[0]);
        }
      }
    }

    // Define feature select events for selected layers.
    weathermapSelect = new OpenLayers.Control.SelectFeature(layers,
      {
        callbacks: {
          over: Drupal.ecenterWeathermapSelect.over,
          out: Drupal.ecenterWeathermapSelect.out,
          click: Drupal.ecenterWeathermapSelect.click
        }
      }
    );
    
    // Actiate the popups
    map.addControl(weathermapSelect);
    weathermapSelect.activate();
  }
}

Drupal.ecenterWeathermapSelect = {};

Drupal.ecenterWeathermapSelect.click = function(feature) {
  console.log('click');
  console.log(feature);
}

Drupal.ecenterWeathermapSelect.over = function(feature) {
  console.log('over');
  console.log(feature);
}

Drupal.ecenterWeathermapSelect.out = function(feature) {
  console.log('out');
  console.log(feature);
}
