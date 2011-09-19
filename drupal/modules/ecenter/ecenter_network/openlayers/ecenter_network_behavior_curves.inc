<?php
// $Id$

/**
 * @file
 * Dynamically load map layers
 */

class ecenter_network_behavior_curves extends openlayers_behavior {

  function options_init() {
    return array(
      'layers' => array(),
      'style' => NULL,
      'arrow_style' => NULL,
      'divisions' => 21,
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
      'style' => array(
        '#type' => 'select',
        '#title' => t('Style'),
        '#description' => t('Style for curved lines'),
        '#options' => openlayers_ui_get_style_options(),
        '#default_value' => !empty($defaults['style']) ?
          $defaults['styles'] : NULL,
      ),
      'divisions' => array(
        '#type' => 'textfield',
        '#title' => t('Divisions'),
        '#description' => t('Number of divisions in curve'),
        '#default_value' => !empty($defaults['divisions']) ?
          $defaults['divisions'] : 21,
      ),
    );
  }

  /**
   * Render.
   */
  function render(&$map) {
    drupal_add_js(drupal_get_path('module', 'ecenter_network') .
      '/openlayers/ecenter_network_behavior_curves.js');
    $style = openlayers_style_load($this->options['style']);
    $this->options['style'] = $style->data;
    return $this->options;
  }

}
