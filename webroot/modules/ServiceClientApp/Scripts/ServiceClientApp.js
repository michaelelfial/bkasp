function ServiceClientApp(gate) {
	AppBaseEx.apply(this, arguments);
	this.gate = gate;
}
ServiceClientApp.Inherit(AppBaseEx,"ServiceClientApp");
ServiceClientApp.Implement(IPlatformUtilityImpl, "ServiceClientApp");
ServiceClientApp.prototype.get_caption = function() {
	return "Service Client";
};
ServiceClientApp.prototype.provideAsServices = new InitializeArray("Playground", ["IAppletStorage","ServiceClientApp"]);

/////
ServiceClientApp.prototype.results = new InitializeObject("Results from the calls go here");
ServiceClientApp.prototype.onConnectSvc = function() {
	if (this.svcApp == null) {
		this.svcApp = this.gate.bindAppByClassName("ExperimentalServiceApp");
		this.svc1 = this.svcApp.GetInterface("IExampleServiceInterface");
		this.svc2 = this.svcApp.GetInterface("IExampleServiceInterface2");
		this.svc1.sampleevent.add(new Delegate(this,this.onSampleEvent))
		this.results.connected = "Connected svcApp:" + (this.svcApp?"OK":"FAIL") + ", svc1:" + (this.svc1?"OK":"FAIL") + ", svc2:" + (this.svc2?"OK":"FAIL");
		this.updateDisplay();
	}
}
ServiceClientApp.prototype.onSampleEvent = function(sender, data) {
	alert("Sample event happened with data: " + data);
	sender.Method1();
	
}
ServiceClientApp.prototype.onDirtyDisconnectSvc = function() {
	this.gate.releaseAll();
	this.svcApp = null;
}
ServiceClientApp.prototype.onIESI1Method1 = function() {
	if (this.svc1 != null) {
		this.results.result1 = this.svc1.Method1();
		this.updateDisplay();
	}
}
/////
ServiceClientApp.prototype.updateDisplay = function() {
	if (this.display) this.display.invoke(this.results);
}
ServiceClientApp.prototype.display = null;
ServiceClientApp.prototype.initialize = function (callback, args) {
	var op = new Operation(null, 10000);
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	// return op;
	this.root = Shell.createStdAppWindow();
	this.placeWindow(this.root);
	this.root.set_windowrect(new Rect(50,50,600,500));
	this.root.updateTargets();
	this.view = new SimpleViewWindow(
		WindowStyleFlags.visible | WindowStyleFlags.fillparent | WindowStyleFlags.parentnotify | WindowStyleFlags.adjustclient,
		this.root,
		{
			view: '<div data-class="TrivialView">\
					<span data-bind-text="{read path=connected}"></span>\
					<input type="button" value="Connect" data-on-click="{bind service=ServiceClientApp path=onConnectSvc}" /><br/>\
					<input type="button" value="Dirty disconnect" data-on-click="{bind service=ServiceClientApp path=onDirtyDisconnectSvc}" /><br/>\
					<input type="button" value="IExampleSeviceInterface1::Method1" data-on-click="{bind service=ServiceClientApp path=onIESI1Method1}" />\
					<span data-bind-text="{read path=result1}"></span>\
					</div>',
			directData: {}
		});
	this.display = this.view.viewDelegate("set_data");
	return op;
}
ServiceClientApp.prototype.run = function(args) {}
ServiceClientApp.prototype.shutdown = function () {
    var op = new Operation();
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	return op;
};
ServiceClientApp.prototype.windowDisplaced = function(w) {
	if (w == this.root) {
		this.ExitApp();
	}
}



