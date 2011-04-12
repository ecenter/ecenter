// Test behaviors...

(function($) {

Drupal.behaviors.EcenterTestTraceroute = function(context) {
  for (var key in Drupal.settings.ecenter_test_traceroute) {
    var trace = Drupal.settings.ecenter_test_traceroute[key];
    $('#' + trace.id + ' .visual-traceroute-wrapper').traceroute(trace.diff);
  
    var traceroutes = $('#' + trace.id + ' .visual-traceroute-wrapper').data('traceroute');
    var traceroute = traceroutes['default'].svg;

    $('.match, .diff .node', traceroute.root()).
    bind({
      'mouseover' : function(e) {
        $('circle', e.currentTarget).each(function() {
          this.setAttribute('stroke', '#0000ff');
        });
        $('text', e.currentTarget).each(function() {
          this.setAttribute('fill', '#ffffff');
        });
        $('rect', e.currentTarget).each(function() {
          this.setAttribute('fill', '#0000ff');
        });
      },
      'mouseout' : function(e) {
        $('circle', e.currentTarget).each(function() {
          this.setAttribute('stroke', '#555555');
        });
        $('text', e.currentTarget).each(function() {
          this.setAttribute('fill', '#555555');
        });
        $('rect', e.currentTarget).each(function() {
          this.setAttribute('fill', '#eeeeee');
        });
      }
    });
  }
}

}) (jQuery);
