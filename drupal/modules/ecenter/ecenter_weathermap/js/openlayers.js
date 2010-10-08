// $Id$
/**
 * @file openlayers.js
 *
 * Extend the Drupal OpenLayers methods
 */
Drupal.openlayers.addFeatures = function(map, layer, features) {
  var newFeatures = [];

  // Go through features
  for (var key in features) {
    var feature = features[key];
    //console.log(feature);
    var newFeatureObject = this.objectFromFeature(feature);

    // If we have successfully extracted geometry add additional
    // properties and queue it for addition to the layer
    if (newFeatureObject) {
      var newFeatureSet = [];

      // Check to see if it is a new feature, or an array of new features.
      if (typeof(newFeatureObject[0]) === 'undefined'){
        newFeatureSet[0] = newFeatureObject;
      }
      else{
        newFeatureSet = newFeatureObject;
      }

      // Go through new features
      for (var i in newFeatureSet) {
        var newFeature = newFeatureSet[i];

        // Add extra data to feature
        if (feature.extra !== undefined) {
          $.extend(newFeature, feature.extra);
        }

        // Transform the geometry if the 'projection' property is different from the map projection
        if (feature.projection) {
          if (feature.projection !== map.projection){
            var featureProjection = new OpenLayers.Projection("EPSG:" + feature.projection);
            var mapProjection = new OpenLayers.Projection("EPSG:" + map.projection);
            newFeature.geometry.transform(featureProjection, mapProjection);
          }
        }

        // Add attribute data
        if (feature.attributes) {
          // Attributes belong to features, not single component geometries
          // of them. But we're creating a geometry for each component for
          // better performance and clustering support. Let's call these
          // "pseudofeatures".
          //
          // In order to identify the real feature each geometry belongs to
          // we then add a 'fid' parameter to the "pseudofeature".
          // NOTE: 'drupalFID' is only unique within a single layer.
          newFeature.attributes = feature.attributes;
          newFeature.data = feature.attributes;
          newFeature.drupalFID = key; 
        }

        // Add style information
        if (feature.style) {
          newFeature.style = jQuery.extend({}, OpenLayers.Feature.Vector.style['default'], feature.style);
        }

        // Push new features
        newFeatures.push(newFeature);
      }
    }
  }

  // Add new features if there are any
  if (newFeatures.length !== 0){
    layer.addFeatures(newFeatures);
  }

}

