function PlaceHolder() {
	Base.apply(this, arguments);
}
PlaceHolder.Inherit(Base,"PlaceHolder");
PlaceHolder.Implement(ITemplateSource);

PlaceHolder.prototype.get_template = function() {
	return this.$template;
}
PlaceHolder.prototype.set_template = function(v) {
	this.$template = v;
	this.$reRender();
}
PlaceHolder.prototype.init = function() {
	
}
PlaceHolder.prototype.$reRender = function() {
	$(this.root).Empty();
	if (this.get_template() != null) {
		var root = ViewBase.cloneTemplate(this.root, this.get_template());
		this.rebind();
		this.updateTargets();
	}
}