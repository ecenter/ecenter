<?php
// $Id$

/**
 * @file
 * Dynamically load map layers
 */

class ecenter_network_behavior_dynamicload extends openlayers_behavior {

  function options_init() {
    return array(
      'input_fields' => '',
    );
  }

  function render(&$map) {
    drupal_add_js(drupal_get_path('module', 'ecenter_network') .
      '/openlayers/ecenter_network_behavior_dynamicload.js');
    return $this->options;
  }

}
