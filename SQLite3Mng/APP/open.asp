<!-- #include file="common.asp" -->
<%
If Request("DBFILE").Count > 0 Then
    db.Close
    On Error Resume Next
    db.Open Request("DBFILE")
    b = True
    If Err.Number <> 0 Then
        b = False
    Else
        Session("ShowTables") = 1
        Session("ShowIndices") = 0
        Session("ShowViews") = 0
        Session("ShowTriggers") = 0
        
        Set r = db.Execute("SELECT * FROM SysDBMan_SessionParams")
        For I = 1 To r.Count
            db.Parameters.Add r(I)("ParamName"), r(I)("ParamVal")
        Next
        
        If Len(Request("DBFILE")) > 0 Then
            dbmandata.VExecute "DELETE FROM Recent WHERE PATH=$Path", 1, 0, CStr(Request("DBFILE"))
            dbmandata.VExecute "INSERT INTO Recent (PATH,DATETIME) VALUES ($Path,$Date)", 1, 0, CStr(Request("DBFILE")), Now
        End If
        
    End If
    %>
    <html>

    <head>
    <% LangMetaTag %>
    <link rel=stylesheet href="/styles.css" type="text/css">
    <title>Table</title>
    <SCRIPT>
        function ReloadAll() {
            <% If b Then %>
            window.top.location = "/";
            <% End If %>
        }
    </SCRIPT>
    </head>
    
    <body topmargin="0" leftmargin="0" onLoad="ReloadAll()">
    <table WIDTH="100%" HEIGHT="100%" border="0" cellspacing="1">
      <tr>
        <TD WIDTH="100%" HEIGHT="100%" VALIGN="MIDDLE" ALIGN="CENTER">
            <% If b Then %>
                Opened: <%= Request("DBFILE") %>
            <% Else %>
                Error: <%= db.LastError %>
            <% End If %>
        </TD>
      </tr>
    </table>
    
    </body>
    
    </html>
    <%
Else
    If Request("DelRecent").Count > 0 Then
        dbmandata.VExecute "DELETE FROM Recent WHERE ID=$Id",1,0, CLng(Request("DelRecent"))
    ElseIf Request("ClearRecent").Count > 0 Then
        dbmandata.Execute "DELETE FROM Recent"
    End If
%>
<html>

<head>
<% LangMetaTag %>
<link rel=stylesheet href="/styles.css" type="text/css">
<title>Table</title>
<SCRIPT>
    function onShortcutMenu() {
        if (event.button != 2) return;
        external.DisplayPopupMenu(external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuEdit"),event.screenX,event.screenY);
    }
    function openDBFile() {
        var s = external.FileDialog(false,"","SQLite3 databases|*.db;*.sqlite;*.sqlite3|All files|*.*","Open database","");
        if (s.length > 0) {
            document.forms[0].DBFILE.value = s;
            document.forms[0].submit();
        }
    }
    function createDBFile() {
        var s = external.FileDialog(true,"","SQLite3 databases|*.db;*.sqlite;*.sqlite3|All files|*.*","Open/Create database","sqlite3");
        if (s.length > 0) {
            document.forms[0].DBFILE.value = s;
            document.forms[0].submit();
        }
    }
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onMouseUp="onShortcutMenu()">
<table WIDTH="100%" HEIGHT="100%" border="0" cellspacing="1">
  <tr>
    <TD WIDTH="100%" VALIGN="MIDDLE" ALIGN="CENTER">
        <H3>Open/Create database</H3>
        <FORM METHOD="POST" ACTION="<%= Self %>">
            <I>Enter the full path name of the DB file you want to open or create or click browse to choose an existing file. If the database you specify does not exist it will be created.</I>
            <BR>
            <I>Leave empty and click Open to open an in-memory database (note that an in-memory database will be lost once you close the manager or open another!)</I>
            <BR>
            <INPUT TYPE="TEXT" SIZE="40" NAME="DBFILE">
            <INPUT TYPE="BUTTON" onclick="openDBFile()" VALUE="Open">
            <INPUT TYPE="BUTTON" onclick="createDBFile()" VALUE="Create">
            <HR COLOR="0" SIZE="1" WIDTH="200">
            <INPUT style="width:200" TYPE="SUBMIT" VALUE="Open/Create">
        </FORM>
    </TD>
  </tr>
  <tr>
    <TD WIDTH="100%" HEIGHT="80%" VALIGN="MIDDLE" ALIGN="CENTER">
        <B>Recent databases</B>
        <DIV style="width: 100%; height: 80%; overflow-y: auto;">
            <TABLE BORDER="0" WIDTH="100%" CELLPADDING="1" CELLSPACING="1" style="border: 1 solid #000000" bgcolor="#FFFFF0">
                <TR>
                        <TH NOWRAP bgcolor="#F5F1D6">
                            &nbsp;
                        </TH>
                        <TH NOWRAP bgcolor="#F5F1D6">
                            Database
                        </TH>
                        <TH NOWRAP bgcolor="#F5F1D6">
                            Date/Time
                        </TH>
                </TR>
                <% 
				On Error Resume Next
                Set recent = dbmandata.Execute("SELECT * FROM Recent ORDER BY DATETIME DESC LIMIT 100")
				If Err.Number = 0 Then
					For I = 1 To recent.Count %>
						<TR>
							<TD NOWRAP>
								<A HREF="open.asp?DelRecent=<%= recent(I)("ID") %>"><IMG BORDER="0" SRC="del.gif" ALT="Remove from the list"></A>
							</TD>
							<TD NOWRAP>
								<A HREF="open.asp?DBFILE=<%= recent(I)("PATH") %>"><%= recent(I)("PATH") %></A>
							</TD>
							<TD NOWRAP>
								<%= su.Sprintf("%lT",recent(I)("DATETIME")) %>
							</TD>
						</TR>
					<% Next %>
				<% End If %>
            </TABLE>
        </DIV>
        <% If recent.Count > 0 Then %>
            <A HREF="open.asp?ClearRecent=1">Clear the list of the recently used databases</A>
        <% End If %>
    </TD>
  </tr>
</table>

</body>

</html>
<% End If %>