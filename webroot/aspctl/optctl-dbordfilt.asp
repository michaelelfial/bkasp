<%


Class OrdererBtn
    Public Field
    Public Name
    Public ClientId
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public Caption
    Public Status
    Public FieldIndex
    Public SkinId
    Public ShowLabel
    Public Hide
    Public AsyncPostBack
    Public AsyncPostBackUCtl
    
    Public ImgNone
    Public ImgDesc
    Public ImgAsc
    Private Rendered
    
    Sub Init(n)
        Me.Name = n
        ClientId = NewClientId()
        Me.Status = 0
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "OrdererBtn"
    End Property
    
    Private Function NextStatus
        If Me.Status = 0 Then 
            NextStatus = 1
        ElseIf Me.Status > 0 Then
            NextStatus = -1
        Else
            NextStatus = 0
        End If
    End Function
    
    Private Function NameDecoration(idx,t)
        If t > 0 Then
            NameDecoration = "_" & idx & "ASC"
        ElseIf t < 0 Then
            NameDecoration = "_" & idx & "DESC"
        Else
            NameDecoration = "_" & idx
        End If            
    End Function
    
    Private Function RenderEvents(v)
        If IsObject(ClientScripts) Then 
            If AsyncPostBack Then
                RenderEvents = ClientScripts.RenderAsyncAndButtonEventHandlers(Me,"click", AsyncPostBackUCtl, Me.Name & NameDecoration(FieldIndex,NextStatus), v)
            Else
                RenderEvents = ClientScripts.RenderControlEventHandlers(Me)
            End If
        Else
            RenderEvents = ""
        End If
    End Function
    Public Function GetAsyncPostBack(uCtl)
        GetAsyncPostBack = "StaticAsyncPostBack(ccStaticEvent.NewEvent(this,arguments[0],'asyncpostback'),'" & CurrentFormName & "','" & uCtl.Name & "','" & Me.ClientId & "','" & Me.Name & NameDecoration(FieldIndex,NextStatus) & "','0')"
    End Function
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s, styleAndCss
        styleAndCss = StyleAndCssString(Me.CssClass, Me.Style)
        s = "<input type=""image"" name=""" & Me.Name & NameDecoration(FieldIndex,NextStatus) & """ id=""" & Me.ClientId & """"
        s = s & styleAndCss
        If Me.Caption <> "" Then s = s & " title=""" & Server.HTMLEncode(Me.Caption) & """"
        Dim curImg
        curImg = ImgNone
        If Status > 0 Then curImg = ImgAsc
        If Status < 0 Then curImg = ImgDesc
        s = s & " src=""" & curImg & """"
        s = s & RenderAttributes(pAttributes)
        If IsObject(ClientScripts) Then s = s & RenderEvents("1")
        s = s & "/>"
        Response.Write s & vbCrLf
        If ShowLabel And Not IsEmpty(Caption) Then
            If IsObject(ClientScripts) Then s = ClientScripts.RenderControlEventHandlers(Me)
            Response.Write "<label style=""cursor:pointer"" for=""" & Me.ClientId & """" & s & "><span " & styleAndCss & ">" & Server.HTMLEncode(Caption) & "</span></label>" & vbCrLf
        End If
        ' Response.Write "[" & NameDecoration(FieldIndex,NextStatus) & "," & Me.Status & "]"
        Rendered = True
    End Sub
    
End Class

Class OrdererSet

    Dim CtlName

    Public ImgNone
    Public ImgDesc
    Public ImgAsc
    Public SkinId
    Private Fields
    Public ShowLabels
    Public pHide
    Public UsePostVariables
    
    Private CurDirection
    
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    
    Public ClientId
    
    Private Rendered
    
    Public Clicked ' Indicator
    
    Sub Class_Initialize()
        Set Fields = CreateCollection()
        ImgNone = ASPCTLPath & "img/forder-none.gif"
        ImgDesc = ASPCTLPath & "img/forder-desc.gif"
        ImgAsc = ASPCTLPath & "img/forder-asc.gif"
        Style = "cursor: pointer"
        ShowLabels = True
        UsePostVariables = True
    End sub
    
    Private CurFieldIndex
    Private Sub StripRequest
        CurFieldIndex = 0
        CurDirection = 0
        Dim n, I
        n = CtlName
        Clicked = False
        For I = 1 To 32 ' Max fields = 0x20
            If ASPALL(n & "_" & I & ".x") <> "" Or ASPALL(n & "_" & I) <> "" Then
                CurFieldIndex = I
                CurDirection = 0
                If UsePostVariables Then PostVariables.SetCtlVar Me, "S", CurFieldIndex & "," & CurDirection
                Clicked = True
                Exit Sub
            ElseIf ASPALL(n & "_" & I & "ASC.x") <> "" Or ASPALL(n & "_" & I & "ASC") <> ""Then
                CurFieldIndex = I
                CurDirection = 1
                If UsePostVariables Then PostVariables.SetCtlVar Me, "S", CurFieldIndex & "," & CurDirection
                Clicked = True
                Exit Sub
            ElseIf ASPALL(n & "_" & I & "DESC.x") <> "" Or ASPALL(n & "_" & I & "DESC") <> "" Then
                CurFieldIndex = I
                CurDirection = -1
                If UsePostVariables Then PostVariables.SetCtlVar Me, "S", CurFieldIndex & "," & CurDirection
                Clicked = True
                Exit Sub
            End If
        Next
        ' If not found find the remembered values
        RestoreSaved
    End Sub
    
    Public Sub RestoreSaved
        Dim v
        If UsePostVariables Then
            v = ConvertTo(vbString,PostVariables.GetCtlVar(Me,"S"))
        Else
            v = CStr(ASPALL(CtlName))
        End If
        Dim arr
        arr = Split(v,",")
        If UBound(arr) >= 1 Then
            CurFieldIndex = ConvertTo(vbLong,arr(0))
            CurDirection = ConvertTo(vbLong,arr(1))
        End If
    End Sub
    
    Sub Init(n)
        If IsEmpty(n) Then
            Me.CtlName = NewCtlName()
        Else
            Me.CtlName = n
        End If
        ' Read the request
        ClientId = NewClientId()
        StripRequest
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "OrdererSet"
    End Property
    
    Function Add(fldName)
        Dim o
        Set o = New OrdererBtn
        o.Init Me.CtlName
        o.ImgNone = Me.ImgNone
        o.ImgDesc = Me.ImgDesc
        o.ImgAsc = Me.ImgAsc
        o.CssClass = Me.CssClass
        o.Style = Me.Style
        o.Field = fldName
        o.Status = 0
        Fields.Add fldName, o
        o.FieldIndex = Fields.Count
        o.SkinId = SkinId
        o.ShowLabel = Me.ShowLabels
        ApplyState
        Set Add = o
    End Function
    
    Private Sub ApplyState
        Dim itm, I
        For I = 1 To Fields.Count
            Set itm = Fields(I)
            If CurFieldIndex = I Then
                itm.Status = CurDirection
            Else
                itm.Status = 0
            End If
            itm.Name = Me.CtlName
            itm.SkinId = SkinId
            If IsEmpty(itm.Hide) Then itm.Hide = pHide
            itm.AsyncPostBack = pAsyncPostBack
            If IsObject(pAsyncPostBackUCtl) Then
                Set itm.AsyncPostBackUCtl = pAsyncPostBackUCtl
            Else
                itm.AsyncPostBackUCtl = pAsyncPostBackUCtl
            End If
        Next
    End Sub
    
    Public Property Get Name
        Name = CtlName
    End Property
    Public Property Let Name(v)
        CtlName = v
        ApplyState
    End Property
    
    Public Property Get Hide
        Hide = ConvertTo(vbBoolean,pHide)
    End Property
    Public Property Let Hide(v)
        pHide = v
        ApplyState
    End Property
    
    Public Property Get SortField
        Dim fld, I
        fld = ""
        For I = 1 To Fields.Count
            If I = CurFieldIndex Then
                fld = Fields(I).Field
                Exit For
            End If
        Next
        SortField = fld
    End Property
    Public Property Let SortField(v)
        Dim fld
        fld = UCase(ConvertTo(vbString,v))
        Dim I
        For I = 1 To Fields.Count
            If UCase(Fields(I).Field) = fld Then
                CurFieldIndex = I
                Exit For
            End If
        Next
        ApplyState
        If UsePostVariables Then PostVariables.SetCtlVar Me, "S", CurFieldIndex & "," & CurDirection
    End Property
    
    Public Property Get SortDir
        SortDir =  CurDirection
    End Property
    Public Property Let SortDir(v)
        Dim d
        d = ConvertTo(vbLong,v)
        If d < -1 Or d > 1 Then d = 0
        CurDirection = d
        ApplyState
        If UsePostVariables Then PostVariables.SetCtlVar Me, "S", CurFieldIndex & "," & CurDirection
    End Property
    
    Public Property Get OrderClause
        If SortField <> "" Then
            If SortDir > 0 Then
                OrderClause = " ORDER BY " & SortField & " ASC"
            ElseIf SortDir < 0 Then
                OrderClause = " ORDER BY " & SortField & " DESC"
            Else
                OrderClause = ""
            End If
        Else
            OrderClause = ""
        End If
    End Property
    
    
    Public Default Property Get Field(idx)
        Dim itm
        If IsEmpty(Fields(idx)) Then
            If VarType(idx) = vbString Then
                Set itm = Add(idx)
            Else
                Err.Raise Error_ItemNotFound,"ASPCTL Framework",Text_ItemNotFound
            End If
        Else
            Set itm = Fields(idx)
        End If
        Set Field = itm
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = Me.CtlName & "=" & CurFieldIndex & "," & CurDirection
        Else
            HttpGetParams = ""
        End If
    End Property
    
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
        ApplyState
        ' PutAsyncControlPostBack Me, "click", uCtl, v
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = pAsyncPostBack
    End Property
    
    Public Sub Render
        Dim s
        s = "<input type=""hidden"" name=""" & Me.CtlName & """ id=""" & Me.ClientId & """"
        s = s & " value=""" & CurFieldIndex & "," & CurDirection & """"
        s = s & "/>"
        Response.Write s & vbCrLf
        Rendered = True
    End Sub

End Class

Function Create_OrdererSet(controlName)
    Set Create_OrdererSet = InitControl(New OrdererSet, True,controlName)
End Function



%>