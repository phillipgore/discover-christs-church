$( document ).ready(function() {

	$('body').on('click', 'a', function(e) {
		if (!$(this).hasClass('outside_link')) {
			e.preventDefault();
			$('.container').load($(this).prop('href'));
			History.pushState(null, "Discover Christ's Church", $(this).attr('href'));
		}
	});
	
	$('body').on('submit', 'form', function(e) {
		e.preventDefault();
		$.ajax({
			type: $(this).prop('method'),
			url: $(this).prop('action'),
			data: $(this).serialize(),
			success: function(data){
				if (data.charAt(0) === "1") {
					$('.jsNotice').html(data.slice(2)).slideDown();
				} else {
					$('.container').load(data);
					History.pushState(null, "Discover Christ's Church", data);
				}
			}
		});
	});
	
	
	var History = window.History;
	if ( !History.enabled ) {
	    return false;
	}
	
	History.Adapter.bind(window,'statechange');
	
});