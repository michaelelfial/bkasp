function DjamApp() {
	AppBaseEx.apply(this, arguments);
}
DjamApp.Inherit(AppBaseEx,"DjamApp");
DjamApp.Implement(IPlatformUtilityImpl, "Djamdji");
DjamApp.prototype.get_caption = function() {
	return "Playground";
};
DjamApp.prototype.provideAsServices = new InitializeArray("Playground", ["IAppletStorage","DjamApp"]);

DjamApp.prototype.initialize = function (callback, args) {
	var op = new Operation(null, 10000);
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	// return op;
	this.root = Shell.createStdAppWindow();
	this.placeWindow(this.root);
	this.root.set_windowrect(new Rect(50,50,600,500));
	this.root.updateTargets();
	this.view = new SimpleViewWindow(
		new TemplateConnector("Djamdji/UIExperiment1"),
		this.root,
		WindowStyleFlags.fillparent | WindowStyleFlags.visible | WindowStyleFlags.adjustclient,
		{
			loadOnCreate: true,
			url: this.moduleUrl("read","main") 
		}
	);
	//this.root.addChild(this.view);
	
	return op;
}
DjamApp.prototype.run = function(args) {}
DjamApp.prototype.shutdown = function () {
    var op = new Operation();
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	return op;
};
DjamApp.prototype.windowDisplaced = function(w) {
	if (w == this.root) {
		this.ExitApp();
	}
}



