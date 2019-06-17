<%
    ' Simple database library for SQLite3 COM with distributed transactions
    ' Designed for use in page scope (should not operate on databases kept in the sesssion or the application)
    ' Const CDatabase_DefaultDataBase = "" ' Define default database file (good idea if there is only one database in use)
    Const CDatabase_Timeout = 30000 ' Timeout for write lock waiting, pages will fail if exceeded
    
    ' Database errors - access them through .DB.LastErrorCode
    '   All codes are listed, but only the ones marked with * are actually useful in ASP, the rest may only be useful in troubleshooting of SQLite3 COM
    Const SQLITE_OK             = 0
    Const SQLITE_ERROR          = 1     ' * SQL error or missing database
    Const SQLITE_INTERNAL       = 2     ' NOT USED. Internal logic error in SQLite
    Const SQLITE_PERM           = 3     ' * Access permission denied
    Const SQLITE_ABORT          = 4     ' * Callback routine requested an abort
    Const SQLITE_BUSY           = 5     ' * The database file is locked
    Const SQLITE_LOCKED         = 6     ' * A table in the database is locked
    Const SQLITE_NOMEM          = 7     ' * A malloc() failed
    Const SQLITE_READONLY       = 8     ' * Attempt to write a readonly database
    Const SQLITE_INTERRUPT      = 9     ' * Operation terminated by .DB.Interrupt()
    Const SQLITE_IOERR          = 10    ' * Some kind of disk I/O error occurred
    Const SQLITE_CORRUPT        = 11    ' * The database disk image is malformed
    Const SQLITE_NOTFOUND       = 12    ' NOT USED. Table or record not found
    Const SQLITE_FULL           = 13    ' * Insertion failed because database is full
    Const SQLITE_CANTOPEN       = 14    ' * Unable to open the database file
    Const SQLITE_PROTOCOL       = 15    ' Database lock protocol error
    Const SQLITE_EMPTY          = 16    ' * Database is empty
    Const SQLITE_SCHEMA         = 17    ' * The database schema changed
    Const SQLITE_TOOBIG         = 18    ' NOT USED. Too much data for one row
    Const SQLITE_CONSTRAINT     = 19    ' * Abort due to contraint violation
    Const SQLITE_MISMATCH       = 20    ' * Data type mismatch
    Const SQLITE_MISUSE         = 21    ' Library used incorrectly
    Const SQLITE_NOLFS          = 22    ' Uses OS features not supported on host
    Const SQLITE_AUTH           = 23    ' Authorization denied
    Const SQLITE_FORMAT         = 24    ' Auxiliary database format error
    Const SQLITE_RANGE          = 25    ' 2nd parameter to sqlite3_bind out of range
    Const SQLITE_NOTADB         = 26    ' * File opened that is not a database file
    Const SQLITE_ROW            = 100   ' sqlite3_step() has another row ready
    Const SQLITE_DONE           = 101   ' sqlite3_step() has finished executing

    Class CDatabase
        Private m_db
        Private m_dbref
        Private m_dbtrans
        Private m_dbTransFailed
        Private m_errMessages
        Private m_transFinalizers ' Transaction finalizers
        Public  SessionInitializer
        
        Public DatabaseFile
		Public DatabaseOpener ' As Function() As String
        Public NoMapPath
		
		Public AccessPermitter ' As Function As Boolean
		
		Private Function GetDatabaseFilePath()
			If DatabaseOpener Is Nothing Then
				GetDatabaseFilePath = DatabaseFile
			Else
				GetDatabaseFilePath = DatabaseOpener(Me)
			End If
		End Function
		
		Public CustomData ' a dictionary for custom data stored by external modules that use the instance
        
        Private Sub Class_Initialize
			Set DatabaseOpener = Nothing
			Set AccessPermitter = Nothing
            Set m_db = Nothing
            m_dbref = 0
            m_dbtrans = 0
            m_dbTransFailed = False
            DatabaseFile = CDatabase_DefaultDataBase
            Set m_errMessages = CreateCollection
            Set m_transFinalizers = CreateCollection
            SysTableName = "SYS"
            SysFieldName = "UID"
			Set CustomData = CreateDictionary
			Set XASPGET = ASPGET
			Set XASPPOST = ASPPOST
			Set XASPALL = GetRef("ASPALL")
			Set XASPVARS = ASPVARS
			If IsObject(ASPJSON) Then
				Set XASPJSON = ASPJSON
			Else
				Set XASPJSON = Nothing
				Set XASPJSON = Nothing
			End If
			
        End Sub
    
    
        Public Function GetDB
            Dim fInit, msg
            If m_db Is Nothing Then
				If Not AccessPermitter Is Nothing Then
					If Not AccessPermitter(Me) Then
						Set m_db = Nothing
						Set GetDB = Nothing
						Exit Function
					End If
				End If
                Set m_db = Server.CreateObject("newObjects.sqlite3.dbutf8")
				On Error Resume Next
                If NoMapPath Then
                    m_db.Open GetDatabaseFilePath()
                Else
                    m_db.Open MapPath(GetDatabaseFilePath())
                End If
                m_db.BusyTimeout = CDatabase_Timeout
                If Not IsEmpty(SessionInitializer) Then
                    Set finit = GetRef(SessionInitializer)
                    finit m_db, Me
                End If
				
				If Err.Number <> 0 Then
					msg = Err.Description & " path=" & GetDatabaseFilePath()
					On Error Goto 0
					Err.Raise 100, "SQLiteLib", Err.Description & " path=" & GetDatabaseFilePath()
				End If
				On Error Goto 0
                m_errMessages.Clear
            End If
            m_dbref = m_dbref + 1
            Set GetDB = m_db
        End Function
        Public Function FreeDb
            m_dbref = m_dbref - 1
            If m_dbref <= 0 Then
                If Not m_db Is Nothing Then m_db.Close
                Set m_db = Nothing
                m_dbref = 0
                m_dbtrans = 0
                m_dbTransFailed = False
            End If
            FreeDb = m_dbref
        End Function
        Public Sub ReInitialize
            Dim finit
            If Not m_db Is Nothing Then
                Set finit = GetRef(SessionInitializer)
                finit m_db, Me
            End If
        End Sub
        
        Public Function DB
            If m_db Is Nothing Then Set DB = GetDb Else Set DB = m_db
        End Function
        
        Public Function BeginTransaction
            If m_db Is Nothing Then 
                Dim dummy
                Set dummy = DB
                Set dummy = Nothing
                m_errMessages.Clear
                m_transFinalizers.Clear
            End If
            If Not m_db Is Nothing Then
                If Err.Number <> 0 Then
                    m_dbTransFailed = True
                    If Err.Description <> "" Then AddError Err.Description
                End If
                If m_dbtrans > 0 Then
                    If m_dbTransFailed Then
                        BeginTransaction = False
                    Else
                        m_dbtrans = m_dbtrans + 1
                        BeginTransaction = True
                    End If
                Else
                    On Error Resume Next
                    Err.Clear
                    DB.Execute "BEGIN TRANSACTION"
                    If Err.Number <> 0 Then
                        m_dbtrans = 0
                        m_dbTransFailed = False
                        BeginTransaction = False
                        Exit Function
                    End If
                    m_dbtrans = 1
                    m_transFinalizers.Clear
                    m_dbTransFailed = False
                    BeginTransaction = True
                End If
            Else
                ' This should never happen
                BeginTransaction = False
                m_dbTransFailed = False
                m_dbtrans = 0
            End If
        End Function
        ' One of the both can be called to close a transaction scope/subscope
            Public Function CompleteTransaction
                CompleteTransaction = True
                If Not EndTransaction(Err.Number) Then
                    If Len(Err.Description) > 0 Then 
                        m_errMessages.Add "", Err.Description
                    End If
                    CompleteTransaction = False
                End If
            End Function
            ' Never call this one if you choose to use the above function
            Private Function PerformTransCompletion(bSuccess)
                Dim I, b, result
                result = True
                For I = 1 To m_transFinalizers.Count
                    If IsObject(m_transFinalizers(I)) Then
                        b = m_transFinalizers(I).Complete(bSuccess)
                        If Not b Then
                            result = False
                            AddError "Transaction completion failed in: " & m_transFinalizers.Key(I) & " ClassType: " & m_transFinalizers.Key(I).ClassType & "."
                        End If
                    End If
                Next
            End Function
            Private Function EndTransaction(code)
                If Not m_db Is Nothing Then
                    If code <> 0 Then m_dbTransFailed = True
                    m_dbtrans = m_dbtrans - 1
                    If m_dbtrans <= 0 Then
                        If m_dbTransFailed Then
                            m_db.Execute "ROLLBACK TRANSACTION"
                            ' Call transaction completion routines
                            PerformTransCompletion False
                            EndTransaction = False
                        Else
                            m_db.Execute "COMMIT TRANSACTION"
                            ' Call transaction completion routines
                            PerformTransCompletion True
                            EndTransaction = True
                        End If    
                        m_transFinalizers.Clear
                        m_dbtrans = 0
                        m_dbTransFailed = False
                    Else
                        If m_dbTransFailed Then
                            EndTransaction = False
                        Else
                            EndTransaction = True
                        End If
                    End If
                Else
                    m_dbtrans = 0
                    m_dbTransFailed = False
                    EndTransaction = False
                    m_transFinalizers.Clear
                End If
            End Function
        ' Invalidate the current transaction - but not close the scope/subscope, a Complete/End Transaction must be called also
            Public Sub CancelTransaction(sReason)
                InvalidateTransaction
                If Len(sReason) > 0 Then m_errMessages.Add "", ConvertTo(vbString, sReason)
            End Sub
            Public Sub InvalidateTransaction
                If Not m_db Is Nothing And m_dbtrans > 0 Then m_dbTransFailed = True
            End Sub
        Public Function TransactionFailed
            TransactionFailed = False
            If Not m_db Is Nothing And m_dbtrans > 0 And m_dbTransFailed Then TransactionFailed = True
        End Function
        Public Function TransactionActive
            TransactionActive = False
            If Not m_db Is Nothing And m_dbtrans > 0 Then TransactionActive = True
        End Function
		
        ' Error messages
        Public Sub ClearErrors
            m_errMessages.Clear
        End Sub
        Public Sub AddError(s)
            m_errMessages.Add "", ConvertTo(vbString, s)
        End Sub
        Public Property Get ErrorMessage
            Dim I, s
            For I = 1 To m_errMessages.Count
                If Not IsEmpty(s) Then s = s & "<br/>"
                s = s & m_errMessages(I)
            Next
            ErrorMessage = s
        End Property
        Public Property Get ErrorMessages
            Set ErrorMessages = m_errMessages
        End Property
        
        ' Transaction completiotion
        ' These should be called after BeginTransaction, but they will fail silently outside a transaction returning false.
        ' The object needs to support a public Function Complete(bSuccess, FailureValCollection, SuccessValCollection) returning boolean 
        '   (false is returned if the completion is not possible - which should never happen in production system).
            Function RegisterObject(o)
                Dim r
                If TransactionActive Then
                    If IsObject(m_transFinalizers(o.Name)) Then
                        Set RegisterObject = m_transFinalizers(o.Name)
                    Else
                        Set r = New CTransRegistration
                        Set r.Obj = o
                        m_transFinalizers.Add o.Name, r
                        Set RegisterObject = r
                    End IF
                Else
                    Set RegisterObject = Nothing
                End If
            End Function
            Private Function GetTransObject(o)
                If IsObject(m_transFinalizers(o.Name)) Then
                    Set GetTransObject = m_transFinalizers(o.Name)
                Else
                    Set GetTransObject = Nothing
                End If
            End Function
            Public Function IsObjectRegistered(o)
                Dim r
                Set r = GetTransObject(o)
                If r Is Nothing Then IsObjectRegistered = False Else IsObjectRegistered = True
            End Function
            
            Public Property Get FailureValue(o,n)
                Dim r
                FailureValue = Empty
                Set r = GetTransObject(o)
                If Not r Is Nothing Then
                    FailureValue = r.Failure(n)
                End If
            End Property
            Public Property Let FailureValue(o,n,v)
                Dim r
                Set r = RegisterObject(o)
                If Not r Is Nothing Then
                    r.Failure(n) = v
                End If
            End Property
            Public Property Get SuccessValue(o,n)
                Dim r
                SuccessValue = Empty
                Set r = GetTransObject(o)
                If Not r Is Nothing Then
                    SuccessValue = r.Success(n)
                End If
            End Property
            Public Property Let SuccessValue(o,n,v)
                Dim r
                Set r = RegisterObject(o)
                If Not r Is Nothing Then
                    r.Success(n) = v
                End If
            End Property
        
        ' Helper - generates unique id as text. Note that this is optional and may be used only if the database
        '   is structured in a certain manner.
        Public SysTableName
        Public SysFieldName
        Public Function NewUID_V0
            Dim bd, x, nTries
            nTries = 0
            Set bd = Server.CreateObject("newObjects.crypt.Number")
            Do
                bd.Random 16,True,True
                x = bd.Hex
                nTries = nTries + 1
            Loop While (DB.VExecute("SELECT COUNT(*) FROM " & SysTableName & " WHERE " & SysFieldName & "=$UID",1,1,x)(1)(1) <> 0 And nTries <= 10)
            NewUID = x
        End Function
        Public Function NewUID
            Dim sf
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            NewUID = sf.NewGUID
        End Function
        
		' Parameter sources - sometimes it is convenient to carry parameters together with the database and we use the same object
		' These allow the input to be simulated to classes that want to allow this
		
		Public XASPGET
		Public XASPPOST
		Public XASPALL
		Public XASPVARS
		Public XASPJSON
		
    End Class
    
    
    Class CTransRegistration
        Public Obj
        Public Failure ' Values for failure scenario, usually the old values
        Public Success ' Values for success scenario, usually the new values
        Private Sub Class_Initialize
            Set Failure = CreateDictionary
            Set Success = CreateDictionary
        End Sub
        Public Function Complete(bSuccess)
            Complete = Obj.Complete(bSuccess, Failure, Success)
        End Function
    End Class
    
    ' Parameters helper for CExecute inplace usage
    Class CExecuteParameters
        Private params
        Sub Class_Initialize
            Set params = CreateDictionary
        End Sub
        Function Param(pname,pvalue)
            params(pname) = pvalue
            Set Param = Me
        End Function
        Function ParamN(pname,pvalue,ptype)
            params(pname) = NullConvertTo(ptype, pvalue)
            Set ParamN = Me
        End Function
        Function LikeParam(pname,v,bLeft,bRight)
            Dim s
            If Len(v) > 0 Then
                s = v
                If bLeft Then s = "%" & s
                If bRight Then s = s & "%"
                params(pname) = s
            Else
                params(pname) = Null
            End If
            Set LikeParam = Me
        End Function
        Public Default Property Get Finish
            Set Finish = params
        End Property
    End Class
    Function CExecuteParams
        Set CExecuteParams = New CExecuteParameters
    End Function
	
	' Class for patching
	Class CSQlitePatcher
		Public Db, PatchesPath
		Sub Class_Initialize
			Set Db = Nothing
			PatchesPath = "/personalpatches"
		End Sub
		
		Public Property Get Version
			Dim r
			On Error Resume Next
			' TO DO: This example assumes that you are using sqlite-lib.asp
			'   and you have a global variable named Database that holds the instance
			'   of the CDtabase class for your application's database.
			'   It that is not so - change the code on the next line
			Set r = Db.Execute("SELECT VER FROM DBVERSION")
			If Err.Number <> 0 Then
				Version = 0
				Exit Property
			End If
			If r.Count > 0 Then
				Version = ConvertTo(vbLong, r(1)("VER"))
			Else
				Version = 0
			End If
		End Property
		Public Property Let Version(v)
			Dim r
			Set r = Db.Execute("select * from sqlite_master where name='DBVERSION' AND type='table'")
			If r.Count = 0 Then
				' Does not exist
				Db.Execute "CREATE TABLE DBVERSION ([VER] INTEGER);"
				Db.VExecute "INSERT INTO DBVERSION ([VER]) VALUES ($V)", 1, 0, ConvertTo(vbLong,v)
			Else
				Db.VExecute "UPDATE DBVERSION SET VER=$V", 1, 0, ConvertTo(vbLong,v)
			End If
		End Property
		
		Private Function GetPathchForVer(v)
			Dim sf, dir, files, f
			GetPathchForVer = Empty
			Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
			' TO DO: This example assumes that you maintain a directory
			'   under your application's root named patches. In that directory
			'   the patche files are copied manually whenever they are generated
			'   and need to be applied. The patches are named #.sql where # is the
			'   version of the schema to which they must be applied (e.g. a patch
			'   from version 4 to 5 will be named 4.sql).
			If Not sf.FolderExists(MapPath(PatchesPath)) Then
				Exit Function
			End If
			Set dir = sf.OpenDirectory( MapPath(PatchesPath), &H40)
			Set files = dir.contents
			For Each f in files
				If f.Type = 2 And UCase(f.name) = UCase(v & ".sql") Then
					Set f = dir.OpenStream(f.name, &H40)
					GetPathchForVer = f.ReadText(-2)
					Exit Function
				End If
			Next
		End Function
		Public Function PatchTo(ver) ' As Boolean
			Dim s, cur
			cur = Version
			If cur >= ver Then
				PatchTo = True
				Exit Function
			End If
			
			On Error Resume Next
			Do
				Err.Clear
				Db.Execute "BEGIN TRANSACTION"
				s = GetPathchForVer(cur)
				If Len(s) > 0 Then
					Db.Execute s
				Else
					Db.Execute "ROLLBACK TRANSACTION"
					PatchTo = False
					Exit Function
				End If
				If Err.Number <> 0 Then
					Db.Execute "ROLLBACK TRANSACTION"
					PatchTo = False
					Exit Function
				Else
					Db.Execute "COMMIT TRANSACTION"
				End If
				cur = Version
			Loop While cur < ver
			PatchTo = True
		End Function
		Public Function PatchMax() ' As Boolean
			Dim s, cur
			cur = Version
			
			On Error Resume Next
			Do
				Err.Clear
				Db.Execute "BEGIN TRANSACTION"
				s = GetPathchForVer(cur)
				If Len(s) > 0 Then
					Db.Execute s
				Else
					Db.Execute "ROLLBACK TRANSACTION"
					PatchMax = True
					Exit Function
				End If
				If Err.Number <> 0 Then
					Db.Execute "ROLLBACK TRANSACTION"
					PatchMax = False
					Exit Function
				Else
					Db.Execute "COMMIT TRANSACTION"
				End If
				cur = Version
			Loop
			PatchMax = True
		End Function
		
	End Class

%>