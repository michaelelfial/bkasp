<!-- #include file="common.asp" -->
<%
    Dim script, ScriptID, r, RefreshContents
    ScriptID = 0
    script = CStr(Request("SCRIPT"))
    
    RefreshContents = ""
    
    If Request("ScriptId").Count Then
        ScriptId = CLng(Request("ScriptId"))
    End If
    
    If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
        
        If Request("Save").Count > 0 Then
            If ScriptId <> 0 Then
                db.VExecute "UPDATE SysDBMan_Scripts SET SCRIPT=$Script WHERE SCRIPTID=$ScriptId", 1, 0, script, ScriptId
            Else
                Set r = db.VExecute("INSERT INTO SysDBMan_Scripts (SCRIPT) VALUES ($1)",1,0,script)
                ScriptId = r.Info
            End If
        ElseIf Request("Run").Count > 0 Then
            ' TO DO:
        ElseIf Request("Del").Count > 0 Then
            db.VExecute "DELETE FROM SysDBMan_Scripts WHERE ScriptId=$ScriptId",1,0,ScriptId
            ScriptId = 0
            script = ""
        End If
        RefreshContents = "dbobjects.asp"
    End If
    
    Set r = db.VExecute("SELECT * FROM SysDBMan_Scripts WHERE SCRIPTID=$ScriptId",1,1,ScriptId)
    If r.Count > 0 Then
        ScriptId = r(1)("SCRIPTID")
        note = r(1)("SCRIPT")
    End If
    ' Set r = Nothing
    
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
    <% If RefreshContents <> "" Then %>
        window.top.frames["DBManC"].location = "<%= RefreshContents %>"
    <% End If %>
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onMouseUp="onShortcutMenu()">
<FORM METHOD="POST" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
    <INPUT TYPE="HIDDEN" NAME="NOTEID" VALUE="<%= NoteID %>">
    <table border="0" width="100%" bgcolor="#004080" cellspacing="1" HEIGHT="100%">
      <tr>
        <td width="100%" COLSPAN="2" NOWRAP ALIGN="CENTER">
            <B><FONT COLOR="#FFFFFF">Script</FONT></B>
        </td>
      </tr>
      <tr>
        <td width="100%" bgcolor="#FFFFFF" COLSPAN="2" align="center" NOWRAP HEIGHT="100%">
          <textarea 
            NAME="SCRIPT" 
            rows="16" cols="100" style="width: 100%; height: 100%"
            class="normalFont" style="border: 1px inset"><%= Server.HTMLEncode(script) %></textarea><BR>
          </td>
      </tr>
      <tr>
         <td width="100%" COLSPAN="2" bgcolor="#FFFFFF" align="center" NOWRAP>
            <input style="width: 120" type="submit" NAME="Save" value="Save">
            <% If ScriptId <> 0 Then %>
                <input NAME="Run" style="width: 120" type="submit" value="Execute as VBScript">
                &nbsp;
                &nbsp;
                &nbsp;
                &nbsp;
                <input style="width: 120" type="submit" NAME="Del" value="Delete">
            <% End If %>
         </td>
      </tr>
    </table>

</FORM>          

</body>

</html>
