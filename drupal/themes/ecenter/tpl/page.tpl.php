<?php
// $Id$

/**
 * @file page.tpl.php
 *
 * Theme implementation to display a single Drupal page.
 */
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php print $language->language ?>" lang="<?php print $language->language ?>" dir="<?php print $language->dir ?>" class="no-js">

<head>
  <?php print $head; ?>
  <title><?php print $head_title; ?></title>
  <?php print $styles; ?>
  <?php if (!empty($inline_css)): ?>
    <style type="text/css">
      <?php print $inline_css; ?>
    </style>
  <?php endif; ?>
  <?php print $scripts; ?>
  <script type="text/javascript"><?php /* Needed to avoid Flash of Unstyled Content in IE */ ?> </script>
</head>
<body class="<?php print $body_classes; ?>">
<div id="header-wrapper" class="clearfix">
  <div class="logo">
    <h1 id="site-name">
      <?php print $site_name; ?>
    </h1>
  </div>

  <?php if (!empty($header)): ?>
  <div id="header">
    <?php print $header; ?>
  </div>
  <?php endif; ?>
</div>

<?php if (!empty($navigation)): ?>
<div id="navigation" class="clearfix">
  <?php print $navigation; ?>
</div>
<?php endif; ?>

<?php if (!empty($messages)): print $messages; endif; ?>

<div id="page-wrapper">

  <?php if (!empty($tabs)): ?>
    <div id="tasks" class="clearfix">
      <?php print $tabs; ?>
    </div>
  <?php endif; ?>

  <div id="content-wrapper" class="clearfix">

    <?php if (!empty($left)): ?>
    <div id="sidebar-left" class="column sidebar">
      <?php print $left; ?>
    </div>
    <?php endif; ?>

    <div id="content" class="clearfix">
      <?php if ($breadcrumb): ?>
        <?php print $breadcrumb; ?>
      <?php endif; ?>
      <?php if (!empty($help)): print $help; endif; ?>

      <?php if (!empty($title)): ?><h1 class="title" id="page-title"><?php print $title; ?></h1><?php endif; ?>
      <div id="content-body">
        <?php print $content; ?>
      </div>
      <?php print $feed_icons; ?>
    </div>

    <?php if (!empty($right)): ?>
    <div id="sidebar-right" class="column sidebar">
      <?php print $right; ?>
    </div>
    <?php endif; ?>

  </div>

</div>

<div id="footer" class="clearfix">
  <?php print $footer_message; ?>
  <?php if (!empty($footer)): print $footer; endif; ?>
</div>

<?php print $closure; ?>

</body>
</html>
