
function IMouseTracker() {}
IMouseTracker.Interface("IMouseTracker");
IMouseTracker.prototype.handleMouseTrack = function(sender, trackevent) {
	if (BaseObject.is(trackevent, "MouseTrackerEvent")) {
		throw "handleMouseTrack is not implemented.";
	}
}