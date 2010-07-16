// @TODO Currently REALLY ROUGH!!!
Drupal.behaviors.EcenterTraceroute = function(context) {
   $('.hop-wrapper div').hide(); 
   $('.hop-wrapper').hover(function() {
     $('div', $(this)).show();
   }, function() {
     $('div', $(this)).hide();
   });
}
