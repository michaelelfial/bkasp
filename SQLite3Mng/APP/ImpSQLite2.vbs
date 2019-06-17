Context("Complete") = False

Dim db
Set db = Context("db")
Dim db2
Set db2 = Creator.CreateObject("newObjects.sqlite.dbutf8")
db2.Open Context("File")
Dim su
Set su = Creator.CreateObject("StringUtilities")

Sub DoImport(tbl)
    
    Dim r
    Dim I, J, nCur, line, Delimiter
    
    Set r = db.Execute("PRAGMA table_info(" & tbl & ")")
    line = "INSERT INTO " & tbl & " ("
    For I = 1 To r.Count
        line = line & r(I)("name")
        If I < r.Count Then line = line & ","
    Next
    line = line & ") VALUES ("
    
    Dim sql
    
    nCur = 1
    Do
        Set r = db2.Execute("SELECT * FROM " & tbl,nCur,100)
        If r.Count > 0 Then
            db.Execute "BEGIN TRANSACTION"
            For I = 1 To r.Count
                sql = line
                For J = 1 To r(I).Count
                    Select Case VarType(r(I)(J))
                        Case vbDouble
                            sql = sql & su.Sprintf("%M",r(I)(J))
                        Case vbNull
                            sql = sql & "Null"
                        Case vbString
                            sql = sql & su.Sprintf("%q",r(I)(J))
                        Case vbLong
                            sql = sql & su.Sprintf("%d",r(I)(J))
                        Case vbInteger
                            sql = sql & su.Sprintf("%d",r(I)(J))
                        Case Else
                            sql = sql & su.Sprintf("%Na",r(I)(J))
                    End Select
                    If J < r(I).Count Then sql = sql & ","
                Next
                sql = sql & ");"
                Context("Progress") = "Importing record " & nCur & " from table: " & tbl
                db.Execute sql
                nCur = nCur + 1
            Next
            db.Execute "COMMIT TRANSACTION"
        Else
            Exit Do
        End If
    Loop
End Sub

Set rt = db2.Execute("SELECT * FROM sqlite_master")
For T = 1 To rt.Count
    If rt(T)("type") <> "index" Then
        On Error Resume Next
        db.Execute rt(T)("sql")
        If rt(T)("type") = "table" Then
            DoImport rt(T)("name")
        End If
        On Error Goto 0
    End If
Next

db2.Close

Context("Complete") = True