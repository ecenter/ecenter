// Add traceroute
Drupal.behaviors.EcenterTraceroute = function(context) {
  $('.traceroute-wrapper').traceroute();
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
