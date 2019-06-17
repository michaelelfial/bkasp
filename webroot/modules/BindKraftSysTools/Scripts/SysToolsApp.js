// SysToolsApp
function SysToolsApp(qbface) {
    AppBase.apply(this, arguments);
	this.$qb = qbface;
}
SysToolsApp.Inherit(AppBase, "SysToolsApp");
SysToolsApp.Implement(IPlatformUtilityImpl, "BindKraftSysTools");
SysToolsApp.Implement(IProcessAcceleratorsImpl);
SysToolsApp.registerShellCommand("systools", "sys", function () {
    Shell.launchAppWindow("SysToolsApp");
}, "A collection of diagnostic and system maintenance client-side tools (UI).");
SysToolsApp.prototype.get_caption = function () {
    return "System tools";
};
SysToolsApp.prototype.provideAsServices = new InitializeArray("System tools services", ["PAppletStorage", "SysToolsApp"]);
SysToolsApp.prototype.toolUrl = function (toolname) {
    //This is a little hepler to avoid repeating things over and over.
    return this.moduleUrl("r", "systools", toolname);
}
SysToolsApp.prototype.fireNumWindows = function() {
	if (this.$qb) {
		if (this.pages && this.pages.children) {
			var count = this.pages.children.length;
			this.$qb.leasedDispatch(this,"windows").invoke(this,count);
		}
	}
}
SysToolsApp.prototype.subscribeForWindows = function(client) {
	if (this.$qb) {
		this.$qb.subscribeClientFor(this, "windows", client)
	}
}
SysToolsApp.prototype.unSubscribeForWindows = function(client) {
	if (this.$qb) {
		this.$qb.unsubscribeClientFor(this, "windows", client)
	}
}
SysToolsApp.prototype.appinitialize = function (callback, args) {
    this.root = Shell.createStdAppWindow();
	Delegate.stubAProperty(this.root,"caption",this,"caption");
    this.placeWindow(this.root);
    this.root.set_windowrect(new Rect(50, 50, 1000, 500));
    this.root.updateTargets();
    return true;
}
SysToolsApp.prototype.run = function () {
    var me = this;
    // Create a splitter as our root app window
    this.split = new TouchSplitterWindow(
        WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,
        { autocollapse: true, leftthreshold: 20, rightthreshold: 80, initial: 25,
			on_notifyPageAdded: function() {
				me.fireNumWindows();
			},
			on_notifyPageRemoved:function() {
				me.fireNumWindows();
			}
		}

    );
    this.pages = null;
    // Ask the host window (we expect to be created by the shell) to position our root window.
    this.split.set_windowparent(this.root);
    // this.placeWindow(this.split);
    // Place a simple menu (tools list) as ledt side.
    this.split.setLeft(new SimpleViewWindow(WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,{
        url: this.toolUrl("toolslist"),
        on_ViewLoaded: function (msg) {
            var view = msg.target.currentView;
            if (BaseObject.is(view, "Base")) {
                //var dc = view.get_data();
                var dc = view.get_data().data;
                // Register accelerators 
                dc.Each(function (idx, item) {
                    me.registerAccelerator(item.accel, new Delegate(me, me.AccelOpenView), item);
                });
            }
        }
    }));
    // Create a tabset window
    this.pages = new TabSetWindow(WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible | WindowStyleFlags.parentnotify);
    this.pages.set_caption("Tool view");
    // Place it in the rith side of the splitter. We are going to open the tools as tab pages
    this.split.setRight(this.pages);
    // Call a method to open something on startup. We leave this in separate method in order to be able to rethink it further later.
    // Use callAsunc to distribute the work in time, we do not need this start window(s) urgently.
    this.callAsync(this.$initialViews, this.pages);
}
SysToolsApp.prototype.appshutdown = function () {
    jbTrace.log("Shutting down");
    AppBase.prototype.appshutdown.apply(this, arguments);
}
SysToolsApp.prototype.windowDisplaced = function (wnd) {
	if (wnd == this.root) {
		this.ExitApp();
	}
}
SysToolsApp.prototype.$initialViews = function (pages) {
    this.LoadView("start");
}
SysToolsApp.prototype.LoadView = function (tool, clientData) {
    var page = new SimpleViewWindow(new TemplateConnector(SysToolsApp.hostedwindowtemplate),
	{
        url: this.toolUrl(tool), directData: clientData
    });
    page.setWindowStyles(WindowStyleFlags.adjustclient, "set");
    page.set_caption(tool);
    this.pages.addPage(page);
    this.pages.selectPage(page);
	this.fireNumWindows();
    return page;
}
SysToolsApp.prototype.AccelOpenView = function (app, accel) {
    var tool = BaseObject.getProperty(accel, "userdata.open");
    if (typeof tool == "string") this.LoadView(tool);
}
SysToolsApp.prototype.OpenView = function (e, dc, binding, parameter) {
    this.LoadView(dc.open);
}

SysToolsApp.prototype.CloseAll = function (e, dc) {
    this.pages.removeAllPages();
}
SysToolsApp.prototype.OpenDataViewer = function (o) {
    var page = new SimpleViewWindow({
        url: this.toolUrl("databrowse"),
        directData: { caption: o.caption, data: o.data }
    },
        new TemplateConnector(SysToolsApp.hostedwindowtemplate));
    page.setWindowStyles(WindowStyleFlags.adjustclient, "set");
    page.set_caption(o.caption);
    this.pages.addPage(page);
    this.pages.selectPage(page);
	this.fireNumWindows();
    return page;
};
SysToolsApp.prototype.OpenBindViewer = function (o) {
    var page = new SimpleViewWindow({
        url: this.toolUrl("bindingsbrowse"),
        directData: { caption: o.caption, data: o.data }
    },
        new TemplateConnector(SysToolsApp.hostedwindowtemplate));
    page.setWindowStyles(WindowStyleFlags.adjustclient, "set");
    page.set_caption("Bindings viewer");
    this.pages.addPage(page);
    this.pages.selectPage(page);
	this.fireNumWindows();
    return page;
};

SysToolsApp.prototype.OpenTab = function (url, data, directData) {
    var tab = new SimpleViewWindow({ url: url, data: (data != null) ? data : {}, directData: directData }, new TemplateConnector(SysToolsApp.hostedwindowtemplate));
    tab.setWindowStyles(WindowStyleFlags.adjustclient, "set");
    this.pages.addPage(tab);
    this.pages.selectPage(tab);
	this.fireNumWindows();
    return tab;
}
SysToolsApp.prototype.OnOpenTab = function (e, dc, binding, parameter) {
    if (parameter != null && parameter.length > 0) {
        return this.OpenTab(parameter);
    } else {
        return this.OpenTab(dc.url, {}, {});
    }
}
SysToolsApp.prototype.OnOpenTabWithData = function (e, dc, binding, parameter) {
    return this.OpenTab(parameter, dc);
}


