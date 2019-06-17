/*
	Carries information for the reported mouse tracking events.
	We want to support a lot of useful shit and stuff, so we use this class
	as the meens to pass data through events - we can extend it gradually.
	
	Second important trait of this class are the tools supplied as methods.
	They usually base their functionality on methods of the geometric classes,
	but in a form that is most useful for the consumer of the message.
	Having these methods on this object saves the need to pass the coorfinate parameters (at least)
	and makes their usage.
	
	Event types (what)
	start,
	move,
	key,
	cancel,
	complete
	
*/
function MouseTrackerEvent(sender, what, changekeydstates) {
	BaseObject.apply(this,arguments);
	this.set_what(what);
	this.set_clientpos(sender.$lastClientPoint);
	this.set_pagepos(sender.$lastPagePos);
	this.set_keystate(sender.$lastKeyState);
	this.set_keystatechanges(changekeydstates);
}
MouseTrackerEvent.Inherit(BaseObject, "MouseTrackerEvent");
MouseTrackerEvent.ImplementProperty("what", new InitializeStringParameter("What is happening - start, move, key, cancel,complete",null));
MouseTrackerEvent.ImplementProperty("clientpos", new InitializeObject("The position of the mouse as reported by the message",null));
MouseTrackerEvent.ImplementProperty("pagepos", new InitializeObject("The position of the mouse as reported by the message's pageX/pageY",null));
MouseTrackerEvent.ImplementProperty("keystate", new InitializeObject("last key state - alt, ctrl, shift ..."));
MouseTrackerEvent.ImplementProperty("keystatechanges", new InitializeObject("object with props indicating what has just changed in the state of the 4 special keys."));
MouseTrackerEvent.ImplementProperty("key", new InitializeNumericParameter("Valid only for key event - key code."));

// Useful results API
MouseTrackerEvent.prototype.mapToContainerInsides = function(containerElement) {
	var ce = (BaseObject.isDOM(containerElement))?containerElement:null;
	if (ce == null) return null;
	var crect = Rect.fromBoundingClientRectangle(ce);
	if (crect != null) {
		var posin = crect.mapToInsides(this.get_clientpos());
		var localpos = posin.mapRelativeFromTo(null,crect);
		return localpos;
	}
	return null;
}.Description("Maps current mouse position to the coordinates of the insides of the container (returns the cloest point still in the container if translation puts the client point outside.");
MouseTrackerEvent.prototype.mapToContainerCoordinates = function(containerElement) {
	var ce = (BaseObject.isDOM(containerElement))?containerElement:null;
	if (ce == null) return null;
	if (crect != null) {
		return this.get_clientpos().mapFromToElement(null, containerElement)
	}
	return null;
}
MouseTrackerEvent.prototype.mapDragToContainerInsides = function(containerElement, drag_rect, anchor) {
	// Turn/collect everything in viewport coordinates
	var _drag_rect = drag_rect;
	if (BaseObject.isDOM(drag_rect)) {
		_drag_rect = drag_rect.fromBoundingClientRectangle();
	}
	if (!BaseObject.is(_drag_rect,"Rect")) { _drag_rect = null; }
	var _cont_rect = containerElement;
	if (BaseObject.isDOM(containerElement)) { _cont_rect= containerElement.fromBoundingClientRectangle(); }
	if (!BaseObject.is(_cont_rect,"Rect")) {_cont_rect = null;}
	// Now turn the 

}