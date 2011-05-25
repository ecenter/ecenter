<?php

/**
 * Implementation of hook_openlayers_layers().
 */
function ecenter_network_openlayers_layers() {
  $export = array();
  $openlayers_layers = new stdClass;
  $openlayers_layers->disabled = FALSE; /* Edit this to true to make a default openlayers_layers disabled initially */
  $openlayers_layers->api_version = 1;
  $openlayers_layers->name = 'ecenter_network_sites';
  $openlayers_layers->title = 'E-center Network Sites';
  $openlayers_layers->description = '';
  $openlayers_layers->data = array(
    'layer_type' => 'openlayers_layer_type_raw',
    'projection' => array(
      0 => '900913',
    ),
    'features' => array(
      0 => array(
        'wkt' => 'POINT(-87.9804 41.3144)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'ANL',
          'labelYOffset' => -20,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
          'labelXOffset' => 4,
        ),
        'extra' => array(
          'ecenterID' => 'ANL',
          'coords' => array(
            'lat' => '41.7144',
            'lon' => '-87.9804',
          ),
        ),
      ),
      1 => array(
        'wkt' => 'POINT(-72.8805 40.8703)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'BNL',
          'labelYOffset' => 17,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
        ),
        'extra' => array(
          'ecenterID' => 'BNL',
          'coords' => array(
            'lat' => '40.8703',
            'lon' => '-72.8805',
          ),
        ),
      ),
      2 => array(
        'wkt' => 'POINT(-88.255 41.8414)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'FNAL',
          'labelYOffset' => 17,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
        ),
        'extra' => array(
          'ecenterID' => 'FNAL',
          'coords' => array(
            'lat' => '41.8414',
            'lon' => '-88.255',
          ),
        ),
      ),
      3 => array(
        'wkt' => 'POINT(-121.923 38.6306)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'JGI',
          'labelYOffset' => 15,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
          'labelXOffset' => 5,
        ),
        'extra' => array(
          'ecenterID' => 'JGI',
          'coords' => array(
            'lat' => '37.9306',
            'lon' => '-122.023',
          ),
        ),
      ),
      4 => array(
        'wkt' => 'POINT(-121.452 38.1269)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'LBL',
          'labelYOffset' => 5,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
          'labelXOffset' => 24,
        ),
        'extra' => array(
          'ecenterID' => 'LBL',
          'coords' => array(
            'lat' => '37.8769',
            'lon' => '-122.252',
          ),
        ),
      ),
      5 => array(
        'wkt' => 'POINT(-121.563 36.9868)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'LLNL',
          'labelYOffset' => -15,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
          'labelXOffset' => 15,
        ),
        'extra' => array(
          'ecenterID' => 'LLNL',
          'coords' => array(
            'lat' => '37.6868',
            'lon' => '-121.713',
          ),
        ),
      ),
      6 => array(
        'wkt' => 'POINT(-122.668 38.2086)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'NERSC',
          'labelYOffset' => 5,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
          'labelXOffset' => -37,
        ),
        'extra' => array(
          'ecenterID' => 'NERSC',
          'coords' => array(
            'lat' => '37.8086',
            'lon' => '-122.268',
          ),
        ),
      ),
      7 => array(
        'wkt' => 'POINT(-84.2697 36.0103)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'ORNL',
          'labelYOffset' => 17,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
        ),
        'extra' => array(
          'ecenterID' => 'ORNL',
          'coords' => array(
            'lat' => '36.0103',
            'lon' => '-84.2697',
          ),
        ),
      ),
      8 => array(
        'wkt' => 'POINT(-122.339 47.6144)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'PNWG',
          'labelYOffset' => 17,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
        ),
        'extra' => array(
          'ecenterID' => 'PNWG',
          'coords' => array(
            'lat' => '47.6144',
            'lon' => '-122.339',
          ),
        ),
      ),
      9 => array(
        'wkt' => 'POINT(-74.6525 40.3808)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'PPPL',
          'labelYOffset' => -20,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
          'labelXOffset' => -5,
        ),
        'extra' => array(
          'ecenterID' => 'PPPL',
          'coords' => array(
            'lat' => '40.3808',
            'lon' => '-74.6525',
          ),
        ),
      ),
      10 => array(
        'wkt' => 'POINT(-122.204 37.4211)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'SLAC',
          'labelYOffset' => -5,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
          'labelXOffset' => -30,
        ),
        'extra' => array(
          'ecenterID' => 'SLAC',
          'coords' => array(
            'lat' => '37.4211',
            'lon' => '-122.204',
          ),
        ),
      ),
      11 => array(
        'wkt' => 'POINT(-121.256 37.4779)',
        'projection' => '4326',
        'style' => array(
          'pointRadius' => 5,
          'fillColor' => '#ffffff',
          'fillOpacity' => 1,
          'strokeColor' => '#4682b4',
          'strokeWidth' => 3,
          'strokeOpacity' => 1,
          'label' => 'SNLL',
          'labelYOffset' => 0,
          'fontWeight' => 'bold',
          'fontSize' => '14px',
          'fontFamily' => '"Droid Sans", "Helvetica Neue", Helvetica, Verdana, sans-serif',
          'fontColor' => '#4682B4',
          'labelXOffset' => 30,
        ),
        'extra' => array(
          'ecenterID' => 'SNLL',
          'coords' => array(
            'lat' => '37.6779',
            'lon' => '-121.706',
          ),
        ),
      ),
    ),
  );

  $export['ecenter_network_sites'] = $openlayers_layers;
  return $export;
}
