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
<h2>Open/Create database</h2>
<p>To open a database choose from File menu Open/Create database or click the
corresponding toolbar button.</p>
<p>On the Open/Create form enter the full path name of the database file name if
you want to create a new database or browse for an existing one if you want to
open it.</p>
<p>In-Memory database: To work in-memory leave the database file field empty.</p>

</body>

</html>
