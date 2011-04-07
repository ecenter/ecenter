<?php
// $Id$

function ecenter_preprocess_page(&$vars) {
  if (arg(0) == 'network' || arg(0) == '<front>') {
    unset($vars['breadcrumb']);
  }
  if (arg(0) == 'network' && $_GET['modal']) {
    $vars['body_classes'] .= ' modal';
  }
}
