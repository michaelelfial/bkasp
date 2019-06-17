function IExampleServiceInterface() {}
IExampleServiceInterface.Interface("IExampleServiceInterface", "IManagedInterface");
IExampleServiceInterface.prototype.Method1 = function() { throw "not impl";}
IExampleServiceInterface.prototype.Method2 = function(a,b) { throw "not impl";}
IExampleServiceInterface.prototype.sampleevent = new InitializeEvent("Example event");