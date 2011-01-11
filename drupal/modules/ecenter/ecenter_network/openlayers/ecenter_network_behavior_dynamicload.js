Drupal.behaviors.ecenter_network_behavior_dynamicload = function(context) {
  // Ignore context -- refresh all maps on the page
  for (var key in Drupal.settings.openlayers.maps) {
    var map = Drupal.settings.openlayers.maps[key];
    var data = $('#' + key).data('openlayers');
    var openlayers = data.openlayers;
    if (data) {
      // Remove all layers (that aren't a base layer)
      for (var i = openlayers.layers.length - 1; i >= 0; i--) {
        var layer = openlayers.layers[i];
        if (layer != undefined && layer.isBaseLayer === false) {
          openlayers.removeLayer(openlayers.layers[i]);
        }
      }

      // Similar to addLayers method in OpenLayers module JS
      for (var name in map.layers) {
        var layer;
        var options = map.layers[name];
        options.drupalID = name;

        // Ensure that the layer handler is available
        if (options.layer_handler !== undefined && Drupal.openlayers.layer[options.layer_handler] !== undefined) {
          var layer = Drupal.openlayers.layer[options.layer_handler](map.layers[name].title, map, options);
          if (layer.isBaseLayer === false) {
            layer.visibility = (!map.layer_activated || map.layer_activated[name]);
            layer.displayInLayerSwitcher = (!map.layer_switcher || map.layer_switcher[name]);
            if (map.center.wrapdateline === '1') {
              layer.wrapDateLine = true;
            }
            openlayers.addLayer(layer);
          }


          // Zoom to extent
          layerextent = layer.getDataExtent();

          // Check for valid layer extent
          if (layerextent != null) {
            openlayers.zoomToExtent(layerextent);

            // If unable to find width due to single point,
            // zoom in with point_zoom_level option.
            if (layerextent.getWidth() == 0.0) {
              openlayers.zoomTo(data.map.behaviors['openlayers_behavior_zoomtolayer'].point_zoom_level);
            }
          }

        }
      }
      
      // Because we are context-less, excute map behaviors the hard way
      for (var name in map.behaviors) {
        if (name != 'ecenter_network_behavior_dynamicload') {
          executeFunctionByName(name, Drupal.behaviors, $('#' + key).get(0));
        }
      }
    }

  }
}


// See http://stackoverflow.com/questions/359788/javascript-function-name-as-a-string
function executeFunctionByName(functionName, context, args) {
  var args = Array.prototype.slice.call(arguments).splice(2);
  var namespaces = functionName.split(".");
  var func = namespaces.pop();
  for(var i = 0; i < namespaces.length; i++) {
    context = context[namespaces[i]];
  }
  return context[func].apply(this, args);
}

