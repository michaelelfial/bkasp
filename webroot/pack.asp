<%@ Language="VBScript" CODEPAGE=1251 %>
<!-- #include file="aspctl/aspctl.asp" -->
<!-- #include file="includes/json-common.asp" -->
<!-- #include file="aspctl/xmljsonresponse.asp" -->
<%
	' Slow down code - uncomment when you test something
	'Set sleeper = Server.CreateObject("newObjects.utilctls.COMSleeper")
	'sleeper.Sleep(2000)
	'For XX = 1 To 10000000
	'Next


	' URL Syntax
	' http:// .../apps/pack.asp?$read=<pack_name>[/node1.node2.node3]
	' http:// .../apps/pack.asp?$write=<pack_name>[/node1.node2.node3]
	' <pack_name> is the name of the JSON db packet without the .json extension
	' Views can be specified at any level, but are extracted only from the starting node of the request
	' The views must be named <view_name>.html.
	' If single normal view is specified it can be done by specifying view: "<view_name>" in the node, if different views are
	' needed specify them as properties of a view object. The names can be any, but if they will take effect depends on the client.
	' The framework on the client currently supports in one form or another normal, maximized and minimized views, but normal is considered
	' a standard while the rest may or may not be used depending on the arrangement of the client apps.
	
	' Limit the allowed locations - forced constants
	
	

	Set result = New XmlPackedResponse
	Set result.Data = result.CreateDataObject
	
	Function ModulesPath()
		Dim mpath
		mpath = Application("modules")
		If Len(mpath) > 0 Then
			ModulesPath = mpath
		Else
			ModulesPath = "/modules/"
		End If
		
	End Function
	
	
	Function CreateExecInfo(op, packAndPath, operationMode)
		Dim spath, r, arr, I
		Set r = CreateDictionary
		r.Info = vbObject
		spath = Request.ServerVariables("SCRIPT_NAME")
		spath = Mid(spath, Len(VirtPath("/")))
		If Left(spath, 1) <> "/" Then spath = "/" & spath
		r("executor") = spath
		If Not IsEmpty(operationMode) And Not IsNull(operationMode) Then
			r("opmode") = NullConvertTo(vbString, operationMode)
		End If
		Dim  path, nodePath, pack
		BreakPackAndPathNoMap packAndPath, path, pack, nodePath
		If Len(path) > 0 Then r("path") = path Else r("path") = Null
		If Len(pack) > 0 Then r("packageid") = pack Else r("packageid") = Null
		If Len(nodepath) > 0 Then r("nodepath") = nodePath Else r("nodepath") = Null
		Set CreateExecInfo = r
	End Function
	' packs - the work directory, the packs/ dir under it is used for packs lookup, views/ for views. If missing the directory where pack.asp is used.
	' views - the views dir
	' pack - pack name (.json must not be specified - it is added internally)
	' nodePath - dotted context node path to start at in the pack (optional)
	Function BreakPackAndPath(packAndPath, ByRef packs, ByRef views, ByRef pack, ByRef nodePath, ByRef databases, ByRef patches) 
		Dim re, matches
		Set re = New RegExp
		re.Pattern = "(?:([a-zA-Z0-9\-_]+):)?([a-zA-Z0-9\-_]+)(?:\/([a-zA-Z0-9\-\._]+))?"
		re.Global = True
		Set matches = re.Execute(packAndPath)
		If matches.Count > 0 Then
			Set matches = matches(0)
			If Len(matches.Submatches(0)) > 0 Then
				packs = ModulesPath & Trim(matches.Submatches(0))
				if Right(packs,1) <> "/" Then packs = packs & "/"
				if Left(packs,1) <> "/" Then packs = "/" & packs
				views = MapPath(packs & "views/")
				databases = packs & "databases/"
				patches = packs & "patches/"
				packs = MapPath(packs & "packs/")
			Else
				Err.Raise 101, "Module name is missing"
				packs = Server.MapPath("packs/")
				views = Server.MapPath("views/")
				databases = "databases/"
				patches = "patches/"
			End If
			If Len(matches.Submatches(1)) > 0 Then
				pack = Trim(matches.Submatches(1))
			Else
				Err.Raise 102, "pack name is missing"
			End If
			If Len(matches.Submatches(2)) > 0 Then
				nodePath = Trim(matches.Submatches(2))
			End If
		End If
	End Function
	Function BreakPackAndPathNoMap(packAndPath, ByRef path, ByRef pack, ByRef nodePath) 
		Dim re, matches, packs
		Set re = New RegExp
		re.Pattern = "(?:([a-zA-Z0-9\-_]+):)?([a-zA-Z0-9\-_]+)(?:\/([a-zA-Z0-9\-\._]+))?"
		re.Global = True
		Set matches = re.Execute(packAndPath)
		If matches.Count > 0 Then
			Set matches = matches(0)
			If Len(matches.Submatches(0)) > 0 Then
				packs = Trim(matches.Submatches(0))
				if Right(packs,1) <> "/" Then packs = packs & "/"
				if Left(packs,1) <> "/" Then packs = "/" & packs
				path = packs
			Else
				Err.Raise 101, "Module name is missing"
				path = Empty
			End If
			If Len(matches.Submatches(1)) > 0 Then
				pack = Trim(matches.Submatches(1))
			Else
				Err.Raise 102, "pack name is missing"
			End If
			If Len(matches.Submatches(2)) > 0 Then
				nodePath = Trim(matches.Submatches(2))
			End If
		End If
	End Function
	Function ProcessRequest(op, packAndPath, result, db, operationMode)
		Dim pack, nodePath, x, tree, packs, views, databases, patches
		ProcessRequest = False
		BreakPackAndPath packAndPath, packs, views, pack, nodePath, databases, patches
		If Len(pack) > 0 Then
			Set tree = New CSQLTree
			Set x = tree.LoadFromDirectory(packs, pack)
			If Not IsEmpty(tree.DeclaredDatabaseName) And Not IsNull(tree.DeclaredDatabaseName) Then
				Set db = CustomDatabase(tree.DeclaredDatabaseName,databases,patches)
				Set SelectedDatabase = db ' Not a nice way to do such things, but all the affected code is in this file too, so we can live with it.
			End If
			If Not x Is Nothing Then
				If op = "read" Then
					Set result.Data = tree.Load(db, ASPJSON, nodePath)
					Set result.MetaData = result.CreateDataObject
					Set result.MetaData("execinfo") = CreateExecInfo(op, packAndPath, operationMode)
				ElseIf op = "write" Then
					If db.BeginTransaction Then
						Set result.Data = tree.Store(db, ASPJSON, nodePath)
						If Not db.CompleteTransaction Then
							db.CustomData("SQLTree").IsSuccessful = False
						End If
					End If
				End If
				If db.CustomData("SQLTree").IsSuccessful Then ' Do this only if everything is Ok
					result.Views.LoadViewCollectionFromDirectory views, tree.GetViewsCollection(db, nodePath)
					Set result.Lookups.Lookups = tree.GetNomenclatureCollection(db, nodePath)
				End If
				ProcessRequest = True
			End If
		End If
	End Function

	Dim execSuccess
	
	Err.Clear
	'On Error Resume Next
	Dim SelectedDatabase
	Set SelectedDatabase = Database
	If Len(ASPGET("$read")) > 0 Then
		execSuccess = ProcessRequest("read", ASPGET("$read"), result, Database, "default")
	ElseIf Len(ASPGET("$write")) > 0 Then
		'If Database.BeginTransaction Then
			execSuccess = ProcessRequest("write", ASPGET("$write"), result, Database , "default")
			'If Not Database.CompleteTransaction Then
				' Database.CustomData("SQLTree").IsSuccessful = False
			'End If
		'End If
	ElseIf Len(ASPGET("$pread")) > 0 Then
		Set SelectedDatabase = Database
		execSuccess = ProcessRequest("read", ASPGET("$pread"), result, SelectedDatabase, "private")
	ElseIf Len(ASPGET("$pwrite")) > 0 Then
		Set SelectedDatabase = Database
		'If SelectedDatabase.BeginTransaction Then
			execSuccess = ProcessRequest("write", ASPGET("$pwrite"), result, SelectedDatabase, "private")
		'	If Not SelectedDatabase.CompleteTransaction Then
		'		SelectedDatabase.CustomData("SQLTree").IsSuccessful = False
		'	End If
		'End If
	End If
	
	If Not SelectedDatabase.CustomData("SQLTree").IsSuccessful Or Not execSuccess Then
		result.Status.IsSuccessful = False
		If SelectedDatabase.ErrorMessages.Count > 0 Then
			For nMsg = 1 To SelectedDatabase.ErrorMessages.Count
				Set result.Status.ValidationErrors = result.CreateDataArray
				result.Status.ValidationErrors.Add "", SelectedDatabase.ErrorMessages.Item(nMsg)
			Next
		End If
		If SelectedDatabase.CustomData("SQLTree").ValidationErrors Then
			result.Status.Message = "Input data validation failed on the server side."
		End If
	End If
	
	On Error Goto 0
	result.SpoolOut
	
	
	'Dim result, items, item
	'Dim pack, nodePath, arr
	'Set result = New XmlPackedResponse
	'Set result.Data = result.CreateDataObject
	'
	''Set params = WrapJSONData(ASPJSON)
	'
	'
	'Set tree = New CSQLTree
	'
	'
	'
	'Set x = tree.LoadFromFile(MapPath("/apps/posts/postings.json"))
	'Set result.Data = tree.Load(Database, ASPJSON)
	'If Not Database.CustomData("SQLTree").IsSuccessful Then
	'	result.Status.IsSuccessful = False
	'	If Database.ErrorMessages.Count > 0 Then
	'		For nMsg = 1 To Database.ErrorMessages.Count
	'			Set result.Status.ValidationErrors = result.CreateDataArray
	'			result.Status.ValidationErrors.Add "", Database.ErrorMessages.Item(nMsg)
	'		Next
	'	End If
	'	If Database.CustomData("SQLTree").ValidationErrors Then
	'		result.Status.Message = "Input data validation failed on the server side."
	'	End If
	'End If
	'
	'result.SpoolOut
%>