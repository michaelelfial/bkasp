function XTApp_Contents_View() {
	GenericViewBaseEx.apply(this, arguments);
}
XTApp_Contents_View.Inherit(GenericViewBaseEx, "XTApp_Contents_View");
XTApp_Contents_View.prototype.get_caption = function() {
	return "Contents";
}