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


function ecenter_preprocess_node(&$vars) {
  if ($vars['build_mode'] == 'ecenter_activity') {
    $node = $vars['node'];
    $author = user_load($node->uid);

    $vars['action'] = ($node->changed > $node->created) ? t('updated by') : t('created by');
    $vars['node_type'] = node_get_types('name', $node->type);

    // @TODO handle commenting shiz

    // Fancy date formatting
    $now = time();

    // Which sort 'won'?
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
        $last_comment_user = user_load($last_comment->uid);
        $vars['name'] = theme('username', $last_comment_user);
        $vars['picture'] = theme('user_picture', $last_comment_user);
        $vars['name_plain'] = $last_comment_user->name;
        $vars['message'] = _ecenter_trim($last_comment->comment);
        $vars['action'] = t('commented on');
      }
    }
    else {
      $date = $node->changed;
      $vars['comment_mode'] = FALSE;
      $vars['message'] = _ecenter_trim($node->body);
      $vars['name_plain'] = $author->name;
    }
    $diff = $now - $date;

    if ($date > ($now - 3600)) { // Last hour
      $diff = ceil($diff / 60);
      $vars['date'] = format_plural($diff,
        '!minutes minute ago',
        '!minutes minutes ago',
        array('!minutes' => $diff)
      );
    }
    else if ($date > ($now - 86400)) { // Last day
      $diff = ceil($diff / 3600);
      $vars['date'] = format_plural($diff,
        '!hours hour ago',
        '!hours hours ago',
        array('!hours' => $diff)
      );
    }
    else if ($date > ($now - 604800)) { // Last week
      $diff = ceil($diff / 86400);
      $vars['date'] = format_plural($diff,
        '!days day ago',
        '!days days ago',
        array('!days' => $diff)
      );
    }
    else if ($date > ($now - 2592000)) { // Last month
      $week = ceil($diff / 604800);
      $days = floor((604800 * $week - $diff) / 86400);
      $vars['date'] = format_plural($week,
        '!weeks week',
        '!weeks weeks',
        array('!weeks' => $week)
      );
      if ($days) {
        $vars['date'] .= ', '. format_plural($days,
          '!days day ',
          '!days days ',
          array('!days' => $days)
        );
      }
      $vars['date'] .= ' '. t('ago');
    }
    else {
      $vars['date'] = format_date($date, 'custom', 'M j, Y');
    }

    if (!empty($node->og_groups)) {
      $group_links = array();
      foreach ($vars['og_links']['raw'] as $link) {
        $group_links[] = l($link['title'], $link['href']);
      }
      $vars['groups'] = implode($group_links, ', ');
    }
    if ($node->type == 'wiki') {
      $revisions = node_revision_list($node);
      $last_revision = array_shift($revisions);
      $last_log = _ecenter_trim($last_revision->log);
      $vars['message'] = (!empty($last_log)) ? $last_log : t('No log message.');
    }
  }
}

/**
 * @function _ecenter_trim
 *
 * Safely trim text
 *
 * @TODO configurable breakpoints?
 *
 * @param $text
 *   String to trim
 * @param $size
 *   Maximum length to trim to
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
