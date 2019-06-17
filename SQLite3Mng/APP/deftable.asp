<!-- #include file="common.asp" -->
<%
    ErrText = ""
    Set cr = Server.CreateObject("newObjects.utilctls.Pack1Creator")
    EditIndex = 0

    Object = CStr(Request("Object"))
    Set table = cr.CreateObject(Server.MapPath("SQLiteTable.comp"))
    'Set table = cr.CreateObject("newObjects.composite.SQLiteTable")
    table.ComponentsPath = Server.MapPath(".")
    Set table.db = db
    
    Sub TypeSelect(cur)
        Dim arr,I
        arr = Split(Application("TYPES"),",")
        %><OPTION VALUE=""></OPTION><%
        For I = LBound(arr) To UBound(arr)
            If UCase(cur) = arr(I) Then
            %><OPTION SELECTED VALUE="<%= arr(I) %>"><%= arr(I) %></OPTION><%
            Else
            %><OPTION VALUE="<%= arr(I) %>"><%= arr(I) %></OPTION><%
            End If
        Next
    End Sub
    
    
    If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
        'For I = 1 To Request.Form.Count
        '    Response.Write Request.Form.Key(I) & "="
        '    For J = 1 To Request.Form(I).Count
        '        Response.Write Request.Form(I)(J) & ","
        '    Next
        '    Response.Write "<BR>"
        'Next
        
        If Request("IsNewTable").Count Then IsNewTable = True
        
        ' Refill from the submitted data
        table.TableName = Request("TableName")
        For I = 1 To Request("Field").Count
            If Request("Field")(I) <> "" Then
                table.AddColumn Request("Field")(I),Request("Type")(I),Empty,False,False,Empty
            End If
        Next
        On Error Resume Next
        For I = 1 To Request("NotNull").Count
            table.Column(CLng(Request("NotNull")(I)))("NotNull") = True
            If Err.Number <> 0 Then ErrText = Err.Description
        Next
        For I = 1 To Request("PrimaryKey").Count
            table.Column(CLng(Request("PrimaryKey")(I)))("PrimaryKey") = True
            If Err.Number <> 0 Then ErrText = Err.Description
        Next
        For I = 1 To Request("Default").Count
            If Request("Default")(I) <> "" Then
                table.Column(I)("Default") = Request("Default")(I)
                If Err.Number <> 0 Then ErrText = Err.Description
            End If
        Next
        On Error Goto 0
        If Err.Number <> 0 Then
            ErrText = Err.Description
        End If
        EditIndex = CLng(Request("EditIndex"))
        Select Case CStr(Request("DO"))
            Case "DELETE"
                table.DelColumn EditIndex
                EditIndex = 0
            Case "ADD"
                EditIndex = 0
            Case "CHANGE"
                EditIndex = 0
            Case "SAVE"
                If IsNewTable Then
                    If table.CreateTable Then
                        ErrText = "Table " & table.TableName & " has been created."
                        IsNewTable = False
                    Else
                        ErrText = "FAILED to create table " & table.TableName & ". " & table.LastError
                    End If
                Else
                    If table.ChangeTable Then
                        ErrText = "Table " & table.TableName & " has been changed."
                    Else
                        ErrText = "FAILED to change table " & table.TableName & ". " & table.LastError
                    End If
                    IsNewTable = False ' Just in case
                End If
                RefreshContents = "dbobjects.asp"
        End Select
        
    Else
        ' Called for the first time
        ' Try to read from the database
        If Object = "" Then
            ' New table
            IsNewTable = True
        Else
            IsNewTable = False
            If Not table.Open(Object) Then
                ErrText = "Cannot open table " & Object & "<BR>" & table.LastError
            Else
                
            End If
        End If
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
    function OnTypeChange(i) {
        var newType = document.all("TypeSel" + i).options[document.all("TypeSel" + i).selectedIndex].value;
        if (newType == "AUTONUMBER") {
            document.all("Type" + i).value = "INTEGER";
            document.all("PrimaryKey" + i).checked = true;
            document.all("NotNull" + i).checked = false;            
        } else {
            document.all("Type" + i).value = newType;
        }
    }
    function ReSubmit(i,act) {
        document.forms["Main"].EditIndex.value = i;
        document.forms["Main"].DO.value = act;
        document.forms["Main"].submit();
    }
    <% If RefreshContents <> "" Then %>
        window.top.frames["DBManC"].location = "<%= RefreshContents %>"
    <% End If %>
    
</SCRIPT>
</head>

<body topmargin="0" leftmargin="0" onMouseUp="onShortcutMenu()">
<FORM METHOD="POST" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>" NAME="Main">
    <INPUT TYPE="HIDDEN" NAME="EditIndex" VALUE="<%= EditIndex %>">
    <INPUT TYPE="HIDDEN" NAME="DO" VALUE="Reload">
    <% If IsNewTable Then %>
        <INPUT TYPE="HIDDEN" NAME="IsNewTable" VALUE="1">
    <% End If %>
    <table border="0" bgcolor="#004080" cellspacing="1">
        <tr>
            <TH COLSPAN="6" NOWRAP ALIGN="LEFT">
                <FONT COLOR="#FFFFFF">Table:</FONT>
                <% If IsNewTable Then %>
                    <INPUT TYPE="TEXT" NAME="TableName" SIZE="80" VALUE="<%= table.TableName %>">
                <% Else %>
                    <FONT COLOR="#FFFF00"><%= table.TableName %></FONT>
                    <INPUT TYPE="HIDDEN" NAME="TableName" VALUE="<%= table.TableName %>">
                <% End If %>
            </TH>
        </tr>
        <tr>
            <tH NOWRAP ALIGN="CENTER">
                &nbsp;
            </TH>
            <tH NOWRAP ALIGN="CENTER">
                <FONT COLOR="#FFFFFF">Field name</FONT>
            </TH>
            <tH NOWRAP ALIGN="CENTER">
                <FONT COLOR="#FFFFFF">Field type</FONT>
            </TH>
            <tH NOWRAP ALIGN="CENTER">
                <FONT COLOR="#FFFFFF">Not null</FONT>
            </TH>
            <tH NOWRAP ALIGN="CENTER">
                <FONT COLOR="#FFFFFF">Default value</FONT>
            </TH>
            <tH NOWRAP ALIGN="CENTER">
                <FONT COLOR="#FFFFFF">Primary key</FONT>
            </TH>
         </tr>
        <%
            For I = 1 To table.ColumnCount
            If EditIndex = I Then
            %>
              <tr>
                <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0E0">
                    <% If EditIndex = I Then %>
                        <IMG ALT="Delete this column" SRC="del.gif" STYLE="cursor:hand" onClick="ReSubmit(<%= I %>,'DELETE')">
                        <IMG ALT="Submit changes" SRC="ok.gif" STYLE="cursor:hand" onClick="ReSubmit(<%= I %>,'CHANGE')">
                    <% End If %>
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <INPUT TYPE="TEXT" NAME="Field" VALUE="<%= table.Column(I)("Name") %>">
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <INPUT TYPE="TEXT" NAME="Type" VALUE="<%= table.Column(I)("Type") %>" ID="Type<%= I %>">
                    <SELECT ID="TypeSel<%= I %>" OnChange="OnTypeChange(<%= I %>)">
                        <% TypeSelect table.Column(I)("Type") %>
                    </SELECT>
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <% If table.Column(I)("NotNull") Then %>
                        <INPUT TYPE="CHECKBOX" NAME="NotNull" VALUE="<%= I %>" CHECKED ID="NotNull<%= I %>">
                    <% Else %>
                        <INPUT TYPE="CHECKBOX" NAME="NotNull" VALUE="<%= I %>" ID="NotNull<%= I %>">
                    <% End If %>
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <INPUT TYPE="TEXT" NAME="Default" VALUE="<%= table.Column(I)("Default") %>">
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <% If table.Column(I)("PrimaryKey") Then %>
                        <INPUT TYPE="CHECKBOX" NAME="PrimaryKey" VALUE="<%= I %>" CHECKED ID="PrimaryKey<%= I %>">
                    <% Else %>
                        <INPUT TYPE="CHECKBOX" NAME="PrimaryKey" VALUE="<%= I %>" ID="PrimaryKey<%= I %>">
                    <% End If %>
                </td>
              </tr>
           <% Else %>
              <tr>
                <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0E0">
                    <IMG ALT="Edit this column" SRC="edit.gif" STYLE="cursor:hand" onClick="ReSubmit(<%= I %>,'EDIT')">
                </td>
                <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0F0" STYLE="border: 1px inset">
                    <INPUT TYPE="HIDDEN" NAME="Field" VALUE="<%= table.Column(I)("Name") %>">
                    <%= table.Column(I)("Name") %>
                </td>
                <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0F0" STYLE="border: 1px inset">
                    <INPUT TYPE="HIDDEN" NAME="Type" VALUE="<%= table.Column(I)("Type") %>">
                    <%= table.Column(I)("Type") %>
                </td>
                <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0F0" STYLE="border: 1px inset">
                    <% If table.Column(I)("NotNull") Then %>
                        Not Null
                        <INPUT TYPE="HIDDEN" NAME="NotNull" VALUE="<%= I %>">
                    <% Else %>
                        &nbsp;
                    <% End If %>
                </td>
                <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0F0" STYLE="border: 1px inset">
                    <INPUT TYPE="HIDDEN" NAME="Default" VALUE="<%= table.Column(I)("Default") %>">
                    <%= table.Column(I)("Default") %>
                </td>
                <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0F0" STYLE="border: 1px inset">
                    <% If table.Column(I)("PrimaryKey") Then %>
                        PRIMARY KEY
                        <INPUT TYPE="HIDDEN" NAME="PrimaryKey" VALUE="<%= I %>">
                    <% Else %>
                        &nbsp;
                    <% End If %>
                </td>
              </tr>
           <% End If %>
        <%
            Next
        %>
        <% If EditIndex = 0 Then %>
            <tr>
                <td NOWRAP ALIGN="LEFT" BGCOLOR="#E0E0E0">
                    <IMG ALT="Add new column" SRC="ok.gif" STYLE="cursor:hand" onClick="ReSubmit(0,'ADD')">
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <INPUT TYPE="TEXT" NAME="Field" VALUE="">
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <INPUT TYPE="TEXT" NAME="Type" VALUE="" ID="Type<%= table.ColumnCount + 1 %>">
                    <SELECT ID="TypeSel<%= table.ColumnCount + 1 %>" OnChange="OnTypeChange(<%= table.ColumnCount + 1 %>)">
                        <% TypeSelect "" %>
                    </SELECT>
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <INPUT TYPE="CHECKBOX" NAME="NotNull" VALUE="<%= table.ColumnCount + 1 %>" ID="NotNull<%= table.ColumnCount + 1 %>">
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <INPUT TYPE="TEXT" NAME="Default" VALUE="">
                </td>
                <td NOWRAP ALIGN="LEFT">
                    <INPUT TYPE="CHECKBOX" NAME="PrimaryKey" VALUE="<%= table.ColumnCount + 1 %>" ID="PrimaryKey<%= table.ColumnCount + 1 %>">
                </td>
            </tr>
        <% End If %>
      <tr>
         <td COLSPAN="6" bgcolor="#FFFFFF" align="RIGHT" NOWRAP>
            <TABLE WIDTH="100%">
                <TR>
                    <TD WIDTH="100%" VALIGN="MIDDLE" ALIGN="CENTER">&nbsp;<FONT COLOR="#FF0000"><%= ErrText %></FONT></TD>
                    <TD WIDTH="200">
                        <B>Warning!</B><BR>
                        When changing table definition the data in any renamed column will be lost!
                        <input style="width: 200" type="BUTTON" value="Save" onClick="ReSubmit(0,'SAVE')">
                    </TD>
                </TR>
            </TABLE>
         </td>
      </tr>
    </table>
</FORM>          

</body>

</html>
