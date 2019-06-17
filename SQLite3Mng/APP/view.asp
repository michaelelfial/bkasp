<!-- #include file="common.asp" -->
<%
    b = EnsureTableExistsSysColWidths

    Table = CStr(Request("Object"))
    If Request("RecBegin").Count Then
        RecBegin = CLng(Request("RecBegin"))
    Else
        RecBegin = 1
    End If
    If Request("RecCount").Count Then
        RecCount = CLng(Request("RecCount"))
    Else
        RecCount = 20
    End If
    
    Set rStruct = db.Execute("PRAGMA table_info(" & Table & ")")
    ErrMsg = ""
    
    qry = "SELECT * FROM " & Table
    
    Set r = db.Execute(qry,RecBegin,RecCount)
    Set rc = db.Execute("SELECT Count(*) FROM " & Table)
    TotalRecords = rc(1)(1)
    Set rc = Nothing
    
    ImgSrc = ""
    If ErrMsg <> "" Then
        ImgSrc = "err.gif"
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
        top.frames["DBManT"].document.frames["DBManT2"].location = "toolbar2-view.asp?RecBegin=<%= RecBegin %>&RecCount=<%= RecCount %>&Object=<%= Table %>&TotalRecords=<%= TotalRecords %>&Msg=<%= ErrMsg %>&Img=<%= ImgSrc %>";
    }
    function onUninitPage() {
        top.frames["DBManT"].document.frames["DBManT2"].location = "toolbar2.asp";
    }
    var minX = 0;
    function OnDragStartX(el) {
        var o = document.all(el);
        minX = o.offsetLeft + o.clientLeft;
        //alert(minX);
    }
    function OnDragX(el,elt) {
        var ob = document.body;
        var p = document.all(el);
        if ((event.clientX + ob.scrollLeft) > (minX + 30)) {
            p.style.posWidth = event.clientX + ob.scrollLeft - minX;
        }
    }
    function OnDragEndX(el,elt) {
        var p = document.all(el);
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
            %><th bgcolor="#C0C0C0" nowrap><font color="#FFFFFF"><A 
                HREF="<%= Self & "?RecBegin=" & RecBegin & "&RecCount=" & RecCount & "&Object=" & Table %>"><IMG ALT="Refresh" BORDER="0" SRC="refresh.gif"></A>
                <A 
                HREF="defview.asp?Object=<%= Table %>"><IMG ALT="View Definition SQL" BORDER="0" SRC="view.gif"></A>
                </font></th><%
        Else
            %><th ID="Chdr<%= I %>" bgcolor="#406080" nowrap <%= ColWidths(I)%>>
                <% If rStruct(I)("pk") <> 0 Then %>
                <IMG SRC="key.gif">
                <% End If %>
                <font color="#FFFFFF"><%= rStruct(I)("name") %></font></th>
                <TH><IMG ID="X<%= I %>" SRC="grip.gif" STYLE="cursor: e-resize"
                    onDragStart="OnDragStartX('Chdr<%= I %>')"
                    onDragEnd="OnDragEndX('Chdr<%= I %>')"
                    onDrag="OnDragX('Chdr<%= I %>')"
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
            %><th bgcolor="#8080F0" nowrap><font color="#FFFFFF">&nbsp</font></th><%
        Else
            %><th bgcolor="#8080F0" nowrap>
              <font color="#FFFFFF"><%= db.StripTypeName(rStruct(I)("type")) %></font></th><TH></TH><%
        End If
    Next
  %>
  </tr>
  <%
  For I = 1 To r.Count
  %><tr>
    <% 
        For J = 0 To r(I).Count
                If J = 0 Then
                    %><td VALIGN="TOP" bgcolor="#FFFFFF" nowrap STYLE="border-bottom: 1px solid black; border-right: 1px solid black">
                        &nbsp;<%= RecBegin + I - 1 %>
                    </td><%
                Else
                    On Error Resume Next
                    Select Case IsDateType(db.StripTypeName(r(I).Info(J)))
                        Case 1
                            Response.Write "<td STYLE=""border-bottom: 1px solid black"" VALIGN=""TOP"" bgcolor=""#F0F0F0"">" & su.Sprintf("%hT",r(I)(J) ) & "</td><TD></TD>"
                        Case 2
                            Response.Write "<td STYLE=""border-bottom: 1px solid black"" VALIGN=""TOP"" bgcolor=""#F0F0F0"">" & su.Sprintf("%ht",r(I)(J) ) & "</td><TD></TD>"
                        Case 3
                            Response.Write "<td STYLE=""border-bottom: 1px solid black"" VALIGN=""TOP"" bgcolor=""#F0F0F0"">" & su.Sprintf("%lT",r(I)(J) ) & "</td><TD></TD>"
                        Case Else
                            Response.Write "<td STYLE=""border-bottom: 1px solid black"" VALIGN=""TOP"" bgcolor=""#F0F0F0"">" & Server.HTMLEncode(su.Sprintf("%Na",r(I)(J) )) & "</td><TD></TD>"
                    End Select
                    If Err.Number <> 0 Then
                        %><td STYLE="border-bottom: 1px solid black" VALIGN="TOP" bgcolor="#FFF0F0"><%= Server.HTMLEncode(su.Sprintf("%Na",r(I)(J) )) %></td><TD></TD><%
                    End If
                    On Error Goto 0
                End If
        Next
    %>
  </tr><%
  Next
  %>
</table>

</body>

</html>
