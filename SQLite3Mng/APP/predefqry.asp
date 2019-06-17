<!-- #include file="common.asp" -->
<%
    If Not db.IsOpened Then
        Response.Redirect "sqlconsole.asp"
    Else
        bInfo = False
        On Error Resume Next
        Set r = db.Execute("PRAGMA table_info(" & Request("Object") & ");")
        If Err.Number = 0 Then
            If r.Count > 0 Then bInfo = True
        End If
        On Error Goto 0
        str = ""
        If bInfo Then
            Select Case UCase(Request("Type"))
                Case "SELECT"
                    str = "SELECT "
                    For I = 1 To r.Count
                        str = str & r(I)("name")
                        If I < r.Count Then str = str & ","
                    Next
                    str = str & " FROM " & Request("Object") & " WHERE ... ;"
                Case "UPDATE"
                    str = "UPDATE " & Request("Object") & " SET "
                    For I = 1 To r.Count
                        str = str & r(I)("name") & "="
                        If I < r.Count Then str = str & ","
                    Next
                    str = str & " WHERE ... ;"
                Case "INSERT"
                    str = "INSERT INTO " & Request("Object") & " ("
                    For I = 1 To r.Count
                        str = str & r(I)("name")
                        If I < r.Count Then str = str & ","
                    Next
                    str = str & ") VALUES ("
                    For I = 1 To r.Count
                        If I < r.Count Then str = str & ","
                    Next
                    str = str & ");"
                Case "DELETE"
                    str = "DELETE FROM " & Request("Object") & " WHERE "
                    For I = 1 To r.Count
                        str = str & r(I)("name") & " "
                        If I < r.Count Then str = str & " AND "
                    Next
                    str = str & ";"
                Case "COPYTABLE"
                    str = "CREATE TABLE CopyOf_" & Request("Object") & " AS SELECT * FROM " & Request("Object") & ";"
                Case "GETDATA"
                    str = "INSERT INTO [" & Request("Object") & "] ("
                    For I = 1 To r.Count
                        str = str & "[" & r(I)("name") & "]"
                        If I < r.Count Then str = str & ","
                    Next
                    str = str & ") SELECT "
                    For I = 1 To r.Count
                        str = str & "[" & r(I)("name") & "]"
                        If I < r.Count Then str = str & ","
                    Next
                    str = str & " FROM CopyOf_" & Request("Object") & vbCrLf
                    str = str & "-- Change the table names or make other adjustments if needed"                    
            End Select
        Else
            Select Case UCase(Request("Type"))
                Case "SELECT"
                    str = "SELECT * FROM " & Request("Object") & " WHERE ... ;"
                Case "UPDATE"
                    str = "UPDATE " & Request("Object") & " SET ... WHERE ...;"
                Case "INSERT"
                    str = "INSERT INTO " & Request("Object") & " (...) VALUES (...);"
                Case "DELETE"
                    str = "DELETE FROM " & Request("Object") & " WHERE ...;"
            End Select
        End If
    End If
    Response.Redirect "sqlconsole.asp?QUERY=" & str
%>