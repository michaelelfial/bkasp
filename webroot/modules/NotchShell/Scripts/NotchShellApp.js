// SysToolsApp
function NotchShellApp() {
    AppBase.apply(this, arguments);
}
NotchShellApp.Inherit(AppBase, "NotchShellApp");
NotchShellApp.Implement(IPlatformUtilityImpl, "notchshell");
NotchShellApp.Implement(IProcessAcceleratorsImpl);
NotchShellApp.maxWidth = 600;
NotchShellApp.notchHeight = 30;
NotchShellApp.notchMinWidth = 200;
NotchShellApp.prototype.get_caption = function () {
    return "Notch shell";
};
NotchShellApp.prototype.provideAsServices = new InitializeArray("services", ["PAppletStorage", "NotchShellApp"]);
NotchShellApp.prototype.toolUrl = function (toolname) {
    //This is a little hepler to avoid repeating things over and over.
    return this.moduleUrl("r", "main", toolname);
}
NotchShellApp.prototype.get_desktopmodule = function() {
	var env = EnvironmentContext.Global();
	return env.getEnv("topmodule","---unknown---");
}
NotchShellApp.prototype.appinitialize = function (callback, args) {
    this.root = Shell.createStdAppWindow(null, new TemplateConnector("notchshell/startpanel"));
	//this.root = Shell.createStdAppWindow(null);
    this.placeWindow(this.root,{role: "shell", position: "left"});
	// Begin Temp
    this.root.set_windowrect(new Rect(0, 0, 300, 600));
	// End Temp
	this.root.setWindowStyles(WindowStyleFlags.topmost | WindowStyleFlags.fillparent, "set");
	this.root.setWindowStyles(WindowStyleFlags.draggable, "reset");
	
	
	this.split = new TouchSplitterWindow(
        WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,
        { autocollapse: true, leftthreshold: 20, rightthreshold: 80, startmaximized: "left" }
    );
	this.split.set_windowparent(this.root);
	var me = this;
	
	this.menu = new SimpleViewWindow(WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,{
        url: this.toolUrl("menu"),
        on_ViewLoaded: function (msg) {
            var view = msg.target.currentView;
            // Do we need this?
        },
		on_Destroy: function(msg) {
			me.menu = null;
		}
    });
	this.split.setLeft(this.menu);
	
	this.topwindows = new SimpleViewWindow(WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,{
        url: this.toolUrl("topwindows"),
        on_ViewLoaded: function (msg) {
            var view = msg.target.currentView;
            // Do we need this?
        },
		on_Destroy: function(msg) {
			me.topwindows = null;
		}
    });
	this.split.setRight(this.topwindows);
    this.root.updateTargets();
	
	this.notch = new SimpleViewWindow(
		new TemplateConnector("notchshell/notchtemplate"),
		WindowStyleFlags.topmost | WindowStyleFlags.adjustclient | WindowStyleFlags.visible | WindowStyleFlags.fillparent,{
        url: this.toolUrl("notch"),
        on_ViewLoaded: function (msg) {
            var view = msg.target.currentView;
            // Do we need this?
        },
		on_Destroy: function(msg) {
			me.notch = null;
		}
    });
	this.placeWindow(this.notch,{ role: "shell", position: "top"});
	// Begin Temp
    //this.notch.set_windowrect(new Rect(50, 100, 120, 40));
	// End Temp
	
	this.callAsync(this.hideUI);
	//this.positionUI();
    return true;
}
NotchShellApp.prototype.positionUI = function() {
	var ws = Shell.get_workspacewindow();
	var rect;
	if (ws != null) {
		var cr = ws.get_clientrect();
		if (cr.w < NotchShellApp.maxWidth) {
			var rect = new Rect(cr);
			rect.h = rect.h - NotchShellApp.notchHeight;
			rect.y = NotchShellApp.notchHeight;
			this.root.setWindowStyles(WindowStyleFlags.fillparent, "reset");
			this.root.set_windowrect(rect);
		} else {
			this.root.setWindowStyles(WindowStyleFlags.fillparent, "reset");
			rect = new Rect(cr);
			rect.x = (rect.w - NotchShellApp.maxWidth)/ 2 ;
			rect.y = NotchShellApp.notchHeight;
			rect.w = NotchShellApp.maxWidth;
			rect.h = rect.h - NotchShellApp.notchHeight;
			this.root.set_windowrect(rect);
		}
		this.notch.set_windowrect(new Rect((cr.w - NotchShellApp.notchMinWidth)/2,0,NotchShellApp.notchMinWidth,NotchShellApp.notchHeight));
	}
}

NotchShellApp.prototype.showUI = function() {
	if (BaseObject.is(this.root,"BaseWindow")) {
		this.root.setWindowStyles(WindowStyleFlags.visible, "set");
		// TODO: Some dynamic sizing
		this.positionUI();
		this.root.activateWindow();
		var ws = BaseObject.getProperty(this, "topwindows.currentView", null);
		if (ws != null) ws.updateTargets();
	}
}
NotchShellApp.prototype.toggleUI = function() {
	this.root.setWindowStyles(WindowStyleFlags.visible, "set");
	this.root.activateWindow();
	Shell.get_workspacewindow().indexClientTransition("toggle")
}
NotchShellApp.prototype.hideUI = function() {
	Shell.get_workspacewindow().indexClientTransition(-1);
	this.root.activateWindow();
}
NotchShellApp.prototype.run = function () {
    
}
NotchShellApp.prototype.appshutdown = function () {
    jbTrace.log("Shutting down");
    AppBase.prototype.appshutdown.call(this, true);
}
NotchShellApp.prototype.windowDisplaced = function () {
}

NotchShellApp.prototype.OpenShortcut = function(e, dc) {
	var script = dc.get_script();
	if (typeof script == "string") {
		var op = Commander.RunGlobal(script);
	}
	this.toggleUI();
}



