<%
	' Session stacks - include this file before aspctl.asp if you want to use the page call stacks
	' Note that save/restore is not currently implemented, but the opprotunity must be kept open!
	' Application("ASPCTL_MaxStacks") = 2 ' The max stacks
	' Application("ASPCTL_MaxStackDepth") = 4 ' The max stack size - if greater error occurs
	' Application/Session("ASPCTL_StackExpiredPage") = "/" ' The page to which to redirect in case of a missing stack or incorrect stack state
	'       or PageCallStack.StackExpiredPage
	Const ASPCTL_SessionStacksName = "ASPCTL_SessionStacks"
	Const ASPCTL_StacksParameter = "ASPCTLStack"
	
	' Structure skeleton
	' {: (SessionStacks)
	'   (int)Counter=<dynamic value>
	'   (int)UserId=<userid>
	'   { Stacks: (StacksCollection)
	'       { <stack-name-auto-generated>: (SessionStack)
	'           (double)Created=<datetime-created>
	'           (string)Name=<stack-name-auto-generated>
	'           { Entries: (StackEntries)
	'               ; This is managed as stack of Entry sections
	'               ; An entry is created only when a call is made
	'               { Entry: (StackEntry)
	'                   ; These are filled when a call is initiated
	'                   { Get:
	'                       ; QueryString collection
	'                   } Get;
	'                   { Post:
	'                       ; Post collection
	'                   } Post;
	'                   { Parameters:
	'                       ; In/out parameters for the callee
	'                   } Parameters;
	'                   ; This is cleared immediatelly after the object initializes
	'                   ;   The information is copied to properties which are not preserved during postbacks
	'                   ;   The rest of the page can use them to identify the current status only
	'                   ;   during the processing immediatelly after a call was received or has just returned.
	'                   (string)Verb=<verb: CALL,RETURN>
	'                   ; Other volatile data
	'                   (int)Stage=<-1 - no call (no stack, unexpected state), 0 - caller, 1 - callee>
	'                   (int)Success=<0-cancelled, 1-returned successfully>
	'                   ; Filled when call is started otherwise empty
	'                   (string)CallerMethod=<POST|GET>
	'                   (string)Caller=<the page from which the call originated>
	'                   (string)Callee=<the page being called - this is needed by the helpers>
	'                   (string)CallerControl=<name of the caller control (if any)>
	'                   (string)CalleeControl=<tag for the callee to consider>
	'               } Entry;
	'           } Entries;
	'       } <stack-name-auto-generated>;
	'       ...
	'   } Stacks;
	' };
	' Some comments
	' This format is used in order to allow the stacks to be saved/restored or transferred through the network (TS Section absed persistence)
	' The files are not stored intentionally to avoid putting too much data in the stacks by mistake
	' In theory the return operation can be performed from a page different from the callee (without intermediate call), but this should be avoided.
	' The code should treat the Created value only as means to determine which stack can be sacrificed when there is no enough space for a new one.
	'   It should not be used as an expiration indicator, because this may disrupt the ability to save/restore the user stacks.
	' The Callee control does not need to correspond to a control name, after all the caller has no way to know for sure the name of the control
	'   on the called page that must service the request. However the callee (page) can implement a logic that depends on this value (as a tag/hint) and
	'   dispatch the call where apporpriate - to a specific user control for instance.
	' The CallerMethod saves the RequestMethod when call is performed and restores it on return
	Const CallStatus_NoCall = -1
	Const CallStatus_Caller = 0
	Const CallStatus_Callee = 1
	
	Class CStacks
	    Private Stacks
	    Private StacksSection
	    Private Current
	    Private CurrentEntries
	    
	    Public StackExpiredPage
	    Public Function GetStackExpiredPage
	        If IsEmpty(StackExpiredPage) Then
	            If Not IsEmpty(Session("ASPCTL_StackExpiredPage")) Then
	                GetStackExpiredPage = Session("ASPCTL_StackExpiredPage")
	            ElseIf Not IsEmpty(Application("ASPCTL_StackExpiredPage")) Then
	                GetStackExpiredPage = Application("ASPCTL_StackExpiredPage")
	            Else
	                GetStackExpiredPage = StackExpiredPage
	            End If
	        Else
	            GetStackExpiredPage = StackExpiredPage
	        End If
	    End Function
	
	    ' Always called in pages supporting stacks
        Public Sub Init
            ' Implicit initialization - if there is a stack open it, otherwise do nothing
            Dim sName
            If ConvertTo(vbString,ASPALL(ASPCTL_StacksParameter)) <> "" Then
                sName = ConvertTo(vbString,ASPALL(ASPCTL_StacksParameter))
                PostVariables.Variable(ASPCTL_StacksParameter) = sName
            ElseIf ConvertTo(vbString, PostVariables.Variable(ASPCTL_StacksParameter)) <> "" Then
                sName = ConvertTo(vbString, PostVariables.Variable(ASPCTL_StacksParameter))
            End If
            If sName <> "" Then
                StacksInit
                If IsObject(StacksSection(sName)) Then
                    Set Current = StacksSection(sName)
                    Set CurrentEntries = Current("Entries")
                    ' Check the situation and perform on call/on return steps as necessary
                    PerformInitialProcessing
                End If
            End If
        End Sub
        Private Sub PerformInitialProcessing
            Dim e, verb
            If IsObject(CurrentEntries.Top) Then
                Set e = CurrentEntries.Top
                verb = UCase(ConvertTo(vbString, e("Verb")))
                e.Remove "Verb"
                If verb = "CALL" Then
                    ' Call has been performed
                    Called = True
                    e("Stage") = CLng(CallStatus_Callee)
                    
                ElseIf verb = "RETURN" Then
                    ' Just returned from a call
                    Returned = True
                    e("Stage") = CLng(CallStatus_Caller)
                    ' Now we need to restore the state
                    Set ASPGET = e("Get")
                    Set ASPGET.Missing = ASPCTL_EmptyStringList
                    Set ASPPOST = e("Post")
                    Set ASPPOST.Missing = ASPCTL_EmptyStringList
                    PostVariables.Init ' ReInitalize
                    ' Remove the state to save space
                    e.Remove "Get"
                    e.Remove "Post"
                    Succeeded = ConvertTo(vbBoolean, e("Success"))
                    RequestMethod = ConvertTo(vbString, e("CallerMethod"))
                    If Len(RequestMethod) = 0 Then
                        RequestMethod = "POST" ' Post is default for returned calls
                    End If
                    e("CallerMethod") = ConvertTo(vbString, RequestMethod)
                End If
            End If
        End Sub
        ' Core stacks initialization
        Public Sub StacksInit
            If IsNotObject(Stacks) Then
                If IsNotObject(Session(ASPCTL_SessionStacksName)) Then
                    Set Session(ASPCTL_SessionStacksName) = CreateTSSection("SessionStacks")
                    Set Stacks = Session(ASPCTL_SessionStacksName)
                    Stacks("Counter") = CLng(0)
                    Stacks.Add "Stacks", CreateTSSection("StacksCollection")
                Else
                    Set Stacks = Session(ASPCTL_SessionStacksName)    
                End If
                Set StacksSection = Stacks("Stacks")    
            End If
        End Sub
        
        Property Get MaxStacks
            Dim n
            n = ConvertTo(vbLong, Application("ASPCTL_MaxStacks"))
            If n > 0 Then MaxStacks = n Else MaxStacks = 2
        End Property
        Property Get MaxStackDepth
            Dim n
            n = ConvertTo(vbLong, Application("ASPCTL_MaxStackDepth"))
            If n > 0 Then MaxStackDepth = n Else MaxStackDepth = 4
        End Property
        
        ' INTERNAL MEMBERS
        Private Sub WasteOldestStack
            Dim I, n, d
            On Error Resume Next ' On concurrency issue we just ignore the cleanup
            n = 0
            For I = 1 To StacksSection.Count
                If IsEmpty(d) Then
                    d = StacksSection(I)("Created")
                    n = I
                Else
                    If StacksSection(I)("Created") < d Then 
                        d = StacksSection(I)("Created")
                        n = I
                    End If
                End If
            Next
            If n > 0 Then StacksSection.Remove I
        End Sub
        Private Function NewStackName
            Dim su
            Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
            Stacks("Counter") = Stacks("Counter") + 1
            NewStackName = su.Sprintf("%12.6f%08X",Now, Stacks("Counter"))
        End Function
        Private Function NewStack
            Dim st
            Set st = CreateTSSection("SessionStack")
            If StacksSection.Count >= MaxStacks Then WasteOldestStack
            st("Created") = CDbl(Now)
            st("Name") = NewStackName
            Set st("Entries") = CreateTSSection("StackEntries")
            StacksSection.Add st("Name"), st
            PostVariables.Variable(ASPCTL_StacksParameter) = CStr(st("Name"))
            Set Current = st
            Set CurrentEntries = st("Entries")
            Set NewStack = st
        End Function
        Private Function NewStackEntry
            If CurrentEntries.Count >= MaxStackDepth Then Err.Raise 6, "CStacks", "The maximum allowed stack depth " & MaxStackDepth & " has been reached. To increase it define Application(""ASPCTL_MaxStackDepth"") in global.asa and set the desired max value."
            Dim e
            Set e = CreateTSSection("StackEntry")
            e("Stage") = CLng(CallStatus_Caller)
            e("Success") = CLng(0)
            CurrentEntries.Push e
            Set NewStackEntry = e
        End Function
        
        ' Saves the ASP collections into the current entry
        Private Sub SaveASPVariables
            Dim e, p, r, I, J
            Set e = Top
            Set p = CreateTSSection(Empty)
            For I = 1 To ASPGET.Count
                Set r = CreateTSRecord
                For J = 1 To ASPGET(I).Count
                    r.Add "", ASPGET(I)(J)
                Next
                p.Add ASPGET.Key(I), r
            Next
            Set e("Get") = p
            Set p = CreateTSSection(Empty)
            For I = 1 To ASPPOST.Count
                Set r = CreateTSRecord
                For J = 1 To ASPPOST(I).Count
                    r.Add "", ASPPOST(I)(J)
                Next
                p.Add ASPPOST.Key(I), r
            Next
            Set r = CreateTSRecord
            r.Add "", PostVariables.Serialize ' Replace the post variables with the most recent ones
            Set p(ASPCTL_PostVarsFieldName) = r
            Set e("Post") = p
        End Sub
        
        ' Helper for the routines requiring current stack
        Private Sub EnsureStackExists
            If Top Is Nothing Then
                StacksInit
                If IsNotObject(Current) Then
                    NewStack
                End If
            End If
        End Sub
        
        ' Members which would not create stack implicitly
        
        Function Top
            If IsObject(CurrentEntries) Then
                If CurrentEntries.Count > 0 Then
                    Set Top = CurrentEntries.Top
                Else
                    Set Top = Nothing
                End If
            Else
                Set Top = Nothing
            End If
        End Function
                
        ' The main API
            Public Property Get StackName
                StackName = ""
                If IsObject(Current) Then
                    StackName = Current("Name")
                End If
            End Property
            ' Top most status
            Public Property Get Status
                Dim e
                Set e = Top
                If e Is Nothing Then
                    Status = CallStatus_NoCall
                Else
                    Status = ConvertTo(vbLong, e("Stage"))
                End IF
            End Property
            ' INDICATORS
            Public Returned ' Just returned from a call
            Public Called ' Just entered a called page
            Public Succeeded ' Usable only when Returned is true
            ' This one has effect on the active operation only (top most)
            Public Property Get ControlTag ' Returns the control name or the control tag depending on the stage
                Dim e
                Set e = CurrentEntries.Top
                If Status = CallStatus_Callee Then
                    ControlTag = ConvertTo(vbString, e("CalleeControl"))
                ElseIf Status = CallStatus_Caller Then
                    ControlTag = ConvertTo(vbString, e("CallerControl"))
                Else
                    ControlTag = ""
                End If
            End Property
            ' These two can be called only when the event has just have happened
            ' These can be used to detect call/return in/for a specific cotnrol
            Public Property Get CallReturned(ctl)
                CallReturned = False
                If Returned Then
                    If IsNotObject(ctl) Then
                        If ControlTag = ConvertTo(vbString,ctl) Then CallReturned = True
                    Else
                        If ControlTag = ConvertTo(vbString,ctl.Name) Then CallReturned = True
                    End IF
                End If
            End Property
            Public Property Get CallReceived(ctl)
                CallReceived = False
                If Called Then
                    If IsNotObject(ctl) Then
                        If ControlTag = ConvertTo(vbString,ctl) Then CallReceived = True
                    Else
                        If ControlTag = ConvertTo(vbString,ctl.Name) Then CallReceived = True
                    End If
                End If
            End Property
            
            ' Was this page caller by another
            Public Property Get CanReturn
                If Status = CallStatus_Callee Then
                    CanReturn = True
                ElseIf Status = CallStatus_Caller Then
                    If IsObject(CurrentEntries.Top(2)) Then
                        CanReturn = True ' No need to check its status it can be callee only
                    Else
                        CanReturn = False
                    End If
                Else
                    CanReturn = False ' No stack
                End If
            End Property
            Public Property Get CanCall
                CanCall = True
                If IsObject(CurrentEntries) Then
                    If CurrentEntries.Count >= MaxStackDepth Then CanCall = False
                End If
            End Property
            
            ' Prepares for a call - create an entry if the current is not for a caller
            Public Function PrepareCall
                EnsureStackExists
                If Status = CallStatus_NoCall Or Status = CallStatus_Callee Then
                    ' New entry is needed
                    Set PrepareCall = NewStackEntry
                ElseIf Status = CallStatus_Caller Then
                    ' Already prepared
                    Set PrepareCall = Top
                Else
                    ' Should not happen
                    Err.Raise 1, "CStacks", "Invalid page stack status"
                    Set PrepareCall = Nothing
                End If
            End Function
            Public Sub DropCall
                If Status = CallStatus_Caller Then
                    CurrentEntries.Drop
                End If
            End Sub
            
            ' Access to the three possible sets of parameters 
            ' This page as caller
            Public Property Get CallParameters
                Dim e
                If Status = CallStatus_Caller Then
                    ' Use the current top entry
                    Set e = Top
                    If IsNotObject(e("Parameters")) Then
                        Set e("Parameters") = CreateTSSection(Empty)
                    End IF
                    Set CallParameters = e("Parameters")    
                Else
                    Err.Raise 1, "CStacks", "Not prepared for a call."
                    Set CallParamters = Nothing
                End If
            End Property
            Public Property Get CallParameter(idx)
                CallParameter = CallParameters.Item(idx)
            End Property
            Public Property Let CallParameter(idx,v)
                CallParameters.Item(idx) = v
            End Property
            
            Public Property Get ReturnParameters
                Dim e
                If Status = CallStatus_Callee Then
                    Set e = Top
                    If IsNotObject(e("Parameters")) Then
                        Set e("Parameters") = CreateTSSection(Empty)
                    End IF
                    Set ReturnParameters = e("Parameters")    
                ElseIf Status = CallStatus_Caller Then
                    If CanReturn Then
                        Set e = CurrentEntries.Top(2)
                        If IsNotObject(e("Parameters")) Then
                            Set e("Parameters") = CreateTSSection(Empty)
                        End IF
                        Set ReturnParameters = e("Parameters")    
                    Else
                        Set ReturnParameters = Nothing
                    End If
                Else
                End If
            End Property
            Public Property Get ReturnParameter(idx)
                ReturnParameter = ReturnParameters.Item(idx)
            End Property
            Public Property Let ReturnParameter(idx,v)
                ReturnParameters.Item(idx) = v
            End Property
            ' For external use - returns a collection with the virtual paths of all the pages in the stack
            Public Function StackChain
                Dim I, coll, e, n
                Set coll = CreateCollection
                If IsObject(CurrentEntries) Then
                    For I = 1 To CurrentEntries.Count
                        Set e = CurrentEntries(I)
                        If I < CurrentEntries.Count Then
                            coll.Add "", e("Caller")
                        Else
                            If ConvertTo(vbLong, e("Stage")) = CallStatus_Caller Then
                                coll.Add "", e("Caller")
                            ElseIf ConvertTo(vbLong, e("Stage")) = CallStatus_Callee Then
                                coll.Add "", e("Caller")
                                n = InStr(e("Callee"),"?")
                                If n > 0 Then
                                    coll.Add "", Mid(e("Callee"),1,n-1)
                                Else
                                    coll.Add "", e("Callee")
                                End If
                            End If
                        End If
                    Next
                End If
                Set StackChain = coll
            End Function
            
            ' Mindless redirect to another page - nothing is indicated the target page feels just like the source page
            ' Must be used with care! This function does not change anything in the stack if the target page invokes
            ' return it will happen as if it was initiated by the source page, if call is initiated the call return to the
            ' target page not to the source page.
            ' Nevertheless the source and the target page can communicate parameters providing the correct collection is used
            ' Call/Return parameters as appropriate.
            ' In callers this must be used after PrepareCall, in callees it can be used without further preparations.
            ' If the page plays both caller and callee roles it is up to the developer to determine the correct state in which
            ' the jump should be made.
            Public Function ExecuteJump(toPage)
                Dim toPath
                toPath = toPage
                If InStr(toPath, "?") > 0 Then
                    If Right(toPath,1) <> "?" Then toPath = toPath & "&"
                    toPath = toPath & ASPCTL_StacksParameter & "=" & Current("Name")
                Else
                    toPath = toPath & "?" & ASPCTL_StacksParameter & "=" & Current("Name")
                End If
                CancelProcessing = True
                Response.Redirect toPath
                ExecuteJump = True
            End Function
            Public Function ExecuteCall(toPage, CallerControl, CalleeTag)
                Dim e, toPath
                If Status = CallStatus_Caller Then
                    Set e = CurrentEntries.Top
                    If e("Verb") <> "" Then
                        ExecuteCall = False
                        Exit Function
                    End If
                    e("Verb") = "CALL" ' The stage is on the receiving end
                    e("Success") = CLng(0)
                    e("Caller") = CStr(Self)
                    e("Callee") = CStr(toPage)
                    e("CallerMethod") = CStr(RequestMethod)
                    If IsNotObject(CallerControl) Then
                        e("CallerControl") = ConvertTo(vbString, CallerControl)
                    Else
                        e("CallerControl") = CallerControl.Name
                    End If
                    e("CalleeControl") = ConvertTo(vbString, CalleeTag)
                    toPath = toPage
                    If InStr(toPath, "?") > 0 Then
                        If Right(toPath,1) <> "?" Then toPath = toPath & "&"
                        toPath = toPath & ASPCTL_StacksParameter & "=" & Current("Name")
                    Else
                        toPath = toPath & "?" & ASPCTL_StacksParameter & "=" & Current("Name")
                    End If
                    SaveASPVariables
                    CancelProcessing = True
                    Response.Redirect toPath
                    ExecuteCall = True
                Else
                    ExecuteCall = False ' Inappropriate status
                End If
            End Function
            Public Function ExecuteReturn(bSuccess)
                Dim e, rp
                If CanReturn Then
                    If Status = CallStatus_Caller Then DropCall
                    Set e = CurrentEntries.Top
                    If e("Verb") <> "" Then
                        ExecuteCall = False
                        Exit Function
                    End If
                    e("Verb") = "RETURN" ' The stage is on the receiving end
                    e("Success") = ConvertTo(vbLong, bSuccess)
                    CancelProcessing = True
                    Response.Redirect e("Caller") & "?" & ASPCTL_StacksParameter & "=" & Current("Name")
                Else
                    ExecuteReturn = False
                    rp = GetStackExpiredPage
                    If Len(rp) > 0 Then
                        CancelProcessing = True
                        Response.Redirect rp
                    End If
                End If
            End Function
            Public Function CancelLink(pg)
                If CanReturn Then
                    CancelLink = pg & "?" & ASPCTL_StacksParameter & "=" & Current("Name")
                Else
                    CancelLink = pg
                End If
            End Function
        
	End Class
	
	Set PageCallStack = New CStacks

%>