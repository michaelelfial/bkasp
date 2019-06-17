<!-- #include file="common.asp" -->
<%
    Table = CStr(Request("Object"))
    RecCount = 40
    If Request("RecCount").Count > 0 Then RecCount = CLng(Request("RecCount"))
    RecBegin = 1
    If Request("RecBegin").Count > 0 Then RecBegin = CLng(Request("RecBegin"))
    TotalRecords = 0
    If Request("TotalRecords").Count > 0 Then TotalRecords = CLng(Request("TotalRecords"))
    Msg = ""
    Img = ""
    If Request("Msg").Count > 0 Then Msg = CStr(Request("Msg"))
    If Request("Img").Count > 0 Then Img = CStr(Request("Img"))
%>
<html>

<head>
<% LangMetaTag %>
<title>Toolbar</title>
<link rel=stylesheet href="/stylestb.css" type="text/css">
<base target="DBManM">
<SCRIPT>
    function GetPageSize() {
        var frm = document.forms["TBForm"];
        return parseFloat(frm.RecCount.options[frm.RecCount.selectedIndex].value);
    }
    function OnGo(x) {
        var frm = document.forms["TBForm"];
        switch (x) {
            case "first":
                frm.RecBegin.value = 1;
                break;
            case "pageback":
                if ((parseFloat(frm.RecBegin.value) - GetPageSize()) < 1) {
                    frm.RecBegin.value = 1;
                } else {
                    frm.RecBegin.value = parseFloat(frm.RecBegin.value) - GetPageSize();
                }
                break;
            case "recback":
                if ((parseFloat(frm.RecBegin.value) - 1) < 1) {
                    frm.RecBegin.value = 1;
                } else {
                    frm.RecBegin.value = parseFloat(frm.RecBegin.value) - 1;
                }
                break;
            case "last":
                frm.RecBegin.value = <%= TotalRecords %>;
                break;
            case "pagefwd":
                if ((parseFloat(frm.RecBegin.value) + GetPageSize()) > <%= TotalRecords %>) {
                    frm.RecBegin.value = <%= TotalRecords %>;
                } else {
                    frm.RecBegin.value = parseFloat(frm.RecBegin.value) + GetPageSize();
                }
                break;
            case "recfwd":
                if ((parseFloat(frm.RecBegin.value) + 1) > <%= TotalRecords %>) {
                    frm.RecBegin.value = <%= TotalRecords %>;
                } else {
                    frm.RecBegin.value = parseFloat(frm.RecBegin.value) + 1;
                }
                break;
                
        }
        frm.submit();
    }
    function TransferPositions() {
        // Deal with the areas
        var doc = top.frames["DBManM"].document;
        var i;
        var o;
        var s = "";
        var ob = doc.body;
        for (i = 1; doc.all("Chdr" + i) != null; i++) {
            // alert (typeof(document.all("X" + TypeKey + i)));
            o = doc.all("Chdr" + i);
            s += o.clientWidth + ",";
        }
        document.forms["TBForm"].ColWidths.value = s;
    }
    function SaveWidths() {
        var frm = document.forms["TBForm"];
        TransferPositions();
        frm.submit();
    }
    
</SCRIPT>
</head>
<body BGCOLOR="buttonface" text="buttontext" topmargin="0" leftmargin="0">
<TABLE CELLPADDING="0" CELLSPACING="0" HEIGHT="100%" WIDTH="100%"><TR>
    <FORM NAME="TBForm" METHOD="GET" ACTION="table.asp">
    <INPUT TYPE="HIDDEN" NAME="Object" VALUE="<%= Table %>">
    <INPUT TYPE="HIDDEN" NAME="ColWidths" VALUE="">
    <TD VALIGN="MIDDLE" NOWRAP STYLE="border: 1px inset">&nbsp;</TD>
    <TD VALIGN="MIDDLE" NOWRAP><INPUT TYPE="SUBMIT" VALUE="Show"></TD>
    <TD VALIGN="MIDDLE" NOWRAP><SELECT NAME="RecCount">
        <% For I = 40 To 200 Step 20 %>
            <% If RecCount = I Then %>
                <OPTION SELECTED VALUE="<%= I %>"><%= I %></OPTION>
            <% Else %>
                <OPTION VALUE="<%= I %>"><%= I %></OPTION>
            <% End If %>
        <% Next %>
    </SELECT></TD>
    <TD VALIGN="MIDDLE" NOWRAP>&nbsp;records&nbsp;</TD>
    <TD VALIGN="MIDDLE" NOWRAP STYLE="border: 1px inset">&nbsp;</TD>
    <TD VALIGN="MIDDLE" NOWRAP><IMG ALT="First record" SRC="first.gif" BORDER="0" hspace="1" vspace="1" onClick="OnGo('first')" STYLE="cursor: hand"></TD>
    <TD VALIGN="MIDDLE" NOWRAP><IMG ALT="Page Back" SRC="lpage.gif" BORDER="0" hspace="1" vspace="1" onClick="OnGo('pageback')" STYLE="cursor: hand"></TD>
    <TD VALIGN="MIDDLE" NOWRAP><IMG ALT="One record back" SRC="lone.gif" BORDER="0" hspace="1" vspace="1" onClick="OnGo('recback')" STYLE="cursor: hand"></TD>
    <TD VALIGN="MIDDLE" NOWRAP><INPUT TITLE="Current record" TYPE="TEXT" SIZE="5" NAME="RecBegin" VALUE="<%= RecBegin %>"></TD>
    <TD VALIGN="MIDDLE" NOWRAP><IMG ALT="One record forward" SRC="rone.gif" BORDER="0" hspace="1" vspace="1" onClick="OnGo('recfwd')" STYLE="cursor: hand"></TD>
    <TD VALIGN="MIDDLE" NOWRAP><IMG ALT="Page forward" SRC="rpage.gif" BORDER="0" hspace="1" vspace="1" onClick="OnGo('pagefwd')" STYLE="cursor: hand"></TD>
    <TD VALIGN="MIDDLE" NOWRAP><IMG ALT="Last record" SRC="last.gif" BORDER="0" hspace="1" vspace="1" onClick="OnGo('last')" STYLE="cursor: hand"></TD>
    <TD VALIGN="MIDDLE" NOWRAP><INPUT TYPE="BUTTON" VALUE="Save column widths" onClick="SaveWidths()"></TD>
    
    <% If Img <> "" Or Msg <> "" Then %>
        <TD WIDTH="100%" VALIGN="MIDDLE" NOWRAP BGCOLOR="buttonhighlight">
        <DIV STYLE="width: 100%; height: 24px;overflow: hidden">
        <% If Img <> "" Then %>
            <IMG SRC="<%= Img %>" ID="MsgImage>
        <% End If %>
        <% If Msg <> "" Then %>
            <SPAN ID="MsgText"><%= Msg %></SPAN>
        <% End If %>
        </DIV>
        </TD>
    <% Else %>
        <TD WIDTH="100%" VALIGN="MIDDLE" NOWRAP>
        &nbsp;
        </TD>
    <% End If %>
    </FORM>
</TR></TABLE>
</body>

</html>
