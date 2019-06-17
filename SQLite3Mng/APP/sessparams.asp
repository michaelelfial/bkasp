<!-- #include file="common.asp" -->
<%
    EnsureTableExistsSysParams
    
    ' Custom functions
    Function cvtToText(v)
        If VarType(v) = vbDate Then
            cvtToText = su.Sprintf("%lT",v)
        Else
            On Error Resume Next
            cvtToText = su.Sprintf("%Na",v)
            If Err.Number <> 0 Then
                cvtToText = ""
            End If
        End If
    End Function
    
    Dim PN,PT,PV
    
    If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
        db.Execute "DELETE FROM SysDBMan_SessionParams"
        db.Parameters.Clear
        
        ' put all the values again
        For I = 1 To Request("PN").Count + 1
            If I <= Request("PN").Count Then
                PN = Request("PN")(I)
                PT = CLng(Request("PT")(I))
                PV = Request("PV")(I)
            Else
                PN = Request("PN.New")
                PT = CLng(Request("PT.New"))
                PV = Request("PV.New")
            End If
        
            If PN <> "" Then
                On Error Resume Next
                If PT = vbDate Then
                    db.VExecute "INSERT INTO SysDBMan_SessionParams (ParamName,ParamType,ParamVal) VALUES " & _
                                "($1, $2, ParseOleDate($3));",1,0,PN,PT,PV
                ElseIf PT = vbNull Then
                    db.VExecute "INSERT INTO SysDBMan_SessionParams (ParamName,ParamType,ParamVal) VALUES " & _
                                "($1, $2, Null);",1,0,PN,PT
                Else
                    db.VExecute "INSERT INTO SysDBMan_SessionParams (ParamName,ParamType,ParamVal) VALUES " & _
                                "($1, $2, $3);",1,0,PN,PT,PV
                End If
                On Error Goto 0
            End If
        Next
        
        Set r = db.Execute("SELECT * FROM SysDBMan_SessionParams")
        For I = 1 To r.Count
            db.Parameters.Add r(I)("ParamName"), r(I)("ParamVal")
        Next
        
        If Request("RefDate") <> "" Then
            dt = ParseOleDate(Request("RefDate"))
            If Not IsNull(dt) Then db.Parameters.ReferenceDate = dt
        End If
        
        If Request("UseRefDate").Count > 0 Then
            db.Parameters.UseReferenceDate = True
        Else
            db.Parameters.UseReferenceDate = False
        End If
        
    End If
    
    Set r = db.Execute("SELECT * FROM SysDBMan_SessionParams")
    
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
<CENTER>
    <H4>Session parameters</H4>
    
    
    <INPUT TYPE="CHECKBOX" NAME="UseRefDate" VALUE="ON" ID="UseRefDate" <%= BChecked(db.Parameters.UseReferenceDate) %> >
    <LABEL FOR="UseRefDate">Use reference date</LABEL>
    <INPUT TYPE="TEXT" NAME="RefDate" VALUE="<%= su.Sprintf("%lT",db.Parameters.ReferenceDate) %>">
    <BR>
    
    <table ID="MT" border="0" bgcolor="#808080" cellspacing="0" CELLPADDING="0" style="border: 1px solid">
        <tr>
            <th bgcolor="#406040" nowrap>
                &nbsp;</th>
            <th bgcolor="#406040" nowrap>
                <font color="#FFFFFF">Parameter name</font></th>
            <th bgcolor="#406040" nowrap>
                <font color="#FFFFFF">Type</font></th>
            <th bgcolor="#406040" nowrap>
                <font color="#FFFFFF">Value</font></th>
        </tr>
        <% If r.Count > 0 Then %>
            <% For row = 1 To r.Count %>
            <tr>
                <td VALIGN="TOP" bgcolor="#C0C0C0">&nbsp;</td>
                <td VALIGN="TOP" bgcolor="#C0C0C0">
                    <INPUT SIZE="10" CLASS="insetedit" TYPE="TEXT" NAME="PN" VALUE="<%= r(Row)("ParamName") %>">
                </td>
                <td VALIGN="TOP" bgcolor="#C0C0C0">
                    <SELECT NAME="PT">
                        <% For I = 1 To SesParamTypes.Count %>
                            <% If r(row)("ParamType") = SesParamTypes(I) Then %>
                                <OPTION VALUE="<%= SesParamTypes(I) %>" SELECTED><%= SesParamTypes.Key(I) %></OPTION>
                            <% Else %>
                                <OPTION VALUE="<%= SesParamTypes(I) %>"><%= SesParamTypes.Key(I) %></OPTION>
                            <% End If %>
                        <% Next %>
                    </SELECT>
                </td>
                <td VALIGN="TOP" bgcolor="#C0C0C0">
                    <INPUT SIZE="32" CLASS="insetedit" TYPE="TEXT" NAME="PV" VALUE="<%= cvtToText(r(row)("ParamVal")) %>">
                </td>
            </tr>
            <% Next %>
        <% End If %>
            <tr>
                <td VALIGN="TOP" bgcolor="#C0C0C0"><font color="#000000">Add new:</font></td>
                <td VALIGN="TOP" bgcolor="#C0C0C0">
                    <INPUT SIZE="10" CLASS="insetedit" TYPE="TEXT" NAME="PN.New" VALUE="<%= Request("PN.New") %>">
                </td>
                <td VALIGN="TOP" bgcolor="#C0C0C0">
                    <SELECT NAME="PT.New">
                        <% For I = 1 To SesParamTypes.Count %>
                            <% If vbString = SesParamTypes(I) Then %>
                                <OPTION VALUE="<%= SesParamTypes(I) %>" SELECTED><%= SesParamTypes.Key(I) %></OPTION>
                            <% Else %>
                                <OPTION VALUE="<%= SesParamTypes(I) %>"><%= SesParamTypes.Key(I) %></OPTION>
                            <% End If %>
                        <% Next %>
                    </SELECT>
                </td>
                <td VALIGN="TOP" bgcolor="#C0C0C0">
                    <INPUT SIZE="32" CLASS="insetedit" TYPE="TEXT" NAME="PV.New" VALUE="<%= Request("PV.New") %>">
                </td>
            </tr>
            <tr>
                <td VALIGN="TOP" bgcolor="#C0C0C0" colspan="4" ALIGN="Right">
                    <HR>
                </td>
            </tr>
            <tr>
                <td VALIGN="TOP" bgcolor="#C0C0C0" colspan="4" ALIGN="Right">
                    <INPUT TYPE="SUBMIT" VALUE="SAVE">                    
                </td>
            </tr>
    </table>
</CENTER>
</FORM>  
<I>Note that the ReferenceDate settings are not saved!</I>        
</body>

</html>
