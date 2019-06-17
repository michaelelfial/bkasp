Context("Complete") = False

Sub DoExport
    Dim db
    Set db = Context("db")
    Dim sf, su
    Set sf = Creator.CreateObject("SFMain")
    Set su = Creator.CreateObject("StringUtilities")
    Dim file
    Set file = sf.CreateFile(Context("File"))
    Dim r
    Dim I, J, nCur, line, Delimiter
    
    Delimiter = Context("Delimiter")
    If Delimiter = "tab" Then Delimiter = vbTab
    
    Set r = db.Execute("PRAGMA table_info(" & Context("Table") & ")")
    line = ""
    For I = 1 To r.Count
        line = line & r(I)("name") & ":" & r(I)("type") & ":" & r(I)("pk") & ":" & r(I)("notnull")
        If I < r.Count Then line = line & Delimiter
    Next
    file.WriteText line, 1
    
    nCur = 1
    Do
        Set r = db.Execute("SELECT * FROM " & Context("Table"),nCur,100)
        If r.Count > 0 Then
            For I = 1 To r.Count
                line = ""
                For J = 1 To r(I).Count
                    Select Case UCase(r(I).Info(J))
                        Case "INTEGER"
                            line = line & su.Sprintf("%d",r(I)(J))
                        Case "REAL"
                            line = line & su.Sprintf("%M",r(I)(J))
                        Case "TEXT"
                            line = line & su.Sprintf("%Q",r(I)(J))
                        Case "BLOB"
                            line = line & ""
                        Case "NULL"
                            line = line & "Null"
                        Case Else
                            line = line & su.Sprintf("%Na",r(I)(J))
                    End Select
                    If J < r(I).Count Then line = line & Delimiter
                Next
                file.WriteText line, 1
                Context("Progress") = "Exporting record " & nCur
                nCur = nCur + 1
            Next
        Else
            Exit Do
        End If
    Loop
    file.Close
End Sub

DoExport

Context("Complete") = True