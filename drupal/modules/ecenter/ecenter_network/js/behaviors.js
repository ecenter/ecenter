$.fn.tablechart.defaults.attachMethod = function(container) {
  $('.chart-title', this.el).after(container); 
}

// Add traceroute
Drupal.behaviors.EcenterTraceroute = function(context) {
  $('#traceroute-wrapper').remove();
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
      'mouseover' : function(e) {
        $('g.node', e.currentTarget).each(function(e) {
          var group = this;
          var hop_id = $(this).attr('hop_id');
          var hop = Drupal.settings.ecenterNetwork.seriesLookupByID[hop_id];

          var tc = $('#utilization-tables').data('tablechart');
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
          
          /*var ol = $('#openlayers-map-auto-id-0').data('openlayers');
          var map = ol.openlayers;
          var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop();
          var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
          var feature = layer.getFeatureBy('ecenterID', hop.hub);
          
          control.callbacks.over.call(control, feature);*/

          $('circle', group).each(function() {
            this.setAttribute('stroke', color);
          });
          $('text.label', group).each(function() {
            this.setAttribute('fill', '#ffffff');
          });
          $('text.hub-label', group).each(function() {
            this.setAttribute('fill', '#000000');
          });
          $('rect.label-background', group).each(function() {
            this.setAttribute('fill', color);
            this.setAttribute('fill-opacity', 1);
          });
          
        });
      },
      'mouseout' : function(e) {
        $('g.node', e.currentTarget).each(function(e) {
          var group = this;
          var hop_id = $(this).attr('hop_id');
          var hop = Drupal.settings.ecenterNetwork.seriesLookupByID[hop_id];

          var tc = $('#utilization-tables').data('tablechart');
          var lh = tc['default'].chart.plugins.linehighlighter;
          lh.unhighlightSeries(hop.sidx, tc['default'].chart);

          /*var ol = $('#openlayers-map-auto-id-0').data('openlayers');
          var map = ol.openlayers;
          var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop();
          var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
          var feature = layer.getFeatureBy('ecenterID', hop.hub);
          
          control.callbacks.out.call(control, feature);*/

          $('circle', group).each(function() {
            this.setAttribute('stroke', '#999999');
          });
          $('text.label', group).each(function() {
            this.setAttribute('fill', '#000000');
          });
          $('text.hub-label', group).each(function() {
            this.setAttribute('fill', '#444444');
          });
          $('rect.label-background', group).each(function() {
            this.setAttribute('fill', '#ffffff');
            this.setAttribute('fill-opacity', 0.65);
          });
        }); 
      }
    });


  }
}

// Catchall for minor behavior modifications
Drupal.behaviors.EcenterEvents = function(context) {
  //try { console.log(context, 'EcenterEvents called'); } catch(e) {}

  // Clear out results wrapper
  $('#query input[type=hidden]').change(function() {
    //try { console.log('clear results wrapper:', this); } catch(e) {}
    $('#results-wrapper').text('');
  });
}

Drupal.behaviors.EcenterShowTables = function(context) {
  var show_label = Drupal.t('Show data');
  var hide_label = Drupal.t('Hide data');
  $('<button class="toggle-data">' + show_label + '</button>')
  .toggle(function() {
    //try { console.log(this, 'showing data tables'); } catch(e) {}
    $(this).text(hide_label).parents('.wrapper').find('.data-tables').slideDown('fast');
  }, function() {
    //try { console.log(this, 'hiding data tables'); } catch(e) {}
    $(this).text(show_label).parents('.wrapper').find('.data-tables').slideUp('fast');
  })
  .appendTo($('.chart-title', context));
}

EcenterNetwork = {};

EcenterNetwork.selectFeature = function(select) {
  var maps = Drupal.settings.openlayers.maps;
  var val = $(this).val().split(':', 2);
  var query_type = val[0];
  var query_value = val[1];

  //try { console.log('selectFeature called'); } catch(e) {}

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

Drupal.behaviors.EcenterSelectSetForm = function(context) {
  var src = $('#edit-network-wrapper-query-src-wrapper-src');
  var dst = $('#edit-network-wrapper-query-dst-wrapper-dst');

  if (src.val()) {
    //try { console.log('calling select feature for source', this); } catch(e) {}
    EcenterNetwork.selectFeature.call(src.get(0), true);
  }
}

/*
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
    //try { console.log('clearing out remembered form values'); } catch(e) {}
    EcenterNetwork.selectFeature.call(src_select, false);
  }

  // If a src/dst changes, change the map, too.
  $('#ecenter-network-select-form #src-wrapper select, #ecenter-network-select-form #dst-wrapper select')
  .change(function(e) { 
    //try { console.log('calling select feature', this); } catch(e) {}
    EcenterNetwork.selectFeature.call(this, true);
  });

  // Bind to ajaxSend event
  $('#ecenter-network-select-form').bind('ajaxSend', function(ajax, xhr) {
    self = this;

    /*try { console.log(ajax, 'ajax send called: ajax'); } catch(e) {}
    try { console.log(xhr, 'ajax send called: xhr'); } catch(e) {}
    try { console.log(this, 'ajax send called: this'); } catch(e) {}*/

    // Add overlay...
    $(this).addClass('data-loading').css('position', 'relative');

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
    $(this).prepend(overlay);
    overlay.fadeIn('slow');

    $('button.cancel', overlay).click(function(e) {
      e.stopPropagation();

      try { console.log('cancel button clicked', xhr); } catch(e) {}

      xhr.aborted = true;
      xhr.abort();

      $(self).removeClass('data-loading');

      $('.loading-overlay', self).fadeOut('fast', function() {
        $(this).remove();
      });

      return false;
    });
  });

  // Bind to ajaxSuccess event
  $('#ecenter-network-select-form').bind('ajaxSuccess', function() {
    // Add overlay...
    $(this).removeClass('data-loading');
    $('.loading-overlay', this).fadeOut('fast', function() {
      $(this).remove();
    });
  });

  // Behind to ajaxError event
  $('#ecenter-network-select-form').bind('ajaxError', function() {
    try { console.log('ajaxError triggered'); } catch(e) {}
    var input = $('#edit-network-wrapper-query-dst-wrapper-dst-wrapper input');
    input.val('');
    input.data('autocomplete')._trigger('change');
  });

  // Bind to series highlight
  $('#results').live('jqplotHighlightSeries', function(e, sidx, plot) {
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
      
      control.callbacks.over.call(control, feature);
    
      var traceroutes = $('#traceroute').data('traceroute');
      var traceroute = traceroutes['default'].svg;
      var group = $('g[hop_id="'+ hop.id +'"]', traceroute.root());
      group.trigger('mouseover');
    }
  });

  // Bind to series unhighlighting
  $('#results').live('jqplotUnhighlightSeries', function(e, sidx, plot) {
  
    var hop = Drupal.settings.ecenterNetwork.seriesLookupByIndex[sidx];
    var ol = $('#openlayers-map-auto-id-0').data('openlayers');
    var map = ol.openlayers;
    var layer = map.getLayersBy('drupalID', 'ecenter_network_traceroute').pop(); 
    var control = map.getControlsBy('drupalID', 'ecenterSelect').pop();
    var feature = layer.getFeatureBy('ecenterID', hop.hub);
    
    control.callbacks.out.call(control, feature);

    var traceroutes = $('#traceroute').data('traceroute');
    var traceroute = traceroutes['default'].svg;
    var group = $('g[hop_id="'+ hop.id +'"]', traceroute.root());
    group.trigger('mouseout');
    
  });

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
});


