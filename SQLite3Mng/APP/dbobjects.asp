<!-- #include file="common.asp" -->
<% If db.IsOpened Then %>
<%
    str = "ShowTables,ShowIndices,ShowViews,ShowTriggers,ShowNotes"
    arr = Split(str,",")
    For I = LBound(arr) To UBound(arr)
        If Request(arr(I)).Count Then
            Session(arr(I)) = Clng(Request(arr(I)))
        End If
    Next

    Sub ShowObjects(ReqParam,TypeName,TypeKey,ImageName,FileName,nameField)
        If Session(ReqParam) = 1 Then
    %>
        <TR>
            <TD><A HREF="<%= Self & "?" & ReqParam & "=0" %>"><IMG BORDER="0" SRC="minus.gif"></A></TD>
            <TD COLSPAN="2"><%= TypeName %></TD>
        </TR>
    <%        
        Set r = db.Execute("SELECT " & nameField & " FROM sqlite_master WHERE type='" & TypeKey & "' ORDER BY name")
            %>
                <TR>
                    <TD><IMG BORDER="0" SRC="blank.gif"></TD>
                    <TD><IMG BORDER="0" SRC="doc.gif"></TD>
                    <TD COLSPAN="1"><A 
                        TARGET="DBManM"
                        HREF="def<%= FileName %>"><I>&nbsp;(create new)</I></A></TD>
                </TR>
            <%
            For I = 1 To r.Count
                If Not UCase(Left(r(I)(1),9)) = "SYSDBMAN_" Then
                %>
                    <TR>
                        <TD><IMG BORDER="0" SRC="blank.gif"></TD>
                        <TD><IMG BORDER="0" SRC="<%= ImageName %>" STYLE="cursor: hand; border: 1px solid rgb(255,255,255)" onMouseOver="OnHighlightImg()" onMouseOut="OnUnhighlightImg()"
                        onMouseUp="On<%= TypeKey %>img('<%= r(I)(1) %>')"></TD>
                        <TD COLSPAN="1"><A 
                            TARGET="DBManM" onMouseUp="On<%= TypeKey %>('<%= r(I)(1) %>')"
                            HREF="<%= FileName %>?Object=<%= r(I)(1) %>">&nbsp;<%= r(I)(1) %></A></TD>
                    </TR>
                <%
                End If
            Next
            
        Else
    %>
        <TR>
            <TD><A HREF="<%= Self & "?" & ReqParam & "=1" %>"><IMG BORDER="0" SRC="plus.gif"></A></TD>
            <TD COLSPAN="2"><%= TypeName %></TD>
        </TR>
    <%
        End If 
    End Sub
    
    Sub ShowNotes(ReqParam,ImageName,FileName)
        EnsureTableExistsSysNotes
        If Session(ReqParam) = 1 Then
    %>
        <TR>
            <TD><A HREF="<%= Self & "?" & ReqParam & "=0" %>"><IMG BORDER="0" SRC="minus.gif"></A></TD>
            <TD COLSPAN="2">Work notes</TD>
        </TR>
    <%        
        Set r = db.Execute("SELECT NOTEID,substr(NOTE,1,80) AS NOTE FROM SysDBMan_Notes ORDER BY NOTE")
            %>
                <TR>
                    <TD><IMG BORDER="0" SRC="blank.gif"></TD>
                    <TD><IMG BORDER="0" SRC="doc.gif"></TD>
                    <TD COLSPAN="1"><A 
                        TARGET="DBManM"
                        HREF="<%= FileName %>"><I>&nbsp;(create new)</I></A></TD>
                </TR>
            <%
            For I = 1 To r.Count
            %>
                <TR>
                    <TD VALIGN="TOP"><IMG BORDER="0" SRC="blank.gif"></TD>
                    <TD VALIGN="TOP"><IMG BORDER="0" SRC="<%= ImageName %>" STYLE="cursor: hand; border: 1px solid rgb(255,255,255)" onMouseOver="OnHighlightImg()" onMouseOut="OnUnhighlightImg()"
                    onMouseUp="OnNoteimg('<%= r(I)(1) %>')"></TD>
                    <TD COLSPAN="1"><A 
                        TARGET="DBManM" onMouseUp="OnNote('<%= r(I)(1) %>')"
                        HREF="<%= FileName %>?NOTEID=<%= r(I)(1) %>">&nbsp;<%= Server.HTMLEncode(r(I)(2)) %>...</A></TD>
                </TR>
            <%
            Next
            
        Else
    %>
        <TR>
            <TD><A HREF="<%= Self & "?" & ReqParam & "=1" %>"><IMG BORDER="0" SRC="plus.gif"></A></TD>
            <TD COLSPAN="2">Work notes</TD>
        </TR>
    <%
        End If 
    End Sub
    
    
%>
<html>

<head>
<% LangMetaTag %>
<link rel=stylesheet href="/styles.css" type="text/css">
<title>DBObjects</title>
<SCRIPT>
    var CtxMenuTables,CtxMenuView,CtxMenuIndex,CtxMenuTrigger
    function initPage() {
        CtxMenuTables = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuTable");
        CtxMenuView = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuView");
        CtxMenuIndex = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuIndex");
        CtxMenuTrigger = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuTrigger");
        CtxMenuNote = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuNote");
    }
    function Ontable(tbl) {
        if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuTables.Subs.Count; i++) {
            CtxMenuTables.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuTables,event.screenX,event.screenY);
    }
    function Onview(tbl) {
        if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuView.Subs.Count; i++) {
            CtxMenuView.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuView,event.screenX,event.screenY);
    }
    function Onindex(tbl) {
        if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuIndex.Subs.Count; i++) {
            CtxMenuIndex.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuIndex,event.screenX,event.screenY);
    }
    function Ontrigger(tbl) {
        if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuTrigger.Subs.Count; i++) {
            CtxMenuTrigger.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuTrigger,event.screenX,event.screenY);
    }
    function Ontableimg(tbl) {
        var i;
        for (i = 1;i <= CtxMenuTables.Subs.Count; i++) {
            CtxMenuTables.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuTables,event.screenX,event.screenY);
    }
    function Onviewimg(tbl) {
        var i;
        for (i = 1;i <= CtxMenuView.Subs.Count; i++) {
            CtxMenuView.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuView,event.screenX,event.screenY);
    }
    function Onindeximg(tbl) {
        var i;
        for (i = 1;i <= CtxMenuIndex.Subs.Count; i++) {
            CtxMenuIndex.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuIndex,event.screenX,event.screenY);
    }
    function Ontriggerimg(tbl) {
        var i;
        for (i = 1;i <= CtxMenuTrigger.Subs.Count; i++) {
            CtxMenuTrigger.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuTrigger,event.screenX,event.screenY);
    }
    function OnNoteimg(tbl) {
        var i;
        for (i = 1;i <= CtxMenuNote.Subs.Count; i++) {
            CtxMenuNote.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuNote,event.screenX,event.screenY);
    }
    function OnNote(tbl) {
        if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuNote.Subs.Count; i++) {
            CtxMenuNote.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuNote,event.screenX,event.screenY);
    }
    function OnHighlightImg() {
        event.srcElement.style.borderColor = 'blue';
    }
    function OnUnhighlightImg() {
        event.srcElement.style.borderColor = 'white';
    }
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onLoad="initPage()" >
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0">
<TR>
    <TD><A TARGET="DBManM" HREF="impexp.asp"><IMG BORDER="0" SRC="impexp.gif"></A></TD>
    <TD COLSPAN="2"><A TARGET="DBManM" HREF="impexp.asp">&nbsp;Import/Export</A></TD>
</TR>
<TR>
    <TD><A TARGET="DBManM" HREF="sqlconsole.asp"><IMG BORDER="0" SRC="console.gif"></A></TD>
    <TD COLSPAN="2"><A TARGET="DBManM" HREF="sqlconsole.asp">&nbsp;SQL Console</A></TD>
</TR>
<TR>
    <TD><A TARGET="DBManM" HREF="dbscheme.asp"><IMG BORDER="0" SRC="dbstruct.gif"></A></TD>
    <TD COLSPAN="2"><A TARGET="DBManM" HREF="dbscheme.asp">&nbsp;Database schema</A></TD>
</TR>
<TR>
    <TD><A TARGET="DBManM" HREF="sessparams.asp"><IMG BORDER="0" SRC="draw.gif"></A></TD>
    <TD COLSPAN="2"><A TARGET="DBManM" HREF="sessparams.asp">&nbsp;Session parameters</A></TD>
</TR>
<% ShowObjects "ShowTables","Tables","table","table.gif","table.asp","name" %>
<% ShowObjects "ShowViews","Views","view","view.gif","view.asp","name" %>
<% ShowObjects "ShowIndices","Indices","index","index.gif","index.asp","name" %>
<% ShowObjects "ShowTriggers","Triggers","trigger","trigger.gif","trigger.asp","name" %>
<% ShowNotes "ShowNotes","Note.png","note.asp" %>
</TABLE>
</body>

</html>
<% Else %>
<html>

<head>
<% LangMetaTag %>
<link rel=stylesheet href="/styles.css" type="text/css">
<title>DBObjects</title>
</head>

<body topmargin="0" leftmargin="0" style="border: 1px outset;">
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