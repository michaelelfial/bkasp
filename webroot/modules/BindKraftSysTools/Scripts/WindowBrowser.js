function WindowBrowser() {
	Base.apply(this, arguments);
}
WindowBrowser.Inherit(Base, "WindowBrowser");
WindowBrowser.Implement(IUIControl);
WindowBrowser.prototype.$window = null;
WindowBrowser.prototype.set_window = function(v) {
	this.$window = v;
}
WindowBrowser.prototype.get_window = function() {
	if (this.$window != null) return this.$window;
	return Shell.get_workspacewindow();
}
WindowBrowser.prototype.GetWindows = function(startIn, limit) {
	var start = startIn?(startIn-1):0;
	var w = this.get_window();
	if (w != null) {
		var ch = w.children;
		var s,e;
		if (start > 0 && start < ch.length) {
			s = start;
			e = start + (limit || ch.length);
		} else if (start >= ch.length) {
			return [];
		} else {
			s = 0;
			e = limit || ch.length;
		}
		if (e > ch.length) e = ch.length;
		return ch.slice(s,e);
	}
	return [];
}
WindowBrowser.prototype.FmtType = {
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
WindowBrowser.prototype.get_windowicon = function () {
	var w = this.get_window();
	if (BaseObject.is(w, "BaseWindow")) {
		if (BaseObject.is(w,"TouchSplitterWindow")) return "splitter";
		if (BaseObject.is(w,"PageSetWindow")) return "tabs";
		if (BaseObject.is(w,"WorkspaceWindow")) return "listview";
	} 
	return "window";
	
}
WindowBrowser.prototype.FmtWindowStyles = {
	ToTarget: function(v) {
		if (v != null) {
			var r = "";
			var s = v.getWindowStyles();
			if (s & WindowStyleFlags.draggable) r += "draggable ";
			if (s & WindowStyleFlags.sizable) r += "sizable ";
			if (s & WindowStyleFlags.fillparent) r += "fillparent ";
			if (s & WindowStyleFlags.visible) r += "visible ";
			if (s & WindowStyleFlags.parentnotify) r += "parentnotify ";
			if (s & WindowStyleFlags.popup) r += "popup ";
			if (s & WindowStyleFlags.adjustclient) r += "adjustclient ";
			if (s & WindowStyleFlags.topmost) r += "topmost ";
			return r;
		}
		return "unknown";
	},
	FromTarget: function(v) {
		return v;
	}
};
WindowBrowser.prototype.FmtWindowInfoMethod = {
	ToTarget: function(v,b) {
		if (v != null && b != null) {
			return v[b.bindingParameter]();
		}
		return "unknown";
	},
	FromTarget: function(v) {
		return v;
	}
}
WindowBrowser.prototype.get_viewtype = function() {
	var w = this.get_window();
	if (w != null) {
		if (w.currentView != null) {
			if (BaseObject.is(w.currentView, "BaseObject")) {
				return w.currentView.classType();
			} else {
				return "passive view";
			}
		}
	}
	return "none";
}
WindowBrowser.prototype.get_hasactiveview = function() {
	var w = this.get_window();
	if (w != null) {
		if (w.currentView != null && BaseObject.is(w.currentView, "Base")) {
			return true;
		}
	}
	return false;
}
WindowBrowser.prototype.ShowViewDataContext = function(e, dc, binding) {
	var svc = this.findService("SysToolsApp");
	if (svc != null && BaseObject.is(dc, "BaseWindow")) {
		svc.OpenDataViewer({ caption: "Data context for a view in:" + dc.get_caption(), data: dc.currentView.get_data()});
	}
}
WindowBrowser.prototype.ShowViewObject = function(e, dc, binding) {
	var svc = this.findService("SysToolsApp");
	if (svc != null && BaseObject.is(dc, "BaseWindow")) {
		svc.OpenDataViewer({ caption: "View object in:" + dc.get_caption(), data: dc.currentView});
	}
}
WindowBrowser.prototype.ShowViewBindings = function(e, dc, binding) {
	var svc = this.findService("SysToolsApp");
	if (svc != null && BaseObject.is(dc, "BaseWindow")) {
		svc.OpenBindViewer({ caption: "View bindings in:" + dc.get_caption(), data: dc.currentView});
	}
}
WindowBrowser.prototype.ShowCreateParams = function(e, dc, binding) {
	var svc = this.findService("SysToolsApp");
	if (svc != null && BaseObject.is(dc, "BaseWindow")) {
		svc.OpenDataViewer({ caption: "Create params for:" + dc.get_caption(), data: dc.createParameters});
	}
}
WindowBrowser.prototype.ShowWindowDC = function(e, dc, binding) {
	var svc = this.findService("SysToolsApp");
	if (svc != null && BaseObject.is(dc, "BaseWindow")) {
		svc.OpenDataViewer({ caption: "Window data context for:" + dc.get_caption(), data: dc.get_data()});
	}
}
WindowBrowser.prototype.ShowTraceMessages = function(e, dc, binding) {
	var svc = this.findService("SysToolsApp");
	if (svc != null && BaseObject.is(dc, "BaseWindow")) {
		svc.LoadView("windowmsgs",{ caption: "Trace messages for window:" + dc.$__instanceId, window: dc});
	}
}