<!-- #include file="common.asp" -->
<%
If db.IsOpened Then    
    Message = ""
    bJustStarted = False
    If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
        If Not thread.Busy Then
            thread.Stop
            thread.Value("Complete") = False
            thread.Value("db") = db
            If Request("ExpPlain").Count > 0 Then
                tofile = CStr(Request("FILE"))
                If tofile <> "" Then
                    thread.Value("Operation") = "Export table to text file"
                    thread.Value("File") = tofile
                    thread.Value("Delimiter") = CStr(Request("Delimiter"))
                    thread.Value("Table") = CStr(Request("TABLE"))
                    Set file = sf.OpenFile(Server.MapPath("ExpTableToText.vbs"),&H40)
                    If Not thread.Start("VBScript",file.ReadText(-2)) Then
                        Message = "Error starting the task: " & thread.LastError
                    Else
                        Message = "Task started."
                        bJustStarted = True
                    End If                    
                    file.Close
                Else
                    Message = "Please specify file name"
                End If                    
            ElseIf Request("ExpTableToMDB").Count > 0 Then
                tofile = CStr(Request("FILE"))
                If tofile <> "" Then
                    thread.Value("Operation") = "Export table to MS Access MDB file"
                    thread.Value("File") = tofile
                    thread.Value("Table") = CStr(Request("TABLE"))
                    thread.Value("ColTypes") = CStr(Request("ColTypes"))
                    Set file = sf.OpenFile(Server.MapPath("ExpTableToMDB.vbs"),&H40)
                    If Not thread.Start("VBScript",file.ReadText(-2)) Then
                        Message = "Error starting the task: " & thread.LastError
                    Else
                        Message = "Task started."
                        bJustStarted = True
                    End If                    
                    file.Close
                Else
                    Message = "Please slect a MDB file to export to"
                End If                    
            ElseIf Request("ExpToMDB").Count > 0 Then
                tofile = CStr(Request("FILE"))
                If tofile <> "" Then
                    thread.Value("Operation") = "Export the entire DB to MS Access MDB file"
                    thread.Value("File") = tofile
                    Set file = sf.OpenFile(Server.MapPath("ExpToMDB.vbs"),&H40)
                    If Not thread.Start("VBScript",file.ReadText(-2)) Then
                        Message = "Error starting the task: " & thread.LastError
                    Else
                        Message = "Task started."
                        bJustStarted = True
                    End If                    
                    file.Close
                Else
                    Message = "Please slect a MDB file to export to"
                End If
            ElseIf Request("ExpSchema").Count > 0 Then
                tofile = CStr(Request("FILE"))
                If tofile <> "" Then
                    thread.Value("Operation") = "Export the schema to a text file"
                    thread.Value("File") = tofile
                    Set file = sf.OpenFile(Server.MapPath("ExpSchema.vbs"),&H40)
                    If Not thread.Start("VBScript",file.ReadText(-2)) Then
                        Message = "Error starting the task: " & thread.LastError
                    Else
                        Message = "Task started."
                        bJustStarted = True
                    End If                    
                    file.Close
                Else
                    Message = "Please slect an output file."
                End If
            ElseIf Request("ImpSQLite2").Count > 0 Then
                fromfile = CStr(Request("FILE"))
                If fromfile <> "" Then
                    thread.Value("Operation") = "Import SQLite2 database"
                    thread.Value("File") = fromfile
                    Set file = sf.OpenFile(Server.MapPath("ImpSQLite2.vbs"),&H40)
                    If Not thread.Start("VBScript",file.ReadText(-2)) Then
                        Message = "Error starting the task: " & thread.LastError
                    Else
                        Message = "Task started."
                        bJustStarted = True
                    End If                    
                    file.Close
                Else
                    Message = "Please specify file name"
                End If                    
            ElseIf Request("ImpSQLite3").Count > 0 Then
                fromfile = CStr(Request("FILE"))
                If fromfile <> "" Then
                    thread.Value("Operation") = "Import SQLite3 database"
                    thread.Value("File") = fromfile
                    Set file = sf.OpenFile(Server.MapPath("ImpSQLite3.vbs"),&H40)
                    If Not thread.Start("VBScript",file.ReadText(-2)) Then
                        Message = "Error starting the task: " & thread.LastError
                    Else
                        Message = "Task started."
                        bJustStarted = True
                    End If                    
                    file.Close
                Else
                    Message = "Please specify file name"
                End If                    
            ElseIf Request("ImpFromMDB").Count > 0 Then
                fromfile = CStr(Request("FILE"))
                If fromfile <> "" Then
                    thread.Value("Operation") = "Import MS Access MDB file"
                    thread.Value("File") = fromfile
                    thread.Value("Tables") = CStr(Request("Tables"))
                    Set file = sf.OpenFile(Server.MapPath("ImpMDB.vbs"),&H40)
                    If Not thread.Start("VBScript",file.ReadText(-2)) Then
                        Message = "Error starting the task: " & thread.LastError
                    Else
                        Message = "Task started."
                        bJustStarted = True
                    End If                    
                    file.Close
                Else
                    Message = "Please specify file name"
                End If                    
            End If
        Else
            If Request("StopThread").Count > 0 Then
                thread.Value("Stop") = True
                ' Wait the thread to see it and stop gracefully
                If thread.Wait(5000) Then
                    Message = "The thread stopped in response to the stop indicator"
                Else
                    Message = "The thread did not stop after 5 seconds. Use terminate to stop the thread."
                End If
                gnmThread.Value("Stop") = False
            End If
        End If
    End If
%>
<html>

<head>
<% LangMetaTag %>
<link rel=stylesheet href="/styles.css" type="text/css">
<% If thread.Busy Or bJustStarted Then %>
    <meta http-equiv="REFRESH" content="5">
<% End If %>
<title>Import/Export</title>
<script>
    function ChooseSchemaFile() {
        document.forms["ExpSchema"].FILE.value = external.FileDialog(true,"","SQL files|*.sql","Choose output file name","sql");
    }
</script>
</head>
<body>
    <H3>Import/Export tools</H3>
    <A HREF="<%= Request.ServerVariables("SCRIPT_NAME") %>"><B>Refresh</B></A><BR>
    <FONT COLOR="#FF0000"><%= Message %></FONT>
    <% If thread.Busy Then %>
        <TABLE WIDTH="100%" BGCOLOR="#E0F0E0"><TR><TD>
        <H4>Import/Export operation in progress</H4>
        Task: <B><%= thread.Value("Operation") %></B><BR>
        Progress/state: <B><%= thread.Value("Progress") %></B><BR>
        <FORM METHOD="POST" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
            <INPUT TYPE="SUBMIT" NAME="StopThread" VALUE="Stop current task">
        </FORM>
        It is not recommended to use the database while the task is in progress. The state will be updated every 5 secinds until the task completes.
        </TD></TR></TABLE>
    <% Else %>
    <% If Not IsEmpty(thread.Value("Complete")) Then %>
        <TABLE WIDTH="100%" BGCOLOR="#F0F0E0"><TR><TD>
        <H4>Last completed Import/Export task</H4>
        Task: <B><%= thread.Value("Operation") %></B><BR>
        <% If thread.Success Then %>
            Status: <B>Completed successfuly</B><BR>
            <B><%= thread.Value("Progress") %></B><BR>
            <A TARGET="DBManC" HREF="dbobjects.asp"><IMG ALT="Reload objects list" SRC="refresh.gif" BORDER="0" hspace="1" vspace="1">Reload objects list</A>
        <% Else %>
            Status: <B>Error</B><BR>
            Error text: <%= thread.LastError %><BR>
            Last task state indication: <B><%= thread.Value("Progress") %></B><BR>
        <% End If %>
        </TD></TR></TABLE>
    <% End If %>
    <TABLE WIDTH="100%">
    <TR>
    <TD VALIGN="TOP">
        <H4>Export</H4>
        <blockquote>
            <FORM METHOD="POST" STYLE="border: 1px solid green" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
                <TABLE>
                    <TR>
                        <TH COLSPAN="2">A table to a text file</TH>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">Table:</TD>
                        <TD VALIGN="TOP">
                            <SELECT NAME="TABLE">
                                <%
                                    Set r = db.Execute("SELECT name FROM sqlite_master WHERE type='table'")
                                    For I = 1 To r.Count
                                    %>
                                      <OPTION VALUE="<%= r(I)(1) %>"><%= r(I)(1) %></OPTION>  
                                    <%
                                    Next
                                %>
                            </SELECT>
                        </TD>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">File:</TD>
                        <TD VALIGN="TOP"><INPUT TYPE="TEXT" MAXLENGTH="255" NAME="FILE" VALUE=""><BR>
                        <I>Specify full path name.</I>
                        </TD>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">Delimiter:</TD>
                        <TD VALIGN="TOP">
                            <SELECT NAME="DELIMITER">
                                <OPTION VALUE=",">,</OPTION>
                                <OPTION VALUE=";">;</OPTION>
                                <OPTION VALUE="|">|</OPTION>
                                <OPTION VALUE="tab">tab</OPTION>
                            </SELECT>
                        </TD>
                    </TR>
                </TABLE>
                <INPUT TYPE="SUBMIT" NAME="ExpPlain" VALUE="Export">
            </FORM>
            Note that the Export MS Access will work only if the exported tables have at least one record. The export will fail 
            if a table with the same name as the exported table already exists in the MS Access database.
            <FORM METHOD="POST" STYLE="border: 1px solid green" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
                <TABLE>
                    <TR>
                        <TH COLSPAN="2">Single table to MS Access MDB</TH>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">Table:</TD>
                        <TD VALIGN="TOP">
                            <SELECT NAME="TABLE">
                                <%
                                    Set r = db.Execute("SELECT name FROM sqlite_master WHERE type='table'")
                                    For I = 1 To r.Count
                                    %>
                                      <OPTION VALUE="<%= r(I)(1) %>"><%= r(I)(1) %></OPTION>  
                                    <%
                                    Next
                                %>
                            </SELECT>
                        </TD>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">MDB File:</TD>
                        <TD VALIGN="TOP"><INPUT TYPE="FILE" NAME="FILE" VALUE=""><BR>
                        </TD>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">Column types (optional):</TD>
                        <TD VALIGN="TOP"><INPUT TYPE="TEXT" NAME="ColTypes" VALUE=""><BR>
                        <I>By default the exporter uses the typs in the first row to determine the column types in the MS Access table.
                        If you want to specify the MS Access column types explicitly - write them in this field (comma separated)</I>
                        </TD>
                    </TR>
                </TABLE>
                <INPUT TYPE="SUBMIT" NAME="ExpTableToMDB" VALUE="Export">
            </FORM>
            <FORM METHOD="POST" STYLE="border: 1px solid green" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
                <TABLE>
                    <TR>
                        <TH COLSPAN="2">The entire DB to MS Access MDB</TH>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">MDB File:</TD>
                        <TD VALIGN="TOP"><INPUT TYPE="FILE" NAME="FILE" VALUE=""><BR>
                        </TD>
                    </TR>
                </TABLE>
                <INPUT TYPE="SUBMIT" NAME="ExpToMDB" VALUE="Export">
            </FORM>
            <FORM METHOD="POST" STYLE="border: 1px solid green" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>" NAME="ExpSchema">
                <TABLE>
                    <TR>
                        <TH COLSPAN="2">The database schema to a text file</TH>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">Output file:</TD>
                        <TD VALIGN="TOP"><INPUT TYPE="TEXT" NAME="FILE" VALUE="">
                        <INPUT TYPE="BUTTON" VALUE="..." onClick="ChooseSchemaFile()">
                        <BR>
                        </TD>
                    </TR>
                </TABLE>
                <INPUT TYPE="SUBMIT" NAME="ExpSchema" VALUE="Export">
            </FORM>
        </blockquote>
    </TD>
    <TD VALIGN="TOP">
        <H4>Import</H4>
        <blockquote>
            <FORM METHOD="POST" STYLE="border: 1px solid green" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
                <TABLE>
                    <TR>
                        <TH COLSPAN="2">SQLite2 UTF-8 database</TH>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">SQLite2 DB file:</TD>
                        <TD VALIGN="TOP">
                            <INPUT TYPE="FILE" MAXLENGTH="64" NAME="FILE" VALUE="">
                        </TD>
                    </TR>
                </TABLE>
                <INPUT TYPE="SUBMIT" NAME="ImpSQLite2" VALUE="Import">
            </FORM>
            <FORM METHOD="POST" STYLE="border: 1px solid green" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
                <TABLE>
                    <TR>
                        <TH COLSPAN="2">SQLite3 UTF-8 database</TH>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">SQLite3 DB file:</TD>
                        <TD VALIGN="TOP">
                            <INPUT TYPE="FILE" NAME="FILE" VALUE="">
                        </TD>
                    </TR>
                </TABLE>
                <INPUT TYPE="SUBMIT" NAME="ImpSQLite3" VALUE="Import">
            </FORM>
            <FORM METHOD="POST" STYLE="border: 1px solid green" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
                <TABLE>
                    <TR>
                        <TH COLSPAN="2">MS Access MDB</TH>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">MDB File:</TD>
                        <TD VALIGN="TOP"><INPUT TYPE="FILE" NAME="FILE" VALUE="">
                        </TD>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">Tables:</TD>
                        <TD VALIGN="TOP"><INPUT TYPE="TEXT" NAME="Tables" VALUE=""> ex: T1,T2,T3<BR>
                        Leave empty for all the tables
                        </TD>
                    </TR>
                </TABLE>
                <INPUT TYPE="SUBMIT" NAME="ImpFromMDB" VALUE="Import"><BR>
                <I>Note: You need to grant read permissions to the Administrator for the MSysObjects table in
                MS Access!</I>
            </FORM>
            <DIV STYLE="display: none">
            
            <FORM METHOD="POST" STYLE="border: 1px solid green" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
                <TABLE>
                    <TR>
                        <TH COLSPAN="2">Single table from MS Access MDB</TH>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">Table:</TD>
                        <TD VALIGN="TOP">
                            <INPUT TYPE="TEXT" NAME="TABLE" VALUE="">
                        </TD>
                    </TR>
                    <TR>
                        <TD VALIGN="TOP">MDB File:</TD>
                        <TD VALIGN="TOP"><INPUT TYPE="FILE" NAME="FILE" VALUE="">
                        </TD>
                    </TR>
                </TABLE>
                <INPUT TYPE="SUBMIT" NAME="ImpTableFromMDB" VALUE="Import">
            </FORM>
            
            </DIV>
        </blockquote>
    </TD>
    </TR>
    </TABLE>
    <% End If %>
</body>

</html>
<% Else %>
    <html>
    
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
    <link rel=stylesheet href="/styles.css" type="text/css">
    <title>DBObjects</title>
    </head>
    
    <body topmargin="0" leftmargin="0">
    <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
    <TR>
        <TD COLSPAN="2">
        Database not opened.
        </TD>
    </TR>
    <TR>
        <TD COLSPAN="2">
        <IMG SRC="of.gif"><A TARGET="DBManM" HREF="open.asp">Click to open or create</A>
        </TD>
    </TR>
    </TABLE>
    </body>
    
    </html>
<% End If %>