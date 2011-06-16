Drupal.behaviors.EcenterTheme = function(context) {
  // Remove no-js class from template
  $(document.documentElement).removeClass('no-js');
}

// Override Tao's collapse behavior
Drupal.behaviors.tao = function (context) {
  $('fieldset.collapsible:not(.ecenter-processed) > legend > .fieldset-title a', context).each(function(i) {
    var fieldset = $(this).parents('fieldset').eq(0);

    fieldset.addClass('ecenter-processed');

    if ($('input.error, select.error, textarea.error').size()) {
      fieldset.removeClass('collapsed');
    }

    $(this).click(function(e) {
      if (fieldset.is('.collapsed')) {
        fieldset
          .removeClass('collapsed')
          .children('.fieldset-content')
          .show();

        // Replot charts, if they exist
        $('.jqplot-data', fieldset).each(function(i) {
          var tc = $(this).data('tablechart');
          for (var name in tc) {
            tc[name].chart.replot();
          }
        });
      }
      else {
        fieldset
          .addClass('collapsed')
          .children('.fieldset-content')
          .hide();
      }
      return false;
    });
  });
};

