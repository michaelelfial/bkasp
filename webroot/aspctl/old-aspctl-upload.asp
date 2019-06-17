<%

Class CASPCTLFile
    Public ContentType
    Public Name
    Public RawFileName
    Public FileName
    Public FileNameExtension
    Public ContentLength
    
    Private Content
    
    Sub Class_Initialize
        Dim sf
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        Set Content = sf.CreateMemoryStream
    End Sub
    
    Public Property Get Data
        Content.Pos = 0
        Data = Content.ReadBin(ContentLength)
    End Property
    Public Property Get TextData
        Content.Pos = 0
        Data = Content.ReadText(-2)
    End Property
    Public Property Get Stream
        Set Stream = Content
    End Property
End Class

Class CASPCTLUpload
    Public postStream
    Public Post
    
    Public Fields
    Public Files
    Private sf
    
    ' Constructors
    Private Sub Class_Initialize()
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        Set postStream = sf.CreateMemoryStream
        postStream.WriteBin Request.BinaryRead(Request.TotalBytes)
        postStream.Pos = 0
        postStream.unicodeText = False
        Set Post = Server.CreateObject("newObjects.utilctls.VarDictionary")
        Post.itemsAssignmentAllowed = True
        Post.AllowUnnamedValues = True
        Post.AllowDuplicateNames = True
        Post.Missing = Empty
        Set Files = Post.CreateNew
        Set Files.Missing = Post.CreateNew
        Set Fields = Post.CreateNew
        Set Fields.Missing = Server.CreateObject("newobjects.utilctls.StringList")
        BuildUploadRequest
    End Sub
    
    ' Private mambers
    Private Function MaxNum(a,b)
        If a >= b Then MaxNum = a Else MaxNum = b
    End Function
    Private Function FindColonThroughQuotes(str,beg)
        Dim qPos, cPos
        Dim pos, qOpened
        
        pos = beg
        qOpened = False

        Do
            If qOpened Then
                qPos = MaxNum(InStr(pos,str,""""),InStr(pos,str,"'"))
                If qPos = 0 Then
                    ' In fact this is an error but we will ignore it anyway
                    ' If you want to be more prcise put here an error raising code
                    FindColonThroughQuotes = Len(str) + 1
                    Exit Function
                Else
                    pos = qPos + 1
                    qOpened = False
                End If
            Else
                qPos = MaxNum(InStr(pos,str,""""),InStr(pos,str,"'"))
                cPos = InStr(pos,str,";")
                If qPos = 0 Then
                    If cPos > 0 Then
                        FindColonThroughQuotes = cPos
                    Else
                        FindColonThroughQuotes = Len(str) + 1
                    End If
                    Exit Function
                End If
                If cPos <= qPos Then
                    If cPos > 0 Then
                        FindColonThroughQuotes = cPos
                    Else
                        FindColonThroughQuotes = Len(str) + 1
                    End If
                    Exit Function
                End If
                
                qOpened = True
                pos = qPos + 1
            End If
        Loop
        
    End Function
    Private Sub ProcessContentType(content,field)
        Dim n
        n = FindColonThroughQuotes(content,1)
        field("ContentType") = Trim(Left(content,n - 1))
    End Sub
    Private Function StripQuotes(str)
        If Left(str,1) = """" Or Left(str,1) = "'" Then
            StripQuotes = Mid(str,2,Len(str) - 2)
        Else
            StripQuotes = str
        End If
    End Function
    Private Sub ProcessContentDisposition(content,field)
        Dim n, cnt, cur, t
        cnt = content
        n = 0
        
        Do 
            n = FindColonThroughQuotes(cnt,1)
            cur = Trim(Left(cnt,n - 1))
            If cur = "" Then Exit Sub
            t = InStr(cur,"=")
            If t > 0 Then
                Select Case UCase(Left(cur,t - 1))
                    Case "NAME"
                        field("Name") = StripQuotes(Mid(cur,t+1,Len(cur) - t))
                    Case "FILENAME"
                        field("RawFileName") = StripQuotes(Mid(cur,t+1,Len(cur) - t))
                        field("FileName") = sf.GetFileName(field("RawFileName"))
                        field("FileNameExtension") = sf.GetExtensionName(field("RawFileName"))
                        field("IsFile") = True
                End Select
            End If
            cnt = Mid(cnt,n+1)
        Loop
    End Sub
    Private Sub ProcessHeader(line, field)
        Dim headName, n, headContent
        n = InStr(line,":")
        If n = 0 Then Err.Raise 2,"CASPCTLUpload", "Invalid header: " & line
        headName = Trim(Left(line, n -1))
        headContent = Mid(line,n + 1, Len(line) - n)
        Select Case UCase(headName)
            Case "CONTENT-TYPE"
                ProcessContentType headContent, field
            Case "CONTENT-DISPOSITION"
                ProcessContentDisposition headContent, field
            Case Else
                field.Add headName, headContent
        End Select
    End Sub
    Private Sub BuildUploadRequest()
        ' Determine the boundary (it is the first line)
        Dim boundary, eolSequence, eolLength, o
        boundary = postStream.ReadText(-3)
        If boundary = "" Then Err.Raise 1, "CASPCTLUpload", "Incorrect post encoding"
        postStream.CodePage = Session.CodePage
        ' Determine the end-of-line
        eolLength = postStream.Pos - Len(boundary)
        postStream.Pos = Len(boundary)
        eolSequence = postStream.ReadText(eolLength)
        postStream.textLineSeparator = eolSequence
          
        ' Loop through the fields
        Dim line ' The current line
        Dim nextLine ' The next line
        Dim field ' The current field
        Dim coll, temp
        Do
            ' Create a node holder for the element/field
            Set field = Post.CreateNew
            field.firstItemAsRoot = True
            field.Add "Value", Empty
            field("IsFile") = False
            ' Loop through the headers
            line = postStream.ReadText(-1)
            While line <> ""
                ' Read next line
                nextLine = postStream.ReadText(-1)
                ' The headers support hiphenation (not happens with IE but it is possible with other browsers)
                While Left(nextLine,1) = vbTab Or Left(nextLine,1) = " "
                    line = line & nextLine
                    nextLine = postStream.ReadText(-1)
                Wend
                ' Here we have the full line
                ProcessHeader line, field
                line = nextLine
            Wend
            ' Headers ended - the content follows
            ' Find the end
            field("ContentBegin") = postStream.Pos
            field("ContentEnd") = postStream.Find(boundary,2) - Len(boundary) - eolLength
            field("ContentLength") = field("ContentEnd") - field("ContentBegin")
            
            ' Set the value
            
            If field("IsFile") Then
                temp = postStream.Pos
                postStream.Pos = field("ContentBegin")
                ' Transfer everything to a File object
                Set o = New CASPCTLFile
                o.ContentType = field("ContentType")
                o.Name = field("Name")
                o.RawFileName = field("RawFileName")
                o.FileName = field("FileName")
                o.FileNameExtension = field("FileNameExtension")
                o.ContentLength = field("ContentLength")
                If field("ContentLength") > 0 Then o.Stream.WriteBin postStream.ReadBin(field("ContentLength"))
                o.Stream.Pos = 0
                postStream.Pos = temp
                
                ' Add it to the files collection
                If Files(o.Name).Count > 0 Then
                    Files(o.Name).Add "", o
                Else
                    Set coll = Post.CreateNew
                    coll.Add "", o
                    Files.Add o.Name, coll
                End If
            Else
                temp = postStream.Pos
                postStream.Pos = field("ContentBegin")
                field("Value") = Empty
                If field("ContentLength") > 0 Then field("Value") = postStream.ReadText(field("ContentLength"))
                postStream.Pos = temp
                ' Add it to the fields collection
                If Fields(field("Name")).Count = 0 Then
                    Set coll = Server.CreateObject("newobjects.utilctls.StringList")
                    coll.Add field("Value")
                    Fields.Add field("Name"), coll
                Else
                    Fields(field("Name")).Add field("Value")
                End If    
            End IF
            
            line = postStream.ReadText(-1)
            If line = "--" Then
                ' This is end of the upload
                Exit Do
            End If            
        Loop
        Set postStream = Nothing
    End Sub
    
End Class

Dim ASPGET, ASPPOST, ASPFILES, ASPVARS
Dim ASP_CONTENT_TYPE
ASP_CONTENT_TYPE = CStr(Request.ServerVariables("CONTENT_TYPE"))
n = Instr(ASP_CONTENT_TYPE,";")
If n > 0 Then ASP_CONTENT_TYPE = Left(ASP_CONTENT_TYPE,n - 1)

Set ASPGET = Request.QueryString
Set ASPVARS = Request.ServerVariables
If UCase(ASP_CONTENT_TYPE) = "MULTIPART/FORM-DATA" Or (ASPCTL_FileUpload And ASPVARS("REQUEST_METHOD") = "POST") Then
    ASPCTL_FileUpload = True
    Set upload_handler = New CASPCTLUpload
    Set ASPPOST = upload_handler.Fields
    Set ASPFILES = upload_handler.Files
Else
    ASPCTL_FileUpload = False
    Set ASPPOST = Request.Form
    Set ASPFILES = Server.CreateObject("newObjects.utilctls.VarDictionary") ' Empty collection
    Set ASPFILES.Missing = ASPFILES.CreateNew
End If

Dim ASPCTL_EmptyStringList
Set ASPCTL_EmptyStringList = Server.CreateObject("newobjects.utilctls.StringList")

Function ASPALL(argName)
    If ASPGET(argName).Count > 0 Then
        Set ASPALL = ASPGET(argName)
    ElseIf ASPPOST(argName).Count > 0 Then
        Set ASPALL = ASPPOST(argName)
    ElseIf ASPVARS(argName) <> "" Then
        Set ASPALL = ASPVARS(argName)
    Else
        Set ASPALL = ASPCTL_EmptyStringList
    End If
End Function

If IsObject(PostVariables) Then PostVariables.Init

If IsObject(PageCallStack) Then
    PageCallStack.Init
End If



%>