/*Drupal.behaviors.ecenter_weathermap_behavior_dynamicload = function(context) {
  for (var key in Drupal.settings.openlayers.maps) {
    var map = Drupal.settings.openlayers.maps[key];
    var data = $('#' + key).data('openlayers');
    if (data) {
      for (var name in data.openlayers.layers) {
        var layer = data.openlayers.layers[name];
        if (!layer.isBaseLayer) {
          layer.destroy();
        }
      }
      //console.log(map);
      for (var name in map.layers) {
        if (map.layers[name].baselayer) {
          console.log(name);
          delete map.layers[name];
        }
      }
      Drupal.openlayers.addLayers(map, data.openlayers);
      //for (var name in data.openlayers.layers) {
      //  var layer = data.openlayers.layers[name];
      //  if (!layer.isBaseLayer) {
      //    layer.redraw();
      //  }
      //}
      //console.log(data.openlayers);
    }
  }
}*/
