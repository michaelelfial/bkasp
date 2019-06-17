function FSBrowserView() {
	TrivialView.apply(this, arguments);
	
	this.$dir = Registers.Default().getRegister("shellfs");
}
FSBrowserView.Inherit(TrivialView,"FSBrowserView");
FSBrowserView.ImplementProperty("dir", new Initialize("Initial directory", null));
FSBrowserView.prototype.get_caption = function() {
	return "FS Browser";
}


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