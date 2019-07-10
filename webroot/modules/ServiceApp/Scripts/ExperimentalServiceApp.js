function ExperimentalServiceApp(gate) {
	AppBaseEx.apply(this, arguments);
	this.svc1 = new ExampleServiceClass();
	this.gate = gate;
}
ExperimentalServiceApp.Inherit(AppBaseEx,"ExperimentalServiceApp");
ExperimentalServiceApp.Implement(IPlatformUtilityImpl, "ServiceApp");
ExperimentalServiceApp.Implement(IManagedInterface);
ExperimentalServiceApp.Implement(IExampleServiceInterface2);
ExperimentalServiceApp.ImplementProperty("log", new InitializeArray("Log"));
ExperimentalServiceApp.prototype.get_caption = function() {
	return "Playground";
};
ExperimentalServiceApp.prototype.logchanged = new InitializeEvent("Fired when log changes");
ExperimentalServiceApp.prototype.provideAsServices = new InitializeArray("Playground", ["IAppletStorage","ExperimentalServiceApp"]);

ExperimentalServiceApp.prototype.GetInterface = function(iface) {
	this.log("GetInterface " + Class.getInterfaceName(iface));
	var ifname = Class.getInterfaceName(iface);
	switch (ifname) {
		case "IExampleServiceInterface":
			return this.svc1;
		case "IExampleServiceInterface2":
			return this;
		case "IManagedInterface":
			return this;
	}
	return AppBaseEx.prototype.GetInterface(iface);
}

ExperimentalServiceApp.prototype.SvcMethod = function(v) {
	this.log("IExampleServiceInterface2.SvcMethod " + v);
	alert("They called me with value: " + v);
}
// App specific methods
ExperimentalServiceApp.prototype.log = function(s) {
	this.get_log().push(s);
	this.logchanged.invoke(this,s);
}
////////////

ExperimentalServiceApp.prototype.initialize = function (callback, args) {
	var op = new Operation(null, 10000);
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	// return op;
	this.svc1 = new ExampleServiceClass(this);
	this.root = Shell.createStdAppWindow();
	this.placeWindow(this.root);
	this.root.set_windowrect(new Rect(50,50,600,500));
	this.root.updateTargets();
	this.view = new SimpleViewWindow(
		WindowStyleFlags.visible | WindowStyleFlags.fillparent | WindowStyleFlags.parentnotify | WindowStyleFlags.adjustclient,
		this.root,
		{
			view: '<div data-class="TrivialView">Service server<br/><input type="button" value="sampleevent" data-on-click="{bind service=ExperimentalServiceApp path=svc1.fireEvent}"/>\
					<div data-class="Repeater" data-bind-$items="{read service=ExperimentalServiceApp path=$log readdata=$logchanged}">\
					<div style="border-bottom: ipx solid black" data-bind-text="{read}"></div>\
					</div></div>',
			directData: {}
		});
	
	return op;
}
ExperimentalServiceApp.prototype.run = function(args) {
	// Use local API to access appdata
	var appData = this.gate.api(IAppDataApi);
	if (appData != null) {
		var appDataReader = appData.getContentReader("ExperimentalServiceApp");
		var s = appDataReader.content("texts/text1");
		if (s != null) {
			this.log(s);
		} else {
			this.log("read nothing from app data");
		}
		
	}
}
ExperimentalServiceApp.prototype.shutdown = function () {
    var op = new Operation();
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	return op;
};
ExperimentalServiceApp.prototype.windowDisplaced = function(w) {
	if (w == this.root) {
		this.ExitApp();
	}
}



