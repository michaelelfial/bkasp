function BkUrl_Test1_View() {
	GenericViewBaseEx.apply(this,arguments);
	this._scheme = new BKUrlScheme();
}
BkUrl_Test1_View.Inherit(GenericViewBaseEx,"BkUrl_Test1_View");
BkUrl_Test1_View.ImplementActiveProperty("scheme", new InitializeStringParameter("","http"), null, true, "OnSchemeChanged");

BkUrl_Test1_View.prototype.updateevent = new InitializeEvent("Update visuals");

BkUrl_Test1_View.prototype.OnSchemeChanged = function() {
	this._scheme.set_source(this.get_scheme());
	this.updateevent.invoke(this,null);
}
BkUrl_Test1_View.prototype.get_schemetostr = function() {
}