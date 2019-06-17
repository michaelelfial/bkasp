<!-- #include file="common.asp" -->
<% If db.IsOpened Then %>
<%
    ' Response.ContentType = "text/plain"
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
    
    Set counts = Server.CreateObject("newObjects.utilctls.VarDictionary")

    Sub ShowObjects(ReqParam,TypeName,TypeKey,ImageName,FileName,nameField)
        Set r = db.Execute("SELECT " & nameField & " FROM sqlite_master WHERE type='" & TypeKey & "' ORDER BY name")
            counts.Add Typekey, r.Count
            For I = 1 To r.Count
                If UCase(Left(r(I)(1),9)) = "SYSDBMAN_" Then hiddenObject = "none" Else hiddenObject = "block"
                
                        Set rs = db.Execute("PRAGMA table_info(" & r(I)(1) & ");")
                        %>

                        <DIV STYLE="position: absolute; display: <%= hiddenObject %>" ID="X<%= TypeKey & I %>" TITLE="<%= r(I)(1) & "," & TypeKey %>" 
                            onClick="OnDivClick('X<%= TypeKey & I %>')">
                        <TABLE CELLSPACING="1" CELLPADDING="1" BGCOLOR="#0080C0">
                            <TR>
                                <TD HEIGHT="12"><IMG 
                                onDragStart="OnDragStartX('X<%= TypeKey & I %>')"
                                onDragEnd="OnDragEndX('X<%= TypeKey & I %>')"
                                onDrag="OnDragX('X<%= TypeKey & I %>')"
                                STYLE="cursor: move" HEIGHT="12" ALT="Hold down left mouse buton and start moving to drag the object." SRC="drag.jpg" ID="img<%= TypeKey & I %>"></TD>
                            </TR>
                            <TR>
                                <TD NOWARP>
                                <IMG BORDER="0" STYLE="border: 1px solid white" SRC="<%= ImageName %>" STYLE="cursor:hand" " onMouseUp="On<%= TypeKey %>('<%= r(I)(1) %>')"
                                ><B><A 
                        TARGET="DBManM" 
                        HREF="<%= FileName %>?Object=<%= r(I)(1) %>">&nbsp;<FONT COLOR="#FFFFFF"><%= r(I)(1) %></FONT></A></B></TD>
                            </TR>
                            <%
                            For J = 1 To rs.Count
                                %><TR>
                                <% If rs(J)("pk") <> 0 Then %>
                                <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><%= rs(J)("name") %><IMG BORDER="0" SRC="key.gif"></TD>
                                <% Else %>
                                <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><%= rs(J)("name") %></TD>
                                <% End If %>
                                </TR><%
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
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><IMG STYLE="border: 1px solid white; cursor: hand" BORDER="0" SRC="trigger.gif" onMouseUp="Ontrigger('<%= rs(J)("name") %>')"><A 
                                            HREF="deftrigger.asp?Object=<%= rs(J)("name") %>"><%= rs(J)("name") %></A></TD>
                                        <% Else %>
                                        <TD VALIGN="TOP" BGCOLOR="#E0E0E0"><IMG STYLE="border: 1px solid white; cursor: hand" BORDER="0" SRC="index.gif" onMouseUp="Onindex('<%= rs(J)("name") %>')"><A 
                                            HREF="defindex.asp?Object=<%= rs(J)("name") %>"><%= rs(J)("name") %></A></TD>
                                        <% End If %>
                                        </TR><%
                                    Next
                                End If
                            %>
                        </TABLE>
                        </DIV>

                <%
            Next
    End Sub
%>
<html>

<head>
<% LangMetaTag %>
<link rel=stylesheet href="/styles.css" type="text/css">
<title>DBObjects</title>
<SCRIPT>
    var dragged = ""
    var originX = 0, originY = 0;
    var relX = 0, relY = 0;
    function OnDragStartX(el) {
        dragged = el;
        var o = document.all(el);
        //originX = o.style.posLeft;
        //originY = o.style.posTop;
        relX = event.offsetX;
        relY = event.offsetY;
    }
    function OnDragX(el) {
        var o = document.all(el);
        var ob = document.body;
        o.style.posLeft = event.clientX + ob.scrollLeft - relX;
        o.style.posTop = event.clientY + ob.scrollTop - relY;
    }
    function MoveToTop(o,typeKey) {
        var i;
        for (i = 1; document.all("X" + typeKey + i) != null; i++) {
            document.all("X" + typeKey + i).style.zIndex = i;
        }
        o.style.zIndex = i+1;
    }
    function OnDragEndX(el) {
        dragged = "";
        originX = 0;
        originY = 0;
        MoveToTop(document.all(el),"table");
    }
    function OnDivClick(el) {
        MoveToTop(document.all(el),"table");
    }

    var CtxMenuTables,CtxMenuView,CtxMenuIndex,CtxMenuTrigger
    
    var curX = 10,curY = 40,maxY = 0,baseY = 40;
    
    function PosElements(TypeKey) {
        // Deal with the areas
        var i;
        var o;
        var ob = document.body;
        for (i = 1; document.all("X" + TypeKey + i) != null; i++) {
            // alert (typeof(document.all("X" + TypeKey + i)));
            o = document.all("X" + TypeKey + i);
            //alert(o.offsetWidth);
            //o.style.position = "absolute";
            
            document.all("img" + TypeKey + i).style.posWidth = o.offsetWidth;
            //o.style.position = "absolute";
            if (curX + 5 + o.offsetWidth > ob.offsetWidth) {
                // New line
                curY += maxY + 5;
                curX = 10;                
                maxY = 0;
                
            }
            o.style.posTop = curY;
            o.style.posLeft = curX + 5;
            curX += 5 + o.offsetWidth;
            if (maxY < o.offsetHeight) maxY = o.offsetHeight;
            
        }
    }
    function PosElements1(TypeKey) {
        // Deal with the areas
        var i;
        var o;
        var ob = document.body;
        for (i = 1; document.all("X" + TypeKey + i) != null; i++) {
            o = document.all("X" + TypeKey + i);
            if (curX + 5 + o.offsetWidth > ob.offsetWidth) {
                // New line
                curY += maxY + 5;
                curX = 10;                
                maxY = 0;
                
            }
            o.style.posTop = curY;
            o.style.posLeft = curX + 5;
            curX += 5 + o.offsetWidth;
            if (maxY < o.offsetHeight) maxY = o.offsetHeight;
            
        }
    }
    function PosElements2(TypeKey) {
        // Deal with the areas
        var i;
        var o;
        var ob = document.body;
        for (i = 1; document.all("X" + TypeKey + i) != null; i++) {
            o = document.all("X" + TypeKey + i);
            if (curX + 5 + o.offsetWidth > ob.offsetWidth) {
                // New line
                curY = baseY + maxY;
                curX = 10;                
                maxY = 0;
            }
            o.style.posTop = curY;
            o.style.posLeft = curX;
            curX += 50;
            curY += 30;
            if (maxY < o.offsetHeight) maxY = o.offsetHeight;
            
        }
    }
    function ArrangeLines() {
        curX = 10,curY = 40,maxY = 0,baseY = 40;
        PosElements1("table");
        PosElements1("view");
    }
    function ArrangeTile() {
        curX = 10,curY = 40,maxY = 0,baseY = 40;
        PosElements2("table");
        PosElements2("view");
    }
    
    function initPage() {
        CtxMenuTables = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuTable");
        CtxMenuView = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuView");
        CtxMenuIndex = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuIndex");
        CtxMenuTrigger = external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuTrigger");
        
        PosElements("table");
        PosElements("view");
        top.frames["DBManT"].document.frames["DBManT2"].location = "toolbar2-pos.asp";
    }
    function UninitPage() {
        top.frames["DBManT"].document.frames["DBManT2"].location = "toolbar2.asp";
    }
    function Ontable(tbl) {
        //if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuTables.Subs.Count; i++) {
            CtxMenuTables.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuTables,event.screenX,event.screenY);
    }
    function Onview(tbl) {
        //if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuView.Subs.Count; i++) {
            CtxMenuView.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuView,event.screenX,event.screenY);
    }
    function Onindex(tbl) {
        //if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuIndex.Subs.Count; i++) {
            CtxMenuIndex.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuIndex,event.screenX,event.screenY);
    }
    function Ontrigger(tbl) {
        //if (event.button != 2) return;
        var i;
        for (i = 1;i <= CtxMenuTrigger.Subs.Count; i++) {
            CtxMenuTrigger.Subs.ItemByIndex(i).Info = tbl;
        }
        external.DisplayPopupMenu(CtxMenuTrigger,event.screenX,event.screenY);
    }
    function OnBodyDrag() {
        event.returnValue = false;
    }
    
    function DrawLineX(name,pict,thick,x1,y1,x2,y2) {
        var img;
        
        var x,y,stp;
        
        if (Math.abs(y1 - y2) > Math.abs(x1 - x2)) {
            // use y
            // use x
            if (y2 > y1) { 
                stp = 1; 
            } else { 
                stp = -1;
            }
            for (y = y1; y != y2; y += stp) {
                if (y2 == y1) {
                    x = x1 + (x2 - x1)/0.001;
                } else {
                    x = x1 + ((x2 - x1) * (y - y1))/(y2 - y1);
                }
                img = document.createElement("IMG");
                document.body.appendChild(img);
                img.id = name;
                img.src = pict;
                img.style.position = "absolute";
                img.style.posLeft = x;
                img.style.posTop = y;
                img.style.width = thick;
                img.style.height = thick;
                img.style.zIndex = 10000;
            }
        } else {
            // use x
            if (x2 > x1) {
                stp = 1;
            } else { 
                stp = -1;
            }
            for (x = x1; x != x2; x += stp) {
                if (x2 == x1) {
                    y = y1 + (y2 - y1)/0.001;
                } else {
                    y = y1 + ((y2 - y1) * (x - x1))/(x2 - x1) ;
                }
                img = document.createElement("IMG");
                document.body.appendChild(img);
                img.id = name;
                img.src = pict;
                img.style.position = "absolute";
                img.style.posLeft = x;
                img.style.posTop = y;
                img.style.width = thick;
                img.style.height = thick;
                img.style.zIndex = 10000;
                //alert(x + "," + y);
            }
        }
    }
    var lsX,lsY,leX,leY;
    var drawMode = 0;
    function OnLineStart() {
        var lines1 = document.all("Lines");
        var lines2 = document.all("DelLines");
        if ((lines1.options.length + lines2.options.length) > 32) {
            alert("You reached the limit of 32 lines.If ou have some deleted lines you can save the current drawing, reload and continue");
            event.cancelBubble = true;
            return;
        }
        drawMode = 1;
        event.cancelBubble = true;
    }
    function OnLineEnd() {
        // drawMode = 2;
    }
    function OnBodyClick() {
        if (drawMode == 1) {
            lsX = event.clientX + document.body.scrollLeft;
            lsY = event.clientY + document.body.scrollTop;
            drawMode = 2;
        } else if (drawMode == 2) {
            leX = event.clientX + document.body.scrollLeft;
            leY = event.clientY + document.body.scrollTop;
            var clrS = document.all("LineColor");
            var lines = document.all("Lines");
            var clr = clrS.options[clrS.selectedIndex].value;
            var n = lines.options.length;
            DrawLineX("line" + n,clr,2,lsX,lsY,leX,leY);
            var ol = document.createElement("OPTION");
            ol.value = "line" + n;
            ol.text = "line" + n;
            lines.options.add(ol);
            drawMode = 0;
        }
    }
    function OnDeleteLine() {
        var lines = document.all("Lines");
        var line = lines.options[lines.selectedIndex].value;
        var i;
        var ln = document.body.all(line);
        for (i = 0;ln[i] != null;i++) {
            ln[i].style.display = "none";
        }
        var dlines = document.all("DelLines");
        var ol = document.createElement("OPTION");
        ol.value = line;
        ol.text = line;
        dlines.options.add(ol);
        lines.options.remove(lines.selectedIndex);
    }
    function OnUnDeleteLine() {
        var lines = document.all("DelLines");
        if (lines.selectedIndex < 0) return;
        var line = lines.options[lines.selectedIndex].value;
        var i;
        var ln = document.body.all(line);
        for (i = 0;ln[i] != null;i++) {
            ln[i].style.display = "block";
        } 
        var dlines = document.all("Lines");
        var ol = document.createElement("OPTION");
        ol.value = line;
        ol.text = line;
        dlines.options.add(ol);
        lines.options.remove(lines.selectedIndex);
    }
    var warnshown = false;
    function ShowDrawing() {
        var dt = document.all("DrawTB");
        var dti = document.all("DrawTBImg");
        if (dt.style.display == "none") {
            if (!warnshown) {
                alert("Note that this feature consumes a lot of browser resources and may cause troubles on systems with less memory.");
                warnshown = true;
            }
            dt.style.display = "block";
            dti.src = "minus.gif"
        } else {
            dt.style.display = "none";
            dti.src = "plus.gif"
        }
    }
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onLoad="initPage()" onUnload="UninitPage()" onDragOver="OnBodyDrag()" onClick="OnBodyClick()">
<TABLE WIDTH="100%" STYLE="border: 1px outset" BGCOLOR="buttonface" CELLPADDING="0" CELLSPACING="0">
<TR>
<TD NOWRAP><IMG SRC="dbstruct.gif" ALT="Arrange objects on lines" STYLE="cursor: hand; border: 1px outset" onClick="ArrangeLines()"></TD>
<TD NOWRAP>&nbsp;</TD>
<TD NOWRAP><IMG SRC="tile.gif" ALT="Tile objects" STYLE="cursor: hand;border: 1px outset" onClick="ArrangeTile()"></TD>
<TD NOWRAP>&nbsp;</TD>
<TD NOWRAP><IMG SRC="plus.gif" ID="DrawTBImg" ALT="Show/hide drawing tools" STYLE="cursor: hand;border: 1px outset" onClick="ShowDrawing()"></TD>
<TD NOWRAP>
    <TABLE CELLPADDING="0" CELLSPACING="0" ID="DrawTB" STYLE="display: none">
      <TR>
        <TD NOWRAP>&nbsp;New line:</TD>
        <TD NOWRAP><IMG SRC="draw.gif" ALT="Line start" STYLE="cursor: hand" onClick="OnLineStart()"></TD>
        <TD NOWRAP>
        <SELECT ID="LineColor">
            <OPTION VALUE="red.gif">Red</OPTION>
            <OPTION VALUE="green.gif">Green</OPTION>
            <OPTION VALUE="blue.gif">Blue</OPTION>
            <OPTION VALUE="black.gif">black</OPTION>
        </SELECT>
        </TD>
        <TD NOWRAP>&nbsp;</TD>
        <TD NOWRAP><SELECT ID="Lines">
        </SELECT></TD>
        <TD NOWRAP><IMG SRC="del.gif" ALT="Delete line" STYLE="cursor: hand" onClick="OnDeleteLine()"></TD>
        <TD NOWRAP>&nbsp;Deleted lines</TD>
        <TD NOWRAP><SELECT ID="DelLines">
        </SELECT></TD>
        <TD NOWRAP><IMG SRC="edit.gif" ALT="UnDelete line" STYLE="cursor: hand" onClick="OnUnDeleteLine()"></TD>
      </TR>
    </TABLE>
<TD NOWRAP WIDTH="100%">&nbsp;</TD>
</TD>
</TR>
</TABLE>

<% ShowObjects "ShowTables","Tables","table","table.gif","table.asp","name" %>
<% ShowObjects "ShowViews","Views","view","view.gif","view.asp","name" %>

</body>

</html>
<% Else %>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<link rel=stylesheet href="/styles.css" type="text/css">
<title>DBObjects</title>
</head>

<body topmargin="0" leftmargin="0" SCROLL="both">
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