function XTApp_Ajax1_View() {
	GenericViewBaseEx.apply(this, arguments);
}
XTApp_Ajax1_View.Inherit(GenericViewBaseEx, "XTApp_Ajax1_View");
XTApp_Ajax1_View.prototype.sendJQRequest = function(e, dc) {
	$.ajax({
		url:"http://localhost/404",
		//dataType:"xml",
		error: function() {
		},
		success: function() {
		}
	});
}