function StdRawExamples(shell) {
	AppBase.apply(this, arguments);
}
StdRawExamples.Inherit(AppBase, "StdRawExamples");
StdRawExamples.Implement(IPlatformUtilityImpl, "RawExamples");
StdRawExamples.prototype.get_caption = function () {
    return "Raw examples reffered by the BindKRaftJS documentation";
};
StdRawExamples.prototype.provideAsServices = new InitializeArray("services", ["IAppletStorage", "StdRawExamples"]);
StdRawExamples.prototype.appinitialize = function (callback, args) {
	this.root = Shell.createStdAppWindow();
	this.placeWindow(this.root);
	this.root.setWindowStyles(WindowStyleFlags.fillparent, "set");
	this.split = new TouchSplitterWindow(
        WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,
        { autocollapse: true, leftthreshold: 20, rightthreshold: 80 }
    );
	this.split.set_windowparent(this.root);
	this.menu = new SimpleViewWindow(
		WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,
		{
			url: this.toolUrl("menu"),
			on_ViewLoaded: function (msg) {
				var view = msg.target.currentView;
				// Do we need this?
        },
		on_Destroy: function(msg) {
			me.menu = null;
		}
    });
	
}


// Utilities
StdRawExamples.prototype.loadViewRawWindow = function(view, data) {
	//var viewUrl =
}