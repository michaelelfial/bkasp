// Low level
function ccStaticPickSelection(e,idFrom) {
    var panel = (typeof(idFrom) == "string")?EL(idFrom):idFrom;
    var s = "";
    if (document.selection) {
        panel.focus();
        var range = document.selection.createRange();
        s = range.text;
    } else if (typeof(panel.selectionStart) != "undefined") {
        s = panel.value.substring(panel.selectionStart, panel.selectionEnd);
    } else if (window.getSelection) {
        s = window.getSelection().toString();
    }
    return s;
}
function ccStaticTextAreaRange(objId) {
    var obj = (typeof(objId) == "string")?EL(objId):objId;
    this.obj = obj;
    if(document.selection) {
        obj.focus();
		var range = document.selection.createRange();
		this.start = -1;
        this.end = 0;
		if(range.parentElement() != obj) {
		    this.range = null;
		} else {
		    this.range = range;
		}
    } else if(typeof(obj.selectionStart) != "undefined") {
        this.start = obj.selectionStart;
		this.end   = obj.selectionEnd;
		this.range = null;
    } else {
        this.start = -1;
        this.end = 0;
        this.range = null;    
    }
    
    this.isEmpty = function() {
        if (this.range != null) return false;
        if (this.start >= 0 && this.end >= this.start) return false;
        return true;
    }
    this.getText = function() {
        if (this.isEmpty()) {
            return this.obj.value;
        } else if (this.range != null) {
            return this.range.text;
        } else {
            this.start
            return this.obj.value.substr(this.start,this.end - this.start);
        }
    }
    this.replace = function(text) {
        if (this.isEmpty()) {
            this.obj.value += text;
        } else if (this.range != null) {
            this.range.text = text;
		    this.range.collapse(false);
		    this.range.select();
        } else {
            this.obj.value = obj.value.substr(0, this.start)
			+ text
			+ this.obj.value.substr(this.end, this.obj.value.length);
            this.obj.focus();
            var pos = this.start + text.replace(/\r\n/g,"\n").length;
    		this.obj.setSelectionRange(pos, pos);
        }
    }
}
ccStaticTextAreaRange.SaveSelection = function(objId) {
    var obj = (typeof(objId) == "string")?EL(objId):objId;
    obj.ccStaticSavedSelection = new ccStaticTextAreaRange(objId);
}
ccStaticTextAreaRange.UseSelection = function(objId) {
    var obj = (typeof(objId) == "string")?EL(objId):objId;
    var r;
    if (obj.ccStaticSavedSelection) {
        r = obj.ccStaticSavedSelection;
    } else {
        r = new ccStaticTextAreaRange(objId);
    }
    obj.ccStaticSavedSelection = null;
    return r;
}
ccStaticTextAreaRange.ccStaticInsertTextFromList = function(e, lstId, taId, sar) { // Insert text from a select
    var ol = (typeof(lstId) == "string")?EL(lstId):lstId;
    var ename;
    if (ol != null) {
        ename = ol.options[ol.selectedIndex].value;
        ccStaticTextAreaRange.UseSelection(taId).replace(sar[ename]);
    }
}
ccStaticTextAreaRange.ccStaticInsertTextFromArray = function(e, ename, taId, sar) { // Insert text from a shared server array
    ccStaticTextAreaRange.UseSelection(taId).replace(sar[ename]);
}
ccStaticTextAreaRange.ccStaticEncloseText = function(e, taId, txtStart, txtEnd) { // Enclose selected text with tags
    var sel = ccStaticTextAreaRange.UseSelection(taId);
    sel.replace(txtStart + sel.getText() + txtEnd);
}
ccStaticTextAreaRange.ccStaticEncloseTextFromArray = function(e, taId, sar, idStart, idEnd) { // Enclose selected text with tags
    ccStaticTextAreaRange.ccStaticEncloseText(e, taId, sar[idStart], sar[idEnd]);
}
ccStaticTextAreaRange.ccStaticEncloseTextFromList = function(e, lstId, taId, sar) { // Enclose selected text with tags
    var idStart, idEnd;
    var ol = (typeof(lstId) == "string")?EL(lstId):lstId;
    var ename = ol.options[ol.selectedIndex].value;
    if (ename.length > 0) {
        var arr = ename.split(",");
        if (arr.length > 1) {
            ccStaticTextAreaRange.ccStaticEncloseText(e, taId, sar[arr[0]], sar[arr[1]]);
        } else if (arr.length == 1) {
            ccStaticTextAreaRange.UseSelection(taId).replace(sar[arr[0]]);
        }
    }
}


function ccStaticInsertText(e, objId, text) {
    var obj = (typeof(objId) == "string")?EL(objId):objId;
	if(document.selection) {
		obj.focus();
		var orig = obj.value.replace(/\r\n/g, "\n");
		var range = document.selection.createRange();

		if(range.parentElement() != obj) {
			return false;
		}
		range.text = text;
		range.collapse(false);
		range.select();
		return;
	} else if(typeof(obj.selectionStart) != "undefined") {
		var start = obj.selectionStart;
		var end   = obj.selectionEnd;

		obj.value = obj.value.substr(0, start)
			+ text
			+ obj.value.substr(end, obj.value.length);
	}

	if(start != null) {
		ccStaticInsertText_Caret(obj, start + text.length);
	} else {
		obj.value += text;
	}
}
function ccStaticInsertText_Caret(obj, pos) {
	if(obj.createTextRange) {
		var range = obj.createTextRange();
		range.move('character', pos);
		range.select();
	} else if(obj.selectionStart) {
		obj.focus();
		obj.setSelectionRange(pos, pos);
	}
}
// Helpers for ASP-CTL user controls
function ccStaticPickSelectionIn(e,idFrom, idField) { // Can be used on buttons that activate user controls to do something on the server
    var fld = (typeof(idField) == "string")?EL(idField):idField;
    fld.value = ccStaticPickSelection(e,idFrom);
    if (fld.value.length <= 0) {
         e.preventDefault();
         return false;
    }
}
function ccStaticInsertTextFromList(e, lstId, taId, sar) { // Insert text from a select
    var ol = (typeof(lstId) == "string")?EL(lstId):lstId;
    var ename;
    if (ol != null) {
        ename = ol.options[ol.selectedIndex].value;
        ccStaticInsertText(e, taId, sar[ename]);
    }
}
function ccStaticInsertTextFromArray(e, ename, taId, sar) { // Insert text from a shared server array
    ccStaticInsertText(e, taId, sar[ename]);
}
function ccStaticEncloseText(e, taId, txtStart, txtEnd) { // Enclose selected text with tags
    var s = ccStaticPickSelection(e,taId);
    ccStaticInsertText(e, taId, txtStart + s + txtEnd);
}
function ccStaticEncloseTextFromArray(e, taId, sar, idStart, idEnd) { // Enclose selected text with tags
    ccStaticEncloseText(e, taId, sar[idStart], sar[idEnd]);
}
function ccStaticEncloseTextFromList(e, lstId, taId, sar) { // Enclose selected text with tags
    var idStart, idEnd;
    var ol = (typeof(lstId) == "string")?EL(lstId):lstId;
    var ename = ol.options[ol.selectedIndex].value;
    if (ename.length > 0) {
        var arr = ename.split(",");
        if (arr.length > 1) {
            ccStaticEncloseText(e, taId, sar[arr[0]], sar[arr[1]]);
        } else if (arr.length == 1) {
            ccStaticInsertText(e, taId, sar[arr[0]]);
        }
    }
}
