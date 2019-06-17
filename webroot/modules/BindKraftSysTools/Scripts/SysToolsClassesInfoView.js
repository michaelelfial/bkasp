/*CLASS*/
function ClassesInfoView() {
    ViewBase.apply(this, arguments);
	//this.commands.push(new Command(this, this.onSortByKind, { caption: "Sort by kind", image: mapPath("img/help_icon.png"), visible: true }));
    this.commands.push(new Command(this, this.onSortByName, { caption: "Sort by name", image: mapPath("img/edit.png"), visible: true }));
	this.commands.push(new Command(this, this.onSortByParent, { caption: "Sort by parent", image: mapPath("img/upfolder.gif"), visible: true }));
	// var sc = new Command(null, null, { caption: "Sub menu", image: mapPath("img/upfolder.gif"), visible: true })
	// this.commands.push(sc);
	// sc.subCommands = [];
	// sc.subCommands.push(new Command(this, this.onSortByKind, { caption: "Sort by kind", image: mapPath("img/help_icon.png"), visible: true }));
    // sc.subCommands.push(new Command(this, this.onSortByName, { caption: "Sort by name", image: mapPath("img/edit.png"), visible: true }));
};
ClassesInfoView.Inherit(ViewBase, "ClassesInfoView");
ClassesInfoView.Implement(ITemplateRoot);
ClassesInfoView.prototype.selectedevent = new InitializeEvent("fired when a class is selected");
ClassesInfoView.prototype.fireSelectedEvent = function(classname) {
	this.selectedevent.invoke(this, {classname: classname});
}
ClassesInfoView.prototype.classinfos = null;
ClassesInfoView.prototype.init = function () {
    this.reload();
};
ClassesInfoView.prototype.OnDataContextChanged = function() {
	this.throwStructuralQuery(new UpdateCommandBars());
}
ClassesInfoView.prototype.get_caption = function () {
    return "Regsitered classes";
};
ClassesInfoView.prototype.reload = function () {
    this.classinfos = [];
    this.classinfos.push(new SysToolsSingleClassInfo(Array));
    for (var k in Function.classes) {
        this.classinfos.push(new SysToolsSingleClassInfo(k));
    };
};
ClassesInfoView.prototype.descasc = false;
ClassesInfoView.prototype.onSortByName = function () {
    var localThis = this;
    this.classinfos = this.classinfos.sort(function (a, b) {
        if (localThis.descasc) {
            if (a.get_name() < b.get_name()) return 1;
            if (b.get_name() < a.get_name()) return -1;
            return 0;
        } else {
            if (a.get_name() < b.get_name()) return -1;
            if (b.get_name() < a.get_name()) return 1;
            return 0;
        }
    });
    this.updateTargets();
    this.descasc = !this.descasc;
};
ClassesInfoView.prototype.onSortByParent = function () {
    var localThis = this;
    this.classinfos = this.classinfos.sort(function (a, b) {
        if (localThis.descasc) {
            if (a.get_baseclass() < b.get_baseclass()) return 1;
            if (b.get_baseclass() < a.get_baseclass()) return -1;
            return 0;
        } else {
            if (a.get_baseclass() < b.get_baseclass()) return -1;
            if (b.get_baseclass() < a.get_baseclass()) return 1;
            return 0;
        }
    });
    this.updateTargets();
    this.descasc = !this.descasc;
};
ClassesInfoView.prototype.onShowClass = function (e, dc) {
	this.fireSelectedEvent(dc.name);
	var app = this.findService("SysToolsApp");
	if (app != null) {
		app.LoadView("class", {classname: dc.get_name()})
	}
};