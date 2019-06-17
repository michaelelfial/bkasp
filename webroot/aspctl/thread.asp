<%
    ' Thread operations
    ' Constants - standard names for thread values, the same constants must be used in the thread source file(s)
    Const ThreadEventName = "Event" ' Sychronization event - the thread can wait on it to be signaled to do some work
    Const ThreadExitFlag = "Exit" ' If set the thread must exit gracefuly as soon as it can.
    Const ThreadBasePath = "Path" ' The base path of the application (The physical path)
    
    Class CThread
        Public Name
        Public Language
        Public Timeout
        Public CustomVariables
        Public ForcedClose
        Private errMessage
        
        Sub Class_Initialize
            Timeout = 20000
            Language = "VBScript"
            errMessage = ""
            Dim o
            Set o = Server.CreateObject("newObjects.utilctls.VarDictionary")
            Set CustomVariables = o.CreateNewDictionary
            ForcedClose = False
        End Sub
        
        ' Direct access to the thread
        Public Property Get Thread
            If IsObject(Application(Name)) Then
                Set Thread = Application(Name)
            Else
                Set Thread = Nothing
            End If
        End Property
        ' Closing the thread
        Public Function Close()
            Close = True
            Dim thr
            If IsObject(Application(Name)) Then 
                Set thr = Application(Name)
                If Not thr Is Nothing Then
                    thr.Value(ThreadExitFlag) = True
                    If IsObject(thr.Value(ThreadEventName)) Then
                        thr.Value(ThreadEventName).Pulse
                    End If
                    If thr.Wait(Timeout) Then
                        thr.Stop
                        Set Application(Name) = Nothing
                    Else
                        If ForcedClose Then
                            thr.Stop
                            Set Application(Name) = Nothing
                        Else
                            Close = False
                        End If
                    End If
                End If
            End IF
        End Function
        
        ' Commands
        Public Property Get RequestExit
            Dim thr
            Set thr = Thread
            RequestExit = False
            If Not thr Is Nothing Then
                RequestExit = thr.Value(ThreadExitFlag)
            End If               
        End Property
        Public Property Let RequestExit(v)
            Dim thr
            Set thr = Thread
            If Not thr Is Nothing Then
                thr.Value(ThreadExitFlag) = v
            End If               
        End Property
        
        Public Sub Pulse
            Dim thr
            Set thr = Thread
            If Not thr Is Nothing Then
                thr.Value(ThreadEventName).Pulse
            End If               
        End Sub
        
        Public Function Wait(timeout)
            Dim thr
            Set thr = Thread
            Wait = False
            If Not thr Is Nothing Then
                Wait = thr.Wait(timeout)
            End If               
        End Function
        
        ' State of the thread - it is running only if the script inside is loaded and doing something - otherwise it is completed or the thread has not been started
        Public Property Get IsRunning
            Dim thr
            Set thr = Thread
            If thr Is Nothing Then
                IsRunning = False
            Else
                If thr.Active And thr.Busy Then
                    IsRunning = True
                Else
                    IsRunning = False
                End If
            End If
        End Property
        Public Property Get IsDone
            Dim thr
            Set thr = Thread
            If thr Is Nothing Then
                IsDone = False
            Else
                If thr.Active And Not thr.Busy Then
                    IsDone = True
                Else
                    IsDone = False
                End If
            End If
        End Property
        
        Public Property Get IsSuccessful
            Dim thr
            Set thr = Thread
            If thr Is Nothing Then
                IsSuccessful = False
            Else
                If thr.Active And Not thr.Busy Then
                    IsSuccessful = thr.Success
                    If Not thr.Success Then errMessage = thr.LastError
                ElseIf thr.Active And thr.Busy Then
                    IsSuccessful = False
                    errMessage = "Thread is busy"
                Else ' Not Active
                    IsSuccessful = False
                    errMessage = "Thread was not started (ever)"
                End If
            End If
        End Property
        
        Private Function CreateThread
            If Not Close Then
                errMessage = "Cannot close the thread."
                CreateThread = Nothing
                Exit Function
            End If
            Dim o, ev
            Set o = Server.CreateObject("newObjects.utilctls.COMScriptThread.free")
            o.MultiThreaded = True
            o.AddCreator = True
            o.Value.extractValues = False
            Dim I
            For I = 1 To CustomVariables.Count
                o.Value.Add CustomVariables.Key(I), CustomVariables(I)
            Next
            o.Value(ThreadExitFlag) = False
            Set ev = Server.CreateObject("newObjects.utilctls.Event")
            ev.Create
            o.Value.Set ThreadEventName, ev
            o.Value.Set ThreadBasePath, MapPath(BasePath)
            Set CreateThread = o
        End Function
        
        Function StartText(strScript)
            Dim thr
            Set thr = CreateThread
            If thr Is Nothing Then
                errMessage = "Cannot create the thread."
                StartText = False
                Exit Function
            End If
            
            If thr.Start(Language, strScript) Then
                StartText = True
                Set Application(Name) = thr
            Else
                ' Not started means critical error not related to something the programmer did
                StartText = False
                errMessage = "Cannot start the thread. " & thr.LastError
                Set thr = Nothing
            End IF
        End Function
        Function StartFiles(strFiles)
            StartFiles = False
            Dim script
            script = ""
            Dim SFMain
            Set SFMain = Server.CreateObject("newObjects.utilctls.SFMain")
            Dim file, arrFiles
            arrFiles = Split(strFiles,";")
            If Not IsArray(arrFiles) Then
                errMessage = "File(s) not specified correctly"
                Exit Function
            End If
            Dim I
            On Error Resume Next
            
            For I = LBound(arrFiles) To UBound(arrFiles)
                ' Response.Write "Loading file: " & Server.MapPath(arrFiles(I)) & "<br>"
                Set file = SFMain.OpenFile(MapPath(arrFiles(I)),&H40)
                If Err.Number <> 0 Then
                    errMessage = errMessage & Err.Description & " while processing file: " & arrFiles(I)
                    Exit Function
                End If
                If script <> "" Then script = script & vbCrLf
                script = script & file.ReadText(-2)
                If Err.Number <> 0 Then
                    errMessage = errMessage & Err.Description & " while processing file: " & arrFiles(I)
                    file.Close
                    Exit Function
                End If
                file.Close
            Next
            On Error Goto 0
            If script = "" Then
                errMessage = errMessage & " No script text has been loaded"
                StartFiles = False
            Else
                StartFiles = StartText(script)
            End If
        End Function
        
        Public Property Get LastError
            Dim em
            em = errMessage
            If Not Me.Thread Is Nothing Then em = "" & em & Me.Thread.LastError
            LastError = em
        End Property
        
        Public Property Get Variables
            If Thread Is Nothing Then
                Set Variables = CustomVariables
            Else
                Set Variables = Thread.Value
            End If
        End Property
    End Class
    
    Function Create_CThread(Name)
        Dim o
        Set o = New CThread
        o.Name = Name
        Set Create_CThread = o
    End Function

%>