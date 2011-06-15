<?php

/**
 * @file
 * Extend the EcenterService class to work with the Data Retrieval Service
 */

class AnomalyDetectionService extends EcenterService {

  public $query_types = array('hub', 'ip');

  public function getData($src, $dst, $start, $end, $data_type, $algorithm = 'spd', $detector_type = NULL, $sensitivity = NULL, $elevation1 = NULL, $elevation2 = NULL, $swc = NULL, $resolution = 50) {
    
    // Parse out query type
    list($src_type, $src_value) = explode(':', $src, 2);
    list($dst_type, $dst_value) = explode(':', $dst, 2);

    if (array_search($src_type, $this->query_types) === FALSE
      && array_search($dst_type, $this->query_types) !== FALSE) {
      throw new Exception('Invalid source query type.');
    }
    else if (array_search($src_type, $this->query_types) !== FALSE
      && array_search($dst_type, $this->query_types) === FALSE) {
      throw new Exception('Invalid destination query type.');
    }
    else if (array_search($src_type, $this->query_types) === FALSE
      && array_search($dst_type, $this->query_types) === FALSE) {
      throw new Exception('Invalid source and destination query types.');
    }

    $params = array(
      'src' => array(
        'query' => array('src_'. $src_type => $src_value),
        'type' => $src_type,
        'value' => $src_value,
      ),  
      'dst' => array(
        'query' => array('dst_'. $dst_type => $dst_value),
        'type' => $dst_type,
        'value' => $dst_value,
      ),  
      'start' => $start,
      'end' => $end,
      'data_type' => $data_type,
    );

    return $this->query($algorithm, $params);
  }

  public function postData($data) {
    return $this->post('test', array('data' => $data));
  }
}
