function MouseHunt_MouseTrackerDevGround() {
	Base.apply(this,arguments);
}
MouseHunt_MouseTrackerDevGround.Inherit(Base, "MouseHunt_MouseTrackerDevGround");
MouseHunt_MouseTrackerDevGround.Implement(IMouseTracker);
MouseHunt_MouseTrackerDevGround.DeclarationBlock({
	onTrackStart: function(e,dc,b) {
		MouseTracker.Default().startTracking(this,b.getRef("cont").get(0));
	},
	handleMouseTrack: function(sender, trackevent) {
		if (BaseObject.is(trackevent, "MouseTrackerEvent")) {
			this.childObject("display").set_data(trackevent);
		} else {
			InfoMessageQuery.emit(this,"Not a MouseTrackerEvent");
		}
		this.childObject("display2").set_data(Rect.fromBoundingClientRectangle(this.child("capturearea")).toString());
	}
});