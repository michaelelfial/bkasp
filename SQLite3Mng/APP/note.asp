<!-- #include file="common.asp" -->
<%
    Dim note, NoteID, r, RefreshContents
    NoteID = 0
    note = CStr(Request("NOTE"))
    
    RefreshContents = ""
    
    If Request("NoteID").Count Then
        NoteID = CLng(Request("NoteID"))
    End If
    
    If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
        
        If Request("Save").Count > 0 Then
            If NoteID <> 0 Then
                db.VExecute "UPDATE SysDBMan_Notes SET NOTE=$Note WHERE NOTEID=$NoteId",1,0,note,NoteID
            Else
                Set r = db.VExecute("INSERT INTO SysDBMan_Notes (NOTE) VALUES ($1)",1,0,note)
                NoteID = r.Info
            End If
        ElseIf Request("Del").Count > 0 Then
            db.VExecute "DELETE FROM SysDBMan_Notes WHERE NoteID=$NoteId",1,0,NoteID
            NoteID = 0
            note = ""
        End If
        RefreshContents = "dbobjects.asp"
    End If
    
    Set r = db.VExecute("SELECT * FROM SysDBMan_Notes WHERE NOTEID=$NoteId",1,1,NoteID)
    If r.Count > 0 Then
        NoteID = r(1)("NOTEID")
        note = r(1)("NOTE")
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
            <B><FONT COLOR="#FFFFFF">Note</FONT></B>
        </td>
      </tr>
      <tr>
        <td width="100%" bgcolor="#FFFFFF" COLSPAN="2" align="center" NOWRAP HEIGHT="100%">
          <textarea 
            NAME="NOTE" 
            rows="16" cols="100" style="width: 100%; height: 100%"
            class="normalFont" style="border: 1px inset"><%= Server.HTMLEncode(note) %></textarea><BR>
          </td>
      </tr>
      <tr>
         <td width="100%" COLSPAN="2" bgcolor="#FFFFFF" align="center" NOWRAP>
            <input style="width: 120" type="submit" NAME="Save" value="Save">
            <% If NoteID <> 0 Then %>
                <input style="width: 120" type="button" value="Execute as query" onClick="document.forms[0].action='sqlconsole.asp';document.forms[0].submit();">
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
