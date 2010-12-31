<?php
// $Id$

/**
 * @file
 * Dynamically load map layers
 */

class ecenter_network_behavior_weathermap_select extends openlayers_behavior {

  function options_init() {
    return array(
      'layers' => array(),
    );
  }

  /**
   * Form defintion for per map customizations.
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
      'layers' => array(
        '#title' => t('Layers'),
        '#type' => 'checkboxes',
        '#options' => $vector_layers,
        '#description' => t('Select layer to apply tooltips to.'),
        '#default_value' => isset($defaults['layers']) ? 
          $defaults['layers'] : array(),
      ),
    );
  }

  /**
   * Render.
   */
  function render(&$map) {
    drupal_add_js(drupal_get_path('module', 'ecenter_network') .'/openlayers/ecenter_network_behavior_weathermap_select.js');
    return $this->options;
  }

}
