function Formatters_Test1_View() {
	GenericViewBaseEx.apply(this,arguments);
	
}
Formatters_Test1_View.Inherit(GenericViewBaseEx,"Formatters_Test1_View");
Formatters_Test1_View.ImplementProperty("demodate", new Initialize("demo date", new Date()));
Formatters_Test1_View.ImplementProperty("lookup", new InitializeCloneObject("",{
	items:[
	{ id:1,name: "asddf sd dfgdfG"},
	{ id:2, name: "sdfsdfsd sdf sdF"},
	{ id:3, name: "kgjlkfjhfgkjl"}
	]
}));
Formatters_Test1_View.prototype.onRecycle = function(e,dc,bind) {
	this.updateSources();
	this.updateTargets();
}