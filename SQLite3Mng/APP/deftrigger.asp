<!-- #include file="common.asp" -->
<%
    Object = CStr(Request("Object"))
    
    If Request.ServerVariables("REQUEST_METHOD") = "POST" And Request("SaveNote").Count = 0 Then
        bExecuted = True
        On Error Resume Next
        db.Execute "DROP TRIGGER " & Object
        Set r = db.Execute(RequesT("QUERY"))
        If Err.Number <> 0 Then
            errText = db.LastError
        Else
            errText = ""
        End If
        On Error Goto 0    
    Else
        bExecuted = False
        Set r = db.Execute(su.Sprintf("SELECT * FROM sqlite_master WHERE name=%q;",Object))
    End If
    
    query = Request("QUERY")   
    
    If Request("QUERY").Count = 0 Then
        query = "CREATE TRIGGER <name> BEFIRE | AFTER <event> ON <table> WHEN <clause> BEGIN ... END;"
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

<% 
    If Request.ServerVariables("REQUEST_METHOD") = "POST" And Request("SaveNote").Count > 0 Then 
        EnsureTableExistsSysNotes
        db.VExecute "INSERT INTO SysDBMan_Notes (NOTE) VALUES ($1)",1,0,CStr(Request("QUERY"))
        %>
        <SCRIPT>
        window.top.frames["DBManC"].location = "dbobjects.asp"
        </SCRIPT>
        <%
    End If 
%>

<FORM METHOD="POST" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
    <INPUT TYPE="HIDDEN" NAME="Object" VALUE="<%= Object %>">
    <% If Not bExecuted Then %>
        <% If r.Count > 0 Then %>
        <table border="0" width="100%" bgcolor="#004080" cellspacing="1">
          <tr>
            <td width="100%" COLSPAN="2" NOWRAP ALIGN="CENTER"><B><FONT COLOR="#FFFFFF">Trigger <%= r(1)("name") %></FONT></B></td>
          </tr>
          <tr>
            <td width="100%" bgcolor="#FFFFFF" COLSPAN="2" align="center" NOWRAP>
              <textarea 
                NAME="QUERY" 
                rows="16" cols="100" 
                class="normalFont" style="width:100%; overflow:auto; border: 1px inset"><%= r(1)("sql") %></textarea><BR>
              </td>
          </tr>
          <tr>
             <td width="100%" COLSPAN="2" bgcolor="#FFFFFF" align="center" NOWRAP>
             <input style="width: 200" type="submit" value="Execute SQL">
             &nbsp;<input type="submit" NAME="SaveNote" value="Save as note">
             </td>
          </tr>
        </table>
        <% Else %>
        <table border="0" width="100%" bgcolor="#004080" cellspacing="1">
          <tr>
            <td width="100%" COLSPAN="2" NOWRAP ALIGN="CENTER"><B><FONT COLOR="#FFFFFF">New trigger</FONT></B></td>
          </tr>
          <tr>
            <td width="100%" bgcolor="#FFFFFF" COLSPAN="2" align="center" NOWRAP>
              <textarea 
                NAME="QUERY" 
                rows="16" cols="100" 
                class="normalFont" style="width:100%; overflow:auto;border: 1px inset"><%= query %></textarea><BR>
              </td>
          </tr>
          <tr>
             <td width="100%" COLSPAN="2" bgcolor="#FFFFFF" align="center" NOWRAP>
             <input style="width: 200" type="submit" value="Execute SQL">
             &nbsp;<input type="submit" NAME="SaveNote" value="Save as note">
             </td>
          </tr>
        </table>
        <% End If %>
    <% Else %>
        <% If errText <> "" Then %>
        <table border="0" width="100%" bgcolor="#004080" cellspacing="1">
          <tr>
            <td width="100%" COLSPAN="2" NOWRAP ALIGN="CENTER"><B><FONT COLOR="#FFFFFF">New trigger</FONT></B></td>
          </tr>
          <tr>
            <td width="100%" bgcolor="#FFFFFF" COLSPAN="2" align="center" NOWRAP>
              <textarea 
                NAME="QUERY" 
                rows="16" cols="100" 
                class="normalFont" style="width:100%; overflow:auto;border: 1px inset"><%= query %></textarea><BR>
              </td>
          </tr>
          <tr>
             <td width="100%" COLSPAN="2" bgcolor="#FFFFFF" align="center" NOWRAP>
             <B>Error: <%= errText %></B>
             </td>
          </tr>
          <tr>
             <td width="100%" COLSPAN="2" bgcolor="#FFFFFF" align="center" NOWRAP>
             <input style="width: 200" type="submit" value="Execute SQL">
             &nbsp;<input type="submit" NAME="SaveNote" value="Save as note">
             </td>
          </tr>
        </table>
        <% Else %>
            <SCRIPT>
                window.top.location = "/";
            </SCRIPT>
        <% End If %>
    <% End If %>
</FORM>          

</body>

</html>
