window.addEvent('domready', function() {

	var myVerticalSlide = new Fx.Slide('vertical_slide').hide();



	$('v_toggle').addEvent('click', function(e){
		e.stop();
		myVerticalSlide.toggle();
	});
});
