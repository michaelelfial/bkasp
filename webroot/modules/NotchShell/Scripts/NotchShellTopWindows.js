function NotchShellTopWindows() {
	TrivialView.apply(this, arguments);
}
NotchShellTopWindows.Inherit(TrivialView, "NotchShellTopWindows");

NotchShellTopWindows.prototype.$window = null;
NotchShellTopWindows.prototype.set_window = function(v) {
	this.$window = v;
}
NotchShellTopWindows.prototype.get_window = function() {
	if (this.$window != null) return this.$window;
	return Shell.get_workspacewindow();
}
NotchShellTopWindows.prototype.get_windows = function() {
	var w = this.get_window();
	var windows = [];
	if (w != null) {
		windows = Array.createCopyOf(w.children);
	}
	return windows;
}
NotchShellTopWindows.prototype.OnWindow = function(e, w) {
	if (BaseObject.is(w,"BaseWindow")) {
		var f = w.getWindowStyles();
		
		if ((f & WindowStyleFlags.visible) != 0) {
			w.setWindowStyles(WindowStyleFlags.visible, "reset");
		} else {
			w.setWindowStyles(WindowStyleFlags.visible, "set");
		}
	}
}
NotchShellTopWindows.prototype.OnWindowMaxRestore = function(e, w) {
	if (BaseObject.is(w,"BaseWindow")) {
		var f = w.getWindowStyles();
		
		if ((f & WindowStyleFlags.fillparent) != 0) {
			w.setWindowStyles(WindowStyleFlags.fillparent, "reset");
		} else {
			w.setWindowStyles(WindowStyleFlags.fillparent, "set");
		}
	}
}
NotchShellTopWindows.prototype.FmtType = {
	ToTarget: function(v) {
		if (v != null) {
			return v.classType();
		}
		return "unknown";
	},
	FromTarget: function(v) {
		return v;
	}
};
NotchShellTopWindows.prototype.get_windowicon = function () {
	var w = this.get_window();
	if (BaseObject.is(w, "BaseWindow")) {
		if (BaseObject.is(w,"TouchSplitterWindow")) return "splitter";
		if (BaseObject.is(w,"PageSetWindow")) return "tabs";
		if (BaseObject.is(w,"WorkspaceWindow")) return "listview";
	} 
	return "window";
	
}
