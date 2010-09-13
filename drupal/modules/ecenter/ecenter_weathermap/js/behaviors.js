// Add traceroute
Drupal.behaviors.EcenterTraceroute = function(context) {
  $('#traceroute').traceroute(Drupal.settings.tracerouteData);
}

// Add date hiding / showing widget
Drupal.behaviors.EcenterDatehide = function(context) {
  $('#date-wrapper').datehide({
    'startDateSelector' : '#edit-ip-select-date-wrapper-start-date-datepicker-popup-0',
    'startTimeSelector' : '#edit-ip-select-date-wrapper-start-date-timeEntry-popup-1',
    'endDateSelector'   : '#edit-ip-select-date-wrapper-end-date-datepicker-popup-0',
    'endTimeSelector'   : '#edit-ip-select-date-wrapper-end-date-timeEntry-popup-1'
  });
}

// Catchall for minor behavior modifications
Drupal.behaviors.EcenterEvents = function(context) {
  $('#ip-select-wrapper input[type=hidden]').change(function() {
    $('#results-wrapper').text('');
  });
  $('#ip-select-wrapper input#edit-ip-select-src-ip-wrapper-src-ip').change(function() {
    $('#ip-select-wrapper input#edit-ip-select-dst-ip-wrapper-dst-ip_quickselect').val('').attr('disabled', true);
  });
}

/**
 * @TODO Remove element after moving...
 */
Drupal.behaviors.EcenterRepositionResults = function(context) {
  var results = $('.end-to-end-results');
  $('#weathermap-end-to-end-results').html(results.html());
  $('#weathermap-end-to-end-results .end-to-end-results').css('display', 'block');
}

/**
 * Disable form elements during AHAH request
 *
 * Adding this to Drupal behaviors causes some serious chaos because it winds
 * up getting called many times, which the behavior only needs to be bound
 * and executed once.
 */
$(document).ready(function() {
  $('#ecenter-weathermap-select-form').bind('ahah_start', function() {
    // Add overlay...
    $(this).addClass('data-loading');
    $('input', this).each(function() {
      var disabled = $(this).attr('disabled');
      $(this).data('ecenter_disabled', disabled);
      $(this).attr('disabled', true);
    });

    overlay = $('<div class="loading-overlay"><p>' + Drupal.t('Loading') + '</p></div>');
    ip_select = $('#ip-select-wrapper');
    map = $('#weathermap-wrapper').css('position', 'relative');
    overlay.css({
      'position' : 'absolute',
      'top' : 0,
      'left' : 0,
      'width' : ip_select.outerWidth(),
      'height' : map.height(),
      'z-index' : 9999,
      'display' : 'none',
    });
    map.prepend(overlay);
    overlay.fadeIn('slow');

  });
  $('#ecenter-weathermap-select-form').bind('ahah_end', function() {
    // Add overlay...
    $(this).removeClass('data-loading');
    $('input', this).each(function() {
      var disabled = $(this).data('ecenter_disabled');
      $(this).attr('disabled', disabled);
    });

    $('#weathermap-wrapper .loading-overlay').fadeOut('fast', function() {
      $(this).remove();
    });
  });
});
