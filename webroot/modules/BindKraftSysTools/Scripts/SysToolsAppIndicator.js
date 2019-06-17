function SysToolsAppIndicator() {
	Base.apply(this,arguments);
}
SysToolsAppIndicator.Inherit(Base,"SysToolsAppIndicator");
SysToolsAppIndicator.Implement(ITemplateSourceImpl,"systools/control-appindicator");
SysToolsAppIndicator.Implement(IAppIndicator);
SysToolsAppIndicator.Implement(IUIControl);
SysToolsAppIndicator.prototype.$windows = null;
SysToolsAppIndicator.prototype.get_windows = function() {
	if (BaseObject.is(this.$windows,"number")) {
		return this.$windows;
	} else {
		return "?"
	}
}
SysToolsAppIndicator.prototype.init = function() {
	var tml = this.get_template();
	if (tml != null) {
		JBUtil.Empty(this.root);
		$(this.root).append(tml);
	}
}
SysToolsAppIndicator.prototype.finalinit = function() {
	Messenger.Instance().subscribe("AppStartStopMessage",this.startstop);
}
SysToolsAppIndicator.prototype.numwindows = new InitializeMethodDelegate("A delegato for handling event telling me the number of windows","NumWindows");
SysToolsAppIndicator.prototype.NumWindows = function(app, nw) {
	this.$windows = nw;
	this.updateTargets();
}
SysToolsAppIndicator.prototype.startstop = new InitializeMethodDelegate("A delegato for handling AppStartStopMessage","StartStopApp");
SysToolsAppIndicator.prototype.StartStopApp = function(msg) {
	if (msg != null) {
		var app = msg.get_app();
		if (app != null) {
			if (msg.get_event() == "start") {
				this.$Plug(app);
			} else if (msg.get_event() == "stop") {
				this.$UnPlug(app);
			}
		}
	}
	// Another way to find your app
	// Shell.getAppByClassName("SysTools")
}
SysToolsAppIndicator.prototype.$Plug = function(app) {
	if (BaseObject.is(app,"SysToolsApp")) {
		app.subscribeForWindows(this.numwindows);
	}
}
SysToolsAppIndicator.prototype.$UnPlug = function(app) {
	if (BaseObject.is(app,"SysToolsApp")) {
		this.$windows = null;
		app.unSubscribeForWindows(this.numwindows);
		this.updateTargets();
	}
}
SysToolsAppIndicator.prototype.unPlug = function() {
	Messenger.Instance().unsubscribe("AppStartStopMessage",this.startstop);
	this.$windows = null;
	this.updateTargets();
}
