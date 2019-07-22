function SysToolsAppIndicator() {
	Base.apply(this,arguments);
	this.api = new LocalAPIClient({IShellApi: null});
	this.shell = this.api.getAPI(IShellApi);
}
SysToolsAppIndicator.Inherit(Base,"SysToolsAppIndicator");
SysToolsAppIndicator.Implement(ITemplateSourceImpl,"systools/control-appindicator");
SysToolsAppIndicator.Implement(IAppIndicator);
SysToolsAppIndicator.Implement(IUIControl);
SysToolsAppIndicator.prototype.$windows = 0;
SysToolsAppIndicator.prototype.get_windows = function() {
	if (BaseObject.is(this.$windows,"number")) {
		return this.$windows;
	} else {
		return "...";
	}
}
SysToolsAppIndicator.prototype.init = function() {
	var tml = this.get_template();
	if (tml != null) {
		JBUtil.Empty(this.root);
		$(this.root).append(tml);
	}
}

SysToolsAppIndicator.prototype.finalinit = function() {
	
}
SysToolsAppIndicator.prototype.stTrack = null;
SysToolsAppIndicator.prototype.onStartApp = function(appId, appClass) {
	if (Class.is(appClass, "SysToolsApp")) {
		var st = this.shell.bindAppByInstanceId(appId);
		this.stTrack = st.GetInterface(ISysToolsAppTrack);
		st.Release();
		if (this.stTrack) {
			this.stTrack.numwindows.add(new Delegate(this, this.onNumWindows));
		}
		this.$windows = 1;
		this.updateTargets();
	}
}
SysToolsAppIndicator.prototype.onStopApp = function(appId, appClass) {
	if (Class.is(appClass, "SysToolsApp")) {
		if (this.stTrack) {
			this.stTrack.Release();
			this.stTrack = null;
		}
		this.$windows = 0;
		this.updateTargets();
	}
}
SysToolsAppIndicator.prototype.onNumWindows = function(count) {
	this.$windows = count;
	this.updateTargets();
}
SysToolsAppIndicator.prototype.plug = function() {
	if (this.shell) {
		this.shell.appstart.add(new Delegate(this, this.onStartApp));
		this.shell.appstop.add(new Delegate(this, this.onStopApp));
	}
}
SysToolsAppIndicator.prototype.unPlug = function() {
	// Messenger.Instance().unsubscribe("AppStartStopMessage",this.startstop);
	this.$windows = 0;
	this.updateTargets();
	if (this.shell) {
		this.shell.Release();
		this.shell = null;
	}
}
