/* Copyright (c) 2006-2010 by OpenLayers Contributors (see authors.txt for
 * full list of contributors). Published under the Clear BSD license.
 * See http://svn.openlayers.org/trunk/openlayers/license.txt for the
 * full text of the license. */

Vector = function(x, y) {
  this.x = x;
  this.y = y;
}

Vector.prototype.add = function(v) {
  return new Vector(this.x + v.x, this.y + v.y);
}

Vector.prototype.subtract = function(v) {
  return new Vector(this.x - v.x, this.y - v.y);
}

Vector.prototype.multiply = function(n) {
  return new Vector(this.x * n, this.y * n);
}

Vector.prototype.divide = function(n) {
  return new Vector(this.x / n, this.y / n);
}

Vector.prototype.magnitude = function() {
  return Math.sqrt(Math.pow(this.x, 2) + Math.pow(this.y, 2));
}

Vector.prototype.normalize = function() {
  return this.divide(this.magnitude);
}

// This is based on springy.js, loosely (@TODO don't mix-n-match licenses in derived work)

Layout = function(cluster, stiffness, repulsion, damping, total_energy) {
  this.cluster = cluster;
  this.stiffness = stiffness;
  this.repulsion = repulsion;
  this.damping = damping;

  $.each(this.cluster, function(i) {
    this.Point = {
      m : 1.0, // mass
      v : new Vector(0, 0), // velocity
      f : new Vector(0, 0), // force
      position : this.geometry.getBounds().getCenterLonLat()
    };
  });

  console.log(this.cluster);
}


/**
 * @requires OpenLayers/Strategy.js
 */

/**
 * Class: OpenLayers.Strategy.Cluster
 * Strategy for vector feature clustering.
 *
 * Inherits from:
 *  - <OpenLayers.Strategy>
 */
OpenLayers.Strategy.Uncluster = OpenLayers.Class(OpenLayers.Strategy, {

  /**
   * APIProperty: distance
   * {Integer} Pixel distance between features that should be considered a
   *   single cluster.  Default is 20 pixels.
   */
  distance: 20,

  /**
   * APIProperty: threshold
   * {Integer} Optional threshold below which original features will be
   *   added to the layer instead of clusters.  For example, a threshold
   *   of 3 would mean that any time there are 2 or fewer features in
   *   a cluster, those features will be added directly to the layer instead
   *   of a cluster representing those features.  Default is null (which is
   *   equivalent to 1 - meaning that clusters may contain just one feature).
   */
  threshold: null,

  /**
   * Property: features
   * {Array(<OpenLayers.Feature.Vector>)} Cached features.
   */
  features: null,

  /**
   * Property: clusters
   * {Array(<OpenLayers.Feature.Vector>)} Calculated clusters.
   */
  clusters: null,

  /**
   * Property: clustering
   * {Boolean} The strategy is currently clustering features.
   */
  clustering: false,

  /**
   * Property: resolution
   * {Float} The resolution (map units per pixel) of the current cluster set.
   */
  resolution: null,

  /**
   * Constructor: OpenLayers.Strategy.Cluster
   * Create a new clustering strategy.
   *
   * Parameters:
   * options - {Object} Optional object whose properties will be set on the
   *   instance.
   */
  initialize: function(options) {
    OpenLayers.Strategy.prototype.initialize.apply(this, [options]);
  },

  /**
   * APIMethod: activate
   * Activate the strategy.  Register any listeners, do appropriate setup.
   *
   * Returns:
   * {Boolean} The strategy was successfully activated.
   */
  activate: function() {
    var activated = OpenLayers.Strategy.prototype.activate.call(this);
    if(activated) {
      this.layer.events.on({
        "beforefeaturesadded": this.cacheFeatures,
        "moveend": this.uncluster,
        scope: this
      });
    }
    return activated;
  },

  /**
   * APIMethod: deactivate
   * Deactivate the strategy.  Unregister any listeners, do appropriate
   *   tear-down.
   *
   * Returns:
   * {Boolean} The strategy was successfully deactivated.
   */
  deactivate: function() {
    var deactivated = OpenLayers.Strategy.prototype.deactivate.call(this);
    if(deactivated) {
      this.clearCache();
      this.layer.events.un({
        "beforefeaturesadded": this.cacheFeatures,
        "moveend": this.uncluster,
        scope: this
      });
    }
    return deactivated;
  },

  /**
   * Method: cacheFeatures
   * Cache features before they are added to the layer.
   *
   * Parameters:
   * event - {Object} The event that this was listening for.  This will come
   *   with a batch of features to be clustered.
   *
   * Returns:
   * {Boolean} False to stop features from being added to the layer.
   */
  cacheFeatures: function(event) {
    var propagate = true;
    if(!this.clustering) {
      this.clearCache();
      this.features = event.features;
      this.cluster();
      propagate = false;
    }
    return propagate;
  },

  /**
   * Method: clearCache
   * Clear out the cached features.
   */
  clearCache: function() {
    this.features = null;
  },

  /**
   * Method: cluster
   * Cluster features based on some threshold distance.
   *
   * Parameters:
   * event - {Object} The event received when cluster is called as a
   *   result of a moveend event.
   */
  uncluster: function(event) {
    if((!event || event.zoomChanged) && this.features) {
      var resolution = this.layer.map.getResolution();
      if(resolution != this.resolution || !this.clustersExist()) {
        this.resolution = resolution;
        var clusters = [];
        var feature, clustered, cluster;
        for(var i=0; i<this.features.length; ++i) {
          feature = this.features[i];
          if(feature.geometry) {
            clustered = false;
            for(var j=clusters.length-1; j>=0; --j) {
              cluster = clusters[j];
              if(this.shouldCluster(cluster, feature)) {
                this.addToCluster(cluster, feature);
                clustered = true;
                break;
              }
            }
            if(!clustered) {
              clusters.push(this.createCluster(this.features[i]));
            }
          }
        }
        this.layer.removeAllFeatures();
        if(clusters.length > 0) {
          this.clustering = true;
          // A legitimate feature addition could occur during this
          // addFeatures call.  For clustering to behave well, features
          // should be removed from a layer before requesting a new batch.
          for (var i=0; i<clusters.length; ++i) {
            var cluster = this.applyUncluster(clusters[i]);
            this.layer.addFeatures(cluster);
          }
          this.clustering = false;
        }
        this.clusters = clusters;
      }
    }
  },

  applyUncluster: function(cluster) {
    var layout = new Layout(cluster, 400.0, 400.0, 0.5);

    console.log(layout);

    // if this.options.rotate label

    /*for (var i=0; i<cluster.length; ++i) {
      var highest, lowest;
      var feature = cluster[i];
      console.log(feature);
    }*/


    /*var g = new Graph();
    var last_node = false;
    for (var i=0; i<cluster.length; ++i) {
      var feature = cluster[i];
      var node = g.newNode({feature: feature});
      if (last_node) {
        g.newEdge(last_node, node);
        last_node = node;
      }
    }
    console.log(g);*/

    return cluster;
  },

  /**
   * Method: clustersExist
   * Determine whether calculated clusters are already on the layer.
   *
   * Returns:
   * {Boolean} The calculated clusters are already on the layer.
   */
  clustersExist: function() {
    var exist = false;
    if(this.clusters && this.clusters.length > 0 &&
       this.clusters.length == this.layer.features.length) {
      exist = true;
      for(var i=0; i<this.clusters.length; ++i) {
        if(this.clusters[i] != this.layer.features[i]) {
          exist = false;
          break;
        }
      }
    }
    return exist;
  },

  /**
   * Method: shouldCluster
   * Determine whether to include a feature in a given cluster.
   *
   * Parameters:
   * cluster - {<OpenLayers.Feature.Vector>} A cluster.
   * feature - {<OpenLayers.Feature.Vector>} A feature.
   *
   * Returns:
   * {Boolean} The feature should be included in the cluster.
   */
  shouldCluster: function(cluster, feature) {
    var should_cluster = false;
    for (var i=0; i<cluster.length; ++i) {
      var cf = cluster[i];
      var cc = cf.geometry.getBounds().getCenterLonLat();
      var fc = feature.geometry.getBounds().getCenterLonLat();
      should_cluster = ((
        Math.sqrt(
          Math.pow((cc.lon - fc.lon), 2) + Math.pow((cc.lat - fc.lat), 2)
        ) / this.resolution
      ) <= this.distance);
      if (should_cluster) {
        break;
      }
    }
    return should_cluster;
  },

  /**
   * Method: addToCluster
   * Add a feature to a cluster.
   *
   * Parameters:
   * cluster - {<OpenLayers.Feature.Vector>} A cluster.
   * feature - {<OpenLayers.Feature.Vector>} A feature.
   */
  addToCluster: function(cluster, feature) {
    cluster.push(feature);
    //cluster.attributes.count += 1;
  },

  /**
   * Method: createCluster
   * Given a feature, create a cluster.
   *
   * Parameters:
   * feature - {<OpenLayers.Feature.Vector>}
   *
   * Returns:
   * {Array} An array of features
   */
  createCluster: function(feature) {
    //var center = feature.geometry.getBounds().getCenterLonLat();
    /*var cluster = new OpenLayers.Feature.Vector(
      new OpenLayers.Geometry.Point(center.lon, center.lat),
      {count: 1}
    );*/
    return [feature];
    //cluster.cluster = [feature];
    //return cluster;
  },

  CLASS_NAME: "OpenLayers.Strategy.Cluster"
});
