// jQuery plugin to hide a set of Drupal date widgets
(function($) {

$.fn.datehide = function(options) {
  var opt = $.extend(true, {}, $.fn.datehide.defaults, options);

  return this.each(function(i) {
    if (!$(this).data('DateHide')) {
      new DateHide(this, opt);
    }
  });
}

$.fn.datehide.defaults = {
  'startDateSelector' : '#start-date',
  'startTimeSelector' : '#start-time',
  'endDateSelector' : '#end-date',
  'endTimeSelector' : '#end-time'
};

function DateHide(el, opt) {
  var dateform = $(el);
  dateform.hide();

  var time_display = $(opt.startDateSelector).val() + ' ' +  $(opt.startTimeSelector).val() + ' - ' + $(opt.endDateSelector).val() + ' ' + $(opt.endTimeSelector).val();

  var display_wrapper = $('<div class="datehide-display-wrapper clearfix"><div class="label"></div><div class="datehide-display"><span class="button">&#9660;</span><span class="date"></span></div></div>');
  var display = $('.datehide-display', display_wrapper);

  $('.label', display_wrapper).text(Drupal.t('Date range'));
  $('.date', display_wrapper).text(time_display);

  display.toggle(function() {
    $(this).toggleClass('open');
    $('.button', this).html('&#9650;');
    dateform.slideDown('fast');
  }, function() {
    $(this).toggleClass('open');
    $('.button', this).html('&#9660');
    dateform.slideUp('fast');
    $('.date', display_wrapper).text(time_display);
  });

  display.hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  });

  $('input', dateform).change(function() {
    time_display = $(opt.startDateSelector).val() + ' ' +  $(opt.startTimeSelector).val() + ' - ' + $(opt.endDateSelector).val() + ' ' + $(opt.endTimeSelector).val();
    $('.date', display_wrapper).text(time_display);
  });

  dateform.before(display_wrapper);

  // Save state
  dateform.data('DateHide', this);
}

})(jQuery);
