<?php
// $Id$

function ecenter_preprocess_page(&$vars) {
  if (arg(0) == 'network' || (arg(0) && !arg(1)) || (arg(0) == 'node' && arg(2))) {
    unset($vars['breadcrumb']);
  }
  if (arg(0) == 'node' && is_numeric(arg(1))) {
    $node = node_load(arg(1));
    $vars['page_type'] = node_get_types('name', $node->type);
  }
}
