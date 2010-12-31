core = 6.x
api = 2

projects[drupal][version] = "6.20"

; Patch Drupal to use jQuery 1.4 
projects[drupal][patch][] = "http://drupal.org/files/issues/do479368-drupal_json_encode_0.patch"


