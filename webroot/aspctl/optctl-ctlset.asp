<%

Class CControlSet

	Private controlSet ' VarDictionary
	Private controlValidators
	Private controlValidator
	Public Name ' String
	Public ClientId
    Private Rendered
    Private RefCreator ' Reference to a creator function of prototype Create_XXXX(controlName)
    Private NthControl ' Teh current number of the control - always incremented

	Private Sub Class_Initialize
		Set controlSet = CreateCollection
		Set controlValidators = CreateCollection
		NthControl = 1
	End Sub
	
	Sub Init(ctlName,RefCreatorProc, numctls)
        If IsEmpty(ctlName) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = ctlName
        End If
        ClientId = NewClientId()
        Rendered = False
        ' Call addControls
        Set RefCreator = GetRef(RefCreatorProc)
        AddControls numctls
    End Sub
    
    Public Property Get ClassType
        ClassType = "CControlSet"
    End Property
    
    Private pAttributes
    Public Property Get Attributes(k)
        If Not IsObject(pAttributes) Then
            Attributes = Empty
            Exit Property
        End If
        Attributes = pAttributes(k)
    End Property
    Public Property Let Attributes(k,v)
        If Not IsObject(pAttributes) Then
            If IsEmpty(v) Or IsNull(v) Then Exit Property
            Set pAttributes = CreateCollection
        End If
        If IsEmpty(v) Or IsNull(v) Then
            If pAttributes.KeyExists(k) Then pAttributes.Remove k
        Else
            pAttributes(k) = v
        End If
        ApplyAttributes
    End Property
    Private Sub ApplyAttributes
        Dim I
        If Not IsObject(pAttributes) Then Exit Sub
        For I = 1 To controlSet.Count
            TransferCollection controlSet(I).Attributes, pAttributes, True
        Next
    End Sub
    
    ' Styling properties
    Private pStyle
    Private Sub ApplyStyle
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).Style = pStyle
        Next
    End Sub
    Public Property Get Style
        Style = pStyle
    End Property
    Public Property Let Style(s)
        pStyle = s
        ApplyStyle
    End Property
    
    Private pCssClass ' CSS Class names
    Private Sub ApplyCssClass
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).CssClass = pCssClass
        Next
    End Sub
    Public Property Get CssClass
        CssClass = pCssClass
    End Property
    Public Property Let CssClass(s)
        pCssClass = s
        ApplyCssClass
    End Property
    
    Private pMaxLength
    Private Sub ApplyMaxLength
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).MaxLength = pMaxLength
        Next
    End Sub
    Public Property Get MaxLength
        MaxLength = pMaxLength
    End Property
    Public Property Let MaxLength(s)
        pMaxLength = s
        ApplyMaxLength
    End Property
    
    Private pSkinId
    Private Sub ApplySkinId
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).SkinId = pSkinId
        Next
    End Sub
    Public Property Get SkinId
        SkinId = pSkinId
    End Property
    Public Property Let SkinId(s)
        pSkinId = s
        ApplySkinId
    End Property
    
    Private pPreserveInQueryString
    Public Property Get PreserveInQueryString
        PreserveInQueryString = pPreserveInQueryString
    End Property
    Public Property Let PreserveInQueryString(b)
        pPreserveInQueryString = b
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).PreserveInQueryString = pPreserveInQueryString
        Next
    End Property
    
    
    ' Returns the number of the controls currently in the control set
    Public Function AddControls(numControls)
        Dim I, ctl, ovalid
        
        For I = 1 To numControls
            Set ctl = RefCreator(Name & "-CTL-" & NthControl)
            controlSet.Add "-CTL-" & NthControl, ctl
            NthControl = NthControl + 1
            ' Set the props
            ctl.Style = Style
            ctl.CssClass = CssClass
            ctl.SkinId = SkinId
            If Not IsEmpty(pMaxLength) Then ctl.MaxLength = pMaxLength
            Controls.Add ctl.Name, ctl
            If IsObject(controlValidator) Then
                Set ovalid = controlValidator.Clone
                Set ovalid.ControlToValidate = ctl
                controlValidators.Add ovalid.Name, ctl
            End If
        Next
        ApplyAttributes
        AddControls = controlSet.Count
    End Function
    Public Function SetControls(numControls)
        Dim I, ctl, ovalid
        ' Remove the existing
        For I = 1 To controlValidators.Count
            If IsObject(controlValidators(I)) Then
                Validators.Remove controlValidators(I).Name
            End If
        Next
        For I = 1 To controlSet.Count
            If IsObject(controlSet(I)) Then
                Controls.Remove controlSet(I).Name
            End If
        Next
        controlValidators.Clear
        controlSet.Clear
        
        NthControl = 1
        
        For I = 1 To numControls
            Set ctl = RefCreator(Name & "-CTL-" & NthControl)
            controlSet.Add "-CTL-" & NthControl, ctl
            NthControl = NthControl + 1
            ' Set the props
            ctl.Style = Style
            ctl.CssClass = CssClass
            ctl.SkinId = SkinId
            If Not IsEmpty(pMaxLength) Then ctl.MaxLength = pMaxLength
            Controls.Add ctl.Name, ctl
            If IsObject(controlValidator) Then
                Set ovalid = controlValidator.Clone
                Set ovalid.ControlToValidate = ctl
                controlValidators.Add ovalid.Name, ctl
            End If
        Next
        ApplyAttributes
        SetControls = controlSet.Count
    End Function
    
    Public Default Property Get Control(n)
        Set Control = controlSet(n)
    End Property
    Public Sub Remove(n)
        conrolSet.Remove n
        If controlValidators.Count >= n Then controlValidators.Remove n
    End Sub
    
    Public Property Set ControlsValidator(v)
        Dim o
        Dim I
        For I = 1 To controlSet.Count
            Set o = v.Clone
            Set o.ControlToValidate = controlSet(I)
            controlValidators.Add o.Name, o
        Next
        ApplyUsedCount
        Set controlValidator = v
    End Property
    Public Property Get Validator(n)
        Set Validator = controlValidators(n)
    End Property
    
    ' Used count
    Private Property Let pUsedCount(v)
        PostVariables.SetCtlVar Me, "U", ConvertTo(vbLong,v)
    End Property
    Public Property Get pUsedCount
        pUsedCount = ConvertTo(vbLong,PostVariables.GetCtlVar(Me,"U"))
    End Property
    
    Private Sub ApplyUsedCount
        Dim I
        For I = 1 To controlSet.Count
            If I <= UsedCount Then
                If IsObject(controlValidators(I)) Then controlValidators(I).Disabled = False
            Else
                If IsObject(controlValidators(I)) Then controlValidators(I).Disabled = True
            End If    
        Next
    End Sub
    Public Property Let UsedCount(ByVal v)
        If v > controlSet.Count Then 
            pUsedCount = controlSet.Count 
        ElseIf v < 0 Then
            pUsedCount = 0
        Else 
            pUsedCount = CLng(v)
        End If
        ApplyUsedCount
    End Property
    Public Property Get UsedCount
        If CLng(pUsedCount) < 0 Or CLng(pUsedCount) > controlSet.Count Then
            UsedCount = controlSet.Count
        Else
            UsedCount = pUsedCount
        End If
    End Property
    
    ' Spcialized methods which will work only on certain kinds of controls and will fail otherwise
    Public Sub UncheckAll
        Dim I
        For I = 1 to controlSet.Count
            controlSet(I).Checked = False
        Next
    End Sub
    
    Public Sub AddItem(key,v)
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).AddItem key, v
        Next
    End Sub
    Public Sub AddItems(itms)
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).AddItems itms
        Next
    End Sub
    Public Sub AddSQLiteItems(results,valField,textField)
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).AddSQLiteItems results, valField, textField
        Next
    End Sub
    Public Property Let Caption(v)
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).Caption = v
        Next
    End Property
    Public Property Let Src(v)
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).Src = v
        Next
    End Property
    Public Property Let NoLabel(v)
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).NoLabel = v
        Next
    End Property
    Public Property Let ConfirmationText(v)
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).ConfirmationText = v
        Next
    End Property
    Public Property Let Hide(v)
        Dim I
        For I = 1 To controlSet.Count
            controlSet(I).Hide = v
        Next
        For I = 1 To controlValidators.Count
            controlValidators(I).Hide = v
        Next
    End Property

End Class

' controlName - String base control name
' RefCreateControlProc - String the name of the procedure to call when a new control needs to be created
' numControls - Long Integer - The number of controls to add initially
Function Create_CControlSet(controlName, RefCreateControlProc, numControls)
    Dim ctl
    Set ctl = New CControlSet
    ctl.Init controlName, RefCreateControlProc, numControls
    Controls.Add ctl.Name, ctl
    Set Create_CControlSet = ctl
End Function

' Predefined functions for some of the most frequently used ones
Function Create_CButtonSet(controlName, numControls)
    Set Create_CButtonSet = Create_CControlSet(controlName, "Create_CButton", numControls)
End Function
Function Create_CTextSet(controlName, numControls)
    Set Create_CTextSet = Create_CControlSet(controlName, "Create_CText", numControls)
End Function
Function Create_CHiddenSet(controlName, numControls)
    Set Create_CHiddenSet = Create_CControlSet(controlName, "Create_CHidden", numControls)
End Function
Function Create_CTextAreaSet(controlName, numControls)
    Set Create_CTextAreaSet = Create_CControlSet(controlName, "Create_CTextArea", numControls)
End Function
Function Create_CImageButtonSet(controlName, numControls)
    Set Create_CImageButtonSet = Create_CControlSet(controlName, "Create_CImageButton", numControls)
End Function
Function Create_CCheckBoxSet(controlName, numControls)
    Set Create_CCheckBoxSet = Create_CControlSet(controlName, "Create_CCheckBox", numControls)
End Function
Function Create_CListSet(controlName, numControls)
    Set Create_CListSet = Create_CControlSet(controlName, "Create_CList", numControls)
End Function





%>