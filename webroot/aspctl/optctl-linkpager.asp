<%
' For get requests only !!!
Class CLinkPager

    Dim Name ' String -- name in the request and forms
    Public mTotalPages
    Public Page
    Public PageSize ' Helper only
    Public ShowPages
    Public ClientId
    Public Clicked
    Public Hide
    
    Public FirstDelimiter
    Public LastDelimiter
    
    Public CssClass
    Public CurrentCssClass
    Public Style
    Public CurrentStyle
    Public SkinId
    
    Public TargetPage
    Public NoTotalPagesPreserve
    
    Sub Class_Initialize()
        Clicked = False
        Page = 1
        ShowPages = 10
        PageSize = 10
        mTotalPages = 0
        FirstDelimiter = "&nbsp;&lt;&lt;&nbsp;"
        LastDelimiter = "&nbsp;&gt;&gt;&nbsp;"
        pSavedPage = 0
        pSavedTotalPages = 1
        PreserveInQueryString = True
        TargetPage = Self
        NoTotalPagesPreserve = True
    End sub
    
    Sub Init(n)
        ' Read the request
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        
        Dim v 
        v = CStr(ASPALL(Me.Name))
        If v <> "" Then 
            Clicked = True
            Page = ConvertTo(vbLong,v)
        Else
            Page = SavedPage
        End If
        SavedTotalPages = ConvertTo(vbLong,Trim(ASPALL(Me.Name & "_TP")))
        If SavedTotalPages > 0 Then TotalPages = SavedTotalPages ' Pre-sets it to the last known pages count
        
        If Page < 1 Then Page = 1
        If SavedPage < 1 Then SavedPage = Page
        Rendered = False
    End Sub
    
    Public Sub RestoreSaved
        Page = SavedPage
        TotalPages = SavedTotalPages
    End Sub
    Private pSavedPage
    Private pSavedTotalPages
    Public Property Get SavedPage
        If ASPALL(Me.Name & "_SP").Count > 0 Then
            SavedPage = ConvertTo(vbLong,Trim(ASPALL(Me.Name & "_SP")))
        Else
            If IsObject(PostVariables) Then
                SavedPage = ConvertTo(vbLong,PostVariables.GetCtlVar(Me,"SP"))
            Else
                SavedPage = 0
            End If
        End If
    End Property
    Public Property Let SavedPage(v)
        If IsObject(PostVariables) Then
            PostVariables.SetCtlVar Me, "SP", ConvertTo(vbLong,v)
        End If
        pSavedPage = ConvertTo(vbLong, v)
    End Property
    Public Property Get SavedTotalPages
        If ASPALL(Me.Name & "_SP").Count > 0 Then
            SavedTotalPages = ConvertTo(vbLong,Trim(ASPALL(Me.Name & "_TP")))
        Else
            If IsObject(PostVariables) Then
                SavedTotalPages = ConvertTo(vbLong,PostVariables.GetCtlVar(Me,"TP"))
            Else
                SavedTotalPages = 1
            End If
        End If
    End Property
    Public Property Let SavedTotalPages(v)
        If IsObject(PostVariables) Then
            PostVariables.SetCtlVar Me, "TP", ConvertTo(vbLong,v)
        End If
        pSavedTotalPages = ConvertTo(vbLong, v)
    End Property
    
    Public Property Get ClassType
        ClassType = "CLinkPager"
    End Property
    
    Public Property Get TotalPages
        TotalPages = mTotalPages
    End Property
    Public Property Let TotalPages(v)
        mTotalPages = ConvertTo(vbLong,v)
        If Page > mTotalPages Then Page = mTotalPages
    End Property
    
    Private pItemCount
    Public Property Let ItemCount(v)
        Dim c, pgs
        c = ConvertTo(vbLong,v)
        pgs = c \ PageSize
        if c Mod PageSize > 0 Then pgs = pgs + 1
        pItemCount = c
        TotalPages = pgs
    End Property
    Public Property Get ItemCount
        ItemCount = pItemCount
    End Property
    
    Public Property Get LimitOffsetClause
        LimitOffsetClause = " LIMIT " & PageSize & " OFFSET " & (Page - 1) * PageSize & " "
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        Dim s
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            s = Me.Name & "_SP=" & Page 
            If Not NoTotalPagesPreserve Then
                s = s & "&" & Me.Name & "_TP=" & TotalPages
            End If
            HttpGetParams = s
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
    
    Public Sub Render
        If TotalPages > 0 Then
            Dim s, sCurrent
            Dim nLimit
            nLimit = CLng(ShowPages / 2)
            
            s = ""
            sCurrent = ""
            If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
            If Not IsEmpty(Me.CurrentCssClass) Then sCurrent = sCurrent & " class=""" & Me.CurrentCssClass & """"
            If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
            If Not IsEmpty(Me.CurrentStyle) Then sCurrent = sCurrent & " style=""" & Me.CurrentStyle & """"
            s = s & RenderAttributes(pAttributes)
            sCurrent = sCurrent & RenderAttributes(pAttributes)
            If IsObject(ClientScripts) Then 
                s = s & ClientScripts.RenderControlEventHandlers(Me)
                sCurrent = sCurrent & ClientScripts.RenderControlEventHandlers(Me)
            End If
            If IsObject(PostVariables) Then
                SavedPage = Page
                SavedTotalPages = TotalPages
            End If
            ' In case of a get form there is no harm in rendering these
            Response.Write "<input type=""hidden"" name=""" & Me.Name & "_SP"" value=""" & Page & """>" & VbCrLf                
            Response.Write "<input type=""hidden"" name=""" & Me.Name & "_TP"" value=""" & TotalPages & """>" & VbCrLf                
            
            If Hide Then Exit Sub
                
            If TotalPages > 1 And Page > 1 + nLimit Then
                ' Output GoFirst
                Response.Write "<a href=""" & PageLink(TargetPage,Me.Name & "=1") & """ " & s & ">1</a>" & FirstDelimiter & VbCrLf
            End If
            
            Dim iPage
            For iPage = Page - nLimit To Page + nLimit
                If iPage > 0 And iPage <= TotalPages Then
                    If iPage = Page Then
                        Response.Write "<a href=""" & PageLink(TargetPage,Me.Name & "=" & iPage) & """ " & sCurrent & ">" & iPage & "</a>&nbsp;" & VbCrLf
                    Else
                        Response.Write "<a href=""" & PageLink(TargetPage,Me.Name & "=" & iPage) & """ " & s & ">" & iPage & "</a>&nbsp;" & VbCrLf
                    End If
                End If
            Next
            
            If TotalPages > 1 And Page < TotalPages - nLimit Then
                ' Output GoFirst
                Response.Write LastDelimiter & "<a href=""" & PageLink(TargetPage,Me.Name & "=" & TotalPages) & """ " & s & ">" & TotalPages & "</a>" & VbCrLf
            End If
            
        End If
    End Sub

End Class


Function Create_CLinkPager(controlName)
    Dim ctl
    Set Create_CLinkPager = InitControl(New CLinkPager, True, controlName)
End Function



%>