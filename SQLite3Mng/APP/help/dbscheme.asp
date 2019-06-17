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
<h2>Database scheme diagram</h2>
<p>On the database scheme diagram you can see the graphical representations of
all the database objects. Almost all the operations can be invoked from there -
Click the icon of an object to open the action menu for it.</p>
<p>The tables and the views can be arranged by dragging them (click and drag the
caption of the object). This way you can position the objects in manner that
corresponds to their functionality. </p>

</body>

</html>
