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
<h2>SQL Features That SQLite Does Not Implement</h2>
<p>Rather than try to list all the features of SQL92 that SQLite does support,
it is much easier to list those that it does not. Unsupported features of SQL92
are shown below.</p>
<p>The order of this list gives some hint as to when a feature might be added to
SQLite. Those features near the top of the list are likely to be added in the
near future. There are no immediate plans to add features near the bottom of the
list.</p>
<table cellPadding="10">
  <tbody>
    <tr>
      <td vAlign="top"><b><nobr>FOREIGN KEY constraints</nobr></b></td>
      <td width="10">&nbsp;
      <td vAlign="top">FOREIGN KEY constraints are parsed but are not enforced.</td>
    </tr>
    <tr>
      <td vAlign="top"><b><nobr>Complete trigger support</nobr></b></td>
      <td width="10">&nbsp;
      <td vAlign="top">There is some support for triggers but it is not
        complete. Missing subfeatures include FOR EACH STATEMENT triggers
        (currently all triggers must be FOR EACH ROW), INSTEAD OF triggers on
        tables (currently INSTEAD OF triggers are only allowed on views), and
        recursive triggers - triggers that trigger themselves.</td>
    </tr>
    <tr>
      <td vAlign="top"><b><nobr>Complete ALTER TABLE support</nobr></b></td>
      <td width="10">&nbsp;
      <td vAlign="top">Only the RENAME TABLE and ADD COLUMN variants of the
        ALTER TABLE command are supported. Other kinds of ALTER TABLE operations
        such as DROP COLUMN, ALTER COLUMN, ADD CONSTRAINT, and so forth are
        omitted.</td>
    </tr>
    <tr>
      <td vAlign="top"><b><nobr>Nested transactions</nobr></b></td>
      <td width="10">&nbsp;
      <td vAlign="top">The current implementation only allows a single active
        transaction.</td>
    </tr>
    <tr>
      <td vAlign="top"><b><nobr>RIGHT and FULL OUTER JOIN</nobr></b></td>
      <td width="10">&nbsp;
      <td vAlign="top">LEFT OUTER JOIN is implemented, but not RIGHT OUTER JOIN
        or FULL OUTER JOIN.</td>
    </tr>
    <tr>
      <td vAlign="top"><b><nobr>Writing to VIEWs</nobr></b></td>
      <td width="10">&nbsp;
      <td vAlign="top">VIEWs in SQLite are read-only. You may not execute a
        DELETE, INSERT, or UPDATE statement on a view. But you can create a
        trigger that fires on an attempt to DELETE, INSERT, or UPDATE a view and
        do what you need in the body of the trigger.</td>
    </tr>
    <tr>
      <td vAlign="top"><b><nobr>GRANT and REVOKE</nobr></b></td>
      <td width="10">&nbsp;
      <td vAlign="top">Since SQLite reads and writes an ordinary disk file, the
        only access permissions that can be applied are the normal file access
        permissions of the underlying operating system. The GRANT and REVOKE
        commands commonly found on client/server RDBMSes are not implemented
        because they would be meaningless for an embedded database engine.</td>
    </tr>
  </tbody>
</table>

</body>

</html>
