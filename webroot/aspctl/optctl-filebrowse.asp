<%

Class CFileBrowser
    Dim Name
    Dim ClientId
    Dim Rendered
    Dim SkinId
    Dim Hide
    
    Dim CurDirectory ' The current directory
    Dim Mask ' The mask for the current directory (not impl)
    
    Dim ImgDir ' The directory containing the file type images
    Dim PageSize    ' The page size for the directory
    Dim CurrentPos ' Current position in the contents
    Dim RootPath ' The root parh
    
    Dim LinkProc ' Callback for link generation (not impl)
    Dim UsePostBack ' (not impl)
    
    Dim CssClass
    Dim Style
    Dim HeaderCssClass
    Dim HeaderStyle
    Dim ItemCssClass
    Dim ItemStyle
    Dim SelectedCssClass
    Dim SelectedStyle
    Dim CellPadding
    Dim CellSpacing
    
    Dim ShowFiles
    Dim ShowFolders
    Dim NoFileSelect
    Dim NoFolderSelect
    
    Dim Mode
    Dim LineSize
    
    
    Private suFormatter
    
    ' Display attributes
    Dim MultiSelect
    
    Dim ShowSize
    Dim ShowTime
    
    Dim ShowHeaders
    ' Dim ShowUpDir
    ' Dim ShowDrives
    
    Dim SelectedFiles
    
    Sub Class_Initialize()
        Set SelectedFiles = CreateCollection
        Set suFormatter = Server.CreateObject("newObjects.utilctls.StringUtilities")
        PageSize = 10
        CurrentPos = 1
        RootPath = MapPath("/")
        ImgDir = "/aspctl/fileimg/"
        UsePostBack = False
        MultiSelect = False
        ShowSize = True
        ShowTime = True
        ShowHeaders = True
        CellPadding = 1
        CellSpacing = 1
        ShowFiles = True
        ShowFolders = True
        Mode = 0
        LineSize = 10
        Selected = False
        NoFileSelect = False
        NoFolderSelect = False
        CssClass = "filebrowser"
        HeaderCssClass = "header"
        ItemCssClass = "item"
        SelectedCssClass = "selected"
    End Sub
    
    Sub Init(n)
        ' Read the request
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        
        ' Get the directory name
        Dim v 
        ' Get the directory name
        v = CStr(ASPALL(Me.Name & "_Directory"))
        If v <> "" Then 
            Me.CurDirectory = PageDecryptString(v)
        End If
        ' Get the selections
        
        Set SelectedFiles = CollectValuesFromRequest(Me.Name,"_F_")
        For v = 1 To SelectedFiles.Count
            SelectedFiles(v) = PageDecryptString(SelectedFiles(v))
        Next
        
        If CurrentPos < 1 Then CurrentPos = 1
        Rendered = False
    End Sub
    
    Public Property Get ClassType
        ClassType = "CFileBrowser"
    End Property
    
    Public Property Get Directory
        Directory = CurDirectory
    End Property
    Public Property Let Directory(x)
        CurDirectory = x
        SelectedFiles.Clear
    End Property
    Function UpDir
        Dim su, d
        If Len(CurDirectory) < 2 Then
            UpDir = False
            Exit Function
        End If
        Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
        Dim sf
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        d = su.Trim(CurDirectory,"\/",1)
        Dim p
        p = InStrRev(d,"\")
        UpDir = False
        If p > 0 Then 
            d = Left(d,p)
            If sf.FolderExists(d) Then
                Directory = d
                UpDir = True
            End If
        End If
    End Function
    Public Function SubDir(x)
        SubDir = False
        If Len(Directory) > 0 then
            Dim d
            d = Directory
            If Right(d,1) <> "\" Then d = d & "\"
            d = d & x
            Dim sf
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            If sf.FolderExists(d) Then
                Directory = d
                SubDir = True
            End If
        End If
    End Function
    
    Public Property Get Clicked
        If Not MultiSelect Then
            If SelectedFiles.Count = 1 Then Clicked = True Else Clicked = False
        Else
            Clicked = False
        End If
    End Property
    Public Property Get ClickedItem
        If Clicked Then ClickedItem = SelectedFiles(1) Else ClickedItem = ""
    End Property
    Public Property Get ClickedDirectory
        Dim itm
        itm = ClickedItem
        ClickedDirectory = ""
        If Len(itm) > 0 Then
            Dim sf
            Dim d
            d = Directory
            If Right(d,1) <> "\" Then d = d & "\"
            d = d & itm
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            If sf.FolderExists(d) Then ClickedDirectory = d
        End If
    End Property
    Public Property Let ClickedDirectory(v)
        Directory = v
    End Property
    Public Property Get ClickedFile
        Dim itm
        itm = ClickedItem
        ClickedFile = ""
        If Len(itm) > 0 Then
            Dim sf
            Dim d
            d = Directory
            If Right(d,1) <> "\" Then d = d & "\"
            d = d & itm
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            If sf.FileExists(d) Then ClickedFile = d
        End If
    End Property
    Public Property Let ClickedFile(v)
        Dim sf
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        If sf.FileExists(v) Then
            Directory = sf.GetFilePath(v)
            SelectedFiles(sf.GetFileName(v)) = sf.GetFileName(v)
        Else
            Directory = sf.GetFilePath(v)
        End If
    End Property
    
    
    Private Function FullPathOf(file)
        Dim s
        s = CurDirectory
        If Right(s,1) <> "\" Then s = s & "\"
        s = s & file
        FullPathOf = s
    End Function
    Private Function FormatFileSize(o)
        Dim size
        size = o.size
        If size < 0 Then
            FormatFileSize = "big!"
        ElseIf size <= 999 Then
            FormatFileSize = suFormatter.Sprintf("%db",size)
        ElseIf size >= 1000 And size < 1000000 Then
            FormatFileSize = suFormatter.Sprintf("%8.1fKb",CDbl(size) / 1024)
        ElseIf size >= 1000000 and size < 1000000000 Then
            FormatFileSize = suFormatter.Sprintf("%8.1fMb",CDbl(size) / (1024 * 1024))
        Else
            FormatFileSize = suFormatter.Sprintf("%8.1fMb",CDbl(size) / (1024 * 1024 * 1024))
        End If
    End Function
    Private Function FormatFileTime(o)
        FormatFileTime = suFormatter.Sprintf("%lT",o.Modified)
    End Function
    
    Public Function IsSelected(s)
        Dim I
        IsSelected = False
        For I = 1 To SelectedFiles.Count
            If UCase(SelectedFiles(I)) = UCase(s) Then
                IsSelected = True
                Exit Function
            End If
        Next
    End Function
    
    
    Private Sub RenderItem(sf,o,index)
        ' Response.Write index & "<BR>"
    
        Dim ext, fullFilePath, extImg
        fullFilePath = FullPathOf(o.name)
        
        If o.Type = 1 Then
            If Not ShowFolders Then Exit Sub
            extImg = VirtPath(ImgDir & "folder.gif")
        Else
            If Not Showfiles Then Exit Sub
            ext = sf.GetExtensionName(fullFilePath)
            If sf.Exists(MapPath(ImgDir & ext & ".gif")) Then
                extImg = VirtPath(ImgDir & ext & ".gif")
            Else
                extImg = VirtPath(ImgDir & "unknown.gif")
            End If
        End If            
        
        Dim s, classStr, styleStr, stdAttribs
        If IsSelected(o.name) Then 
            If IsEmpty(Me.SelectedCssClass) Then classStr = "" Else classStr = "class=""" & Me.SelectedCssClass & """"
            If IsEmpty(Me.SelectedStyle) Then styleStr = "" Else styleStr = "style=""" & Me.SelectedStyle & """"
            stdAttribs = classStr & " " & styleStr
        Else
            If IsEmpty(Me.ItemCssClass) Then classStr = "" Else classStr = "class=""" & Me.ItemCssClass & """"
            If IsEmpty(Me.ItemStyle) Then styleStr = "" Else styleStr = "style=""" & Me.ItemStyle & """"
            stdAttribs = classStr & " " & styleStr
        End If
        
        s = ""
        s = s & "<tr>" & vbCrLf
        Dim checked
        If Not Me.MultiSelect Then
            s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
            If (NoFolderSelect And o.Type = 1) Or (NoFileSelect And o.Type = 2) Then
                s = s & "<img src=""" & extImg & """ alt=""" & Server.HTMLEncode(o.Name) & """ id=""" & Me.ClientId & "_" & index & """/></td>"  & vbCrLf
                s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
                s = s & "<label for=""" & Me.ClientId & "_" & index & """>" & Server.HTMLEncode(o.name) & "</label></td>"  & vbCrLf
            Else
                s = s & "<input type=""image"" name=""" & Me.Name & "_F_" & PageEncryptString(o.name) & """ src=""" & extImg & """ alt=""" & Server.HTMLEncode(o.Name) & """ id=""" & Me.ClientId & "_" & index & """/></td>"  & vbCrLf
                s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
                s = s & "<label style=""cursor:pointer"" for=""" & Me.ClientId & "_" & index & """>" & Server.HTMLEncode(o.name) & "</label></td>"  & vbCrLf
            End If
        Else
            If IsSelected(o.name) Then checked = "checked" Else checked = ""
            If (NoFolderSelect And o.Type = 1) Or (NoFileSelect And o.Type = 2) Then
                s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
                s = s & "<img src=""" & extImg & """ alt=""" & Server.HTMLEncode(o.Name) & """/></td>" & vbCrLf
                s = s & "<td " & stdAttribs & " nowrap>" & vbCrLf
                s = s & "<label for=""" & Me.ClientId & "_" & index & """>" & Server.HTMLEncode(o.name) & "</label></td>" & vbCrLf
            Else
                s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
                s = s & "<input type=""checkbox"" name=""" & Me.Name & "_F_" & PageEncryptString(o.name) & """ id=""" & Me.ClientId & "_" & index & """ " & checked & " ><img src=""" & extImg & """ alt=""" & Server.HTMLEncode(o.Name) & """/></td>" & vbCrLf
                s = s & "<td " & stdAttribs & " nowrap>" & vbCrLf
                s = s & "<label style=""cursor:pointer"" for=""" & Me.ClientId & "_" & index & """>" & Server.HTMLEncode(o.name) & "</label></td>" & vbCrLf
            End If
        End If
        If Me.ShowSize Then
            s = s & "<td " & stdAttribs & " nowrap>" & FormatFileSize(o) & "</td>" & vbCrLf
        End If
        If Me.ShowTime Then
            s = s & "<td " & stdAttribs & " nowrap>" & FormatFileTime(o) & "</td>" & vbCrLf
        End If
        s = s & "</tr>" & vbCrLf
        Response.Write s
    End Sub
    
    Public Sub Render0
        If IsEmpty(CurDirectory) Then Exit Sub
        Dim dir, sf, list, numListed, I, o
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        On Error Resume Next
        Set dir = sf.OpenDirectory(CurDirectory,&H40)
        If Err.Number <> 0 Then
            Set list = CreateCollection
        Else
            Set list = dir.contents
        End If
        
        
        Dim headerAttribs, tableAttribs
        headerAttribs = ""
        tableAttribs = ""
        If Not IsEmpty(Me.HeaderCssClass) Then headerAttribs = headerAttribs & "class=""" & Me.HeaderCssClass & """ "
        If Not IsEmpty(Me.HeaderStyle) Then headerAttribs = headerAttribs & "style=""" & Me.HeaderStyle & """ "
        If Not IsEmpty(Me.CssClass) Then tableAttribs = tableAttribs & "class=""" & Me.CssClass & """ "
        If Not IsEmpty(Me.Style) Then tableAttribs = tableAttribs & "style=""" & Me.Style & """ "            
            
        
        Dim s
        Response.Write "<input type=""hidden"" name=""" & Me.Name & "_Directory"" value=""" & PageEncryptString(Me.CurDirectory) & """/>"
        If Hide Then Exit Sub
        Response.Write "<table cellpadding=""" & CellPadding & """ cellspacing=""" & CellSpacing & """ " & tableAttribs & ">" & vbCrLf
        Response.Write "<tr>" & vbCrLf
            Response.Write "<th " & headerAttribs & ">&nbsp;</th><th " & headerAttribs & ">" & ResourceText("Name") & "</th>" & vbCrLf
            If Me.ShowSize Then Response.Write "<th " & headerAttribs & ">" & ResourceText("Size") & "</th>" & vbCrLf
            If Me.ShowTime Then Response.Write "<th " & headerAttribs & ">" & ResourceText("DateTime") & "</th>" & vbCrLf
        Response.Write "</tr>" & vbCrLf
        For I = CurrentPos To list.Count
            Set o = list(I) ' Current file object
            RenderItem sf, o, I            
        Next
        Response.Write "</table>" & vbCrLf
    End Sub
    
    Private Function RenderItem1(sf,o,index)
        ' Response.Write index & "<BR>"
        RenderItem1 = 0
    
        Dim ext, fullFilePath, extImg
        fullFilePath = FullPathOf(o.name)
        
        If o.Type = 1 Then
            If Not ShowFolders Then Exit Function
            extImg = VirtPath(ImgDir & "folder.gif")
        Else
            If Not Showfiles Then Exit Function
            ext = sf.GetExtensionName(fullFilePath)
            If sf.Exists(MapPath(ImgDir & ext & ".gif")) Then
                extImg = VirtPath(ImgDir & ext & ".gif")
            Else
                extImg = VirtPath(ImgDir & "unknown.gif")
            End If
        End If            
        
        Dim s, classStr, styleStr, stdAttribs
        If IsSelected(o.name) Then 
            If IsEmpty(Me.SelectedCssClass) Then classStr = "" Else classStr = "class=""" & Me.SelectedCssClass & """"
            If IsEmpty(Me.SelectedStyle) Then styleStr = "" Else styleStr = "style=""" & Me.SelectedStyle & """"
            stdAttribs = classStr & " " & styleStr
        Else
            If IsEmpty(Me.ItemCssClass) Then classStr = "" Else classStr = "class=""" & Me.ItemCssClass & """"
            If IsEmpty(Me.ItemStyle) Then styleStr = "" Else styleStr = "style=""" & Me.ItemStyle & """"
            stdAttribs = classStr & " " & styleStr
        End If
        s = ""
        Dim checked, tooltip
        tooltip = Server.HTMLEncode(o.Name & vbCrLf & FormatFileSize(o) & vbCrLf & FormatFileTime(o))
        If Not Me.MultiSelect Then
            If (NoFolderSelect And o.Type = 1) Or (NoFileSelect And o.Type = 2) Then
                s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
                s = s & "<img src=""" & extImg & """ alt=""" & tooltip & """ id=""" & Me.ClientId & "_" & index & """/>"  & vbCrLf
                s = s & "<label for=""" & Me.ClientId & "_" & index & """>" & Server.HTMLEncode(o.name) & "</label></td>"  & vbCrLf
            Else
                s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
                s = s & "<input type=""image"" name=""" & Me.Name & "_F_" & PageEncryptString(o.name) & """ src=""" & extImg & """ alt=""" & tooltip &  """ id=""" & Me.ClientId & "_" & index & """/>"  & vbCrLf
                s = s & "<label style=""cursor:pointer"" for=""" & Me.ClientId & "_" & index & """>" & Server.HTMLEncode(o.name) & "</label></td>"  & vbCrLf
            End If
        Else
            If IsSelected(o.name) Then checked = "checked" Else checked = ""
            If (NoFolderSelect And o.Type = 1) Or (NoFileSelect And o.Type = 2) Then
                s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
                s = s & "<img src=""" & extImg & """ alt=""" & tooltip & """/>" & vbCrLf
                s = s & "<label style=""cursor:pointer"" for=""" & Me.ClientId & "_" & index & """>" & Server.HTMLEncode(o.name) & "</label></td>" & vbCrLf
            Else
                s = s & "<td " & stdAttribs & " nowrap>"  & vbCrLf
                s = s & "<input type=""checkbox"" name=""" & Me.Name & "_F_" & PageEncryptString(o.name) & """ id=""" & Me.ClientId & "_" & index & """ " & checked & " /><img src=""" & extImg & """ alt=""" & tooltip & """/>" & vbCrLf
                s = s & "<label style=""cursor:pointer"" for=""" & Me.ClientId & "_" & index & """>" & Server.HTMLEncode(o.name) & "</label></td>" & vbCrLf
            End If
        End If
        Response.Write s
        RenderItem1 = 1
    End Function
    
    Public Sub Render1
        If IsEmpty(CurDirectory) Then Exit Sub
        Dim dir, sf, list, numListed, I, o
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        On Error Resume Next
        Set dir = sf.OpenDirectory(CurDirectory,&H40)
        If Err.Number <> 0 Then
            Set list = CreateCollection
        Else
            Set list = dir.contents
        End If
        
        Dim headerAttribs, tableAttribs
        headerAttribs = ""
        tableAttribs = ""
        If Not IsEmpty(Me.HeaderCssClass) Then headerAttribs = headerAttribs & "class=""" & Me.HeaderCssClass & """ "
        If Not IsEmpty(Me.HeaderStyle) Then headerAttribs = headerAttribs & "style=""" & Me.HeaderStyle & """ "
        If Not IsEmpty(Me.CssClass) Then tableAttribs = tableAttribs & "class=""" & Me.CssClass & """ "
        If Not IsEmpty(Me.TableStyle) Then tableAttribs = tableAttribs & "style=""" & Me.TableStyle & """ "            
            
        
        Dim s
        Response.Write "<input type=""hidden"" name=""" & Me.Name & "_Directory"" value=""" & PageEncryptString(Me.CurDirectory) & """/>" & vbCrLf
        If Hide Then Exit Sub
        Response.Write "<table cellpadding=""" & CellPadding & """ cellspacing=""" & CellSpacing & """ " & tableAttribs & ">" & vbCrLf
        Dim totalItems
        totalItems = 0
        Response.Write "<tr>"
        For I = CurrentPos To list.Count
            Set o = list(I) ' Current file object
            totalItems = totalItems + RenderItem1(sf, o, I)
            If totalItems Mod LineSize = 0 Then Response.Write "</tr><tr>" & vbCrLf
        Next
        Dim stdAttribs, classStr, styleStr
        If IsEmpty(Me.ItemCssClass) Then classStr = "" Else classStr = "class=""" & Me.ItemCssClass & """"
        If IsEmpty(Me.Style) Then styleStr = "" Else styleStr = "style=""" & Me.Style & """"
        stdAttribs = classStr & " " & styleStr
        If totalItems Mod LineSize <> 0 Then
            For I = totalItems Mod LineSize + 1 To LineSize
                Response.Write "<td " & stdAttribs & ">&nbsp;</td>" & vbCrLf
            Next
        End If
        Response.Write "</tr>"
        Response.Write "</table>" & vbCrLf
    End Sub
    
    Public Sub Render
        If Mode = 2 Then
        ElseIf Mode = 1 Then
            Render1
        Else
            Render0
        End If
    End Sub

End Class

Function Create_FileBrowser(controlName)
    Dim ctl
    Set Create_FileBrowser = InitControl(New CFileBrowser, True, controlName)
End Function



%>