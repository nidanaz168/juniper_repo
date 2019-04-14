$(document).ready(function(){
		$('#showheader').toggle(function(){
			$('#headerbox').slideUp('slow');
		}, function(){
			$('#headerbox').slideDown('slow');
		});
		$('.btn').click(function(){ $('#headerbox').slideUp();});
	});