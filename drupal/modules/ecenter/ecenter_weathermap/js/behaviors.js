// Add traceroute
Drupal.behaviors.EcenterTraceroute = function(context) {
  if (Drupal.settings.ecenterWeathermap && Drupal.settings.ecenterWeathermap.tracerouteData) {
    $('#traceroute').traceroute(Drupal.settings.ecenterWeathermap.tracerouteData);
  }
}

// Catchall for minor behavior modifications
Drupal.behaviors.EcenterEvents = function(context) {
  $('#query input[type=hidden]').change(function() {
    $('#results-wrapper').text('');
  });
  $('#edit-weathermap-wrapper-query-src-wrapper-src-wrapper input').change(function() {
    var input = $('#edit-weathermap-wrapper-query-dst-wrapper-dst-wrapper input');
    input.val('');
    input.data('autocomplete')._trigger('change');
  });
}

// 
Drupal.behaviors.EcenterSelectSetForm = function(context) {
  var src = $('#edit-weathermap-wrapper-query-src-wrapper-src');
  var dst = $('#edit-weathermap-wrapper-query-dst-wrapper-dst');

  if (src.val()) {
    EcenterWeathermap.selectFeature.call(src.get(0), true)
  }
  if (dst.val()) {
    EcenterWeathermap.selectFeature.call(dst.get(0), true)
  }
}

Drupal.behaviors.EcenterShowTables = function(context) {
  var show_label = Drupal.t('Show data tables');
  var hide_label = Drupal.t('Hide data tables');
  $('.tablechart', context).after('<div class="toggle-data button">' + show_label + '</div>');
  $('.toggle-data', context).toggle(function() {
    $(this).text(hide_label);
    $('.snmp-data-table').show();
  }, function() {
    $(this).text(show_label);
    $('.snmp-data-table').hide();
  });
}


EcenterWeathermap = {};

/**
 * select param calls select function on feature
 */
EcenterWeathermap.selectFeature = function(select) {
   var maps = Drupal.settings.openlayers.maps;
   var val = $(this).val().split(':', 2);
   var query_type = val[0];
   var query_value = val[1];

   // Iterate over "all" maps for ease.  There should be but one.
   if (query_type == 'hub') {
     for (key in maps) {
       var ol = $('#' + maps[key].id).data('openlayers');
       var layer = ol.openlayers.getLayersBy('drupalID', 'ecenter_weathermap_sites').pop();
       var control = ol.openlayers.getControlsBy('ecenterID', 'ecenter_weathermap_select').pop();
       var feature = layer.getFeatureBy('ecenterID', query_value);


       // If this is called while loading, we have a problem
       if (control && feature) { 
         control.callbacks.over.call(control, feature);
         if (select) {
           control.select.call(control, feature);
         }
       }
     }
   }
}

/**
 * Disable form elements during AHAH request
 *
 * Adding this to Drupal behaviors causes some serious chaos because it winds
 * up getting called many times, which the behavior only needs to be bound
 * and executed once.
 */
$(document).ready(function() {

  $('#ecenter-weathermap-select-form #src-wrapper select, #ecenter-weathermap-select-form #dst-wrapper select')
  .change(function(e) { 
    EcenterWeathermap.selectFeature.call(this, true);
  });

  // Bind to ahah_start event
  $('#ecenter-weathermap-select-form').bind('ahah_start', function() {
    self = this;

    // Add overlay...
    $(this).addClass('data-loading').css('position', 'relative');

    /*$('input', this).each(function() {
      var disabled = $(this).attr('disabled');
      $(this).data('ecenter_disabled', disabled);
      $(this).attr('disabled', true);
    });*/

    overlay = $('<div class="loading-overlay"><p class="loading">' + Drupal.t('Loading') + '</p><button class="cancel">' + Drupal.t('Cancel') + '</button></div>');
    //map = $('#weathermap-wrapper').css('position', 'relative');
    overlay.css({
      'position' : 'absolute',
      'top' : 0,
      'left' : 0,
      'width' : $(this).outerWidth(),
      'height' : $(this).height(),
      'z-index' : 5,
      'display' : 'none',
    });
    $(this).prepend(overlay);
    overlay.fadeIn('slow');

    // @TODO eee this doesn't work!
    $('button.cancel', overlay).click(function(e) {
      e.stopPropagation();
      var input = $('#edit-weathermap-wrapper-query-dst-wrapper-dst-wrapper input');
      input.val('');
      input.data('autocomplete')._trigger('change');
      $(self).removeClass('data-loading');
      $('.loading-overlay', this).fadeOut('fast', function() {
        $(self).remove();
      });
    });
  });

  // Behind to ahah_end event
  $('#ecenter-weathermap-select-form').bind('ahah_end', function() {
    // Add overlay...
    $(this).removeClass('data-loading');
    $('.loading-overlay', this).fadeOut('fast', function() {
      $(this).remove();
    });
  });

  // Bind to series highlighting
  $('#results').bind('jqplotHighlightSeries', function(e, sidx, plot) {
    if (Drupal.settings.ecenterWeathermap.seriesLookup) {
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
          console.log('no series...');
          console.log(sidx);
          console.log(tc.chart.series);
        }
        console.log('---');
        if (s) {
          series_color = (lh.colors && lh.colors[sidx] != undefined) ? lh.colors[sidx] : s.seriesColors[sidx];
          var opts = {color: series_color, lineWidth: s.lineWidth + lh.sizeAdjust};
          lh.highlightSeries(sidx, tc.chart, opts);
        }
      }*/

      $('#trace-hop-label-' + hop.id).addClass('highlight');
      if (hop.corresponding_id) {
        $('#trace-hop-label-' + hop.corresponding_id).addClass('highlight');
      }
    }
  });

  // Bind to series unhighlighting
  $('#results').bind('jqplotUnhighlightSeries', function(e, sidx, plot) {
    $('.trace-label').removeClass('highlight');
  });

  // Bind to feature select: Set value, then call autocomplete's change function
  $('#weathermap-map').bind('ecenterfeatureselect', function(e, feature, layer) {
    if (layer.selectedFeatures.length == 1) {
      var input = $('#edit-weathermap-wrapper-query-src-wrapper-src-wrapper input');
      input.val(feature.ecenterID);
      input.data('autocomplete')._trigger('change');
    }
    else if (layer.selectedFeatures.length > 1) {
      var input = $('#edit-weathermap-wrapper-query-dst-wrapper-dst-wrapper input');
      input.val(feature.ecenterID);
      input.data('autocomplete')._trigger('change');
    }
  });

  // Bind to feature select
  $('#weathermap-map').bind('ecenterfeatureunselect', function(e, feature, layer) {
    // No selected features
    if (!layer.selectedFeatures.length) {
      var input = $('#edit-weathermap-wrapper-query-src-wrapper-src-wrapper input');
      input.val('');
      input.data('autocomplete')._trigger('change');
    }
    else if (layer.selectedFeatures.length) {
      var input = $('#edit-weathermap-wrapper-query-dst-wrapper-dst-wrapper input');
      input.val('');
      input.data('autocomplete')._trigger('change');
    }
  });

});


