window.addEvent('domready', function() {

	var myVerticalSlide = new Fx.Slide('vertical_slide').hide();
	var comment = new Fx.Slide('comment-s').hide();

	$('v_toggle').addEvent('click', function(e){
		e.stop();
		myVerticalSlide.toggle();
	});

	$('comment-t').addEvent('click', function(e){
		e.stop();
		comment.toggle();
	});

});
