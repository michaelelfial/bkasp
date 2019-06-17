// Version 1.B
// This is memory economic way to perform async operations.
// It does not rely on features such as apply/call because they are not existent in
// JS of many lightweight browsers. Furthermore a regular polling of the status is used instead of a callback because problems with it
// in some older and mobile browsers.
function newStaticLoader(ldrName) {
    return {
        timeInterval: 100,
        timeLimit: 15000,
        loader: window.ActiveXObject ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest(),
        tasks: new Array(),
        completed: new Object(), // completed tasks go here if no complete routine is specified
        current: null,
        timeTaken: 0,
        active: false,
        nextTask: function() {
            if (this.active) return;
            this.current = null;
            if (this.tasks.length > 0) {
                this.active = true;
                this.current = this.tasks.shift();
                this.timeTaken = 0;
                this.adviseStart();                    
                this.loader.open(this.current.method,this.current.url,true);
                if (typeof(this.current.headers) != "undefined") {
                    for (var hn in this.current.headers) {
                        try {
                            this.loader.setRequestHeader(hn, this.current.headers[hn]);        
                        } catch (exc) {
                            if (ASPCTLDebugAsyncPostBack) {
                                alert("Header not set.\r\nHeader: " + hn + "\r\nValue: " + this.current.headers[hn] + "\r\nError: " + exc.description);
                            }
                        }
                    }
                }
                if (ASPCTLDebugAsyncPostBack) {
                    alert("url:" + this.current.url + "\r\nMethod:" + this.current.method + "\r\nContent-length:" + this.current.headers[hn] + "\r\nPost data:\r\n" + this.current.postData);
                }
                this.loader.send(this.current.postData);
                setTimeout(ldrName + ".ticker()",this.timeInterval);
            } else {
                this.active = false;
            }
        },
        splitHeader: function(hdr) {
            var n = hdr.indexOf(":");
            if (n < 0) return null;
            var hname = hdr.slice(0,n);
            var hcontent = hdr.slice(n+1);
            return {
                name: hname,
                content: hcontent
            }
        },
        adviseStart: function() {
            var o = this.current;
            if (o.eventSink != null && o.eventSink.onstart != null) {
                if (o.eventSink.onstart(o,this) === false) return false;
            }
            return true;
        },
        adviseProgress: function() {
            var o = this.current;
            if (o.eventSink != null && o.eventSink.onprogress != null) {
                if (o.eventSink.onprogress(o,this) === false) return false;
            }
            return true;
        },
        adviseComplete: function() {
            var o = this.current;
            if (o.eventSink != null && o.eventSink.oncomplete != null) {
                if (o.eventSink.oncomplete(o,this) === false) return false;
            }
            return true;
        },
        ticker: function() {
            var o,s,i,h;
            if (this.loader.readyState == 4) {
                if (this.loader.status != 200) {
                    
                    o = this.current;
                    o.status = this.loader.status;
                    o.succeeded = false;
                    this.adviseComplete();
                    if (typeof(o.errorHandler) != "undefined" && o.errorHandler != null) {
                        if (ASPCTLDebugAsyncPostBack) {
                            o.errorHandler(o,this.loader.statusText + "\r\n" + this.loader.responseText);
                        } else {
                            o.errorHandler(o,this.loader.statusText);
                        }
                    }
                    this.timeTaken = 0;
                    this.loader.abort();
                    this.active = false;
                    this.nextTask();
                } else {
                    o = this.current;
                    o.succeeded = true;
                    this.timeTaken = 0;
                    s = this.loader.getAllResponseHeaders();
                    s = s.split("\r\n");
                    for (i = 0;i < s.length;i++) {
                        h = this.splitHeader(s[i]);
                        if (h != null) {
                            o.responseHeaders[h.name] = h;
                        }
                    }
                    if (o.resultType == "xml") {
                        o.result = this.loader.responseXML;
                        if (ASPCTLDebugAsyncPostBack) {
                            alert("Async request result:\r\n" + this.loader.responseText);
                        }
                    } else if (o.resultType == "bin") {
                        o.result = this.loader.responseBody;
                    } else if (o.resultType == "stream") {
                        o.result = this.loader.responseStream;
                    } else {
                        if (ASPCTLDebugAsyncPostBack) {
                            alert("Async request result:\r\n" + this.loader.responseText);
                        }
                        o.result = this.loader.responseText;
                    }
                    this.adviseComplete();
                    if (o.complete) {
                        o.complete(o);
                    } else {
                        this.completed[o.url] = o;
                    }
                    this.active = false;
                    this.nextTask();
                }
            } else {
                if (this.timeTaken > this.timeLimit) {
                    o = this.current;
                    o.succeeded = false;
                    o.status = -1;
                    this.adviseComplete();
                    if (typeof(o.errorHandler) != "undefined" && o.errorHandler != null) {
                        o.errorHandler(o,"Time out.");
                    }
                    this.timeTaken = 0;
                    this.loader.abort();
                    this.active = false;
                    this.nextTask();
                } else {
                    this.timeTaken += this.timeInterval;
                    if (this.adviseProgress() === false) {
                        o = this.current;
                        o.succeeded = false;
                        o.status = -1;
                        this.adviseComplete();
                        if (typeof(o.errorHandler) != "undefined" && o.errorHandler != null) {
                            o.errorHandler(o,"Timeout.");
                        }
                        this.timeTaken = 0;
                        this.loader.abort();
                        this.active = false;
                        this.nextTask();
                    } else {
                        setTimeout(ldrName + ".ticker()",this.timeInterval);
                    }
                }
            }
        },
        cancelCurrent: function() {
            this.timeTaken = this.timeLimit + 1000;
        },
        newTask: function(reqMethod,u,rType,hs,pData,sType) {
            var o = {
                url: u,
                status: 0,
                method: (reqMethod?reqMethod:"GET"),
                headers: hs,
                postData: pData,
                resultType: (rType?rType:"text"),
                complete: null, // Completion routine - consummer
                result: null,
                responseHeaders: new Object(),
                succeeded: false,
                errorHandler: this.errorSink,
                taskType: sType,
                eventSink: null, // an object implementing onstart,oncomplete,onprogress
                eventParam: null // Place paremeters for the event handler here (convention)
            };
            var i;
            if (typeof(sType) == "string") { 
                for (i =  this.tasks.length - 1; i >= 0;i--) {
                    if (this.tasks[i].taskType == sType) this.tasks.splice(i,1);
                }
            }
            this.tasks[this.tasks.length] = o;
            return o; // For additional manipulation
        },
        getContentFor: function(u,containerName) {
            var o = this.newTask("GET",u,"text",null,null,containerName);
            o.container = EL(containerName);
            o.complete = function (o) {
                o.container.innerHTML = o.result;
            }
            this.nextTask();
        },
        postArea: function(u, areaId, completion, errHandler, buttonName) {
            // Collect form fields
            var els,i,frm,pData = "",fld,j, a;
            els = new Array();
            frm = EL[areaId];
            a = frm.getElementsByTagName("input");
            for (i = 0; i < a.length; i++) els[els.length] = a[i];
            a = frm.getElementsByTagName("select");
            for (i = 0; i < a.length; i++) els[els.length] = a[i];
            a = frm.getElementsByTagName("textarea");
            for (i = 0; i < a.length; i++) els[els.length] = a[i];
            
            for (i = 0; i < els.length;i++) {
                fld = els[i];
                switch(fld.type.toLowerCase()) {
                    case "select-one":
                        if (fld.selectedIndex >= 0) {
                            pData += encodeURIComponent(fld.id) + "=" + encodeURIComponent(fld.options[fld.selectedIndex].value);
                            pData += "&";
                        }
                    break;
                    case "select-multiple":
                        for (j = 0; j < fld.options.length; j++) {
                            if (fld.options[j].selected) {
                                pData += encodeURIComponent(fld.id) + "=" + encodeURIComponent(fld.options[fld.selectedIndex].value);
                                pData += "&";
                            }
                        }
                    break;
                    case "button":
                        if (buttonName == fld.id) {
                            pData += encodeURIComponent(fld.id) + "=" + encodeURIComponent(fld.value);
                            pData += "&";
                        }
                    break;
                    case "checkbox":
                        if (fld.checked) {
                            pData += encodeURIComponent(fld.id) + "=" + encodeURIComponent(fld.value);
                            pData += "&";
                        }
                    break;
                    case "image": // Images are currently submitted like buttons (ASPCTL knows how to deal with this)
                        if (buttonName == fld.name) {
                            pData += encodeURIComponent(fld.id) + "=" + encodeURIComponent(fld.value);
                            pData += "&";
                        }
                    break;
                    case "radio":
                        if (fld.checked) {
                            pData += encodeURIComponent(fld.id) + "=" + encodeURIComponent(fld.value);
                            pData += "&";
                        }
                    break;
                    case "reset": // Always ignored
                    break;
                    case "submit":
                        if (buttonName == fld.name) {
                            pData += encodeURIComponent(fld.id) + "=" + encodeURIComponent(fld.value);
                            pData += "&";
                        }
                    break;
                    case "file": // Ignored
                    break;
                    case "text":
                    case "hidden":
                    case "password":
                    case "textarea":
                        pData += encodeURIComponent(fld.id) + "=" + encodeURIComponent(fld.value);
                        pData += "&";
                    break;
                }
            }
            
            var hs = {
                    "Content-Type": "application/x-www-form-urlencoded",
                    "Content-length": pData.length
                };
                
            var addr = u;
            if (addr.indexOf('?') < 0) addr += '?'; else addr += '&';
            addr += "ASPCTLArea=" + areaId;
            var o = this.newTask("POST", addr, "xml", hs, pData, null); 
            o.complete = completion;
            o.container = areaId; // Remember the form name to help the completion routine
            if (typeof(errHandler) != "undefined" && errHandler != null) {
                o.errorHandler = errHandler;
            }
            return o;
        },
        getArea: function(u, areaId, completion, errHandler) {
            var addr = u;
            if (addr.indexOf('?') < 0) addr += '?'; else addr += '&';
            addr += "ASPCTLArea=" + areaId;
            var o = this.newTask("GET", addr, "xml", null, null, null); 
            o.complete = completion;
            o.container = areaId; // Remember the form name to help the completion routine
            if (typeof(errHandler) != "undefined" && errHandler != null) {
                o.errorHandler = errHandler;
            }
            return o;
        },
        postForm: function(u, frmName, completion, errHandler, buttonName) {
            // Collect form fields
            var i,frm,pData = "",fld,j;
            frm = document.forms[frmName];
            for (i = 0; i < frm.elements.length; i++) {
                fld = frm.elements[i];
                if (typeof(fld.name) != "undefined" && fld.name.length > 0) {
                    switch(fld.type.toLowerCase()) {
                        case "select-one":
                            if (fld.selectedIndex >= 0) {
                                pData += encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.options[fld.selectedIndex].value);
                                if (i < frm.elements.length - 1) pData += "&";
                            }
                        break;
                        case "select-multiple":
                            for (j = 0; j < fld.options.length; j++) {
                                if (fld.options[j].selected) {
                                    pData += encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.options[fld.selectedIndex].value);
                                    if (i < frm.elements.length - 1) pData += "&";
                                }
                            }
                        break;
                        case "button":
                            if (buttonName == fld.name) {
                                pData += encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.value);
                                if (i < frm.elements.length - 1) pData += "&";
                            }
                        break;
                        case "checkbox":
                            if (fld.checked) {
                                pData += encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.value);
                                if (i < frm.elements.length - 1) pData += "&";
                            }
                        break;
                        case "image": // Images are currently submitted like buttons (ASPCTL knows how to deal with this)
                            if (buttonName == fld.name) {
                                pData += encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.value);
                                if (i < frm.elements.length - 1) pData += "&";
                            }
                        break;
                        case "radio":
                            if (fld.checked) {
                                pData += encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.value);
                                if (i < frm.elements.length - 1) pData += "&";
                            }
                        break;
                        case "reset": // Always ignored
                        break;
                        case "submit":
                            if (buttonName == fld.name) {
                                pData += encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.value);
                                // alert(encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.value));
                                if (i < frm.elements.length - 1) pData += "&";
                            }
                        break;
                        case "file": // Ignored
                        break;
                        case "text":
                        case "hidden":
                        case "password":
                        case "textarea":
                            pData += encodeURIComponent(fld.name) + "=" + encodeURIComponent(fld.value);
                            if (i < frm.elements.length - 1) pData += "&";
                        break;
                    }
                }
            }
            var hs = {
                    "Content-Type": "application/x-www-form-urlencoded",
                    "Content-length": pData.length
                };
            var o = this.newTask("POST", u, "xml", hs, pData, null); 
            o.complete = completion;
            o.container = frmName; // Remember the form name to help the completion routine
            if (typeof(errHandler) != "undefined" && errHandler != null) {
                o.errorHandler = errHandler;
            }
            return o;
        },
        errorSink: function(t,errText) {
            // assign your function if you want to receive the errors or uncomment this while testing
            // alert(t.method + "\r\n" + t.url + "\r\n" + t.status + "\r\n" + errText);
        }    
        
    };
}
// Only 2 loaders (max 2 concurrent tasks) are maintained. If you need to adjust timeouts and other parameters do it here.
// This one should be used for secondary work - ads, hints etc.
var ccStaticLoader = newStaticLoader("ccStaticLoader");
// This one should be used for priority tasks - such as asynchronours form submits.
var ccPriorityLoader = newStaticLoader("ccPriorityLoader");
// ASP-CTL Specific - send request/decode partial update response
// frmName - name of the form, clts - an Array of server side names of user controls involved
// ctlName, ctlVal - like in postback
function ccStaticASPCTLRequest(frmName,ctls, ctlName, ctlVal, eventSink, eventParam) {
    var frm = document.forms[frmName];
    var u = frm.action;
    if (u.indexOf('?') < 0) u += '?'; else u += '&';
    u += "ASPCTLPartial=form.xml&ASPCTLControlList=" + ctls.join(",");
    if (typeof(ctlName) != "undefined" && ctlName != null && typeof(ctlVal) != "undefined" && ctlVal != null && ctlVal != "") u += "&" + ctlName + '=' + ctlVal
    var task = ccPriorityLoader.postForm(u, frmName, ccStaticASPCTLResponse,ccStaticASPCTLError,ctlName);
    if (eventSink != null) {
        task.eventSink = eventSink;
    } else {
        if (typeof(ASPCTL_AsyncEventSink) != "undefined") {
            task.eventSink = ASPCTL_AsyncEventSink;
        }
    }
    task.eventParam = eventParam;
    ccPriorityLoader.nextTask();
}
function ccStaticASPCTLResponse(task) {
    var x = task.result; // Response XML
    var frm = document.forms[task.container];
    var root = x.documentElement;
    var i,n,ntype,execcode,arrExecCode;
    arrExecCode = new Array();
    for (i = 0; i < root.childNodes.length; i++) {
        n = root.childNodes[i];
        if (n.tagName == "update") {
            ntype = n.attributes.getNamedItem("type");
            if (typeof(ntype) != "undefined") {
                switch(ntype.value) {
                    case "value":
                        if (n.childNodes.length > 0) { // Old WebKit returns empty node for 0 length texts
                            frm[n.attributes.getNamedItem("name").value].value = n.childNodes[0].nodeValue;
                        } else {
                            frm[n.attributes.getNamedItem("name").value].value = "";
                        }
                    break;
                    case "innerHTML":
                        if (n.childNodes.length > 0) { // See above
                            EL(n.attributes.getNamedItem("id").value).innerHTML = n.childNodes[0].nodeValue;
                        } else {
                            EL(n.attributes.getNamedItem("id").value).innerHTML = "";
                        }
                    break;
                }
                execcode = n.attributes.getNamedItem("code");
                if (typeof(execcode) != "undefined" && execcode != null) {
                    arrExecCode[arrExecCode.length] = execcode.value;
                }
            }
            
        }
        // Ignore the rest
    }
    for (i = 0; i < arrExecCode.length; i++) {
        eval(arrExecCode[i]);
    }
    if (ASPCTL_ControlsOnLoad) ASPCTL_ControlsOnLoad();
    n = root.attributes.getNamedItem("redirect");
    if (typeof(n) != "undefined" && n != null) {
        document.location = n.value;
    }
}
function ccStaticASPCTLError(task, errText) {
    if (ASPCTLDebugAsyncPostBack) {
        if (window.confirm("Display the server response?")) {
            // ASPCTLDisableAsyncPostBack = true; // You can uncomment this for a while if you want to revert to normal submit after error while debugging
            document.write(errText);
            document.close();
        }
    } else if (typeof(ASPCTLAsyncPostBackErrorText) != "undefined") {
        if (window.confirm(ASPCTLAsyncPostBackErrorText)) {
            ASPCTLDisableAsyncPostBack = true;
        }
    }
}
function StaticAsyncPostBack(e,frmName,uCtl,invId,ctlName,ctlVal,eventSink,clientId) {
    if (typeof(ASPCTLDisableAsyncPostBack) != "undefined" && ASPCTLDisableAsyncPostBack) {
        StaticPostBack(e,frmName,invId,ctlName,ctlVal);
    } else {
        e.stopPropagation();
        if (e.returnValue === false) return;
        ccStaticASPCTLRequest(frmName,[uCtl],ctlName,ctlVal,eventSink,{control:clientId,invoker:invId});
        e.preventDefault();
    }
}
function StaticButtonAsyncPostBack(e,frmName,uCtl,invId,ctlName,ctlVal,eventSink,clientId) {
    if (typeof(ASPCTLDisableAsyncPostBack) != "undefined" && ASPCTLDisableAsyncPostBack) {
        
    } else {
        e.stopPropagation();
        if (e.returnValue === false) return;
        ccStaticASPCTLRequest(frmName,[uCtl],ctlName,ctlVal,eventSink,{control:clientId,invoker:invId});
        e.preventDefault();
    }
}