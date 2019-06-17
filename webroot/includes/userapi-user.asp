<%
    ' Package:  UserAPI 
    ' Version:  2011-04-10
    ' File:     userapi-user.asp
    ' Description:
    '   Defines CUser class and suporting routines and constants.
    '   Defines the supported access levels and SQL access routines for use in queries
    
    ' Misc constants
    
        
    Const FR_EXEC       = 1 ' Const FR_EXEC = 1
    Const FR_READ       = 2
    Const FR_FILL       = 4 ' Put items in a container (if the record is a container)
    Const FR_SUB        = 8 ' Put sub containers in this one
    Const FR_WRITE      = 16 ' Write
    
    ' For the current user only
    Function SQLAccessRightsTable(table,accessLevel)
        SQLAccessRightsTable =  " (Parameter('USER_LEVEL') >= 100 OR " & _
                                " (Parameter('USER_LEVEL') = 1 AND " & table & ".OWNER_GROUP_ID=Parameter('GROUP_ID')) OR " & _
                                " (Parameter('USER_LEVEL') = 2 AND " & table & ".R_GROUP>=" & accessLevel & ") OR " & _
                                "  (Parameter('USER_ID')=" & table & ".OWNER_USER_ID AND " & table & ".R_USER>=" & accessLevel & ") OR " & _
                                "  (Parameter('GROUP_ID')=" & table & ".OWNER_GROUP_ID AND " & table & ".R_GROUP>=" & accessLevel & ") OR " & _
                                "  (" & table & ".R_ALL>=" & accessLevel & "))"
    End Function
    Function SQLAccessRights(accessLevel)
        SQLAccessRights =  " (Parameter('USER_LEVEL') >= 100 OR " & _
                           " (Parameter('USER_LEVEL') = 1 AND OWNER_GROUP_ID=Parameter('GROUP_ID')) OR " & _
                           " (Parameter('USER_LEVEL') = 2 AND R_GROUP>=" & accessLevel & ") OR " & _
                           "  (Parameter('USER_ID')=OWNER_USER_ID AND R_USER>=" & accessLevel & ") OR " & _
                           "  (Parameter('GROUP_ID')=OWNER_GROUP_ID AND R_GROUP>=" & accessLevel & ") OR " & _
                           "  (R_ALL>=" & accessLevel & "))"
    End Function
    
    Function SQLAccessRightsTableD(table, accessLevel,d)
        SQLAccessRightsTableD = SQLAccessRightsTable(table,accessLevel) & " AND NOT " & table & ".DELETED"
    End Function
    Function SQLAccessRightsD(table, accessLevel,d)
        SQLAccessRightsD = SQLAccessRights(table,accessLevel) & " AND NOT DELETED"
    End Function
    
    Function SQLExecRights
        SQLExecRights = SQLAccessRights(FR_EXEC)
    End Function
    Function SQLExecRightsTable(table)
        SQLExecRightsTable = SQLAccessRightsTable(table, FR_EXEC)
    End Function
    Function SQLReadRights
        SQLReadRights = SQLAccessRights(FR_READ)
    End Function
    Function SQLReadRightsTable(table)
        SQLReadRightsTable = SQLAccessRightsTable(table,FR_READ)
    End Function
    Function SQLWriteRightsTable()
        SQLWriteRightsTable = SQLAccessRights(FR_WRITE)
    End Function
    Function SQLWriteRightsTable(table)
        SQLWriteRightsTable = SQLAccessRightsTable(table,FR_WRITE)
    End Function

    Function Create_CUser(db)
        Dim u
        Set u = New CUser
        Set u.Database = db
    End Function

    Class CUser
        Public Id, Login, Email, Language, Level, GroupId
        Public R_USER, R_GROUP, R_ALL, PersonId
        Public Database ' As CDatabase
        Public LastError ' Used in some cases to report an error of secondary importance
        Public Password ' Available only immediately after logon/autologon - not persisted !!!
    
        Private Sub Class_Initialize
            Id = 0
            Login = Empty
            Email = Empty
            Language = PageUILanguage
            Level = 0
            GroupId = 0
            R_USER = 0
            R_GROUP = 0
            R_ALL = 0
            PersonId = 0
            Set Database = Nothing
        End Sub
        
        ' Indicators - note that these treat any loaded user as logged on
        '   The check will have a real meaning only if this is the instance that represents the current user
        Public Property Get IsLoggedOn
            If ConvertTo(vbLong, Id) <> 0 Then
                IsLoggedOn = True
            Else
                IsLoggedOn = False
            End If
        End Property
        Public Property get IsAdmin
            If IsLoggedOn And Level >= cUserAccessAdmin Then
                IsAdmin = True
            Else
                IsAdmin = False
            End If 
        End Property
        
        ' Database transfer and login
        Public Function LoadDefaultRights
            Dim r
            LoadDefaultRights = False
            If Not IsLoggedOn Then Exit Function
            Set r = Database.DB.VExecute("SELECT * FROM USER_ACCESSDEFAULTS WHERE USER_ID=$USER_ID",1,1,ConvertTo(vbLong,Id))
            If r.Count <> 0 Then
                R_USER = ConvertTo(vbLong, r(1)("R_USER"))
                R_GROUP = ConvertTo(vbLong, r(1)("R_GROUP"))
                R_ALL = ConvertTo(vbLong, r(1)("R_ALL"))
            Else
                Set r = Database.DB.VExecute("SELECT * FROM GROUP_ACCESSDEFAULTS WHERE GROUP_ID=$GROUP_ID",1,1,ConvertTo(vbLong, GroupId))
                If r.Count <> 0 Then
                    R_USER = ConvertTo(vbLong, r(1)("R_USER"))
                    R_GROUP = ConvertTo(vbLong, r(1)("R_GROUP"))
                    R_ALL = ConvertTo(vbLong, r(1)("R_ALL"))
                Else
                    If IsAdmin Then
                        R_USER = RA_USER_DEFAULT
                        R_GROUP = RA_GROUP_DEFAULT
                        R_ALL = RA_ALL_DEFAULT
                    Else
                        R_USER = RU_USER_DEFAULT
                        R_GROUP = RU_GROUP_DEFAULT
                        R_ALL = RU_ALL_DEFAULT
                    End If
                End If
            End If
            LoadDefaultRights = True
        End Function
        Public Function Load(ident)
            Dim r
            Load = False
            Set r = Database.DB.VExecute("SELECT * FROM USER WHERE ID=$ID OR LOGIN=$LOGIN OR EMAIL=$LOGIN",1,1, _
                            NullConvertTo(vbLong, ident), NullConvertTo(vbString, ident))
            If r.Count > 0 Then
                Set r = r(1)
                Id = ConvertTo(vbLong, r("ID"))
                Login = ConvertTo(vbString, r("LOGIN"))
                Email = ConvertTo(vbString, r("EMAIL"))
                Language = ConvertTo(vbString, r("LANGUAGE"))
                If Len(Language) = 0 Then Language = PageUILanguage
                Level = ConvertTo(vbLong, r("LEVEL"))
                GroupId = ConvertTo(vbLong, r("GROUP_ID"))
                PersonId = ConvertTo(vbLong, r("PERSON_SID"))
                LoadDefaultRights
                Load = True
            End If
        End Function
        Public Function SendCredentialsEx(forceLanguage)
            Dim r, rp, m, params
            SendCredentialsEx = False
            If Not IsLoggedOn Then Exit Function
            Set r = Database.DB.VExecute("SELECT * FROM USER WHERE ID=$ID",1,1,Id)
            If r.Count > 0 Then
                Set r = r(1)
                Set rp = Database.DB.VExecute("SELECT * FROM PERSON WHERE SID=$PERSON_SID AND LANGUAGE=$LANGUAGE AND NOT DELETED",1,1, _
                                                NullConvertTo(vbLong, r("PERSON_SID")), PageUILanguage)
                Set m = New CMail
                m.Trace = False
                m.SetAdminSender cMailFromName
                Set params = CreateDictionary
                If rp.Count > 0 Then
                    Set rp = rp(1)
                    params("NAME1") = ConvertTo(vbString, rp("NAME1"))
                    params("NAME2") = ConvertTo(vbString, rp("NAME2"))
                    params("NAME3") = ConvertTo(vbString, rp("NAME3"))
                End If
                params("Login") = ConvertTo(vbString,r("LOGIN"))
                params("Password") = ConvertTo(vbString,r("PASS"))
                params("Email") = ConvertTo(vbString,r("EMAIL"))
                If Not m.Load("ACCOUNT_CREDENTIALS",IfThenElse(Len(forceLanguage)>0,forceLanguage,Language),params) Then
                    Database.AddError TR("Error loading the mail template")
                    Exit Function
                End If
                m.ToUser Id
                If Not m.Send Then
                    Database.AddError TR("Error") & " " & m.ErrorMessage
                Else
                    SendCredentialsEx = True
                End If
            End If
        End Function
        Function SendCredentials
            SendCredentials = SendCredentialsEx(PageUILanguage)
        End Function
        
        Public Function SetPersonId(pid)
            SetPersonId = False
            If IsLoggedOn Then
                If Database.BeginTransaction Then
                    On Error Resume Next
                    Database.DB.VExecute "UPDATE USER SET PERSON_SID=$PERSON_SID WHERE ID=$ID",1,0,NullConvertTo(vbLong,pid),Id
                    If Database.CompleteTransaction Then
                        SetPersonId = True
                        PersonId = ConvertTo(vbLong, pid)
                    End If
                End If
            End If
        End Function
        Public Function SetPassword(p)
            SetPassword = False
            If IsLoggedOn Then
                If Database.BeginTransaction Then
                    On Error Resume Next
                    Database.DB.VExecute "UPDATE USER SET PASS=$PASS WHERE ID=$ID",1,0,NullConvertTo(vbString,p),Id
                    If Database.CompleteTransaction Then
                        SetPassword = True
                    End If
                End If
            End If
        End Function
        Public Function SetEmail(p)
            SetEmail = False
            If IsLoggedOn Then
                If Database.BeginTransaction Then
                    On Error Resume Next
                    Database.DB.VExecute "UPDATE USER SET EMAIL=$EMAIL WHERE ID=$ID",1,0,NullConvertTo(vbString,p),Id
                    If Database.CompleteTransaction Then
                        Email = ConvertTo(vbsTring, p)
                        SetEmail = True
                    End If
                End If
            End If
        End Function
        
        Public Function LogOn(l,p,e)
            LogOn = False
            Clear ' It is better this way here
            If Len(p) > 0 Then
                Set r = Database.DB.VExecute("SELECT * FROM USER WHERE NOT DELETED AND (LOGIN=$L OR EMAIL=$E) " & _
                                                "AND PASS=$P AND (FAILURES ISNULL OR FAILURES < 5 OR ATTEMPTED ISNULL OR OleDateDiff('m',ATTEMPTED,OleSysTime()) > 5)", _
                                                1,1,NullConvertTo(vbString,l),NullConvertTo(vbString,e),NullConvertTo(vbString,p))
                If r.Count > 0 Then
                    If p = ConvertTo(vbString,r(1)("PASS")) Then
                        If Not ConvertTo(vbBoolean, r(1)("DELETED")) Then ' Note that currently this is shorted out by the query above
                            Set r = r(1)
                            Id = ConvertTo(vbLong, r("ID"))
                            Login = ConvertTo(vbString, r("LOGIN"))
                            Email = ConvertTo(vbString, r("EMAIL"))
                            Language = PageUILanguage
                            Level = ConvertTo(vbLong, r("LEVEL"))
                            GroupId = ConvertTo(vbLong, r("GROUP_ID"))
                            PersonId = ConvertTo(vbLong, r("PERSON_SID"))
                            Password = p
                            
                            ' Mark the success
                            Database.DB.VExecute "UPDATE USER SET ATTEMPTED=OleSysTime(), FAILURES = 0,[IP]=$IP WHERE ID=$USER_ID", 1, 0, _
                                                NullConvertTo(vbLong,ASPVARS("REMOTE_ADDR")), NullConvertTo(vbLong,Id)
                            ' Load default rights
                            LoadDefaultRights
                            
                            LogOn = True
                            Exit Function
                        Else
                            LastError = TR("This account has been disabled.")
                        End If
                    End If
                Else
                    ' Mark the failure
                    Database.DB.VExecute "UPDATE USER SET ATTEMPTED=OleSysTime(), FAILURES = FAILURES + 1 WHERE (LOGIN=$L OR EMAIL=$E)", _
                                            1, 0, NullConvertTo(vbString,l), NullConvertTo(vbString,e)
                End If
            End If
        End Function
        Function AutoLogOn
            Dim savedHash
            Clear
            AutoLogOn = False
            If IsALP Or IsLoggedOn Then Exit Function
            ' Collect the data
            If Request.Cookies("ASPCTLLogin").HasKeys Then
                savedHash = ConvertTo(vbString,Request.Cookies("ASPCTLLogin")("hash"))
                Login = ConvertTo(vbString,Request.Cookies("ASPCTLLogin")("login"))
            Else
                Exit Function
            End If
            If Len(savedHash) = 0 Or Len(Login) = 0 Then Exit Function
            
            If CheckLoginHash(savedHash) Then
                AutoLogOn = True
            Else
                Login = Empty
            End If
        End Function
        Public Function LogOff
            Clear
        End Function
        Public Function GenerateLoginHash(pwd)
            Dim hasher, ua, c, h
            GenerateLoginHash = False
            ua = ConvertTo(vbString,ASPVARS("HTTP_USER_AGENT"))
            c = Login & "|" & ua
            ' The user's login and IP are hashed using his/her password as HMAC key
            Set hasher = Server.CreateObject("newObjects.crypt.HashObject")
            hasher.InitHash "SHA1"
            hasher.CodePage = 65001
            hasher.Key = pwd
            hasher.HashData c
            GenerateLoginHash = hasher.Value
        End Function
        Function SaveAutoLogin(pwd)
            Dim h
            SaveAutoLogin = False
            If IsALP Then Exit Function
            h = LCase(GenerateLoginHash(pwd))
            If Len(h) > 0 Then
                Response.Cookies("ASPCTLLogin")("hash") = h
                Response.Cookies("ASPCTLLogin")("login") = Login
                Response.Cookies("ASPCTLLogin").Path = BasePath
                Response.Cookies("ASPCTLLogin").Expires = DateAdd("d",cAutoLoginDays,Now)
                SaveAutoLogin = True
            End If
        End Function
        Public Function RemoveAutoLogin
            Response.Cookies("ASPCTLLogin") = ""
            Response.Cookies("ASPCTLLogin").Path = BasePath
            Response.Cookies("ASPCTLLogin").Expires = DateAdd("d",cAutoLoginDays,Now)
            RemoveAutoLogin = True
        End Function
        Private Function CheckLoginHash(hash)
            Dim r, p, computedHash
            CheckLoginHash = False
            If Len(hash) = 0 Then Exit Function ' Not counted as login
            Set r = Database.DB.VExecute("SELECT * FROM USER WHERE LOGIN=$L AND (FAILURES ISNULL OR FAILURES < 5 OR ATTEMPTED ISNULL OR OleDateDiff('m',ATTEMPTED,OleSysTime()) > 5)", _
                                            1,1,NullConvertTo(vbString,Login))
            If r.Count > 0 Then
                If Not ConvertTo(vbBoolean, r(1)("DELETED")) Then ' Not shorted out
                    computedHash = GenerateLoginHash(ConvertTo(vbString,r(1)("PASS")))
                    If LCase(computedHash) = LCase(hash) Then
                        Set r = r(1)
                        Id = ConvertTo(vbLong, r("ID"))
                        Login = ConvertTo(vbString, r("LOGIN"))
                        Email = ConvertTo(vbString, r("EMAIL"))
                        Language = PageUILanguage
                        Level = ConvertTo(vbLong, r("LEVEL"))
                        GroupId = ConvertTo(vbLong, r("GROUP_ID"))
                        PersonId = ConvertTo(vbLong, r("PERSON_SID"))
                        Password = ConvertTo(vbString,r("PASS"))
                        
                        ' Mark the success
                        Database.DB.VExecute "UPDATE USER SET ATTEMPTED=OleSysTime(), FAILURES = 0,[IP]=$IP WHERE ID=$USER_ID", 1, 0, _
                                             NullConvertTo(vbLong,ASPVARS("REMOTE_ADDR")), NullConvertTo(vbLong, Id)
                        ' Load default rights
                        LoadDefaultRights
                        CheckLoginHash = True
                    Else
                        RemoveAutoLogin
                        Database.DB.VExecute "UPDATE USER SET ATTEMPTED=OleSysTime(), FAILURES = FAILURES + 1 WHERE (LOGIN=$L)", 1, 0, NullConvertTo(vbString,Login)
                    End If
                Else
                    RemoveAutoLogin
                    LastError = TR("This account has been disabled.")
                End If
            End If
        End Function
        
        ' Rights and quota checkers
        Function HasRight(uid,gid,ru,rg,ra,accessLevel) ' Low level access logic, should not be used directly
            HasRight = False
            If IsAdmin Then
                HasRight = True
                Exit Function
            ElseIf IsLoggedOn Then
                If ConvertTo(vbLong,uid) = Id Then
                    If ConvertTo(vbLong, ru) >= accessLevel Then
                        HasRight = True
                        Exit Function
                    End If
                End If
                If Level = 1 And ConvertTo(vbLong,gid) = GroupId Then
                    HasRight = True
                    Exit Function
                End If
                If ConvertTo(vbLong,gid) = GroupId Or Level = 2 Then
                    If ConvertTo(vbLong, rg) >= accessLevel Then
                        HasRight = True
                        Exit Function
                    End If
                End If
                If ConvertTo(vbLong, ra) >= accessLevel Then
                    HasRight = True
                    Exit Function
                End If
            Else
                If ConvertTo(vbLong, ra) >= accessLevel Then
                    HasRight = True
                    Exit Function
                End If
            End If
        End Function
        
        Function CanAccessItem(sid, table, accessLevel)
            Dim rec
            CanAccessItem = False
            Set rec = Database.DB.VExecute("SELECT SID, OWNER_USER_ID, OWNER_GROUP_ID, R_USER, R_GROUP, R_ALL FROM [" & _
                                           table & "] WHERE SID=$SID LIMIT 1",1,1,NullConvertTo(vbLong, sid))
            If rec.Count > 0 Then
                CanAccessItem = HasRight(rec("OWNER_USER_ID"),rec("OWNER_GROUP_ID"),rec("R_USER"),rec("R_GROUP"),rec("R_ALL"),accessLevel)
            End If
        End Function
        
        Function CanAccessRecord(rcoll, accessLevel)
            Dim r
            CanAccessRecord = False
            If IsNotObject(rcoll) Then
                Err.Raise 1, "CUser", "No record supplied to CanWriteRecord"
                Exit Function
            Else
                If rcoll.Count <= 0 Then Exit Function
                Set r = rcoll(1)
                CanAccessRecord = HasRight(r("OWNER_USER_ID"),r("OWNER_GROUP_ID"),r("R_USER"),r("R_GROUP"),r("R_ALL"),accessLevel)
            End If
        End Function
        
        Function CanWriteRecord(rcoll)
            Dim r
            CanWriteRecord = False
            If IsNotObject(rcoll) Then
                Err.Raise 1, "CUser", "No record supplied to CanWriteRecord"
                Exit Function
            Else
                If rcoll.Count <= 0 Then Exit Function
                Set r = rcoll(1)
                CanWriteRecord = HasRight(r("OWNER_USER_ID"),r("OWNER_GROUP_ID"),r("R_USER"),r("R_GROUP"),r("R_ALL"),FR_WRITE)
            End If
        End Function
        Function CanReadRecord(rcoll)
            Dim r
            CanReadRecord = False
            If IsNotObject(rcoll) Then
                Err.Raise 1, "CUser", "No record supplied to CanReadRecord"
                Exit Function
            Else
                If rcoll.Count <= 0 Then Exit Function
                Set r = rcoll(1)
                CanReadRecord = HasRight(r("OWNER_USER_ID"),r("OWNER_GROUP_ID"),r("R_USER"),r("R_GROUP"),r("R_ALL"),FR_READ)
            End If
        End Function
        Function CanAccess(rec, accessLevel) ' For use when rendering lists to indicate which are writable for the current user
            CanAccess = False
            If IsNotObject(rec) Then
                Err.Raise 1, "CUser", "No record supplied to CanWrite"
                Exit Function
            Else
                CanAccess = HasRight(rec("OWNER_USER_ID"),rec("OWNER_GROUP_ID"),rec("R_USER"),rec("R_GROUP"),rec("R_ALL"),accessLevel)
            End If
        End Function
        
        Function CanWrite(rec) ' For use when rendering lists to indicate which are writable for the current user
            CanWrite = False
            If IsNotObject(rec) Then
                Err.Raise 1, "CUser", "No record supplied to CanWrite"
                Exit Function
            Else
                CanWrite = HasRight(rec("OWNER_USER_ID"),rec("OWNER_GROUP_ID"),rec("R_USER"),rec("R_GROUP"),rec("R_ALL"),FR_WRITE)
            End If
        End Function
        
        Function UpdateSecurity(table, sid, bUserOwn,bGroupOwn,ru,rg,ra)
            UpdateSecurity = False
            If Not IsLoggedOn Then Exit Function
            If Database.BeginTransaction Then
            On Error Resume Next
                If bUserOwn Then
                    Database.DB.VExecute "UPDATE [" & table & "] SET OWNER_USER_ID=$UID WHERE SID=$SID",1,0,NullConvertTo(vbLong,Id),NullConvertTo(vbLong,sid)
                End If
                If bGroupOwn Then
                    Database.DB.VExecute "UPDATE [" & table & "] SET OWNER_GROUP_ID=$UID WHERE SID=$SID",1,0,NullConvertTo(vbLong,GroupId),NullConvertTo(vbLong,sid)
                End If
                Database.DB.VExecute "UPDATE [" & table & "] SET R_USER=$RU,R_GROUP=$RG,R_ALL=$RA WHERE SID=$SID",1,0,_
                                        NullConvertTo(vbLong,ru),NullConvertTo(vbLong,rg),NullConvertTo(vbLong,ra),_
                                        NullConvertTo(vbLong,sid)
                
                If Database.CompleteTransaction Then
                    UpdateSecurity = True
                End If
            End If
        End Function
        
        
        Function GetQuotaAvaliable(Table, bGrp, bDelta) ' Low level routine
            Dim n, nDays, r
            Set r = Database.DB.VExecute("SELECT DAYS FROM USER_QUOTAS WHERE USER_ID=$USER_ID",1,1,NullConvertTo(vbLong, Id))
            If r.Count = 0 Then
                Set r = Database.DB.VExecute("SELECT DAYS FROM GROUP_QUOTAS WHERE GROUP_ID=$GROUP_ID",1,1,NullConvertTo(vbLong, GroupId))
                If r.Count = 0 Then
                    nDays = 1
                Else
                    nDays = ConvertTo(vbLong, r(1)(1))
                End If
            Else
                nDays = ConvertTo(vbLong, r(1)(1))
            End If
            If nDays < 1 Then nDays = 1
            
            On Error Resume Next
            If bDelta Then
                ' The code here walks around a problem with the SQLite3 COM compiled with an option to return errors on invalid arguments
                '   passed to OLE Date/Time functions
                If bGrp Then
                    n = Database.DB.VExecute("SELECT (SELECT [" & Table & "] FROM GROUP_DELTA_QUOTAS WHERE GROUP_ID=$GROUP_ID) - COUNT(*) " & _
                                        " FROM [" & Table & "] WHERE OWNER_USER_ID=$USER_ID AND NOT DELETED AND " & _
                                        "   (CASE WHEN CREATED ISNULL THEN 0 ELSE OleDateDiff('D',CREATED,OleSysTime()) < " & nDays & " END)", _
                                        1,1,NullConvertTo(vbLong,GroupId), NullconvertTo(vbLong, Id))(1)(1)
                Else
                    n = Database.DB.VExecute("SELECT (SELECT [" & Table & "] FROM USER_DELTA_QUOTAS WHERE USER_ID=$USER_ID) - COUNT(*) " & _
                                        " FROM [" & Table & "] WHERE OWNER_USER_ID=$USER_ID AND NOT DELETED AND " & _
                                        "   (CASE WHEN CREATED ISNULL THEN 0 ELSE OleDateDiff('D',CREATED,OleSysTime()) < " & nDays & " END)", _
                                        1,1, NullConvertTo(vbLong, Id))(1)(1)
                End If
            Else
                If bGrp Then
                    n = Database.DB.VExecute("SELECT (SELECT [" & Table & "] FROM GROUP_QUOTAS WHERE GROUP_ID=$GROUP_ID) - COUNT(*) " & _
                                            " FROM [" & Table & "] WHERE OWNER_USER_ID=$USER_ID AND NOT DELETED",1,1, NullConvertTo(vbLong,GroupId), NullConvertTo(vbLong,Id))(1)(1)
                Else
                    n = Database.DB.VExecute("SELECT (SELECT [" & Table & "] FROM USER_QUOTAS WHERE USER_ID=$USER_ID) - COUNT(*) " & _
                                            " FROM [" & Table & "] WHERE OWNER_USER_ID=$USER_ID AND NOT DELETED",1,1, NullConvertTo(vbLong,Id))(1)(1)
                End If
            End IF
            If Err.Number <> 0 Then 
                GetQuotaAvaliable = 0
                Exit Function
                Dim sErr
                sErr = Err.Description
                On Error Goto 0
                Err.Raise 1, "usearapi-user.GetQuotaAvailable table=" & Table,sErr
            End If
            
            
            GetQuotaAvaliable = n
        End Function
        Function GetEffectiveQuotaAvailable(Table,bDelta)
            Dim n
            n = GetQuotaAvaliable(Table, False, bDelta)
            If IsNull(n) Then
                n = GetQuotaAvaliable(Table, True, bDelta)
            End If
            GetEffectiveQuotaAvailable = n
        End Function
        Function CheckQuota(Table)
            CheckQuota = False
            If Not IsLoggedOn Then Exit Function
            If IsAdmin Then
                CheckQuota = True
                Exit Function
            End If
            If Not IsOneOf(UCQuotas_QFields,UCase(Table),",") Then
                CheckQuota = True
                Exit Function
            End If
            Dim n, r
            If Not IsOneOf(CheckQuota_Ignore,table,",") Then
                n = GetQuotaAvaliable(Table, False, False)
                If IsNull(n) Then
                    n = GetQuotaAvaliable(Table, True, False)
                End If
                If Not IsNull(n) Then
                    If n > 0 Then
                        CheckQuota = True
                        Exit Function
                    End If
                End If
            Else
                CheckQuota = True
            End If
        End Function
        Function CheckDeltaQuota(Table)
            CheckDeltaQuota = False
            If Not IsLoggedOn Then Exit Function
            If IsAdmin Then
                CheckDeltaQuota = True
                Exit Function
            End If
            If Not IsOneOf(UCQuotas_QFields,UCase(Table),",") Then
                CheckDeltaQuota = True
                Exit Function
            End If
            Dim n, r
            If Not IsOneOf(CheckDeltaQuota_Ignore,table,",") Then
                n = GetQuotaAvaliable(Table, False, True)
                If IsNull(n) Then
                    n = GetQuotaAvaliable(Table, True, True)
                End If
                If Not IsNull(n) Then
                    If n > 0 Then
                        CheckDeltaQuota = True
                        Exit Function
                    End If
                End If
            Else
                CheckDeltaQuota = True
            End If
        End Function
        Function CheckQuotas(Table)
            CheckQuotas = False
            If Not CheckQuota(Table) Then Exit Function
            If Not CheckDeltaQuota(Table) Then Exit Function
            CheckQuotas = True
        End Function
        
        ' User services - individual functional rights (all must be positive boooleans)
        Private rUserServices
        Private Function LoadUserServices
            Dim r
            Set r = Database.DB.VExecute("SELECT * FROM USER_SERVICES WHERE USER_ID=$USER_ID",1,1,NullConvertTo(vbLong,Id))
            If r.Count > 0 Then
                Set rUserServices = r(1)
                Exit Function
            End If
            Set r = Database.DB.VExecute("SELECT * FROM GROUP_SERVICES WHERE GROUP_ID=$GROUP_ID",1,1,NullConvertTo(vbLong,GroupId))
            If r.Count > 0 Then
                Set rUserServices = r(1)
                Exit Function
            End If
            Set rUserServices = CreateCollection
        End Function
        Function IsServiceAllowed(svcName)
            If IsAdmin Then
                IsServiceAllowed = True
                Exit Function
            End If
            If Not IsObject(rUserServices) Then
                LoadUserServices
            End If
            IsServiceAllowed = ConvertTo(vbBoolean, rUserServices(svcName))
        End Function
        ' Mail notifications
        Private rNotifications
        Private Function LoadUserNotifications
            Dim r
            Set r = Database.DB.VExecute("SELECT * FROM USER_NOTIFY WHERE USER_ID=$USER_ID",1,1,NullConvertTo(vbLong,Id))
            If r.Count > 0 Then
                Set rNotifications = r(1)
                Exit Function
            End If
            Set r = Database.DB.VExecute("SELECT * FROM GROUP_NOTIFY WHERE GROUP_ID=$GROUP_ID",1,1,NullConvertTo(vbLong,GroupId))
            If r.Count > 0 Then
                Set rNotifications = r(1)
                Exit Function
            End If
            Set rNotifications = CreateCollection
        End Function
        Function PermitNotification(notifyName)
            If Not IsObject(rNotifications) Then
                LoadUserNotifications
            End If
            PermitNotification = ConvertTo(vbBoolean, rNotifications(notifyName))
        End Function
        
        
        ' Display helpers
        Public Function DisplayName
            If IsAdmin Then
                DisplayName = Login & "*"
            Else
                DisplayName = Login
            End If
        End Function
        
        ' Persistence
        Public Sub Clear
            Id = 0
            Login = Empty
            Email = Empty
            Language = PageUILanguage
            Level = 0
            GroupId = 0
            R_USER = 0
            R_GROUP = 0
            R_ALL = 0
            PersonId = 0
        End Sub
        Public Function GetTS
            Dim ts
            Set ts = CreateTSSection("CUser")
            ts("ID") = ConvertTo(vbLong, Id)
            ts("LOGIN") = ConvertTo(vbString, Login)
            ts("EMAIL") = ConvertTo(vbString, Email)
            ts("LANGUAGE") = ConvertTo(vbString, Language)
            ts("LEVEL") = ConvertTo(vbLong, Level)
            ts("GID") = ConvertTo(vbLong, GroupId)
            ts("R_USER") = ConvertTo(vbLong, R_USER)
            ts("R_GROUP") = ConvertTo(vbLong, R_GROUP)
            ts("R_ALL") = ConvertTo(vbLong, R_ALL)
            ts("PERSON_SID") = ConvertTo(vbLong, PersonId)
            Set GetTS = ts
        End Function
        Public Function SetTS(ts)
            SetTS = False
            Id = ConvertTo(vbLong, ts("ID"))
            Login = ConvertTo(vbString, ts("LOGIN"))
            Email = ConvertTo(vbString, ts("EMAIL"))
            Language = ConvertTo(vbString, ts("LANGUAGE"))
            Level = ConvertTo(vbLong, ts("LEVEL"))
            GroupId = ConvertTo(vbLong, ts("GID"))
            R_USER = ConvertTo(vbLong, ts("R_USER"))
            R_GROUP = ConvertTo(vbLong, ts("R_GROUP"))
            R_ALL = ConvertTo(vbLong, ts("R_ALL"))
            PersonId = ConvertTo(vbLong, ts("PERSON_SID"))
            SetTS = True
        End Function
        Public Function Serialize(bEncrypt)
            Dim ts
            Set ts = GetTS
            Serialize = TSToHex(ts, bEncyrpt)
        End Function
        Public Function Deserialize(sData, bDecrypt)
            Dim ts
            Set ts = TSFromHex(sData, bDecrypt)
            Deserialize = SetTS(ts)                
        End Function
        Public Function SaveToSession(sesName)
            Dim s
            SaveToSession = False
            s = Serialize(False)
            If Len(s) > 0 Then
                SaveToSession = True
                Session(sesName) = s
            End If
        End Function
        Public Function LoadFromSession(sesName)
            LoadFromSession = Deserialize(Session(sesName), False)
        End Function
        
        ' Maintenance
        Function InitServicesFromGroup
            Database.DB.VExecute "INSERT INTO USER_SERVICES (USER_ID," & CreateSQLParameterList(UCServices_Fields) & ") SELECT $USER_ID," & _
                                 CreateSQLParameterList(UCServices_Fields) & " FROM GROUP_SERVICES WHERE GROUP_ID=$GROUP_ID",1,0,_
                                 Id, GroupId
        End Function
        Function InitQuotasFromGroup
            Database.DB.VExecute "INSERT INTO USER_QUOTAS (USER_ID," & CreateSQLParameterList(UCQuotas_QFields) & ",DAYS) SELECT $USER_ID," & _
                                 CreateSQLParameterList(UCQuotas_QFields) & ",DAYS FROM GROUP_QUOTAS WHERE GROUP_ID=$GROUP_ID",1,0,_
                                 Id, GroupId
            Database.DB.VExecute "INSERT INTO USER_DELTA_QUOTAS (USER_ID," & CreateSQLParameterList(UCQuotas_QFields) & ") SELECT $USER_ID," & _
                                 CreateSQLParameterList(UCQuotas_QFields) & " FROM GROUP_DELTA_QUOTAS WHERE GROUP_ID=$GROUP_ID",1,0,_
                                 Id, GroupId                                 
        End Function
        Function InitDefaultRightsFromGroup
            Database.DB.VExecute "INSERT INTO USER_ACCESSDEFAULTS (USER_ID,R_USER,R_GROUP,R_ALL) SELECT $USER_ID," & _
                                 "  R_USER, R_GROUP, R_ALL FROM GROUP_ACCESSDEFAULTS WHERE GROUP_ID=$GROUP_ID",1,0,_
                                 Id, GroupId
        End Function
        Function InitNotifyFromGroup
            Database.DB.VExecute "INSERT INTO USER_NOTIFY (USER_ID," & CreateSQLParameterList(UCNotify_Fields) & ") SELECT $USER_ID," & _
                                 CreateSQLParameterList(UCNotify_Fields) & " FROM GROUP_NOTIFY WHERE GROUP_ID=$GROUP_ID",1,0,_
                                 Id, GroupId
        End Function
        Function InitFromGroup
            InitServicesFromGroup
            InitQuotasFromGroup
            InitDefaultRightsFromGroup
            InitNotifyFromGroup
        End Function
        Function ClearSpecificSettings
            Database.DB.VExecute "DELETE FROM USER_SERVICES WHERE USER_ID=$USER_ID",1,0,Id
            Database.DB.VExecute "DELETE FROM USER_QUOTAS WHERE USER_ID=$USER_ID",1,0,Id
            Database.DB.VExecute "DELETE FROM USER_DELTA_QUOTAS WHERE USER_ID=$USER_ID",1,0,Id
            Database.DB.VExecute "DELETE FROM USER_ACCESSDEFAULTS WHERE USER_ID=$USER_ID",1,0,Id
            Database.DB.VExecute "DELETE FROM USER_NOTIFY WHERE USER_ID=$USER_ID",1,0,Id
        End Function
    End Class
    
    ' Registers a new user
    Function RegisterNewUser(login, pass, email, level, grpId)
        Set RegisterNewUser = Nothing
        Dim r, uid, oUser
        Set r = Database.DB.VExecute("SELECT * FROM USER WHERE LOGIN=$LOGIN OR EMAIL=$EMAIL",1,1, _
                                        NullConvertTo(vbString,login), NullConvertTo(vbString,email))
        If r.Count > 0 Then
            Database.AddError TR("The user name or the e-mail addressa are already in use.")
            Exit Function
        End If                                        
        If Database.BeginTransaction Then
        On Error Resume Next
            Set r = Database.DB.VExecute("INSERT INTO USER ([LOGIN], [PASS], [LEVEL], [EMAIL], [GROUP_ID], ATTEMPTED, FAILURES) VALUES " & _
                                         "($LOGIN, $PASS, $LEVEL, $EMAIL, $GROUP_ID, OleLocalTime(), 0)", 1, 0, _
                                            NullConvertTo(vbString, login), _
                                            NullConvertTo(vbString, pass), _
                                            NullConvertTo(vbLong, level), _
                                            NullConvertTo(vbString, email), _
                                            NullConvertTo(vbLong, grpId) )
            uid = r.Info
            Set oUser = New CUser
            set oUser.Database = Database
            If Not oUser.Load(uid) Then
                Err.Raise 1, "CUser", "User load failed"
            End If
            
            If Database.CompleteTransaction Then
                ' TO DO: Create a new user object for the new user
                Set RegisterNewUser = oUser
            End If                                            
        End If
        
    End Function

%>