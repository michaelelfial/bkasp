<%
' Icon methods
Const LV_IconMethod_List       = 0 ' The Icon contains a field name/index which specifies the index in the ImageList
Const LV_IconMethod_Path       = 1 ' The Icon contains a field name/index which specifies the path to the image directly
Const LV_IconMethod_CallBack   = 2 ' The Icon contains a GetRef to a function which supplies the path to the image

Const LV_ImagePos_Before       = 0
Const LV_ImagePos_After        = 1

Const LV_ClickMode_None        = 0
Const LV_ClickMode_Button      = 1
Const LV_ClickMode_Checkbox    = 2
Const LV_ClickMode_Link        = 3

Const LV_ViewMode_Details      = 0
Const LV_ViewMode_Icons        = 1



Class CListViewColumn
    Public DisplayField     ' Used to extract data from collections - can be integer or name
    Public KeyField         ' If specified is used insted of indices to distinguish the particular items
    Public Caption  ' Caption shown in headers if applicable
    Public Format   ' StringUtilities.Sprintf format string
    Public CssClass 
    Public Style
    Public HeaderCssClass
    Public HeaderStyle
    Public Visible  ' Boolean visible flag
    Public IconMethod
    Public Icon
    Public ClickMode
    Public ListView
    Public ColumnIndex
    
    Public ImagePos
    
    Sub Class_Initialize
        Format = "%s"
        IconMethod = LV_IconMethod_List
        Visible = True
        ClickMode = LV_ClickMode_None
        ImagePos = LV_ImagePos_Before
    End Sub
    
    Sub Init()
        ' Initializer - the parent Listview should call this after setting all the necessary properties
        ' Especially important are the ColumnIndex, ListView
        
        Dim v ' Incoming values
        Dim I
        ' Try checkboxes because they are more economic
        If ASPALL(ListView.Name & "_C" & ColumnIndex & "_CheckBox").Count > 0 Then
            Set v = ASPALL(ListView.Name & "_C" & ColumnIndex & "_CheckBox")
        Else
            ' Try buttons
            Set v = CollectValuesFromRequest(ListView.Name, "_I" & ColumnIndex & "_")    
        End If
        If IsEmpty(KeyField) Then
            For I = 1 To v.Count
                If Not IsEmpty(v(I)) Then
                    ListView.SelectedItems.Add Empty, v(I)    
                End If
            Next
        Else
            For I = 1 To v.Count
                If Not IsEmpty(v(I)) Then
                    ListView.SelectedItems.Add Empty, PageDecryptString(v(I))
                End If
            Next
        End If
    End Sub
    

    Public Property Get ClassType
        ClassType = "CListViewColumn"
    End Property
    
    Sub RenderHeader
        ' Not impl
    End Sub
    Private Function DisplayText(ItemIndex, Item)
        If IsEmpty(DisplayField) Then
            DisplayText = ConvertTo(vbString(Item))
        Else
            DisplayText = Item(DisplayField)
        End If
    End Function
    Function RenderImage(ItemIndex,Item)
        Dim s, iconPath
        If Not IsEmpty(Icon) Then
            If IconMethod = LV_IconMethod_List Then
                iconPath = ListView.ImageList(Item(Icon))
            ElseIf IconMethod = LV_IconMethod_Path Then
                iconPath = Item(Icon)
            ElseIf IconMethod = LV_IconMethod_CallBack Then
                If IsObject(Icon) Then
                    If Not Icon Is Nothing Then
                        iconPath = Icon(Me, ItemIndex, Item)
                    End If
                End If
            End If
        End If
        
        If IsEmpty(iconPath) Or IsNull(iconPath) Then iconPath = Listview.DefaultIcon
            
        If ClickMode <> LV_ClickMode_Button Then
            s = "<img border=""0"" src=""" & iconPath & """>"
        Else
            If IsEmpty(KeyField) Then
                s = "<input type=""image"" border=""0"" name=""" & ListView.Name & "_I" & ColumnIndex & "_" & ItemIndex & """ src=""" & iconPath & """ id=""" & ListView.ClientID & "_" & ItemIndex & """>"
            Else
                s = "<input type=""image"" border=""0"" name=""" & ListView.Name & "_I" & ColumnIndex & "_" & PageEncryptString(Item(KeyField)) & """ src=""" & iconPath & """ id=""" & ListView.ClientID & "_" & ItemIndex & """>"
            End If
        End If
        RenderImage = s
    End Function
    Function Render(ItemIndex, Item)  ' Render an Item
        If Not Visible Then 
            Render = ""
            Exit Function
        End If
        Dim s, checked
        s = "<td nowrap "
        If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
        If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
        s = s & ">" & vbCrLf
        
        If ClickMode = LV_ClickMode_Checkbox Then
            checked = ""
            If IsEmpty(KeyField) Then
                If ListView.IsSelected(ItemIndex) Then checked = " checked"
                s = s & "<input type=""checkbox"" name=""" & ListView.Name & "_C" & ColumnIndex & "_CheckBox"" id=""" & ListView.ClientId & "_" & ItemIndex & """ value=""" & ItemIndex & """" & checked & ">" & vbCrLf
            Else
                If ListView.IsSelected(Item(KeyField)) Then checked = " checked"
                s = s & "<input type=""checkbox"" name=""" & ListView.Name & "_C" & ColumnIndex & "_CheckBox"" id=""" & ListView.ClientId & "_" & ItemIndex & """ value=""" & PageEncryptString(Item(KeyField)) & """" & checked & ">" & vbCrLf
            End If
        End If
        
        If ImagePos = LV_ImagePos_Before Then
            ' Put the image before
            s = s & RenderImage(ItemIndex, Item) & vbCrLf
        End If
        
        s = s & "<label style=""cursor: pointer"" for=""" & ListView.ClientId & "_" & ItemIndex & """>"
        
        s = s & Server.HTMLEncode(DisplayText(ItemIndex, Item))
        
        s = s & "</label>" & vbCrLf
        
        If ImagePos = LV_ImagePos_After Then
            s = s & RenderImage(ItemIndex, Item) & vbCrLf
        End If
        
        s = s & "</td>" & vbCrLf
        Render = s    
    End Function
    
    
    
End Class

Class CListView
    Public Name
    Public ClientId
    Public Columns
    Public Items
    Public BaseIndex
    Public ImageList
    Public Rendered
    Public SkinId
    Public Hide
    
    Public KeyField
    Public SelectedItems ' 
    
    Public ViewMode
    Public ClickMode
    Public ShowHeaders
    Public LineSize
    Public PreserveOptions
    
    ' Default Styling for the items
    Public CssClass
    Public Style
    ' Default styling for the headers
    Public HeaderCssClass
    Public HeaderStyle
    ' Table styling
    Public TableCssClass
    Public TableStyle
    Public CellPadding
    Public CellSpacing
    
    Public DefaultIcon
    
    
    Sub Class_Initialize
        Set Columns = CreateCollection
        Set ImageList = CreateCollection
        Set SelectedItems = CreateCollection
        CellPadding = 0
        CellSpacing = 0
        BaseIndex = 1
        ShowHeaders = True
        LineSize = 10
        PreserveOptions = True
        DefaultIcon = SysImage(Empty)
    End Sub
    
    Sub Init(n)
        ' Read the request
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        
        ' Collect the values from the Request
        UnPersistOptions
        ' Add the default column - always present ???
        ' AddColumn "Default", Empty, Empty
        
        Rendered = False
    End Sub
    

    Public Property Get ClassType
        ClassType = "CListView"
    End Property
    Public Function IsSelected(keyOrIndex)
        Dim I, k
        k = ConvertTo(vbString,keyOrIndex)
        IsSelected = False
        For I = 1 To SelectedItems.Count
            If k = SelectedItems(I) Then
                IsSelected = True
                Exit Function
            End If
        Next
    End Function
    
    ' Columns
    Function AddColumn(colName,DisplayField,KeyField)
        Dim c
        Set c = New CListViewColumn
        c.DisplayField = DisplayField
        If IsEmpty(KeyField) Then
            c.KeyField = Me.KeyField
        Else
            c.KeyField = KeyField
        End If
        ' Set the defaults
        Set c.ListView = Me
        c.Style = Me.Style
        c.CssClass = Me.CssClass
        c.HeaderStyle = Me.HeaderStyle
        c.HeaderCssClass = Me.HeaderCssClass
        ' By default only the first column is clickable
        If Columns.Count > 0 Then
            c.ClickMode = LV_ClickMode_None
        Else
            c.ClickMode = Me.ClickMode
        End If
        
        Columns.Add colName, c
        c.ColumnIndex = Columns.Count ' This is important - the column needs it in order to find its values
        
        ' Calling the initializer in order to enable it to read the request
        c.Init
        
        Set AddColumn = c    
    End Function
    Sub DeleteColumn(c)
        Columns.Remove c
    End Sub
    Property Get Column(c)
        Set Column = Columns(c)
    End Property
    
    Private Function PersistOptions
        If PreserveOptions Then
            Dim ts
            Set ts = CreateTSSection(Empty)
            ts("ViewMode") = ConvertTo(vbLong,ViewMode)
            ts("ClickMode") = ConvertTo(vbLong,ClickMode)
            ts("ShowHeaders") = ConvertTo(vbLong,ShowHeaders)
            ts("LineSize") = ConvertTo(vbLong,LineSize)
            PersistOptions = TSToHex(ts, EncryptSecondaryData)
        Else
            PersistOptions = ""
        End If
    End Function
    Private Function UnPersistOptions
        Dim s
        s = ConvertTo(vbString,ASPALL(Me.Name & "_Options"))
        If Len(s) > 0 Then
            ' Something to unpersist
            Dim ts
            Set ts = TSFromHex(s, EncryptSecondaryData)
            ViewMode = ConvertTo(vbLong,ts("ViewMode"))
            ClickMode = ConvertTo(vbLong, ts("ClickMode"))
            ShowHeaders = ConvertTo(vbLong, ts("ShowHeaders"))
            LineSize = ConvertTo(vbLong, ts("LineSize"))
        End If
    End Function
    
    ' Rendering
    Sub Render
        Dim s, I, J
        s = ""
        s = s & "<input type=""hidden"" name=""" & Me.Name & "_Options"" value=""" & PersistOptions & """>" & vbCrLf
        If Hide Then
            Response.Write s
            Exit Sub
        End If
        s = s & "<table CellPadding=""" & CellPadding & """ CellSpacing=""" & CellSpacing & """ " & StyleAndCssString(TableCssClass,TableStyle) & ">" & vbCrLf
        If ViewMode = LV_ViewMode_Details Then
            For I = Me.BaseIndex To Items.Count - 1 + BaseIndex
                s = s & "<tr>" & vbCrLf
                For J = 1 To Columns.Count
                    s = s & Columns(J).Render(I, Items(I))
                Next
                s = s & "</tr>" & vbCrLf
            Next
        ElseIf ViewMode = LV_ViewMode_Icons then
            s = s & "<tr>" & vbCrLf
            For I = Me.BaseIndex To Items.Count - 1 + BaseIndex
                s = s & Column(1).Render(I, Items(I))
                If I > 0 And ((I Mod LineSize) = 0) Then
                    s = s & "</tr><tr>" & vbCrLf
                End If
            Next
            s = s & "</tr>" & vbCrLf
        Else
            ' Unknown mode
        End If
        s = s & "</table>" & vbCrLf
        Response.Write s
    End Sub

End Class

Function Create_CListView(controlName)
    Dim ctl
    Set Create_CListView = InitControl(New CListView, True, controlName)
End Function

%>