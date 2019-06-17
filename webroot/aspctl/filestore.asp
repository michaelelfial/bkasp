<%
  ' Utilities for keeping files in the file system instead of the database
  ' The general concept is to pass a root for a store point and obtain relative (to the store root)
  ' path string refering to a file
  
    Class CFileStore
        Private pStoreRoot, pNumDirs
        Public DoNotAddTimePortion
        
        Private Sub Class_Initialize
            pStoreRoot = "" ' causes error
            pNumDirs = 100 ' default is good for about 50-100 000 files
        End Sub
        
        Public Sub Init(r,nd)
            pStoreRoot = r
            Dim sf, f
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            If Not sf.FolderExists(r) Then
                Err.Raise 1, "CFileStore", "The specified path " & pStoreRoot & " does not exist."
                Exit Sub
            End If
            pNumDirs = nd
            If pNumDirs < 1 Then pNumDirs = 1 ' Prevent wrong values
        End Sub
        ' This is generated for reference reasons it does not guarantee uniqueness!
        Public Function TimedNamePortion
            If DoNotAddTimePortion Then
                TimedNamePortion = "file"
                Exit Function
            End If
            Dim dt, s, su
            dt = Now
            Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
            TimedNamePortion = su.Sprintf("%04d-%02d-%02d-%02d-%02d",Year(dt),Month(dt),Day(dt),Hour(dt),Minute(dt),Second(dt))
        End Function
        
        
        ' sid - unique id for the store (use one from the db)
        ' To avoid language problems naming is not allowed
        Public Function StoreCFile(sid, fileCtl)
            Dim docRoot, subDir, sf, strg, strm, fileName
            StoreCFile = ""
            If fileCtl.IsUploaded Then
                Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
                docRoot = pStoreRoot
                If docRoot <> "" Then
                    If Right(docRoot,1) <> "\" Then docRoot = docRoot & "\"
                    subDir = ConvertTo(vbString, (sid Mod pNumDirs) )
                    Set strg = sf.CreateDirectory(docRoot & subDir)
                    fileName = sid & "-" & TimedNamePortion & "." & fileCtl.FileNameExtension
                    Set strm = strg.CreateStream(fileName)
                    fileCtl.Stream.CopyTo strm, fileCtl.Stream.Size
                    strm.Close
                    strg.Close
                    StoreCFile = subDir & "\" & fileName
                End If
            End If
        End Function
        Public Function StoreData(sid, data, fext)
            Dim docRoot, subDir, sf, strg, strm, fileName
            StoreData = ""
            If Not IsEmpty(data) Then
                Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
                docRoot = pStoreRoot
                If docRoot <> "" Then
                    If Right(docRoot,1) <> "\" Then docRoot = docRoot & "\"
                    subDir = ConvertTo(vbString, (sid Mod pNumDirs) )
                    Set strg = sf.CreateDirectory(docRoot & subDir)
                    fileName = sid & "-" & TimedNamePortion & "." & fext
                    Set strm = strg.CreateStream(fileName)
                    strm.WriteBin data
                    strm.Close
                    strg.Close
                    StoreData = subDir & "\" & fileName
                End If
            End If
        End Function
        Public Function StoreStream(sid, srcStrm, fext)
            Dim docRoot, subDir, sf, strg, strm, fileName
            StoreStream = ""
            If IsObject(srcStrm) Then
                Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
                docRoot = pStoreRoot
                If docRoot <> "" Then
                    If Right(docRoot,1) <> "\" Then docRoot = docRoot & "\"
                    subDir = ConvertTo(vbString, (sid Mod pNumDirs) )
                    Set strg = sf.CreateDirectory(docRoot & subDir)
                    fileName = sid & "-" & TimedNamePortion & "." & fext
                    Set strm = strg.CreateStream(fileName)
                    srcStrm.CopyTo strm, srcStrm.Size
                    strm.Close
                    strg.Close
                    StoreStream = subDir & "\" & fileName
                End If
            End If
        End Function
        
        Private Function LoadFileFromURL(sUrl,strm)
            Dim Loader, wi
            LoadFileFromURL = False
            Set Loader = Server.CreateObject("Microsoft.XMLHTTP")
            'Response.Write sUrl & "<br/>"
            'Response.End
            'Err.Raise 1,"asdada","adasA"
            Loader.Open "GET",sUrl, false
            Loader.Send Null
            If Loader.readyState = 4 Then
                strm.WriteBin Loader.responseBody
                LoadFileFromURL = True
            End If
        End Function
        Public Function FileAvailable(url,savedPath,bForce)
            Dim sf, bExists, f, strg, spath, fpath
            FileAvailable = False
            docRoot = pStoreRoot
            If Len(docRoot) = 0 Then Exit Function
            fpath = FullFilePath(savedPath)
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            bExists = sf.FileExists(fpath)
            If bForce Or Not bExists Then
                spath = sf.GetFilePath(fpath)
                If Right(spath,1) = "\" Then spath = Left(spath,Len(spath) - 1)
                Set strg = sf.CreateDirectory(spath)
                'Response.Write spath & "<br/>"
                'Response.End
                'Err.Raise 1,"asdada","adasA"
                Set f = sf.CreateFile(fpath)
                If LoadFileFromURL(url,f) Then
                    f.Close
                    FileAvailable = True
                Else
                    f.Close
                    sf.DeleteFile fpath, True
                    FileAvailable = False
                End If
            ElseIf bExists Then
                FileAvailable = True
            End If
        End Function
        
        Public Function ReadFile(savedPath) ' For reading
            Dim sf
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            Set ReadFile = sf.OpenFile(FullFilePath(savedPath),&H40)
        End Function
        Public Function WriteFile(savedPath) ' Get for writing
            Dim sf
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            Set WriteFile = sf.OpenFile(FullFilePath(savedPath))
        End Function
        Public Function ReplaceFile(savedPath) ' Recreate for writing
            Dim sf
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            Set ReplaceFile = sf.CreateFile(FullFilePath(savedPath))
        End Function
        Public Sub RemoveFile(savedPath) ' Recreate for writing
            Dim sf
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            sf.DeleteFile FullFilePath, True
        End Sub
        
        Public Function FullFilePath(savedPath)
            Dim docRoot
            docRoot = pStoreRoot
            If docRoot <> "" Then
                If Right(docRoot,1) <> "\" Then docRoot = docRoot & "\"
                FullFilePath = docRoot & savedPath
            Else
                FullFilePath = ""
            End IF
        End Function
        
        Property Get StoreRoot
            StoreRoot = pStoreRoot
        End Property
        Property Get NumDirs
            NumDirs = pNumDirs
        End Property
    End Class
    
    ' root - physical path of the root point (must exist, should be secured appropriately)
    ' numdirs - honoured only when new files are stored - disperse in how many directories
    Function Create_CFileStore(root, numdirs)
        Dim o
        Set o = New CFileStore
        o.Init root, numdirs
        Set Create_CFileStore = o
    End Function

%>