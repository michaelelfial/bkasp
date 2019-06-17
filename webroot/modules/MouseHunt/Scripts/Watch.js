function Watch() {
	BaseObject.apply(this,arguments);
}
Watch.Inherit(BaseObject,"Watch");
//Watch.Implement(
Watch.prototype.$marker = null;
Watch.prototype.$interval = null;
Watch.prototype.$measure = null;
Watch.prototype.$useevents = null;

// Events
Watch.prototype.intervalexpiredevent = new InitializeEvent("If requested fires when measured interval expires. Would not fire if the interval is stopped. Handle intervalstoppedevent if want tobe sure you will receive event no matter what happens.");
Watch.prototype.intervalstoppedevent = new InitializeEvent("Interval has been stopped or expired. It cannot be used as interval expiration tool anymore");
Watch.prototype.intervalstartedevent = new InitializeEvent("A new interval measurement has been started andevents are requested.");
Watch.prototype.get_date = function() {
	return new Date();
}
Watch.prototype.get_milliseconds = function() {
}
Watch.prototype.clearInterval = function() {
	this.$marker = null;
	this.$interval = null;
	this.$useevents = null;
	this.$measure = null;
}
Watch.prototype.intervalActive = function() {
	if (this.$interval != null && this.$marker != null) return true;
	return false;
}
Watch.prototype.startInterval = function(interval, withevents) {
	var dt = new Date();
	this.$useevents = withevents
	this.$marker = dt.getMilliseconds();
	this.$interval = interval;
	this.discardAsync("WatchEvents");
	var asyncResult = this.callAsyncIf(this.$useevents,function() {
		if (this.intervalActive()) {
			this.$intervalexpiredevent.invoke(this,this.measure());
		}
	}).key("WatchEvents").after(interval).maxAge(interval * 5);
}
Watch.prototype.measure = function() {
	if (this.intervalActive()) {
		this.$measure = (new Date()).getMilliseconds() - this.$marker;
		return this.$measure;
	} else {
		return null;
	}
}
Watch.prototype.intervalExpired = function() {
	if (this.intervalActive()) {
		var m = (new Date()).getMilliseconds();
		if (m > this.$marker + this.$interval) return true;
		return false;
	} else {
		return null;
	}
}.Returns("null, true, false where null means no interval is set, true - expired, false - still not exired.");