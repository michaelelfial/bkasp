<!-- #include file="common.asp" -->
<% If db.IsOpened Then %>
<%
    str = "ShowTables,ShowIndices,ShowViews,ShowTriggers"
    arr = Split(str,",")
    For I = LBound(arr) To UBound(arr)
        If Request(arr(I)).Count Then
            Session(arr(I)) = Clng(Request(arr(I)))
        End If
    Next
    
    F1 = CStr(Request("F1"))
    F2 = CStr(Request("F2"))
    If Request("Clear").Count > 0 Then
        F1 = ""
        F2 = ""
    End If
    
    ObjectsPerLine = 5

    Sub ShowObjects(ReqParam,TypeName,TypeKey,ImageName,FileName,nameField)
    %>
        <TR>
    <%        
        Set r = db.Execute("SELECT " & nameField & " FROM sqlite_master WHERE type='" & TypeKey & "' AND upper(substr(name,1,9)) != 'SYSDBMAN_' ORDER BY name")
            For I = 1 To r.Count
            %>
                <TD VALIGN="TOP">
                    <%
                        Set rs = db.Execute("PRAGMA table_info(" & r(I)(1) & ");")
                        %>
                        <TABLE CELLSPACING="1" CELLPADDING="1" BGCOLOR="#004080">
                            <TR>
                                <TD><B><A 
                        TARGET="DBManM" onMouseUp="On<%= TypeKey %>('<%= r(I)(1) %>')"
                        HREF="<%= FileName %>?Object=<%= r(I)(1) %>"><IMG BORDER="0" SRC="<%= ImageName %>">&nbsp;<FONT COLOR="#FFFFFF"><%= r(I)(1) %></FONT></A></B></TD>
                            </TR>
                            <%
                            For J = 1 To rs.Count
                                If F1 <> "" AND F2 <> "" Then
                                    If F1 = r(I)(1) & "." & rs(J)("name") Or F2 = r(I)(1) & "." & rs(J)("name") Then
                                        %><TR>
                                        <% If rs(J)("pk") <> 0 Then %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><B><FONT COLOR="#FF0000"><%= rs(J)("name") %></FONT></B><IMG BORDER="0" SRC="key.gif"></TD>
                                        <% Else %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><B><FONT COLOR="#FF0000"><%= rs(J)("name") %></FONT></B></TD>
                                        <% End If %>
                                        </TR><%
                                    Else
                                        %><TR>
                                        <% If rs(J)("pk") <> 0 Then %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><%= rs(J)("name") %><IMG BORDER="0" SRC="key.gif"></TD>
                                        <% Else %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><%= rs(J)("name") %></TD>
                                        <% End If %>
                                        </TR><%
                                    End If
                                ElseIf F1 <> "" Then
                                    If F1 = r(I)(1) & "." & rs(J)("name") Then
                                        %><TR>
                                        <% If rs(J)("pk") <> 0 Then %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><B><FONT COLOR="#FF0000"><%= rs(J)("name") %></FONT></B><IMG BORDER="0" SRC="key.gif"></TD>
                                        <% Else %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><B><FONT COLOR="#FF0000"><%= rs(J)("name") %></FONT></B></TD>
                                        <% End If %>
                                        </TR><%
                                    ElseIf Split(F1,".")(0) = r(I)(1) Then
                                        %><TR>
                                        <% If rs(J)("pk") <> 0 Then %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><%= rs(J)("name") %><IMG BORDER="0" SRC="key.gif"></TD>
                                        <% Else %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><%= rs(J)("name") %></TD>
                                        <% End If %>
                                        </TR><%
                                    Else
                                        %><TR>
                                        <% If rs(J)("pk") <> 0 Then %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><A HREF="<%= Self & "?F1=" & F1 & "&F2=" & r(I)(1) & "." & rs(J)("name") %>"><%= rs(J)("name") %></A><IMG BORDER="0" SRC="key.gif"></TD>
                                        <% Else %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><A HREF="<%= Self & "?F1=" & F1 & "&F2=" & r(I)(1) & "." & rs(J)("name") %>"><%= rs(J)("name") %></A></TD>
                                        <% End If %>
                                        </TR><%
                                    End If
                                Else
                                    %><TR>
                                    <% If rs(J)("pk") <> 0 Then %>
                                    <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><A HREF="<%= Self & "?F1=" & r(I)(1) & "." & rs(J)("name") %>"><%= rs(J)("name") %></A><IMG BORDER="0" SRC="key.gif"></TD>
                                    <% Else %>
                                    <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><A HREF="<%= Self & "?F1=" & r(I)(1) & "." & rs(J)("name") %>"><%= rs(J)("name") %></A></TD>
                                    <% End If %>
                                    </TR><%
                                End If
                            Next
                            %>
                            <%
                                Set rs = db.Execute("SELECT * FROM sqlite_master WHERE tbl_name=" & su.Sprintf("%q",r(I)(1)) & " AND type IN ('index','trigger');")
                                If rs.Count > 0 Then
                                    %><TR>
                                    <TD VALIGN="TOP" BGCOLOR="#E0F0F0"><B>Related:</B></TD>
                                    </TR><%
                                    For J = 1 To rs.Count
                                        %><TR>
                                        <% If rs(J)("type") = "trigger" Then %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><A 
                                            onMouseUp="Ontrigger('<%= rs(J)("name") %>')"
                                            HREF="deftrigger.asp?Object=<%= rs(J)("name") %>"><IMG BORDER="0" SRC="trigger.gif"><%= rs(J)("name") %></A></TD>
                                        <% Else %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><A 
                                            onMouseUp="Onindex('<%= rs(J)("name") %>')"
                                            HREF="defindex.asp?Object=<%= rs(J)("name") %>"><IMG BORDER="0" SRC="index.gif"><%= rs(J)("name") %></A></TD>
                                        <% End If %>
                                        </TR><%
                                    Next
                                End If
                            %>
                        </TABLE>
                </TD>
                <TD WIDTH="20">&nbsp;</TD>
            <%
            If (I) Mod ObjectsPerLine = 0 Then
                %></TR><TD COLSPAN="<%= (ObjectsPerLine * 2) %>">&nbsp;</TD><TR><%
            End If
            Next
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
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onLoad="initPage()">
<%
    If F1 <> "" Then
        If F2 <> "" Then
            %>2 Fields selected: <B><%= F1 %></B> <%= F2 %><BR>
            <A HREF="<%= Self %>">Clear selection and start over.</A>
            <FORM METHOD="POST" ACTION="deftrigger.asp">
            <%
            
                arr1 = Split(F1,".")
                arr2 = Split(F2,".")
                query = "CREATE TRIGGER DT" & arr1(0) & arr2(0) & " AFTER DELETE ON " & arr1(0) & vbCrLf & _
                        " FOR EACH ROW " & vbCrLf & _
                        " BEGIN " & vbCrLf & _
                        "   DELETE FROM " & arr2(0) & " WHERE " & F2 & "=Old." & arr1(1) & ";" & vbCrLf & _
                        " END"
            %>
            <INPUT TYPE="HIDDEN" NAME="QUERY" VALUE="<%= query %>">
            <INPUT TYPE="SUBMIT" VALUE="Create cascaded deletion trigger">
            </FORM>
            <I>When a record from the first table is deleted the trigger will delete the records from the second table that have the the same values for the specified field.</I>
        <% Else
            %>1 Field selected: <%= F1 %><BR>
            <B>Now select from the other table the column that is reffered by the already selected column in the first table.</B>
            <%
        End If        
    Else
        %>
        <B>Select from one of the tables a column that points records in other table(s).</B>
        <%
    End If
%>
<HR COLOR="0" SIZE="1">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
<% ShowObjects "ShowTables","Tables","table","table.gif","table.asp","name" %>
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