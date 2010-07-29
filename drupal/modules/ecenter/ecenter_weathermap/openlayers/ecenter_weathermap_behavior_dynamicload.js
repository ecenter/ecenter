Drupal.behaviors.ecenter_weathermap_behavior_dynamicload = function(context) {

  for (var key in Drupal.settings.openlayers.maps) {
    var map = Drupal.settings.openlayers.maps[key];

    //console.log('---');
    //console.log(map.layers.ecenter_data);
    //console.log(map.layers.ecenter_data.features.length);

    var data = $('#' + key).data('openlayers');

    if (data) {
      for (var name in data.openlayers.layers) {
        var layer = data.openlayers.layers[name];
        if (!layer.isBaseLayer) {
          layer.destroy();
        }
      }

      Drupal.openlayers.addLayers(map, data.openlayers);
    }

    for (var name in data.openlayers.layers) {
      var layer = data.openlayers.layers[name];
      if (!layer.isBaseLayer) {
        layer.redraw();
      }
    }

    /*
    if (options.layer_handler !== undefined && Drupal.openlayers.layer[options.layer_handler] !== undefined) {
      var layer = Drupal.openlayers.layer[options.layer_handler](map.layers[name].title, map, options);

      layer.visibility = (!map.layer_activated || map.layer_activated[name]);

      if (layer.isBaseLayer === false) {
        layer.displayInLayerSwitcher = (!map.layer_switcher || map.layer_switcher[name]);
      }

      if (map.center.wrapdateline === '1') {
        // TODO: move into layer specific settings
        layer.wrapDateLine = true;
      }

      openlayers.addLayer(layer);
    }
    */


  }

  /*for (var key in data.openlayers.layers) {
    var layer = data.openlayers.layers[key];
    if (!layer.isBaseLayer) {
      //console.log(layer);
      layer.destroy();

      //layer.redraw();
    }
  }*/
}
