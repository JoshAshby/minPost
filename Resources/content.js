window.addEvent('domready', function() {
	
	//create our Accordion instance
	var myAccordion = new Accordion($('accordion'), 'h4.toggler', 'div.element', {
		opacity: false,
		onActive: function(toggler, element){
			toggler.setStyle('color', '#41464D');
		},
		onBackground: function(toggler, element){
			toggler.setStyle('color', '#528CE0');
		}
	});
});
