// Attach as onevent="f(new ccStaticEvent(this,arguments[0],'event')); ..."
// where event is the name of the event to handle
function ccStaticEvent(handleElement, eventObject, eventName) {
    this.element = handleElement;
    this.altKey = false;
    this.ctrlKey = false;
    this.shiftKey = false;
    if (!eventObject && window.event) eventObject = window.event;
    if (eventObject) {
        this.eventObject = eventObject;
        this.type = eventObject.type;
        if (eventObject.srcElement) {
            this.source = eventObject.srcElement;
        } else if (eventObject.target) {
            this.source = eventObject.target;
        } else {
            this.source = handleElement;
        }
        if (typeof(eventObject.clientX) != "undefined") {
            this.clientX = eventObject.clientX;
            this.clientY = eventObject.clientY;
            this.client = true;
        } else {
            this.clientX = -1;
            this.clientY = -1;
            this.client = false;
        }
        this.scrollLeft = (document.body.scrollLeft > 0)?document.body.scrollLeft:((document.documentElement.scrollLeft > 0)?document.documentElement.scrollLeft:window.pageXOffset);
        this.scrollTop = (document.body.scrollTop > 0)?document.body.scrollTop:((document.documentElement.scrollTop > 0)?document.documentElement.scrollTop:window.pageYOffset);
        this.scrollLeft = (this.scrollLeft)?this.scrollLeft:0;
        this.scrollTop = (this.scrollTop)?this.scrollTop:0;
        if (typeof(eventObject.pageX) != "undefined") {
            this.pageX = eventObject.pageX;
            this.pageY = eventObject.pageY;
            this.page = true;
        } else if (typeof(eventObject.clientX) != "undefined") {
            this.pageX = this.clientX + this.scrollLeft;
            this.pageY = this.clientY + this.scrollTop;
            this.page = true;
        } else {
            this.pageX = -1;
            this.pageY = -1;
            this.page = false;
        }
        if (typeof(eventObject.screenX) != "undefined") {
            this.screenX = eventObject.screenX;
            this.screenY = eventObject.screenY;
            this.screen = true;
        } else {
            this.screenX = -1;
            this.screenY = -1;
            this.screen = false;
        }
        if (eventObject.altKey) this.altKey = eventObject.altKey;
        if (eventObject.ctrlKey) this.ctrlKey = eventObject.ctrlKey;
        if (eventObject.shiftKey) this.shiftKey = eventObject.shiftKey;
    } else {
        this.eventObject = null;
        this.type = eventName;
        this.source = handleElement;
        this.client = false;
        this.clientX = -1;
        this.clientY = -1;
        this.page = false;
        this.pageX = -1;
        this.pageY = -1;
        this.screen = false;
        this.screenX = -1;
        this.screenY = -1;
    }
    this.element = handleElement;
}
ccStaticEvent.Event = null;
ccStaticEvent.NewEvent = function(handleElement, eventObject, eventName) {
    ccStaticEvent.Event = new ccStaticEvent(handleElement, eventObject, eventName);
    return ccStaticEvent.Event;
}
ccStaticEvent.EventResult = function() {
    if (ccStaticEvent.Event) {
        if (ccStaticEvent.Event.returnValue === false) return false;
    }
}
ccStaticEvent.prototype.preventDefault = function() {
    this.returnValue = false;
    if (this.eventObject) {
        if (this.eventObject.preventDefault) {
            this.eventObject.preventDefault();
        } else {
            this.eventObject.returnValue = false;
        }
    }
}
ccStaticEvent.prototype.stopPropagation = function() {
    if (this.eventObject) {
        if (window.event) {
            this.eventObject.cancelBubble=true;
        } else if (this.eventObject.stopPropagation) {
            this.eventObject.stopPropagation();
        }
    }
}

// Elements wrapper
function EL(n) {
    if (typeof(document.getElementById) != "undefined") {
        return document.getElementById(n);
    } else if (typeof(document.all) != "undefined") {
        return document.all(n);
    } else {
        return new Object; // Perhaps an error swallowing object should be put here.
    }
}
function ELSByAttributeStep(attr,els,arr) {
    var i;
    if (els.length > 0) {
        for (i = 0;i < els.length; i++) {
            if (els[i].getAttribute(attr)) {
                arr.push(els[i]);
            }
        }
    }
}
function ELSByAttribute(attrName) {
    var arr = new Array();
    var t;
    if (document.getElementsByTagName) {
        t = document.getElementsByTagName("DIV");
        ELSByAttributeStep(attrName,t,arr);
        t = document.getElementsByTagName("INPUT");
        ELSByAttributeStep(attrName,t,arr);
        t = document.getElementsByTagName("TABLE");
        ELSByAttributeStep(attrName,t,arr);
        t = document.getElementsByTagName("TD");
        ELSByAttributeStep(attrName,t,arr);
        t = document.getElementsByTagName("TR");
        ELSByAttributeStep(attrName,t,arr);
        t = document.getElementsByTagName("SELECT");
        ELSByAttributeStep(attrName,t,arr);
        t = document.getElementsByTagName("SPAN");
        ELSByAttributeStep(attrName,t,arr);
        t = document.getElementsByTagName("TEXTAREA");
        ELSByAttributeStep(attrName,t,arr);
    }
    return arr;
}
// ASP-CTL basic routines
function ASPCTL_BodyScrollPosition() {
    var x = 0, y = 0;
    x = (document.body.scrollLeft > 0)?document.body.scrollLeft:((document.documentElement.scrollLeft > 0)?document.documentElement.scrollLeft:window.pageXOffset);
    y = (document.body.scrollTop > 0)?document.body.scrollTop:((document.documentElement.scrollTop > 0)?document.documentElement.scrollTop:window.pageYOffset);
    return (x + "," + y);
}
function StaticConfirm(e,msg) {
    if (!confirm(msg)) {
        e.preventDefault();
    }
}
function StaticPostBack(e,frmName,invId,ctlName,ctlVal) {
    var frm = document.forms[frmName];
    if (ctlName != null) {
        if (frm.action.indexOf('?') < 0) frm.action += '?'; else frm.action += '&';
        frm.action += ctlName + '=' + ctlVal;
    }
    if (frm.onsubmit) { 
        if (frm.onsubmit() === false) return; 
    }
    if (frm.elements['ASPCTL_PostBackFocus']) frm.elements['ASPCTL_PostBackFocus'].value = invId;
    frm.submit();
}
function StaticStopPropagation(e) {
    e.stopPropagation();
}

// ASP-CTL standard validators
var ccStaticValidateRequired = function() {
}
ccStaticValidateRequired.Value = function(e,bRequired,errClass,okClass) {
    if (e && e.element) {
        var o = e.element;
        if (typeof(o.className) != "undefined" && !e.aspctlInvalidated) {
            if (o.className != okClass) o.className = okClass;
            if (o.value == "" || typeof(o.value) == "undefined") {
                if (bRequired) o.className = errClass;
                e.aspctlInvalidated = true;
            }
        }
    }
}
ccStaticValidateRequired.Select = function(e,bRequired,errClass,okClass) {
    if (e && e.element) {
        var o = e.element;
        if (typeof(o.className) != "undefined" && !e.aspctlInvalidated) {
            if (o.className != okClass) o.className = okClass;
            if (o.selectedIndex < 0) {
                o.className = errClass;
            } else if (o.options && o.options[o.selectedIndex]) {
                if (o.options[o.selectedIndex].value == "") {
                    if (bRequired) o.className = errClass;
                    e.aspctlInvalidated = true;
                }
            }
        }
    }
}

var ccStaticValidateLength = function() {
}
ccStaticValidateLength.Value = function(e,minLen,maxLen,errClass,okClass) {
    if (e && e.element) {
        var o = e.element;
        if (typeof(o.className) != "undefined" && !e.aspctlInvalidated) {
            if (o.className != okClass) o.className = okClass;
            if (typeof(o.value) != "undefined") {
                if (o.value.length < minLen || o.value.length > maxLen) {
                    o.className = errClass;
                    e.aspctlInvalidated = true;
                }
            }
        }
    }
}

var ccStaticValidateRange = function() {
}
ccStaticValidateRange.Value = function(e,minVal,maxVal,errClass,okClass) {
    if (e && e.element) {
        var o = e.element;
        if (typeof(o.className) != "undefined" && !e.aspctlInvalidated) {
            var minv, maxv;
            minv = (minVal != null)?parseFloat(minVal):NaN;
            maxv = (maxVal != null)?parseFloat(maxVal):NaN;
            if (o.className != okClass) o.className = okClass;
            if (typeof(o.value) != "undefined") {
                var v = parseFloat(o.value);
                if (!isNaN(v)) {
                    if (!isNaN(minv) && v < minv) {
                        o.className = errClass;
                        e.aspctlInvalidated = true;
                    } else if (!isNaN(maxv) && v > maxv) {
                        o.className = errClass;
                        e.aspctlInvalidated = true;
                    }
                }
            }
        }
    }
}

var ccStaticValidateRegExp = function() {
}
ccStaticValidateRegExp.Value = function(e,reStr,errClass,okClass) {
    if (e && e.element) {
        var o = e.element;
        if (typeof(o.className) != "undefined" && !e.aspctlInvalidated) {
            if (o.className != okClass) o.className = okClass;
            if (typeof(o.value) != "undefined") {
                var re = new RegExp(reStr,"ig");
                if (!re.test(o.value)) {
                    o.className = errClass;
                    e.aspctlInvalidated = true;
                }
            }
        }
    }
}