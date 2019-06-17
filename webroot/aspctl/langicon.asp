<!-- #include file="aspctl.asp" -->
<%
    Set r = ASPCTLResDB.VExecute("SELECT ICON FROM Languages WHERE Language=$l",1,1,NullConvertTo(vbString,ASPGET("lang")))
    Response.ContentType = "image/gif"
    If r.Count > 0 Then
        Response.BinaryWrite r(1)("ICON")
    End If
%>