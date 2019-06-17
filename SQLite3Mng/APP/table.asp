<!-- #include file="common.asp" -->
<%
    b = EnsureTableExistsSysColWidths

    Table = CStr(Request("Object"))
    EditID = 0
    If Request("Edit").Count > 0 Then EditId = CLng(Request("Edit"))
    If Request("RecBegin").Count Then
        RecBegin = CLng(Request("RecBegin"))
    Else
        RecBegin = 1
    End If
    If RecBegin < 0 Then RecBegin = 0
    If Request("RecCount").Count Then
        RecCount = CLng(Request("RecCount"))
    Else
        RecCount = 40
    End If
    If RecCount <= 0 Then RecCount = 20
    
    If Request("Del").Count > 0 Then
        db.Execute "DELETE FROM " & Table & " WHERE OID=" & Request("Del")
    End If
    
    Set rStruct = db.Execute("PRAGMA table_info(" & Table & ")")
    ErrMsg = ""
    
    If Request("Upd").Count > 0 Then
        qry = "UPDATE " & Table & " SET "
        For I = 1 To rStruct.Count
            If Request("F_" & rStruct(I)("name")) <> "" Then
                qry = qry & "[" & rStruct(I)("name") & "]="
                If db.IsNumericType(db.StripTypeName(rStruct(I)("type"))) Then
                    If IsDateType(db.StripTypeName(rStruct(I)("type"))) > 0 Then
                        qry = qry & su.Sprintf("ParseOleDate(%q)",Request("F_" & rStruct(I)("name")))
                    Else
                        qry = qry & su.Sprintf("%a",Request("F_" & rStruct(I)("name")))
                    End If
                Else
                    qry = qry & su.Sprintf("%q",Request("F_" & rStruct(I)("name")))
                End If
                If I < rStruct.Count Then qry = qry & ","
            End If
        Next
        If Right(qry,1) = "," Then qry = Left(qry,Len(qry) - 1)
        qry = qry & " WHERE OID=" & Request("Upd")
        ' Response.Write qry & "<HR>"
        On Error Resume Next
        db.Execute qry
        If Err.Number <> 0 Then
            ErrMsg = db.LastError
        End If
        On Error Goto 0
    ElseIf Request("Add").Count > 0 Then
        qry = "INSERT INTO " & Table & " ("
        For I = 1 To rStruct.Count
            If Request("F_" & rStruct(I)("name")) <> "" Then
                qry = qry & "[" & rStruct(I)("name") & "]"
                If I < rStruct.Count Then qry = qry & ","
            End If
        Next
        If Right(qry,1) = "," Then qry = Left(qry,Len(qry) - 1)
        qry = qry & ") VALUES ("
        For I = 1 To rStruct.Count
            If Request("F_" & rStruct(I)("name")) <> "" Then
                If db.IsNumericType(db.StripTypeName(rStruct(I)("type"))) Then
                    If IsDateType(db.StripTypeName(rStruct(I)("type"))) > 0 Then
                        qry = qry & su.Sprintf("ParseOleDate(%q)",Request("F_" & rStruct(I)("name")))
                    Else
                        qry = qry & su.Sprintf("%a",Request("F_" & rStruct(I)("name")))
                    End If
                Else
                    qry = qry & su.Sprintf("%q",Request("F_" & rStruct(I)("name")))
                End If
                If I < rStruct.Count Then qry = qry & ","
            End If
        Next
        If Right(qry,1) = "," Then qry = Left(qry,Len(qry) - 1)
        qry = qry & ");"
        On Error Resume Next
        Set r = db.Execute(qry)
        If Err.Number <> 0 Then
            ErrMsg = db.LastError
        End If
        EditID = r.Info
        On Error Goto 0
    End If
    
    If Request("ColWidths") <> "" Then
        db.Execute "DELETE FROM SysDBMan_ColumnWidths WHERE Obj='" & Table & "';"
        db.Execute "INSERT INTO SysDBMan_ColumnWidths (Obj,Widths) VALUES ('" & Table & "','" & Request("ColWidths") & "');"
    End If
    
    Dim arrColWidths
    Set rColWidths = db.Execute("SELECT Widths FROM SysDBMan_ColumnWidths WHERE Obj='" & Table & "';")
    If rColWidths.Count > 0 Then
        strColWidths = rColWidths(1)(1)
        If strColWidths <> "" Then
            arrColWidths = Split(strColWidths,",")
        End If
    End If
    
    Function ColWidths(n)
        ColWidths = ""
        Dim w
        If IsArray(arrColWidths) Then
            On Error Resume Next
            w = CLng(arrColWidths(n - 1))
            If Err.Number = 0 Then ColWidths = "WIDTH=""" & w & """"
            On Error Goto 0
        End If
    End Function
    
    
    qry = "SELECT OID,* FROM " & Table
    
    Set r = db.Execute(qry,RecBegin,RecCount)
    Set rc = db.Execute("SELECT Count(OID) FROM " & Table)
    TotalRecords = rc(1)(1)
    Set rc = Nothing
    
    ImgSrc = ""
    If ErrMsg <> "" Then
        ImgSrc = "err.gif"
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
    function onInitPage() {
        var i,c,o;
        //alert(".");
        for (i = 1; document.all("T" + i) != null; i++) {
            o = document.all("T" + i);
            c = document.all("C" + i); //.parentElement;
            //alert(c.offsetWidth);
            o.style.posWidth = c.offsetWidth;
        }
        top.frames["DBManT"].document.frames["DBManT2"].location = "toolbar2-table.asp?RecBegin=<%= RecBegin %>&RecCount=<%= RecCount %>&Object=<%= Table %>&TotalRecords=<%= TotalRecords %>&Msg=<%= ErrMsg %>&Img=<%= ImgSrc %>";
    }
    function onUninitPage() {
        top.frames["DBManT"].document.frames["DBManT2"].location = "toolbar2.asp";
    }
    var minX = 0;
    function OnDragStartX(el,elt) {
        var o = document.all(el);
        var p = document.all(elt);
        minX = o.offsetLeft + o.clientLeft;
        // alert(minX);
    }
    function OnDragX(el,elt) {
        var ob = document.body;
        var p = document.all(el);
        var t = document.all(elt);
        if ((event.clientX + ob.scrollLeft) > (minX + 30)) {
            t.style.posWidth = event.clientX + ob.scrollLeft - minX;
            p.style.posWidth = event.clientX + ob.scrollLeft - minX;
        }
    }
    function OnDragEndX(el,elt) {
        var p = document.all(el);
        var t = document.all(elt);
        t.style.posWidth = p.clientWidth;
        // alert((p.clientWidth) + "," + t.style.posWidth);
        minX = 0;
    }
    function OnBodyDrag() {
        if (minX != 0) {
            event.returnValue = false;
        }
    }
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onMouseUp="onShortcutMenu()" onLoad="onInitPage()" onUnload="onUninitPage()" onDragOver="OnBodyDrag()">

<table ID="MT" border="0" bgcolor="#808080" cellspacing="0" CELLPADDING="0">
  <tr>
  <%
    For I = 0 To rStruct.Count
        If I = 0 Then
            %><th bgcolor="#C0C0A0" nowrap><font color="#FFFFFF"><A 
                HREF="<%= Self & "?RecBegin=" & RecBegin & "&RecCount=" & RecCount & "&Object=" & Table %>"><IMG ALT="Refresh" BORDER="0" SRC="refresh.gif"></A>
                <A 
                HREF="deftable.asp?Object=<%= Table %>"><IMG ALT="Design" BORDER="0" SRC="table.gif"></A>
                <A 
                HREF="deftable2.asp?Object=<%= Table %>"><IMG ALT="Definition SQL" BORDER="0" SRC="console.gif"></A>
                </font></th><%
        Else
            %><th ID="Chdr<%= I %>" bgcolor="#406040" nowrap <%= ColWidths(I)%>>
                <% If rStruct(I)("pk") <> 0 Then %>
                <IMG SRC="key.gif">
                <% End If %>
                <font color="#FFFFFF"><%= rStruct(I)("name") %></font></th>
                <TH><IMG ID="X<%= I %>" SRC="grip.gif" STYLE="cursor: e-resize"
                    onDragStart="OnDragStartX('C<%= I %>','T<%= I %>')"
                    onDragEnd="OnDragEndX('C<%= I %>','T<%= I %>')"
                    onDrag="OnDragX('C<%= I %>','T<%= I %>')"
                ></TH>
                <%
        End If
    Next
  %>
  </tr>
  <tr>
  <%
    For I = 0 To rStruct.Count
        If I = 0 Then
            %><th bgcolor="#80A040" nowrap><font color="#FFFFFF">&nbsp</font></th><%
        Else
            %><th bgcolor="#80A040" nowrap>
              <font color="#FFFFFF"><%= db.StripTypeName(rStruct(I)("type")) %></font></th><TH></TH><%
        End If
    Next
  %>
  </tr>
  <%
  If EditId = 0 Then
  %>
  <TR>
  <%
        For J = 0 To rStruct.Count
            If J = 0 Then
                RecAfterAdd = TotalRecords - RecCount + 1
                If RecAfterAdd < 1 Then RecAfterAdd = 1
                %><FORM METHOD="POST" ACTION="<%= Self %>">
                    <INPUT TYPE="HIDDEN" NAME="Add" VALUE="1">
                    <INPUT TYPE="HIDDEN" NAME="Object" VALUE="<%= Table %>">
                    <INPUT TYPE="HIDDEN" NAME="RecBegin" VALUE="<%= TotalRecords - RecCount + 1 %>">
                    <INPUT TYPE="HIDDEN" NAME="RecCount" VALUE="<%= RecCount %>">
                <td VALIGN="TOP" bgcolor="#FFFFFF" nowrap>
                    <INPUT TYPE="IMAGE" SRC="ok.gif" BORDER="0" ALT="Insert">
                </td><%
            Else
                ' response.write IsDateType(db.StripTypeName(rStruct(J)("type"))) & "<HR>"
                Select Case IsDateType(db.StripTypeName(rStruct(J)("type")))
                    Case 1
                        %><td ID="C<%= J %>" VALIGN="TOP" bgcolor="#C0C0C0"><INPUT SIZE="1" ID="T<%= J %>" CLASS="insetedit" TYPE="TEXT" NAME="F_<%= rStruct(J)("name") %>" VALUE=""></td><TD></TD><%
                    Case 2
                        %><td ID="C<%= J %>" VALIGN="TOP" bgcolor="#C0C0C0"><INPUT SIZE="1" ID="T<%= J %>" CLASS="insetedit" TYPE="TEXT" NAME="F_<%= rStruct(J)("name") %>" VALUE=""></td><TD></TD><%
                    Case 3
                        %><td ID="C<%= J %>" VALIGN="TOP" bgcolor="#C0C0C0"><INPUT SIZE="1" ID="T<%= J %>" CLASS="insetedit" TYPE="TEXT" NAME="F_<%= rStruct(J)("name") %>" VALUE=""></td><TD></TD><%
                    Case Else
                        %><td ID="C<%= J %>" VALIGN="TOP" bgcolor="#C0C0C0"><INPUT SIZE="1" ID="T<%= J %>" CLASS="insetedit" TYPE="TEXT" NAME="F_<%= rStruct(J)("name") %>" VALUE=""></td><TD></TD><%
                End Select
            End If
            If J = rStruct.Count Then 
                %></FORM><%
            End If
        Next
  %>
  </TR>
  <%
  End If
  For I = 1 To r.Count
  %><tr>
    <% 
        For J = 1 To r(I).Count
            If I Mod 2 <> 0 Then cellColor = "F0F0F0" Else cellColor = "E0E0E0"
            If r(I)(1) = EditId Then
                If J = 1 Then
                    %><FORM METHOD="POST" ACTION="<%= Self %>">
                        <INPUT TYPE="HIDDEN" NAME="Upd" VALUE="<%= r(I)(1) %>">
                        <INPUT TYPE="HIDDEN" NAME="Object" VALUE="<%= Table %>">
                        <INPUT TYPE="HIDDEN" NAME="RecBegin" VALUE="<%= RecBegin %>">
                        <INPUT TYPE="HIDDEN" NAME="RecCount" VALUE="<%= RecCount %>">
                    <td VALIGN="TOP" bgcolor="#<%= cellColor %>" nowrap STYLE="border-right: 1px solid black">
                        <INPUT TYPE="IMAGE" SRC="ok.gif" BORDER="0" ALT="Update">
                        <A HREF="<%= Self & "?RecBegin=" & RecBegin & "&RecCount=" & RecCount & "&Object=" & Table & "&Del=" & r(I)(J) %>"><IMG SRC="del.gif" BORDER="0" ALT="Delete"></A>
                    </td><%
                Else
                    If IsNull(r(I)(J)) Then
                        If I Mod 2 <> 0 Then
                            %><td VALIGN="TOP" ID="C<%= J-1 %>" bgcolor="#C0C0C0"><INPUT ID="T<%= J-1 %>" CLASS="insetedit" TYPE="TEXT" NAME="F_<%= r(I).Key(J) %>" VALUE=""></td><TD></TD><%
                        Else
                            %><td VALIGN="TOP" ID="C<%= J-1 %>" bgcolor="#D0D0D0"><INPUT ID="T<%= J-1 %>" CLASS="insetedit" TYPE="TEXT" NAME="F_<%= r(I).Key(J) %>" VALUE=""></td><TD></TD><%
                        End If
                    Else
                        On Error Resume Next
                        ' response.write IsDateType(db.StripTypeName(r(I).Info(J))) & ":" & db.StripTypeName(r(I).Info(J)) & "<HR>"
                        Select Case IsDateType(db.StripTypeName(rStruct(J-1)("type")))
                            Case 1
                                Response.Write "<td ID=""C" & J-1 & """ VALIGN=""TOP"" bgcolor=""#C0C0C0""><INPUT SIZE=""1"" ID=""T" & J-1 & """ CLASS=""insetedit"" TYPE=""TEXT"" NAME=""F_" & r(I).Key(J) & """ VALUE=""" & su.Sprintf("%hT",r(I)(J) ) & """></td><TD></TD>"
                            Case 2
                                Response.Write "<td ID=""C" & J-1 & """ VALIGN=""TOP"" bgcolor=""#C0C0C0""><INPUT SIZE=""1"" ID=""T" & J-1 & """ CLASS=""insetedit"" TYPE=""TEXT"" NAME=""F_" & r(I).Key(J) & """ VALUE=""" & su.Sprintf("%ht",r(I)(J) ) & """></td><TD></TD>"
                            Case 3
                                Response.Write "<td ID=""C" & J-1 & """ VALIGN=""TOP"" bgcolor=""#C0C0C0""><INPUT SIZE=""1"" ID=""T" & J-1 & """ CLASS=""insetedit"" TYPE=""TEXT"" NAME=""F_" & r(I).Key(J) & """ VALUE=""" & su.Sprintf("%lT",r(I)(J) ) & """></td><TD></TD>"
                            Case Else
                                Response.Write "<td ID=""C" & J-1 & """ VALIGN=""TOP"" bgcolor=""#C0C0C0""><INPUT SIZE=""1"" ID=""T" & J-1 & """ CLASS=""insetedit"" TYPE=""TEXT"" NAME=""F_" & r(I).Key(J) & """ VALUE=""" & Server.HTMLEncode(su.Sprintf("%Na",r(I)(J))) & """></td><TD></TD>"
                        End Select
                        If Err.Number <> 0 Then
                            Response.Write "<td ID=""C" & J-1 & """ VALIGN=""TOP"" bgcolor=""#C0C0C0""><INPUT SIZE=""1"" ID=""T" & J-1 & """ CLASS=""insetedit"" TYPE=""TEXT"" NAME=""F_" & r(I).Key(J) & """ VALUE=""" & Server.HTMLEncode(su.Sprintf("%Na",r(I)(J) )) & """></td><TD></TD>"
                        End If
                        On Error Goto 0
                    End If
                End If
                If J = r(I).Count Then 
                    %></FORM><%
                End If
            Else
                If J = 1 Then
                    %><td VALIGN="TOP" bgcolor="#<%= cellColor %>" nowrap STYLE="border-right: 1px solid black">
                        <A HREF="<%= Self & "?RecBegin=" & RecBegin & "&RecCount=" & RecCount & "&Object=" & Table & "&Edit=" & r(I)(J) %>"><IMG SRC="edit.gif" BORDER="0" ALT="Edit"></A>
                        <A HREF="<%= Self & "?RecBegin=" & RecBegin & "&RecCount=" & RecCount & "&Object=" & Table & "&Del=" & r(I)(J) %>"><IMG SRC="del.gif" BORDER="0" ALT="Delete"></A>
                    </td><%
                Else
                    ' response.write db.StripTypeName(rStruct(J-1)("type")) & "<HR>"
                    On Error Resume Next
                    Select Case IsDateType(db.StripTypeName(rStruct(J-1)("type")))
                        Case 1
                            Response.Write "<td STYLE=""border-bottom: 1px solid black"" VALIGN=""TOP"" bgcolor=""#" & cellColor & """>" & su.Sprintf("%hT",r(I)(J) ) & "</td><TD></TD>"
                        Case 2
                            Response.Write "<td STYLE=""border-bottom: 1px solid black"" VALIGN=""TOP"" bgcolor=""#" & cellColor & """>" & su.Sprintf("%ht",r(I)(J) ) & "</td><TD></TD>"
                        Case 3
                            Response.Write "<td STYLE=""border-bottom: 1px solid black"" VALIGN=""TOP"" bgcolor=""#" & cellColor & """>" & su.Sprintf("%lT",r(I)(J) ) & "</td><TD></TD>"
                        Case Else
                            Response.Write "<td STYLE=""border-bottom: 1px solid black"" VALIGN=""TOP"" bgcolor=""#" & cellColor & """>" & Server.HTMLEncode(su.Sprintf("%Na",r(I)(J) )) & "</td><TD></TD>"
                    End Select
                    If Err.Number <> 0 Then
                        %><td STYLE="border-bottom: 1px solid black" VALIGN="TOP" bgcolor="#FFF0F0"><%= Server.HTMLEncode(su.Sprintf("%Na",r(I)(J) )) %></td><TD></TD><%
                    End If
                    On Error Goto 0
                End If
            End If
        Next
    %>
  </tr><%
  Next
  %>
</table>

</body>

</html>
