<%



Sub HtmlBoxGenerateMainScript(sKey, appData)
%>
<script type="text/javascript">
/**
    Utilities
*/
var htmlBox_Handlers = new Array();
function htmlBox_AddHandler(handler, oldhandler,preHandler, param) {
    var args = "(";
    if (param != null) args += "\"" + param + "\"";
    args += ")"
    if (oldhandler != null) {
        htmlBox_Handlers[htmlBox_Handlers.length] = oldhandler;
        // Create argument list
        if (preHandler == null || !preHandler) {
            return function() {
               htmlBox_Handlers[htmlBox_Handlers.length - 1]();
               var f = new Function(handler + args);
               f();
            };
        } else {
            return function() {
               var f = new Function(handler + args);
               f();
               htmlBox_Handlers[htmlBox_Handlers.length - 1]();
            };
        }
    } else {
        return function() {
           var f = new Function(handler + args);
           f();
        };
    }
}
function htmlBox_SplitControlNames(controlNames) {
    if (controlNames == null) return null;
    var parts = controlNames.split(",");
    if (parts.length >= 2) {
        var o = {
            fieldName: parts[0],
            frameName: parts[1]
        };
        return o;
    }
    return null;
}
function htmlBox_ParentForm1(o) {
    var cur = o;
    while (cur != null) {
        if (cur.tagName.toUpperCase() == "FORM") return cur;
        cur = cur.parentElement;
    }
    return null;
}
function htmlBox_ParentForm(o) {
    // Find the iframe
    var ifrms = document.all.tags("iframe");
    var cur = ifrms[o.name];
    while (cur != null) {
        if (cur.tagName.toUpperCase() == "FORM") return cur;
        cur = cur.parentElement;
    }
    return null;
}

var htmlBox_ProcessedBoxes = new Object();
function htmlBox_initBox(controlNames) {
    
    var names = htmlBox_SplitControlNames(controlNames);
    if (htmlBox_ProcessedBoxes[names.frameName]) return;
    var ifrm = document.frames[names.frameName];
    if (ifrm == null) return;
    htmlBox_ProcessedBoxes[ifrm.name] = true;
	var frm = htmlBox_ParentForm(ifrm);
    var sHTML = ""
    // The initialization HTML
	sHTML += ""
		+ "<STYLE>"
		+ htmlBox_BoxesOnThePageStyle[names.fieldName]
		+ "</STYLE>"
		+ "<BODY ONCONTEXTMENU=\"return false\">"
		+	"<P></P>"
		+ "</BODY>";
    
	
	if (names != null && frm != null) {
        ifrm.document.designMode = "on";
        ifrm.document.open("text/html","replace");
        ifrm.document.write(sHTML);
        ifrm.document.close();
        if (frm.all[names.fieldName].value != "") ifrm.document.body.innerHTML = frm.all[names.fieldName].value;
    }
    frm.onsubmit = htmlBox_AddHandler("htmlBox_doSubmitBox",frm.onsubmit,true,controlNames);
}
function htmlBox_doSubmitBox(controlNames) {
    var frm = event.srcElement;
    var names = htmlBox_SplitControlNames(controlNames);
    if (names == null) return;
    var ifrm = document.frames[names.frameName];
    var ctl = frm.all[names.fieldName];
    ctl.value = ifrm.document.body.innerHTML;
}
// Requires an array htmlBox_BoxesOnThePage pairs "fieldName,frameName"
function htmlBox_initPage() {
    if (typeof(htmlBox_BoxesOnThePage) == "undefined") return;
    var ctlnames;
    for (ctlnames in htmlBox_BoxesOnThePage) {
        htmlBox_initBox(htmlBox_BoxesOnThePage[ctlnames]);
    } 
}
</script>
<%
End Sub

Class CHtmlBox
    Public Name
    Public Value
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public pInnerCss
    Public ClientId
    Public Width
    Public Height
    Private Rendered
    Public Border
    Public SkinId
    
    ' Client Ids for toolbars
    Public BaseFromattingToolbarClientId
    Public AdvancedFromattingToolbarClientId
    Public ObjectsToolbarClientId
    
    Private Sub Class_Initialize
        ClientScripts.RegisterProcedure "ASPCTLHtmlBox", "HtmlBoxGenerateMainScript", Empty
        ClientScripts.RegisterInitializer "ASPCTLHtmlBox", "htmlBox_initPage()"
        If IsEmpty(ClientScripts.Block("ASPCTLHtmlBox")) Then
            ClientScripts.AppendToBlock "ASPCTLHtmlBox", "var htmlBox_BoxesOnThePage = new Array();"
        End If
        Dim o
        Set o = ClientScripts.ScriptArray("htmlBox_BoxesOnThePageStyle")
        pInnerCss = "BODY {border: 1px inset; margin: 1pt;}"
    End Sub
    
    Sub Init(n)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        BaseFromattingToolbarClientId = NewClientId()
        AdvancedFromattingToolbarClientId = NewClientId()
        ObjectsToolbarClientId = NewClientId()
        
        Value = CStr(ASPALL(Me.Name))
        Rendered = False
        ClientScripts.AppendToBlock "ASPCTLHtmlBox", "htmlBox_BoxesOnThePage[htmlBox_BoxesOnThePage.length] = """ & Name & "," & FrameName & """;"
        ClientScripts.ScriptArray("htmlBox_BoxesOnThePageStyle")(Name) = JSEscape(pInnerCss)
        ClientScripts.RegisterFile "aspctl_htmlBoxTb", ASPCTLPath & "htmlboxtoolbar.js"
    End Sub
    
    Public Property Get InnerCss
        InnerCss = pInnerCss
    End Property
    Public Property Let InnerCss(s)
        pInnerCss = s
        ClientScripts.ScriptArray("htmlBox_BoxesOnThePageStyle")(Name) = JSEscape(pInnerCss)
    End Property
    Public Property Get FrameName
        FrameName = Me.Name & "_IFRM"
    End Property
    
    Public Property Get ClassType
        ClassType = "CHtmlBox"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub Render
        Dim s
        s = "<input type=""hidden"" name=""" & Me.Name & """ value=""" & Server.HTMLEncode(Me.Value) & """>"
        s = s & "<iframe name=""" & FrameName & """"
        s = s & " id=""" & Me.FrameName & """"
        If Not IsEmpty(Me.Border) Then s = s & " FRAMEBORDER=""" & Me.Border & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Width) Then Style = "width: " & Me.Width & ";" & Style
        If Not IsEmpty(Me.Height) Then Style = "height: " & Me.Height & ";" & Style
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        s = s & RenderAttributes(pAttributes)
        s = s & ">"
        s = s & "</iframe>"
        Response.Write s
        Rendered = True
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & "=" & Me.Value
        Else
            HttpGetParams = ""
        End If
    End Property
    
    ' Toolbars (optionally rendered)
    Public Sub RenderBaseFromattingToolbar(tbMode)
        Dim s, noWrap, nWidth, nVert, nSep
        Select Case UCase(ConvertTo(vbString,tbMode))
            Case "VERTICAL"
                noWrap = ""
                nVert = "</tr><tr>" & vbCrLf
                nSep = "<td height=""2px""></td>" & vbCrLf
            Case "SQUARE"
                noWrap = " nowrap "
                nVert = ""
                nSep = "</tr><tr>"
            Case Else
                noWrap = " nowrap "
                nVert = ""
                nSep = "<td>&nbsp;</td>" & vbCrLf
        End Select
        
        s = s & "<table id=""" & BaseFromattingToolbarClientId & """ cellpadding=""0"" cellspacing=""0"" border=""0""><tr>" & vbCrLf
        s = s & "<td><button type=""button""  onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','cut')""><img src=""" & ASPCTLPath & "img/cut.gif"" border=""0"" alt=""" & ResourceText("cut") & """></button></td>" & vbCrLf
        s = s & nVert
        s = s & "<td><button type=""button""  onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','copy')""><img src=""" & ASPCTLPath & "img/copy.gif"" border=""0"" alt=""" & ResourceText("copy") & """></button></td>" & vbCrLf
        s = s & nVert
        s = s & "<td><button type=""button""  onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','paste')""><img src=""" & ASPCTLPath & "img/paste.gif"" border=""0"" alt=""" & ResourceText("paste") & """></button></td>" & vbCrLf
        s = s & nVert
        s = s & nSep
        s = s & nVert
        s = s & "<td><button type=""button"" onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','bold')""><img src=""" & ASPCTLPath & "img/bold.gif"" border=""0"" alt=""" & ResourceText("bold") & """></button></td>" & vbCrLf
        s = s & nVert
        s = s & "<td><button type=""button""  onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','italic')""><img src=""" & ASPCTLPath & "img/italic.gif"" border=""0"" alt=""" & ResourceText("italic") & """></button></td>" & vbCrLf
        s = s & nVert
        s = s & "<td><button type=""button""  onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','underline')""><img src=""" & ASPCTLPath & "img/underline.gif"" border=""0"" alt=""" & ResourceText("underline") & """></button></td>" & vbCrLf
        s = s & nVert
        s = s & nSep
        s = s & nVert
        s = s & "<td><button type=""button""  onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','justify','left')""><img src=""" & ASPCTLPath & "img/left.gif"" border=""0"" alt=""" & ResourceText("left") & """></button></td>" & vbCrLf
        s = s & nVert
        s = s & "<td><button type=""button""  onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','justify','center')""><img src=""" & ASPCTLPath & "img/center.gif"" border=""0"" alt=""" & ResourceText("center") & """></button></td>" & vbCrLf
        s = s & nVert
        s = s & "<td><button type=""button""  onClick=""htmlBox_doTbCmd('" & Me.FrameName & "','justify','right')""><img src=""" & ASPCTLPath & "img/right.gif"" border=""0"" alt=""" & ResourceText("right") & """></button></td>" & vbCrLf
        s = s & "</tr></table>" & vbCrLf
        Response.Write s
    End Sub
    
    Public Sub RenderAdvancedFormattingToolbar(tbMode)
        
    End Sub
    

End Class

Function Create_CHtmlBox(controlName)
    Set Create_CHtmlBox = InitControl(New CHtmlBox,True,controlName)
End Function

%>