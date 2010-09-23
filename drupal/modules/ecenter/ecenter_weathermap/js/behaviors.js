// Add traceroute
Drupal.behaviors.EcenterTraceroute = function(context) {
  if (Drupal.settings.ecenterWeathermap && Drupal.settings.ecenterWeathermap.tracerouteData) {
    $('#traceroute').traceroute(Drupal.settings.ecenterWeathermap.tracerouteData);
  }
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
 * @TODO not working at all, and not all that important
 */
/*Drupal.behaviors.EcenterRepositionMessages = function(context) {
  var messages = $('#ecenter-weathermap-select-form .messages');
  $('#ecenter-weathermap-select-form #weathermap-debug').fadeOut().html(messages.html()).slideDown();
  //messages.remove();
}*/

/**
 * Disable form elements during AHAH request
 *
 * Adding this to Drupal behaviors causes some serious chaos because it winds
 * up getting called many times, which the behavior only needs to be bound
 * and executed once.
 */
$(document).ready(function() {

  // Bind to ahah_start event
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

  // Behind to ahah_end event
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

  // Bind to series highlighting
  $('#results').bind('jqplotHighlightSeries', function(e, sidx, plot) {
    var hop = Drupal.settings.ecenterWeathermap.seriesLookup.idx[sidx];
    var tc = $('#results').data('TableChart');
    var lh = tc.chart.plugins.linehighlighter;

    // Highlight corresponding line
    /*if (hop.corresponding_idx) {
      sidx = hop.corresponding_idx;
      s = tc.chart.series[sidx];
      console.log(hop);
      console.log(s);
      if (s == undefined) {
        console.log(tc.chart.series);
        console.log(sidx);
      }
      console.log('---');
      //series_color = (lh.colors && lh.colors[sidx] != undefined) ? lh.colors[sidx] : s.seriesColors[sidx];
      //var opts = {color: series_color, lineWidth: s.lineWidth + lh.sizeAdjust};
      //lh.highlightSeries(sidx, tc.chart, opts);
    }*/

    $('#trace-hop-label-' + hop.id).addClass('highlight');
    if (hop.corresponding_id) {
      $('#trace-hop-label-' + hop.corresponding_id).addClass('highlight');
    }
  });

  $('#results').bind('jqplotUnhighlightSeries', function(e, sidx, plot) {
    $('.trace-label').removeClass('highlight');
  });

});


