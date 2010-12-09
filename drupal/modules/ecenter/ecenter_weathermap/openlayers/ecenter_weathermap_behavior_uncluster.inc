<?php
// $Id: openlayers_behavior_cluster.inc,v 1.1.2.3 2010/07/21 09:38:30 strk Exp $

/**
 * @file
 * Implementation of OpenLayers Cluster behavior.
 */

/**
 * Cluster behavior
 */
class ecenter_weathermap_behavior_uncluster extends openlayers_behavior {
  /**
   * Provide initial values for options.
   */
  function options_init() {
    return array(
      'unclusterlayer' => array(),
      //'distance' => '20',
      //'push_distance' => '20',
    );
  }

  /**
   * Provide form for configurations per map.
   */
  function options_form($defaults) {
    // Only prompt for vector layers
    $vector_layers = array();
    foreach ($this->map['layers'] as $id => $name) {
      $layer = openlayers_layer_load($id);
      if (isset($layer->data['vector']) && $layer->data['vector'] == TRUE) {
        $vector_layers[$id] = $name;
      }
    }

    return array(
      'unclusterlayer' => array(
        '#title' => t('Layers'),
        '#type' => 'checkboxes',
        '#options' => $vector_layers,
        '#description' => t('Select layers to cluster.'),
        '#default_value' => isset($defaults['unclusterlayer']) ? 
        $defaults['unclusterlayer'] : array(),
      ),
      /*'distance' => array(
        '#type' => 'textfield',
        '#default_value' => (isset($defaults['distance'])) ?
        $defaults['distance'] : 20,
        '#size' => 5,
        '#title' => t('Distance'),
        '#description' => t('Pixel distance between features that should ' .
          'be unclustered'),
      ),
      'push_distance' => array(
        '#type' => 'textfield',
        '#default_value' => (isset($defaults['push_distance'])) ?
        $defaults['push_distance'] : 20,
        '#size' => 5,
        '#title' => t('Push distance'),
        '#description' => t('Amount of distance to create between unclustered ' .
          'features'),
      ),*/
    );
  }

  /**
   * Render.
   */
  function render(&$map) {
    drupal_add_js(drupal_get_path('module', 'ecenter_weathermap') .
      '/openlayers/springy.js');
    drupal_add_js(drupal_get_path('module', 'ecenter_weathermap') .
      '/openlayers/Uncluster.js');
    drupal_add_js(drupal_get_path('module', 'ecenter_weathermap') .
      '/openlayers/ecenter_weathermap_behavior_uncluster.js');
    return $this->options;
  }
}
