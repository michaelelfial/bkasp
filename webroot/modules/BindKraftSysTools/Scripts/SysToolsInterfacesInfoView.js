/*CLASS*/
function InterfacesInfoView() {
    ViewBase.apply(this, arguments);
}
InterfacesInfoView.Inherit(ViewBase, "InterfacesInfoView");
InterfacesInfoView.prototype.showclassevent = new InitializeEvent("Class has been clicked");
InterfacesInfoView.prototype.showinterfaceevent = new InitializeEvent("Interface has been clicked");
InterfacesInfoView.prototype.get_caption = function() {
	return "All interfaces";
}
InterfacesInfoView.prototype.OnDataContextChanged = function() {
	this.throwStructuralQuery(new UpdateCommandBars());
}
InterfacesInfoView.prototype.descasc = false;
InterfacesInfoView.prototype.init = function () {
    this.reload();
};
InterfacesInfoView.prototype.reload = function () {
    this.prots = [];
    for (var k in Function.interfaces) {
        this.prots.push(new SysToolsInterfaceInfo(k));
    };
};
InterfacesInfoView.prototype.onSortByName = function () {
    var localThis = this;
    this.prots = this.prots.sort(function (a, b) {
        if (localThis.descasc) {
            if (a.name < b.name) return 1;
            if (b.name < a.name) return -1;
            return 0;
        } else {
            if (a.name < b.name) return -1;
            if (b.name < a.name) return 1;
            return 0;
        }
    });
    this.updateTargets();
    this.descasc = !this.descasc;
};
InterfacesInfoView.prototype.onSortByKind = function () {
    var localThis = this;
    this.prots = this.prots.sort(function (a, b) {
        if (localThis.descasc) {
            if (a.kind < b.kind) return 1;
            if (b.kind < a.kind) return -1;
            return 0;
        } else {
            if (a.kind < b.kind) return -1;
            if (b.kind < a.kind) return 1;
            return 0;
        }
    });
    this.updateTargets();
    this.descasc = !this.descasc;
};
InterfacesInfoView.prototype.onShowClass = function (e, dc) {
	this.showclassevent.invoke(this, {classname: dc.name});
	this.findService("SysToolsApp").LoadView("class",{classname: dc.name});
};
InterfacesInfoView.prototype.onShowProt = function (e, dc) {
	this.showinterfaceevent.invoke(this, {interfacename: dc.name});
	this.findService("SysToolsApp").LoadView("interface",{interfacename: dc.name});
};
