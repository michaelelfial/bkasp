<!-- #include file="common.asp" -->
<%
    Topic = CStr(Request("Topic"))
    Set cfg = cf.Read(Server.MapPath("/help.cfg"))
%>
<html>

<head>
<% LangMetaTag %>
<title>Toolbar</title>
<link rel=stylesheet href="/stylestb.css" type="text/css">
<base target="DBManM">
<SCRIPT>
    function OnGo() {
        var frm = document.forms["TBForm"];
        top.frames["DBManM"].location = frm.TopicSel.options[frm.TopicSel.selectedIndex].value;
    }
</SCRIPT>
</head>
<body BGCOLOR="buttonface" text="buttontext" topmargin="0" leftmargin="0">
<TABLE CELLPADDING="0" CELLSPACING="0" HEIGHT="100%" WIDTH="100%"><TR>
    <FORM NAME="TBForm">
    
    <TD VALIGN="MIDDLE" NOWRAP STYLE="border: 1px inset">&nbsp;</TD>
    <TD VALIGN="MIDDLE" NOWRAP>&nbsp;Topic&nbsp;</TD>
    <TD VALIGN="MIDDLE" NOWRAP><SELECT NAME="TopicSel"onChange="OnGo()">
        <% For I = 1 To cfg.Count %>
            <% If cfg.Key(I) = Topic Then %>
                <OPTION SELECTED VALUE="<%= cfg.Key(I) %>"><%= cfg(I)(1) %></OPTION>
            <% Else %>
                <OPTION VALUE="<%= cfg.Key(I) %>"><%= cfg(I)(1) %></OPTION>
            <% End If %>
        <% Next %>
    </SELECT></TD>
    <TD WIDTH="100%" VALIGN="MIDDLE" NOWRAP>&nbsp;</TD>
    </FORM>
</TR></TABLE>
</body>

</html>
