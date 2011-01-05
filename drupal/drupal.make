core = 6.x
api = 2

projects[drupal][version] = "6.20"

; Patch Drupal to use jQuery 1.4 (see http://drupal.org/node/479368)
projects[drupal][patch][] = "http://drupal.org/files/issues/do479468-drupal_to_js-expanded-comments-nostatic.patch"


