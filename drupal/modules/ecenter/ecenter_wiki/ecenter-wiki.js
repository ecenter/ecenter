(function($) {

Drupal.behaviors.EcenterWiki = function(context) {
  $('.view-id-ecenter_wiki').masonry({
    itemSelector : '.group'
  });
}

})(jQuery);
