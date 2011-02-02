$.fn.tablechart.defaults.attachMethod = function(container) {
  $('h3', this.el).after(container); 
}

// Add traceroute
Drupal.behaviors.EcenterTraceroute = function(context) {
  $('#traceroute-wrapper').remove();
  if (Drupal.settings.ecenterNetwork && Drupal.settings.ecenterNetwork.tracerouteData) {
    $('<div id="traceroute-wrapper">')
    .appendTo($('#network-map'));
    $('<div id="traceroute"></div>')
    .appendTo($('#traceroute-wrapper'))
    .traceroute(Drupal.settings.ecenterNetwork.tracerouteData);
  }
}

// Catchall for minor behavior modifications
Drupal.behaviors.EcenterEvents = function(context) {
  // Clear out results wrapper
  $('#query input[type=hidden]').change(function() {
    $('#results-wrapper').text('');
  });
  $('#edit-network-wrapper-query-src-wrapper-src-wrapper input').change(function() {
    var input = $('#edit-network-wrapper-query-dst-wrapper-dst-wrapper input');
    input.val('');
    input.data('autocomplete')._trigger('change');
  });
}

// 
Drupal.behaviors.EcenterSelectSetForm = function(context) {
  var src = $('#edit-network-wrapper-query-src-wrapper-src');
  var dst = $('#edit-network-wrapper-query-dst-wrapper-dst');

  if (src.val()) {
    EcenterNetwork.selectFeature.call(src.get(0), true)
  }
  if (dst.val()) {
    EcenterNetwork.selectFeature.call(dst.get(0), true)
  }
}

Drupal.behaviors.EcenterShowTables = function(context) {
  var show_label = Drupal.t('Show data tables');
  var hide_label = Drupal.t('Hide data tables');
  $('.tablechart', context).after('<button class="toggle-data">' + show_label + '</button>');
  $('.toggle-data', context).toggle(function() {
    $(this).text(hide_label).parent().find('#utilization-tables').slideDown('fast');
  }, function() {
    $(this).text(show_label).parent().find('#utilization-tables').slideUp('fast');
  });
}

EcenterNetwork = {};

/**
 * select param calls select function on feature
 */
EcenterNetwork.selectFeature = function(select) {
  var maps = Drupal.settings.openlayers.maps;
  var val = $(this).val().split(':', 2);
  var query_type = val[0];
  var query_value = val[1];

  // Iterate over "all" maps for ease.  There should be but one.
  if (query_type == 'hub') {
    for (key in maps) {
      var ol = $('#' + maps[key].id).data('openlayers');
      var layer = ol.openlayers.getLayersBy('drupalID', 'ecenter_network_sites').pop();
      var control = ol.openlayers.getControlsBy('ecenterID', 'ecenter_network_select').pop();
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
  // Clear out 'remembered' form values
  var src_input = $('#edit-network-wrapper-query-src-wrapper-src-wrapper input');
  var dst_input = $('#edit-network-wrapper-query-dst-wrapper-dst-wrapper input');
  var src_select = $('#edit-network-wrapper-query-src-wrapper-src-wrapper select');
  if (src_input.val() != '' && dst_input.val() == '') {
    src_input.val('');
    src_select.val('');
    EcenterNetwork.selectFeature.call(src_select, false);
  }

  // If a src/dst changes, change the map, too.
  $('#ecenter-network-select-form #src-wrapper select, #ecenter-network-select-form #dst-wrapper select')
  .change(function(e) { 
    EcenterNetwork.selectFeature.call(this, true);
  });

  // Bind to ajaxSend event
  $('#ecenter-network-select-form').bind('ajaxSend', function(ajax, xhr) {
    self = this;

    // Add overlay...
    $(this).addClass('data-loading').css('position', 'relative');

    var overlay = $('<div class="loading-overlay"><p class="loading">' + Drupal.t('Loading') + '</p><button class="cancel">' + Drupal.t('Cancel') + '</button></div>');
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

    $('button.cancel', overlay).click(function(e) {
      e.stopPropagation();

      xhr.abort();
      xhr.aborted = true;

      var input = $('#edit-network-wrapper-query-dst-wrapper-dst-wrapper input');
      input.val('');
      input.data('autocomplete')._trigger('change');
      $(self).removeClass('data-loading');

      $('.loading-overlay', self).fadeOut('fast', function() {
        $(this).remove();
      });

      return false;
    });
  });

  // Behind to ahah_end event
  $('#ecenter-network-select-form').bind('ajaxSuccess', function() {
    // Add overlay...
    $(this).removeClass('data-loading');
    $('.loading-overlay', this).fadeOut('fast', function() {
      $(this).remove();
    });
  });

  // Bind to series highlighting
  $('#results').bind('jqplotHighlightSeries', function(e, sidx, plot) {
    if (Drupal.settings.ecenterNetwork.seriesLookup) {
      var hop = Drupal.settings.ecenterNetwork.seriesLookup.idx[sidx];
      var tc = $('#utilization-tables').data('tablechart');
      var lh = tc['default'].chart.plugins.linehighlighter;
        
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
  $('#network-map').bind('ecenterfeatureselect', function(e, feature, layer) {
    if (layer.selectedFeatures.length == 1) {
      var input = $('#edit-network-wrapper-query-src-wrapper-src-wrapper input');
      input.val(feature.ecenterID);
      input.data('autocomplete')._trigger('change');
    }
    else if (layer.selectedFeatures.length > 1) {
      var input = $('#edit-network-wrapper-query-dst-wrapper-dst-wrapper input');
      input.val(feature.ecenterID);
      input.data('autocomplete')._trigger('change');
    }
  });

  // Bind to feature select
  $('#network-map').bind('ecenterfeatureunselect', function(e, feature, layer) {
    // No selected features
    if (!layer.selectedFeatures.length) {
      var input = $('#edit-network-wrapper-query-src-wrapper-src-wrapper input');
      input.val('');
      input.data('autocomplete')._trigger('change');
    }
    else if (layer.selectedFeatures.length) {
      var input = $('#edit-network-wrapper-query-dst-wrapper-dst-wrapper input');
      input.val('');
      input.data('autocomplete')._trigger('change');
    }
  });

});


