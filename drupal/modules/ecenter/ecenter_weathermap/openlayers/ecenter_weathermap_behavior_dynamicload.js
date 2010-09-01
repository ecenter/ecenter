Drupal.behaviors.ecenter_weathermap_behavior_dynamicload = function(context) {
  // Ignore context -- refresh all maps on the page
  for (var key in Drupal.settings.openlayers.maps) {
    var map = Drupal.settings.openlayers.maps[key];
    var data = $('#' + key).data('openlayers');
    var openlayers = data.openlayers;

    console.log('---');
    console.log(data);

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

          var center = OpenLayers.LonLat.fromString(map.center.initial.centerpoint).transform(
            new OpenLayers.Projection('EPSG:4326'), 
            new OpenLayers.Projection('EPSG:' + map.projection));
          var zoom = parseInt(map.center.initial.zoom, 10);
          openlayers.setCenter(center, zoom, false, false);
        }
      }
    }

    // Because we are context-less, excute map behaviors the hard way
    for (var name in map.behaviors) {
      if (name != 'ecenter_weathermap_behavior_dynamicload') {
        executeFunctionByName(name, Drupal.behaviors, $('#' + key).get(0));
      }
    }
  }
}

// See http://stackoverflow.com/questions/359788/javascript-function-name-as-a-string
function executeFunctionByName(functionName, context /*, args */) {
  var args = Array.prototype.slice.call(arguments).splice(2);
  var namespaces = functionName.split(".");
  var func = namespaces.pop();
  for(var i = 0; i < namespaces.length; i++) {
    context = context[namespaces[i]];
  }
  return context[func].apply(this, args);
}

