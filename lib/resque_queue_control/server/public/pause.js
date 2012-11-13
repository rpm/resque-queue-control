jQuery(document).ready(function($) {
	$('input:checkbox.pause').click( function(){
		var queue = $(this);
		var data = {'queue_name': queue.val(), 'pause': queue.is(':checked')};
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
