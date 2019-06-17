<!-- #include file="common.asp" -->
<%
    Object = CStr(Request("Object"))
    If Request("Index").Count > 0 Then
        Index = CStr(Request("Index"))
    Else
        Randomize
        randNum = CLng(999999 * Rnd)
        Index = su.Sprintf("NewIndex%06d%s",randNum,Object)
    End If
    
    
    Set rTI = db.Execute("PRAGMA TABLE_INFO(" & Object & ");")
    Set conflicts = Server.CreateObject("newObjects.utilctls.VarDictionary")
    conflicts.Add "none", ""
    conflicts.Add "ROLLBACK", "ROLLBACK"
    conflicts.Add "ABORT", "ABORT"
    conflicts.Add "FAIL", "FAIL"
    conflicts.Add "IGNORE", "IGNORE"
    conflicts.Add "REPLACE", "REPLACE"
    
    ErrText = ""
    bFirstShown = True
    
    ' There is a better way in ALP but for the IIS compatibility sake ...
    Function FindColumnInRequest(col)
        Dim I
        FindColumnInRequest = False
        For I = 1 To Request("Column").Count
            If Request("Column")(I) = col Then
                FindColumnInRequest = True
                Exit Function
            End If
        Next
    End Function
    
    If Request("CREATE").Count > 0 Then
        bFirstShown = False
        ' Try to create the index
        If Request("Column").Count > 0 Then
            If Request("CONFLICT") <> "" Then
                qry = su.Sprintf("CREATE UNIQUE INDEX %s ON %s (",Index,Object)
            Else
                qry = su.Sprintf("CREATE INDEX %s ON %s (",Index,Object)
            End If
            For I = 1 To Request("Column").Count
                qry = qry & su.Sprintf("[%s]",Request("Column")(I))
                If I < Request("Column").Count Then qry = qry & ","
            Next
            If Request("CONFLICT") <> "" Then
                qry = qry & su.Sprintf(") ON CONFLICT %s;",Request("CONFLICT"))
            Else
                qry = qry & ");"
            End If
            ' Try to execute
            On Error Resume Next
            db.Execute qry
            If Err.Number <> 0 Then
                ErrText = db.LastError
            End If
            On Error Goto 0
        Else
            ErrText = "No column has been selected."
        End If
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
        external.DisplayPopupMenu(external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuEditSQL"),event.screenX,event.screenY);
    }
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onMouseUp="onShortcutMenu()">
<FORM METHOD="POST" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
    <% If bFirstShown Or ErrText <> "" Then %>
        <table border="0" width="100%" bgcolor="#004080" cellspacing="1">
            <% If ErrText <> "" Then %>
                <tr>
                    <TD ALIGN="LEFT" COLSPAN="6">
                        <FONT COLOR="#FFC000"><B><%= ErrText %></B></FONT>
                    </TD>
                </tr>
            <% End If %>
            <tr>
                <TD ALIGN="LEFT" COLSPAN="6">
                    <FONT COLOR="#FFFFFF">Index name:</FONT>
                    <INPUT TYPE="TEXT" NAME="Index" VALUE="<%= Index %>">
                    <INPUT TYPE="HIDDEN" NAME="Object" VALUE="<%= Object %>">
                </TD>
            </tr>
            <tr>
                <TH>&nbsp;</TH>
                <TH NOWRAP><FONT COLOR="#FFFFFF">Column</FONT></TH>
                <TH NOWRAP><FONT COLOR="#FFFFFF">Type</FONT></TH>
                <tH NOWRAP ALIGN="CENTER">
                    <FONT COLOR="#FFFFFF">Not null</FONT>
                </TH>
                <tH NOWRAP ALIGN="CENTER">
                    <FONT COLOR="#FFFFFF">Default value</FONT>
                </TH>
                <tH NOWRAP ALIGN="CENTER">
                    <FONT COLOR="#FFFFFF">Primary key</FONT>
                </TH>
            </tr>
            <% For I = 1 To rTI.Count %>
                <tr>
                    <td NOWRAP ALIGN="LEFT">
                        <% If FindColumnInRequest(rTI(I)("name")) Then %>
                            <INPUT CHECKED TYPE="CHCKBOX" NAME="Column" VALUE="<%= rTI(I)("name") %>">
                        <% Else %>
                            <INPUT TYPE="CHECKBOX" NAME="Column" VALUE="<%= rTI(I)("name") %>">
                        <% End If %>
                        
                    </td>
                    <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0E0">
                        <%= rTI(I)("Name") %>
                    </td>
                    <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0E0">
                        <%= rTI(I)("type") %>
                    </td>
                    <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0E0">
                        <% If rTI(I)("notnull") <> 0  Then %>
                            NOT NULL
                        <% Else %>
                            &nbsp;
                        <% End If %>
                    </td>
                    <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0E0">
                        <% If Not IsNull(rTI(I)("dflt_value")) Then %>
                            <%= rTI(I)("dflt_value") %>
                        <% Else %>
                            &nbsp;
                        <% End If %>
                    </td>
                    <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0E0">
                        <% If rTI(I)("pk") <> 0  Then %>
                            PRIMARY KEY
                        <% Else %>
                            &nbsp;
                        <% End If %>
                    </td>
                  </tr>
            <% Next %>
            <TR>
                <TD ALIGN="LEFT" VALIGN="TOP" COLSPAN="6">
                    <FONT COLOR="#FFFF80">Select the columns which will be indexed.</FONT>
                </TD>
            </TR>
            <TR>
                <TD ALIGN="LEFT" VALIGN="TOP" COLSPAN="6">
                    <FONT COLOR="#FFFF80">Conflict algorythm. If algorythm is selected the index will require uniqueness.</FONT><BR>
                    <SELECT NAME="CONFLICT">
                        <% For I = 1 To conflicts.Count %>
                            <% If conflicts(I) = Request("CONFLICT") Then %>
                                <OPTION SELECTED VALUE="<%= conflicts(I) %>"><%= conflicts.Key(I) %></OPTION>
                            <% Else %>
                                <OPTION VALUE="<%= conflicts(I) %>"><%= conflicts.Key(I) %></OPTION>
                            <% End If %>                        
                        <% Next %>
                    </SELECT>
                </TD>
            </TR>
            <TR>
                <TD ALIGN="CENTER" VALIGN="TOP" COLSPAN="6">
                    <INPUT TYPE="SUBMIT" NAME="CREATE" VALUE="Create index">
                </TD>
            </TR>
        </table>
    <% Else %>
        <SCRIPT>
            window.top.location = "/";
        </SCRIPT>
    <% End If %>
</FORM>          
</body>

</html>
