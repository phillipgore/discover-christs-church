 $(document).ready(function() {
 	
	$('body').on('click', 'a', function(e) {
		e.preventDefault();
		$('.container').load($(this).prop('href'));
		
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
				}
			}
		});
	});

});