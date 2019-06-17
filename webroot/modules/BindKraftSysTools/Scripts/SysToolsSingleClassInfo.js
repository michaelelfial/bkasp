/*CLASS*/
function SysToolsSingleClassInfo(cls) {
	BaseObject.apply(this,arguments);
	if (typeof cls == "string") {
		if (cls == "Array") {
			this.classDef = Array;
		} else if (cls == "Date") {
			this.classDef = Date;
		} else {
			this.classDef = Function.classes[cls];
		}
	} else if (BaseObject.is(cls, "BaseObject")) {
		this.classDef = cls.classDefinition();
	} else {
		this.classDef = cls;
	}
	if (this.classDef != null) {
		// Collect info
		var state = {};
		var info;
		for (var k in this.classDef) {
			info = Function.GetDocumentationOf(this.classDef, k, state,true);
			if (info != null) this.$staticmembers.push(info);
		}
		state = {};
		for (var k in this.classDef.prototype) {
			info = Function.GetDocumentationOf(this.classDef, k, state,false);
			if (info != null) this.$members.push(info);
		}
		state = {};
		if (this.classDef.parent != null) {
			for (var k in this.classDef.parent.constructor.prototype) {
				info = Function.GetDocumentationOf(this.classDef.parent.constructor, k, state,false);
				if (info != null) this.$parentmembers.push(info);
			}
		}
	}
}
SysToolsSingleClassInfo.Inherit(BaseObject, "SysToolsSingleClassInfo");
SysToolsSingleClassInfo.prototype.$staticmembers = new InitializeArray("Array filled with the collected information about all the static members - not sorted or classified");
SysToolsSingleClassInfo.prototype.$members = new InitializeArray("Array filled with the collected information about all the members - not sorted or classified");
SysToolsSingleClassInfo.prototype.$parentmembers = new InitializeArray("Array filled with the collected information about all the members of the parent class - not sorted or classified");
SysToolsSingleClassInfo.ImplementProperty("inherited", new InitializeBooleanParameter("Show inherited members as well", true),null,"OnSettingsChanged");
SysToolsSingleClassInfo.ImplementProperty("showprivate", new InitializeBooleanParameter("Show private/protected members as well", false),null,"OnSettingsChanged");
SysToolsSingleClassInfo.ImplementProperty("showhidden", new InitializeBooleanParameter("Show members marked as hidden", false),null,"OnSettingsChanged");
SysToolsSingleClassInfo.ImplementProperty("filter", new InitializeStringParameter("Show only members containing text", ""),null,"OnSettingsChanged");

SysToolsSingleClassInfo.prototype.settingschangedevent = new InitializeEvent("Fired when some settings change and data needs to be redraw (if this is used in UI)");

SysToolsSingleClassInfo.prototype.OnSettingsChanged = function() {
		this.$clearCaches();
		this.settingschangedevent.invoke(this, null);
}
SysToolsSingleClassInfo.prototype.$clearCaches = function() {
	this.$properties_cache = null;
	this.$methods_cache = null;
	this.$fields_cache = null
}
SysToolsSingleClassInfo.prototype.$sortMembers = function(arrMembers) {
	return arrMembers.sort(function(a,b) {return (a.name > b.name)?1:-1;});
}
SysToolsSingleClassInfo.prototype.$filterOwnOnly = function(arrMembers) {
	return arrMembers.Select(function(idx, item) {
		if (item.isinherited) return null;
		return item;
	});
}
SysToolsSingleClassInfo.prototype.$filterPublicOnly = function(arrMembers) {
	return arrMembers.Select(function(idx, item) {
		if (item.priv) return null;
		return item;
	});
}
SysToolsSingleClassInfo.prototype.$filterVisibleOnly = function(arrMembers) {
	return arrMembers.Select(function(idx, item) {
		if (item.hidden) return null;
		return item;
	});
}
SysToolsSingleClassInfo.prototype.$filterMembers = function(arrMembers) {
	var r = arrMembers;
	if (!this.get_inherited()) {
		r = this.$filterOwnOnly(r);
	}
	if (!this.get_showprivate()) {
		r = this.$filterPublicOnly(r);
	}
	if (!this.get_showhidden()) {
		r = this.$filterVisibleOnly(r);
	}
	var f = this.get_filter();
	if (f != null && f.length > 0) {
		r = r.Select(function(idx, item) {
			if (item.name.indexOf(f) >= 0) return item;
			return null;
		});
	}
	return r;
}
SysToolsSingleClassInfo.prototype.get_name = function() {
	if (this.classDef) return this.classDef.classType;
}
SysToolsSingleClassInfo.prototype.get_baseclass = function() {
	if (this.classDef && this.classDef.parent) return this.classDef.parent.constructor.classType;
}
SysToolsSingleClassInfo.prototype.get_fullchain = function() {
	if (this.classDef) return Class.fullClassType(this.classDef);
}
SysToolsSingleClassInfo.prototype.get_parents = function() {
	if (this.classDef) return this.get_fullchain().split("::").Select(function(idx,item) {
		return { name: item };
	});
}
SysToolsSingleClassInfo.prototype.get_protocols = function() {
	if (this.classDef) return Class.supportedInterfaces(this.classDef).Select(function(idx,item) {
		return {name: item};
	});
}
SysToolsSingleClassInfo.prototype.get_constructor = function() {
	if (this.classDef) {
		var info = Function.GetDocumentationOf(this.classDef,null);
		info.name = this.get_name();
		return info;
	}
}
SysToolsSingleClassInfo.prototype.$properties_cache = null;
SysToolsSingleClassInfo.prototype.get_properties = function() {
	if (this.$properties_cache != null) return this.$properties_cache;
	var self = this;
	var props = this.$members.Select(function(idx, item) {
		if (item.isproperty) {
			return item;
		}
		return null;
	});
	this.$properties_cache = this.$sortMembers(this.$filterMembers(props));
	return this.$properties_cache;
}
SysToolsSingleClassInfo.prototype.$methods_cache = null;
SysToolsSingleClassInfo.prototype.get_methods = function() {
	if (this.$methods_cache != null) return this.$methods_cache;
	var self = this;
	var props = this.$members.Select(function(idx, item) {
		if (!item.isfield && !item.isproperty) {
			return item;
		}
		return null;
	});
	this.$methods_cache = this.$sortMembers(this.$filterMembers(props));
	return this.$methods_cache;
}
SysToolsSingleClassInfo.prototype.$fields_cache = null;
SysToolsSingleClassInfo.prototype.get_fields = function() {
	if (this.$fields_cache != null) return this.$fields_cache;
	var self = this;
	var props = this.$members.Select(function(idx, item) {
		if (item.isfield && item.type != "Event" && item.type != "MethodDelegate" && item.type != "MethodTrigger") {
			return item;
		}
		return null;
	});
	this.$fields_cache = this.$sortMembers(this.$filterMembers(props));
	return this.$fields_cache;
}
SysToolsSingleClassInfo.prototype.get_events = function() {
	var self = this;
	var props = this.$members.Select(function(idx, item) {
		if (item.isfield && item.type == "Event") {
			return item;
		}
		return null;
	});
	return this.$sortMembers(this.$filterMembers(props));
}
SysToolsSingleClassInfo.prototype.get_triggers = function() {
	var self = this;
	var props = this.$members.Select(function(idx, item) {
		if (item.isfield && item.type == "MethodTrigger") {
			return item;
		}
		return null;
	});
	return this.$sortMembers(this.$filterMembers(props));
}
SysToolsSingleClassInfo.prototype.get_delegates = function() {
	var self = this;
	var props = this.$members.Select(function(idx, item) {
		if (item.isfield && item.type == "MethodDelegate") {
			return item;
		}
		return null;
	});
	return this.$sortMembers(this.$filterMembers(props));
}
SysToolsSingleClassInfo.prototype.get_staticproperties = function() {
	var self = this;
	var props = this.$staticmembers.Select(function(idx, item) {
		if (item.isproperty) {
			return item;
		}
		return null;
	});
	return this.$sortMembers(this.$filterMembers(props));
}
SysToolsSingleClassInfo.prototype.get_staticmethods = function() {
	var self = this;
	var props = this.$staticmembers.Select(function(idx, item) {
		if (!item.isfield && !item.isproperty) {
			return item;
		}
		return null;
	});
	return this.$sortMembers(this.$filterMembers(props));
}
SysToolsSingleClassInfo.prototype.get_staticfields = function() {
	var self = this;
	var props = this.$staticmembers.Select(function(idx, item) {
		if (item.isfield) {
			return item;
		}
		return null;
	});
	return this.$sortMembers(this.$filterMembers(props));
}

