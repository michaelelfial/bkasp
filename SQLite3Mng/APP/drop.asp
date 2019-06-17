<!-- #include file="common.asp" -->
<%
If Request("CONFIRM").Count > 0 Then

    On Error Resume Next
    b = True
    db.Execute "DROP " & Request("Type") & " " & Request("Object") & ";"
    If Err.Number <> 0 Then
        b = False
    End If
    On Error Goto 0
    %>
    <html>

    <head>
    <% LangMetaTag %>
    <link rel=stylesheet href="/styles.css" type="text/css">
    <title>Drop object</title>
    <SCRIPT>
        function ReloadAll() {
            <% If b Then %>
            window.top.location = "/";
            <% End If %>
        }
    </SCRIPT>
    </head>
    
    <body topmargin="0" leftmargin="0" onLoad="ReloadAll()">
    <table WIDTH="100%" HEIGHT="100%" border="0" cellspacing="1">
      <tr>
        <TD WIDTH="100%" HEIGHT="100%" VALIGN="MIDDLE" ALIGN="CENTER">
            <% If b Then %>
                Dropped: <%= Request("Type") & " " & Request("Object") %>
            <% Else %>
                Error: <%= db.LastError %>
            <% End If %>
        </TD>
      </tr>
    </table>
    
    </body>
    
    </html>
    <%
Else
%>
<html>

<head>
<% LangMetaTag %>
<link rel=stylesheet href="/styles.css" type="text/css">
<title>Drop</title>
</head>

<body topmargin="0" leftmargin="0">
<table WIDTH="100%" HEIGHT="100%" border="0" cellspacing="1">
  <tr>
    <TD WIDTH="100%" HEIGHT="100%" VALIGN="MIDDLE" ALIGN="CENTER">
        <H3>Drop database object</H3>
        <FORM METHOD="POST" ACTION="<%= Self %>">
            <INPUT TYPE="HIDDEN" NAME="Type" VALUE="<%= Request("Type") %>">
            <INPUT TYPE="HIDDEN" NAME="Object" VALUE="<%= Request("Object") %>">
            <B>Are you sure you want to drop (delete) the following database object?</B><BR>
            <BR>
            <B><%= Request("Type") & " " & Request("Object") %></B>
            <HR COLOR="0" SIZE="1" WIDTH="200">
            <INPUT style="width:100" TYPE="SUBMIT" NAME="CONFIRM" VALUE="Yes">
            <INPUT style="width:100" TYPE="BUTTON" VALUE="Cancel" onClick="window.location='blank.asp'">
            <HR COLOR="0" SIZE="1" WIDTH="200">
            <I>Note that this may cause other objects to be deleted. For example dropping a table automatically drops its indices and triggers.</U>
        </FORM>
    </TD>
  </tr>
</table>

</body>

</html>
<% End If %>