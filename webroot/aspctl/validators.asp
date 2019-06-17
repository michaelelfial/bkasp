<%

Dim ValidatorErrorImage

' Standard styles for the validators
Const Validator_StandardStyle = "color: #FF0000"

Class CValidator
    Public Group
    Public ValidateControls
    Public Name
    Public ValidatorProcedures
    Public IndicatorProcedures ' Client side procedures
    Public Text
    Public Message
    Public Image
    Public ErrorCssClass ' If non empty it is used instead of the image or the text
    Public ShowAllIndicators
    Public ClientId
    Private Rendered
    Public IsValid
    Public CssClass
    Public Style
    Public SkinId
    Public Hide
    Public EnableClientSide
    Public ShowFailedValidator ' For developers - appneds the name of the failed validator to the Messsage
    
    Public Disabled ' Disables the validator
    
    ' Typical parameters for validators
    Public MinValue
    Public MaxValue
    Public MaxLength
    Public MinLength
    Public RegExpression
    Public Required
    Public AllLanguages ' Some validators need to know if they should validate only for the current language or all the language entries (currently only required)
    Public ValType
    Public Parameters ' Other parameters - see the validator routine for instructions on how to name the parameter for it
    
    Private Sub Class_Initialize
        Set ValidateControls = CreateCollection()
        Set ValidatorProcedures = CreateCollection()
        Set IndicatorProcedures = CreateCollection()
        Set Parameters = CreateCollection()
        IsValid = True
        Text = "*"
        Style = Validator_StandardStyle
        ShowAllIndicators = False
        EnableClientSide = True
    End Sub
    Public Sub Init(n)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Rendered = False
        Disabled = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CValidator"
    End Property
    Public Property Get Protocols
        Protocols = "PClone,PControl"
    End Property
    
    Public Function Clone()
        Dim v
        Set v = Create_CValidator(Empty)
        v.Group = Group
        Set v.ValidateControls = ValidateControls.Clone
        v.Name = Name
        Set v.ValidatorProcedures = ValidatorProcedures.Clone
        v.Text = Text
        v.Message = Message
        v.Image = Image
        v.ClientId = NewClientId()
        v.CssClass = CssClass
        v.Style = Style
        v.SkinId = SkinId
        v.MinValue = MinValue
        v.MaxValue = MaxValue
        v.MaxLength = MaxLength
        v.MinLength = MinLength
        v.RegExpression = RegExpression
        v.Required = Required
        v.ValType = ValType
        v.ErrorCssClass = ErrorCssClass
        v.EnableClientSide = EnableClientSide
        Set v.IndicatorProcedures = IndicatorProcedures.Clone
        Set v.Parameters = Parameters.Clone
        Set Clone = v
    End Function
    
    Public Property Get ControlToValidate
        If ValidateControls.Count > 0 Then
            Set ControlToValidate = ValidateControls(1)    
        Else
            Set ControlToValidate = Nothing
        End If
    End Property
    Public Property Set ControlToValidate(o)
        ValidateControls.Clear
        If Not o Is Nothing Then
            ValidateControls.Add o.Name, o
        End If
    End Property
    Public Property Let ControlToValidate(s)
        ValidateControls.Clear
        If IsObject(Controls(s)) Then
            ValidateControls.Add s, Controls(s)
        End If
    End Property
    
    Public Property Get ControlsToValidate
        Set ControlsToValidate = ValidateControls
    End Property
    Public Sub AddControlToValidate(c)
        If IsObject(c) Then
            ValidateControls.Add c.Name, c
        Else
            ValidateControls.Add c, Controls(c)
        End If
    End Sub
    
    Public Sub AddProcedure(s)
        Dim errNo
        On Error Resume Next
        Err.Clear
        ValidatorProcedures.Add s, GetRef(s)
        errNo = Err.Number
        On Error Goto 0
        If errNo <> 0 Then Err.Raise 1, "CValidator","Validator procedure " & s & " not defined"
        On Error Resume Next
        IndicatorProcedures.Add s, GetRef("Client_" & s)
    End Sub
    Public Sub RemoveProcedure(s)
        ValidatorProcedures.Remove s
        On Error Resume Next
        IndicatorProcedures.Remove s
    End Sub
    Private Sub MarkErrorCssClass
        Dim iCtl, ctl
        If ErrorCssClass <> "" And Not EnableClientSide Then
            For iCtl = 1 To ValidateControls.Count
                Set ctl = ValidateControls(iCtl)
                ctl.CssClass = ErrorCssClass
            Next
        End If
    End Sub
    Public Function PerformValidate
        Dim iCtl, iProc, ctl
        IsValid = True
        PerformValidate = True
        If Disabled Then Exit Function
        For iCtl = 1 To ValidateControls.Count
            Set ctl = ValidateControls(iCtl)
            If Not ctl Is Nothing Then
                ' TRACE - uncomment to trace
                ' Response.Write "Control ... " & ctl.ClassType & "::" & ctl.Name & "<br/>"
                For iProc = 1 to ValidatorProcedures.Count
                    ' TRACE - uncomment to trace
                    ' Response.Write "-->Calling ... " & ValidatorProcedures.Key(iProc) & "<br/>"
                    If Not ValidatorProcedures(iProc)(ctl, Me) Then
                        PerformValidate = False
                        IsValid = False
                        If ShowFailedValidator Then Message = Message & " (" & TR("Failed validation") & ": " & TR(ValidatorProcedures.Key(iProc)) & ")"
                        If ErrorCssClass <> "" Then
                            MarkErrorCssClass
                        End If
                        Exit Function
                    End If
                Next
            End If
        Next
    End Function
    Public Sub RegisterClientSideIndication
        If EnableClientSide And Not Disabled Then
            Dim iCtl, iProc, ctl
            For iCtl = 1 To ValidateControls.Count
                Set ctl = ValidateControls(iCtl)
                If Not ctl Is Nothing Then
                    ' TRACE - uncomment to trace
                    ' Response.Write "Control ... " & ctl.ClassType & "::" & ctl.Name & "<br/>"
                    For iProc = 1 To IndicatorProcedures.Count
                        ' TRACE - uncomment to trace
                        ' Response.Write "-->Calling ... " & ValidatorProcedures.Key(iProc) & "<br/>"
                        Call IndicatorProcedures(iProc)(ctl, Me)
                    Next
                End If
            Next
        End If
    End Sub
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        Dim img
        If Not IsEmpty(Image) Then
            img = Image
        ElseIf Not IsEmpty(ValidatorErrorImage) Then
            img = ValidatorErrorImage
        End If
            
            
        If Not Me.IsValid Then
            s = ""
            If ErrorCssClass = "" Or ShowAllIndicators Then
                If Len(ConvertTo(vbString,img)) > 0 Then
                    s = "<img src=""" & img & """ id=""" & Me.ClientId & """"
                    If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
                    If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
                    If Me.Text <> "" Then s = s & " alt=""" & Server.HTMLEncode(Me.Text) & """"
                    If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
                    s = s & "/>"
                Else
                    s = "<span id=""" & Me.ClientId & """"
                    If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
                    If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
                    If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
                    s = s & ">"
                    If Me.Text <> "" Then s = s & Server.HTMLEncode(Me.Text)
                    s = s & "</span>"    
                End If
            End If
            Response.Write s
        End If
        Rendered = True
    End Sub
End Class

Function Create_CValidator(controlName)
    Dim v
    Set v = New CValidator
    v.Init controlName
    Validators.Add v.Name, v
    Set Create_CValidator = v
End Function
Function Create_UCValidator(forControl, userCtl, skinName) ' For explicit usage in user controls only
    Set Create_UCValidator = Create_UCNamedValidator(Empty, forControl, userCtl, skinName)
End Function
Function Create_UCNamedValidator(vName, forControl, userCtl, skinName) ' For explicit usage in user controls only
    Dim v
    Set v = New CValidator
    v.Init vName
    Validators.Add v.Name, v
    
    If IsObject(forControl) Then
        Set v.ControlToValidate = forControl
    ElseIf IsEmpty(forControl) Then
        ' Do nothing
    Else
        arr = Split(forControl,",")
        If IsArray(arr) Then
            If UBound(arr) >= 0 Then
                For I = LBound(arr) To UBound(arr)
                    If Trim(arr(I)) <> "" Then
                        v.ControlsToValidate.Add Trim(arr(I)), Controls(Trim(arr(I)))
                    End If
                Next
            End If
        End If
    End If
    
    If IsObject(userCtl) Then
        v.Group = userCtl.Name
    Else
        v.Group = ConvertTo(vbString, userCtl)
    End If
    v.SkinId = skinName
    
    Set Create_UCNamedValidator = v
End Function
Function Create_PGValidator(forControl, grpName, skinName) ' For explicit usage in pages outside user controls only
    Dim v
    Set v = New CValidator
    v.Init controlName
    Validators.Add v.Name, v
    
    If IsObject(forControl) Then
        Set v.ControlToValidate = forControl
    ElseIf IsEmpty(forControl) Then
        ' Do nothing
    Else
        arr = Split(forControl,",")
        If IsArray(arr) Then
            If UBound(arr) >= 0 Then
                For I = LBound(arr) To UBound(arr)
                    If Trim(arr(I)) <> "" Then
                        v.ControlsToValidate.Add Trim(arr(I)), Controls(Trim(arr(I)))
                    End If
                Next
            End If
        End If
    End If
    
    If Len(grpName) > 0 Then
        v.Group = grpName
    End If
    v.SkinId = skinName
    
    Set Create_PGValidator = v
End Function

Function Create_CValidatorFor(controlName, forControl, procedures)
    Dim v, arr, I
    Set v = New CValidator
    v.Init controlName
    Validators.Add v.Name, v
    
    If IsObject(forControl) Then
        Set v.ControlToValidate = forControl
    ElseIf IsEmpty(forControl) Then
        ' Do nothing
    Else
        arr = Split(forControl,",")
        If IsArray(arr) Then
            If UBound(arr) >= 0 Then
                For I = LBound(arr) To UBound(arr)
                    If Trim(arr(I)) <> "" Then
                        v.ControlsToValidate.Add Trim(arr(I)), Controls(Trim(arr(I)))
                    End If
                Next
            End If
        End If
    End If
    
    If Not IsEmpty(procedures) Then
        arr = Split(procedures,",")
        If IsArray(arr) Then
            If UBound(arr) >= 0 Then
                For I = LBound(arr) To UBound(arr)
                    If Trim(arr(I)) <> "" Then
                        v.AddProcedure Trim(arr(I))
                    End If
                Next
            End If
        End If
    End If
    
    Set Create_CValidatorFor = v
End Function

Function Create_CValidatorProc(procedures)
    Set Create_CValidatorProc = Create_CValidatorFor(Empty,Empty,procedures)
End Function

' Validator prototype
' ctl - the control to validate
' vld - the validator object itself
' MyValidator(ctl, vld)

' Some standard procedures
Function ValidateRequired(ctl, vld)
    Dim temp, I
    ValidateRequired = True
    If Not vld.Required Then Exit Function
    If IsOneOf("CText,CTextArea,CPass,CHidden,CDateBox,CHtmlBox",ctl.ClassType,",") Then
        If IsEmpty(ctl.Value) Or ConvertTo(vbString,ctl.Value) = "" Then ValidateRequired = False
    ElseIf IsOneOf("CList",ctl.ClassType,",") Then
        If ctl.MultiSelect Then
            If ctl.Selected.Count = 0 Then ValidateRequired = False
        Else
            If Len(ctl.SelectedValue) = 0 Then ValidateRequired = False
        End If
    ElseIf IsOneOf("CRadioList", ctlClassType,",") Then
        If ctl.SelectedIndex <= 0 Then ValidateRequired = False
    ElseIf IsOneOf("CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        If vld.AllLanguages Then
            For I = LBound(SupportedLanguages) To UBound(SupportedLanguages)
                If IsEmpty(ctl.LanguageValue(SupportedLanguages(I))) Or ConvertTo(vbString,ctl.LanguageValue(SupportedLanguages(I))) = "" Then 
                    ValidateRequired = False
                    Exit Function
                End If
            NExt
        Else
            If IsEmpty(ctl.Value) Or ConvertTo(vbString,ctl.Value) = "" Then ValidateRequired = False
        End If
    ElseIf ImplementsProtocol(ctl,"PMultiControl") Then
        If IsEmpty(ctl.Value) Or ConvertTo(vbString,ctl.Value) = "" Then ValidateRequired = False
    Else
        On Error Resume Next
        Err.Clear
            ' Attempt to read a property named Value
            temp = ctl.Value
            If Err.Number <> 0 Then
                On Error Goto 0
                Err.Raise 1,"ValidateRequired","ValidateRequired needs a Value property defined on the object. " & _
                            "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
                Exit Function
            End If
        Err.Clear
        On Error Goto 0
        If IsNull(NullConvertTo(vbString,temp)) Then
            ValidateRequired = False
        End If
    End If
End Function
Sub Client_ValidateRequired(ctl,vld)
    If IsOneOf("CText,CTextArea,CPass,CDateBox,CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateRequired.Value", "" & ConvertTo(vbLong,vld.Required) & ",'" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REQUIRED", "load"
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateRequired.Value", "" & ConvertTo(vbLong,vld.Required) & ",'" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REQUIRED", Empty
        If ASPCTL_AggressiveClientValidation Then
            ClientScripts.RegisterEventHandlerEx ctl, "keyup", "ccStaticValidateRequired.Value", "" & ConvertTo(vbLong,vld.Required) & ",'" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REQUIRED", Empty
        End If
    ElseIf IsOneOf("CList",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateRequired.Select", "" & ConvertTo(vbLong,vld.Required) & ",'" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REQUIRED", "load"
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateRequired.Select", "" & ConvertTo(vbLong,vld.Required) & ",'" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REQUIRED", Empty
    ElseIf IsOneOf("CMultiText,CMultiTextArea",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateRequired.Value", "" & ConvertTo(vbLong,vld.Required) & ",'" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REQUIRED", Empty
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateRequired.Value", "" & ConvertTo(vbLong,vld.Required) & ",'" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REQUIRED", Empty
        If ASPCTL_AggressiveClientValidation Then
            ClientScripts.RegisterEventHandlerEx ctl, "keyup", "ccStaticValidateRequired.Value", "" & ConvertTo(vbLong,vld.Required) & ",'" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REQUIRED", Empty
        End If
    End If
End Sub

Function ValidateRequireSome(ctl, vld)
    ValidateRequireSome = True
    If Not vld.Required Then Exit Function
    If ConvertTo(vbLong,vld.MinValue) < 1 And ConvertTo(vbLong,vld.MaxValue) < 1 Then Exit Function        
    Dim I, v, n
    On Error Resume Next
    Err.Clear
    n = 0
    For I = 1 To vld.ValidateControls.Count
        v = NullConvertTo(vbString,vld.ValidateControls(I).Value)
        If Err.Number <> 0 Then
            Err.Raise 1,"ValidateRequired","ValidateRequired needs a Value property defined on the object. " & _
                            "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
            Exit Function
        End If
        If Not IsNull(v) Then n = n + 1
    Next
    If ConvertTo(vbLong,vld.MinValue) >= 1 Then
        If n < ConvertTo(vbLong,vld.MinValue) Then
            ValidateRequireSome = False
            Exit Function
        End If
    End If
    If ConvertTo(vbLong,vld.MaxValue) >= 1 Then
        If n > ConvertTo(vbLong,vld.MaxValue) Then
            ValidateRequireSome = False
            Exit Function
        End If
    End If
End Function
Sub Client_ValidateRequireSome(ctl,vld)
    
End Sub

Function ValidateRelation(ctl, vld)
    ValidateRelation = True
    Dim I, v, n, J, v2
    On Error Resume Next
    Err.Clear
    n = 0
    For I = 1 To vld.ValidateControls.Count
        v = NullConvertTo(vbDouble,vld.ValidateControls(I).Value)
        If Err.Number <> 0 Then
            On Error Goto 0
            Err.Raise 1,"ValidatRelation","ValidatRelation needs a Value property defined on the object. " & _
                            "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
            Exit Function
        End If
        For J = 1 To vld.Parameters.Count
            If IsObject(vld.Parameters(J)) Then
                Err.Clear
                v2 = NullConvertTo(vbDouble,vld.Parameters(J).Value)
                If Err.Number <> 0 Then
                    On Error Goto 0
                    Err.Raise 1,"ValidatRelation","ValidatRelation needs a Value property defined on the object. " & _
                            "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
                    Exit Function
                End If
                If Not IsNull(v2) Then
                    Select Case UCase(vld.Parameters.Key(J))
                        Case ">"
                            If Not (v > v2) Then ValidateRelation = False
                        Case "<"
                            If Not (v < v2) Then ValidateRelation = False
                        Case ">="
                            If Not (v >= v2) Then ValidateRelation = False
                        Case "<="
                            If Not (v <= v2) Then ValidateRelation = False
                        Case "="
                            If Not (v = v2) Then ValidateRelation = False
                        Case Else
                            Err.Raise 1,"ValidatRelation","Unsupported relation specified. "
                    End Select
                End If
            End If
        Next
    Next
End Function
Sub Client_ValidatRelation(ctl,vld)
    
End Sub

Function ValidateLength_Helper(text,vld)
    ValidateLength_Helper = True
    Dim minLen, maxLen
    minLen = ConvertTo(vbLong,vld.MinLength)
    maxLen = ConvertTo(vbLong,vld.MaxLength)
    If minLen > 0 Then
        If Len(text) < minLen Then
            ValidateLength_Helper = False
            Exit Function
        End If
    End If
    If maxLen > 0 Then
        If Len(text) > maxLen Then
            ValidateLength_Helper = False
            Exit Function
        End If
    End If
End Function
Function ValidateLength(ctl,vld)
    ValidateLength = True
    Dim text, I, coll
    On Error Resume Next
    Err.Clear
    If IsOneOf("CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        Set coll = ctl.Values
        For I = 1 To coll.Count
            text = ConvertTo(vbString,coll(I))
            If text <> "" Then
                If Not ValidateLength_Helper(text,vld) Then
                    ValidateLength = False
                    Exit Function
                End If
            End If
        Next
    Else
        text = ConvertTo(vbString,ctl.Value)
        If Err.Number <> 0 Then 
            On Error Goto 0
            Err.Raise 1,"ValidateLength","ValidateLength needs a Value property defined on the object. " & _
                        "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
        End If
        On Error Goto 0
        If text = "" Then Exit Function
        ValidateLength = ValidateLength_Helper(text,vld)
    End If
End Function
Sub Client_ValidateLength(ctl,vld)
    Dim minLen, maxLen
    minLen = ConvertTo(vbLong,vld.MinLength)
    maxLen = ConvertTo(vbLong,vld.MaxLength)
    If IsOneOf("CText,CTextArea,CPass,CDateBox,CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateLength.Value", "'" & minLen & "','" & maxLen & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_LENGTH", "load"
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateLength.Value", "'" & minLen & "','" & maxLen & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_LENGTH", Empty
        If ASPCTL_AggressiveClientValidation Then
            ClientScripts.RegisterEventHandlerEx ctl, "keyup", "ccStaticValidateLength.Value", "'" & minLen & "','" & maxLen & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_LENGTH", Empty
        End If
    ElseIf IsOneOf("CMultiText,CMultiTextArea",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateLength.Value", "'" & minLen & "','" & maxLen & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_LENGTH", Empty
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateLength.Value", "'" & minLen & "','" & maxLen & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_LENGTH", Empty
        If ASPCTL_AggressiveClientValidation Then
            ClientScripts.RegisterEventHandlerEx ctl, "keyup", "ccStaticValidateLength.Value", "'" & minLen & "','" & maxLen & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_LENGTH", Empty
        End If
    End If
    
End Sub

Function ValidateRange_Helper(v,vld)
    ValidateRange_Helper = True
    If Not IsEmpty(vld.MinValue) And ConvertTo(vbDouble,v) < ConvertTo(vbDouble,vld.MinValue) Then
        ValidateRange_Helper = False
        Exit Function
    End If
    If Not IsEmpty(vld.MaxValue) And ConvertTo(vbDouble,v) > ConvertTo(vbDouble,vld.MaxValue) Then
        ValidateRange_Helper = False
        Exit Function
    End If
End Function
Function ValidateRange(ctl,vld)
    ValidateRange = True
    Dim v, coll, I
    On Error Resume Next
    Err.Clear
    If IsOneOf("CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        Set coll = ctl.Values
        For I = 1 To coll.Count
            v = coll(I)
            If v <> "" Then
                If Not ValidateRange_Helper(v,vld) Then
                    ValidateRange = False
                    Exit Function
                End If
            End If
        Next    
    Else
        v = ctl.Value
        If Err.Number <> 0 Then 
            On Error Goto 0
            Err.Raise 1,"ValidateRange","ValidateRange needs a Value property defined on the object. " & _
                        "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
        End If
        On Error Goto 0
        If v = "" Then Exit Function
        ValidateRange = ValidateRange_Helper(v,vld)
    End If
End Function
Sub Client_ValidateRange(ctl,vld)
    Dim minVal, maxVal
    minVal = ConvertTo(vbString,vld.MinValue)
    maxVal = ConvertTo(vbString,vld.MaxValue)
    If IsOneOf("CText,CTextArea,CPass,CDateBox,CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateRange.Value", "'" & minVal & "','" & maxVal & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_RANGE", "load"
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateRange.Value", "'" & minVal & "','" & maxVal & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_RANGE", Empty
        If ASPCTL_AggressiveClientValidation Then
            ClientScripts.RegisterEventHandlerEx ctl, "keyup", "ccStaticValidateRange.Value", "'" & minVal & "','" & maxVal & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_RANGE", Empty
        End If
    ElseIf IsOneOf("CMutliText,CMultiTextArea",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateRange.Value", "'" & minVal & "','" & maxVal & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_RANGE", Empty
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateRange.Value", "'" & minVal & "','" & maxVal & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_RANGE", Empty
        If ASPCTL_AggressiveClientValidation Then
            ClientScripts.RegisterEventHandlerEx ctl, "keyup", "ccStaticValidateRange.Value", "'" & minVal & "','" & maxVal & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_RANGE", Empty
        End If
    End If
    
End Sub

Function ValidateType(ctl,vld)
    ValidateType = True
    Dim v, c, I, coll
    On Error Resume Next
    Err.Clear
    If IsOneOf("CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        Set coll = ctl.Values
        For I = 1 To coll.Count
            v = coll(I)
            If v <> "" Then
                c = TryConvertTo(vld.ValType,v)
                If IsNull(c) Then 
                    ValidateType = False
                    Exit Function
                End If
            End If
        Next
    Else
        v = ctl.Value
        If Err.Number <> 0 Then 
            On Error Goto 0
            Err.Raise 1,"ValidateType","ValidateType needs a Value property defined on the object. " & _
                        "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
        End If
        On Error Goto 0
        If v = "" Then Exit Function
        On Error Resume Next
        
        c = TryConvertTo(vld.ValType,v)
        If IsNull(c) Then ValidateType = False
    End If
End Function

Function ValidateRegExp(ctl,vld)
    ValidateRegExp = True
    Dim v, re, I, coll
    On Error Resume Next
    Err.Clear
    If IsObject(vld.RegExpression) Then
        Set re = vld.RegExpression
    ElseIf Len(vld.RegExpression) > 0 Then
        Set re = New RegExp
        re.Pattern = vld.RegExpression
        re.IgnoreCase = True
        re.Global = True
    End If
    If Not IsObject(re) Then Exit Function
    If IsOneOf("CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        Set coll = ctl.Values
        For I = 1 To coll.Count
            v = coll(I)
            If v <> "" Then
                If Not re.Test(v) Then 
                    ValidateRegExp = False
                    Exit Function
                End If
            End If
        Next
    Else
        v = ctl.Value
        If Err.Number <> 0 Then 
            On Error Goto 0
            Err.Raise 1,"ValidateType","ValidateType needs a Value property defined on the object. " & _
                        "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
        End If
        On Error Goto 0
        If v = "" Then Exit Function
        If Not re.Test(v) Then ValidateRegExp = False
    End If
End Function
Sub Client_ValidateRegExp(ctl,vld)
    If IsOneOf("CText,CTextArea,CPass,CDateBox,CTextLang,CTextAreaLang",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateRegExp.Value", "'" & JSEscape(vld.RegExpression) & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REGEXP", "load"
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateRegExp.Value", "'" & JSEscape(vld.RegExpression) & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REGEXP", Empty
        If ASPCTL_AggressiveClientValidation Then
            ClientScripts.RegisterEventHandlerEx ctl, "keyup", "ccStaticValidateRegExp.Value", "'" & JSEscape(vld.RegExpression) & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REGEXP", Empty
        End If
    ElseIf IsOneOf("CMultiText,CMultiTextArea",ctl.ClassType,",") Then
        ClientScripts.RegisterEventHandlerEx ctl, "change", "ccStaticValidateRegExp.Value", "'" & JSEscape(vld.RegExpression) & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REGEXP", Empty
        ClientScripts.RegisterEventHandlerEx ctl, "blur", "ccStaticValidateRegExp.Value", "'" & JSEscape(vld.RegExpression) & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REGEXP", Empty
        If ASPCTL_AggressiveClientValidation Then
            ClientScripts.RegisterEventHandlerEx ctl, "keyup", "ccStaticValidateRegExp.Value", "'" & JSEscape(vld.RegExpression) & "','" & vld.ErrorCssClass & "','" & ctl.CssClass & "'", "ASPCTL_VALIDATE_REGEXP", Empty
        End If
    End If
End Sub

Function ValidateUpload(ctl,vld)
    ValidateUpload = True
    Dim ctypes
    If IsOneOf("CFile",ctl.ClassType,",") Then
        If ctl.IsUploaded Then
            If Not IsEmpty(vld.MinLength) Then
                If ctl.ContentLength < vld.MinLength Then
                    vld.Message = TR("File too small") & vld.Message
                    ValidateUpload = False
                    Exit Function
                End If
            End If
            If Not IsEmpty(vld.MaxLength) Then
                If ctl.ContentLength > vld.MaxLength Then
                    vld.Message = TR("File too big") & vld.Message
                    ValidateUpload = False
                    Exit Function
                End If
            End If
            If vld.Parameters.Count > 0 Then
                Set ctypes = vld.Parameters.FindByName("ContentType") ' There are Content-Type restrictions
                If ctypes.Count > 0 Then
                    Set ctypes = vld.Parameters.FindByValue("ContentType",ctl.ContentType,1,1)
                    If ctypes.Count = 0 Then
                        vld.Message = TR("The file is not of an acceptable type") & " (" & ctl.ContentType & "). " & vld.Message
                        ValidateUpload = False
                        Exit Function
                    End If
                End If
                Set ctypes = vld.Parameters.FindByName("FileExtension") ' There are file extension restrictions
                If ctypes.Count > 0 Then
                    Set ctypes = vld.Parameters.FindByValue("FileExtension",ctl.FileNameExtension,1,1)
                    If ctypes.Count = 0 Then
                        vld.Message = TR("The file is not of an acceptable type") & " (." & ctl.FileNameExtension & "). " & vld.Message
                        ValidateUpload = False
                        Exit Function
                    End If
                End If
            End If
        End If
    End If
End Function

Function ValidatePathExists(ctl,vld)
    ValidatePathExists = True
    Dim v
    On Error Resume Next
    Err.Clear
    v = ConvertTo(vbString,ctl.Value)
    If Len(v) = 0 Then 
        ValidatePathExists = False
        Exit Function
    End If
    If Err.Number <> 0 Then 
        On Error Goto 0
        Err.Raise 1,"ValidatePathExists","ValidatePathExists needs a Value property defined on the object. " & _
                    "Please implement that property in " & ctl.ClassType & " and make it return the main/most relevant value for that object"
    End If
    On Error Goto 0
    If v = "" Then Exit Function
    Dim sf
    Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
    If Not sf.Exists(v) Then ValidatePathExists = False
End Function

Function ValidateDateBox(ctl,vld)
    ValidateDateBox = True
    If IsOneOf("CDateBox",ctl.ClassType,",") Then
        Dim v,d
        If ctl.Value = "" Then Exit Function
        v = ctl.DateValue
        If IsNull(v) Then
            ValidateDateBox = False
        Else
            If Not IsEmpty(vld.MinValue) And Not IsNull(vld.MinValue) Then
                d = TryConvertTo(vbDate,vld.MinValue)
                If Not IsNull(d) Then
                    If v < d Then ValidateDateBox = False
                End If
            End If
            If Not IsEmpty(vld.MaxValue) And Not IsNull(vld.MaxValue) Then
                d = TryConvertTo(vbDate,vld.MaxValue)
                If Not IsNull(d) Then
                    If v > d Then ValidateDateBox = False
                End If
            End If
        End If
    End If
End Function

Function ValidateSameInput(ctl,vld)
    ValidateSameInput = True
    
    Dim v, v2, I
    v = ConvertTo(vbString,ctl.Value)
        
    For I = 1 To vld.ValidateControls.Count
        If v <> ConvertTo(vbString,vld.ValidateControls(I).Value) Then
            ValidateSameInput = False
            Exit Function
        End If
    Next
End Function

' Helpers for the most frequently used validators (use a skin to add the other more common traits)
'   Note that these also set maxLength if the control is of the appropriate kind.
Private Sub SetMaxLengthHelper(ctl,ml)
    If Not IsObject(ctl) Then Exit Sub
    If ctl Is Nothing Then Exit Sub
    If IsOneOf("CText,CPass,CDateBox,CMultiText,CTextLang",ctl.ClassType,",") Then
        ctl.MaxLength = ml
    End If
End Sub
Function Create_NumericValidator(forControl,maxLength,isRequired,valType,minVal,maxVal)
    Dim v
    Set v = Create_CValidatorProc("ValidateRequired,ValidateRegExp,ValidateType,ValidateRange")
    v.Required = isRequired
    v.valType = valType
    v.MinValue = minVal
    v.MaxValue = maxVal
    v.RegExpression = "^[\-\+]{0,1}[0-9\.]+$"
    If IsObject(forControl) Then
        SetMaxLengthHelper forControl, maxLength
        Set v.ControlToValidate = forControl
    End If
    Set Create_NumericValidator = v
End Function
Function Create_TextValidator(forControl,maxLength,isRequired,minLen,maxLen,RegExpression)
    Dim v
    Set v = Create_CValidatorProc("ValidateRequired,ValidateLength,ValidateRegExp")
    v.Required = isRequired
    v.MinLength = minLen
    v.MaxLength = maxLen
    v.RegExpression = RegExpression
    If IsObject(forControl) Then
        SetMaxLengthHelper forControl, maxLength
        Set v.ControlToValidate = forControl
    End If
    Set Create_TextValidator = v
End Function
Function Create_RequiredValidator(forControl,maxLength,isRequired)
    Dim v
    Set v = Create_CValidatorProc("ValidateRequired")
    v.Required = isRequired
    If IsObject(forControl) Then
        SetMaxLengthHelper forControl, maxLength
        Set v.ControlToValidate = forControl
    End If
    Set Create_RequiredValidator = v
End Function

%>