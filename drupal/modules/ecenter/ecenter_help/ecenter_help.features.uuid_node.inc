<?php

/**
 * Implementation of hook_uuid_features_default_content().
 */
function ecenter_help_uuid_features_default_content() {
  $nodes = array();

  $nodes[] = array(
    'type' => 'wiki',
    'language' => '',
    'uid' => '1',
    'status' => '1',
    'created' => '1323710681',
    'changed' => '1323710681',
    'comment' => '0',
    'promote' => '0',
    'moderate' => '0',
    'sticky' => '0',
    'tnid' => '0',
    'translate' => '0',
    'revision_uid' => '1',
    'title' => 'Frontend installation guide',
    'body' => 'The E-Center frontend is packaged as a Drupal 6 distribution. The E-Center distribution follows the standard [Drupal installation procedure][1] and assumes you have a basic understanding of the Drupal installation procedure and PHP web application administration.
  
  The core E-Center network analysis functionality requires a running version of the Data Retrieval Service. See the [DRS deployment guide][2] or [contact the Fermilab E-Center team][3] for access to the FNAL Data Retrieval Service.
  
  ## Download E-Center
  
  ### From zipped file
  
  Download the appropriate (usually the most recent) release from [the downloads page][4] and extract in your webroot.
  
  ### From code repository
  
  You must have [Drush][5] and [Drush make][6] installed to build E-Center from scratch. Clone from Git repository:
  
  <pre>git clone https://github.com/ecenter/ecenter.git
  </pre>
  
  Run the build script:
  
  <pre>cd ecenter/drupal
  ./build.sh /var/www/ecenter
  </pre>
  
  this command will create an E-Center instance in the `/var/www/ecenter` directory. You may pass the `--tar` flag to create a gzipped tarball of the built distribution or the `--working-copy` flag to build E-Center for local development.
  
  ## Installing E-Center
  
  Extract or copy the E-Center codebase to your webroot. Follow the Drupal guide to [create a database][7] and [edit the settings.php file][8] (the distribution comes with a pre-generated settings.php file).
  
  Now, head to the default Drupal install URL `http://ecenter.myhost.tld/install.php`.
  
  ### Select E-Center profile
  
  If your configuration is correct, you will see a profile selection screen. Select the "E-Center" profile.
  
  ![Select E-Center profile option][9]
  
  ### Configure Drupal and E-Center
  
  At this point, Drupal is installed. Fill in the standard Drupal configuration details. As shown below, you may need to edit file permissions on the settings file that comes with the E-Center distribution.
  
  ![Configure Drupal][10]
  
  This is where we depart from the standard Drupal installation. Enter configuration details for each Data Retrieval Service instance. You may always add or change this information later.
  
  ![Configure Data Retrieval Service][11]
  
  Configure DRS caching. The defaults, which aggressively cache DRS results, should be appropriate for most E-Center deployments, and should only be disabled in development and for debugging:
  
  ![Configure DRS caching][12]
  
  ## Post-installation tasks
  
  ### Cron configuration (required)
  
  Work in progress...
  
  ### Site administration
  
  *   You may always change the E-Center data service configuration by visiting<span class="Apple-converted-space"> </span>`admin/settings/ecenter`<span class="Apple-converted-space"> </span>(relative to your webroot).
  *   You will likely want to enable some performance settings for production sites at<span class="Apple-converted-space"> </span>`admin/settings/performance`. E-Center is incompatible with aggressive mode caching and block caching. E-Center has been tested to work with normal mode caching, CSS optimization, and Javascript optimization.
  *   You may wish to change the default security and permissions settings: See the Drupal documentation on [roles][13] and [permissions][14].
  
  ### For developers
  
  The Drupal `devel` module is included in the E-Center distribution. Enable `devel` and `simplemenu_devel` from the modules page or using `drush`.
  
   [1]: http://drupal.org/documentation/install
   [2]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/DEPLOYMENT.markdown
   [3]: /contact
   [4]: https://github.com/ecenter/ecenter/downloads
   [5]: http://drupal.org/project/drush
   [6]: http://drupal.org/project/drush_make
   [7]: http://drupal.org/documentation/install/create-database
   [8]: http://drupal.org/documentation/install/settings-file
   [9]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/select-profile-annotated.png
   [10]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-01.png
   [11]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-02-drs.png
   [12]: https://cdcvs.fnal.gov/redmine/projects/ecenter/repository/revisions/master/entry/drupal/docs/img/configure-site-03-drs-perf.png
   [13]: http://drupal.org/getting-started/6/admin/user/roles
   [14]: http://drupal.org/getting-started/6/admin/user/permissions',
    'teaser' => 'The E-Center frontend is packaged as a Drupal 6 distribution. The E-Center distribution follows the standard [Drupal installation procedure][1] and assumes you have a basic understanding of the Drupal installation procedure and PHP web application administration.
  
  The core E-Center network analysis functionality requires a running version of the Data Retrieval Service.',
    'log' => '',
    'revision_timestamp' => '1323710681',
    'format' => '3',
    'name' => 'admin',
    'picture' => '',
    'data' => 'a:1:{s:23:"ecenter_network_queries";a:6:{s:98:"src=hub%3AFNAL&amp;dst=hub%3AANL&amp;start=2011-12-08+15%3A30%3A00&amp;end=2011-12-08+18%3A30%3A00";a:2:{s:4:"time";i:1323369249;s:5:"query";s:98:"src=hub%3AFNAL&amp;dst=hub%3AANL&amp;start=2011-12-08+15%3A30%3A00&amp;end=2011-12-08+18%3A30%3A00";}s:99:"src=hub%3AFNAL&amp;dst=hub%3ALLNL&amp;start=2011-12-08+15%3A30%3A00&amp;end=2011-12-08+18%3A30%3A00";a:2:{s:4:"time";i:1323369256;s:5:"query";s:99:"src=hub%3AFNAL&amp;dst=hub%3ALLNL&amp;start=2011-12-08+15%3A30%3A00&amp;end=2011-12-08+18%3A30%3A00";}s:99:"src=hub%3ASLAC&amp;dst=hub%3AFNAL&amp;start=2011-12-08+18%3A00%3A00&amp;end=2011-12-08+21%3A00%3A00";a:2:{s:4:"time";i:1323377640;s:5:"query";s:99:"src=hub%3ASLAC&amp;dst=hub%3AFNAL&amp;start=2011-12-08+18%3A00%3A00&amp;end=2011-12-08+21%3A00%3A00";}s:99:"src=hub%3ASLAC&amp;dst=hub%3AFNAL&amp;start=2011-12-07+21%3A00%3A00&amp;end=2011-12-08+21%3A00%3A00";a:2:{s:4:"time";i:1323450198;s:5:"query";s:99:"src=hub%3ASLAC&amp;dst=hub%3AFNAL&amp;start=2011-12-07+21%3A00%3A00&amp;end=2011-12-08+21%3A00%3A00";}s:99:"src=hub%3ASLAC&amp;dst=hub%3AFNAL&amp;start=2011-12-09+14%3A00%3A00&amp;end=2011-12-09+17%3A00%3A00";a:2:{s:4:"time";i:1323463792;s:5:"query";s:99:"src=hub%3ASLAC&amp;dst=hub%3AFNAL&amp;start=2011-12-09+14%3A00%3A00&amp;end=2011-12-09+17%3A00%3A00";}s:99:"src=hub%3APNWG&amp;dst=hub%3APPPL&amp;start=2011-12-09+18%3A30%3A00&amp;end=2011-12-09+21%3A30%3A00";a:2:{s:4:"time";i:1323466311;s:5:"query";s:99:"src=hub%3APNWG&amp;dst=hub%3APPPL&amp;start=2011-12-09+18%3A30%3A00&amp;end=2011-12-09+21%3A30%3A00";}}}',
    'path' => 'content/frontend-installation-guide',
    'og_groups_both' => array(),
    'og_groups' => array(),
    'tableofcontents_toc_automatic' => '0',
    'og_public' => TRUE,
    'last_comment_timestamp' => '1323710681',
    'last_comment_name' => NULL,
    'comment_count' => '0',
    'taxonomy' => array(
      '1' => array(
        'tid' => '1',
        'vid' => '2',
        'name' => 'E-Center Documentation',
        'description' => '',
        'weight' => '0',
      ),
    ),
    'uuid' => 'b0a988e6-24e8-11e1-b676-0026b9b97a6a',
    'revision_uuid' => 'b0a9ad8a-24e8-11e1-b676-0026b9b97a6a',
    'pathauto_perform_alias' => FALSE,
    'date' => '2011-12-12 11:24:41 -0600',
    'uuid_term' => array(
      '0' => 'b0acb2e6-24e8-11e1-b676-0026b9b97a6a',
    ),
  );
  return $nodes;
}
