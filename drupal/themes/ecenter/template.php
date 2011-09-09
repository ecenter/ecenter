<?php
// $Id$

function ecenter_preprocess_page(&$vars) {
  if (arg(0) == 'network' || (arg(0) && !arg(1)) || (arg(0) == 'node' && arg(2))) {
    unset($vars['breadcrumb']);
  }
  if (arg(0) == 'node' && is_numeric(arg(1))) {
    $node = node_load(arg(1));

    // Don't display node type on 'page' nodes, which are are strictly 
    // informational
    switch ($node->type) {
      case 'page':
        break;
      default:
        $vars['page_type'] = node_get_types('name', $node->type);
    }
  }
  if (arg(0) == 'node' && arg(1) == 'add' || arg(2) == 'edit') {
    $vars['body_classes'] .= ' node-edit';  
  }
}

function ecenter_preprocess_node(&$vars) {
  global $user;
  $node = $vars['node'];

  // Remove Organic Groups' group and group post template suggestions
  if ((($group_post_idx = array_search('node-og-group-post', $vars['template_files'])) !== FALSE) ||
      (($group_post_idx = array_search('node-og-group', $vars['template_files'])) !== FALSE)) {
    unset($vars['template_files'][$group_post_idx]);
  }

  // Unset author picture on group node
  if ($node->type == 'group') {
    unset($vars['picture']);
  }

  if ($vars['teaser']) {
    $vars['content'] = _ecenter_trim($node->content['body']['#value'], 250);
  }

  if ($node->type == 'issue' && !empty($node->issue_queries)
    && !$vars['teaser'] && !$vars['build_mode']) {
    _ecenter_network_add_behaviors();
    $output = '';
    foreach ($node->issue_queries as $query) {
      $output .= theme('ecenter_network_data',
        unserialize($query->field_query_data[0]['value']),
        TRUE);
    }
    $fieldset = array(
      '#title' => t('Query results'),
      '#type' => 'fieldset',
      '#collapsible' => TRUE,
      '#collapsed' => TRUE,
      '#prefix' => '<div class="page-network-weathermap query-results">',
      '#suffix' => '</div>',
      '#value' => $output,
    );
    $vars['content'] .= drupal_render($fieldset);
  }

  if ($vars['build_mode'] == 'ecenter_activity') {
    $args = explode('/', $_REQUEST['q']);
    $vars['action'] = ($node->changed > $node->created) ? t('updated by') : t('created by');
    $vars['node_type'] = node_get_types('name', $node->type);

    // Node classes
    $classes = array(
      $node->type,
    );

    if ($args[0] != 'group' && !empty($node->og_groups)) {
      $group_links = array();
      foreach ($vars['og_links']['raw'] as $link) {
        $group_links[] = l($link['title'], $link['href']);
      }
      $vars['groups'] = implode($group_links, ', ');
    }
    else {
      unset($vars['groups']);
    }

    if ($node->type == 'wiki') {
      $revisions = node_revision_list($node);
      $last_revision = array_shift($revisions);
      $last_log = _ecenter_trim($last_revision->log);
      $vars['message'] = (!empty($last_log)) ? $last_log : t('No log message.');
    }

    // If comment timestamp newer than updated, we'll display a special
    // 'commented' message, otherwise that the node was created/updated
    if ($node->last_comment_timestamp > $node->changed) {
      $date = $node->last_comment_timestamp;
      $vars['comment_mode'] = TRUE;
      if (user_access('access comments')) {
        $query = "
          SELECT c.cid as cid,
            c.pid, c.nid, c.subject, c.comment, c.format,
            c.timestamp, c.name, c.mail, c.homepage, u.uid,
            u.name AS registered_name, u.signature, u.signature_format,
            u.picture, u.data, c.thread, c.status
          FROM {comments} c
          INNER JOIN
            {users} u ON c.uid = u.uid
          WHERE
            c.nid = %d
            AND c.status = %d
          ORDER BY
            c.cid DESC
          LIMIT 1
        ";
        $last_comment = db_fetch_object(db_query($query, array($node->nid, COMMENT_PUBLISHED)));
        $author = user_load($last_comment->uid);
        $vars['message'] = _ecenter_trim($last_comment->comment);
        $vars['action'] = t('commented on');
      }
    }
    else {
      $date = $node->changed;
      $author = user_load($node->uid);

      $vars['comment_mode'] = FALSE;

      // @TODO Instead of trimming body, we might want to use pre-processed
      // body value to avoid build mode wrangling.
      $vars['message'] = _ecenter_trim($node->body);
    }

    // If message is for 'you'
    if ($user->uid && $user->uid == $author->uid) {
      $author->name = ($vars['comment_mode']) ? t('You') : t('you');
      $classes[] = 'self-author';
    }

    $vars['name'] = theme('username', $author);
    $vars['picture'] = theme('user_picture', $author);
    $vars['name_plain'] = check_plain($author->name);
    $vars['date'] = _ecenter_format_date($date);
    $vars['classes'] = implode($classes, ' ');

  }
}

function ecenter_node_submitted($node) {
  $og_links = array();
  
  if (og_is_group_post_type($node->type) && !empty($node->og_groups_both)) {
    $current_groups = og_node_groups_distinguish($node->og_groups_both, FALSE);
    foreach ($current_groups['accessible'] as $gid => $item) {
      $og_links[] = l($item['title'], 'node/'. $gid);
    }
  }

  $group = (!empty($og_links)) ? format_plural(count($og_links), ' in group !groups', ' in groups !groups', array(
    '!groups' => implode(', ', $og_links),
  )) : '';

  return t('Submitted by !username on @datetime', 
    array(
    '!username' => theme('username', $node), 
    '@datetime' => format_date($node->created),
  )) . $group;
}

/**
 * Fancy format a date
 *
 * @param $timestamp
 *  A UNIX style timestamp
 * @return
 *  A fancy formatted string representation of the date
 */
function _ecenter_format_date($timestamp) {
  $now = time();
  $diff = $now - $timestamp;

  if ($timestamp > ($now - 3600)) { // Last hour
    $diff = ceil($diff / 60);
    $date = format_plural($diff,
      '!minutes minute ago',
      '!minutes minutes ago',
      array('!minutes' => $diff)
    );
  }
  else if ($timestamp > ($now - 86400)) { // Last day
    $diff = ceil($diff / 3600);
    $date = format_plural($diff,
      '!hours hour ago',
      '!hours hours ago',
      array('!hours' => $diff)
    );
  }
  else if ($timestamp > ($now - 604800)) { // Last week
    $diff = ceil($diff / 86400);
    $date = format_plural($diff,
      '!days day ago',
      '!days days ago',
      array('!days' => $diff)
    );
  }
  else if ($timestamp > ($now - 2592000)) { // Last month
    $week = ceil($diff / 604800);
    $days = floor((604800 * $week - $diff) / 86400);
    $date = format_plural($week,
      '!weeks week',
      '!weeks weeks',
      array('!weeks' => $week)
    );
    if ($days) {
      $date .= ', '. format_plural($days,
        '!days day ',
        '!days days ',
        array('!days' => $days)
      );
    }
    $date .= ' '. t('ago');
  }
  else {
    $date = format_date($timestamp, 'custom', 'M j, Y');
  }

  return $date;
}

/**
 * Trim text for E-Center
 *
 * @param $text
 *   Text to trim
 * @param $size
 *   Length to trim the string to
 * @param $suffix
 *   A suffix to append once the string is trimmed, such as elipses
 * @return
 *   $text trimmed to a maximum length of $size (or shorter)
 */
function _ecenter_trim($text, $size = 140, $suffix = ' ...') {
  $text = filter_xss($text, array('a', 'em', 'strong', 'cite', 'code'));

  if ($size >= drupal_strlen($text)) {
    return _filter_htmlcorrector($text);
  }

  $text = truncate_utf8($text, $size);
  $reverse = strrev($text);
  $max_rpos = strlen($text);
  $min_rpos = $max_rpos;
  $break_points[] = array(
    '</a>' => 0,
    '</em>' => 0,
    '</strong>' => 0,
    '</cite>' => 0,
    '</code>' => 0,
    '. ' => 1,
    '! ' => 1,
    '? ' => 1,
    '。' => 0,
    '؟ ' => 1,
    ' ' => 0,
  );
  foreach ($break_points as $points) {
    foreach ($points as $point => $offset) {
      $rpos = strpos($reverse, strrev($point));
      if ($rpos !== FALSE) {
        $min_rpos = min($rpos + $offset, $min_rpos);
      }
    }
    if ($min_rpos !== $max_rpos) {
      return ($min_rpos === 0) ? _filter_htmlcorrector($text) . $suffix: _filter_htmlcorrector(substr($text, 0, 0 - $min_rpos)) . $suffix;
    }
  }
  return _filter_htmlcorrector($text) . $suffix;
}
