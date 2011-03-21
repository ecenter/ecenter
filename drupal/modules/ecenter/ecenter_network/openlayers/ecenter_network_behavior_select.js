// $Id$

/**
 * @file ecenter_network_behavior_select.js
 * 
 * Selection behavior for E-Center
 *
 * Completely bypass OL default selection behavior by triggering events with
 * jQuery for easy interactivity in Drupal.
 */
Drupal.behaviors.ecenter_network_behavior_select = function(context) {
  var layers, data = $(context).data('openlayers');
  if (data && data.map.behaviors['ecenter_network_behavior_select']) {
    var map = data.openlayers;
    var options = data.map.behaviors['ecenter_network_behavior_select'];
    var layers = [];

    for (var i in options.layers) {
      var selectedLayer = map.getLayersBy('drupalID', options.layers[i]);
      if (typeof selectedLayer[0] != 'undefined') {
        layers.push(selectedLayer[0]);
      }
    }

    // Define feature select events for selected layers.
    // @TODO abstract to own class
    ecenterSelect = new OpenLayers.Control.SelectFeature(layers, {
      drupalID: 'ecenterSelect',
      callbacks: {
        over: Drupal.ecenterSelect.over,
        out: Drupal.ecenterSelect.out,
        click: Drupal.ecenterSelect.click,
      },
    });

    map.addControl(ecenterSelect);
    ecenterSelect.activate();
  }
}

Drupal.ecenterSelect = {};

Drupal.ecenterSelect.click = function(feature) {
  var layer = feature.layer;
  var control = this;
  $(control.map.div).trigger('featureClick', [feature, layer, control]);
}

Drupal.ecenterSelect.over = function(feature) {
  var layer = feature.layer;
  var control = this;
  $(control.map.div).trigger('featureOver', [feature, layer, control]);
}

Drupal.ecenterSelect.out = function(feature) {
  var layer = feature.layer;
  var control = this;
  $(control.map.div).trigger('featureOut', [feature, layer, control]);
}
