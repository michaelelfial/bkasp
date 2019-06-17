<%
    ' These are modifications of some of the basic WEB controls
    ' to behave in multi-instance manner. The prefix used in the class names is Multi
    ' e.g. CMultiText
    
    
Class CMultiText
    Dim Name ' String
    Public pValues ' Variant collection
    Public MaxLength ' Int
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Private Rendered
    Public SkinId
    Public Hide
    Public Instance ' Current instance - affects the Value
    
    Sub Init(n)
        Dim vals, pc, I
        MaxLength = 255
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Set pValues = CreateCollection
        If ASPALL(Me.Name).Count > 0 Then
            pValues.Add "", CStr(ASPALL(Me.Name)) ' Single instance
        ElseIf ASPCTL_UsePostVarsForButtonValues Then
            Set vals = CollectValuesFromRequest(Me.Name,"_V_")
            Set pValues = CreateCollection
            If vals.Count > 0 Then
                Set pc = PostVariables.CtlPostCollection(Me,"V")
                For I = 1 To vals.Count
                    If Not IsEmpty(pc(vals(I))) Then
                        pValues(ConvertTo(vbString,pc(vals(I)))) = CStr(ASPALL(Me.Name & "_V_" & vals(I)))
                    End If
                Next
            End If
        Else
            Set vals = CollectValuesFromRequest(Me.Name,"_V_")
            Set pValues = CreateCollection
            If vals.Count > 0 Then
                For I = 1 To vals.Count
                    pValues(PageDecryptString(vals(I))) = CStr(ASPALL(Me.Name & "_V_" & vals(I)))
                Next
            End If
        End If
        Rendered = False
    End Sub
    
    Public Property Get InstanceValue(inst)
        InstanceValue = pValues(inst)
    End Property
    Public Property Let InstanceValue(inst, v)
        pValues(inst) = v
    End Property
    Public Sub ClearValues
        pValues.Clear
    End Sub
    Public Property Get Value
        Value = pValues(Instance)
    End Property
    Public Property Let Value(v)
        pValues(Instance) = v
    End Property
    Public Property Get Values
        Set Values = pValues
    End Property
    
    Public Property Get ClassType
        ClassType = "CMultiText"
    End Property
    Public Property Get Protocols
        Protocols = "PControl,PMultiControl,PValues"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Function InstanceClientId(v)
        If v <> "" Then
            ValueClientId = ClientId & "_" & PageEncryptString(v)    
        Else
            ValueClientId = ClientId
        End If
    End Function
    
    Public Sub RenderInstance(inst)
        If Hide Then Exit Sub
        Dim s, pc
        If Len(inst) > 0 Then
            If ASPCTL_UsePostVarsForButtonValues Then
                Set pc = PostVariables.CtlPostCollection(Me,"V")
                pc.Add CStr(pc.Count + 1), inst
                s = "<input type=""text"" name=""" & Me.Name & "_V_" & CStr(pc.Count) & """ id=""" & Me.InstanceClientId(v) & """"
            Else
                s = "<input type=""text"" name=""" & Me.Name & "_V_" & PageEncryptString(v) & """ id=""" & Me.InstanceClientId(v) & """"
            End If
        Else
            s = "<input type=""text"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        End If
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Not IsEmpty(Me.MaxLength) Then s = s & " maxlength=""" & Me.MaxLength & """"
        If Me.InstanceValue(inst) <> "" Then s = s & " value=""" & Server.HTMLEncode(Me.InstanceValue(inst)) & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & "/>"
        Response.Write s
        Rendered = True
    End Sub
    Public Sub Render
        RenderInstance Instance
    End Sub
    
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        Dim s, I
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            s = ""
            For I = 1 To pValues.Count
                If Len(s) > 0 Then s = s & "&"
                s = s & Name & "_V_" & pValues.Key(I) & "=" & pValues(I)
            Next
            HttpGetParams = s
        Else
            HttpGetParams = ""
        End If
    End Property
    
    ' PostBack
    Public Property Let AutoPostBack(v)
        PutControlPostBack Me, "change", v
    End Property
    Public Property Set AutoPostBack(o)
        PutControlPostBack Me, "change", o
    End Property
    Public Property Get AutoPostBack
        AutoPostBack = IsControlPostBackEnabled(Me,"change")
    End Property

End Class

Function Create_CMultiText(controlName)
    Set Create_CMultiText = InitControl(New CMultiText,True,controlName)
End Function

Class CMultiTextArea
    Dim Name ' String
    Public pValues ' Variant
    Public MaxLength ' Int
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Public Cols
    Public Rows
    Private Rendered
    Public SkinId
    Public Hide
    Public Instance ' Current instance
    
    Sub Init(n)
        MaxLength = 2048
        Cols = 40
        Rows = 4
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Set pValues = CreateCollection
        If ASPALL(Me.Name).Count > 0 Then
            pValues.Add "", CStr(ASPALL(Me.Name)) ' Single instance
        ElseIf ASPCTL_UsePostVarsForButtonValues Then
            Set vals = CollectValuesFromRequest(Me.Name,"_V_")
            Set pValues = CreateCollection
            If vals.Count > 0 Then
                Set pc = PostVariables.CtlPostCollection(Me,"V")
                For I = 1 To vals.Count
                    If Not IsEmpty(pc(vals(I))) Then
                        pValues(ConvertTo(vbString,pc(vals(I)))) = CStr(ASPALL(Me.Name & "_V_" & vals(I)))
                    End If
                Next
            End If
        Else
            Set vals = CollectValuesFromRequest(Me.Name,"_V_")
            Set pValues = CreateCollection
            If vals.Count > 0 Then
                For I = 1 To vals.Count
                    pValues(PageDecryptString(vals(I))) = CStr(ASPALL(Me.Name & "_V_" & vals(I)))
                Next
            End If
        End If
        Rendered = False
    End Sub
    
    Public Property Get InstanceValue(inst)
        InstanceValue = pValues(inst)
    End Property
    Public Property Let InstanceValue(inst, v)
        pValues(inst) = v
    End Property
    Public Sub ClearValues
        pValues.Clear
    End Sub
    Public Property Get Value
        Value = pValues(Instance)
    End Property
    Public Property Let Value(v)
        pValues(Instance) = v
    End Property
    Public Property Get Values
        Set Values = pValues
    End Property
    
    
    Public Property Get ClassType
        ClassType = "CMultiTextArea"
    End Property
    Public Property Get Protocols
        Protocols = "PControl,PMultiControl,PValues"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Function InstanceClientId(v)
        If v <> "" Then
            ValueClientId = ClientId & "_" & PageEncryptString(v)    
        Else
            ValueClientId = ClientId
        End If
    End Function
    
    Public Sub RenderInstance(inst)
        If Hide Then Exit Sub
        Dim s, pc
        If Len(inst) > 0 Then
            If ASPCTL_UsePostVarsForButtonValues Then
                Set pc = PostVariables.CtlPostCollection(Me,"V")
                pc.Add CStr(pc.Count + 1), inst
                s = "<textarea name=""" & Me.Name & "_V_" & CStr(pc.Count) & """ id=""" & Me.InstanceClientId(v) & """"
            Else
                s = "<textarea name=""" & Me.Name & "_V_" & PageEncryptString(v) & """ id=""" & Me.InstanceClientId(v) & """"
            End If
        Else
            s = "<textarea name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        End If
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Cols > 0 Then s = s & " cols=""" & Me.Cols & """ "
        If Rows > 0 Then s = s & " rows=""" & Me.Rows & """ "
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & ">"
        If Me.InstanceValue(inst) <> "" Then s = s & Server.HTMLEncode(Me.InstanceValue(inst))
        s = s & "</textarea>"
        Response.Write s
        Rendered = True
    End Sub
    
    Public Sub Render
        RenderInstance Instance
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        Dim s, I
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            s = ""
            For I = 1 To pValues.Count
                If Len(s) > 0 Then s = s & "&"
                s = s & Name & "_V_" & pValues.Key(I) & "=" & pValues(I)
            Next
            HttpGetParams = s
        Else
            HttpGetParams = ""
        End If
    End Property

End Class

Function Create_CMultiTextArea(controlName)
    Set Create_CMultiTextArea = InitControl(New CMultiTextArea,True,controlName)
End Function

%>