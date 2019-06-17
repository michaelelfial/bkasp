function NotchShellMenu() {
	TrivialView.apply(this, arguments);
	
	this.$shellfs = Registers.Default().getRegister("shellfs");
}
NotchShellMenu.Inherit(TrivialView,"NotchShellMenu");
NotchShellMenu.ImplementProperty("shellfs", new Initialize("Shell FS", null));
NotchShellMenu.prototype.get_caption = function() {
	return "Start menu";
}
NotchShellMenu.prototype.get_startmenu = function() {
	var shellfs = Registers.Default().getRegister("shellfs");
	var startmenu = shellfs.cd("startmenu");
	if (startmenu != null) {
		return startmenu.get_files();
	}
	return null;
}
NotchShellMenu.prototype.$backupicon = new IconSpec("notchshell","app.svg");
NotchShellMenu.prototype.get_backupicon = function() {
	
	return this.$backupicon;
}
NotchShellMenu.prototype.$viewmodes = new InitializeArray("The modes",[
{ mode: "list", icon: "list.svg"},
{ mode: "icons", icon: "grid.svg"}
]);
NotchShellMenu.prototype.get_viewmodes = function() {
	return this.$viewmodes;
}




function NotchShellApp_IconComponent() {
	Base.apply(this,arguments);
}
NotchShellApp_IconComponent.Inherit(Base, "NotchShellApp_IconComponent");
NotchShellApp_IconComponent.Implement(ITemplateSourceImpl, new Defaults("templateName", "notchshell/component-icon"));
NotchShellApp_IconComponent.Implement(IUIControl);
NotchShellApp_IconComponent.ImplementProperty("icon", new Initialize("IconSpec object",null), null, "OnIconChanged");
NotchShellApp_IconComponent.ImplementProperty("backupicon", new Initialize("IconSpec object",null), null, "OnIconChanged");
NotchShellApp_IconComponent.ImplementProperty("image", new Initialize("The ImageX from the template must be injected here", null));
NotchShellApp_IconComponent.prototype.init = function() {
	var el = $(this.root);
	var c = el.children();
	if (c.length == 0) {
		var tml = this.get_template();
		el.empty();
		el.append(tml);
	}
}
NotchShellApp_IconComponent.prototype.finalinit = function() {
	var donothing = null;
}
NotchShellApp_IconComponent.prototype.OnIconChanged = function() {
	if (!this.$finalInitPending) {
		this.updateTargets();
	}
}
NotchShellApp_IconComponent.prototype.$getIconSpec = function(prop) {
	if (BaseObject.is (this.get_icon(), "IconSpec")) {
		return this.get_icon()["get_" + prop]();
	} else if (BaseObject.is (this.get_backupicon(), "IconSpec")) {
		return this.get_backupicon()["get_" + prop]();
	}
	return null;
}
NotchShellApp_IconComponent.prototype.get_modulename = function() {
	return this.$getIconSpec("modulename");
}
NotchShellApp_IconComponent.prototype.get_servername = function() {
	return this.$getIconSpec("servername");
}
NotchShellApp_IconComponent.prototype.get_iconpath = function() {
	var rt = this.$getIconSpec("restype");
	var rp = this.$getIconSpec("respath");
	return (rt != null && rp != null)?(rt + "/" + rp):null;
}

/*
function FSBrowser_Directory() {
	Base.apply(this, arguments);
}
FSBrowser_Directory.Inherit(Base,"FSBrowser_Directory");
FSBrowser_Directory.Implement(IUIControl);
FSBrowser_Directory.ImplementProperty("dir", new Initialize("A MemoryFSDirectory object", null, "OnDirChanged"));
FSBrowser_Directory.prototype.OnDirChanged = function(propname, oldvalue, newvalue) {
	this.updateTargets();
}
FSBrowser_Directory.prototype.get_files = function() {
	var dir = this.get_dir();
	if (BaseObject.is(dir, "MemoryFSDirectory")) {
		return dir.get_files();
	}
}
FSBrowser_Directory.prototype.get_dirs = function() {
	var dir = this.get_dir();
	if (BaseObject.is(dir, "MemoryFSDirectory")) {
		return dir.get_directories();
	}
}
FSBrowser_Directory.prototype.get_contents = function() {
	var dir = this.get_dir();
	if (BaseObject.is(dir, "MemoryFSDirectory")) {
		return dir.get_contents();
	}
}
FSBrowser_Directory.prototype.IsDirFormatter = {
	ToTarget: function(v) {
		return BaseObject.is(v, "IMemoryDirectory");
	},
	FromTarget: function(v) {
		return v;
	}
}
FSBrowser_Directory.prototype.fsitemtype = {
	ToTarget: function(v) {
		if (BaseObject.is(v, "IMemoryDirectory")) {
			return "directory";
		} else if (BaseObject.is(v, "IMemoryFile")) {
			return "file";
		} else {
			return "unknown";
		}
	},
	FromTarget: function(v) {
		return v;
	}
}
*/