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

// Override how tablechart works
$.fn.tablechart.defaults.attachMethod = function(container) {
  $('.chart-title', this.el).after(container);
}

// Fire plugin with Drupal behaviors (needs to run more or less last)
Drupal.behaviors.EcenterNetwork = function(context) {
  $('#ecenter-network-select-form').ecenter_network();
}

// No options yet...
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

$.ecenter_network.prototype.draw = function() {
  var length = this.options.draw_plugins.length;
  for (var i=0; i < length; i++) {
    var plugin = this.options.draw_plugins[i];
    plugin.call(this);
  }
}

$.fn.ecenter_network.plugins = {}

$.fn.ecenter_network.plugins.ajax = function() {
  var self = this;
  var el = this.el;

  // Add hidden loading overlay so it will be available later
  $('#network-wrapper', el).prepend($('<div id="loading-overlay"><div class="loading-wrapper"><p class="loading">' + Drupal.t('Loading...') + '</p><button class="cancel">' + Drupal.t('Cancel') + '</button></div></div>'));

  $(el).bind({
    'ajaxSend' : function(e, xhr, s) {
      $('button.cancel').click(function(e) {
        e.stopPropagation();

        xhr.aborted = true;
        xhr.abort();

        return false;
      });
    },
    'ajaxSuccess' : function(e) {
      $(el).removeClass('data-loading');
      $('#loading-overlay', self.el).fadeOut('fast');
    },
    'ajaxError' : function(e) {
      var dst = $('#dst-wrapper select');
      $.fn.ecenter_network.plugins.map.unselectFeature.call(dst.get(0));

      dst.val('');
      $('#dst-wrapper input').val('');

      $(el).removeClass('data-loading');
      $('#loading-overlay', self.el).fadeOut('fast');
    }
  });
}

$.fn.ecenter_network.plugins.date = function() {
  $('#recent-select input, #date-select input', this.el).bind('change', function() {
    var dst = $('#dst-wrapper input', this.el);
    if (dst.val()) {
      dst.data('autocomplete')._trigger('change');
    }
  });
}

$.fn.ecenter_network.plugins.change = function() {
  var self = this;
  var processed = $('#dst-wrapper select').data('ecenterProcessed');

  // Clear out old results when destination select changes
  if (!processed) {
    $('#dst-wrapper select', this.el).bind('change', function(e) {
      $('#results', self.el).slideUp(600, function() {
        $(this).remove();
      });

      $('#recent-queries', self.el).slideUp(600, function() {
        $(this).remove();
      });

      // Add overlay.
      $(self.el).addClass('data-loading').css('position', 'relative');

      var overlay = $('#loading-overlay')
      overlay.css({
        'position' : 'absolute',
        'top' : 0,
        'left' : 0,
        'width' : $('#network-wrapper', self.el).outerWidth(),
        'height' : $('#network-wrapper', self.el).height(),
        'z-index' : 5,
        'display' : 'none',
      });
      $(self.el).prepend(overlay);
      overlay.fadeIn('slow');

      $(this).data('ecenterProcessed', true);
    });
  }
}

$.fn.ecenter_network.plugins.map = function() {
  var maps = Drupal.settings.openlayers.maps;
  for (key in maps) {
    var id = '#' + maps[key].id;
    
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
      }
    });

    $(id).live('featureOver', function(e, feature, layer, control) {
      if (feature.ecenterID) {
        if (layer.drupalID == 'ecenter_network_traceroute') {
          var hub = Drupal.settings.ecenterNetwork.seriesLookupByHub[feature.ecenterID];
          var tc = $('#utilization-tables').data('tablechart');
          
          if (tc) {
            var lh = tc['default'].chart.plugins.linehighlighter;

            for (key in hub.sidx) {
              //lh.highlightSeries(hub.sidx[key], tc['default'].chart);
              var length = tc['default'].chart.seriesColors.length;
              var sidx = hub.sidx[key] % length;
              var color = tc['default'].chart.seriesColors[sidx];
            }
          }

          var selectStyle = {
            strokeColor: color,
            pointRadius: 7,
            strokeWidth: 4,
            fontColor: color,
            zIndex: 1000
          };

          /*var traceroutes = $('#traceroute').data('traceroute');
          if (traceroutes) {
            var traceroute = traceroutes['default'].svg;
            for (id in hub.id) {
              var group = $('g[hop_id="'+ hub.id[id] +'"]', traceroute.root());
              group.trigger('mouseover', [false]);
            }
          }*/
        } else {
          var selectStyle = {
            strokeColor: '#0000aa',
            pointRadius: 7,
            strokeWidth: 4,
            fontColor: '#0000aa',
            zIndex: 1000
          };
        }
        var style = $.extend({}, feature.style, selectStyle);
        layer.drawFeature(feature, style);
      }
    });

    $(id).live('featureOut', function(e, feature, layer, control) {
      if (feature.ecenterID) {
        var selected = (OpenLayers.Util.indexOf(
          feature.layer.selectedFeatures, feature) > -1);
        if (!selected) {
          layer.drawFeature(feature, feature.style || feature.layer.style ||
              "default");
        }
        /*if (layer.drupalID == 'ecenter_network_traceroute') {
          var hub = Drupal.settings.ecenterNetwork.seriesLookupByHub[feature.ecenterID];
          var tc = $('#utilization-tables').data('tablechart');

          if (tc) {
            var lh = tc['default'].chart.plugins.linehighlighter;
            for (key in hub.sidx) {
              lh.unhighlightSeries(hub.sidx[key], tc['default'].chart);
            }
          }

          var traceroutes = $('#traceroute').data('traceroute');
          if (traceroutes) {
            var traceroute = traceroutes['default'].svg;
            for (id in hub.id) {
              var group = $('g[hop_id="'+ hub.id[id] +'"]', traceroute.root());
              group.trigger('mouseout', [false]);
            }
          }
        }*/
      }
    });

    // Bind to feature select: Set value, then call autocomplete's change function
    $(id).live('featureClick', function(e, feature, layer) {
      if (layer.drupalID == 'ecenter_network_sites') {
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
      }
    });
  }
}

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

$.fn.ecenter_network.plugins.traceroute = function() {http://localhost/ecenter/network
  var el = this.el;
  var trace_el = $('#traceroute-wrapper', this.el);

  if (!trace_el.length && Drupal.settings.ecenterNetwork && Drupal.settings.ecenterNetwork.tracerouteData) {
    var traceroutes = $('#traceroute').data('traceroute');
    $('<div id="traceroute-wrapper">')
      .prependTo($('#hop-wrapper'));

    $('<div id="traceroute"></div>')
      .appendTo($('#traceroute-wrapper'))
      .traceroute(Drupal.settings.ecenterNetwork.tracerouteData);

    var traceroutes = $('#traceroute').data('traceroute');
    if (!traceroutes) {
      return;
    }

    var traceroute = traceroutes['default'].svg;

    $('.match, .diff', traceroute.root()).
    bind({
      'mouseover' : function(e) {
        $('g.node', e.currentTarget).each(function(e) {
          var group = this;
          var hop_id = $(this).attr('hop_id');
          var hop = Drupal.settings.ecenterNetwork.seriesLookupByID[hop_id];

          var tc = $('#utilization-tables').data('tablechart');
          if (tc) {
            var lh = tc['default'].chart.plugins.linehighlighter;
            if (lh.colors) {
              var idx = hop.sidx % lh.colors.length;
              var color = lh.colors[idx];
            }
            else {
              var idx = hop.sidx % tc['default'].chart.seriesColors.length;
              var color = tc['default'].chart.seriesColors[idx];
            }
          }
          else {
            var color = '#000000';
          }

          $('circle', group).each(function() {
            this.setAttribute('stroke', '#555555');
          });
          $('.hub-label text', group).each(function() {
            this.setAttribute('fill', '#000000');
          });
          $('.label text', group).each(function() {
            this.setAttribute('fill', '#ffffff');
          });
          $('.background rect', group).each(function() {
            this.setAttribute('fill', color);
          });
        });
      },
      'mouseout' : function(e) {
        $('g.node', e.currentTarget).each(function(e) {
          var group = this;
          var hop_id = $(this).attr('hop_id');
          var hop = Drupal.settings.ecenterNetwork.seriesLookupByID[hop_id];

          $('circle', group).each(function() {
            this.setAttribute('stroke', '#aaaaaa');
          });
          $('.hub-label text', group).each(function() {
            this.setAttribute('fill', '#444444');
          });
          $('.label text', group).each(function() {
            this.setAttribute('fill', '#555555');
          });
          $('.background rect', group).each(function() {
            this.setAttribute('fill', '#ffffff');
          });
        });
      }
    });
  }
}

$.fn.ecenter_network.plugins.chart = function() {
  // Bind to series highlighting
  $('#results', this.el).live('jqplotHighlightSeries', function(e, sidx, plot) {
    if (Drupal.settings.ecenterNetwork.seriesLookupByIndex) {
      var hop = Drupal.settings.ecenterNetwork.seriesLookupByIndex[sidx];
      var tc = $('#utilization-tables').data('tablechart');
      var lh = tc['default'].chart.plugins.linehighlighter;

      var length = tc['default'].chart.seriesColors.length;
      sidx = sidx % length;
      var background_color = tc['default'].chart.seriesColors[sidx];

      var ol = $('#openlayers-map-auto-id-0').data('openlayers');
      var map = ol.openlayers;
      var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop(); 
      var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
      var feature = layer.getFeatureBy('ecenterID', hop.hub);

      if (feature) {
        control.callbacks.over.call(control, feature);
      }
    }
  });

  // Bind to series unhighlighting
  $('#results', this.el).live('jqplotUnhighlightSeries', function(e, sidx, plot) {
    var hop = Drupal.settings.ecenterNetwork.seriesLookupByIndex[sidx];
    var ol = $('#openlayers-map-auto-id-0').data('openlayers');
    var map = ol.openlayers;
    var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop(); 
    var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
    var feature = layer.getFeatureBy('ecenterID', hop.hub);

    if (feature) {
      control.callbacks.out.call(control, feature);
    }
  });

}


$.fn.ecenter_network.defaults = {
  // Initialization plugins
  init_plugins : [
    $.fn.ecenter_network.plugins.ajax,
    $.fn.ecenter_network.plugins.map,
    $.fn.ecenter_network.plugins.date,
    $.fn.ecenter_network.plugins.chart
  ],
  // Drawing plugins
  draw_plugins : [
    $.fn.ecenter_network.plugins.change,
    $.fn.ecenter_network.plugins.traceroute,
    $.fn.ecenter_network.plugins.draw_map,
  ]
};

})(jQuery);
