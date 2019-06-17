function NotchShellComponent_Icon() {
	Base.apply(this,arguments);
}
NotchShellComponent_Icon.Inherit(Base, "NotchShellComponent_Icon");
NotchShellComponent_Icon.Implement(ITemplateSourceImpl, new Defaults("templateName", "notchshell/component-icon"));
NotchShellComponent_Icon.Implement(IUIControl);
NotchShellComponent_Icon.ImplementProperty("icon", new Initialize("IconSpec object",null), null, "OnIconChanged");
NotchShellComponent_Icon.ImplementProperty("backupicon", new Initialize("IconSpec object",null), null, "OnIconChanged");
NotchShellComponent_Icon.ImplementProperty("image", new Initialize("The ImageX from the template must be injected here", null));
NotchShellComponent_Icon.prototype.init = function() {
	var el = $(this.root);
	var c = el.children();
	if (c.length == 0) {
		var tml = this.get_template();
		el.empty();
		el.append(tml);
	}
}
NotchShellComponent_Icon.prototype.finalinit = function() {
	var donothing = null;
}
NotchShellComponent_Icon.prototype.OnIconChanged = function() {
	if (!this.$finalInitPending) {
		this.updateTargets();
	}
}
NotchShellComponent_Icon.prototype.$getIconSpec = function(prop) {
	if (BaseObject.is (this.get_icon(), "IconSpec")) {
		return this.get_icon()["get_" + prop]();
	} else if (BaseObject.is (this.get_backupicon(), "IconSpec")) {
		return this.get_backupicon()["get_" + prop]();
	}
	return null;
}
NotchShellComponent_Icon.prototype.get_modulename = function() {
	return this.$getIconSpec("modulename");
}
NotchShellComponent_Icon.prototype.get_servername = function() {
	return this.$getIconSpec("servername");
}
NotchShellComponent_Icon.prototype.get_iconpath = function() {
	var rt = this.$getIconSpec("restype");
	var rp = this.$getIconSpec("respath");
	return (rt != null && rp != null)?(rt + "/" + rp):null;
}