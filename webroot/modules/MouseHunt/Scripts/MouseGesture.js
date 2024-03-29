/*
	Mouse gestures are used by the MouseTrap
	Setting additional data depends on the implementation, but should be done during construction or initialization.
	This means that (when needed) DOM elements that can change should be identified through names, paths or other means that the gesture
	can use to find them each time it is called to inspectEvent.
	Lifecycle:
		A MouseTrap is configured with a new instance of MouseGesture-s (among which is ours)
			The gesture receives the needed arguments
		Each time the trap is invoked to handle a "mouse sighting" it reinitializes all its gestures by calling $start on them.
		The MouseTrap starts sending the mouse messages to the inspectEvent of each gesture.
		The inspectEvent returns nothing/null to continue listening
		If the gesture determines that there is no point in inspecting events further (no chance for gesture detection) it returns false and is no longer called.
			The MouseTrap calls stop() in the MouseGesture
		If a gesture is detected the gesture returns true from inspectEvent.
		If the trap decides to stop detecting or if gesture is detected it calls stop on all still active gestures (including the one that detected it).
		
		
*/
function MouseGesture() {
	BaseObject.apply(this,arguments);
}
MouseGesture.Inherit(BaseObject,"MouseGesture");
MouseGesture.ImplementProperty("recoginizing", new InitializeBooleanParameter("Indicates if the gesture is still actively recognizing or stopped.", false));
MouseGesture.prototype.$clear = function() {
	this.set_recognizing(false);
	this.clear();
}
MouseGesture.prototype.clear = function() {
	// Override this method as necessary.
}.Description("Override to clear your spcific recognition data. No need to call this after operation, it will be called first by the start method the next time the gesture is used. Still, to release a little memory it can be called after operation.");
MouseGesture.prototype.$start = function() {
	this.clear();
	this.set_recognizing(true);
	this.start();
};
MouseGesture.prototype.start = function() {
	// Override this as necessary
}.Description("Override to initialize the members your gesture needs during gesture recognition.");
MouseGesture.prototype.$stop = function() {
	var r = this.stop();
	this.$clear();
	if (r != null) return r;
	return false;
}.Description("Stops the gesture - gives it a chance to uninitialize any resources it is using")
	.Returns("Currently the return result is not used, but returning false is default (nothing running)");
MouseGesture.prototype.stop = function() {
	return false;
}.Description("Can be called by inspectEvent to cancel further recognition and directly return === false. Use like: return this.stop();");
MouseGesture.prototype.$inspectEvent = function(msg) {
	return this.inspectEvent(msg);
}
MouseGesture.prototype.inspectMessage = function(msg) {
	throw "Not implemented";
}.Description("All mouse events should be passed to this method after clearing the gesture before starting a new trap.")
	.Param("msg","A MouseTrackerEvent coming from the system MouseTracker.")
	.Returns("Empty result means the gesture recognition continues, === false menas cancelled - no longer recognizing, === true gesture detected.");

MouseGesture.prototype.getGestureResult = function() {
		throw "getGestureResult is not implemented in " + this.fullClassType();
}.Description("Should be called obly immediatelly after inspectMessage returns true to create a MouseGestureResult descriptor of what the gesture detected.")
	.Remarks("overriding","Override this method to implement the specific details for your gesture (see MouseGestureResult for more details)." +
						  " One can subclass MouseGestureResult to provide more information, but the subclass should be useful for basic detection" + 
						  " even when used as MouseGestureResult and the additional infomration should be optional.")
	.Remarks("implementation","The implementation must create and return a MosueGestureResult or derived object and fill it with the data required.");
	