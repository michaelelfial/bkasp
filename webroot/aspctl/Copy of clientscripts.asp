<%

Function JSEscape(str)
    Dim s
    s = Replace(str,"\","\\")
    s = Replace(s,"""","\""")
    s = Replace(s,"'","\'")
    JSEscape = s
End Function
' Names of the client variables
Const ASPCTL_AsyncPostBackErrorText = "ASPCTLAsyncPostBackErrorText"
Const ASPCTL_DisableAsyncPostBack = "ASPCTLDisableAsyncPostBack"
Const ASPCTL_DebugAsyncPostBack = "ASPCTLDebugAsyncPostBack"
Const ASPCTL_PageLoadUnloadProcPrefix = "ASPCTLPageProc"

Class CClientScripts
    Private Scripts
    Private ScriptFiles
    Private ScriptProcedures
    Private ScriptProceduresData
    Private Initializers
    Private Uninitializers
    Private pScriptArray
    Private pFormHandlers
    Private pEventHandlers
    Private nGlobalVars
    
    Public  AsyncPostBackErrorText
    
    Sub Class_Initialize()
        Set Scripts = CreateCollection()
        Set ScriptFiles = CreateCollection()
        Set ScriptProcedures = CreateCollection()
        Set ScriptProceduresData = CreateCollection()
        Set Initializers = CreateCollection()
        Set Uninitializers = CreateCollection()
        Set pScriptArray = CreateCollection()
        Set pFormHandlers = CreateCollection()
        Set pEventHandlers = CreateCollection()
        nGlobalVars = 0
    End sub
    
    Sub RegisterFile(sKey,virtPath)
        ScriptFiles.Set sKey, virtPath
    End Sub
    Sub UnRegisterFile(sKey)
        ScriptFiles.Set sKey
    End Sub
    
    Sub RegisterBlock(sKey,sBlock)
        Scripts.Set sKey, sBlock
    End Sub
    Sub UnRegisterBlock(sKey)
        Scripts.Set sKey
    End Sub
    ' Procedure prototype: Sub <proc>(sKey, appData)
    Public Sub RegisterProcedure(sKey, sProc, appData)
        ScriptProcedures.Set sKey, GetRef(sProc)
        ScriptProceduresData.Set sKey, appData
    End Sub
    Public Sub UnRegisterProcedure(sKey)
        ScriptProcedures.Remove sKey
        ScriptProceduresData.Remove sKey
    End Sub
    
    Public Sub RegisterInitializer(sKey, sProc)
        Initializers.Set sKey, sProc
    End Sub
    Public Sub UnRegisterInitializer(sKey)
        Initializers.Remove sKey
    End Sub
    
    Public Sub RegisterUninitializer(sKey, sProc)
        Uninitializers.Set sKey, sProc
    End Sub
    Public Sub UnRegisterUninitializer(sKey)
        Uninitializers.Remove sKey
    End Sub
    
    Public Property Get ScriptArray(sName)
        If Not IsObject(pScriptArray(sName)) Then
            pScriptArray.Set sName, CreateCollection()
        End If
        Set ScriptArray = pScriptArray(sName)
    End Property
    
    Public Function GetGlobalVariableName(ctl,srvName) ' Pass ctl if this would be instance specific variable and pass Empty for static
        If IsNotObject(ctl) Then
            GetGlobalVariableName = "aspctl" & nGlobalVars & srvName
            nGlobalVars = nGlobalVars + 1
        Else
            GetGlobalVariableName = "aspctl_" & ctl.ClientId & srvName
        End If
    End Function
    
    Public Property Get Block(sKey)
        Block = Scripts(sKey)
    End Property
    
    Public Property Let Block(sKey, sBlock)
        Scripts(sKey) = sBlock
    End Property
    
    Public Sub AppendToBlock(sKey,sBlock)
        Dim blk
        blk = Scripts(sKey)
        If blk <> "" Then blk = blk & vbCrLf
        blk = blk & sBlock
        Scripts(sKey) = blk
    End Sub
    
    Public Sub AddFormHandler(fname,fhandler)
        pFormHandlers.Add fname, fhandler
    End Sub
        
    ' JavaScript features based on Static Events micro library 
    Public Sub EnableStaticEventsLibrary
        RegisterFile "ASPCTL_StaticEventsScript", ASPCTLPath & "staticevents.js"
    End Sub
    Public Property Get IsStaticEventsLibraryEnabled
        If ScriptFiles("ASPCTL_StaticEventsScript") <> "" Then
            IsStaticEventsLibraryEnabled = True
        Else
            IsStaticEventsLibraryEnabled = False
        End If
    End Property
    Sub RegisterEventHandlerEx(ctl, evnt, proc, params, cookie, options)
        If IsEmpty(ctl) Or IsNull(ctl) Or ConvertTo(vbString, evnt) = "" Then Exit Sub
        If ctl Is Nothing Then Exit Sub    
        EnableStaticEventsLibrary
        If Not IsObject(pEventHandlers(ctl.Name)) Then
            Set pEventHandlers(ctl.Name) = CreateCollection
        End If
        If Not IsObject(pEventHandlers(ctl.Name)(evnt)) Then
            Set pEventHandlers(ctl.Name)(evnt) = CreateCollection
        End If
        Dim o, arrOpts, I
        Set o = CreateCollection
        o("Params") = params
        o("Proc") = proc
        o("Name") = ctl.Name
        o("Id") = ctl.ClientId
        arrOpts = Split(ConvertTo(vbString,options),";")
        If IsArray(arrOpts) Then
            For I = LBound(arrOpts) To UBound(arrOpts)
                o("Option") = arrOpts(I)
            Next
        End If
        If Len(cookie) > 0 Then
            Set pEventHandlers(ctl.Name)(evnt)(cookie) = o
        Else
            pEventHandlers(ctl.Name)(evnt).Add Empty, o
        End If
    End Sub
    Sub RegisterEventHandler(ctl, evnt, proc, params, cookie)
        RegisterEventHandlerEx ctl, evnt, proc, params, cookie, Empty
    End Sub
    Sub RegisterBodyEventHandler(evnt, proc, params, cookie)
        RegisterEventHandlerEx ASPCTLBodyObject, evnt, proc, params, cookie, Empty
    End Sub
    
    Sub StopPropagation(ctl,evnt)
        RegisterEventHandler ctl, evnt, "StaticStopPropagation", "", "ASPCTL_StopPropagation"
    End Sub
    Sub AllowPropagation(ctl,evnt)
        UnRegisterEventHandler ctl, evnt, "ASPCTL_StopPropagation"
    End Sub
    
    ' Removes: If evnt is empty all event handlers else if cookie is empty all handlers for the event and otherwise only the handler with that cookie
    Sub UnregisterEventHandler(ctl, evnt, cookie)
        Dim h
        Set h = GetControlEventHandlers(ctl, evnt)
        If Not h Is Nothing Then
            If Len(evnt) > 0 Then
                If Len(cookie) > 0 Then
                    h.Remove cookie
                Else
                    h.Clear
                End If
            Else
                h.Clear
            End If
        End If
    End Sub
    Sub UnregisterBodyEventHandler(evnt, cookie)
        UnregisterEventHandler ASPCTLBodyObject, evnt, cookie
    End Sub
    
    Function GetControlEventHandlers(ctl, eventName)
        Dim oCtl, oEvent
        If IsObject(pEventHandlers(ctl.Name)) Then
            Set oCtl = pEventHandlers(ctl.Name)
            If Len(eventName) > 0 Then
                If IsObject(oCtl(eventName)) Then
                    Set oEvent = oCtl(eventName)
                    If oEvent.Count > 0 Then
                        Set GetControlEventHandlers = oEvent
                        Exit Function
                    End If
                End If
            Else
                Set GetControlEventHandlers = oCtl
                Exit Function
            End If
        End If
        Set GetControlEventHandlers = Nothing
    End Function
    Function GetControlEventHandlersCode(ctl,eventName)
        Dim oHandlers, s, I, bEventCreated, h, params
        bEventCreated = False
        Set oHandlers = GetControlEventHandlers(ctl, eventName)
        If oHandlers Is Nothing Then
            GetControlEventHandlersCode = Empty
        Else
            s = ""
            For I = 1 To oHandlers.Count
                Set h = oHandlers(I)
                If Len(h("Params")) > 0 Then 
                    params = "," & h("Params")
                Else
                    params = ""
                End If
                If Not bEventCreated Then
                    s = s & h("Proc") & "(ccStaticEvent.NewEvent(EL('" & ctl.ClientId & "'),(arguments.length>0?arguments[0]:null),'" & eventName & "')" & params & ");"    
                Else
                    s = s & h("Proc") & "(ccStaticEvent.Event" & params & ");"
                End If
            Next
            GetControlEventHandlersCode = s
        End If
    End Function
    Function RenderControlEventHandlersEx(ctl,plusEvent,plusHandler,plusParamsIn) ' For internal use!
        RenderControlEventHandlersEx = ""
        Dim eh, I, J, strexec, e, params, h, bEventCreated, plusParams, bPlusNeedsRendering
        If Len(plusParamsIn) > 0 Then plusParams = "," & plusParamsIn Else plusParams = plusParamsIn
        bPlusNeedsRendering = False
        If Not IsEmpty(plusEvent) Then bPlusNeedsRendering = True
        strexec = ""
        Set eh = GetControlEventHandlers(ctl, Empty)
        If Not eh Is Nothing Then
            For I = 1 To eh.Count
                If eh.Key(I) <> "" And Left(eh.Key(I),1) <> "$" Then
                    If Len(strexec) > 0 Then strexec = strexec & " "
                    strexec = strexec & "on" & eh.Key(I) & "="""
                    Set e = eh(I)
                    bEventCreated = False
                    For J = 1 To e.Count
                        If IsObject(e(J)) Then
                            Set h = e(J)
                            If Len(h("Params")) > 0 Then 
                                params = "," & h("Params")
                            Else
                                params = ""
                            End If
                            If Not bEventCreated Then
                                bEventCreated = True
                                if Not IsEmpty(plusEvent) And eh.Key(I) = plusEvent Then
                                    bPlusNeedsRendering = False
                                    strexec = strexec & plusHandler & "(ccStaticEvent.NewEvent(this,(arguments.length>0?arguments[0]:null),'" & eh.Key(I) & "')" & plusParams & ");"
                                    strexec = strexec & h("Proc") & "(ccStaticEvent.Event" & params & ");"
                                Else
                                    strexec = strexec & h("Proc") & "(ccStaticEvent.NewEvent(this,(arguments.length>0?arguments[0]:null),'" & eh.Key(I) & "')" & params & ");"
                                End If
                            Else
                                strexec = strexec & h("Proc") & "(ccStaticEvent.Event" & params & ");"
                            End If
                        End If
                    Next
                    If bEventCreated Then
                        strexec = strexec & "return ccStaticEvent.EventResult();"
                    End If
                    strexec = strexec & """"
                End If
            Next
        End If
        If bPlusNeedsRendering Then
            strexec = strexec & "on" & plusEvent & "=""" & plusHandler & "(ccStaticEvent.NewEvent(this,(arguments.length>0?arguments[0]:null),'" & plusEvent & "')" & plusParams & ");return ccStaticEvent.EventResult();"""
        End If
        If Len(strexec) > 0 Then strexec = " " & strexec & " "
        RenderControlEventHandlersEx = strexec
    End Function
    Function RenderControlEventHandlers(ctl) ' For public use
        RenderControlEventHandlers = RenderControlEventHandlersEx(ctl,Empty,Empty,Empty)
    End Function
    
    ' Use this for inline rendering of event handlers of sub-elements only
    Function GetSingleEventHandler(funcName,evntName,params)
        GetSingleEventHandler = funcName & "(ccStaticEvent.NewEvent(this,arguments[0],'" & evntName & "')" & IfThenElse(Len(params) > 0,"," & params,"") & ");"
    End Function
    Sub RenderSingleEventHandler(funcName,evntName,params)
        Response.Write "on" & evntName & "=""" & GetSingleEventHandler(funcName,evntName,params) & """"
    End Sub
    
    
    ' Ctl to bind to, ctlFocus set focus there, name of the ctl for post back, ctlVal value
    Sub SetPostBackFocus(ctl, eventName, ctlFocus, ctlName, ctlVal)
        If ConvertTo(vbString,ctlName) <> "" Then
            RegisterEventHandler ctl, eventName, "StaticPostBack", "'" & CurrentFormName & "','" & ctlFocus.ClientId & "','" & ctlName & "','" & ctlVal & "'", "ASPCTL_POSTBACK"
        Else
            RegisterEventHandler ctl, eventName, "StaticPostBack", "'" & CurrentFormName & "','" & ctlFocus.ClientId & "'", "ASPCTL_POSTBACK"
        End If
    End Sub
    Sub SetPostBack(ctl,eventName, ctlName, ctlVal)
        SetPostBackFocus ctl, eventName, ctl, ctlName, ctlVal
    End Sub
    Sub SetAsyncPostBackFocus(ctl, eventName, uCtl, ctlFocus, ctlName, ctlVal)
        If Not ASPCTL_AsyncRequestsEnabled Then
            SetPostBackFocus ctl, eventName, ctlFocus, ctlName, ctlVal
        Else
            If ConvertTo(vbString,ctlName) <> "" Then
                RegisterEventHandler ctl, eventName, "StaticAsyncPostBack", "'" & CurrentFormName & "','" & uCtl.Name & "','" & ctlFocus.ClientId & "','" & ctlName & "','" & ctlVal & "'", "ASPCTL_ASYNCPOSTBACK"
            Else
                RegisterEventHandler ctl, eventName, "StaticAsyncPostBack", "'" & CurrentFormName & "','" & uCtl.Name & "','" & ctlFocus.ClientId & "'", "ASPCTL_ASYNCPOSTBACK"
            End If
        End If
    End Sub
    
    Function RenderAsyncAndControlEventHandlers(ctl,eventName, uCtl, ctlName, ctlVal)
        If ASPCTL_AsyncRequestsEnabled Then
            RenderAsyncAndControlEventHandlers = RenderControlEventHandlersEx(ctl,eventName,"StaticAsyncPostBack","'" & CurrentFormName & "','" & uCtl.Name & "','" & uCtl.ClientId & "','" & ctlName & "','" & ctlVal & "'")
        Else
            RenderAsyncAndControlEventHandlers = RenderControlEventHandlers(ctl)
        End If
    End Function
    Function RenderAsyncAndButtonEventHandlers(ctl,eventName, uCtl, ctlName, ctlVal)
        If ASPCTL_AsyncRequestsEnabled Then
            RenderAsyncAndButtonEventHandlers = RenderControlEventHandlersEx(ctl,eventName,"StaticButtonAsyncPostBack","'" & CurrentFormName & "','" & uCtl.Name & "','" & uCtl.ClientId & "','" & ctlName & "','" & ctlVal & "'")
        Else
            RenderAsyncAndButtonEventHandlers = RenderControlEventHandlers(ctl)
        End If
    End Function
    
    Public Sub EnableAsyncLibrary
        RegisterFile "staticevents-asynch.js", ASPCTLPath & "staticevents-asynch.js"
    End Sub
    Public Property Let EnableAsyncPostBack(v)
        Session("AsyncRequestsEnabled") = v
    End Property
    
    
    ' Standard scripts
    Public Sub EnablePostBack
        CreateStdPostBackProc
    End Sub
    Private Sub CreateStdPostBackProc()
        If Not Scripts.KeyExists("ASPCTL_StandardPostBack") Then
            Dim s
            s =     "function ASPCTL_StandardPostBack(frmName,invId,ctlName,ctlVal) {" & vbCrLf
            s = s & "  var frm = document.forms[frmName];" & vbCrLf
            s = s & "  if (ctlName != null) {" & vbCrLf
            s = s & "    if (frm.action.indexOf('?') < 0) frm.action += '?'; else frm.action += '&';" & vbCrLf
            s = s & "    frm.action += ctlName + '=' + ctlVal;}" & vbCrLf
            s = s & "  if (frm.onsubmit) { if (frm.onsubmit() === false) return; }" & vbCrLf
            s = s & "  if (frm.elements['ASPCTL_PostBackFocus']) frm.elements['ASPCTL_PostBackFocus'].value = invId;" & vbCrLf
            s = s & "  frm.submit();" & vbCrLf
            s = s & "}" & vbCrLf
            Block("ASPCTL_StandardPostBack") = s
        End If
    End Sub
    
    ' Must be called while rendering - the CreateStdPostBackProc must be called before any page rendering occurs (the standard web controls do that automatically when their AutoPostBack is assigned)
    Public Function GetPostBack(ctl,cName,cValue)
        If ConvertTo(vbString,cName) <> "" Then
            GetPostBack = "ASPCTL_StandardPostBack('" & CurrentFormName & "','" & ctl.ClientId & "','" & cName & "','" & cValue & "');"
        Else
            GetPostBack = "ASPCTL_StandardPostBack('" & CurrentFormName & "','" & ctl.ClientId & "');"
        End If
    End Function
    ' Simple asynch postback
    Public Function GetAsyncPostBack(usrControl, focusCtl, cName, cVal) ' focusCtl is currently unused
        GetAsyncPostBack = "StaticAsyncPostBack(ccStaticEvent.NewEvent(this,arguments[0],'click'),'" & _
                            CurrentFormName & "','" & usrControl.ClientId & "','" & focusCtl.ClientId & "','" & cName & "','" & cValue & "');"
    End Function
    
    Private Sub RenderLoadControlHandlers
        Dim lds, I, params, h, c, nCalls
        nCalls = 0
        %>
        <script type="text/javascript">
            function ASPCTL_ControlsOnLoad() {
            <%
            For c = 1 To pEventHandlers.Count
                Set lds = pEventHandlers(c).FindByValue("Option","load", 1, 10000)
                If lds.Count > 0 Then
                     For I = 1 To lds.Count
                        Set h = lds(I)
                        If Len(h("Params")) > 0 Then 
                            params = "," & h("Params")
                        Else
                            params = ""
                        End If
                        If I <= 1 Then
                            Response.Write h("Proc") & "(ccStaticEvent.NewEvent(EL('" & h("Id") & "'),null,'$load')" & params & ");" & vbCrLf
                        Else
                            Response.Write h("Proc") & "(ccStaticEvent.Event" & params & ");" & vbCrLf
                        End If
                        nCalls = nCalls + 1
                    Next 
                End If    
            Next
            %>
            }
        </script>
        <%
        If nCalls > 0 Then
            RegisterInitializer "ASPCTL_ControlEvents", "ASPCTL_ControlsOnLoad()"
        End If
    End Sub
    Private Sub RenderUnLoadControlHandlers
        Dim lds, I, params, h, c, nCalls
        nCalls = 0
        %>
        <script type="text/javascript">
            function ASPCTL_ControlsOnUnLoad() {
            <%
            For c = 1 To pEventHandlers.Count
                Set lds = pEventHandlers(c).FindByValue("Option","unload", 1, 10000)
                If lds.Count > 0 Then
                     For I = 1 To lds.Count
                        Set h = lds(I)
                        If Len(h("Params")) > 0 Then 
                            params = "," & h("Params")
                        Else
                            params = ""
                        End If
                        If I <= 1 Then
                            Response.Write h("Proc") & "(ccStaticEvent.NewEvent(EL('" & h("Id") & "'),null,'$unload')" & params & ");" & vbCrLf
                        Else
                            Response.Write h("Proc") & "(ccStaticEvent.Event" & params & ");" & vbCrLf
                        End If
                        nCalls = nCalls + 1
                    Next 
                End If    
            Next
            %>
            }
        </script>
        <%
        If nCalls > 0 Then
            RegisterUnInitializer "ASPCTL_ControlEvents", "ASPCTL_ControlsOnUnLoad()"
        End If
    End Sub
    Public Sub Render
        Dim itm
        Dim I, J
        Response.Write "<script type=""text/javascript"">" & vbCrLf
        Response.Write "var " & ASPCTL_DisableAsyncPostBack & "=" & IfThenElse(ASPCTL_AsyncRequestsEnabled,"false;","true;") & vbCrLf
        Response.Write "var " & ASPCTL_DebugAsyncPostBack & "=" & IfThenElse(ASPCTL_AsyncRequestsDebug,"true;","false;") & vbCrLf
        
        If Len(AsyncPostBackErrorText) > 0 Then
            Response.Write "var " & ASPCTL_AsyncPostBackErrorText & "=""" & JSEscape(AsyncPostBackErrorText) & """;" & vbCrLf
        End If
        Response.Write "</script>" & vbCrLf
        If ASPCTL_EnableClientValidation Then
            For I = 1 To Validators.Count
                Validators(I).RegisterClientSideIndication
            Next
        End If
        If pScriptArray.Count > 0 Then
            Response.Write "<script type=""text/javascript"">" & vbCrLf
            For I = 1 to pScriptArray.Count
                Response.Write "var " & pScriptArray.Key(I) & " = new Object();" & vbCrLf
                For J = 1 to pScriptArray(I).Count
                    Response.Write pScriptArray.Key(I) & "[""" & pScriptArray(I).Key(J) & """] = """ & JSEscape(pScriptArray(I)(J)) & """;" & vbCrLf
                Next
            Next
            Response.Write "</script>" & vbCrLf
        End If
        For Each itm In ScriptFiles
            Response.Write "<script type=""text/javascript"" src=""" & itm & """></script>" & vbCrLf
        Next
        For Each itm In Scripts
            Response.Write "<script type=""text/javascript"">" & vbCrLf
            Response.Write itm
            Response.Write "</script>" & vbCrLf
        Next
        For I = 1 To ScriptProcedures.Count
            Call ScriptProcedures(I)(ScriptProcedures.Key(I), ScriptProceduresData(ScriptProcedures.Key(I)))
        Next
        RenderLoadControlHandlers
        RenderUnLoadControlHandlers
        ' This must be last! Do not put code after this section
        Response.Write "<script type=""text/javascript"">" & vbCrLf
            If Initializers.Count > 0 Then
                Response.Write "function " & ASPCTL_PageLoadUnloadProcPrefix & "OnLoad() {" & vbCrLf
                    For I = 1 To Initializers.Count
                        Response.Write Initializers(I) & ";" & vbCrLf
                    Next
                Response.Write "}" & vbCrLf
            End If
            If Uninitializers.Count > 0 Then
                Response.Write "function " & ASPCTL_PageLoadUnloadProcPrefix & "OnUnload() {" & vbCrLf
                    For I = 1 To Uninitializers.Count
                        Response.Write Uninitializers(I) & ";" & vbCrLf
                    Next
                Response.Write "}" & vbCrLf
            End If
        Response.Write "</script>" & vbCrLf
    End Sub
    Public Sub RenderPartial
        If ASPCTL_EnableClientValidation Then
            For I = 1 To Validators.Count
                Validators(I).RegisterClientSideIndication
            Next
        End If
    End Sub
    
    Public Sub RenderBodyEvents
        Dim s
        s = ""
        If Initializers.Count > 0 Then s = s & " onload=""" & ASPCTL_PageLoadUnloadProcPrefix & "OnLoad();"""
        If Uninitializers.Count > 0 Then s = s & " onunload=""" & ASPCTL_PageLoadUnloadProcPrefix & "OnUnload();"""
        s = s & RenderControlEventHandlers(ASPCTLBodyObject)
        Response.Write s
    End Sub
    
    ' For internal use mostly
    Public Function RenderFormHandlers(fname)
        Dim fn, I, s, hk
        fn = ConvertTo(vbString,fname)
        s = ""
        For I = 1 To pFormHandlers.Count
            hk = ConvertTo(vbString,pFormHandlers.Key(I))
            If fn = hk Or hk = "" Then
                s = s & pFormHandlers(I) & ";"
            End If
        Next
        RenderFormHandlers = s
    End Function
    
End Class

Dim ClientScripts
Set ClientScripts = New CClientScripts

%>