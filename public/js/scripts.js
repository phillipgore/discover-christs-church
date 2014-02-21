$( document ).ready(function() {
	
	$(window).on('resize', function() {
		centerItem($('.video_container'));
	});
	
	$('.video_open').on('click', function(e) {
		e.preventDefault();
		centerItem($('.video_container'));
		$('.video_container').fadeIn();
	});
	
	$('.video_close').on('click', function(e) {
		e.preventDefault();
		player.api('pause');
		$('.video_container').fadeOut('fast');
	});
	
	function centerItem(item) {
		var top = ($(window).outerHeight() / 2) - ($(item).outerHeight() / 2);
		var left = ($(window).outerWidth() / 2) - ($(item).outerWidth() / 2);
		$(item).css({
			"top": top,
			"left": left
		});
		
	}

	$('body').on('click', 'a', function(e) {
		if (!$(this).hasClass('download')) {
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
	
	var iframe = $('#player')[0],
	        player = $f(iframe),
	        status = $('.status');
	
	    player.addEvent('ready', function() {
	        status.text('ready');
	
	        player.addEvent('pause', onPause);
	        player.addEvent('finish', onFinish);
	        player.addEvent('playProgress', onPlayProgress);
	    });
	
	    function onPause(id) {
	        status.text('paused');
	    }
	
	    function onFinish(id) {
	        status.text('finished');
	    }
	
	    function onPlayProgress(data, id) {
	        status.text(data.seconds + 's played');
	    }
	
});