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
  });
}

// Takes results element
$.ecenter_network = function(el) {
  this.el = el;
  for (var name in $.fn.ecenter_network.plugins) {
    var plugin = $.fn.ecenter_network.plugins[name];
    plugin.call(this);
  }
}

// World's tiniest plugin architecture
$.fn.ecenter_network.plugins = {}

$.fn.ecenter_network.plugins.ajax = function() {
  var el = this.el;


  $(el).bind({
    'ajaxStart' : function(ajax, xhr) {

      // Clear out old results
      $('#results', el).text('');

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

$.fn.ecenter_network.plugins.date_behavior = function() {
  $('#recent-select input, #date-select input', this.el).change(function() {
    var dst = $('.dst-wrapper input', this.el);
    if (dst.val()) {
      dst.data('autocomplete')._trigger('change');
    }
  });
}

$.fn.ecenter_network.plugins.traceroute = function() {
  var el = this.el;
  $(el).bind({
    'ajaxSuccess' : function() {
      $('<div id="traceroute-wrapper">').remove();
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
      }
    }
  });
}

})(jQuery);
