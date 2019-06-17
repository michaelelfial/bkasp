/* Mouse tracker helper
	This singleton attaches to the body and accepts tracking requests from anywhere.
	However only one tracking client can exist at any given time.
	The client is informed about the mouse movements and is provided by some precalculated
		values (depends on the version of this class) to make its live simpler.
	Basically this is a rudimentary mouse capture appliance.

*/
function MouseTracker() {
	BaseObject.apply(this,arguments);
	this.$initTracker();
	this.$clearTrackData();
}
MouseTracker.Inherit(BaseObject, "MouseTracker");
// Handler delegates
MouseTracker.prototype.$handleMouseMove = new InitializeMethodCallback("Handle mouse movements on the body","handleMouseMove");
MouseTracker.prototype.$handleMouseDown = new InitializeMethodCallback("Handle mouse down on the body","handleMouseDown");
MouseTracker.prototype.$handleMouseUp = new InitializeMethodCallback("Handle mouse up on the body","handleMouseUp");
MouseTracker.prototype.$handleKeyUp = new InitializeMethodCallback("Handle key up on the body","handleKeyUp");

MouseTracker.prototype.$tracking = false; // true when tracking is active
MouseTracker.prototype.$client = null; // Tracker - the client that requested tracking (BaseObject, IMouseTracker)
MouseTracker.prototype.$lastClientPoint = null; // The last known mouse pos (viewport coordinates)
MouseTracker.prototype.$lastPagePoint = null; // The last known mouse pos (page coordinates)
MouseTracker.prototype.$lastKeyState = {}; // The last known mouse pos (page coordinates)

///// Const /////////////
MouseTracker.keyStates = { ctrlKey: false, altKey: false, metaKey: false, shiftKey: false };

/////////// (Re)Initialization helpers //////////////
MouseTracker.prototype.$clearTrackData = function() {
	this.$lastClientPoint = null;
	this.$lastPagePoint = null; // Only for optional purposes - the client point is what we really track
	this.$lastKeyState = {};
	this.$client = null;
	this.$tracking = false;
}.Description("Clears all the dynamic tracking data");
MouseTracker.prototype.$uninitTracker = function() { // It is not clear if we will ever need this.
	var body = window.document.body;
	body.removeEventListener("mousemove",this.$handleMouseMove,true);
	body.removeEventListener("mousedown",this.$handleMouseDown,true);
	body.removeEventListener("mouseup",this.$handleMouseUp,true);
	body.removeEventListener("keyup",this.$handleKeyUp,true);
}
MouseTracker.prototype.$initTracker = function() {
	var body = window.document.body;
	body.addEventListener("mousemove",this.$handleMouseMove,true);
	body.addEventListener("mousedown",this.$handleMouseDown,true);
	body.addEventListener("mouseup",this.$handleMouseUp,true);
	body.addEventListener("keyup",this.$handleKeyUp,true);
}
MouseTracker.prototype.isTracking = function() {
	return (this.$client && this.$tracking);
}
////////////// Start tracking ///////////////
MouseTracker.prototype.startTracking = function(client,initialPoint_or_MouseEvent) {
	this.stopTracking(this.thisCall(function() {
		var changedstates = null;
		if (BaseObject.is(client, "IMouseTracker")) {
			this.$clearTrackData();
			this.$client = client;
			this.$tracking = true;
			if (BaseObject.is(initialPoint_or_MouseEvent, "Point")) {
				this.$lastClientPoint = new Point(initialPoint_or_MouseEvent);
			} else if (initialPoint_or_MouseEvent != null && initialPoint_or_MouseEvent.target) {
				changedstates = this.$reportMouseMessage(initialPoint_or_MouseEvent);
			}
			var msg = this.createTrackMessage("start",changedstates); // move
			this.adviseClient(msg);
		} else {
			this.$clearTrackData();
			throw "The client must implement IMouseTracker";
		}
	}));
}.Description("Starts tracking/capturing the mouse. Can be supplied with initial mouse event from which it will strip initial coordinates, but will ignore the type of the event")
	.Param("client","Object supporting IMouseTracker which will be advised for the mouse movements while the tracking operation continues." +
			"Only one tracking operation is allowed at any given moment. Starting a new one will stop (cancel) the current one.")
	.Param("container", "Reference to a DOM element in which the operation is performed. Relative coordinates in the container will be calculated and included in the messages.")
	.Param("anchorPoint", "Initial anchor point can be optionally supplied. When anchorPoint exists distance to it is reported also all the time.")
	.Param("initialPoint_or_MouseEvent","If mouse event is supplied clientX/Y are stripped from it as lastPoint, if point is supplied it will be used only if there is a container and it will be interpretted in container coordinates.");
///////// Stop (cancel), Complete tracking
MouseTracker.prototype.stopTracking = function(callback) {
	if (this.isTracking()) { // Have to stop it indead - this is cancelled 
		var msg = this.createTrackMessage("cancel"); // No need of keystate changes data - nothing can be changed at this moment.
		this.adviseClient(msg);
		this.$clearTrackData();
	} 
	// Currently we call this each time, but some optimizations will come into play in future.
	if (BaseObject.isCallback(callback)) BaseObject.callCallback(callback);
}
MouseTracker.prototype.completeTracking = function(callback, msg) {
	if (this.isTracking()) { // Have to stop it indead - this is cancelled 
		var msg = this.createTrackMessage("complete"); // No need of keystate changes data - nothing can be changed at this moment.
		this.adviseClient(msg);
		this.$clearTrackData();
	}
	if (BaseObject.isCallback(callback)) BaseObject.callCallback(callback);
}

////////// Message helpers /////////////
MouseTracker.prototype.createTrackMessage = function(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9) {
	var m = new MouseTrackerEvent(this,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9);
	// Fill in stuff from the tracker.
	m.set_clientpos(this.$lastClientPoint);
	m.set_pagepos(this.$lastPagePoint);
	return m;
}
MouseTracker.prototype.adviseClient = function(msg) {
	if (this.isTracking() && msg != null) {
		this.$client.handleMouseTrack(this,msg);
	}
}

///////////// Handlers /////////////////
MouseTracker.prototype.handleMouseMove = function(e) {
	if (!this.isTracking()) return;
	var changedstates = this.$reportMouseMessage(e);
	// TODO: Use changedstates when we decide to extend this in future.
	var msg = this.createTrackMessage("move",changedstates); // move
	this.adviseClient(msg);
	e.preventDefault();
}
MouseTracker.prototype.handleMouseDown = function(e) {
	if (!this.isTracking()) return; // We have to do more here when we start handling start-track situations
	var changedstates = this.$reportMouseMessage(e);
	// TODO: Use changedstates when we decide to extend this in future.
	// Stop the tracking here (it might be stopped already through call from the client while handling the message).
	this.stopTracking(); // The client should not start new tracking during handling.	
	e.preventDefault();
}
MouseTracker.prototype.handleMouseUp = function(e) {
	if (!this.isTracking()) return;
	var changedstates = this.$reportMouseMessage(e);
	// TODO: Use changedstates when we decide to extend this in future.
	this.completeTracking(); // The client should not start new tracking during handling.	
	e.preventDefault();
}
MouseTracker.prototype.handleKeyUp = function(e) {
	if (!this.isTracking()) return;
	var changedstates = this.$applyKeyStateFromEvent(e);
	// TODO: Use changedstates when we decide to extend this in future.
	var ch = (typeof e.which == "number")? e.which:e.keyCode;
	if (ch == 27) {
		this.stopTracking(); // The client should not start new tracking during handling.	
		e.preventDefault();
	} else {
		var msg = this.createTrackMessage("key",changedstates); // move
		msg.set_key(ch);
		this.adviseClient(msg);
		// e.preventDefault(); // TODO: Should we prevent default?
	}
}
/////////////// Handler helpers ///////////////
MouseTracker.prototype.$applyKeyStateFromEvent = function(e) {
	return this.$applyKeyState(this.$getKeyState(e));
}.Description("Sets a new last key state and returns an object with the states that have changed.");
MouseTracker.prototype.$applyKeyState = function(state) {
	var i;
	// If any state is null we consider this full change even if both are nulls
	if (state == null || this.$lastKeyState == null) {
		var o = BaseObject.DeepClone(MouseTracker.keyStates);
		for (i in o) {o[i] = true;}
		this.$lastKeyState = state?state:{};
		return o;
	}
	var events = {};
	for (i in MouseTracker.keyStates) {
		if (this.$lastKeyState[i] != state[i]) {
			events[i] = true;
		}
		this.$lastKeyState[i] = state[i];
	}
	return events;
}.Description("Sets a new last key state and returns an object with the states that have changed.");
MouseTracker.prototype.$getKeyState = function(e) {
	return {
		ctrlKey: e.ctrlKey,
		altKey: e.altKey,
		metaKey: e.metaKey,
		shiftKey: e.shiftKey
	};
}
/* $reportMouseMessage
	Reports a mouse message so that important data would be stripped from it and preserved in the tracker for theduration
	of the tracking session.
*/
MouseTracker.prototype.$reportMouseMessage = function(e) {
	if (e.clientX != null && e.clientY != null) {
		this.$lastClientPoint = new Point(e.clientX,e.clientY);
		this.$lastPagePoint = new Point(e.pageX,e.pageY);
	}
	return this.$applyKeyStateFromEvent(e);
}

MouseTracker.Default = function() {
	if (MouseTracker.$default == null) {
		MouseTracker.$default = new MouseTracker();
	}
	return MouseTracker.$default;
}




