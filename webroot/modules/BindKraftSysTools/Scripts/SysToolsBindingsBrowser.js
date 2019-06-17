function SysToolsBindingsBrowser() {
	Base.apply(this, arguments);
}
SysToolsBindingsBrowser.Inherit(Base, "SysToolsBindingsBrowser");
SysToolsBindingsBrowser.Implement(IUIControl);
SysToolsBindingsBrowser.ImplementProperty("node", new Initialize("Base node in a view/window"));
SysToolsBindingsBrowser.prototype.ignoreBorder = 0;
SysToolsBindingsBrowser.prototype.TemplateSelector = function (switcher) {
	var item = switcher.get_item();
	if (BaseObject.is(item, "Base")) {
		if (item.isTemplateRoot() && !this.ignoreBorder) return switcher.getTemplateByKey("border");
		return switcher.getTemplateByKey("bindnode");
	}
	return switcher.getTemplateByKey("null");
}
SysToolsBindingsBrowser.prototype.get_nodebindings = function() {
	var node = this.get_node();
	if (node != null && node.bindings != null) {
		return node.bindings;
	}
	return null;
}
SysToolsBindingsBrowser.prototype.get_nodedescendants = function() {
	var node = this.get_node();
	if (node != null && node.bindingDescendants != null) {
		return node.bindingDescendants;
	}
	return null;
}
SysToolsBindingsBrowser.prototype.HighlightToggle = function(e, dc, binding, param) {
	if (BaseObject.is(dc, "Binding")) {
		if (BaseObject.is(dc.$target, "Base")) {
			$(dc.$target.root).toggleClass("systools_highlight");
		} else {
			$(dc.$target).toggleClass("systools_highlight");
		}
	}
}
SysToolsBindingsBrowser.prototype.OnOpenNodeDC = function(e, dc, bind, param) {
	var svc = this.findService("SysToolsApp");
	if (svc != null && BaseObject.is(this.get_node(), "Base")) {
		svc.OpenDataViewer({ caption: "Data context", data: this.get_node().get_data()});
	}
}
SysToolsBindingsBrowser.prototype.OnOpenNode = function(e, dc, bind, param) {
	var svc = this.findService("SysToolsApp");
	if (svc != null && BaseObject.is(this.get_node(), "Base")) {
		svc.OpenDataViewer({ caption: "Node dump " + this.get_node().classType(), data: this.get_node()});
	}
}
SysToolsBindingsBrowser.prototype.ExpressionFormatter = {
	ToTarget: function(v) {
		if (v.$targetIndex != null) {
			return v.$targetAction + "[" + v.$targetIndex + "]" + v.$expression;
		} else {
			return v.$targetAction + " " + v.$expression;
		}
	},
	FromTarget: function(v) {
		return null;
	}
};
SysToolsBindingsBrowser.prototype.TypeFormatter = {
	ToTarget: function(v) {
		return BaseObject.typeOf(v);
	},
	FromTarget: function(v) {
		return null;
	}
};
SysToolsBindingsBrowser.prototype.TagFormatter = {
	ToTarget: function(v) {
		return v.root.tagName;
	},
	FromTarget: function(v) {
		return null;
	}
};