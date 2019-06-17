<%

Class CTextLang
    Dim Name ' String
    Public MaxLength ' Int
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Private Rendered
    Public SkinId
    Public Hide
    Public IgnoreUnspportedLanguages
    
    Private pLanguage
    
    Private pValues
    Sub Class_Initialize
        Set pValues = CreateCollection
        pLanguage = PageUILanguage
    End Sub
    
    Sub Init(n)
        MaxLength = 255
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Dim I, s
        For I = LBound(SupportedLanguages) To UBound(SupportedLanguages)
            s = CStr(ASPALL(LangName(SupportedLanguages(I))))
            If Len(s) > 0 Then pValues(SupportedLanguages(I)) = s
        Next
        Rendered = False
    End Sub
    
    Public Property Get Language
        Language = pLanguage
    End Property
    Public Property Let Language(v)
        If Len(v) > 0 Then
            If Not IsLanguageSupported(v) Then 
                Err.Raise 1, "CTextLang", "Unsupported language assigned to the control"
                pLanguage = PageUILanguage
            Else
                pLanguage = v
            End If
        Else
            pLanguage = PageUILanguage
        End If
    End Property
    
    Public Property Get Value
        Value = pValues(Language)
    End Property
    Public Property Let Value(v)
        pValues(Language) = v
    End Property
    Public Property Get LanguageValue(lang)
        LanguageValue = pValues(lang)
    End Property
    Public Property Let LanguageValue(lang,v) ' Defaults to the current Language
        If Len(lang) > 0 Then
            If Not IsLanguageSupported(lang) Then 
                If Not IgnoreUnspportedLanguages Then Err.Raise 1, "CTextLang", "Value for unsupported language assigned to the control"
            Else
                pValues(lang) = v    
            End If
        Else
            pValues(Language) = v
        End If
    End Property
    Public Property Get Values
        Set Values = pValues
    End Property
    
    Public Property Get ClassType
        ClassType = "CTextLang"
    End Property
    Public Property Get Protocols
        Protocols = "PControl,PValues,PLanguageControl"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Private Function LangName(lng)
        LangName = Me.Name & "_" & lng
    End Function
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<input type=""text"" name=""" & LangName(Language) & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Not IsEmpty(Me.MaxLength) Then s = s & " maxlength=""" & Me.MaxLength & """"
        If Me.Value <> "" Then s = s & " value=""" & Server.HTMLEncode(Me.Value) & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & "/>"
        Dim I
        For I = 1 To pValues.Count
            If pValues.Key(I) <> Language And Len(pValues(I)) > 0 Then
                s = s & "<input type=""hidden"" name=""" & LangName(pValues.Key(I)) & """ value=""" & Server.HTMLEncode(pValues(I)) & """ />"
            End If
        Next
        Response.Write s
        Rendered = True
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        Dim I, s
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            s = ""
            For I = 1 To pValues.Count
                If Len(pValues(I)) > 0 Then
                    If Len(s) <> 0 Then s = s & "&"
                    s = s & LangName(pValues.Key(I)) & "=" & pValues(I)
                End If
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

Function Create_CTextLang(controlName)
    Set Create_CTextLang = InitControl(New CTextLang,True,controlName)
End Function


Class CTextAreaLang
    Dim Name ' String
    Public MaxLength ' Int
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Public Cols
    Public Rows
    Private Rendered
    Public SkinId
    Public Hide
    Public IgnoreUnspportedLanguages
    
    Private pLanguage
    
    Private pValues
    Sub Class_Initialize
        Set pValues = CreateCollection
        pLanguage = PageUILanguage
    End Sub
    
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
        Dim I, s
        For I = LBound(SupportedLanguages) To UBound(SupportedLanguages)
            s = CStr(ASPALL(LangName(SupportedLanguages(I))))
            If Len(s) > 0 Then pValues(SupportedLanguages(I)) = s
        Next
        Rendered = False
    End Sub
    
    Public Property Get Language
        Language = pLanguage
    End Property
    Public Property Let Language(v)
        If Len(v) > 0 Then
            If Not IsLanguageSupported(v) Then 
                Err.Raise 1, "CTextLang", "Unsupported language assigned to the control"
                pLanguage = PageUILanguage
            Else
                pLanguage = v
            End If
        Else
            pLanguage = PageUILanguage
        End If
    End Property
    
    Public Property Get Value
        Value = pValues(Language)
    End Property
    Public Property Let Value(v)
        pValues(Language) = v
    End Property
    Public Property Get LanguageValue(lang)
        LanguageValue = pValues(lang)
    End Property
    Public Property Let LanguageValue(lang,v) ' Defaults to the current Language
        If Len(lang) > 0 Then
            If Not IsLanguageSupported(lang) Then 
                If Not IgnoreUnspportedLanguages Then Err.Raise 1, "CTextLang", "Value for unsupported language assigned to the control"
            Else
                pValues(lang) = v    
            End If
        Else
            pValues(Language) = v
        End If
    End Property
    Public Property Get Values
        Set Values = pValues
    End Property
    
    Public Property Get ClassType
        ClassType = "CTextAreaLang"
    End Property
    Public Property Get Protocols
        Protocols = "PControl,PValues,PLanguageControl"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Private Function LangName(lng)
        LangName = Me.Name & "_" & lng
    End Function
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<textarea name=""" & LangName(Language) & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Cols > 0 Then s = s & " cols=""" & Me.Cols & """ "
        If Rows > 0 Then s = s & " rows=""" & Me.Rows & """ "
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & ">"
        If Me.Value <> "" Then s = s & Server.HTMLEncode(Me.Value)
        s = s & "</textarea>"
        Dim I
        For I = 1 To pValues.Count
            If pValues.Key(I) <> Language And Len(pValues(I)) > 0 Then
                s = s & "<input type=""hidden"" name=""" & LangName(pValues.Key(I)) & """ value=""" & Server.HTMLEncode(pValues(I)) & """ />"
            End If
        Next
        Response.Write s
        Rendered = True
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        Dim I, s
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            s = ""
            For I = 1 To pValues.Count
                If Len(pValues(I)) > 0 Then
                    If Len(s) <> 0 Then s = s & "&"
                    s = s & LangName(pValues.Key(I)) & "=" & pValues(I)
                End If
            Next
            HttpGetParams = s
        Else
            HttpGetParams = ""
        End If
    End Property

End Class

Function Create_CTextAreaLang(controlName)
    Set Create_CTextAreaLang = InitControl(New CTextAreaLang,True,controlName)
End Function

%>