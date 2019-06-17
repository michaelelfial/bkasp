<!-- #include file="common.asp" -->
<%
    If Request("Enc").Count > 0 Then
        Dim cst
        cst = CStr(Request("Charset"))
        Session("Charset") = cst
        If cst <> "" Then
            Session.CodePage = DBManCfg("CHARSET")(cst)("CodePage")
        Else
            Session.CodePage = 0
        End If
    End If
%>
<html>

<head>
<% LangMetaTag %>
<link rel=stylesheet href="/styles.css" type="text/css">
<title>Welcome</title>
</head>

<body topmargin="2" leftmargin="2">


<h1><i><font color="#C0C0C0">Welcome to SQLite</font><font color="#808080">3</font><font color="#C0C0C0"> DB Manager</font></i></h1>

<p>
<div align="right">
  <table border="0" style="border: 1 solid #000000" bgcolor="#FFFFF0" cellspacing="1" align="right">
    <tr>
      <td width="100%"><img border="0" src="Sqlite.gif"></td>
    </tr>
    <tr>
      <th width="100%" nowrap bgcolor="#F5F1D6">Common tasks</th>
    </tr>
    <tr>
      <td width="100%"><a href="open.asp"><img border="0" src="of.gif">
        Open/Create database</a>&nbsp;
        <% If db.IsOpened Then %>
        <a href="deftable.asp"><br>
        <img border="0" src="table.gif"> Design a table</a>&nbsp;<br>
        <a href="dbscheme.asp"><img border="0" src="dbstruct.gif"> See the DB
        structure</a>&nbsp;<br>
        <a href="impexp.asp"><img border="0" src="impexp.gif"> Import/Export
        data</a>
        <br>
        <a href="sqlconsole.asp"><img border="0" src="console.gif"> Run a query</a>
        <% End If %>
        <br>
        <a href="help.asp"><img border="0" src="help.gif">
        Help and SQL language reference</a>
        </td>
    </tr>
  </table>
</div>

This application is designed
for ALP 1.2 and above and Internet Explorer 5.5 or above. However, it will work correctly
on any IE version beginning with IE 4 with some visual features unavailable. None of these features is absolutely crucial.

<FORM METHOD="POST" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
    <p><b><i>User interface encoding:</i></b></p>
    <select size="1" name="Charset">
        <option value="">(System default)</option>
        <% For I = 1 To DBManCfg("CHARSET").Count %>
            <% If DBManCfg("CHARSET").Key(I) = Session("Charset") Then %>
                <option SELECTED value="<%= DBManCfg("CHARSET").Key(I) %>"><%= DBManCfg("CHARSET")(I)("Name") %></option>
            <% Else %>
                <option value="<%= DBManCfg("CHARSET").Key(I) %>"><%= DBManCfg("CHARSET")(I)("Name") %></option>
            <% End If %>
        <% Next %>
    </select>
    <input type="submit" value="Submit" name="Enc"><br>
<i>The database stores text in UTF-8</i> and is not locale dependent internally. However, you may not be able to see/enter the
correct characters in the manager if the code page is not correct. It is still recommended to use the manager to edit textual data only 
in the locale selected in the Control panel of your system. 
</FORM>
<p>&nbsp;</p>

<p><b>Quick information about the DB manager</b></p>

<p>This application uses context menus for many operations. The left panel displays the DB contents, you can right click on any of the objects
or left-click over its icon to see the actions applicable to the object. </p>

<p><b>Composing SQL</b>. Wherever SQL statements are allowed you can right click
in them and select a function, keyword or other element from the context menu
and insert it in the SQL source. </p>

<p>DB manager supports and uses newObjects ActiveX Pack1 2.5 or later. The database manager expects SQLite engine and interface implemented by
<b>newObjects SQLite3 COM</b> component (part of ActiveX Pack1 2.5 and above) which embeds a 3.3.5.0 (or later) SQLite3 DB engine with OLE DATE 
management SQL functions and session variable functions add-on. The required version of SQLite3 COM is included with ActiveX Pack1 2.5 and above - no need 
to check the DLL separately if you have appropriate version of the pack installed.
</p>

<p>For more information about SQLite database engine itsef please visit the <b><a href="http://www.sqlite.org">SQLite
WEB site</a></b>.</p>


<p>The DB Manager is implemented entirely in ASP with some DHTML enhancements.
It uses one composite object which is also left in plain source form using very simple coding techniques. </p>


</body>

</html>
