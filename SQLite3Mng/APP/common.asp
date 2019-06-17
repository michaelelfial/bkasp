<%

    Dim Self
    Self = Request.ServerVariables("SCRIPT_NAME")

    Function IsDateType(st)
        Dim arr, I
        arr = Split(Application("DATETypes"),",")
        If IsArray(arr) Then
            For I = LBound(arr) To UBound(arr)
                If UCase(st) = UCase(arr(I)) Then
                    IsDateType = 1
                    Exit Function
                End If
            Next
        End If
        arr = Split(Application("TIMETypes"),",")
        If IsArray(arr) Then
            For I = LBound(arr) To UBound(arr)
                If UCase(st) = UCase(arr(I)) Then
                    IsDateType = 2
                    Exit Function
                End If
            Next
        End If
        arr = Split(Application("DATETIMETypes"),",")
        If IsArray(arr) Then
            For I = LBound(arr) To UBound(arr)
                If UCase(st) = UCase(arr(I)) Then
                    IsDateType = 3
                    Exit Function
                End If
            Next
        End If
        IsDateType = 0
    End Function
    Function EnsureTableExistsSysSchemPositions()
        Dim r
        Set r = db.Execute("SELECT * FROM sqlite_master WHERE type='table' AND name='SysDBMan_SchemePositions';")
        If r.Count > 0 Then
            EnsureTableExistsSysSchemPositions = True
            Exit Function
        Else
            On Error Resume Next
            db.Execute "CREATE TABLE SysDBMan_SchemePositions (Name TEXT,Type TEXT,X INTEGER,Y INTEGER);"
            If Err.Number <> 0 Then
                EnsureTableExistsSysSchemPositions = False
            Else
                EnsureTableExistsSysSchemPositions = True
            End If
        End If
    End Function
    Function EnsureTableExistsSysSchemDrawings()
        Dim r
        Set r = db.Execute("SELECT * FROM sqlite_master WHERE type='table' AND name='SysDBMan_SchemeDrawings';")
        If r.Count > 0 Then
            EnsureTableExistsSysSchemDrawings = True
            Exit Function
        Else
            On Error Resume Next
            db.Execute "CREATE TABLE SysDBMan_SchemeDrawings (Line TEXT);"
            If Err.Number <> 0 Then
                EnsureTableExistsSysSchemDrawings = False
            Else
                EnsureTableExistsSysSchemDrawings = True
            End If
        End If
    End Function
    Function EnsureTableExistsSysColWidths()
        Dim r
        Set r = db.Execute("SELECT * FROM sqlite_master WHERE type='table' AND name='SysDBMan_ColumnWidths';")
        If r.Count > 0 Then
            EnsureTableExistsSysColWidths = True
            Exit Function
        Else
            On Error Resume Next
            db.Execute "CREATE TABLE SysDBMan_ColumnWidths (Obj TEXT,Widths TEXT);"
            If Err.Number <> 0 Then
                EnsureTableExistsSysColWidths = False
            Else
                EnsureTableExistsSysColWidths = True
            End If
        End If
    End Function
    Function EnsureTableExistsSysParams()
        Dim r
        Set r = db.Execute("SELECT * FROM sqlite_master WHERE type='table' AND name='SysDBMan_SessionParams';")
        If r.Count > 0 Then
            EnsureTableExistsSysParams = True
            Exit Function
        Else
            On Error Resume Next
            db.Execute "CREATE TABLE SysDBMan_SessionParams (ParamName,ParamType,ParamVal);"
            If Err.Number <> 0 Then
                EnsureTableExistsSysParams = False
            Else
                EnsureTableExistsSysParams = True
            End If
        End If
    End Function
    Function EnsureTableExistsSysNotes()
        Dim r
        Set r = db.Execute("SELECT * FROM sqlite_master WHERE type='table' AND name='SysDBMan_Notes';")
        If r.Count > 0 Then
            EnsureTableExistsSysNotes = True
            Exit Function
        Else
            On Error Resume Next
            db.Execute "CREATE TABLE SysDBMan_Notes (NOTEID INTEGER PRIMARY KEY,NOTE TEXT);"
            If Err.Number <> 0 Then
                EnsureTableExistsSysNotes = False
            Else
                EnsureTableExistsSysNotes = True
            End If
        End If
    End Function
    
    Sub LangMetaTag
        If Session("Charset") <> "" Then
            %>
            <meta http-equiv="Content-Type" content="text/html; charset=<%= Session("Charset") %>">
            <%
        End If
    End Sub
    
    Function Checked(name)
        If Request(name) <> "" Then Checked = "CHECKED" Else Checked = ""
    End Function
    Function BChecked(b)
        If b Then BChecked = "CHECKED" Else BChecked = ""
    End Function
    
    Function ParseOleDate(strDate)
        Dim re
        Set re = new RegExp
        re.Pattern = "^\d{4}-\d{1,2}-\d{1,2}$"
        re.Global = True
        re.IgnoreCase = True
        Dim arr,arrT
        arr = Split(strDate," ")
        Dim dt, matches
        dt = Null
        If UBound(arr) >= 0 Then
            Set matches = re.Execute(arr(0))
            
            If matches.Count <> 1 Then Exit Function
            arrT = Split(arr(0),"-")
            dt = DateSerial(arrT(0),arrT(1),arrT(2))
            If UBound(arr) > 0 Then
                Set re = new RegExp
                re.Global = True
                re.Pattern = "^\d{1,2}:\d{1,2}"
                Set matches = re.Execute(arr(1))
                If matches.Count <> 1 Then 
                    dt = Null
                    Exit Function
                End If
                arrT = Split(arr(1),":")
                dt = DateAdd("h",arrT(0),dt)
                dt = DateAdd("n",arrT(1),dt)
            End If
        End If
        ParseOleDate = dt
    End Function
%>