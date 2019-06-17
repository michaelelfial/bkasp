/**
	Displays all the shortcuts from a specified dircotry from the shellfs
*/
function NotchShellComponent_ShortcutsDir() {
	Base.apply(this,arguments);
}
NotchShellComponent_ShortcutsDir.Inherit(Base,"NotchShellComponent_ShortcutsDir");
NotchShellComponent_ShortcutsDir.Implement(ITemplateSourceImpl, new Defaults("templateName", "notchshell/component-startmenu"));
NotchShellComponent_ShortcutsDir.Implement(IUIControl);
NotchShellComponent_ShortcutsDir.Implement(IFreezable);
// Properties
NotchShellComponent_ShortcutsDir.ImplementProperty("caption", new InitializeStringParameter("Caption to show. Some template may not show it.",null));
NotchShellComponent_ShortcutsDir.ImplementProperty("detailed", new InitializeBooleanParameter("If the template supports a detailed display it can switch to it depending on this prperty. Otherwise it will have no effect",false));
NotchShellComponent_ShortcutsDir.ImplementProperty("directory", new Initialize("The directory to display - bind it here", null), null, "OnDirectoryChanged");
NotchShellComponent_ShortcutsDir.ImplementProperty("backupicon", new Initialize("The default icon of none is specified", new IconSpec("notchshell","app.svg")));
//NotchShellComponent_ShortcutsDir.ImplementProperty("apprunning", new Initialize("...", true));
NotchShellComponent_ShortcutsDir.prototype.$dirpath = null;
NotchShellComponent_ShortcutsDir.prototype.openevent = new InitializeEvent("Fires when shortcut is activated - clicked, selected whatever is supported by the view. handler(sender, ShellShortcut)");
NotchShellComponent_ShortcutsDir.prototype.set_dirpath = function(v) {
	if (typeof v == "string") {
		this.$dirpath = v;
		var fs = Registers.Default().getRegister("shellfs");
		var dir = fs.cd(v);
		if (dir != null) {
			this.set_directory(dir);
		}
	}
}
NotchShellComponent_ShortcutsDir.prototype.get_dirpath = function() {
	return this.$dirpath;
}
NotchShellComponent_ShortcutsDir.ImplementProperty("mode", 
													new InitializeStringParameter("Mode - has to correspond to a template in the template switcher. Default is list.", "list"), 
													null, 
													"OnModeChanged");
NotchShellComponent_ShortcutsDir.prototype.init = function() {
	var el = $(this.root);
	var c = el.children();
	if (c.length == 0) {
		var tml = this.get_template();
		el.empty();
		el.append(tml);
	}
}													
// Property callbacks
NotchShellComponent_ShortcutsDir.prototype.OnDirectoryChanged = function(name,oldv,newv) {
	if (this.isFullyInitialized()) {
		this.updateTargets();
	}
}
NotchShellComponent_ShortcutsDir.prototype.OnModeChanged = function(name,oldv,newv) {
	if (this.isFullyInitialized()) {
		this.updateTargets();
	}
}
// Template selector
NotchShellComponent_ShortcutsDir.prototype.OnSelectTemplate = function(switcher) {
	return switcher.getTemplateByKey(this.get_mode() || "list");
}
// Implemented properties
NotchShellComponent_ShortcutsDir.prototype.get_shortcuts = function() {
	var dir = this.get_directory();
	if (BaseObject.is(dir, "IMemoryDirectory")) {
		var files = dir.contents(new TypeChecker("ShellShortcut"))
		files.Each(function(idx, shk){
			if (idx % 2 == 0) {
				shk.apprunning = false;
			} else {
				shk.apprunning = true;
			}
		}); 
		return files;
	} else {
		return null;
	}
}.Returns("Array of { key: filename, value: ShellShortcut, apprunning: true/false } objects")
	.Description("Returns a list of the shortcuts in the directory enclosed in object that contains also the filename in case you want to show it in the template.");
NotchShellComponent_ShortcutsDir.prototype.onActivateShortcut = function(e, dc) {
	this.openevent.invoke(this, dc.value);	
}