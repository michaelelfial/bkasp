<%
    ' Package:  UserAPI 
    ' Version:  2011-04-11
    ' File:     userapi.asp
    ' Description:
    '   Main hub file for the UserAPI library
    '   UserAPI library provides user management and multilanguage support over a predefined DB schema pattern
    '   This file adds some globally useful constants as a standartization for the user controls and manages instances
    '   of some UserAPI classes.
    
    ' Custom header entries
    
    ' Create instances of some frequently used utility objects
    '   Can be used anywhere in the application
    Set StringUtilities = Server.CreateObject("newObjects.utilctls.StringUtilities")
    Set SFMain = Server.CreateObject("newObjects.utilctls.SFMain")
    
    ' Standard mode constants for user controls representing records - optional, but recommended use 
    Const UCMode_Slim           = 0 ' View single entry - the one selected, typically defined by the Id property
    Const UCMode_List           = 1 ' Browse for entry - list of entries possibly filtered according to some control settings
    Const UCMode_Form           = 2 ' Add/Eddit entry - edit the selcted entry
    Const UCMode_View           = 4 ' Full view
    
    ' ROOT DATABASE - the application may use more databases for specific purposes
    Dim Database
    Set Database = New CDatabase
    Database.DatabaseFile = cUserDataBase
    Database.SessionInitializer = "InitDatabaseConnection" ' Default implementation in configuration.asp
    
    
    Function GetSID(sid)
        Dim r
        If Database.BeginTransaction Then
            Set r = Database.DB.VExecute("SELECT ID FROM SYS WHERE ID=$ID",1,1,NullConvertTo(vbLong,sid))
            If r.Count > 0 Then
                GetSID = ConvertTo(vbLong, r(1)(1))
            Else
                Set r = Database.DB.VExecute("INSERT INTO SYS (UID) VALUES (?)",1,0,Database.NewUID)
                GetSID = ConvertTo(vbLong, r.Info)
            End If
            If Not Database.CompleteTransaction Then
                GetSID = Null
            End If
        Else
            GetSID = Null
        End If
    End Function
    
    Set CurrentUser = New CUser
    Set CurrentUser.Database = Database
    CurrentUser.LoadFromSession "CURRENT_USER" ' Then ' This gets the preserved user from the session (if any)
    If Not CurrentUser.IsLoggedOn Then
        ' Attempt autologin
        If CurrentUser.AutoLogOn Then
            If Not CurrentUser.SaveToSession("CURRENT_USER") Then
                Response.Write "Failed to save the user data in the session"
            Else
                Database.ReInitialize
            End If
        End If
    End If
    
    ' Proxies to current user
    Function LogOn(l,p,e,bSave)
        Dim b
        CurrentUser.LogOff
        b = CurrentUser.LogOn(l,p,e)
        LogOn = b
        If b Then
            If Not CurrentUser.SaveToSession("CURRENT_USER") Then
                Response.Write "Failed to save the user data in the session"
            Else
                Database.ReInitialize
            End If
            If bSave Then 
                CurrentUser.SaveAutoLogin CurrentUser.Password
            End If
        End If
    End Function
    ' Call this routine after making any changes to the current user!
    Function UpdateCurrentUser
        UpdateCurrentUser = CurrentUser.SaveToSession("CURRENT_USER")
    End Function
    
    Function LogOff
        CurrentUser.RemoveAutoLogin
        CurrentUser.LogOff
        CurrentUser.SaveToSession "CURRENT_USER"
    End Function
    Function AutoLogOn
        Dim b
        AutoLogOn = False
        If CurrentUser.IsLoggedOn Then Exit Function
        If CurrentUser.AutoLogOn Then
            CurrentUser.SaveToSession "CURRENT_USER"
            CurrentUser.SaveAutoLogin CurrentUser.Password
            AutoLogOn = True
        End If
    End Function
    Function RemoveAutoLogOn
        CurrentUser.RemoveAutoLogin
    End Function
    
    Function IsLoggedOn
        IsLoggedOn = CurrentUser.IsLoggedOn
    End Function
    Function IsAdmin
        IsAdmin = CurrentUser.IsAdmin
    End Function
    
    
    ' In-DB configuration support
    ' Simple config support - prefer the advanced configuration support. 
    Dim GetConfiguration_Cache
    Function GetConfiguration
        Dim r
        If IsObject(GetConfiguration_Cache) Then
            Set GetConfiguration = GetConfiguration_Cache
            Exit Function
        Else
            Set r = Database.DB.Execute("SELECT * FROM CONFIGURATION LIMIT 1")
            If r.Count > 0 Then
                Set GetConfiguration_Cache = r(1)
                Set GetConfiguration = r(1)
            Else
                ' This is just an extreme precaution - a default one always exists
                Set GetConfiguration = CreateCollection
            End If
        End If
    End Function
    
    ' Advanced configuration support
    Class CMainConfiguration
        Private cfg
        Private Sub LoadCfg
            If IsNotObject(cfg) Then
                Set cfg = Database.DB.Execute("SELECT * FROM CONFIGURATION LIMIT 1")(1)
            End If
        End Sub
        Private Sub SaveCfg
            If IsNotObject(cfg) Then Exit Sub
            If Database.BeginTransaction Then
            On Error Resume Next
                Database.DB.CExecute "UPDATE [CONFIGURATION] SET " & CreateSQLAssignList(cfg) & " WHERE ID=$ID", cfg
                Database.CompleteTransaction
            End If
        End Sub
        
        Public Default Property Get Value(n)
            LoadCfg
            Value = cfg(n)
        End Property
        Public Property Let Value(n,v)
            LoadCfg
            cfg(n) = v
            SaveCfg
        End Property
        
        Public Property Get CodeValue(sCode,pSid)
            Dim r
            Set r = Database.DB.VExecute("SELECT * FROM CONTENT_CONFIGURATION WHERE CODE=$CODE AND ($MSID ISNULL OR MAIN_SID=$MSID) LIMIT 1",1,1,_
                                            NullConvertTo(vbString,sCode), NullConvertTo(vbLong,pSid))
            If r.Count > 0 Then
                CodeValue = r(1)("OBJECT_SID") ' Treated as variant
            Else
                CodeValue = Null
            End If
        End Property
        Public Property Let CodeValue(sCode,pSid,v)
            Dim m, vv
            m = NullConvertTo(vbLong, pSid)
            If IsEmpty(v) Then 
                vv = Null
            Else
                vv = v
            End If
            If Database.BeginTransaction Then
            On Error Resume Next
                Database.DB.Vexecute "DELETE FROM CONTENT_CONFIGURATION WHERE CODE=$CODE AND ($MSID ISNULL OR MAIN_SID=$MSID)",1,0,NullConvertTo(vbString,sCode),m
                Database.DB.Vexecute "INSERT INTO CONTENT_CONFIGURATION (CODE,MAIN_SID,OBJECT_SID) VALUES ($CODE,$MSID,$OSID)",1,0,_
                                     NullConvertTo(vbString,sCode), m, vv
                Database.CompleteTransaction
            End If
        End Property
        Public Property Get CodeSid(c,msid) ' If msid is Null returns MAIN_SID for code otherwise SID for CODE/MAIN_SID
            Dim r
            Set r = Database.DB.VExecute("SELECT * FROM CONTENT_CONFIGURATION WHERE CODE=$CODE AND ($MSID ISNULL OR MAIN_SID=$MSID) LIMIT 1",1,1,_
                                            NullConvertTo(vbString,c), NullConvertTo(vbLong,msid))
            If r.Count > 0 Then
                If IsNull(NullConvertTo(vbLong,msid)) Then
                    CodeSid = ConvertTo(vbLong, r(1)("MAIN_SID"))
                Else
                    CodeSid = ConvertTo(vbLong, r(1)("OBJECT_SID"))
                End If
            Else
                CodeSid = 0
            End If
        End Property
        Public Property Let CodeSid(c,msid,v)
            Dim m
            m = NullConvertTo(vbLong, msid)
            If Database.BeginTransaction Then
            On Error Resume Next
                If IsNull(m) Then
                    Database.DB.Vexecute "DELETE FROM CONTENT_CONFIGURATION WHERE CODE=$CODE",1,0,NullConvertTo(vbString,c)
                    Database.DB.Vexecute "INSERT INTO CONTENT_CONFIGURATION (CODE,MAIN_SID) VALUES ($CODE,$MSID)",1,0,NullConvertTo(vbString,c),NullConvertTo(vbLong,v)
                Else
                    Database.DB.Vexecute "DELETE FROM CONTENT_CONFIGURATION WHERE CODE=$CODE AND MAIN_SID=$MSID",1,0,NullConvertTo(vbString,c),m
                    Database.DB.Vexecute "INSERT INTO CONTENT_CONFIGURATION (CODE,MAIN_SID,OBJECT_SID) VALUES ($CODE,$MSID,$OSID)",1,0,NullConvertTo(vbString,c),m,NullConvertTo(vbLong,v)
                End If
                Database.CompleteTransaction
            End If
        End Property
        
        
        
        Public Property Get Code(c)
            Code = CodeSid(c,Null)
        End Property
        Public Property Let Code(c,v)
            CodeSid(c,Null) = v
        End Property
    End Class
    Dim Configuration
    Set Configuration = New CMainConfiguration
    
    
    Function GetDatabaseItemSysInfo(sid, table)
        Set GetDatabaseItemSysInfo = GetDatabaseItemSysInfoLang(sid, table,PageUILanguage)
    End Function
    Function GetDatabaseItemSysInfoLang(sid, table,Lang)
        Dim r
        Set r = Database.DB.VExecute("SELECT SID, CREATED, MODIFIED, R_USER, R_GROUP, R_ALL, DELETED, CHANGED," & _
                                     "  MODIFY_USER_ID, " & _
                                     "  (SELECT LOGIN FROM USER WHERE ID=MODIFY_USER_ID) AS MODIFY_USER_LOGIN, " & _
                                     "  OWNER_USER_ID, " & _
                                     "  (SELECT LOGIN FROM USER WHERE ID=OWNER_USER_ID) AS OWNER_USER_LOGIN, " & _
                                     "  OWNER_GROUP_ID, " & _
                                     "  (SELECT NAME FROM S_GROUP WHERE ID=OWNER_GROUP_ID) AS OWNER_GROUP_NAME " & _
                                     "  FROM [" & Table & "] WHERE SID=$SID AND ($LANGUAGE ISNULL OR LANGUAGE=$LANGUAGE)",_
                                     1,1,NullConvertTo(vbLong, sid), NullConvertTo(vbString,Lang))
        If r.Count > 0 Then
            Set GetDatabaseItemSysInfoLang = r(1)
        Else
            Set GetDatabaseItemSysInfoLang = CreateCollection
        End If                                     
    End Function
    
    
    Function RightsDisplayText(r,bAll)
        Dim rghts
        rghts = ConvertTo(vbLong, r)
        If rghts >= FR_WRITE Then
            RightsDisplayText = TR("write/read")
        ElseIf rghts >= FR_READ Then
            RightsDisplayText = TR("read")
        ElseIf rghts >= FR_EXEC Then
            RightsDisplayText = TR("use (special)")
        Else
            RightsDisplayText = TR("no access")
        End If
    End Function
    
    ' Anonymous IP actions
    Function RequestAnonymousAction(actName,limitNum)
            Dim r, remoteIP, ua, acceptLang
            remoteIP = NullConvertTo(vbString,ASPVARS("REMOTE_ADDR"))
            ua = NullConvertTo(vbString, ASPVARS("HTTP_USER_AGENT"))
            acceptLang = NullConvertTo(vbString, ASPVARS("HTTP_ACCEPT_LANGUAGE"))
            RequestAnonymousAction = False
            
            Set r = Database.DB.VExecute("SELECT *, OleDateDiff('m',PERFORMED,OleSysTime()) AS INTERVAL " & _
                                         " FROM IPACTION WHERE [IP]=$IP AND [ACTION]=$ACTION",1,1, _
                                         remoteIP, NullConvertTo(vbString,actName))
            If r.Count > 0 Then
                If Not ConvertTo(vbBoolean,r(1)("BLOCKED")) Then
                    If ConvertTo(vbLong,r(1)("INTERVAL")) > 1440 Then
                        ' The interval from the last attempt has elapsed - unlock and clear the attempts count
                        Database.DB.VExecute "UPDATE IPACTION SET [ATTEMPTS]=1, [LOCKED]=0, [PERFORMED]=OleSysTime() WHERE " & _
                                             "[IP]=$IP AND [ACTION]=$ACTION", 1, 0, remoteIP, NullConvertTo(vbString,actName)
                        RequestAnonymousAction = True
                    Else
                        If ConvertTo(vbBoolean,r(1)("LOCKED")) Then
                            Exit Function ' Already locked
                        Else
                            If ConvertTo(vbLong, r(1)("ATTEMPTS")) >= limitNum Then
                                ' Lock the IP
                                Database.DB.VExecute "UPDATE IPACTION SET [LOCKED]=-1, [PERFORMED]=OleSysTime() WHERE " & _
                                                     "[IP]=$IP AND [ACTION]=$ACTION", 1, 0, remoteIP, NullConvertTo(vbString,actName)
                                Exit Function
                            Else
                                ' Increase the attempts count
                                Database.DB.VExecute "UPDATE IPACTION SET [ATTEMPTS]=[ATTEMPTS]+1, [PERFORMED]=OleSysTime() WHERE " & _
                                                     "[IP]=$IP AND [ACTION]=$ACTION", 1, 0, remoteIP, NullConvertTo(vbString,actName)
                                RequestAnonymousAction = True
                            End If
                        End If
                    End If
                End If
            Else
                ' Need to insert an initial entry
                Database.DB.Vexecute "INSERT INTO IPACTION ([IP],[ACTION],[PERFORMED],[ATTEMPTS],[UA],[HTTP_ACCEPT_LANGUAGE]) " & _
                                     "VALUES ($IP,$ACTION,OleSysTime(),1,$UA,$HTTP_ACCEPT_LANGUAGE)",1,0, _
                                     remoteIP, NullConvertTo(vbString,actName), ua, acceptLang
                RequestAnonymousAction = True ' The first time is always free
            End If                                         
        End Function
        Function LockAnonymousAction(ip,actName,bLock)
            If bLock Then
                Database.DB.VExecute "UPDATE IPACTION SET [LOCKED]=-1, [PERFORMED]=OleSysTime() WHERE " & _
                                     "[IP]=$IP AND [ACTION]=$ACTION", 1, 0, NullConvertTo(vbString,ip), NullConvertTo(vbString,actName)
            Else
                Database.DB.VExecute "UPDATE IPACTION SET [ATTEMPTS]=0, [LOCKED]=0, [PERFORMED]=OleSysTime() WHERE " & _
                                     "[IP]=$IP AND [ACTION]=$ACTION", 1, 0, NullConvertTo(vbString,ip), NullConvertTo(vbString,actName)
            End If
        End Function
        Function BlockAnonymousAction(ip,actName,bLock)
            If bLock Then
                Database.DB.VExecute "UPDATE IPACTION SET [BLOCKED]=-1 WHERE " & _
                                     "[IP]=$IP AND [ACTION]=$ACTION", 1, 0, NullConvertTo(vbString,ip), NullConvertTo(vbString,actName)
            Else
                Database.DB.VExecute "UPDATE IPACTION SET [BLOCKED]=0, [ATTEMPTS]=0, [LOCKED]=0, [PERFORMED]=OleSysTime() WHERE " & _
                                     "[IP]=$IP AND [ACTION]=$ACTION", 1, 0, NullConvertTo(vbString,ip), NullConvertTo(vbString,actName)
            End If
        End Function
    
        ' Classes used in the configuration - configuration.asp
        Class CCfgCategoryType
            Public fTable, fCategoryType, fPage
            Public fService, fAdmin, fUser, fCaption, fImage, fIsContent
            Sub Class_Initialize
                fAdmin = False
                fUser = False
                fIsContent = True
            End Sub
            Public Function Table(v)
                fTable = v
                Set Table = Me
            End Function
            Public Function CategoryType(v)
                fCategoryType = v
                Set CategoryType = Me
            End Function
            Public Function Page(v)
                fPage = v
                Set Page = Me
            End Function
            Public Function Service(v)
                fService = v
                Set Service = Me
            End Function
            Public Function Admin(v)
                fAdmin = v
                Set Admin = Me
            End Function
            Public Function User(v)
                fUser = v
                Set User = Me
            End Function
            Public Function Caption(v)
                fCaption = v
                Set Caption = Me
            End Function
            Public Function Image(v)
                fImage = v
                Set Image = Me
            End Function
            Public Function IsContent(v)
                fIsContent = v
                Set IsContent = Me
            End Function
            Function Finish
                Set Finish = Me
            End Function
        End Class
        Function CfgCategoryType
            Set CfgCategoryType = New CCfgCategoryType
        End Function
        
        
%>