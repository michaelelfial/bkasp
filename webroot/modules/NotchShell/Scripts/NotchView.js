function NotchView() {
	TrivialView.apply(this,arguments);
}
NotchView.Inherit(TrivialView,"NotchView");
NotchView.prototype.onStart = function() {
	var app = this.findService("NotchShellApp");
	app.toggleUI();
}