// Add traceroute
Drupal.behaviors.EcenterTraceroute = function(context) {
  $('#traceroute').traceroute(Drupal.settings.tracerouteData, Drupal.settings.tracerouteMaxLength);
}

// Add date hiding / showing widget
Drupal.behaviors.EcenterDatehide = function(context) {
  $('#date-wrapper').datehide({
    'startDateSelector' : '#edit-date-wrapper-start-date-datepicker-popup-0',
    'startTimeSelector' : '#edit-date-wrapper-start-date-timeEntry-popup-1',
    'endDateSelector' : '#edit-date-wrapper-end-date-datepicker-popup-0',
    'endTimeSelector' : '#edit-date-wrapper-end-date-timeEntry-popup-1'
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
 * Disable form elements during AHAH request
 *
 * Adding this to Drupal behaviors causes some serious chaos because it winds
 * up getting called many times, which the behavior only needs to be bound
 * and executed once.
 */
$(document).ready(function() {
  $('#ecenter-weathermap-select-form').bind('ahah_start', function() {
    $(this).addClass('data-loading');
    $('input', this).each(function() {
      var disabled = $(this).attr('disabled');
      $(this).data('ecenter_disabled', disabled);
      $(this).attr('disabled', true);
    });
  });
  $('#ecenter-weathermap-select-form').bind('ahah_end', function() {
    $(this).removeClass('data-loading');
    $('input', this).each(function() {
      var disabled = $(this).data('ecenter_disabled');
      $(this).attr('disabled', disabled);
    });
  });
});
