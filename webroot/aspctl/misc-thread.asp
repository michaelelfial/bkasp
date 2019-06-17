<%
    ' Thread operations
    ' Constants - standard names for thread values
    Const ThreadRunFlag = "Run"
    Const ThreadEventName = "Event"
    
    
    Class CThread
        Public Name ' The thread name in the Application collection
        Public Language
        Public Timeout
        Private errText
        Public CustomVariables
        
        
        Sub Class_Initialize
            Language = "VBScript"
            Timeout = 20000
            Dim o
            Set o = Server.CreateObject("newObjects.utilctls.VarDictionary")
            Set CustomVariables = o.CreateNewDictionary
        End Sub
        
        Private Function CreateNewThread
            Dim o
            Set o = Server.CreateObject("newObjects.utilctls.COMScriptThread.free")
            o.MultiThreaded = True
            o.AddCreator = True
            o.Value.extractValues = False
            Dim I
            For I = 1 To CustomVariables.Count
                o.Value.Add CustomVariables.Key(I), CustomVariables(I)
            Next
            Set CreateNewThread = o
        End Function
        Function Create(bReplace)
            If Name = "" Then Err.Raise 1, "CThread", "Empty thread name"
            If IsObject(Application(Name)) Then
                If bReplace Then 
                    Close
                    Set Application(Name) = CreateNewThread
                End If
            Else
                Set Application(Name) = CreateNewThread
            End If    
            Set Create = Application(Name)
        End Function
        Function ReCreate
            Dim o
            Set o = Create(True)
            ReCreate = True
        End Function
        
        Public Property Get Thread
            If IsObject(Application(Name)) Then
                Set Thread = Application(Name)
            Else
                Set Thread = Create(False)
            End If
        End Property
        
        Public Property Get Loaded
            Loaded = Thread.Active
        End Property
        Public Property Get Busy
            Busy = Thread.Busy
        End Property
        
        
        Public Default Property Get Variables
            Set Variables = Thread.Value
        End Property
        
        
        Sub Close
            Dim thr
            If IsObject(Application(Name)) Then 
                Set thr = Application(Name)
                thr(ThreadRunFlag) = False
                If IsObject(thr(ThreadEventName)) Then
                    thr(ThreadEventName).Set
                End If
                thr.Wait Timeout
                thr.Stop
            End IF
        End Sub
        
        Function StopThread
            On Error Resume Next
            thr(ThreadRunFlag) = False
            If IsObject(thr(ThreadEventName)) Then
                thr(ThreadEventName).Set
            End If
            StopThread = thr.Wait(cShortWait)
        End Function
        
        Function LoadText(txt)
            Dim thr
            Set thr = Thread
            If thr.Start(Language,script,Timeout) Then
                If thr.Wait(Timeout) Then
                    If thr.Success Then
                        LoadText = True
                        Exit Function
                    Else
                        errText = thr.LastError
                        LoadText = False
                        Exit Function
                    End If
                Else
                    errText = "Timeout while waiting the thread to start up."
                    LoadText = False
                    Exit Function
                End If
            Else
                If Not thr.Success Then
                    errText = "Thread load error: " & thr.LastError
                Else
                    ' errText = "Thread load error: " & thr.LastError
                    errText = "Cannot load the thread at this time."
                End If
                LoadText = False
            End If
        End Function
        Function LoadFiles(scriptfiles)
            LoadFiles = False
            Dim script
            script = ""
            Dim SFMain
            Set SFMain = Server.CreateObject("newObjects.utilctls.SFMain")
            Dim file, arrFiles
            arrFiles = Split(scriptfiles,";")
            If Not IsArray(arrFiles) Then
                LoadFiles = False
                Exit Function
            End If
            Dim I
            On Error Resume Next
            For I = LBound(arrFiles) To UBound(arrFiles)
                ' Response.Write "Loading file: " & Server.MapPath(arrFiles(I)) & "<br>"
                Set file = SFMain.OpenFile(MapPath(arrFiles(I)),&H40)
                If Err.Number <> 0 Then
                    errText = Err.Description & " while processing file: " & arrFiles(I)
                    Exit Function
                End If
                If script <> "" Then script = script & vbCrLf
                script = script & file.ReadText(-2)
                If Err.Number <> 0 Then
                    errText = Err.Description & " while processing file: " & arrFiles(I)
                    file.Close
                    Exit Function
                End If
                file.Close
            Next
            On Error Goto 0
            LoadFiles = LoadText(script)
        End Function
        
        Function Execute(sProc)
            If Thread.Active Then
                If Thread.Busy Then
                    errText = "The thread is busy"
                    Execute = False
                Else
                    Execute = Thread.Execute(sProc)
                End If
            Else
                errText = "The thread has not been loaded"
                Execute = False
            End If
        End Function
        
        Public Property Get LastError
            Dim e
            e = thr.LastError
            If e = "" Then
                LastError = errText    
            Else
                LastError = e
            End If
            errText = ""
        End Property
    End Class
    
    Function Create_CThread(Name)
        Dim o
        Set o = New CThread
        o.Name = Name
        Set Create_CThread = o
    End Function
    

%>