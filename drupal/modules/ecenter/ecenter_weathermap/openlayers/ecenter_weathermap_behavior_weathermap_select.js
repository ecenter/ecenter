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
    // Our system is so different, it almost makes sense to not subclass
    // SelectFeature at all...
    weathermapSelect = new OpenLayers.Control.SelectFeature(layers,
      {
        callbacks: {
          over: Drupal.ecenterWeathermapSelect.over,
          out: Drupal.ecenterWeathermapSelect.out,
          click: Drupal.ecenterWeathermapSelect.click,
          clickout: Drupal.ecenterWeathermapSelect.clickout
        },
        selectStyle: {
          strokeOpacity: 1,
          fillOpacity: 1,
          fontColor: '#222222'
        },
        highlight: function(feature) {},
        unhighlight: function(feature) {}
      }
    );

    // Actiate the popups
    map.addControl(weathermapSelect);
    weathermapSelect.activate();
  }
}

Drupal.ecenterWeathermapSelect = {};

Drupal.ecenterWeathermapSelect.click = function(feature) {
  var selected = (OpenLayers.Util.indexOf(
    feature.layer.selectedFeatures, feature) > -1);
  if (selected) {
    this.unselect(feature);
    /*if(this.toggleSelect()) {
    } else if(!this.multipleSelect()) {
        this.unselectAll({except: feature});
    }*/
  } else {
    /*if (!this.multipleSelect()) {
      this.unselectAll({except: feature});
    }*/
    this.select(feature);

    // @TODO -- is this bad?  I'd much prefer to use jQuery's native DOM
    // event handling here.
    $('#weathermap-map').trigger('ecenterfeatureselect', [feature, feature.layer]);
  }
}

Drupal.ecenterWeathermapSelect.clickout = function(feature) {
  console.log('clickout');
  console.log(feature);
}

// Pretty much a straight up copy of OL's highlight routine 
Drupal.ecenterWeathermapSelect.over = function(feature) {
  console.log(this);
  var layer = feature.layer;
  var cont = this.events.triggerEvent("ecenterbeforefeatureover", {
      feature : feature
  });
  if (cont !== false) {
    feature._prevHighlighter = feature._lastHighlighter;
    feature._lastHighlighter = this.id;
    var style = $.extend({}, feature.style, this.selectStyle);
    layer.drawFeature(feature, style);
    this.events.triggerEvent("ecenterfeatureover", {feature : feature});
  }

}

Drupal.ecenterWeathermapSelect.out = function(feature) {
  var layer = feature.layer;
  feature._lastHighlighter = feature._prevHighlighter;
  delete feature._prevHighlighter;
  layer.drawFeature(feature, feature.style || feature.layer.style ||
      "default");
  this.events.triggerEvent("ecenterfeatureout", {feature : feature});
}
