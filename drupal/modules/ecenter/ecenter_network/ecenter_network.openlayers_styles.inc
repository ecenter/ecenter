<?php

/**
 * Implementation of hook_openlayers_styles().
 */
function ecenter_network_openlayers_styles() {
  $export = array();
  $openlayers_styles = new stdClass;
  $openlayers_styles->disabled = FALSE; /* Edit this to true to make a default openlayers_styles disabled initially */
  $openlayers_styles->api_version = 1;
  $openlayers_styles->name = 'ecenter_curve';
  $openlayers_styles->title = 'E-center curve style';
  $openlayers_styles->description = 'Basic e-center curve style.';
  $openlayers_styles->data = array(
    'pointRadius' => 0,
    'strokeColor' => '#777777',
    'strokeWidth' => 4,
  );

  $export['ecenter_curve'] = $openlayers_styles;
  $openlayers_styles = new stdClass;
  $openlayers_styles->disabled = FALSE; /* Edit this to true to make a default openlayers_styles disabled initially */
  $openlayers_styles->api_version = 1;
  $openlayers_styles->name = 'ecenter_default';
  $openlayers_styles->title = 'E-center style';
  $openlayers_styles->description = 'Basic e-center style.';
  $openlayers_styles->data = array(
    'pointRadius' => 6,
    'fillColor' => '#ffffff',
    'strokeColor' => '#0000aa',
    'strokeWidth' => 2,
    'fillOpacity' => 1,
  );

  $export['ecenter_default'] = $openlayers_styles;
  $openlayers_styles = new stdClass;
  $openlayers_styles->disabled = FALSE; /* Edit this to true to make a default openlayers_styles disabled initially */
  $openlayers_styles->api_version = 1;
  $openlayers_styles->name = 'ecenter_selected';
  $openlayers_styles->title = 'E-center selected style';
  $openlayers_styles->description = 'Basic e-center style.';
  $openlayers_styles->data = array(
    'pointRadius' => 6,
    'fillColor' => '#ffffff',
    'strokeColor' => '#777777',
    'strokeWidth' => 2,
    'fillOpacity' => 1,
  );

  $export['ecenter_selected'] = $openlayers_styles;
  return $export;
}
