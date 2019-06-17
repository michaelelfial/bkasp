<%
	Const PathType_Absolute = "absolute" ' We are not going to use this much
	Const PathType_Relative = "relative"
	Const PathType_Rooted = "rooted"
	Const PathType_Virtual = "virtual"
	
	Class PathCalc
		Public collFactory
		Public OriginalPathList
		Public PathType
		Sub Class_Initialize
			Set collFactory = Server.CreateObject("newObjects.utilctls.VarDictionary")
			Set OriginalPathList = collFactory.CreateNewList()
		End Sub
		
		Public Function GetClone
			Dim r: Set r = new PathCalc
			Set r.collFactory = collFactory
			Set r.OriginalPathList = Me.OriginalPathList.Clone
			r.PathType = Me.PathType
			Set GetClone = r
		End Function
		Public Property Get Original
			Dim I, s: s = ""
			For I = 1 To OriginalPathList.Count
				If I = 0 Then
					Select Case PathType
						Case PathType_Absolute
							s = s & OriginalPathList(I) & ":"
						Case PathType_Relative
							s = s & OriginalPathList(I) & ""
						Case PathType_Rooted
							s = s & "\" & OriginalPathList(I)
						Case PathType_Virtual
							s = s & "\" & OriginalPathList(I)
					End Select
				Else 
					s = s & "\"
					s = s & OriginalPathList(I)
				End If
			Next
			Original = s
		End Property
		Public Property Get AsVirtualPath
			Dim I,s: s = ""
			For I = 1 To OriginalPathList.Count
				s = s & "/" + OriginalPathList(I)
			Next
			AsVirtualPath = s
		End Property
		public Function Pull
			If OriginalPathList.Count > 0 Then
				Pull = OriginalPathList.Pull
				Exit Function
			End If
			Pull = Empty
		End Function
		
		Public Sub ParseVirtualPath(pathIn) ' Assume this is a valid virtual path - always produces virtual (forced type needed to initialize anchor objects)
			ParsePath pathIn
			If PathType = PathType_Relative Or PathType = PathType_Rooted Or PathType = PathType_Virtual Then
				PathType = PathType_Virtual
			End If
		End Sub
		Public Sub ParsePath(pathIn)
			OriginalPathList.Clear
			PathType = Empty
			Dim path: path = Replace(pathIn,"/","\")
			If Len(path) > 0 Then
				Dim re: Set re = new RegExp
				Dim matches, match
				re.Pattern ="(?:^([a-zA-Z])\:)|(?:\\+(?:([^\\]+)(?=\\)))|(?:\\+((?:[^\\]+)(?=$)))|(?:^(?:([^\\]+)(?=\\|$)))"
				re.Global = True
				Set matches = re.Execute(path)
				
				For I = 0 To matches.Count - 1
					Set match = matches(i)
					If Not IsEmpty(match.Submatches(0)) Then
						If I = 0 Then PathType = PathType_Absolute
						'Response.Write "A=" & match.Submatches(0) & vbCrLf
						OriginalPathList.Add "", match.Submatches(0)
					ElseIf Not IsEmpty(match.Submatches(1)) Then
						If I = 0 Then PathType = PathType_Rooted
						'Response.Write "R=" & match.Submatches(1) & vbCrLf
						OriginalPathList.Add "", match.Submatches(1)
					ElseIf Not IsEmpty(match.Submatches(2)) Then
						If I = 0 Then PathType = PathType_Rooted
						'Response.Write "R1=" & match.Submatches(2) & vbCrLf
						OriginalPathList.Add "", match.Submatches(2)
					ElseIf Not IsEmpty(match.Submatches(3)) Then
						If I = 0 Then PathType = PathType_Relative
						'Response.Write "L=" & match.Submatches(3) & vbCrLf
						OriginalPathList.Add "", match.Submatches(3)
					Else
						' Well this is wrong actually we will see what to do later
					End If
				Next
			End If
		End Sub
		Public Sub ParseAppPath(path)
			ParsePath MapPath(path)
		End Sub
		Public Function Normalize 
		
			Dim I : I = 1
			Dim part, result: Set result = Me.GetClone
			Dim chain: Set chain = result.OriginalPathList
			While I <= chain.Count
				part = chain(I)
				If part = "." Then
					chain.Remove I
				ElseIf part = ".." Then
					If I > 1 Then
						chain.Remove I-1
						chain.Remove I-1
						I = I - 1
					Else
						Err.Raise 111, "PathCalc", "Cannot normalize the supplief path - nowhere to go back: " & Me.AsVirtualPath
					End If
				Else
					I = I + 1
				End If
			Wend
			Set Normalize = result
		End Function
		Public Function DirectConcat(p2) ' Concatenates unconditionally two paths regardless of their type
			Dim result: Set result = Me.GetClone
			Dim I
			For I = 1 To p2.OriginalPathList.Count
				result.OriginalPathList.Add "", p2.OriginalPathList(I)
			Next
			Set DirectConcat = result
		End Function
		Public Function NormalConcat(p2)
			Dim c: Set c = DirectConcat(p2)
			Set NormalConcat = c.Normalize
		End Function
		Public Function Subtract(x)
		   Dim self,start
		   set self = normalize
		   set start = x.normalize
		   dim result
		   for i = 1 to start.OriginalPathList.count
			
			if start.OriginalPathList(i) = self.OriginalPathList(1) then
				self.OriginalPathList.Remove(1)
			else
				err.raise 1 , "pathcalc", "not matching: " & start.AsVirtualPath & "   " & self.AsVirtualPath
			end if
		   next
		   set Subtract = self
		   
		End Function
		
		
		Public Function GetVirtualPath(pathCalcRoot, currentPath)
			Dim root
			Dim current
			If pathCalcRoot Is PathCalc Then
				Set root = pathCalcRoot
			Else
				Set root = new PathCalc
				root.ParsePath pathCalcRoot
			End If
			If currentPath Is PathCalc Then
				Set current = currentPath
			Else
				Set current = new PathCalc
				current.ParsePath currentPath
			End If
			Dim result
			Dim I
			Select Case PathType
				Case PathType_Rooted
					' Rooted, we need to concat it to the actual root.
					Set result = root.GetClone
					For I = 1 To OriginalPathList.Count
						result.OriginalPathList.Add "", OriginalPathList(I)
					Next
				Case PathType_Relative
					' Current path needs to be at least rooted
					Set result = root.GetClone
					
				
			End Select
		End Function
	End Class

	Class ChainFileConcatenator
		Private reDirective, collFactory
		Sub Class_Initialize
			Set collFactory = Server.CreateObject("newObjects.utilctls.VarDictionary")
			With collFactory
				.firstItemAsRoot = True
				.itemsAssignmentAllowed = True
				.enumItems = True
				.allowUnnamedValues = True
				.allowDuplicateNames = True
				.RequireSetForObjects = True
			End With
			Set reDirective = new RegExp
			reDirective.Global = True
			reDirective.Pattern = "(?:^|\n)\s*?//#using\s*?\""([^\""]+)\"".*(?=\n|$)"
		End Sub
		Function GetDirectivesFromString(s)
			Dim I, matches
			Set matches = reDirective.Execute(s)
			Set results = collFactory.CreateNewList()
			' results.Add "", "Matches=" & matches.Count
			For I = 0 To matches.Count - 1
				results.Add "", matches(I).Submatches(0)
			Next
			Set GetDirectivesFromString = results
		End Function
	End Class
	
	Set chainLoader = New ChainFileConcatenator
	Sub TraverseScriptFile(sf, rootPath, rootedPath, fileList, Ind)
		
		Dim appFilePath: Set appFilePath = rootPath.NormalConcat(rootedPath)
		Dim appDirPath: Set appDirPath = appFilePath.GetClone
		appDirPath.Pull
		
		' Response.Write Ind & "Reading [" & appFilePath.AsVirtualPath & "]" &  vbCrLf
		Dim s:s = GetTextFile(appFilePath.AsVirtualPath,0)
		Dim dirs: Set dirs = chainLoader.GetDirectivesFromString(s)
		
		' Response.Write Ind & appFilePath.AsVirtualPath & " --> " & dirs.Count & " diretives" & vbCrLf
		Dim I, fileP
		For I = 1 To dirs.Count
			Set fileP = New PathCalc
			' Response.Write " D=" & dirs(I) & vbCrLf
			fileP.ParsePath dirs(I)
			' Response.Write " DD=" & fileP.AsVirtualPath & vbCrLf
			TraverseScriptFile sf, appDirPath, fileP, fileList, Ind & "  "
		Next
		fileList(appFilePath.AsVirtualPath) = appFilePath.AsVirtualPath
		'Response.Write " RP=" & rootedPath.AsVirtualPath & vbCrLf
		'Response.Write " FP=" & appFilePath.AsVirtualPath & vbCrLf
	End Sub
	Public Sub TraverseScriptFileDownload(sf, rootPath, rootedPath, fileList, basePathOut)
		Dim appFilePath: Set appFilePath = rootPath.NormalConcat(rootedPath)
		Dim appDirPath: Set appDirPath = appFilePath.GetClone
		appDirPath.Pull
		
		' Response.Write Ind & "Reading [" & appFilePath.AsVirtualPath & "]" &  vbCrLf
		Dim s:s = GetTextFile(appFilePath.AsVirtualPath,0)
		Dim dirs: Set dirs = chainLoader.GetDirectivesFromString(s)
		
		' Response.Write Ind & appFilePath.AsVirtualPath & " --> " & dirs.Count & " diretives" & vbCrLf
		Dim I, fileP
		For I = 1 To dirs.Count
			Set fileP = New PathCalc
			' Response.Write " D=" & dirs(I) & vbCrLf
			fileP.ParsePath dirs(I)
			' Response.Write " DD=" & fileP.AsVirtualPath & vbCrLf
			TraverseScriptFileDownload sf, appDirPath, fileP, fileList, basePathOut
		Next
			
		dim fp : set fp = appFilePath.Subtract(rootedPath)
		set fp = basePathOut.Concat(fp)
		fileList(appFilePath.AsVirtualPath) = fp.AsVirtualPath
	End Sub
	Function LoadScriptRoot(root, file)
		Dim sf: Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
		' Response.ContentType = "text/plain"
		
		Dim rootPath: Set rootPath = New PathCalc
		rootPath.ParsePath root ' "/tempscripts"
		' Response.Write " rootPath=" & rootPath.AsVirtualPath & vbCrLf
		
		Dim firstFile: Set firstFile = New PathCalc
		firstFile.ParsePath file ' "/bindkraft/../bindkraft-boot.js"
		Dim fileList: Set fileList = Server.CreateObject("newObjects.utilctls.VarDictionary")
		With fileList
			.firstItemAsRoot = True
			.itemsAssignmentAllowed = True
			.enumItems = False
			.allowUnnamedValues = False
			.allowDuplicateNames = False
			.RequireSetForObjects = True
		End With
		TraverseScriptFile sf, rootPath, firstFile, fileList, "  "
		
		Set LoadScriptRoot = fileList
		
	End Function
	
	Function LoadScriptRootDownload(root, file, basePathOut)
		Dim sf: Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
		' Response.ContentType = "text/plain"
		
		Dim rootPath: Set rootPath = New PathCalc
		rootPath.ParsePath root ' "/tempscripts"
		' Response.Write " rootPath=" & rootPath.AsVirtualPath & vbCrLf
		
		Dim firstFile: Set firstFile = New PathCalc
		firstFile.ParsePath file ' "/bindkraft/../bindkraft-boot.js"
		Dim fileList: Set fileList = Server.CreateObject("newObjects.utilctls.VarDictionary")
		With fileList
			.firstItemAsRoot = True
			.itemsAssignmentAllowed = True
			.enumItems = False
			.allowUnnamedValues = False
			.allowDuplicateNames = False
			.RequireSetForObjects = True
		End With
		Dim baseOnPath: Set baseOnPath = new PathCalc
		baseOnPath.ParsePath basePathOut
		TraverseScriptFileDownload sf, rootPath, firstFile, fileList, baseOnPath
		
		Set LoadScriptRoot = fileList
		
	End Function
	
	Sub RegisterScriptRoot(root, file)
		Dim list: Set list = LoadScriptRoot(root,file)
		Dim I
		For I = 1 To list.Count
			ClientScripts.RegisterFile list.Key(I), VirtPath(list(I))
		Next
	End Sub
	Sub SpoolScriptTags(root,file,base)
		Dim list: Set list = LoadScriptRootDownload(root,file,base)
		Dim I
		For I = 1 To list.Count
			Response.Write "<scripts src=""" & list(I) & """></scripts>" & vbCrLf
		Next
	End Sub

%>