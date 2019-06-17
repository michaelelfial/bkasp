/*CLASS*/
function InterfaceInfoView() {
    ViewBase.apply(this, arguments);
};
InterfaceInfoView.Inherit(ViewBase, "InterfaceInfoView");
InterfaceInfoView.Implement(ITemplateRoot);
InterfaceInfoView.prototype.showclassevent = new InitializeEvent("Class has been clicked");
InterfaceInfoView.prototype.showinterfaceevent = new InitializeEvent("Interface has been clicked");
InterfaceInfoView.prototype.get_caption = function() {
	return "Interface info " + BaseObject.getProperty(this.get_data(),"interfacename","");
}
InterfaceInfoView.prototype.OnDataContextChanged = function() {
	this.throwStructuralQuery(new UpdateCommandBars());
}
InterfaceInfoView.prototype.set_data = function (v) {
    if (v != null && v.interfacename != null) {
        v.info = new SysToolsInterfaceInfo(v.interfacename, true);
    }
    ViewBase.prototype.set_data.call(this, v);
};
InterfaceInfoView.prototype.indentformat = null;
InterfaceInfoView.prototype.onShowClass = function (e, dc) {
	this.showclassevent.invoke(this, {classname: dc});
	this.findService("SysToolsApp").LoadView("class",{classname: dc});
};
InterfaceInfoView.prototype.onShowProt = function (e, dc) {
	this.showinterfaceevent.invoke(this, {interfacename: dc.name});
	this.findService("SysToolsApp").LoadView("interface",{interfacename: dc.name});
};
