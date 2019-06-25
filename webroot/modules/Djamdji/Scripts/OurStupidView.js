function OurStupidView() {
	GenericViewBaseEx.apply(this, arguments);
}
OurStupidView.Inherit(GenericViewBaseEx,"OurStupidView");
OurStupidView.ImplementProperty("xtemplate", new Initialize("sdjfbsjkd", null));

OurStupidView.prototype.Refr = function() {
	this.updateSources();
	this.get_hostcontainer().set_data({ inject: this.get_xtemplate()});
}