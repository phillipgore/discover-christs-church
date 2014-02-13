$( document ).ready(function() {

	$('body').on('click', 'a', function(e) {
		if (!$(this).hasClass('download')) {
			e.preventDefault();
			if (!$(this).hasClass('outside_link')) {
				e.preventDefault();
				$('.cover').fadeIn('fast');
				$('.container').load($(this).prop('href') + " .content", function() {
					$('.cover').fadeOut('fast');
				});
				History.pushState(null, "Discover Christ's Church", $(this).attr('href'));
			}
		}
	});
	
	$('body').on('submit', 'form', function(e) {
			e.preventDefault();
			$('.cover').fadeIn('fast');
			$.ajax({
				url: $(this).prop('action'),
				type: $(this).prop('method'),
				datatype: 'html',
				data: $(this).serialize(),
				success: function(data){
					if (data.charAt(0) === "1") {
						$('.cover').fadeOut('fast');
						$('.jsNotice').html(data.slice(2)).slideDown();
					} else {
						$('.container').load(data + " .content", function() {
							$('.cover').fadeOut('fast');
						});
						History.pushState(null, "Discover Christ's Church", data);
						console.log(data)
					}
				}
			});
			return false;
	});
	
	
	var History = window.History;
	if ( !History.enabled ) {
	    return false;
	}
	
	History.Adapter.bind(window,'statechange');
	
});