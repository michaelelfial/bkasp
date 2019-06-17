<!-- #include file="common.asp" -->
<%
    If Request("NoteID").Count > 0 Then
        db.VExecute "DELETE FROM SysDBMan_Notes WHERE NoteID=$1",1,0,CLng(Request("NoteID"))
    End If
%>
<html>

<head>
<% LangMetaTag %>
<link rel=stylesheet href="/styles.css" type="text/css">
<title>Table</title>
<SCRIPT>
   
        window.top.frames["DBManC"].location = "dbobjects.asp"
    
</SCRIPT>
</head>
<body topmargin="0" leftmargin="0">

</body>

</html>