// Test behaviors...

(function($) {

Drupal.behaviors.EcenterTestTraceroute = function(context) {
  for (var key in Drupal.settings.ecenter_test_traceroute) {
    var trace = Drupal.settings.ecenter_test_traceroute[key];
    $('#' + trace.id + ' .visual-traceroute-wrapper').traceroute(trace.diff);
  }
}

}) (jQuery);
