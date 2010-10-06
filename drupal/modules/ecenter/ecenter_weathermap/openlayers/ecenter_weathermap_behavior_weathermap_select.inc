<?php
// $Id$

/**
 * @file
 * Dynamically load map layers
 */

class ecenter_weathermap_behavior_weathermap_select extends openlayers_behavior {

  function options_init() {
    return array(
      'input_fields' => '',
    );
  }

  function render(&$map) {
    drupal_add_js(drupal_get_path('module', 'ecenter_weathermap') .'/openlayers/ecenter_weathermap_behavior_weathermap_select.js');
    return $this->options;
  }

}
