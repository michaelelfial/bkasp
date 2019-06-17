Set dbOld = CreateObject("newObjects.sqlite3.dbutf8")
Set dbNew = CreateObject("newObjects.sqlite3.dbutf8")
Dim hOld, hNew
Set sf = CreateObject("newObjects.utilctls.SFMain")
Dim vold, vnew ' versions
Dim fout

Dim ASPCTL_TEMPLATE_COLLECTION
    Private Sub ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set ASPCTL_TEMPLATE_COLLECTION = CreateObject("newObjects.utilctls.VarDictionary")
        With ASPCTL_TEMPLATE_COLLECTION
            .firstItemAsRoot = True
            .itemsAssignmentAllowed = True
            .enumItems = True
            .allowUnnamedValues = True
            .allowDuplicateNames = True
            .RequireSetForObjects = True
        End With
    End Sub
    Function CreateCollection()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateCollection = ASPCTL_TEMPLATE_COLLECTION.CreateNew()
    End Function
    Function CreateStack()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateStack = ASPCTL_TEMPLATE_COLLECTION.CreateNewStack()
    End Function
    Function CreateQueue()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateQueue = ASPCTL_TEMPLATE_COLLECTION.CreateNewQueue()
    End Function
    Function CreateList()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateList = ASPCTL_TEMPLATE_COLLECTION.CreateNewList()
    End Function
    Function CreateDictionary()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateDictionary = ASPCTL_TEMPLATE_COLLECTION.CreateNewDictionary()
    End Function
    Sub TransferCollection(dst,src,bClearDst)
        Dim I
        If IsObject(dst) And IsObject(src) Then
            If bClearDst Then dst.Clear
            For I = 1 To src.Count
                dst.Add src.Key(I), src(I)
            Next    
        End If
    End Sub

Function GetVersion(db)
    Dim r
    Set r = db.Execute("SELECT [VER] FROM DBVERSION LIMIT 1")
    If r.Count > 0 Then
        GetVersion = CLng(r(1)(1))
    Else
        GetVersion = 0
    End If
End Function

Sub Usage
    WScript.Echo "ASP-CTL Database patch generator ver. 1.1"
    WScript.Echo "  Generates a patch file for database upgrade over the"
    WScript.Echo "  schemas of the old and the new database versions passed"
    WScript.Echo "  as text files containing the full SQL for the db schema."
    WScript.Echo "  "
    WScript.Echo "Usage: cscript patchgen.vbs <oldschema.sql> <newschema.sql> [force] [test]"
    WScript.Echo "  <oldschema.sql> - the old schema file"
    WScript.Echo "  <newschema.sql> - the new schema file"
    WScript.Echo "  force - optional. If specified the new schme can be version"
    WScript.Echo "      bigger than old + 1"
    WScript.Echo "  test - optional. If specified the execute SQL scripts are tested"
    WScript.Echo "  "
    WScript.Echo "  If successful outputs a file named #.sql in the current directory"
    WScript.Echo "  where the # is the old version number."
    WScript.Echo "  Example:"
    WScript.Echo "  cscript patchgen.vbs schema2.sql schema3.sql"
    WScript.Echo "  "
    WScript.Echo "  Requirements:"
    WScript.Echo "  This tool requires the database to use a table named"
    WScript.Echo "  DBVERSION with a single column VER. The table should have"
    WScript.Echo "  only one record in any given database."
    WScript.Echo "  You can use the following code for definition of the table"
    WScript.Echo "  in the schemas:"
    WScript.Echo "      CREATE TABLE DBVERSION ([VER] INTEGER);"
    WScript.Echo "      DELETE FROM DBVERSION;"
    WScript.Echo "      INSERT INTO DBVERSION ([VER]) VALUES (3);"
    WScript.Echo "  The value inserted should be the approriate version of the schema."
    WScript.Echo "  The tool requires that the version of the new schema is greater"
    WScript.Echo "  than the version in the old schema. The new version should be"
    WScript.Echo "  consecutive - i.e. the new version must be the old version + 1."
    WScript.Echo "  However, this last condition can be ignored using the force option."
    WScript.Echo "  It is recommended to avoid generating patches for non-consecutive"
    WScript.Echo "  versions because this rises the chance for mistakes."
    WScript.Echo "  "
    WScript.Echo "  The tool can deal with almost all the normal changes made to a"
    WScript.Echo "  database during the development of new versions of a product."
    WScript.Echo "  However, it cannot perform cross-table actions such as moving a"
    WScript.Echo "  field from a table to a (possibly new) child table."
    WScript.Echo "  Internally the changed tables are copied in temporary unindexed"
    WScript.Echo "  tables and then refilled after re-creation. The indices of all the"
    WScript.Echo "  changed tables are recreated from scratch. This means that tables"
    WScript.Echo "  containing huge amount of data may require considerable time for"
    WScript.Echo "  the patching process to complete. You should have this in mind"
    WScript.Echo "  when designing the code that applies the generated patches."
    WScript.Echo "  If that is a regular ASP page it should request longer timeout"
    WScript.Echo "  in order to avoid failures caused by script timeouts."
    WScript.Echo "  If the database is expected to grow huge (hundreds of millions"
    WScript.Echo "  records) it is probably better to apply the patches from the"
    WScript.Echo "  command line."
    WScript.Echo "  "
    WScript.Echo "  The generated patch is a plain SQL script which MUST be executed"
    WScript.Echo "  inside a transaction. The script itself does not contain BEGIN"
    WScript.Echo "  and COMMIT statemets because the application may need to issue"
    WScript.Echo "  these on its own in order to track the results better."
    WScript.Echo "  "
    WScript.Echo "  This tool is supplied together with an example ASP-CTL page"
    WScript.Echo "  that applies the patches by looking them up from a directory"
    WScript.Echo "  named ""patches"". The example is named patch.asp. Do not"
    WScript.Echo "  forget to put this file under some kind of protection because"
    WScript.Echo "  it should not be accessible to the regular users!"
    WScript.Echo "  "
    WScript.Echo "  Caution: If you are using interdependent views (vies defined"
    WScript.Echo "  over other views) you should be careful to specify them in the"
    WScript.Echo "  schema file in an appropriate order - the views that refer to"
    WScript.Echo "  other vies after all the views on which they depend. This is not"
    WScript.Echo "  required for tables or indices because they are processed first."
    WScript.Echo "  "
    WScript.Echo "  From version 1.1 of this script explicit SQL scripts are supported."
    WScript.Echo "  They are included in the schema between tags like this one:"
    WScript.Echo "  --EXECUTE BEFORE [[BEGIN(#)"
    WScript.Echo "  ... SQL statements ..."
    WScript.Echo "  --END]]"
    WScript.Echo "  The # in the BEGIN statement is the database version from which"
    WScript.Echo "  the upgrade is performed. I.e. if you upgrade from version 7 to"
    WScript.Echo "  8 in the schema for version 8 you will code the SQL with BEGIN(7)"
    WScript.Echo "  because they need to be executed when upgrading from version 7"
    WScript.Echo "  There are two kind of scripts:"
    WScript.Echo "  --EXECUTE BEFORE [[BEGIN(#)"
    WScript.Echo "      This SQL is executed before the schema update"
    WScript.Echo "  --EXECUTE AFTER [[BEGIN(#)"
    WScript.Echo "      This SQL is executed after the schema update"
    WScript.Echo "  This enables you to create some temporary tables and use them after"
    WScript.Echo "  the changes to the schema are made."
    WScript.Echo "  The test option instructs the patch generator to attempt to execute"
    WScript.Echo "  the explicit SQL scripts over in-memory databases and thus check them"
    WScript.Echo "  for syntax errors. However, the SQL may depend on some existing data"
    WScript.Echo "  and errors may occur even if the SQL is absolutely correct. This is why"
    WScript.Echo "  the test parameter is optional."
End Sub

Dim bOptionForce, bOptionCheckScripts
Sub CollectOptions
    Dim I
    For I = 2 To WScript.Arguments.length - 1
        Select Case UCase(WScript.Arguments(I))
            Case "FORCE"
                bOptionForce = True
            Case "TEST"
                bOptionCheckScripts = True
        End Select
    Next
End Sub

Sub Init
    Dim f, bforce, h
    If WScript.Arguments.length < 2 Then
        Usage
        WScript.Quit
    End If
    CollectOptions
    bForce = bOptionForce
    
    dbOld.Open ""
    Set hOld = LoadSQLScript(WScript.Arguments(0),-1)
    dbOld.Execute hOld.SQL
        WScript.Echo " - Created in-memory representation of the old databse"
    vold = GetVersion(dbOld)
        WScript.Echo "      Old databse version: " & vold
        
    dbNew.Open ""
    Set hNew = LoadSQLScript(WScript.Arguments(1),vold)
    dbNew.Execute hNew.SQL
    WScript.Echo " - Created in-memory representation of the new databse"
    
    If Len(hNew.Pre) > 0 Then
        WScript.Echo "  + Execute before script is found"
        If bOptionCheckScripts Then
            WScript.Echo "  > Testing the execute before script"
            dbNew.Execute hNew.Pre
        End If
    End If
    
    If Len(hNew.Post) > 0 Then
        WScript.Echo "  + Execute after script is found"
        If bOptionCheckScripts Then
            WScript.Echo "  > Testing the execute after script"
            dbNew.Execute hNew.Post
        End If
    End If
    
    vnew = GetVersion(dbNew)        
        WScript.Echo "      New databse version: " & vnew
        
    If vnew <= vold Then
        WScript.Echo " ! The new version is smaller or equal to the old version"
        WScript.Quit
    ElseIf vnew > vold + 1 Then
        WScript.Echo " ! The new version is too big."
        WScript.Echo " ! This may cause discrepancies."
        If Not bforce Then
            WScript.Quit
        Else
            WScript.Echo " - force specified - proceeding"
        End If
    Else
        WScript.Echo " - Versions are Ok."
    End If
    Set fout = sf.CreateFile(vold & ".sql")
    WScript.Echo " - Output file name is: " & vold & ".sql"
    WScript.Echo " - Initialization Done."
    
End Sub

Class HSQL
    Public SQL, Pre, Post
End Class
' Returns the SQL and sub scripts in HSQL
Function LoadSQLScript(sFile,ver)
    Dim rePre, rePost, s, matches, m, file, h
    Set rePre = New RegExp
    rePre.Pattern = "\-\-EXECUTE\s+BEFORE\s+\[\[BEGIN\((\d+)\)\s+((?:.|\n)*?)\-\-END\]\]"
    rePre.IgnoreCase = True
    rePre.Global = True
    Set rePost = New RegExp
    rePost.Pattern = "\-\-EXECUTE\s+AFTER\s+\[\[BEGIN\((\d+)\)\s+((?:.|\n)*?)\-\-END\]\]"
    rePost.IgnoreCase = True
    rePost.Global = True
    
    Set file = sf.OpenFile(sFile,&H40)
    s = file.ReadText(-2)
    
    Set h = New HSQL
    h.SQL = s
    Set matches = rePre.Execute(s)
    For Each m In matches
        If CLng(ver) = CLng(m.Submatches(0)) Then
            WScript.Echo "  + Including explicit pre-patch SQL for version: " & CLng(m.Submatches(0))
            h.Pre = hPre & m.Submatches(1)
        Else
            WScript.Echo "  - Excluding explicit pre-patch SQL for version: " & CLng(m.Submatches(0))
        End If
    Next
    h.SQL = rePre.Replace(h.SQL,"")
    Set matches = rePost.Execute(s)
    For Each m In matches
        If CLng(ver) = CLng(m.Submatches(0)) Then
            WScript.Echo "  + Including explicit post-patch SQL for version: " & CLng(m.Submatches(0))
            h.Post = hPost & m.Submatches(1)
        Else
            WScript.Echo "  - Excluding explicit post-patch SQL for version: " & CLng(m.Submatches(0))
        End If
    Next
    h.SQL = rePost.Replace(h.SQL,"")
    file.Close
    Set LoadSQLScript = h    
End Function

Function GetTableFields(db,tname)
    Dim r, o , I
    Set r = db.Execute("PRAGMA TABLE_INFO(" & tname & ")")
    If r.Count > 0 Then
        Set o = CreateDictionary
        For I = 1 To r.Count
            o(r(I)("name")) = True
        Next
        Set GetTableFields = o
    Else
        WScript.Echo " ! table info cannot be extracted."
        WScript.Quit
    End If
End Function
Function CompareTables(tname)
    Dim r, told, tnew
    Set r = dbOld.VExecute("SELECT sql FROM SQLITE_MASTER WHERE type='table' AND name=?",1,1,tname)
    If r.Count = 0 Then
        CompareTables = "new"
        Exit Function
    End If
    told = r(1)(1)
    Set r = dbNew.VExecute("SELECT sql FROM SQLITE_MASTER WHERE type='table' AND name=?",1,1,tname)
    If r.Count = 0 Then
        CompareTables = "removed"
        Exit Function
    End If
    tnew = r(1)(1)
    If UCase(Trim(tnew)) = UCase(Trim(told)) Then
        CompareTables = "same"
    Else
        CompareTables = "changed"
    End If
End Function 
Function GetSQL(db,objName)
    Dim r, s
    Set r = db.VExecute("SELECT sql FROM SQLITE_MASTER WHERE name=?",1,1,CStr(objName))
    If r.Count > 0 Then
        GetSQL = r(1)(1)
    Else
        GetSQL = Null
    End If    
End Function
Sub TableIndexesCreate(tname)
    Dim r, I
    Set r = dbNew.VExecute("SELECT name, sql FROM SQLITE_MASTER WHERE type='index' AND sql NOTNULL AND tbl_name=?",1,0,CStr(tname))
    WScript.Echo "   - " & r.Count & " non-automatic indexes found for table " & tname
    For I = 1 To r.Count
        WScript.Echo "   - Add index " & r(I)("name")
        fout.WriteText r(I)("sql") & ";", 1
    Next
End Sub
Sub TableIndexesDrop(tname)
    Dim r, I
    Set r = dbOld.VExecute("SELECT name FROM SQLITE_MASTER WHERE type='index' AND sql NOTNULL AND tbl_name=?",1,0,CStr(tname))
    WScript.Echo "   - " & r.Count & " non-automatic indexes found for table " & tname
    For I = 1 To r.Count
        WScript.Echo "   - Remove index " & r(I)("name")
        fout.WriteText  "  DROP INDEX [" & r(I)("name") & "];", 1
    Next
End Sub
Sub TableUpdateIndexes(tname)
    Dim rn, I, ro, J
    Set rn = dbNew.VExecute("SELECT name, sql FROM SQLITE_MASTER WHERE type='index' AND sql NOTNULL AND tbl_name=?",1,0,CStr(tname))
    For I = 1 To rn.Count
        Set ro = dbOld.VExecute("SELECT name, sql FROM SQLITE_MASTER WHERE type='index' AND sql NOTNULL AND tbl_name=? AND name=?",1,1,CStr(tname),CStr(rn(I)("name")))
        If ro.Count > 0 Then
            If UCase(Trim(rn(I)("sql"))) = UCase(Trim(ro(1)("sql"))) Then
                WScript.Echo "   - Unchanged index " & rn(I)("name")
            Else
                WScript.Echo "   - Droping and recreating index " & rn(I)("name")
                fout.WriteText "  DROP INDEX [" & rn(I)("name") & "];", 1
                fout.WriteText "  " & rn(I)("sql") & ";", 1
            End If
        Else
            WScript.Echo "   - Adding new index " & rn(I)("name")
            fout.WriteText "  " & rn(I)("sql") & ";", 1
        End If
    Next
End Sub

Sub ChangeTable(tname)
    Dim fieldsNew, fieldsOld, s, I, snew, sold
    fout.WriteText "  CREATE TABLE [PATCH_TEMP_" & tname & "] AS SELECT * FROM [" & tname & "];", 1
    fout.WriteText "  DROP TABLE [" & tname & "];", 1
    fout.WriteText "  " & GetSQL(dbNew, tname) & ";", 1
    Set FieldsNew = GetTableFields(dbNew, tname)
    Set FieldsOld = GetTableFields(dbOld, tname)
    snew = ""
    sold = ""
    For I = 1 To FieldsNew.Count
        If FieldsOld(FieldsNew.Key(I)) Then
            If Len(snew) > 0 Then snew = snew & ","
            snew = snew & "[" & FieldsNew.Key(I) & "]"
            If Len(sold) > 0 Then sold = sold & ","
            sold = sold & "[" & FieldsNew.Key(I) & "]"
        End If
    Next
    If Len(sold) > 0 And Len(snew) > 0 Then
        fout.WriteText "  INSERT INTO [" & tname & "] (" & snew & ") SELECT " & sold & " FROM [PATCH_TEMP_" & tname & "];", 1
    End If
    fout.WriteText "  DROP TABLE [PATCH_TEMP_" & tname & "];", 1
End Sub


Sub ScanTables
    Dim rTables, T, collTables, tname, taction
    Set collTables = CreateDictionary
    Set rTables = dbNew.Execute("SELECT name FROM SQLITE_MASTER WHERE type='table' AND name NOT IN ('DBVERSION')")
    WScript.Echo " - " & rTables.Count & " tables in the new database"
    For T = 1 To rTables.Count
        collTables(rTables(T)("name")) = True
    Next
    Set rTables = dbOld.Execute("SELECT name FROM SQLITE_MASTER WHERE type='table' AND name NOT IN ('DBVERSION')")
    WScript.Echo " - " & rTables.Count & " tables in the old database"
    For T = 1 To rTables.Count
        collTables(rTables(T)("name")) = True
    Next
    
    For T = 1 To collTables.Count
        tname = collTables.Key(T)
        WScript.Echo " - Table " & T & ": " & tname
        taction = CompareTables(tname)
        WScript.Echo "     " & taction
        Select Case taction
            Case "removed"
                fout.WriteText "  -- REMOVIG TABLE " & tname, 1
                fout.WriteText "  DROP TABLE [" & tname & "];", 1
                fout.WriteText "  -- END REMOVING TABLE " & tname, 1
                fout.WriteText "", 1
            Case "same"
                fout.WriteText "  -- UNCHANGED TABLE " & tname, 1
                TableUpdateIndexes tname
                fout.WriteText "  -- END UNCHANGED TABLE " & tname, 1
                fout.WriteText "", 1
            Case "new"
                fout.WriteText "  -- ADD TABLE " & tname, 1
                fout.WriteText "  " & GetSQL(dbNew, tname) & ";", 1
                WScript.Echo " - Added new table"
                fout.WriteText "", 1
                fout.WriteText "  -- ADD INDEXES", 1
                TableIndexesCreate tname
                fout.WriteText "  -- END ADDING TABLE " & tname, 1
                fout.WriteText "", 1
            Case "changed"
                fout.WriteText "  -- CHANGE TABLE " & tname, 1
                ChangeTable tname
                WScript.Echo " - Changed table " & tname
                TableIndexesCreate tname
        End Select
    Next
End Sub

Sub RemoveViewsAndTriggers
	Dim r, I
    fout.WriteText "", 1
    fout.WriteText "  -- REMOVE VIEWS AND TRIGGERS", 1
    Set r = dbOld.Execute("SELECT name, type FROM SQLITE_MASTER WHERE type IN ('view','trigger') AND sql NOTNULL")
    For I = 1 To r.Count
        fout.WriteText "  DROP " & r(I)("type") & " [" & r(I)("name") & "];",1
        WScript.Echo " - drop " & r(I)("type") & " " & r(I)("name")
    Next
End Sub
Sub RecreateViewsAndTriggers
    Dim r, I
    fout.WriteText "", 1
    fout.WriteText "  -- RECREATE VIEWS AND TRIGGERS", 1
    Set r = dbNew.Execute("SELECT name, type, sql FROM SQLITE_MASTER WHERE type IN ('view','trigger') AND sql NOTNULL")
    For I = 1 To r.Count
        fout.WriteText r(I)("sql") & ";",1
        WScript.Echo " - create " & r(I)("type") & " " & r(I)("name")
    Next
End Sub


Init
    fout.WriteText "-- PATCH FROM VERSION " & vold & " TO VERSION " & vnew, 1
    ' fout.WriteText "BEGIN TRANSACTION;", 1
    fout.WriteText ""
    fout.WriteText "-- VERSION", 1
    fout.WriteText "DELETE FROM DBVERSION;INSERT INTO DBVERSION ([VER]) VALUES (" & vnew & ");", 1
    fout.WriteText ""
    
    If Len(hNew.Pre) > 0 Then
        WScript.Echo "- Outputing the execute before SQL"
        fout.WriteText "-- EXECUTE BEFORE SQL", 1
        fout.WriteText hNew.Pre, 1
    End If

    WScript.Echo " - Scanning tables"
    
		RemoveViewsAndTriggers
        ScanTables
        RecreateViewsAndTriggers
        
    If Len(hNew.Post) > 0 Then
        WScript.Echo "- Outputing the execute after SQL"
        fout.WriteText "-- EXECUTE AFTER SQL", 1
        fout.WriteText hNew.Post, 1
    End If        
    ' fout.WriteText "COMMIT TRANSACTION;", 1
fout.Close    