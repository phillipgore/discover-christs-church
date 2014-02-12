$( document ).ready(function() {

	$('body').on('click', 'a', function(e) {
		if (!$(this).hasClass('outside_link')) {
			e.stopPropagation();
			e.preventDefault();
			$('.cover').fadeIn('fast');
			$('.container').load($(this).prop('href'), function() {
				$('.cover').fadeOut('fast');
			});
			History.pushState(null, "Discover Christ's Church", $(this).attr('href'));
		}
	});
	
	$('body').on('submit', 'form', function(e) {
		e.stopPropagation();
		e.preventDefault();
		$('.cover').fadeIn('fast');
		$.ajax({
			type: $(this).prop('method'),
			url: $(this).prop('action'),
			data: $(this).serialize(),
			success: function(data){
				if (data.charAt(0) === "1") {
					$('.cover').fadeOut('fast');
					$('.jsNotice').html(data.slice(2)).slideDown();
				} else {
					$('.container').load(data, function() {
						$('.cover').fadeOut('fast');
					});
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