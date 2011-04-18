(function($) {

$.fn.tablechart.defaults.attachMethod = function(container) {
  $('.chart-title', this.el).after(container); 
}

Drupal.behaviors.EcenterNetwork = function(context) {
  console.log(context);

  $('#ecenter-network-select-form').ecenter_network();
}

// No options yet...
$.fn.ecenter_network = function() {
  this.each(function(i) {
    var ecenter_network = $(this).data('ecenterNetwork');
    if (ecenter_network == undefined) {
      ecenter_network = new $.ecenter_network(this);
      $(this).data('ecenterNetwork', ecenter_network);
    };
    ecenter_network.refresh();
  });
}

$.ecenter_network = function(el) {
  this.el = el;
  // Bind events
  for (var name in $.fn.ecenter_network.events) {
    var plugin = $.fn.ecenter_network.events[name];
    plugin.call(this);
  }
}

$.ecenter_network.prototype.refresh = function() {
  for (var name in $.fn.ecenter_network.refresh) {
    var plugin = $.fn.ecenter_network.refresh[name];
    plugin.call(this);
  }
}

// World's tiniest plugin architecture
$.fn.ecenter_network.events = {}
$.fn.ecenter_network.refresh = {}

$.fn.ecenter_network.events.ajax = function() {
  var el = this.el;

  $(el).bind({
    'ajaxStart' : function(ajax, xhr) {

      // Clear out old results
      $('#results', el).slideUp(function() {
        $(this).remove();
      });

      // Add overlay...
      $(el).addClass('data-loading').css('position', 'relative');

      var overlay = $('<div class="loading-overlay"><div class="loading-wrapper"><p class="loading">' + Drupal.t('Loading...') + '</p><button class="cancel">' + Drupal.t('Cancel') + '</button></div></div>');
      overlay.css({
        'position' : 'absolute',
        'top' : 0,
        'left' : 0,
        'width' : $(this).outerWidth(),
        'height' : $(this).height(),
        'z-index' : 5,
        'display' : 'none',
      });
      $(el).prepend(overlay);
      overlay.fadeIn('slow');

      $('button.cancel', overlay).click(function(e) {
        e.stopPropagation();

        try { console.log('cancel button clicked', xhr); } catch(e) {}

        xhr.aborted = true;
        xhr.abort();

        $(el).removeClass('data-loading');

        $('.loading-overlay', el).fadeOut('fast', function() {
          $(this).remove();
        });

        return false;
      });
    },
    'ajaxSuccess' : function() {
      $(el).removeClass('data-loading');
      $('.loading-overlay', el).fadeOut('fast', function() {
        $(this).remove();
      });
    }
  });
}

$.fn.ecenter_network.events.date_behavior = function() {
  $('#recent-select input, #date-select input', this.el).change(function() {
    var dst = $('#dst-wrapper input', this.el);
    if (dst.val()) {
      dst.data('autocomplete')._trigger('change');
    }
  });
}

$.fn.ecenter_network.refresh.map = function() {
  var maps = Drupal.settings.openlayers.maps;
  for (key in maps) {
    var id = '#' + maps[key].id;
    
    $(id).bind('featureClick', function(e, feature, layer, control) {
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

    $(id).bind('featureOver', function(e, feature, layer, control) {
      if (feature.ecenterID) {
        if (layer.drupalID == 'ecenter_network_traceroute') {
          var hub = Drupal.settings.ecenterNetwork.seriesLookupByHub[feature.ecenterID];
          var tc = $('#utilization-tables').data('tablechart');
          var lh = tc['default'].chart.plugins.linehighlighter;

          for (key in hub.sidx) {
            lh.highlightSeries(hub.sidx[key], tc['default'].chart);
            var length = tc['default'].chart.seriesColors.length;
            var sidx = hub.sidx[key] % length;
            var color = tc['default'].chart.seriesColors[sidx];
          }

          var selectStyle = {
            strokeColor: color,
            pointRadius: 7,
            strokeWidth: 4,
            fontColor: color,
            zIndex: 1000
          };

          var traceroutes = $('#traceroute').data('traceroute');
          var traceroute = traceroutes['default'].svg;
          for (id in hub.id) {
            var group = $('g[hop_id="'+ hub.id[id] +'"]', traceroute.root());
            group.trigger('mouseover');
          }
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

    $(id).bind('featureOut', function(e, feature, layer, control) {
      if (feature.ecenterID) {
        var selected = (OpenLayers.Util.indexOf(
          feature.layer.selectedFeatures, feature) > -1);
        if (!selected) {
          layer.drawFeature(feature, feature.style || feature.layer.style ||
              "default");
        }
        if (layer.drupalID == 'ecenter_network_traceroute') {
          var hub = Drupal.settings.ecenterNetwork.seriesLookupByHub[feature.ecenterID];
          var tc = $('#utilization-tables').data('tablechart');
          var lh = tc['default'].chart.plugins.linehighlighter;
          var traceroutes = $('#traceroute').data('traceroute');
          var traceroute = traceroutes['default'].svg;

          for (key in hub.sidx) {
            lh.unhighlightSeries(hub.sidx[key], tc['default'].chart);
          }
          for (id in hub.id) {
            var group = $('g[hop_id="'+ hub.id[id] +'"]', traceroute.root());
            group.trigger('mouseout');
          }
        } 
      }
    });

    // Bind to feature select: Set value, then call autocomplete's change function
    $(id).bind('featureClick', function(e, feature, layer) {
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

$.fn.ecenter_network.refresh.traceroute = function() {
  var el = this.el;
  if (Drupal.settings.ecenterNetwork && Drupal.settings.ecenterNetwork.tracerouteData) {
    $('<div id="traceroute-wrapper">')
      .prependTo($('#hop-wrapper'));
    
    $('<div id="traceroute"></div>')
      .appendTo($('#traceroute-wrapper'))
      .traceroute(Drupal.settings.ecenterNetwork.tracerouteData);
    
    var traceroutes = $('#traceroute').data('traceroute');
    if (traceroutes == undefined) {
      return;
    }

    var traceroute = traceroutes['default'].svg;

    $('.match, .diff', traceroute.root()).
    bind({
      'mouseover' : function(e, map_highlight) {
        var map_highlight = (undefined || true) ? true : false;
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

            lh.highlightSeries(hop.sidx, tc['default'].chart);
          } 
         
          /*if (map_highlight) {
            var ol = $('#openlayers-map-auto-id-0').data('openlayers');
            var map = ol.openlayers;
            var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop();
            var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
            var feature = layer.getFeatureBy('ecenterID', hop.hub);
            control.callbacks.over.call(control, feature);
          }*/

          $('circle', group).each(function() {
            this.setAttribute('stroke', color);
          });
          $('text', group).each(function() {
            this.setAttribute('fill', '#ffffff');
          });
          $('rect', group).each(function() {
            this.setAttribute('fill', color);
          });
          
        });
      },
      'mouseout' : function(e, map_highlight) {
        var map_highlight = (undefined || true) ? true : false;

        $('g.node', e.currentTarget).each(function(e) {
          var group = this;
          var hop_id = $(this).attr('hop_id');
          var hop = Drupal.settings.ecenterNetwork.seriesLookupByID[hop_id];

          var tc = $('#utilization-tables').data('tablechart');
          
          if (tc) {
            var lh = tc['default'].chart.plugins.linehighlighter;
            lh.unhighlightSeries(hop.sidx, tc['default'].chart);
          }

          /*if (map_highlight) {
            var ol = $('#openlayers-map-auto-id-0').data('openlayers');
            var map = ol.openlayers;
            var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop();
            var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
            var feature = layer.getFeatureBy('ecenterID', hop.hub);
            control.callbacks.out.call(control, feature);
          }*/

          $('circle', group).each(function() {
            this.setAttribute('stroke', '#555555');
          });
          $('text', group).each(function() {
            this.setAttribute('fill', '#555555');
          });
          $('rect', group).each(function() {
            this.setAttribute('fill', '#ffffff');
          });
        }); 
      }
    });
  }
}

EcenterNetwork = {};

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

})(jQuery);
