<?php
// $Id$

/**
 * @file
 * Extend the EcenterService class to work with the Data Retrieval Service
 */

class DataRetrievalService extends EcenterService {

  /**
   * Provide a "backdoor" technique for extending available datatypes
   */
  public $query_types = array('hub', 'ip');

  /**
   * Get hubs
   *
   * @return
   *   An array of hubs.
   */
  public function getHubs() {
    return $this->query('hub');
  }

  /**
   * Get hops
   *
   * @param $src_ip
   *   (optional) Source IP.  If provided, will return all destinations for this
   *   source.
   * @return
   *   An array of hops.
   */
  public function getHops($src = FALSE, $src_type = 'hub') {
    if ($src && $src_type == 'hub') {
      $q = 'hubs/' . $src;
    }
    else if ($src) {
      $q = 'destination/' . $src;
    }
    else {
      $q = 'source';
    }
    return $this->query($q);
  }

  /**
   * Get data from service
   *
   * @param $src
   *   Source, of the form <query_type>:<source identifier>.
   * @param $dst
   *   Destination, of the form <query_type>:<destination identifier>.
   * @param $start
   *   Start time.
   * @param $end
   *   End time.
   * @param $resolution
   *   (optional) Maximum number of data points to return for any measurement.
   * @return
   *   Result for this query.
   */
  public function getData($src, $dst, $start, $end, $resolution = 50) {

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
      'resolution' => $resolution,
    );

    return $this->query('data', $params);
  }

  /**
   * Get data from pasted traceroute
   *
   * @param $traceroute
   *   String output from traceroute command
   * @param $start
   *   Start time.
   * @param $end
   *   End time.
   * @param $resolution
   *   (optional) Maximum number of data points to return for any measurement.
   * @return
   *   Result for this query.
   */
  public function getTraceroute($traceroute, $start, $end, $resolution = 50) {
    $data = array(
      'trace' => $traceroute,
      'start' => $start,
      'end' => $end,
      'resolution' => $resolution,
    );
    return $this->post('data', $data);
  }

  /**
   * Get node
   * 
   * @param $ip
   *   IP address to query for
   * @return 
   *   Result for this query
   */
  public function getNode($ip) {
    return $this->query('node/'. $ip);
  }

  /**
   * Get service health over a given time frame
   *
   * @param $start
   *   Start time.
   * @param $end
   *   End time.
   * @return
   *   Result for this query.
   */
  public function getHealth($start, $end) {
    $params = array(
      'start' => $start,
      'end' => $end,
    );
    return $this->query('health', $params);
  }

  /**
   * Get site centric data
   *
   * @param $site
   *   Hubname to get data for
   * @param $start
   *   Start time.
   * @param $end
   *   End time.
   * @param $only_data
   *   Only return basic data (no additional information).
   * @param $resolution
   *   (optional) Maximum number of data points to return for any measurement.
   * @return
   *   Result for this query.
   */
  public function getSiteCentricData($site, $start, $end, $only_data = FALSE, $resolution = 50) {
    $params = array(
      'src_hub' => $site,
      'start' => $start,
      'end' => $end,
      'only_data' => $only_data,
      'resolution' => $resolution,
    );
    return $this->query('site', $params);
  }

}
