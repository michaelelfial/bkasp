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
<h2>Cascaded deletion triggers</h2>
<p>What is this? In MS Access you can create relations between fields from
different tables and this way instruct the database that the records from one
table depend on records from another.</p>
<p>The cascaded deletion trigger allows you link two tables over two fields in
such a manner that if a record is deleted from the first table all the records
from the second table that have the same value in the linked field will be
automatically deleted.</p>
<p>To create cascaded deletion trigger choose Tools-&gt;Create cascaded deletion
trigger. Then choose a field from the 1-st table and then a field from the 2-nd.
This will link for automatic deletion the records from the second table that
have the selected field equal to the field from the first table.</p>

</body>

</html>
