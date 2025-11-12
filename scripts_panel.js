var slideFromRight = $('#slideoutpanel').SlideOutPanel(
	{
		width: '50vw',
		enableEscapeKey: true,
	}
);
function OpenPanel() {
	console.log('1');
	slideFromRight.open();
	console.log('2');
	ViewRelated();
	console.log('3');
}
