Drupal.behaviors.EcenterTraceroute = function(context) {
  $('.traceroute').traceroute();
}

Drupal.behaviors.EcenterDatehide = function(context) {
  $('#date-wrapper').datehide({
    'startDateSelector' : '#edit-date-wrapper-start-date-datepicker-popup-0',
    'startTimeSelector' : '#edit-date-wrapper-start-date-timeEntry-popup-1',
    'endDateSelector' : '#edit-date-wrapper-end-date-datepicker-popup-0',
    'endTimeSelector' : '#edit-date-wrapper-end-date-timeEntry-popup-1',
  });
}

