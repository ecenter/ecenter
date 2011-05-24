/**
 * @file behaviors-health.js
 */

(function($) {

/**
 * Drupal behavior to format health display
 */
Drupal.behaviors.EcenterNetworkHealth = function(context) {
  $('table.network-health table').each(function() {
    var table = $(this);
    
    if (table.hasClass('critical')) {
      var klass = 'critical';
    } else if (table.hasClass('marginal')) {
      var klass = 'marginal';
    } else {
      var klass = 'normal';
    }

    var marker = $('<div class="marker">')
      .addClass(klass)
      .bt(table.html());

    table
      .after(marker)
      .hide();
  });
}

})(jQuery);
