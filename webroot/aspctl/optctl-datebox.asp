<%

Class CDateBox
    Dim Name ' String
    Public Value ' Variant
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId
    Private Rendered
    Public SkinId
    Public Hidden
    Public Hide
    
    Public Format
    
    Sub Class_Initialize
        Format = "YYYY-MM-DD hh:mm"
        DtVal = Null
        Hidden = False
    End SUb
    
    Sub Init(n)
        MaxLength = 32
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
        ClassType = "CDateBox"
    End Property
    Public Property Get Protocols
        Protocols = "PControl,PDateValue"
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Name & "=" & Value
        Else
            HttpGetParams = ""
        End If
    End Property
    
    Public Property Let DateValue(v)
        Value = FormatDateString(NullConvertTo(vbDate,v),Me.Format)
    End Property
    Public Property Get DateValue
        DateValue = ParseDateString(Me.Value,Me.Format)
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
        If Hidden Then
            s = "<input type=""hidden"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        Else
            s = "<input type=""text"" name=""" & Me.Name & """ id=""" & Me.ClientId & """"
        End If
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
    

End Class

Function Create_CDateBox(controlName)
    Set Create_CDateBox = InitControl(New CDateBox,True,controlName)
End Function



%>