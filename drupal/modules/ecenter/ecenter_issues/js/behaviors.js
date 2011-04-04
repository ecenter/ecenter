(function($) {

Drupal.behaviors.issueModal = function() {

  $('a.issue-modalframe:not(.issue-modalframe-processed)')
  .addClass('issue-modalframe-processed')
  .click(function(e) {
    e.stopPropagation();
    // Build modal frame options.
    var modalOptions = {
      url: $(this).attr('href'),
      autoFit: true,
    };
    Drupal.modalFrame.open(modalOptions);
    return false;
  });
 
}

})(jQuery);
