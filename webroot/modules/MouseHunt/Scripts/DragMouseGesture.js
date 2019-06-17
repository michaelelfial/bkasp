function DragMouseGesture(distance, timeallotted) {
	MouseGesture.apply(this,arguments);
	this.timeallotted = timeallotted || 300; //Default is 300 ms;
	this.distance = distance || 2;
	this.watch = new Watch();
}
DragMouseGesture.Inherit(MouseGesture,"DragMouseGesture");
// Data
DragMouseGesture.prototype.distance = null;
DragMouseGesture.prototype.timeallotted = null;
DragMouseGesture.prototype.initialPos = null;
//DragMouseGesture.prototype.watch = new InitializeObject("A watch","Watch");
var x = new Watch();
DragMouseGesture.prototype.clear = function() {
	this.initialPos = null;
	this.watch.clearInterval();
}
DragMouseGesture.prototype.start = function() {
	this.watch.startInterval(this.timeallotted)
};
MouseGesture.prototype.inspectMessage = function(msg) {
	if (!this.watch.intervalExpired()) {
		var pos = msg.get_clientpos();
		if (pos == null) return false;
		if (this.initialPos == null) this.initialPos = pos;
		if (this.initialPos.distance(pos) >= 2) return true;
		return null;
	} else {
		return false; // Signal that we do not want to be asked anymore.
	}
};