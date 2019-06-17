// Dynamic - client side event handling and various utils
// REQUIRES: staticevents.js
// This part of the library is not compatible with light browsers (PIE etc.)

function ccDynamicSliceArgs(args,nStart,nEnd) {
    var i,r;
    r = new Array();
    for (i = nStart; (i < nEnd || typeof(nEnd) == "undefined") && i < args.length; i++) {
        r[r.length] = args[i];
    }
    return r;
}
function ccDynamicAttachEvent(domEl,eventKind,handler) {
    var custArgs = ccDynamicSliceArgs(arguments,3);
    if (domEl.addEventListener) {
        domEl.addEventListener(eventKind, function(evt) {
                custArgs.unshift(ccStaticEvent.NewEvent(domEl, evt, eventKind));
                handler.apply(domEl,custArgs);
                return ccStaticEvent.EventResult;
            }, false);
    } else if (domEl.attachEvent) {
        domEl.attachEvent("on" + eventKind, function(evt) {
                custArgs.unshift(ccStaticEvent.NewEvent(domEl, evt, eventKind));
                handler.apply(domEl,custArgs);
                return ccStaticEvent.EventResult;
            });
    }
}

// WARNING!!! The classes/routines below are beta versions. Their behaviour may not be fully preserved in the final version.

function ccStaticElPos(e) {
    var r = {x:0,y:0};
    var o = e;
    r.w = o.offsetWidth;
    r.h = o.offsetHeight;
    // if (e.offsetParent) {
        do {
            r.x += o.offsetLeft;
            r.y += o.offsetTop;
        } while (o = o.offsetParent);
    // }
    return r;
}
function ccStaticElPos2(e) { // Features required may not be available or may be buggy in some browsers
    var r = {x:0,y:0};
    var o = e;
    var d;
    d = o.getBoundingClientRect();
    r.w = d.right - d.left;
    r.h = d.bottom - d.top;
    r.x += d.left;
    r.y += d.top;
    return r;
}


function ccStaticTicker(varName,msecs) {
    this.clients = new Array();
    this.varName = varName;
    this.interval = msecs;
    this.ticking = false;
}
ccStaticTicker.prototype.add = function(obj) {
    this.remove(obj);
    this.clients[this.clients.length] = obj;
    if (!this.ticking) {
        window.setTimeout(this.varName + ".tick();", this.interval);
        this.ticking = true;
    }
}
ccStaticTicker.prototype.remove = function(obj) {
    var i;
    for (i = this.clients.length - 1; i >= 0; i--) {
        if (this.clients[i] === obj) {
            this.clients.splice(i,1);
        }
    }
}
ccStaticTicker.prototype.tick = function() {
    var i;
    for (i = this.clients.length - 1; i >= 0; i--) {
        if (!this.clients[i].tick()) {
            this.clients.splice(i,1);
        }
    }
    if (this.clients.length > 0) {
        window.setTimeout(this.varName + ".tick();", this.interval);
        this.ticking = true;
    } else {
        this.ticking = false;
    }
}
var ccStaticDocTicker = new ccStaticTicker("ccStaticDocTicker",40);
function ccStaticTrans() {
}
ccStaticTrans.open = function(innerContent) {
    this.normalize();
    this.dir = 1;
    this.innerHTML = innerContent;
    ccStaticDocTicker.add(this);
}
ccStaticTrans.close = function(innerContent) {
    this.normalize();
    this.dir = -1;
    this.innerHTML = innerContent;
    ccStaticDocTicker.add(this);
}
ccStaticTrans.toggle = function(innerContent) {
    this.normalize();
    this.dir = -this.dir;
    this.innerHTML = innerContent;
    ccStaticDocTicker.add(this);
}
ccStaticTrans.finalize = function() {
    if (typeof(this.innerHTML) != "undefined" && this.innerHTML != null) {
        this.element.innerHTML = this.innerHTML;
        this.innerHTML = null;
    }
    if (typeof(this.finalizer) != "undefined") {
        this.finalizer();
    }
}

function ccStaticTransReveal(el,w,h,step) {
    this.maxw = (w?w:(el != null?parseInt(el.style.width):0));
    this.maxh = (h?h:(el != null?parseInt(el.style.height):0));
    this.w = 0;
    this.h = 0;
    this.step = step;
    this.dir = 1;
    this.element = el;
    this.innerHTML = null;
    this.closed = true;
    this.finalize = ccStaticTrans.finalize;
    this.tick = function() {
        this.w += step * this.dir;
        this.h += step * this.dir;
        if (this.w <= this.maxw && this.w >= 0) this.element.style.width = this.w + "px";
        if (this.h <= this.maxh && this.h >= 0) this.element.style.height = this.h + "px";
        if (this.w <= 0 && this.h <= 0) {
            this.closed = true;
            this.element.style.display = "none";
        } else {
            this.closed = false;
            this.element.style.display = "block";
        }
        if ( (this.w >= this.maxw && this.h >= this.maxh) || (this.w < 0 && this.h < 0) ) {
            this.finalize();
            return false;
        } else {
            return true;
        }           
    }
    this.initFromElement = function() {
        var h = parseInt(this.element.style.height);
        if (!isNaN(h) && h > 0) this.maxh = h;
        var w = parseInt(this.element.style.width);
        if (!isNaN(w) && w > 0) this.maxw = w;
    }
    this.normalize = function() {
        if (this.w < 0) this.w = 0;
        if (this.w > this.maxw) this.w = this.maxw;
        if (this.h < 0) this.h = 0;
        if (this.h > this.maxh) this.h = this.maxh;
    }
    this.open = ccStaticTrans.open;
    this.close = ccStaticTrans.close;
    this.toggle = ccStaticTrans.toggle;
}

function ccStaticTransDrop(el,h,step) {
    this.maxh = (h?h:(el != null?parseInt(el.style.height):0));
    this.h = 0;
    this.step = step;
    this.dir = 1;
    this.element = el;
    this.innerHTML = null;
    this.closed = true;
    this.finalize = ccStaticTrans.finalize;
    this.tick = function() {
        this.h += step * this.dir;
        if (this.h <= this.maxh && this.h >= 0) this.element.style.height = this.h + "px";
        if (this.h <= 0) {
            this.closed = true;
            this.element.style.display = "none";
        } else {
            this.closed = false;
            this.element.style.display = "block";
        }
        if (this.h >= this.maxh || this.h < 0) {
            this.finalize();
            return false;
        } else {
            return true;
        }           
    }
    this.normalize = function() {
        if (this.h < 0) this.h = 0;
        if (this.h > this.maxh) this.h = this.maxh;
    }
    this.initFromElement = function() {
        var h = parseInt(this.element.style.height);
        if (!isNaN(h) && h > 0) this.maxh = h;
    }
    this.open = ccStaticTrans.open;
    this.close = ccStaticTrans.close;
    this.toggle = ccStaticTrans.toggle;
}

function ccStaticTransAppear(el,step) {
    this.maxAlpha = 100;
    this.alpha = 0;
    this.step = step;
    this.dir = 1;
    this.element = el;
    this.innerHTML = null;
    this.closed = true;
    this.finalize = ccStaticTrans.finalize;
    this.tick = function() {
        this.alpha += step * this.dir;
        if (this.alpha <= this.maxAlpha && this.alpha >= 0) {
            this.element.style.opacity = (this.alpha / 100);
            if (this.element.filters) {
                this.element.style.filter = "alpha(opacity=" + this.alpha + ");";
            }
        }
        if (this.alpha <= 0) {
            this.closed = true;
            this.element.style.display = "none";
        } else {
            this.closed = false;
            this.element.style.display = "block";
        }
        if (this.alpha >= this.maxAlpha || this.alpha < 0) {
            this.finalize();
            return false;
        } else {
            return true;
        }           
    }
    this.normalize = function() {
        if (this.alpha < 0) this.alpha = 0;
        if (this.alpha > this.maxAlpha) this.alpha = this.maxAlpha;
    }
    this.initFromElement = function() {}
    this.open = ccStaticTrans.open;
    this.close = ccStaticTrans.close;
    this.toggle = ccStaticTrans.toggle;
}
function ccStaticIdToObject(s, bArray) {
    if (typeof(s) != "string") {
        return s;
    } else {
        var arrObj, i , arr, o;
        arr = s.split(",");
        arrObj = new Array();
        for (i = 0; i < arr.length; i++) {
            o = EL(arr[i]);
            if (o != null) {
                arrObj[arrObj.length] = o;
            } else {
                return s;
            }
        }
        if (bArray) {
            return arrObj;
        } else {
            return ((arrObj.length > 0)?arrObj[0]:null);
        }
    }
}
// slistElsOpen = "id1,id2,...,idn; sElement = "idel";sBoundElement = "id_attachtoelement"
function ccStaticFloatPanel(varName,slistElsOpen,sElement,trans,sBoundElement) {
    this.transition = trans;
    this.transition.finalizer = this.reBind;
    this.transition.finalizerPanel = this;
    this.showElementsId = slistElsOpen;
    this.showElements = null;
    this.varName = varName;
    this.pinId = sBoundElement;
    this.pin = null;
    this.elementId = sElement;
    this.element = null;
    this.prepare = function() {
        var arr, i, arrObj, o;
        this.showElements = ccStaticIdToObject(this.showElementsId,true);
        if (typeof(this.showElements) == "string") return false;
        this.pin = ccStaticIdToObject(this.pinId, false);
        if (typeof(this.pin) == "string") return false;
        this.element = ccStaticIdToObject(this.elementId, false);
        if (typeof(this.element) == "string") return false;
        if (this.transition != null) this.transition.element = this.element;
        return true;
    }
    this.attachEvents = function() {
        if (!this.prepare()) return;
        var i;
        if (this.transition != null) this.transition.initFromElement();
        for (i = 0; i < this.showElements.length; i++) {
            ccDynamicAttachEvent(this.showElements[i],"mouseover",new Function("e", this.varName + ".onOpen(e);"));
        }
        ccDynamicAttachEvent(document.body,"mouseover",new Function("e", this.varName + ".onClose(e);"));
        ccDynamicAttachEvent(document.body,"click",new Function("e", this.varName + ".onClose(e);"));
    }
    this.onOpen = function(e,innerContent) {
        if (!this.prepare()) return;
        if (this.binder) this.binder(this.pin,this.transition.element,this.transition);
        this.open(innerContent);
        e.stopPropagation();
    }
    this.onClose = function(e,innerContent) {
        if (!this.prepare()) return;
        if (this.binder) this.binder(this.pin,this.transition.element,this.transition);
        this.close(innerContent);
        e.stopPropagation();        
    }
    this.onToggle = function(e,innerContent) {
        if (!this.prepare()) return;
        if (this.binder) this.binder(this.pin,this.transition.element,this.transition);
        this.toggle(innerContent);
        e.stopPropagation();
    }
    this.onBindPostion = function(e) {
        if (this.binder) this.binder(this.pin,this.transition.element,this.transition);
    }
    this.open = function(innerContent) {
        if (!this.prepare()) return;
        this.transition.open(innerContent);
    }
    this.close = function(innerContent) {
        if (!this.prepare()) return;
        this.transition.close(innerContent);
    }
    this.toggle = function(innerContent) {
        if (!this.prepare()) return;
        this.transition.toggle(innerContent);
    }
    this.binder = ccStaticElementBinder.under;
    this.reBind = function() {
        var me = this.finalizerPanel;
        if (me.binder) me.binder(me.pin,me.transition.element,me.transition);
    }
}
// Bounders
function ccStaticBindCorrection(trans) {
    if (trans == null) return {x:0,y:0,w:0,h:0};
    var p = {
        x: parseInt(trans.correctionX),
        y: parseInt(trans.correctionY),
        w: parseInt(trans.correctionW),
        h: parseInt(trans.correctionH)
    }
    if (isNaN(p.x)) p.x = 0;
    if (isNaN(p.y)) p.y = 0;
    if (isNaN(p.w)) p.w = 0;
    if (isNaN(p.h)) p.h = 0;
    return p;
}
var ccStaticElementBinder = {
    under: function(pin,el,trans) { // pin - bind to this elements position, el - elemnent to bind, trans - transition to update (not used in the built-in routines)
        var p = ccStaticElPos(pin);
        var c = ccStaticBindCorrection(trans);
        if (el) {
            el.style.top = (p.y + p.h + c.y) + "px";
            el.style.left = (p.x + c.x) + "px";
            el.style.width = (p.w + c.w) + "px";
            if (trans != null) {
                trans.maxw = p.w;
            }
        }
    },
    right: function(pin,el,trans) {
        var p = ccStaticElPos(pin);
        var c = ccStaticBindCorrection(trans);
        if (el) {
            el.style.top = (p.y + c.y) + "px";
            el.style.left = (p.x + p.w + c.x) + "px";
        }
    }
}

function ccStaticStdProgress(covid) {
    this.cover = EL(covid);
    this.coverId = covid;
}
ccStaticStdProgress.prototype.onstart = function(task,sloader) {
    
}
ccStaticStdProgress.prototype.onprogress = function(task,sloader) {
    if (sloader.timeTaken > 200) {
        if (this.cover && task.eventParam && task.eventParam.control) {
            if (this.cover.style.display == "block") return true;
            var w = EL(task.eventParam.control);
            if (w) {
                var p = ccStaticElPos(w);
                this.cover.style.left = p.x + "px";
                this.cover.style.top = p.y + "px";
                this.cover.style.width = p.w + "px";
                this.cover.style.height = p.h + "px";
                this.cover.style.display = "block";
            }
        }
    }
}
ccStaticStdProgress.prototype.oncomplete = function(task,sloader) {
    if (this.cover) {
        if (!task.succeeded) {
            this.cover.style.display = "none";
        } else {
            var errHolder = EL(this.coverId + "_text");
            if (errHolder) {
                errHolder.innerHTML = "Error occured";
            } else {
                this.cover.style.display = "none";
            }
        }
    }
}