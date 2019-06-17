
function SysToolsBindingsViewer() {
	ViewBase.apply(this, arguments);
}
SysToolsBindingsViewer.Inherit(ViewBase, "SysToolsBindingsViewer");
SysToolsBindingsViewer.prototype.get_caption = function() {
	return CObject.getProperty(this.get_data(),"caption", "Bindings viewer");
}