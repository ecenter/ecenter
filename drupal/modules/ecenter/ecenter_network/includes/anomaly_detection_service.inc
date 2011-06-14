<?php

/**
 * @file
 * Extend the EcenterService class to work with the Data Retrieval Service
 */

class AnomalyDetectionService extends EcenterService {

  public $query_types = array('hub', 'ip');

  public function analyzeLiveData($src, $dst, $start, $end, $data_type, $detector_type, $sensitivity, $elevation1, $elevation2, $swc, $resolution = 50) {
    dpm('arg!!!');
  }

  public function analyzeStaticData($data) {
  }
}
