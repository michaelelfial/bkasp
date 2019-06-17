function MiniShellApp() {
	AppBaseEx.apply(this,arguments);
}
MiniShellApp.Inherit(AppBaseEx, "MiniShellApp");

MiniShellApp.prototype.initialize = function(args) {
	var op = new Operation(10000);
	this.main = Shell.createStdAppWindow();
	this.placeWindow(this.main);
	return op;
}
MiniShellApp.prototype.run = function(args) {
	
}

MiniShellApp.prototype.shutdown = function() {
}
MiniShellApp.prototype.windowDisplaced = function(w) {
	// throw "windowDisplaced is not implemented by " + this.fullClassType();
}