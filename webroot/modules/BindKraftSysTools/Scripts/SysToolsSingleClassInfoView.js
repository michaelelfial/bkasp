/*CLASS*/
function SysToolsSingleClassInfoView() {
	TrivialView.apply(this, arguments);
}
SysToolsSingleClassInfoView.Inherit(TrivialView,"SysToolsSingleClassInfoView");
SysToolsSingleClassInfoView.prototype.settingschangedevent = new InitializeEvent("Fired when some settings change and data needs to be redraw (if this is used in UI)");
SysToolsSingleClassInfoView.prototype.get_caption = function() {
	return "Class info " + BaseObject.getProperty(this.get_data(),"classname","");
}
SysToolsSingleClassInfoView.prototype.OnDataContextChanged = function() {
	this.throwStructuralQuery(new UpdateCommandBars());
}
SysToolsSingleClassInfoView.prototype.$info = null;
SysToolsSingleClassInfoView.prototype.get_info = function() {
	return this.$info;
}
SysToolsSingleClassInfoView.prototype.OnBeforeDataContextChanged = function() {
	
}
SysToolsSingleClassInfoView.prototype.set_data = function (v) {
    if (v != null && v.classname != null) {
        if (v.classname == "Array") {
            v.info = new SysToolsSingleClassInfo(Array, true);
        } else {
            v.info = new SysToolsSingleClassInfo(v.classname, true);
        }
		v.info.settingschangedevent.add(this.settingschangedevent);
    }
    ViewBase.prototype.set_data.call(this, v);
};
SysToolsSingleClassInfoView.prototype.fmtIndentination = {
	ToTarget: function (v) {
		return v * 20;
	},
	FromTarget: function (v) {
		return v;
	}
};
SysToolsSingleClassInfoView.prototype.onShowClass = function (e, dc) {
	var svc = this.findService("SysToolsApp");
	svc.LoadView("class", {classname: dc.name});
	
};
SysToolsSingleClassInfoView.prototype.onShowProt = function (e, dc) {
	var svc = this.findService("SysToolsApp");
	svc.LoadView("interface", {interfacename: dc.name});
};