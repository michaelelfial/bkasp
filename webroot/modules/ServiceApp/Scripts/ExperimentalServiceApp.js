function ExperimentalServiceApp() {
	AppBaseEx.apply(this, arguments);
	this.svc1 = new ExampleServiceClass();
}
ExperimentalServiceApp.Inherit(AppBaseEx,"ExperimentalServiceApp");
ExperimentalServiceApp.Implement(IPlatformUtilityImpl, "ServiceApp");
ExperimentalServiceApp.Implement(IManagedInterface);
ExperimentalServiceApp.Implement(IExampleServiceInterface2);

ExperimentalServiceApp.prototype.get_caption = function() {
	return "Playground";
};
ExperimentalServiceApp.prototype.provideAsServices = new InitializeArray("Playground", ["IAppletStorage","ExperimentalServiceApp"]);
ExperimentalServiceApp.prototype.GetInterface = function(iface) {
	var ifname = Class.getInterfaceName(iface);
	switch (ifname) {
		case "IExampleServiceInterface":
			return this.svc1;
		case "IExampleServiceInterface2":
			return this;
		case "IManagedInterface":
			return this;
	}
	return null;
}

ExperimentalServiceApp.prototype.SvcMethod = function(v) {
	alert("They called me with value: " + v);
}

ExperimentalServiceApp.prototype.initialize = function (callback, args) {
	var op = new Operation(null, 10000);
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	// return op;
	this.root = Shell.createStdAppWindow();
	this.placeWindow(this.root);
	this.root.set_windowrect(new Rect(50,50,600,500));
	this.root.updateTargets();
	
	return op;
}
ExperimentalServiceApp.prototype.run = function(args) {}
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



// A second class implementing a service interface
function ExampleServiceClass() {
	BaseObject.apply(this, arguments);
}
ExampleServiceClass.Inherit(BaseObject, "ExampleServiceClass");
ExampleServiceClass.Implement(IExampleServiceInterface);
ExampleServiceClass.prototype.Method1 = function() {
	return "Hello from instance " + this.$__instanceId;
}
ExampleServiceClass.prototype.Method2 = function(a,b) {
	return a + " " + b;
}
ExampleServiceClass.prototype.fireEvent = function(data) {
	this.sampleevent.invoke(this, data);
}
ExampleServiceClass.prototype.GetInterface = function(iface) {
	var ifname = Class.getInterfaceName(iface);
	switch (ifname) {
		case "IExampleServiceInterface":
			return this;
	}
	return null;
}