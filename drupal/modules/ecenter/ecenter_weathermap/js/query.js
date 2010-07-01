Drupal.behaviors.EcenterNetworkQuery = function(context) {

  // Hide submit form
  //$('#ecenter-network-query-select-form #edit-submit').hide();
  $('#edit-dst-ip_quickselect').attr('disabled', true);
  $('#edit-dst-ip_quickselect_dropdown').addClass('disabled');

  // Submit when destination is filled in
  $('#edit-src-ip_quickselect').blur(function(e) {
    $.ajax({
      url: Drupal.settings.basePath + 'weathermap/js/services/',
      dataType: 'html',
      type: 'POST',
      data: {
        src_ip: $('#edit-src-ip').val()
      },
      success: function(data) {
        $('#edit-dst-ip-wrapper').replaceWith(data);
        Drupal.behaviors.QuickSelect();
      },
      error: function(request, textStatus, error) {
        if (request.status == 404) {
          $('#edit-dst-ip_quickselect').attr('disabled', true);
          $('#edit-dst-ip_quickselect_dropdown').addClass('disabled');
          $('#edit-dst-ip_quickselect').val(Drupal.t('No destinations available for this source'));
        }
        else {
          alert(Drupal.t('The network query failed. Please contact your administrator.'));
        }
      }
    });
  });

  // Submit when destination is filled in
  /*$('#edit-dst-ip_quickselect').live('blur', function() {
    console.log('hullo');
    $.ajax({
      path: Drupal.settings.basePath + '/weathermap/js/data/',
      dataType: 'html',
      type: 'POST',
      data: {
        src_ip: $('#edit-src-ip').val(),
        dst_ip = $('#edit-dst-ip').val()
      },
      success: function(data) {
        console.log(data);
      }
    });
  });*/
}
