<!-- #include virtual="/common.asp" -->
<%
    ' Response.ContentType = "text/plain"
    b = EnsureTableExistsSysSchemPositions
    b = EnsureTableExistsSysSchemDrawings
    
    Msg = ""
    Saving = "false"
    If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
        ' Save the positions
        Saving = "true"
        On Error Resume Next
        db.Execute "BEGIN TRANSACTION;"
        db.Execute "DELETE FROM SysDBMan_SchemePositions"
        For I = 1 To Request("Name").Count
            If Request("X")(I) <> "" AND Request("Y")(I) <> "" Then
                db.Execute(su.Sprintf("INSERT INTO SysDBMan_SchemePositions (Name,Type,X,Y) VALUES (%q,%q,%d,%d);", _
                           Request("Name")(I),Request("Type")(I),Request("X")(I),Request("Y")(I)))
                If Err.Number <> 0 Then Response.Write "Err: " & db.LastError & "<BR>"                           
            End If
        Next
        arr = Split(Request("Lines"),";")
        db.Execute "DELETE FROM SysDBMan_SchemeDrawings"
        If IsArray(arr) Then
            For I = LBound(arr) To UBound(arr)
                db.Execute(su.Sprintf("INSERT INTO SysDBMan_SchemeDrawings (Line) VALUES (%q);",arr(I)))
                If Err.Number <> 0 Then Response.Write "ErrL: " & db.LastError & "<BR>"                           
            Next
        End If
        db.Execute "COMMIT TRANSACTION;"
        On Error Goto 0
        Msg = "The postions have been saved"
    End If
%>
<html>

<head>
<% LangMetaTag %>
<title>Toolbar</title>
<link rel=stylesheet href="/stylestb.css" type="text/css">
<base target="DBManM">
<SCRIPT>
    function FindIndex(arr) {
        var i;
        var names = document.all("Name");
        var types = document.all("Type");
        for (i = 0; i < names.length; i++) {
            if (names[i].value == arr[0] && types[i].value == arr[1]) return i;
        }
        return -1;
    }
    function TransferPositions(TypeKey) {
        // Deal with the areas
        var doc = top.frames["DBManM"].document;
        var i;
        var o;
        var s;
        var arr;
        var idx;
        var fname,ftype,fx,fy;
        var ob = doc.body;
        for (i = 1; doc.all("X" + TypeKey + i) != null; i++) {
            // alert (typeof(document.all("X" + TypeKey + i)));
            o = doc.all("X" + TypeKey + i);
            s = o.title;
            arr = s.split(",");
            idx = FindIndex(arr);
            if (idx >= 0) {
                fname = document.all("Name")[idx];
                ftype = document.all("Type")[idx];
                fx = document.all("X")[idx];
                fy = document.all("Y")[idx];
            
                fx.value = o.offsetLeft + o.clientLeft; // + ob.scrollLeft;
                fy.value = o.offsetTop + o.clientTop; // + ob.scrollTop;
                //alert(arr + " :" + fname.value + " " + fx.value + ";" + fy.value);
            } 
        }
    }
    function RestorePositions(TypeKey) {
        // Deal with the areas
        var doc = top.frames["DBManM"].document;
        var i;
        var o;
        var s;
        var arr;
        var idx;
        var fname,ftype,fx,fy;
        var ob = doc.body;
        for (i = 1; doc.all("X" + TypeKey + i) != null; i++) {
            // alert (typeof(document.all("X" + TypeKey + i)));
            o = doc.all("X" + TypeKey + i);
            s = o.title;
            arr = s.split(",");
            idx = FindIndex(arr);
            if (idx >= 0) {
                fname = document.all("Name")[idx];
                ftype = document.all("Type")[idx];
                fx = document.all("X")[idx];
                fy = document.all("Y")[idx];
                if (fx.value != "" && fy.value != "") {
                    o.style.posLeft = parseFloat(fx.value);
                    o.style.posTop = parseFloat(fy.value);
                }
            }
        }
    }
    function RestoreLines() {
        var str = document.forms["TBForm"].Lines.value;
        var i;
        var arr;
        var doc = top.frames["DBManM"].document;
        if (str != "") {
            var arrLines = str.split(";");
            for (i = 0; i < arrLines.length; i++) {
                arr = arrLines[i].split(",");
                top.frames["DBManM"].DrawLineX("line" + i,arr[4],2,parseFloat(arr[0]),parseFloat(arr[1]),parseFloat(arr[2]),parseFloat(arr[3]));
                var lines = doc.all("Lines");
                var ol = doc.createElement("OPTION");
                ol.value = "line" + i;
                ol.text = "line" + i;
                lines.options.add(ol);
            }
        }
    }
    function TransferLines() {
        var i;
        var str = "";
        var o;
        var doc = top.frames["DBManM"].document;
        for (i = 0; doc.all("line" + i) != null; i++) {
            o = doc.all("line" + i);
            if (typeof(o.length) != "undefined") {
                if (o[0].style.display != "none") {
                    str += o[0].style.posLeft + "," + o[0].style.posTop + "," + o[o.length - 1].style.posLeft + "," + o[o.length - 1].style.posTop + "," + o[0].src + ";";
                }
                //alert(str);
            } 
        }
        str = str.slice(0,str.length - 1);
        document.forms["TBForm"].Lines.value = str;
    }
    function RestorePos() {
        if (!<%= Saving %>) {
            RestorePositions("table");
            RestorePositions("view");
            RestoreLines();
        }
    }
    function SavePos() {
        TransferPositions("table");
        TransferPositions("view");
        TransferLines();
        document.forms["TBForm"].submit();
    }
</SCRIPT>
</head>
<body BGCOLOR="buttonface" text="buttontext" topmargin="0" leftmargin="0" onLoad="RestorePos()">
<TABLE CELLPADDING="0" CELLSPACING="0" HEIGHT="100%" WIDTH="100%"><TR>
    <FORM NAME="TBForm" TARGET="_self" METHOD="POST" ACTION="<%= Self %>">
    <%
        Set r = db.Execute("SELECT M.type AS Type,M.name AS name, P.X AS X,P.Y AS Y FROM sqlite_master AS M LEFT OUTER JOIN  SysDBMan_SchemePositions AS P ON P.name=M.name AND P.type=M.type WHERE M.type='table' OR M.type='view'")
        For I = 1 To r.Count
            %>
            <INPUT TYPE="HIDDEN" NAME="Name" ID="Name" VALUE="<%= r(I)("Name") %>">
            <INPUT TYPE="HIDDEN" NAME="Type" ID="Type" VALUE="<%= r(I)("Type") %>">
            <% If IsNull(r(I)("X")) Or IsNull(r(I)("Y")) Then %>
                <INPUT TYPE="HIDDEN" NAME="X" ID="X" VALUE="">
                <INPUT TYPE="HIDDEN" NAME="Y" ID="Y" VALUE="">
            <% Else %>
                <INPUT TYPE="HIDDEN" NAME="X" ID="X" VALUE="<%= r(I)("X") %>">
                <INPUT TYPE="HIDDEN" NAME="Y" ID="Y" VALUE="<%= r(I)("Y") %>">
            <% End If %>
            <%
        Next
        Set r = db.Execute("SELECT Line FROM SysDBMan_SchemeDrawings",1,32)
        str = ""
        For I = 1 To r.Count
            str = str & r(I)(1)
            If I < r.Count Then str = str & ";"
        Next
        %>
        <INPUT TYPE="HIDDEN" NAME="Lines" VALUE="<%= str %>">
    <TD VALIGN="MIDDLE" NOWRAP STYLE="border: 1px inset">&nbsp;</TD>
    <TD VALIGN="MIDDLE" NOWRAP>&nbsp;Object positions:&nbsp;</TD>
    <TD VALIGN="MIDDLE" NOWRAP>
    <INPUT TYPE="HIDDEN" VALUE="Restore" onClick="RestorePos()">
    <INPUT TYPE="BUTTON" VALUE="Save" onClick="SavePos()">
    </TD>
    <% If Msg <> "" Then %>
        <TD WIDTH="100%" VALIGN="MIDDLE" NOWRAP><%= Msg %></TD>
    <% Else %>
        <TD WIDTH="100%" VALIGN="MIDDLE" NOWRAP>&nbsp;</TD>
    <% End If %>
    </FORM>
</TR></TABLE>
</body>

</html>
