Context("Complete") = False
Dim su
Set su = Creator.CreateObject("StringUtilities")
Dim db
Set db = Context("db")
Dim mdb
Set mdb = Creator.CreateObject("ADODB.Connection")
mdb.Open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Context("File") & ";"

Dim TypeMap(10),Convs
'        0           1       2    3       4    5        6        7    8     9    10
Types = "LONGINTEGER,INTEGER,BLOB,BOOLEAN,TEXT,CURRENCY,DATETIME,REAL,EMPTY,GUID,NUMERIC"
Convs = "l,i,b,i,t,l,r,r,t,t,r"

Dim arrTypes,arrConvs
arrTypes = Split(Types,",")
arrConvs = Split(Convs,",")

TypeMap(0) = "20,21"
TypeMap(1) = "136,10,3,2,16,19,18,17"
TypeMap(2) = "128"
TypeMap(3) = "11"
TypeMap(4) = "8,129,130,200,202"
TypeMap(5) = "6"
TypeMap(6) = "7,133,134,135,14,64"
TypeMap(7) = "5,4,139"
TypeMap(8) = "0"
TypeMap(9) = "72"
TypeMap(10) = "131"

Function GetAppropriateType(adoType,ByRef conv)
    GetAppropriateType = ""
    Dim I, J, arr
    For I = LBound(arrTypes) To UBound(arrTypes)
        arr = Split(TypeMap(I),",")
        If IsArray(arr) Then
            For J = LBound(arr) To UBound(arr)
                If CLng(arr(J)) = CLng(adoType) Then
                    GetAppropriateType = arrTypes(I)
                    conv = arrConvs(I)
                    Exit Function
                End If
            Next
        End If
    Next
End Function

Sub ColVal(sql,f)
    Dim conv
    On Error Resume Next
    GetAppropriateType f.Type,conv
    Select Case conv
        Case "l"
            sql = sql & su.Sprintf("%NM",f.Value)
        Case "i"
            sql = sql & su.Sprintf("%Nd",f.Value)
        Case "b"
            If IsNull(f.Value) Then
                sql = sql & "Null"
            Else
                sql = sql & "X'" & su.BinToHex(f.Value) & "'"
            End If
        Case "t"
            sql = sql & su.Sprintf("%Nq",f.Value)
        Case "r"
            sql = sql & su.Sprintf("%NM",f.Value)
        Case Else
            sql = sql & su.Sprintf("%Nq",f.Value)
    End Select
    If Err.Number <> 0 Then
        sql = sql & "Null"
    End If
End Sub


Sub DoImport(tbl)
    Dim rst, sql, I, sqlIns
    Set rst = Creator.CreateObject("ADODB.Recordset")
    rst.Open tbl,mdb,1,3,2
    If Not rst.EOF Then
        ' Create the table
        sql = "CREATE TABLE [" & tbl & "] ("
        sqlIns = "INSERT INTO [" & tbl & "] ("
        For I = 0 To rst.Fields.Count - 1
            sql = sql & "[" & rst.Fields(I).Name & "] "
            sql = sql & GetAppropriateType(rst.Fields(I).Type,conv)
            sqlIns = sqlIns & "[" & rst.Fields(I).Name & "]"
            
            If Not rst.Fields(I).Attributes And (&H20 Or &H40) Then
                sql = sql & " NOT NULL"
            End If
            If I < rst.Fields.Count - 1 Then
                sql = sql & ","
                sqlIns = sqlIns & ","
            Else
                sqlIns = sqlIns & ") VALUES ("
                sql = sql & ")"
            End If
        Next
        db.Execute sql
        Dim n
        n = 0
        db.Execute "BEGIN TRANSACTION"
        While Not rst.EOF
            Context("Progress") = "Importing table: " & tbl & " Record:" & n
            n = n + 1
            If n Mod 100 = 0 Then
                db.Execute "COMMIT TRANSACTION"
                db.Execute "BEGIN TRANSACTION"
            End If
            sql = sqlIns
            For I = 0 To rst.Fields.Count - 1
                ColVal sql, rst.Fields(I)
                If I < rst.Fields.Count - 1 Then
                    sql = sql & ","
                Else
                    sql = sql & ");"
                End If
            Next
            db.Execute sql
            rst.MoveNext
        Wend
        db.Execute "COMMIT TRANSACTION"
    End If
End Sub

Dim Tables
If Context("Tables") <> "" Then
    Tables = Split(Context("Tables"),",")
End If

Set mrst = mdb.Execute("SELECT * FROM MSysObjects WHERE Type=1")
While Not mrst.EOF
    If UCase(Left(mrst("Name").Value,4)) <> "MSYS" Then
        On Error Resume Next
        If IsArray(Tables) Then
            For T = LBound(Tables) To UBound(Tables)
                If UCase(mrst("Name").Value) = UCase(Trim(Tables(T))) Then
                    Context("Progress") = "Importing table: " & mrst("Name").Value
                    DoImport mrst("Name").Value
                End If
            Next
        Else
            Context("Progress") = "Importing table: " & mrst("Name").Value
            DoImport mrst("Name").Value
        End If
        On Error Goto 0
    End If
    mrst.MoveNext
Wend
Context("Progress") = "Finished"

mdb.Close

Context("Complete") = True