// $Id: openlayers_behavior_cluster.js,v 1.1.2.3 2010/07/21 09:38:30 strk Exp $

/**
 * @file
 * OpenLayers Behavior implementation for clustering.
 */

/**
 * OpenLayers Cluster Behavior
 */
Drupal.behaviors.ecenter_network_uncluster = function(context) {
  var data = $(context).data('openlayers');
  if (data && data.map.behaviors.ecenter_network_behavior_uncluster) {
    var options = data.map.behaviors.ecenter_network_behavior_uncluster;
    var map = data.openlayers;

    //options.distance = 20;

    var layers = [];
    for (var i in options.unclusterlayer) {
      var selectedLayer = map.getLayersBy('drupalID', options.unclusterlayer[i]);
      if (typeof selectedLayer[0] != 'undefined') {
        layers.push(selectedLayer[0]);
      }
    }

    // Go through chosen layers
    for (var i in layers) {
      var layer = layers[i];
      // Ensure vector layer
      if (layer.CLASS_NAME == 'OpenLayers.Layer.Vector') {
        var uncluster = new OpenLayers.Strategy.Uncluster(options);
        layer.addOptions({ 'strategies': [uncluster] }); 
        uncluster.setLayer(layer);
        uncluster.features = layer.features.slice();
        uncluster.activate();
        uncluster.uncluster();
      }
    }
  }
};
