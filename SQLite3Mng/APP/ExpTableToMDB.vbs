Context("Complete") = False

Sub DoExport
    Dim db
    Set db = Context("db")
    Dim mdb, su
    Set su = Creator.CreateObject("StringUtilities")
    Set mdb = Creator.CreateObject("ADODB.Connection")
    mdb.Open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Context("File") & ";"
    
    Dim r,arrColTypes
    Dim I, J, nCur, line, insline
    If Context("ColTypes") <> "" Then
        arrColTypes = Split(Context("ColTypes"),",")
    End If
    
    Dim rst
    Set rst = Creator.CreateObject("ADODB.Recordset")
    
    nCur = 1
    Do
        Set r = db.Execute("SELECT * FROM " & Context("Table"),nCur,100)
        If r.Count > 0 Then
            If nCur = 1 Then
                ' Create the table
                line = "CREATE TABLE [" & Context("Table") & "] ("
                For I = 1 To r(1).Count
                    If IsArray(arrColTypes) Then
                        line = line & r(1).Key(I) & " " & arrColTypes(I - 1)
                    Else
                        Select Case UCase(r(1).Key(I))
                            Case "INTEGER"
                                line = line & r(1).Key(I) & " INTEGER"
                            Case "REAL"
                                line = line & r(1).Key(I) & " DOUBLE"
                            Case "TEXT"
                                line = line & r(1).Key(I) & " TEXT"
                            Case "BLOB"
                                line = line & r(1).Key(I) & " BINARY"
                            Case Else
                                line = line & r(1).Key(I) & " TEXT"
                        End Select
                    End If
                    If I < r(1).Count Then line = line & ","
                Next
                line = line & ");"
                Context("Progress") = "Creating table: " & line
                    mdb.Execute line
                Context("Progress") = "Table created"
                rst.Open Context("Table"), mdb, 1, 3, 2
            End If
            For I = 1 To r.Count
                rst.AddNew
                For J = 1 To r(I).Count
                    rst(J-1).Value = r(I)(J)
                Next
                rst.Update
                Context("Progress") = "Exporting record " & nCur
                nCur = nCur + 1
            Next
        Else
            Exit Do
        End If
    Loop
    Set rst = Nothing
    mdb.Close
End Sub

DoExport

Context("Complete") = True