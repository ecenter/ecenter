<?php
// $Id$

/**
 * Theme services for use in options list.  Should always return plaintext!
 */
function theme_ecenter_weathermap_hop_option($hop) {
  return $hop->nodename .' ('. $hop->ip_noted .')';
}
