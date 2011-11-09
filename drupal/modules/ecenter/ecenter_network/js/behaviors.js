/**
 * @file behaviors.js
 *
 * Defines a lightweight jQuery plugin that acts as a controller for behaviors
 * related to the E-center weather map. The configuration consists of two sets
 * of plugins. The first plugins run once, and should bind to elements that
 * will not change or are events that will bubble and can be caught by
 * $.live(). The second set of plugins is run every time the plugin is called.
 *
 * It is assumed that *some* plugin will be in charge of "garbage collection"
 * (removing elements and/or unbinding events). In the default configuration,
 * the entire '#results' object is removed every time the destination value
 * changes.
 *
 * In general, changing the destination value in the form should be the primary
 * trigger for binding/rebinding behaviors.
 */

(function($) {

/**
 * Override tablechart attachMethod
 */
$.fn.tablechart.defaults.attachMethod = function(container) {
  $('.chart-title', this.el).after(container);
}

/**
 * Drupal behavior to attach network weathermap behaviors
 */
Drupal.behaviors.EcenterNetwork = function(context) {
  $('#ecenter-network-select-form').ecenter_network();
}

/**
 * jQuery plugin for controlling and delegating event binding and weathermap
 * behavior.
 */
$.fn.ecenter_network = function(options) {
  var options = $.extend(true, {}, $.fn.ecenter_network.defaults, options);

  this.each(function(i) {
    var ecenter_network = $(this).data('ecenterNetwork');
    if (ecenter_network == undefined) {
      ecenter_network = new $.ecenter_network(this, options);
      $(this).data('ecenterNetwork', ecenter_network);
    };
    ecenter_network.draw();
  });
}

/**
 * E-center Network object for encapulsating functionality
 *
 * Constructor calls init_plugins, which should bind once or
 * live bind to weathermap events.
 */
$.ecenter_network = function(el, options) {
  this.el = el;
  this.options = options;

  // Bind events
  var length = this.options.init_plugins.length;
  for (var i=0; i < length; i++) {
    var plugin = this.options.init_plugins[i];
    plugin.call(this);
  }
}

// Callback for hover 'over' event
$.ecenter_network.hoverOver = function() {
  for (var i = 0, ii = this.groups.length; i < ii; ++i) {
    var forward_style = {}, reverse_style = {},
      hub_id = this.groups[i],
      hop = Drupal.settings.ecenterNetwork.seriesLookupByHub[hub_id],
      set = this.paper.groups[hub_id],
      tc = $('#utilization-tables').data('tablechart');

    if (tc) {
      var fwd_idx = hop.sidx[0] % tc['default'].chart.seriesColors.length;
      forward_style['stroke'] = tc['default'].chart.seriesColors[fwd_idx];
      if (hop.sidx[1] != undefined) {
        var rev_idx = hop.sidx[1] % tc['default'].chart.seriesColors.length;
        reverse_style['stroke'] = tc['default'].chart.seriesColors[rev_idx];
      }
    }

    for (var j = 0, jj = set.items.length; j < jj; ++j) {
      var element = set.items[j];
      switch (element.type) {
        case 'circle':
        case 'path':
          if (element['tracerouteDirection'] == 'forward' || (element['tracerouteOnlyReverse']) || ( element['tracerouteDirection'] == 'reverse' && element['tracerouteType'] == 'diff'  ) ) {
            element.attr(forward_style);
          } else {
            element.attr(reverse_style);
          }
          break;
        case 'text':
          element.attr(this.paper.tracerouteOptions.label.overStyle);
          break;
      }
    }
  }
}

// Callback for hover 'out' event
$.ecenter_network.hoverOut = function() {
  for (var i = 0, ii = this.groups.length; i < ii; ++i) {
    var set = this.paper.groups[this.groups[i]];
    for (var j = 0, jj = set.items.length; j < jj; ++j) {
      var element = set.items[j];
      switch (element.type) {
        case 'circle':
        case 'path':
          element.attr(this.paper.tracerouteOptions.marker.style);
          break;
        case 'text':
          element.attr(this.paper.tracerouteOptions.label.style);
          break;
      }
    }
  }
}


/**
 * E-Center Network draw method
 *
 * Call draw_plugins, which must be bound to each new query result
 */
$.ecenter_network.prototype.draw = function() {
  var length = this.options.draw_plugins.length;
  for (var i=0; i < length; i++) {
    var plugin = this.options.draw_plugins[i];
    plugin.call(this);
  }
}

/**
 * Container object for default plugins
 */
$.fn.ecenter_network.plugins = {}

/**
 * Bind AJAX behaviors
 */
$.fn.ecenter_network.plugins.ajax = function() {
  var self = this;
  var el = this.el;

  // Add hidden loading overlay so it will be available later
  $('#network-wrapper', el).prepend($('<div id="loading-overlay"><div class="loading-wrapper"><p class="loading">' + Drupal.t('Loading...') + '</p><button class="cancel">' + Drupal.t('Cancel') + '</button></div></div>'));

  // Use bind; ajax_form events do not bubble to the top of the DOM
  $(el).bind({
    'ajaxSend' : function(e, xhr, s) {
      var overlay = $('#loading-overlay');
      var url_parts = s.url.replace(Drupal.settings.basePath, '').split('/');
      if (url_parts[0] == 'ahah_helper') {
        overlay.css({
          'position' : 'absolute',
          'top' : 0,
          'left' : 0,
          'width' : $('#network-wrapper').outerWidth(),
          'height' : $('#network-wrapper').height(),
          'z-index' : 5,
        });
        overlay.fadeIn('slow');

        $('button.cancel').click(function(e) {
          e.stopPropagation();
          xhr.aborted = true;
          xhr.abort();
          return false;
        });

        $('.messages').fadeOut(900, function() {
          $(this).remove();
        });
        $('#results').fadeOut(900, function() {
          $(this).remove();
        });
        $('#recent-queries').slideUp(900, function() {
          $(this).remove();
        });
      }
    },
    'ajaxSuccess' : function(e) {
      $(el).removeClass('data-loading');
      var overlay = $('#loading-overlay', self.el)
      .fadeOut('fast', function() {
        $('button', overlay).css({'display' : 'inline'});
      });

      // Zoom to correct level for sites layer
      var src = $('#src-wrapper input');
      var dst = $('#dst-wrapper input');
      if (src.val() && !dst.val()) {
        var ol = $('#openlayers-map-auto-id-0').data('openlayers');
        var map = ol.openlayers;
        var layer = map.getLayersBy('drupalID', 'ecenter_network_sites').pop();

        // Zoom to extent
        layerextent = layer.getDataExtent();

        // Check for valid layer extent
        if (layerextent != null) {
          map.zoomToExtent(layerextent);
        }
      }
    },
    'ajaxError' : function(e) {
      var dst = $('#dst-wrapper select');
      $.fn.ecenter_network.plugins.map.unselectFeature.call(dst.get(0));

      dst.val('');
      $('#dst-wrapper input').val('');

      $('#traceroute-paste-wrapper').fadeOut();
      $('#traceroute-paste-wrapper textarea').val('');

      $(el).removeClass('data-loading');
      var overlay = $('#loading-overlay', self.el)
        .fadeOut('fast');
      $('button', overlay).css({'display' : 'inline'});

      // Zoom to correct level for sites layer
      var ol = $('#openlayers-map-auto-id-0').data('openlayers');
      var map = ol.openlayers;
      var layer = map.getLayersBy('drupalID', 'ecenter_network_sites').pop();

      // Zoom to extent
      layerextent = layer.getDataExtent();

      // Check for valid layer extent
      if (layerextent != null) {
        map.zoomToExtent(layerextent);
      }
    }
  });
}

/**
 * Trigger form submission when destination value is provided and date changes.
 */
$.fn.ecenter_network.plugins.date = function() {
  // @TODO This is a little DRY violation, maybe delegate instead?
  $('#recent-select input', this.el).bind('change', function() {
    $('#date-select input').val('');
    var traceroute = $('#traceroute-paste-wrapper textarea', this.el);
    if (traceroute.val()) {
      traceroute.trigger('change');
      return;
    }
    var dst = $('#dst-wrapper input', this.el);
    if (dst.val()) {
      dst.data('autocomplete')._trigger('change');
      return;
    }
  });
  $('#date-select input', this.el).bind('change', function() {
    var dst = $('#dst-wrapper input', this.el);
    $('#recent-select input').attr('checked', false);
    var traceroute = $('#traceroute-paste-wrapper textarea', this.el);
    if (traceroute.val()) {
      traceroute.trigger('change');
      return;
    }
    var dst = $('#dst-wrapper input', this.el);
    if (dst.val()) {
      dst.data('autocomplete')._trigger('change');
      return;
    }
  });
}

/**
 * Trigger loading screen, destruction of old DOM elements and handlers
 * when destination changes.
 */
$.fn.ecenter_network.plugins.change = function() {
  var self = this;

  if (!$('#src-wrapper input').val()) {
    $('#dst-wrapper input, #dst-wrapper button')
      .attr('disabled', 'disabled')
      .addClass('disabled');
  } else {
    $('#dst-wrapper input, #dst-wrapper button')
      .removeAttr('disabled')
      .removeClass('disabled');
  }

  $('#src-wrapper select, #dst-wrapper select', this.el).bind('change', function(e) {
    $('#traceroute-paste-wrapper').fadeOut();
    $('#traceroute-paste-wrapper textarea').val('');
  });
}

/**
 * Handle map events; we can bind with 'live' because these custom events
 * bubble to the top of the DOM.
 */
$.fn.ecenter_network.plugins.map = function() {
  var maps = Drupal.settings.openlayers.maps;
  for (key in maps) {
    var id = '#' + maps[key].id;

    // Persist selection after zooming or panning
    var ol = $(id).data('openlayers');
    var map = ol.openlayers;
    map.events.on({
      moveend: function(e) {
        $.fn.ecenter_network.plugins.draw_map();
      }
    });

    $(id).live('featureClick', function(e, feature, layer, control) {
      if (layer.drupalID == 'ecenter_network_sites') {
        // Toggle click state
        var selected = (OpenLayers.Util.indexOf(
          feature.layer.selectedFeatures, feature) > -1);
        if (selected) {
          control.unselect(feature);
          Drupal.ecenterSelect.out.call(control, feature); // Unhighlight
        } else {
          control.select(feature);
          Drupal.ecenterSelect.over.call(control, feature); // Highlight
        }

        if (layer.selectedFeatures.length == 0) {
          var input = $('#src-wrapper input', this.el);
          input.val('');
          input.data('autocomplete')._trigger('change');
        }
        else if (layer.selectedFeatures.length == 1) {
          var input = $('#src-wrapper input', this.el);
          input.val(feature.ecenterID);
          input.data('autocomplete')._trigger('change');
        }
        else if (layer.selectedFeatures.length > 1) {
          var input = $('#dst-wrapper input', this.el);
          input.val(feature.ecenterID);
          input.data('autocomplete')._trigger('change');
        }
      }
    });

    $(id).live('featureOver', function(e, feature, layer, control, cancel) {
      if (feature.ecenterID) {
        if (layer.drupalID == 'ecenter_network_traceroute') {
          var hub = Drupal.settings.ecenterNetwork.seriesLookupByHub[feature.ecenterID];
          var tc = $('#utilization-tables').data('tablechart');

          if (tc) {
            var length = tc['default'].chart.seriesColors.length;
            var sidx = hub.sidx[0] % length;
            var color = tc['default'].chart.seriesColors[sidx];
          }

          var selectStyle = {
            strokeColor: color,
            pointRadius: 7,
            strokeWidth: 4,
            fontColor: color,
          };

          var traceroutes = $('#traceroute').data('traceroute');
          if (!cancel && traceroutes && traceroutes['default']) {
            var trace = traceroutes['default'];
            var set = trace.paper.set(feature.ecenterID);
            $(trace.paper.canvas).trigger('elementmouseover', set.items[0], true);
          }
        } else {
          var selectStyle = {
            strokeColor: '#0000aa',
            pointRadius: 7,
            strokeWidth: 4,
            fontColor: '#0000aa',
          };
        }
        var style = $.extend({}, feature.style, selectStyle);
        layer.drawFeature(feature, style);
      }
    });

    $(id).live('featureOut', function(e, feature, layer, control, cancel) {
      if (feature.ecenterID) {
        var selected = (OpenLayers.Util.indexOf(
          feature.layer.selectedFeatures, feature) > -1);
        if (!selected) {
          layer.drawFeature(feature, feature.style || feature.layer.style ||
              "default");
        }
        if (layer.drupalID == 'ecenter_network_traceroute') {
          var hub = Drupal.settings.ecenterNetwork.seriesLookupByHub[feature.ecenterID];
          var traceroutes = $('#traceroute').data('traceroute');
          if (!cancel && traceroutes && traceroutes['default']) {
            var trace = traceroutes['default'];
            var set = trace.paper.set(feature.ecenterID);
            $(trace.paper.canvas).trigger('elementmouseout', set.items[0]);
          }
        }
      }
    });
  }
}

/**
 * Helper function for selecting a map feature based on select element value
 */
$.fn.ecenter_network.plugins.map.selectFeature = function(select) {
  var maps = Drupal.settings.openlayers.maps;
  var val = $(this).val().split(':', 2);
  var query_type = val[0];
  var query_value = val[1];

  if (query_type == 'hub') {
    for (key in maps) {
      var ol = $('#' + maps[key].id).data('openlayers');
      var layer = ol.openlayers.getLayersBy('drupalID', 'ecenter_network_sites').pop();
      var control = ol.openlayers.getControlsBy('drupalID', 'ecenterSelect').pop();
      var feature = layer.getFeatureBy('ecenterID', query_value);

      // If this is called while loading, we have a problem
      if (control && feature) {
        if (select) {
          control.select.call(control, feature);
        }
        control.callbacks.over.call(control, feature);
      }
    }
  }
}

/**
 * Helper function for unselecting a map feature based on select element
 * value.
 */
$.fn.ecenter_network.plugins.map.unselectFeature = function() {
  var maps = Drupal.settings.openlayers.maps;
  var val = $(this).val().split(':', 2);
  var query_type = val[0];
  var query_value = val[1];

  if (query_type == 'hub') {
    for (key in maps) {
      var ol = $('#' + maps[key].id).data('openlayers');
      var layer = ol.openlayers.getLayersBy('drupalID', 'ecenter_network_sites').pop();
      var control = ol.openlayers.getControlsBy('drupalID', 'ecenterSelect').pop();
      var feature = layer.getFeatureBy('ecenterID', query_value);

      if (control && feature) {
        control.unselect(feature);
        control.callbacks.out.call(control, feature);
      }
    }
  }
}


/**
 * When drawing map, automatically select features based on present form values.
 */
$.fn.ecenter_network.plugins.draw_map = function() {
  var src = $('#src-wrapper select', this.el);
  var dst = $('#dst-wrapper select', this.el);
  if (src.val()) {
    $.fn.ecenter_network.plugins.map.selectFeature.call(src.get(0), true);
  }
  if (dst.val()) {
    $.fn.ecenter_network.plugins.map.selectFeature.call(dst.get(0), true);
  }
}

/**
 * Create traceroute visualization using traceroute jQuery plugin.
 */
$.fn.ecenter_network.plugins.traceroute = function() {
  var traceroutes = $('#traceroute', this.el).data('traceroute');
  if (!traceroutes && Drupal.settings.ecenterNetwork && Drupal.settings.ecenterNetwork.tracerouteData) {
    $('<div id="traceroute-wrapper">')
      .insertBefore($('#utilization-tables'));
    $('<div id="traceroute"></div>')
      .appendTo($('#traceroute-wrapper'))
      .traceroute(Drupal.settings.ecenterNetwork.tracerouteData);

    var traceroutes = $('#traceroute', this.el).data('traceroute');

    if (!traceroutes) {
      return;
    }

    $(traceroutes['default'].paper.canvas).bind({
      'elementmouseover' : function(e, element, cancel_map, cancel_highlight) {
        var hub_id = element.groups[0];

        $.ecenter_network.hoverOver.call(element);

        if (!cancel_highlight) {
          var hop = Drupal.settings.ecenterNetwork.seriesLookupByHub[hub_id];
          var tc = $('#utilization-tables').data('tablechart');
          var lh = tc['default'].chart.plugins.linehighlighter;
          for (key in hop.sidx) {
            lh.highlightSeries(hop.sidx[key], tc['default'].chart);
          }
        }
        
        if (element.tracerouteType == 'match' && !cancel_map) {
          var ol = $('#openlayers-map-auto-id-0').data('openlayers');
          var map = ol.openlayers;
          var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop();
          var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
          var feature = layer.getFeatureBy('ecenterID', hub_id);
          control.callbacks.over.call(control, feature, true);
        }

      },
      'elementmouseout' : function(e, element) {
        var hub_id = element.groups[0];
        var hop = Drupal.settings.ecenterNetwork.seriesLookupByHub[hub_id];
        var tc = $('#utilization-tables').data('tablechart');
        var lh = tc['default'].chart.plugins.linehighlighter;
        
        for (key in hop.sidx) {
          lh.unhighlightSeries(hop.sidx[key], tc['default'].chart);
        }

        if (!(element.tracerouteType == 'diff' && element.tracerouteDirection == 'reverse')) {
          var ol = $('#openlayers-map-auto-id-0').data('openlayers');
          var map = ol.openlayers;
          var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop();
          var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
          var feature = layer.getFeatureBy('ecenterID', hub_id);
          control.callbacks.out.call(control, feature, true);
        }

        $.ecenter_network.hoverOut.call(element);
      }
    });
  }
}

/**
 * Live bind to series highlighting.
 */
$.fn.ecenter_network.plugins.chart = function() {
  // Bind to series highlighting
  $('#results', this.el).live('jqplotHighlightSeries', function(e, sidx, plot) {

    var lookup = Drupal.settings.ecenterNetwork.seriesLookupByIndex[sidx],
      tc = $('#utilization-tables').data('tablechart'),
      lh = tc['default'].chart.plugins.linehighlighter;

    var length = tc['default'].chart.seriesColors.length;
    var ol = $('#openlayers-map-auto-id-0').data('openlayers');
    var map = ol.openlayers;
    var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop();
    var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
    var feature = layer.getFeatureBy('ecenterID', lookup.hubID);

    if (feature) {
      control.callbacks.over.call(control, feature, true);
    }

    var traceroutes = $('#traceroute').data('traceroute');
    if (traceroutes && traceroutes['default']) {
      var trace = traceroutes['default'];
      var set = trace.paper.set(lookup.hubID);
      $.ecenter_network.hoverOver.call(set.items[0]);
    }
  });

  // Bind to series unhighlighting
  $('#results', this.el).live('jqplotUnhighlightSeries', function(e, sidx, plot) {
    var lookup = Drupal.settings.ecenterNetwork.seriesLookupByIndex[sidx],
      tc = $('#utilization-tables').data('tablechart'),
      lh = tc['default'].chart.plugins.linehighlighter;

    var length = tc['default'].chart.seriesColors.length;
    var ol = $('#openlayers-map-auto-id-0').data('openlayers');
    var map = ol.openlayers;
    var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop();
    var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
    var feature = layer.getFeatureBy('ecenterID', lookup.hubID);

    if (feature) {
      control.callbacks.out.call(control, feature, true);
    }

    var traceroutes = $('#traceroute').data('traceroute');
    if (traceroutes && traceroutes['default']) {
      var trace = traceroutes['default'];
      var set = trace.paper.set(lookup.hubID);
      $.ecenter_network.hoverOut.call(set.items[0]);
    }
  });
}

$.fn.ecenter_network.plugins.show_data_button = function() {
  $('#results .data-wrapper').each(function(i) {
    if (!$(this).data('showDataButton')) {
      var wrapper = this;
      var show_text = Drupal.t('Show data tables');
      var hide_text = Drupal.t('Hide data tables');
      $('.tablechart', this).after('<button class="show-data">' + show_text + '</button>');
      $('button.show-data', this).toggle(function(e) {
        $('.data-tables', wrapper).show();
        $(this).html(hide_text);
        return false;
      }, function(e) {
        $('.data-tables', wrapper).hide();
        $(this).html(Drupal.t(show_text));
        return false;
      });
      $(this).data('showDataButton', true);
    }
  });
}

$.fn.ecenter_network.plugins.end_to_end = function() {
  $('#end-to-end-results .end-to-end-table tbody tr', this.el).hover(function() {
    var parts = this.id.split('-');
    $('#' + parts[0] + '-' + parts[1] + '-data-tables').addClass('active-row');
  }, function() {
    var parts = this.id.split('-');
    $('#' + parts[0] + '-' + parts[1] + '-data-tables').removeClass('active-row');
  });
}


$.fn.ecenter_network.plugins.analysis = function() {
  $('.analysis-submit').live({
    'click' : function(e) {
      e.stopPropagation();
      var wrapper = $(this).parents('.analysis-wrapper');
      var enable = $(this).parents('.analysis-wrapper').find('.analysis-enable').attr('checked', true);
      
      var input = $('#dst-wrapper input');
      
      input.data('autocomplete')._trigger('change');
      $('#loading-overlay button').focus();

      return false;
    }
  });
  $('.ads-algorithm').live({
    'change' : function(e) {
      if ($('option:selected', this).val() == 'apd') {
        $('#ads-settings input').not('.ads-algorithm').attr('disabled', true);
      }
      else {
        $('#ads-settings input').not('.ads-algorithm').attr('disabled', false);
      }
    }
  });
}

$.fn.ecenter_network.plugins.timezone_select = function() {
  $('#timezone-select').change(function() {
    var dst = $('#dst-wrapper input', this.el);
    if (dst.val()) {
      dst.data('autocomplete')._trigger('change');
      return;
    }
  });
}

$.fn.ecenter_network.plugins.traceroute_paste = function() {
  var target = $('#traceroute-paste-wrapper');
  var dialog = target.hide()
    .css({'z-index' : 5})
    .clone()
    .attr('id', 'traceroute-paste-copy');

  $('textarea', target).attr('readonly', true);
  $('body').append(dialog);

  var dialog = $('#traceroute-paste-copy').dialog({
    autoOpen : false,
    closeText : null,
    modal: true,
    width: 700,
    buttons: {
      'Submit traceroute' : function() {
        // Debug by showing field
        $('#traceroute-paste-wrapper').fadeIn();
        // Copy the value
        $('#src-wrapper input, #dst-wrapper input').val(null);
        var traceroute = $('textarea', this).val();
        $('textarea', target)
          .val(traceroute)
          .trigger('change');
        $(this).dialog('close');
      },
      'Cancel' : function() {
        $(this).dialog('close');
      }
    }
  });
 
  var button = $('<button>'+ Drupal.t('Paste traceroute') +'</button>')
    .click(function() {
      dialog.dialog('open');
      return false; 
    });

  $('#dst-wrapper').after(button);
}


/**
 * Default options: Define default plugins to call
 */
$.fn.ecenter_network.defaults = {
  // Initialization plugins
  init_plugins : [
    $.fn.ecenter_network.plugins.ajax,
    $.fn.ecenter_network.plugins.map,
    $.fn.ecenter_network.plugins.date,
    $.fn.ecenter_network.plugins.chart,
    $.fn.ecenter_network.plugins.traceroute_paste,
    $.fn.ecenter_network.plugins.analysis
  ],
  // Drawing plugins
  draw_plugins : [
    $.fn.ecenter_network.plugins.change,
    $.fn.ecenter_network.plugins.traceroute,
    $.fn.ecenter_network.plugins.draw_map,
    $.fn.ecenter_network.plugins.show_data_button,
    $.fn.ecenter_network.plugins.timezone_select,
    $.fn.ecenter_network.plugins.end_to_end
  ]
};

})(jQuery);
