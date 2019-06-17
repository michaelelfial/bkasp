' Static properties
' 
Public ComponentsPath   ' Component path to help it create new objects
Public db               ' Main database object
Public LastError
Public IsTemporary
Public TableName
' Public Values - it has been moved outside
Public RowID
Public Filter
Public EOF
Public Dbg

LastError = ""
IsTemporary = False
TableName = ""
RowID = Null
Filter = ""

' Internals
Private Columns
Set Columns = Context.CreateObject("VarDictionary")
Columns.itemsAssignmentAllowed = True
Columns.allowDuplicateNames = True
Set Values = Context("ValuesCollection")
Values.itemsAssignmentAllowed = True
Values.allowDuplicateNames = True
Values.extractValues = True

Set su = Context.CreateObject("StringUtilities")

Private Sub InitValues
    Values.Clear
    Dim I
    For I = 1 To Columns.Count
        Values.Add Columns.Key(I),Null
    Next
End Sub
Private Function AreValuesSynch
    If Values.Count <> Columns.Count Then
        AreValuesSynch = False
    Else
        Dim I
        For I = 1 To Columns.Count
            If UCase(Columns.Key(I)) <> UCase(Values.Key(I)) Then
                AreValuesSynch = False
                Exit Function
            End If
        Next
    End If
    AreValuesSynch = True
End Function

Private Function DBEscape(s)
    DBEscape = Replace(s,"'","''")
End Function

Private Function ValueToLiteral(colNum,v)
    If colNum > Columns.Count Then Err.Raise 201,"SQLiteTable","Column not found"
    If db.IsNumericType(Columns(colNum)("Type")) Then
        ValueToLiteral = su.Sprintf("%NM",v)
    Else
        ValueToLiteral = su.Sprintf("%Nq",v)
    End If
End Function

strOpenQ = """'["
strCloseQ = """']"
nLastExcapable = 2
strNonAlphaNum = "()+-,;/*=<>:?"
strControlChars = "(),;"
strSpaces = " " & vbCr & vbLf & vbTab
strNumbers = "0123456789"


Function RemoveQuoting(s)
    Dim c
    c = Left(s,1)
    
    ' Dbg.Echo " RemoveQ On: [" & s & "]"
    
    Dim n
    n = InStr(strCloseQ,c)
    If n <= 0 Or c = "" Then
        RemoveQuoting = s
        Exit Function
    End If
    Dim str,escseq
    If Len(s) = 2 Then
        RemoveQuoting = ""
        Exit Function
    End If
    str = Mid(s,2,Len(s) - 2)
    If n <= nLastExcapable Then
        escseq = Mid(strCloseQ,n,1) & Mid(strCloseQ,n,1)
        str = Replace(str,escseq,Mid(strCloseQ,n,1))
    End If
    RemoveQuoting = str
End Function

Function GetToken(stmt,ByVal bRemove)
    Dim c
    Dim I
    Dim n ' Temporary numeric
    Dim posStart,posEnd
    posStart = 1
    posEnd = 0
    ' Modes
    Dim Started ' -1 nothing yet, 0 non-quoted, > 0 quoted the number corresponds to the quote used
    Started = -1
    Dim TokenType ' 0 - unknown yet, 1 - alphanum, 2 - nonalphanum
    TokenType = 0
    
    For I = 1 To Len(stmt)
        c = Mid(stmt,I,1)
        If Started < 0 Then
            If InStr(strControlChars,c) > 0 Then
                ' Self token
                GetToken = c
                If bRemove Then stmt = Mid(stmt,I+1)
                Exit Function
            End If
            If InStr(strSpaces,c) > 0 Then 
                posStart = I + 1
            Else
                n = InStr(strOpenQ,c)
                If n > 0 Then 
                    Started = n
                    TokenType = 0
                Else
                    If InStr(strNonAlphaNum,c) > 0 Then
                        TokenType = 2
                    Else
                        TokenType = 1
                    End If
                    Started = 0
                End If
            End If
        ElseIf Started = 0 Then
            If InStr(strSpaces,c) > 0 Then 
                posEnd = I - 1
            Else
                If TokenType = 1 Then ' AlphaNum token
                    If InStr(strNonAlphaNum,c) > 0 Then
                        ' NonAlphaNum found - end token
                        posEnd = I - 1
                    End If
                ElseIf TokenType = 2 Then ' NonAlphaNum
                    If InStr(strNonAlphaNum,c) = 0 Then
                        ' AlphaNum found - end token
                        posEnd = I - 1
                    End If
                End If
            End If
        ElseIf Started > 0 And Started <= nLastEscapable Then
            If InStr(strCloseQ,c) = Started Then
                ' Possible escape
                If Mid(stmt,I+1,I) = c Then
                    ' It is escape
                    I = I + 2
                Else
                    ' It is end of token - together with this char
                    posEnd = I
                End If
            End If
            ' If the If is not in action then
            ' We just continue
        Else ' Non-Escapable symbol
            If InStr(strCloseQ,c) = Started Then
                posEnd = I
            End If
        End If
        ' Make checks for completion
        If posEnd > 0 Then
            ' Finished
            If posEnd < posStart Then
                ' Crazy Error
                Err.Raise 1,"GetToken","posEnd is lessThen posStart"
            Else
                ' WScript.Echo stmt & " " & posStart & " " & (posEnd - posStart + 1)
                GetToken = Mid(stmt,posStart,posEnd - posStart + 1)
                If bRemove Then stmt = Mid(stmt,posEnd + 1)
                Exit Function
            End If
        End If
    Next
    ' If we are here we have incomplete token at the end of the string
    If Started > 0 Then Err.Raise 2,"GetToken","Incomplete token"
    GetToken = Mid(stmt,posStart)
    If bRemove Then stmt = ""
End Function


Private Sub ParseType(stmt,cType,cSize)
    Dim tok, n
    cType = Null
    For n = 0 To UBound(cSize)
        cSize(n) = Null
    Next
    tok = RemoveQuoting(GetToken(stmt,True))
    cType = CStr(tok)
    tok = RemoveQuoting(GetToken(stmt,False))
    n = 0
    If tok = "(" Then
        tok = GetToken(stmt,True)
        Do
            tok = RemoveQuoting(GetToken(stmt,True))
            If tok = ")" Then 
                Exit Sub
            End If
            If IsNumeric(tok) And n < 2 Then
                cSize(n) = CLng(tok)
                n = n + 1
            Else
                Exit Sub
            End If
        Loop While tok <> "" And n < 2
    End If
End Sub



' Clear
Sub ClearDefinition
    Columns.Clear
    Values.Clear
End Sub

' Init from DB
Function ReadFromDB(tname)
    Dim r
    TableName = tname
    ClearDefinition
    On Error Resume Next
    Set r = db.Execute("PRAGMA table_info(" & tname & ");")
    If Err.Number <> 0 Then
        LastError = "Table not found"
        ReadFromDB = False
        Exit Function
    End If
    On Error Goto 0
    Dim nColumn,bNotNull,bPrimaryKey
    Dim strType,nSize(1)
    
    If r.Count > 0 Then
        
        ' Dbg.Echo "r.Count=" & r.Count
        
        For nColumn = 1 To r.Count
            bNotNull = False
            If r(nColumn)("notnull") <> 0 Then bNotNull = True
            bPrimaryKey = False
            If r(nColumn)("pk") <> 0 Then bPrimaryKey = True
            ParseType r(nColumn)("type"), strType, nSize
            If Not AddColumn(r(nColumn)("name"),strType,nSize,bNotNull,bPrimaryKey,r(nColumn)("dflt_value")) Then
                ClearDefinition
                LastError = "Unsupported features." & LastError
                ReadFromDB = False
                Exit Function
            End IF
        Next
        RowID = 0
        ReadFromDB = True
    Else
        ReadFromDB = False
        LastError = "Table not found"
    End If
End Function

' CreateTable
Function CreateTable
    Dim qry, I
    If IsTemporary Then
        qry = "CREATE TEMPORARY TABLE " & TableName & "("
    Else
        qry = "CREATE TABLE " & TableName & "("
    End If
    For I = 1 To Columns.Count
        qry = qry & "[" & Columns(I)("Name") & "] " & Columns(I)("Type") & " "
        If Columns(I)("NotNull") Then qry = qry & "NOT NULL "
        If Columns(I)("PrimaryKey") Then qry = qry & "PRIMARY KEY "
        If Not IsNull(Columns(I)("Default")) And Not IsEmpty(Columns(I)("Default")) Then 
            If db.IsNumericType(Columns(I)("Type")) Then
                qry = qry & "DEFAULT " & su.Sprintf("%M",Columns(I)("Default"))
            Else
                qry = qry & "DEFAULT " & su.Sprintf("%q",Columns(I)("Default"))
            End If
        End If
        If I < Columns.Count Then qry = qry & ","
    Next
    qry = qry & ");"
    On Error Resume Next
        db.Execute qry
        If Err.Number <> 0 Then
            LastError = db.LastError
            CreateTable = False
            Exit Function
        End If
    CreateTable = True
End Function

Function ChangeTable
    ' Create temporary table
    Dim tName
    tName = TableName & "_SQLiteTableCompTemp"
    db.Execute "BEGIN TRANSACTION;"
    On Error Resume Next
    db.Execute "CREATE TEMPORARY TABLE " & tName & " AS SELECT * FROM " & TableName & ";"
    If Err.Number <> 0 Then
        LastError = "Failed to transfer data to a temporary table."
        db.Execute "ROLLBACK TRANSACTION;"
        ChangeTable = False
        Exit Function
    End If
    ' Drop existing
    db.Execute "DROP TABLE " & TableName & ";"
    If Err.Number <> 0 Then
        LastError = "Failed to drop the old table."
        db.Execute "ROLLBACK TRANSACTION;"
        ChangeTable = False
        Exit Function
    End If
    ' Recreate
    If Not CreateTable Then
        db.Execute "ROLLBACK TRANSACTION;"
        ChangeTable = False
        Exit Function
    End If
    Dim strCommonColumns, r, I
    strCommonColumns = ""
    Set r = db.Execute("PRAGMA TABLE_INFO(" & tName & ");")
    For I = 1 To r.Count
        If IsObject(Columns(r(I)("name"))) Then
            strCommonColumns = strCommonColumns & "[" & r(I)("name") & "],"
        End If
    Next
    If strCommonColumns <> "" Then
        strCommonColumns = Left(strCommonColumns,Len(strCommonColumns) - 1)
        ' Transfer the data
        db.Execute "INSERT INTO " & TableName & " (" & strCommonColumns & ") SELECT " & strCommonColumns & " FROM " & tName
        If Err.Number <> 0 Then
            LastError = "Failed transfer data."
            db.Execute "ROLLBACK TRANSACTION;"
            ChangeTable = False
            Exit Function
        End If
    End If
    db.Execute "DROP TABLE " & tName & ";"
    db.Execute "COMMIT TRANSACTION;"
    ChangeTable = True
End Function
' Add Column method
Function AddColumn(cname,ctype,csize,notnull,primarykey,def)
    Dim col
    LastError = ""
    If IsObject(Columns(cname)) Then
        AddColumn = False
        LastError = "Column with this name already exists"
        Exit Function
    End If
    Dim cctype
    cctype = db.StripTypeName(ctype)
    'If cctype = "" Then
    '    AddColumn = False
    '    LastError = "Invalid type name."
    '    Exit Function
    'End If
    If cname = "" Then
        AddColumn = False
        LastError = "Empty column name."
        Exit Function
    End If
    Set col = Context.CreateObject("VarDictionary")
    col.extractValues = True
    col.itemsAssignmentAllowed = True
    col.Add "Name", UCase(cname)
    col.Add "Type", UCase(ctype)
    col.Add "Size", csize
    col.Add "NotNull", notnull
    col.Add "PrimaryKey", primarykey
    col.Add "Default", def
    If Columns.Add(UCase(cname), col) > 0 Then
        AddColumn = True
    Else
        LastError = "Unknown error"
        AddColumn = False
    End If
End Function

' DelColumn method
Function DelColumn(idx)
    If IsObject(Columns(idx)) Then
        Columns.Remove idx
        DelColumn = True
    Else
        DelColumn = False
        LastError = "Column not found"
        Exit Function
    End If
End Function

' GetColumnInfo property
Function GetColumnInfo(idx)
    ' Dbg.Echo "  Column: " & idx & "," & IsObject(Columns(idx)) & "," & VarType(Columns(idx))
    If IsObject(Columns(idx)) Then
        Set GetColumnInfo = Columns(idx)
    Else
        Err.Raise 1,"SQLTable","Column not found"
    End If
End Function

' Column Count
Function ColumnCount
    ColumnCount = Columns.Count
End Function

' AddNew
Function AddNew
    InitValues
    RowID = Null
End Function

' Update
Function Update
    Dim r
    If Columns.Count = 0 Or TableName = "" Then
        Update = 0
        LastError = "Table not initialized."
        Exit Function
    End If
    If Not AreValuesSynch Then
        Update = 0
        LastError = "Table not initialized."
        Exit Function
    End If
    Dim str, I
    str = ""
    If IsNull(RowID) Then
        ' Add New
        str = "INSERT INTO [" & TableName & "] ("
        For I = 1 To Values.Count
            If Not (Columns(I)("PrimaryKey") And (Columns(I)("Type"))) Then
                str = str & "[" & Values.Key(I) & "],"
            End If
        Next
        If Right(str,1) = "," Then str = Left(str,Len(str)-1)
        str = str & ") VALUES ("
        For I = 1 To Values.Count
            If Not (Columns(I)("PrimaryKey") And (Columns(I)("Type"))) Then
                str = str & ValueToLiteral(Values(I)) & ","
            End If
        Next
        If Right(str,1) = "," Then str = Left(str,Len(str)-1)
        str = str & ");"
        On Error Resume Next
        Set r = db.Execute(str)
        If Err.Number <> 0 Then
            Update = 0
            LastError = db.LastError
            Exit Function
        End If
        RowID = r.Info
        Update = r.Info
    Else
        ' Update existing
        str = "UPDATE [" & TableName & "] SET "
        For I = 1 To Values.Count
            If Not (Columns(I)("PrimaryKey") And (Columns(I)("Type") = "INTEGER")) Then
                str = str & "[" & Columns(I)("Name") & "]=" & ValueToLiteral(I,Values(I)) & ","
            End If
        Next
        If Right(str,1) = "," Then str = Left(str,Len(str)-1)
        str = str & " WHERE OID=" & RowID & ";"
        On Error Resume Next
        Set r = db.Execute(str)
        If Err.Number <> 0 Then
            Update = 0
            LastError = db.LastError
            Exit Function
        End If
        Update = RowID
    End If
End Function

' Move
Function ReadData(nWhich)
    If IsNull(RowID) Then
        LastError = "Undefined position"
        ReadData = False
        Exit Function
    End If
    InitValues
    Dim r
    Dim sql
    sql = "SELECT OID,* FROM " & TableName 
    If nWhich < 0 Then
        sql = sql & " WHERE OID < " & RowID
    ElseIf nWhich > 0 Then
        sql = sql & " WHERE OID > " & RowID
    Else
        sql = sql & " WHERE OID = " & RowID
    End If
    If CStr(Filter) <> "" Then str = str & " AND " & Filter      
    
    If nWhich < 0 Then
        sql = sql & " ORDER BY OID DESC"
    ElseIf nWhich > 0 Then
        sql = sql & " ORDER BY OID ASC"
    End If
    
    On Error Resume Next
    Set r = db.Execute(sql,1,1)
    If Err.Number <> 0 Or r.Count = 0 Then
        LastError = "Record not found."
        EOF = True
        ReadData = False
        Exit Function
    End If
    ' Transfer the result
    RowID = CLng(r(1)("OID"))
    Dim I
    For I = 1 To Columns.Count
        ' Dbg.Echo "  " & Columns(I)("Name") & "=" & r(1)(Columns(I)("Name"))
        Values(I) = r(1)(Columns(I)("Name"))
    Next
    EOF = False
    ReadData = True
End Function

