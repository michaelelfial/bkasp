// A second class implementing a service interface
function ExampleServiceClass(app) {
	AppElementBase.apply(this, arguments);
	this.app = app;
}
ExampleServiceClass.Inherit(AppElementBase, "ExampleServiceClass");
ExampleServiceClass.Implement(IExampleServiceInterface);
ExampleServiceClass.prototype.Method1 = function() {
	this.app.log("IExampleServiceInterface.Method1 called");
	return "Hello from instance " + this.$__instanceId;
}
ExampleServiceClass.prototype.Method2 = function(a,b) {
	this.app.log("IExampleServiceInterface.Method2 called");
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