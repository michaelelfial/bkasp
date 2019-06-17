<%

' IMPL
' ~~~~

Function InitControl(ctl,bReg,controlName)
    ctl.Init controlName
    If bReg Then Controls.Add ctl.Name, ctl
    Set InitControl = ctl
End Function

' Post back implementation helpers - can but should not be called directly
Function IsControlPostBackEnabled(ctl,eventName)
    Dim eh
    IsControlPostBackEnabled = False
    If Not IsObject(ClientScripts) Then Exit Function
    Set eh = ClientScripts.GetControlEventHandlers(ctl,eventName)
    If IsObject(eh) Then
        If IsObject(eh("ASPCTL_POSTBACK")) Then
            IsControlPostBackEnabled = True
        End If
    End If
End Function
Sub PutControlPostBack(ctl, eventName, v)
    If Not IsObject(ClientScripts) Then Exit Sub
    If IsObject(v) Then
        If v Is Nothing Then
            ClientScripts.UnregisterEventHandler ctl, eventName, "ASPCTL_POSTBACK"
        Else
            If ConvertTo(vbString,v.Value) <> "" Then
                ClientScripts.SetPostBackFocus ctl, eventName, ctl, v.Name, ConvertTo(vbString,v.Value)
            Else
                ClientScripts.SetPostBackFocus ctl, eventName, ctl, v.Name, "0"
            End If
        End If
    ElseIf VarType(v) = vbBoolean Then
        If v Then
            ClientScripts.EnableStaticEventsLibrary
            ClientScripts.SetPostBackFocus ctl, eventName, ctl, Empty, Empty
        Else
            ClientScripts.UnregisterEventHandler ctl, eventName, "ASPCTL_POSTBACK"
        End If
    ElseIf IsEmpty(v) Then
        ClientScripts.UnregisterEventHandler ctl, eventName, "ASPCTL_POSTBACK"
    Else
        ClientScripts.SetPostBackFocus ctl, eventName, ctl, ConvertTo(vbString,v), "0"
    End If
End Sub
Function IsAsyncControlPostBackEnabled(ctl,eventName)
    Dim eh
    IsAsyncControlPostBackEnabled = False
    If Not IsObject(ClientScripts) Then Exit Function
    Set eh = ClientScripts.GetControlEventHandlers(ctl,eventName)
    If IsObject(eh) Then
        If IsObject(eh("ASPCTL_ASYNCPOSTBACK")) Then
            IsAsyncControlPostBackEnabled = True
        End If
    End If
End Function
Sub PutAsyncControlPostBack(ctl, eventName, uCtl, v)
    If Not IsObject(ClientScripts) Then Exit Sub
    If IsObject(v) Then
        If v Is Nothing Then
            ClientScripts.UnregisterEventHandler ctl, eventName, "ASPCTL_ASYNCPOSTBACK"
        Else
            If ConvertTo(vbString,v.Value) <> "" Then
                ClientScripts.SetAsyncPostBackFocus ctl, eventName, uCtl, ctl, v.Name, ConvertTo(vbString,v.Value)
            Else
                ClientScripts.SetAsyncPostBackFocus ctl, eventName, uCtl, ctl, v.Name, "0"
            End If
        End If
    ElseIf VarType(v) = vbBoolean Then
        If v Then
            ClientScripts.EnableStaticEventsLibrary
            ClientScripts.SetAsyncPostBackFocus ctl, eventName, uCtl, ctl, Empty, Empty
        Else
            ClientScripts.UnregisterEventHandler ctl, eventName, "ASPCTL_ASYNCPOSTBACK"
        End If
    ElseIf IsEmpty(v) Then
        ClientScripts.UnregisterEventHandler ctl, eventName, "ASPCTL_ASYNCPOSTBACK"
    Else
        ClientScripts.SetPostBackFocus ctl, eventName, uCtl, ctl, ConvertTo(vbString,v), "0"
    End If
End Sub
Const ASPCTL_HideControlEventNames = "click,keypress"
' (control, initiatorElement, commasepEventNames, controlToShowHide) - use with checkboxes and radio buttons only
Sub PutShowHideControlEvents(ctl, eventNames, uCtl)
    If Not IsObject(ClientScripts) Then Exit Sub
    Dim stdEventNames
    Dim arrEvents
    If IsEmpty(eventNames) Then
        arrEvents = Split(ASPCTL_HideControlEventNames,",")
    Else
        arrEvents = Split(eventNames,",")
    End If
    If Not IsArray(arrEvents) Then Exit Sub
    Dim I, s
    For I = LBound(arr) To UBound(arr)
        s = Trim(arr(I))
        If Len(s) > 0 Then
            ClientScripts.RegisterEventHandlerEx ctl, s, "ccStdHideShowControl", "'" & ctl.ClientId & "','" & uCtl.ClientId & "'", "ASPCTL_AutoShowHide", "load"
        End If
    Next
End Sub
Sub PutAsyncButtonPostBack(ctl, eventName, uCtl, v)
    ' Not used for now
End Sub

' Dummy control used to represent as controls some elements - used by ClientScripts
' You can use it for your own purposes as well
Class CDummyControl
    Public Name ' String
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Private Rendered
    Public SkinId
    Public Value ' Variant
    
    Sub Init(n)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CText"
    End Property
    Public Property Get Protocols
        Protocols = "PControl"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & "=" & Me.Value
        Else
            HttpGetParams = ""
        End If
    End Property
    
    Public Sub Render
        ' Nothing
    End Sub
End Class

Function Create_CDummyControl(controlName)
    Set Create_CDummyControl = InitControl(New CDummyControl,True,controlName)
End Function

Class CText
    Dim Name ' String
    Public Value ' Variant
    Public MaxLength ' Int
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Private Rendered
    Public SkinId
    Public Hide
    
    Sub Init(n)
        MaxLength = 255
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Value = CStr(ASPALL(Me.Name))
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CText"
    End Property
    Public Property Get Protocols
        Protocols = "PControl"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<input type=""text"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Not IsEmpty(Me.MaxLength) Then s = s & " maxlength=""" & Me.MaxLength & """"
        If Me.Value <> "" Then s = s & " value=""" & Server.HTMLEncode(Me.Value) & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & "/>"
        Response.Write s
        Rendered = True
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & "=" & Me.Value
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
    
    ' AsyncPostBack
    Public Property Let AsyncPostBack(uCtl,v)
        PutAsyncControlPostBack Me, "change", uCtl, v
    End Property
    Public Property Set AsyncPostBack(uCtl,o)
        PutAsyncControlPostBack Me, "change", uCtl, o
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = IsAsyncControlPostBackEnabled(Me,"change")
    End Property

End Class

Function Create_CText(controlName)
    Set Create_CText = InitControl(New CText,True,controlName)
End Function

Class CFile
    Dim Name ' String
    Private File ' Variant
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Private Rendered
    Public SkinId
    Public Hide
    
    ' Image config
    Public JpegQuality, GifCompression
    
    ' Image info properties - filled only if the Image property is used!
    Public ImageWidth
    Public ImageHeight
    Public ImageBitsPerPixel
    Public ImageXDPI, ImageYDPI
    
    
    
    Sub Class_Initialize
        UseMultipartFormData = True
        JpegQuality = 128
        GifCompression = 0
    End Sub
    
    Sub Init(n)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        If ASPFILES(Me.Name).Count > 0 Then
            Set File = ASPFILES(Me.Name)(1)
        Else
            Set File = Nothing
        End If
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CFile"
    End Property
    Public Property Get Protocols
        Protocols = "PControl"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<input type=""file"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & "/>"
        Response.Write s
        Rendered = True
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        HttpGetParams = ""
    End Property
    Public Property Get IsUploaded
        IsUploaded = False 
        If Not File Is Nothing Then 
            If File.ContentLength > 0 Then IsUploaded = True
        End If
    End Property
    Public Property Get ContentType
        ContentType = ""
        If Not File Is Nothing Then ContentType = File.ContentType
    End Property
    Public Property Let AutoPostBack(v)
        PutControlPostBack Me, "change", v
    End Property
    Public Property Set AutoPostBack(o)
        PutControlPostBack Me, "change", o
    End Property
    Public Property Get AutoPostBack
        AutoPostBack = IsControlPostBackEnabled(Me,"change")
    End Property
    
    Public Property Get DeducedContentType ' Quick helper for images (for now)
        Dim ext
        If FileNameExtension <> "" Then
            ext = LCase(FileNameExtension)
            If IsOneOf("jpg,jpe,jpeg",ext,",") Then
                DeducedContentType = "image/jpeg"
            ElseIf IsOneOf("tif,tiff",ext,",") Then
                DeducedContentType = "image/tiff"
            ElseIf ext = "gif" Then
                DeducedContentType = "image/gif"
            ElseIf ext = "bmp" Then
                DeducedContentType = "image/bmp"
            ElseIf ext = "png" Then
                DeducedContentType = "image/png"
            ElseIf ext = "ico" Then
                DeducedContentType = "image/x-icon"
            ElseIf ext = "wmf" Then
                DeducedContentType = "image/x-wmf"
            ElseIf ext = "wmf" Then
                DeducedContentType = "image/x-wmf"
            Else
                DeducedContentType = ""
            End If
        Else
            DeducedContentType = ""
        End If
    End Property
    Private Function ResizeKeepingAspectRatio(wimg, toWidth, toHeight, bIfBigger)
        Dim w, h
        Dim ih, iw
        Dim dw, dh
        ResizeKeepingAspectRatio = False
        If wimg.ImageCount < 1 Then Exit Function
        iw = ConvertTo(vbLong, toWidth)
        ih = ConvertTo(vbLong, toHeight)
        If iw > 0 And ih > 0 Then
            ' Fit it into that rectangle
            dw = ConvertTo(vbDouble,wimg.Width) / ConvertTo(vbDouble,iw)
            dh = ConvertTo(vbDouble,wimg.Height) / ConvertTo(vbDouble,ih)
            If Not (bIfBigger And dw < 1 And dh < 1) Then
                If dw > dh Then
                    ' By width
                    w = iw
                    h = (iw * wimg.Height) / wimg.Width
                    wimg.TransResizeWidth = w
                    wimg.TransResizeHeight = h
                    wimg.ApplyTransform
                    ResizeKeepingAspectRatio = True
                Else
                    h = ih
                    w = (ih * wimg.Width) / wimg.Height
                    wimg.TransResizeWidth = w
                    wimg.TransResizeHeight = h
                    wimg.ApplyTransform
                    ResizeKeepingAspectRatio = True
                End If
            Else
                ResizeKeepingAspectRatio = True
            End If
        ElseIf iw > 0 Then
            ' By width
            dw = ConvertTo(vbDouble,wimg.Width) / ConvertTo(vbDouble,iw)
            If Not (bIfBigger And dw < 1) Then
                w = iw
                h = (iw * wimg.Height) / wimg.Width
                wimg.TransResizeWidth = w
                wimg.TransResizeHeight = h
                wimg.ApplyTransform
                ResizeKeepingAspectRatio = True
            Else
                ResizeKeepingAspectRatio = True
            End If
        ElseIf ih > 0 Then
            dh = ConvertTo(vbDouble,wimg.Height) / ConvertTo(vbDouble,ih)
            If Not (bIfBigger And dh < 1) Then
                h = ih
                w = (ih * wimg.Width) / wimg.Height
                wimg.TransResizeWidth = w
                wimg.TransResizeHeight = h
                wimg.ApplyTransform
                ResizeKeepingAspectRatio = True
            Else
                ResizeKeepingAspectRatio = True
            End If
        End If
    End Function
    Public Property Get Image(w,h,ct,bKeepSizeIfSmaller)
        If Not IsUploaded Then
            Image = Null
            Exit Property
        End If
        If Stream.Size = 0 Then
            Image = Null
            Exit Property
        End If
        ' Load the image
        Dim wi
        Set wi = Server.CreateObject("newObjects.media.ImgManipulator")
        wi.AddImage Data, DeducedContentType
        If wi.ImageCount = 0 Then
            Image = Null
            Exit Property
        End If
        ' Resize
        
        If Not ResizeKeepingAspectRatio(wi, w, h, bKeepSizeIfSmaller) Then
            Image = Null
            Exit Property
        End If
        
        ImageWidth = wi.Width
        ImageHeight = wi.Height
        
        On Error Resume Next
        Err.Clear
        If LCase(ct) = "image/jpeg" Then
            wi.BitsPerPixel = 24
            wi.JpegQuality = JpegQuality
            wi.ApplyTransform
            Image = wi.GetImage(-1, 3)
        ElseIf LCase(ct) = "image/gif" Then
            wi.BitsPerPixel = 8
            wi.GifCompression = GifCompression
            wi.ApplyTransform
            Image = wi.GetImage(-1, 2)
        ElseIf LCase(ct) = "image/png" Then
            wi.BitsPerPixel = 24
            wi.ApplyTransform
            Image = wi.GetImage(-1, 4)
        Else
            Image = Null
        End If
        ImageBitsPerPixel = wi.BitsPerPixel
        ImageXDPI = wi.XDPI
        ImageYDPI = wi.YDPI
        If Err.Number <> 0 Then
            Image = Null
        End If
    End Property
    Public Property Get RawFileName
        RawFileName = ""
        If Not File Is Nothing Then RawFileName = File.RawFileName
    End Property
    Public Property Get FileName
        FileName = ""
        If Not File Is Nothing Then FileName = File.FileName
    End Property
    Public Property Get FileNameExtension
        FileNameExtension = ""
        If Not File Is Nothing Then FileNameExtension = File.FileNameExtension
    End Property
    Public Property Get ContentLength
        ContentLength = 0
        If Not File Is Nothing Then ContentLength = File.ContentLength
    End Property
    
    Public Property Get Data
        Data = Empty
        If Not File Is Nothing Then Data = File.Data
    End Property
    Public Property Get TextData
        TextData = Empty
        If Not File Is Nothing Then TextData = File.TextData
    End Property
    Public Property Get Stream
        Set Stream = Nothing
        If Not File Is Nothing Then Set Stream = File.Stream
    End Property
    Public Property Get Value
        If IsUploaded Then Value = FileName Else Value = Empty
    End Property

End Class

Function Create_CFile(controlName)
    Set Create_CFile = InitControl(New CFile,True,controlName)
End Function

Class CPass
    Dim Name ' String
    Public Value ' Variant
    Public MaxLength ' Int
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Private Rendered
    Public SkinId
    Public Hide
    
    Sub Init(n)
        MaxLength = 255
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Value = CStr(ASPALL(Me.Name))
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CPass"
    End Property
    Public Property Get Protocols
        Protocols = "PControl"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<input type=""password"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Me.Value <> "" Then s = s & " value=""" & Server.HTMLEncode(Me.Value) & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & "/>"
        Response.Write s
        Rendered = True
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & "=" & Me.Value
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
    
    ' AsyncPostBack
    Public Property Let AsyncPostBack(uCtl,v)
        PutAsyncControlPostBack Me, "change", uCtl, v
    End Property
    Public Property Set AsyncPostBack(uCtl,o)
        PutAsyncControlPostBack Me, "change", uCtl, o
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = IsAsyncControlPostBackEnabled(Me,"change")
    End Property

End Class

Function Create_CPass(controlName)
    Set Create_CPass = InitControl(New CPass,True,controlName)
End Function


Class CTextArea
    Dim Name ' String
    Public Value ' Variant
    Public MaxLength ' Int
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Public Cols
    Public Rows
    Private Rendered
    Public SkinId
    Public Hide
    
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
        Value = CStr(ASPALL(Me.Name))
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CTextArea"
    End Property
    Public Property Get Protocols
        Protocols = "PControl"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<textarea name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Cols > 0 Then s = s & " cols=""" & Me.Cols & """ "
        If Rows > 0 Then s = s & " rows=""" & Me.Rows & """ "
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & ">"
        If Me.Value <> "" Then s = s & Server.HTMLEncode(Me.Value)
        s = s & "</textarea>"
        Response.Write s
        Rendered = True
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & "=" & Me.Value
        Else
            HttpGetParams = ""
        End If
    End Property

End Class

Function Create_CTextArea(controlName)
    Set Create_CTextArea = InitControl(New CTextArea,True,controlName)
End Function


Class CHidden
    Dim Name ' String
    Public Value ' Variant
    Public MaxLength ' Int
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Private Rendered
    Public SkinId
    Public Hide
    
    Sub Init(n)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Value = CStr(ASPALL(Me.Name))
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CHidden"
    End Property
    Public Property Get Protocols
        Protocols = "PControl"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<input type=""hidden"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Me.Value <> "" Then s = s & " value=""" & Server.HTMLEncode(Me.Value) & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & "/>"
        Response.Write s
        Rendered = True
    End Sub
    
    Public Sub RenderLabel
        If Hide Then Exit Sub
        Dim s
        s = "<span id=""" & Me.ClientId & "_Label"""
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & ">"
        If Me.Value <> "" Then s = s & Server.HTMLEncode(Me.Value)
        s = s & "</span>"
        Response.Write s
    End Sub
    
    Public Sub RenderVisible
        Render
        RenderLabel
    End Sub
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & "=" & Me.Value
        Else
            HttpGetParams = ""
        End If
    End Property

End Class

Function Create_CHidden(controlName)
    Set Create_CHidden = InitControl(New CHidden,True,controlName)
End Function

Class CButton
    Dim Name ' String
    Public Value ' Variant
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Public Caption
    Public Clicked
    Private Rendered
    Public SkinId
    Public Hide
    
    Sub Init(n)
        Dim vals, pc
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Clicked = False
        If ASPALL(Me.Name).Count > 0 Then
            Value = CStr(ASPALL(Me.Name))
        ElseIf ASPCTL_UsePostVarsForButtonValues Then
            Set vals = CollectValuesFromRequest(Me.Name,"_V_")
            If vals.Count > 0 Then Value = ConvertTo(vbString,vals(1))
            Set pc = PostVariables.CtlPostCollection(Me,"V")
            If Not IsEmpty(pc(Value)) Then Value = pc(Value)
        Else
            Set vals = CollectValuesFromRequest(Me.Name,"_V_")
            If vals.Count > 0 Then Value = PageDecryptString(vals(1))
        End If
        If Me.Value <> "" Then Clicked = True
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CButton"
    End Property
    Public Property Get Protocols
        Protocols = "PControl,PButton"
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & "=" & Me.Value
        Else
            HttpGetParams = ""
        End If
    End Property
    
    Private pConfirmationText
    Public Property Get ConfirmationText
        ConfirmationText = pConfirmationText
    End Property
    Public Property Let ConfirmationText(v)
        pConfirmationText = ConvertTo(vbString, v)
        If IsObject(ClientScripts) Then
            If pConfirmationText <> "" Then
                ClientScripts.RegisterEventHandler Me, "click", "StaticConfirm", "'" & JSEscape(pConfirmationText) & "'", "ASPCTL_ConfirmationText"
            Else
                ClientScripts.UnregisterEventHandler Me, "click", "ASPCTL_ConfirmationText"
            End If
        End If
    End Property
    
    Public Function GetPostBack(v)
        GetPostBack = ClientScripts.GetPostBack(Me, Me.Name, IfEmpty(v,"0"))
    End Function
    
    Public Function ValueClientId(v)
        If v <> "" Then
            ValueClientId = ClientId & "_" & PageEncryptString(v)    
        Else
            ValueClientId = ClientId
        End If
    End Function
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    ' AsyncPostBack
    Private pAsyncPostBack, pAsyncPostBackUCtl
    Public Property Let AsyncPostBack(uCtl,v)
        Set pAsyncPostBackUCtl = uCtl
        pAsyncPostBack = v
        ' PutAsyncControlPostBack Me, "click", uCtl, v
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = pAsyncPostBack
    End Property
    Private Function RenderEvents(v)
        If IsObject(ClientScripts) Then 
            If pAsyncPostBack Then
                RenderEvents = ClientScripts.RenderAsyncAndButtonEventHandlers(Me,"click", pAsyncPostBackUCtl, Me.Name, v)
            Else
                RenderEvents = ClientScripts.RenderControlEventHandlers(Me)
            End If
        Else
            RenderEvents = ""
        End If
    End Function
    Public Function GetAsyncPostBack(uCtl,v)
        If pAsyncPostBack Then
            GetAsyncPostBack = "StaticAsyncPostBack(ccStaticEvent.NewEvent(this,arguments[0],'asyncpostback'),'" & CurrentFormName & "','" & uCtl.Name & "','" & Me.ClientId & "','" & Me.Name & "','" & IfEmpty(v,"0") & "',null,'" & uCtl.ClientId & "')"
        Else
            GetAsyncPostBack = GetPostBack(v)
        End If
    End Function
    
    Public Sub RenderValue(v)
        If Hide Then Exit Sub
        Dim s, pc
        If v <> "" Then
            If ASPCTL_UsePostVarsForButtonValues Then
                Set pc = PostVariables.CtlPostCollection(Me,"V")
                pc.Add CStr(pc.Count + 1), v
                s = "<input type=""submit"" name=""" & Me.Name & "_V_" & CStr(pc.Count) & """ id=""" & Me.ValueClientId(v) & """"
            Else
                s = "<input type=""submit"" name=""" & Me.Name & "_V_" & PageEncryptString(v) & """ id=""" & Me.ValueClientId(v) & """"
            End If
        Else
            s = "<input type=""submit"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        End If
        If Not IsObject(ClientScripts) Then
            If Me.ConfirmationText <> "" Then s = s & " onclick=""return confirm('" & JSEscape(Me.ConfirmationText) & "')"""
        End If
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Me.Caption <> "" Then s = s & " value=""" & Server.HTMLEncode(Me.Caption) & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & RenderEvents(v)
        s = s & "/>"
        Response.Write s
    End Sub
    
    Public Sub Render
        RenderValue ""
        Rendered = True
    End Sub
    
End Class

Function Create_CButton(controlName)
    Set Create_CButton = InitControl(New CButton,True,controlName)
End Function


Class CImageButton
    Dim Name ' String
    Public X ' Variant
    Public Y ' Variant
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Public Caption
    Public Clicked
    Public Src
    Public NoLabel
    Private Rendered
    Public SkinId
    Public Value
    Public LabelOnLeft
    Public ImageAlign
    Public Hide
    
    Sub Init(n)
        Dim vals,s,pc
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Clicked = False
        Me.X = CStr(ASPALL(Me.Name & ".x"))
        Me.Y = CStr(ASPALL(Me.Name & ".y"))
        If Me.X <> "" Then 
            Clicked = True
            Value = Caption
        ElseIf CStr(ASPALL(Me.Name)) <> "" Then
            Clicked = True
            Value = CStr(ASPALL(Me.Name))
        ElseIf ASPCTL_UsePostVarsForButtonValues Then
            Set vals = CollectValuesFromRequest(Me.Name,"_V_")
            If vals.Count > 0 Then Value = ConvertTo(vbString,vals(1))
            If Value <> "" Then
                Clicked = True
                s = Me.Name & "_V_" & Value
                Me.X = CStr(ASPALL(s & ".x"))
                Me.Y = CStr(ASPALL(s & ".y"))
            End If
            Set pc = PostVariables.CtlPostCollection(Me,"V")
            If Not IsEmpty(pc(Value)) Then Value = pc(Value)
        Else
            Set vals = CollectValuesFromRequest(Me.Name,"_V_")
            If vals.Count > 0 Then Value = PageDecryptString(vals(1))
            If Value <> "" Then
                Clicked = True
                s = Me.Name & "_V_" & PageEncryptString(Value)
                Me.X = CStr(ASPALL(s & ".x"))
                Me.Y = CStr(ASPALL(s & ".y"))
            End If
        End If
        Rendered = False
        LabelOnLeft = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CImageButton"
    End Property
    Public Property Get Protocols
        Protocols = "PControl,PButton"
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & ".x=" & Me.X & "&" & Name & ".y=" & Me.Y
        Else
            HttpGetParams = ""
        End If
    End Property
    
    Private pConfirmationText
    Public Property Get ConfirmationText
        ConfirmationText = pConfirmationText
    End Property
    Public Property Let ConfirmationText(v)
        pConfirmationText = ConvertTo(vbString, v)
        If IsObject(ClientScripts) Then
            If pConfirmationText <> "" Then
                ClientScripts.RegisterEventHandler Me, "click", "StaticConfirm", "'" & JSEscape(pConfirmationText) & "'", "ASPCTL_ConfirmationText"
            Else
                ClientScripts.UnregisterEventHandler Me, "click", "ASPCTL_ConfirmationText"
            End If
        End If
    End Property
    
    Public Function ValueClientId(v)
        If v <> "" Then
            ValueClientId = ClientId & "_" & PageEncryptString(v)    
        Else
            ValueClientId = ClientId
        End If
    End Function
    
    Public Function GetPostBack(v)
        GetPostBack = ClientScripts.GetPostBack(Me, Me.Name, IfEmpty(v,"0"))
    End Function
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    ' AsyncPostBack
    Private pAsyncPostBack, pAsyncPostBackUCtl
    Public Property Let AsyncPostBack(uCtl,v)
        Set pAsyncPostBackUCtl = uCtl
        pAsyncPostBack = v
        ' PutAsyncControlPostBack Me, "click", uCtl, v
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = pAsyncPostBack
    End Property
    Private Function RenderEvents(v)
        If IsObject(ClientScripts) Then 
            If pAsyncPostBack Then
                RenderEvents = ClientScripts.RenderAsyncAndButtonEventHandlers(Me,"click", pAsyncPostBackUCtl, Me.Name, IfEmpty(v,"0"))
            Else
                RenderEvents = ClientScripts.RenderControlEventHandlers(Me)
            End If
        Else
            RenderEvents = ""
        End If
    End Function
    ' Post on behalf this button
    Public Function GetAsyncPostBack(uCtl,v)
        If pAsyncPostBack Then
            GetAsyncPostBack = "StaticAsyncPostBack(ccStaticEvent.NewEvent(this,arguments[0],'asyncpostback'),'" & CurrentFormName & "','" & uCtl.Name & "','" & Me.ClientId & "','" & Me.Name & "','" & IfEmpty(v,"0") & "',null,'" & uCtl.ClientId & "')"
        Else
            GetAsyncPostBack = GetPostBack(v)
        End If
    End Function
    
    Public Function RenderLabel(v)
        Dim s
        s = ""
        If Me.Caption <> "" Then 
            s = s & " <label"
            If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
            s = s & " style=""cursor: pointer;"
            If Not IsEmpty(Me.Style) Then s = s & " " & Me.Style
            s = s & """"
            s = s & " for=""" & Me.ValueClientId(v) & """>" & Server.HTMLEncode(Me.Caption) & "</label> "
        End If
        RenderLabel = s
    End Function
    
    Public Sub RenderValue(v)
        If Hide Then Exit Sub
        Dim s, pc
        s = ""
        If LabelOnLeft And Not Me.NoLabel Then s = s & RenderLabel(v)
        If v <> "" Then
            If ASPCTL_UsePostVarsForButtonValues Then
                Set pc = PostVariables.CtlPostCollection(Me,"V")
                pc.Add CStr(pc.Count + 1), v
                s = s & "<input type=""image"" name=""" & Me.Name & "_V_" & CStr(pc.Count) & """ id=""" & Me.ValueClientId(v) & """"
            Else
                s = s & "<input type=""image"" name=""" & Me.Name & "_V_" & PageEncryptString(v) & """ id=""" & Me.ValueClientId(v) & """"
            End If
        Else
            s = s & "<input type=""image"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        End If
        If Me.Caption <> "" Then s = s & " title=""" & Server.HTMLEncode(Me.Caption) & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Not IsObject(ClientScripts) Then
            If Me.ConfirmationText <> "" Then s = s & " onclick=""return confirm('" & JSEscape(Me.ConfirmationText) & "')"""
        End If
        If Me.Caption <> "" Then s = s & " alt=""" & Server.HTMLEncode(Me.Caption) & """"
        s = s & " src=""" & Me.Src & """"
        If Not IsEmpty(ImageAlign) Then s = s & " align=""" & ImageAlign & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & RenderEvents(v)
        s = s & "/>"
        If Not LabelOnLeft And Not Me.NoLabel Then s = s & RenderLabel(v)
        Response.Write s
        Rendered = True
    End Sub
    Public Sub Render
        RenderValue(Empty)
    End Sub
    
End Class

Function Create_CImageButton(controlName)
    Set Create_CImageButton = InitControl(New CImageButton,True,controlName)
End Function

Class CCheckBox
    Dim Name ' String
    Public Value ' Variant
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Public Caption
    Public Checked
    Private Rendered
    Public SkinId
    Public Hide
    Public NoLabel
    
    Sub Init(n)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Checked = False
        Me.Value = CStr(ASPALL(Me.Name))
        If Me.Value <> "" Then Checked = True
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CCheckBox"
    End Property
    Public Property Get Protocols
        Protocols = "PControl,PChecked"
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        HttpGetParams = ""
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            If Checked Then HttpGetParams = Name & "=" & Me.Value
        End If
    End Property
    
    ' PostBack
    Public Property Let AutoPostBack(v)
        PutControlPostBack Me, "click", v
    End Property
    Public Property Set AutoPostBack(o)
        PutControlPostBack Me, "click", o
    End Property
    Public Property Get AutoPostBack
        AutoPostBack = IsControlPostBackEnabled(Me,"click")
    End Property
    
    ' AsyncPostBack
    Public Property Let AsyncPostBack(uCtl,v)
        PutAsyncControlPostBack Me, "click", uCtl, v
    End Property
    Public Property Set AsyncPostBack(uCtl,o)
        PutAsyncControlPostBack Me, "click", uCtl, o
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = IsAsyncControlPostBackEnabled(Me,"click")
    End Property
    
    Public Property Set ShowHideControl(v)
        PutShowHideControlEvents Me, Empty, v
    End Property

    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub RenderLabel
        Dim s
        s = ""
        If Hide Then Exit Sub
        If Not IsEmpty(Me.Caption) Then 
            s = s & " <label"
            If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
            s = s & " style=""cursor: pointer;"
            If Not IsEmpty(Me.Style) Then s = s & " " & Me.Style
            s = s & """"
            s = s & " for=""" & Me.ClientId & """>" & Server.HTMLEncode(Me.Caption) & "</label>"
        End If
        Response.Write s
    End Sub
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<input type=""checkbox"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Me.Value <> "" Then s = s & " value=""" & Me.Value & """" Else s = s & " value=""on"""
        If Me.Checked Then
            s = s & " checked"
        End If
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & "/>"
        Response.Write s
        If Not NoLabel Then RenderLabel
        Rendered = True
    End Sub
End Class

Function Create_CCheckBox(controlName)
    Set Create_CCheckBox = InitControl(New CCheckBox,True,controlName)
End Function


Class CList
    Dim Name ' String
    Public Items ' Collection
    Public Selected ' Selected values
    Public MultiSelect
    Public NoChecks ' The selected values are not checked against existing items
    
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Public Caption
    Public Size
    Private Rendered
    Public SkinId
    Public Hide
    
    Sub Class_Initialize
        Set Items = CreateCollection()
        Set Selected = CreateCollection()
        Size = 1
        MultiSelect = False
        pAutoPostBackEnabled = False
    End Sub
    Sub Init(n)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Dim I
        For I = 1 To ASPALL(Me.Name).Count
            Selected.Add Empty, ASPALL(Me.Name)(I)
        Next
        
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CList"
    End Property
    Public Property Get Protocols
        Protocols = "PControl"
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            Dim s, I
            s = ""
            For I = 1 To Selected.Count
                s = s & Name & "=" & Selected(I)
                If I < Selected.Count Then s = s & "&"
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
    
    ' AsyncPostBack
    Public Property Let AsyncPostBack(uCtl,v)
        PutAsyncControlPostBack Me, "change", uCtl, v
    End Property
    Public Property Set AsyncPostBack(uCtl,o)
        PutAsyncControlPostBack Me, "change", uCtl, o
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = IsAsyncControlPostBackEnabled(Me,"change")
    End Property
    
    
    Public Sub AddItem(key,v)
        Items.Add ConvertTo(vbString,key), ConvertTo(vbString,v)
    End Sub
    Public Sub AddItems(itms)
        Dim I
        For I = 1 To itms.Count
            Items.Add itms.Key(I), itms(I)
        Next    
    End Sub
    Public Sub AddSQLiteItems(results,valField,textField)
        Dim I
        For I = 1 To results.Count
            Items.Add results(I)(valField), results(I)(textField)
        Next    
    End Sub
    Public Sub NormalizeSelection ' Removes selected values non-existent in the items collection
        Dim I, sval
        For I = Selected.Count To 1 Step -1
            sval = UCase(CStr(Selected(1)))
            If Not Items.KeyExists(sval) Then
                Selected.Remove I
            End If
        Next
    End Sub
    
    Public Property Get SelectedIndex
        If Selected.Count < 1 Then
            SelectedIndex = 0
            Exit Property
        Else
            Dim I, sval
            sval = UCase(CStr(Selected(1)))
            For I = 1 To Items.Count
                If UCase(Items.Key(I)) = sval Then
                    SelectedIndex = I
                    Exit Property
                End If
            Next
        End If
        SelectedIndex = 0
    End Property
    Public Property Let SelectedIndex(idx)
        Selected.Clear
        If idx < 1 Or idx > Items.Count Then
            Exit Property
        End If
        Selected.Add Empty, Items.Key(idx)
    End Property
    
    
    Public Property Get SelectedValue
        SelectedValue = Empty
        If Selected.Count > 0 Then SelectedValue = Selected(1)
    End Property
    Public Property Let SelectedValue(v)
        Selected.Clear
        If v <> "" And (Me.NoChecks Or Items.KeyExists(ConvertTo(vbString,v))) Then
            Selected.Add Empty, ConVertTo(vbString,v)
        End If
        sVal = UCase(v)
    End Property
    Public Property Get Value
        Value = SelectedValue
    End Property
    Public Property Let Value(v)
        SelectedValue = v
    End Property
    
    Public Function SelectItem(itemValue, bSelect)
        Dim I
        For I = 1 to Selected.Count
            If Selected(I) = ConvertTo(vbString,itemValue) Then Selected.Remove I
        Next
        If bSelect Then
            For I = 1 to Items.Count
                If Items.Key(I) = ConvertTo(vbString,itemValue) Then Selected.Add Empty, Items.Key(I)
            Next
        End If
    End Function
    Public Function IsSelected(itemValue)
        Dim I
        IsSelected = False
        For I = 1 to Selected.Count
            If Selected(I) = ConvertTo(vbString,itemValue) Then 
                IsSelected = True
                Exit Function
            End If
        Next
    End Function
    
    Private Function SelectedAtIndex(ind)
        Dim I
        For I = 1 To Selected.Count
            If Items.Key(ind) = Selected(I) Then 
                SelectedAtIndex = " selected"
                Exit Function
            End If
        Next
        SelectedAtIndex = ""
    End Function
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        s = "<select name=""" & Me.Name & """ id=""" & Me.ClientId & """ size=""" & Me.Size & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If MultiSelect Then s = s & " multiple"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        s = s & ">"
        Response.Write s & vbCrLf
        
        ' The items
        Dim I
        For I = 1 To Items.Count
            Response.Write "<option value=""" & Server.HTMLEncode(Items.Key(I)) & """" & SelectedAtIndex(I) & ">" & _
                            Server.HTMLEncode(ConvertTo(vbString,Items(I))) & "</option>" & vbCrLf
        Next
        
        s = "</select>"
        If Not IsEmpty(Me.Caption) Then 
            s = s & "<label for=""" & Me.ClientId & """"
            If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
            If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
            s = s & ">" & Server.HTMLEncode(Me.Caption) & "</label>"
        End If
        Response.Write s & vbCrLf
        Rendered = True
    End Sub
End Class

Function Create_CList(controlName)
    Set Create_CList = InitControl(New CList,True,controlName)
End Function
Function Create_CListMulti(controlName)
    Dim ctl
    Set ctl = InitControl(New CList,True,controlName)
    ctl.MultiSelect = True
    Set Create_CListMulti = ctl
End Function

Class CLink
    Dim Name ' String
    Public Value ' Variant
    Public Image ' String
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Public Caption
    Public ShowLabel ' Boolean - If true a label is displayed with the image
    Public Clicked
    Private Rendered
    Public SkinId
    Public Border
    Public Url
    Public Hide
    
    Private pAutoPostBackEnabled
    
    Sub Init(n)
        pAutoPostBackEnabled = False
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        Clicked = False
        If ASPALL(Me.Name).Count > 0 Then
            Value = CStr(ASPALL(Me.Name)(1))
            Clicked = True
        End If
        ' If Me.Value <> "" Then Clicked = True
        ' If Me.Value = "" Then Me.Value = "1"
        ShowLabel = True
        Border = 0
        Url = Self
        Rendered = False
    End Sub
    
    Public Property Get AutoPostBack
        AutoPostBack = False
        If Len(pAutoPostBackEnabled) > 0 Then AutoPostBack = True
    End Property
    Public Property Let AutoPostBack(v)
        ClientScripts.EnablePostBack
        pAutoPostBackEnabled = Convertto(vbBoolean,v)
    End Property
    
    
    Public Property Get ClassType
        ClassType = "CLink"
    End Property
    Public Property Get Protocols
        Protocols = "PControl"
    End Property
    
    Public PreserveInQueryString
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub RenderValue(newVal)
        If Hide Then Exit Sub
        Dim s
        If Not IsEmpty(newVal) Then Me.Value = newVal
        s = "<a id=""" & Me.ClientId & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
        If pAutoPostBackEnabled Then
            s = s & " href=""javascript:" & ClientScripts.GetPostBack(Me,Name,Value) & ";"">"
        Else
            s = s & " href=""" & Url & "?" & Me.Name & "=" & Me.Value & "&" & HttpGetParams & """>"
        End If
        If Me.Image <> "" Then
            s = s & "<img BORDER=""" & Border & """ src=""" & Me.Image & """"
            If Me.Caption <> "" Then s = s & " alt=""" & Server.HTMLEncode(Me.Caption) & """"
            s = s & "/>"
            If Me.Caption <> "" And ShowLabel Then s = s & " " & Server.HTMLEncode(Me.Caption)
        Else
            If Me.Caption <> "" Then s = s & Server.HTMLEncode(Me.Caption)
        End If    
        s = s & "</a>"
        Response.Write s
        Rendered = True
    End Sub
    Public Sub Render
        RenderValue Empty
    End Sub  
End Class

Function Create_CLink(controlName)
    Set Create_CLink = InitControl(New CLink,True,controlName)  
End Function

%>