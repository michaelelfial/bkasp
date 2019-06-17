<% @Language=JScript %>
<%
Response.ContentType = "text/plain";
var __boolErr = false;
// Determine input parameters
var __strMenuFile = "";
if (Request.QueryString("menufile").Count > 0) {
    Response.Write("// menufile: " + Request.QueryString("menufile") + "\n");
    __strMenuFile = new String(Server.MapPath(Request.QueryString("menufile")(1)));
} else {
    Response.Write("Error - no menufile parameter.\n");
    __boolErr = true;
}
var __strMenuName = "";
if (Request.QueryString("menuname").Count > 0) {
    Response.Write("// menuname: " + Request.QueryString("menuname") + "\n");
    __strMenuName = new String(Request.QueryString("menuname")(1));
} else {
    Response.Write("Error - no menuname parameter.\n");
    __boolErr = true;
}
var __boolCreateVars = false;
if (Request.QueryString("createvariables").Count > 0) {
    __boolCreateVars = parseInt(Request.QueryString("createvariables")(1));
}
if (__boolCreateVars) {
    Response.Write("// Variables will be created for the explicitly named items\n");
} else {
    Response.Write("// No variables will be created for the items with names\n");
}    
    
var __strFrame = "";
if (Request("frame").Count > 0) {
    __strFrame = "frame=" + Request("frame");
} 


var __reTokens = /\,/gi;
var __reSpcL = /\S/gi;
var __reSpcR = /\s*$/gi;
var __reAccel = /\-/gi;
function Trim(s) {
    var result = s;
    var i = result.search(__reSpcL);
    if (i >= 0) result = result.slice(i,result.length);
    i = result.search(__reSpcR);
    if (i >= 0) result = result.slice(0,i);
    return result;
}
var __itemAutoNameCnt = 0;
function AutoName() {
    __itemAutoNameCnt++;
    return ("Item" + __itemAutoNameCnt);
}
// Class MenuStack
function MenuStack() {
    this.pos = new Array();
    this.ident = "";    
}
MenuStack.prototype.Ident = function () {
    var i;
    this.ident = "";
    for (i = 0; i < this.pos.length; i++) this.ident += "  ";
}
MenuStack.prototype.Push = function (name) {
    this.pos[this.pos.length] = name;
    this.Ident();
}
MenuStack.prototype.Pull = function () {
    this.pos = this.pos.slice(0,-1);
    this.Ident();
    return this.Top();
}
MenuStack.prototype.Top = function () {
    var s = "external.Menus.MenuTree";
    var i;
    for (i = 0; i < this.pos.length; i++) {
        s += "('" + this.pos[i] + "')";
    }
    return s;
}
// Call only once
MenuStack.prototype.CreateTop = function () {
    var s = "external.Menus.MenuTree";
    var i;
    for (i = 0; i < (this.pos.length - 1); i++) {
        s += "('" + this.pos[i] + "')";
    }
    s += ".CreateSubItem('" + this.pos[this.pos.length - 1] + "');"
    return s;
}
MenuStack.prototype.FreeTop = function () {
    var s = "external.Menus.MenuTree";
    var i;
    for (i = 0; i < (this.pos.length - 1); i++) {
        s += "('" + this.pos[i] + "')";
    }
    s += ".Subs.Remove('" + this.pos[this.pos.length - 1] + "');"
    return s;
}
MenuStack.prototype.SetAccel = function(str) {
    var arr = str.split(__reAccel);
    var i;
    if (arr != null) {
        for (i = 0; i < arr.length; i++) {
            switch (arr[i]) {
                case "Ctrl":
                    Response.Write(this.ident + this.Top() + ".Accelerator.Ctrl = true;\n");                
                    continue;
                case "Shift":
                    Response.Write(this.ident + this.Top() + ".Accelerator.Shift = true;\n");
                    continue;
                case "Alt":
                    Response.Write(this.ident + this.Top() + ".Accelerator.Alt = true;\n");
                    continue;
                default:
                    Response.Write(this.ident + this.Top() + ".Accelerator.Key = '" + arr[i] + "';\n");
                    return;
            }
        }
    }
    
}

function TrimArray(a) {
    var i;
    for (i = 0; i < a.length; i++) {
        a[i] = Trim(a[i]);
    }
}
function CheckCount(arr,cnt,line) {
    if (arr.length < cnt) {
        Response.Write("*** Error on line " + currentLine + ": Wrong number of arguments.\n");
        Response.Write(line +  "\n");
        return false;
    } else return true;
}
function OptionalName(arr,cnt) {
    if (arr.length > cnt) {
        return arr[cnt];
    } return AutoName();
}
function ExplicitName(arr,cnt,stack) {
    if (__boolCreateVars) {
        if (arr.length > cnt) {
            Response.Write(stack.ident + "var " + arr[cnt] + " = " + stack.Top() + ";\n");
        }
    }
}
var __radioOn = false;
function CheckRadio(b,line) {
    if (b) {
        if (!__radioOn) {
            Response.Write("*** Error on line " + currentLine + ": Radio group not started.\n");
            Response.Write(line +  "\n");
            return false;
        }
    } else {
        if (__radioOn) {
            Response.Write("*** Error on line " + currentLine + ": Illegal in a radio group.\n");
            Response.Write(line +  "\n");
            return false;
        }
    }
    return true;
}
var currentLine = 0;
function ParseMenuDefinition(file) {
    var strLine;
    var arr;
    var strKeyword;
    var tmp;
    currentLine = 0;
    while (!file.EOS) {
        currentLine++;
        strLine = file.ReadText(-1);
        if (strLine.length == 0) continue;
        tmp = Trim(strLine);
        if (tmp.charAt(0) == "'") continue;
        arr = strLine.split(__reTokens);
        if (arr == null) {
            Reaponse.Write("Error on line " + currentLine);
            return false;
        }
        if (arr.length > 0) {
            TrimArray(arr);
            strKeyword = arr[0];
            switch (strKeyword) {
                case "POPUP":
                case "P":
                    // POPUP, Caption
                    if (!CheckCount(arr,2,strLine)) return false;
                    if (!CheckRadio(false,strLine)) return false;
                    Response.Write("\n");
                    Response.Write(__ms.ident + "// Popup menu\n");
                    __ms.Push(OptionalName(arr,2));
                    Response.Write(__ms.ident + __ms.CreateTop() + "\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Caption = '" + arr[1] + "';\n");
                    ExplicitName(arr,2,__ms);
                break;
                case "POPUP END":
                case "PE":
                    if (!CheckRadio(false,strLine)) return false;
                    // POPUP END
                    __ms.Pull();
                break;
                case "ITEM":
                case "I":
                    // ITEM, Caption, Handler, Info
                    if (!CheckCount(arr,4,strLine)) return false;
                    __ms.Push(OptionalName(arr,4));
                    Response.Write(__ms.ident + "// Menu item\n");
                    Response.Write(__ms.ident + __ms.CreateTop() + "\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Caption = '" + arr[1] + "';\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Handler = '" + arr[2] + "';\n");
                    Response.Write(__ms.ident + __ms.Top() + ".HandlerNamespace = '" + __strFrame + "';\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Info = '" + arr[3] + "';\n");
                    ExplicitName(arr,4,__ms);
                    __ms.Pull();
                break;
                case "ACCELERATED ITEM":
                case "A":
                    // ITEM, Accel, Caption, Handler, Info
                    if (!CheckCount(arr,5,strLine)) return false;
                    __ms.Push(OptionalName(arr,5));
                    Response.Write(__ms.ident + "// Menu item\n");
                    Response.Write(__ms.ident + __ms.CreateTop() + "\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Caption = '" + arr[2] + "';\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Handler = '" + arr[3] + "';\n");
                    Response.Write(__ms.ident + __ms.Top() + ".HandlerNamespace = '" + __strFrame + "';\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Info = '" + arr[4] + "';\n");
                    ExplicitName(arr,5,__ms);
                    __ms.SetAccel(arr[1]);
                    __ms.Pull();
                break;
                case "RADIOGROUP":
                case "R":
                    // RADIOGROUP
                    if (!CheckRadio(false,strLine)) return false;
                    __radioOn = true;
                    __ms.Push(OptionalName(arr,1));
                    Response.Write(__ms.ident + "// Radio group\n");
                    Response.Write(__ms.ident + __ms.CreateTop() + "\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Type = '" + 4 + "';\n");
                    ExplicitName(arr,1,__ms);
                    __radioOn = true;
                break;
                case "RADIOGROUP END":
                case "RE":
                    if (!CheckRadio(true,strLine)) return false;
                    __radioOn = false;
                    __ms.Pull();
                    __radioOn = false;
                break;
                case "SEPARATOR":
                case "S":
                    __ms.Push(OptionalName(arr,1));
                    Response.Write(__ms.ident + "// Separator\n");
                    Response.Write(__ms.ident + __ms.CreateTop() + "\n");
                    Response.Write(__ms.ident + __ms.Top() + ".Type = '" + 2 + "';\n");
                    __ms.Pull();
                break;
            }
        }
    }
    return true;
}

var __ms; // Menu stack
if (!__boolErr) {    
    // Start the main work
    __ms = new MenuStack();
    
    // Create the root item
    __ms.Push(__strMenuName);
    // Remove menu with the same name if exist
    Response.Write(__ms.FreeTop() + "\n");
    Response.Write(__ms.CreateTop() + "\n");
    
    // Create holding item
    var __strCurrentName = AutoName();
    __ms.Push(__strCurrentName);
    Response.Write(__ms.CreateTop() + "\n");
    Response.Write("var " + __strMenuName + " = " + __ms.Top() + ";\n");
    
    // Open the file
    var __fso = Server.CreateObject("{F86AC6C2-5578-4AE8-808A-DC5DAA78082A}");
    if (!__fso.FileExists(__strMenuFile)) {
        Response.Write("// ERROR - menu file does not exist: \n  " + __strMenuFile + "\n");
    } else {
        var __f = __fso.OpenFile(__strMenuFile,0x10);
        if (!ParseMenuDefinition(__f)) {
            Response.Write("// ERRORS - compilation failed.\n");
        } else {
            Response.Write("// SUCCESS - compilation ok.\n");
        }    
    }
}
%>

    
    
