/*
	By default starting a trap will ignore new start attempts until the trap is finished with gestures.
	If this is inconvenient use set_alwaysstart(true);
*/
/*CLASS*/
function MouseTrap(owner, gesture1, gesture2,gestureEtc) {
	BaseObject.apply(this, arguments);
	this.$owner = owner; // Should be object inherited from Base class at least.
	this.$gestures = Array.createCopyOf(arguments,1);
}
MouseTrap.Inherit(BaseObject,"MouseTrap");
MouseTrap.Implement(IMouseTracker);
MouseTrap.ImplementProperty("alwaysstart", new InitializeBooleanParameter("If true tells the trap to start trapping from scratch even f there is active trapping at the moment."));
MouseTrap.prototype.handleMouseTrack = function(sender, trackevent) {
	if (BaseObject.is(trackevent, "MouseTrackerEvent")) {
		// Main work
		var g = null;
		switch(trackevent.get_what()) { 
			case "start":
				this.$startGestures();
			break;
			case "move":
			case "key":
				g = this.$tryGestures(trackevent);
				if (g === false) {
					this.$stopGestures(); // Immediate stop to not waste time.
				} else if (BaseObject.is(g, "MouseGesture")) {
					// return g; advise the owner for the detected gesture. 
				}
			break;
			case "cancel":
			case "complete":
				this.$stopGestures();
			break;
		}
	}
}
MouseTrap.prototype.$owner = null;
MouseTrap.prototype.$gestures = new InitializeArray("Array of configured gestures");
MouseTrap.prototype.$activeGestures = null;
MouseTrap.prototype.$tryGestures = function(msg) {
	if (this.$activeGestures == null || this.$activeGestures.length == 0) { // No active gestures
		return false; // Explicit false
	}
	// Ask all active gestures
	var gest = null;
	for (var i = this.$activeGestures.length - 1; i >= 0; i--) {
		gest = this.$activeGestures[i];
		var r = gest.inspectMessage(msg);
		if (r === false) {
			this.$activeGestures.splice(i,1);
		} else if (r === true) {
			return gest; // Return the successful gesture
		}
	}
	if (this.$activeGestures.length == 0) { // No active gestures
		this.$activeGestures = null;
		return false; // Explicit false
	}
	return null;
}
MouseTrap.prototype.$startGestures = function() {
	this.$activeGestures = Array.createCopyOf(this.$gestures);
	for (var i = 0; i < this.$activeGestures.length; i++) {
		this.$activeGestures[i].$start();
	}
}
MouseTrap.prototype.$stopGestures = function() {
	if (this.$activeGestures != null) {
		for (var i = 0; i < this.$activeGestures.length; i++) {
			this.$activeGestures[i].$stop();
		}
		this.$activeGestures = null;
	}
}
MouseTrap.prototype.isTrapping = function() {
	if (BaseObject.is(this.$activeGestures,"Array") && this.$activeGestures.length > 0) return true;
	return false;
}
MouseTrap.prototype.stop = function() {
	if (this.isTrapping()) {
		// Stop the system tracker
		MouseTracker.Default().stopTracking();
		// We do not wait for the tracker to stop
	}
	this.$stopGestures();
}.Description("Stops trapping and reinit to initial state");
MouseTrap.prototype.start = function(e) {
	if (!this.get_alwaysstart() && this.isTrapping()) return false;
	if (e != null && e.target && e.clientX) {
		MouseTracker.Default().startTracking(this, e);
		return true;
	} else {
		jbTrace.log("Attempt to start a MouseTrap without proper mouse sighting (mouse event)");
	}
	return false;
}.Description("Starts trapping the mouse for a capture. Depends on the gesture which is for now very rudimentary. Will usually wait for movement and if the state requirements match start a capture.")
 .Param("event_or_point","mouse DOM event for the starting position.");