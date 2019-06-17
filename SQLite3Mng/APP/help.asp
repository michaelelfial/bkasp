<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>EULA</title>
<link rel=stylesheet href="/styles.css" type="text/css">
<SCRIPT>
    function onInitPage() {
        top.frames["DBManT"].document.frames["DBManT2"].location = "/toolbar2-help.asp?Topic=<%= Request.ServerVariables("SCRIPT_NAME") %>";
    }
    function onUninitPage() {
        top.frames["DBManT"].document.frames["DBManT2"].location = "/toolbar2.asp";
    }
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onLoad="onInitPage()" onUnload="onUninitPage()">
<h2>newObjects SQLite Database Manager help</h2>
<blockquote>
    <%
    Set cfg = cf.Read(Server.MapPath("/help.cfg"))
    For I = 1 To cfg.Count
    %>
    <B><A HREF="<%= cfg.Key(I) %>"><%= cfg(I)(1) %></A></B><BR>
    <%
    Next
    %>
</blockquote>
</body>

</html>
