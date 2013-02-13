jQuery(document).ready(function($) {
	$('input:checkbox[name=pause]').click( function(){
		var queue = $(this);
		var data = {'queue_name': queue.val()};
    data.action = queue.is(':checked') ?  'pause' : 'unpause';
		$.ajax({
		  type: 'POST',
		  url: location.href,
		  data: data,
		  async: false,
		  cache: false,
		  success: function() { return true; },
		  error: function() { return false; },
		  dataType: 'json'
		});
  });
  $('input:checkbox[name=super_pause]').click( function(){
    var queue = $(this);
    var data = {'queue_name': queue.val()};
    data.action = queue.is(':checked') ?  'super_pause' : 'super_unpause';
    $.ajax({
      type: 'POST',
      url: location.href,
      data: data,
      async: false,
      cache: false,
      success: function() { return true; },
      error: function() { return false; },
      dataType: 'json'
    });
  });
});
