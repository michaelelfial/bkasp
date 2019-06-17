<%
	Const cEntityStateName = "state"
	Const cEntityState_Unchanged = "0"
	Const cEntityState_New = "1"
	Const cEntityState_Updated = "2"
	Const cEntityState_Deleted = "3"
	Const cEntityState_Undeleted = "4" ' Not actually used on the server side (for naw anyway)
	
	' Default behavour constnts
	Const cBehaviour_SkipMissingOperations = False ' If true no error is issued when data cannot be processed due to missing insert, update or delete operation

	' Helper functions
	Function CSQLTree_IsJSONArray(o)
		CSQLTree_IsJSONArray = False
		If IsArray(o) Then
			CSQLTree_IsJSONArray = True
		ElseIf IsObject(o) Then
			If o Is Nothing Then
				Exit Function
			End If
			If IsObject(o.Info) Then
				If Not o.Info.Type Then
					CSQLTree_IsJSONArray = True
				End If
			Else 
				If o.Info = vbArray Then
					CSQLTree_IsJSONArray = True
				End If
			End If
		End If
	End Function
	Function CSQLTree_IsJSONObject(o)
		CSQLTree_IsJSONObject = False
		If IsObject(o) Then
			If o Is Nothing Then
				Exit Function
			End If
			If IsObject(o.Info) Then
				If o.Info.Type Then
					CSQLTree_IsJSONObject = True
				End If
			Else 
				If o.Info <> vbArray Then
					CSQLTree_IsJSONObject = True
				End If
			End If
		End If
	End Function
	' In this case node is the raw JSON node and not a node class
	Function SQLTree_CheckAccess(db, accessNode, bWrite)
		Dim func, args, funcName, b
		SQLTree_CheckAccess = False
		if CSQLTree_IsJSONObject(accessNode) Then
			funcName = accessNode("func")
		Else
			SQLTree_CheckAccess = True
			Exit Function
		End If
		If IsNull(funcName) Then Exit Function
		If Len(funcName) = 0 Then Exit Function
		If IsObject(SQLEntryCheckAccess(funcName)) Then
			Set func = SQLEntryCheckAccess(funcName)
			If CSQLTree_IsJSONObject(accessNode("args")) Then
				Set args = accessNode("args")
			Else
				Set args = CreateDictionary ' No arguments
			End If
			b = func(db, args, bWrite)
			SQLTree_CheckAccess = b
			If Not b Then
				db.AddError "Access forbidden."
			End If
		Else
			db.AddError funcName & " not found in the CheckAccess register."
			SQLTree_CheckAccess = False
		End If
	End Function
	
	' Helper for quick exec not needed anymore
	Function PackExecute(op, packAndPath, json, db, overrideState)
		Dim arr, pack, nodePath, x, tree, result
		Set result = Nothing
		
			arr = Split(packAndPath, "/")
			If IsArray(arr) Then
				If UBound(arr) > 0 Then nodePath = Trim(arr(1))
				pack = Trim(arr(0))
				If Len(pack) > 0 Then
					Set tree = New CSQLTree
					Set x = tree.LoadFromDirectory(MapPath("/apps/packs/"), pack)
					If Not x Is Nothing Then
						If op = "read" Then
							Set result = tree.Load(db, json, nodePath)
						ElseIf op = "write" Then
							Set result = tree.StoreEx(db, json, nodePath, overrideState)
						End If
						If Not db.CustomData("SQLTree").IsSuccessful Then ' Indicate it easy if something is wrong
							Set result = Nothing
							db.InvalidateTransaction
						End If
					End If
				End If
			End If
		
		Set PackExecute = result
	End Function
	
	' SQL Trees
	Class CSQLTree
		Public Property Get ClassType
			ClassType = "CSQLTree"
		End Property
		Public TreeDef ' Contains the loaded definition of the SQLTree
		Public RootNode
		Public DeclaredDatabaseName
		Sub Class_Initialize
			Set RootNode = Nothing
		End Sub
		' Execution of loaded definitions
		Public Function Load(db, params, route)
			Dim stack, startNode
			Set db.CustomData("SQLTree") = New CSQLTreeStatus
			Set stack = CreateStack
			Set startNode = NavigateRoute(db, route, False)
			If startNode Is Nothing Then
				db.CustomData("SQLTree").IsSuccessful = False
				Set Load = Nothing
				Exit Function
			End If
			Err.Clear
			'On Error Resume Next
			Set Load = startNode.Read(db,params,stack,Empty)
			If Err.Number <> 0 Then
				db.CustomData("SQLTree").IsSuccessful = False
				db.AddError Err.Description
				Set Load = Nothing
			End If
		End Function
		Public Function Store(db, data, route)
			Set Store = StoreEx(db, data, route, Empty)
		End Function
		Public Function StoreEx(db, data, route, overrideState)
			Dim stack, startNode
			Set db.CustomData("SQLTree") = New CSQLTreeStatus
			Set stack = CreateStack
			Set startNode = NavigateRoute(db, route, True)
			If startNode Is Nothing Then
				db.CustomData("SQLTree").IsSuccessful = False
				Set StoreEx = Nothing
				Exit Function
			End If
			Err.Clear
			On Error Resume Next
			Set StoreEx = startNode.Write(db,data,stack,overrideState)
			If Err.Number <> 0 Then
				db.CustomData("SQLTree").IsSuccessful = False
				db.AddError Err.Description
				Set StoreEx = Nothing
			End If
		End Function
		Public Function GetViewsCollection(db, route)
			Dim startNode
			Set GetViewsCollection = CreateDictionary
			Set startNode = NavigateRoute(db, route, False)
			If Not startNode Is Nothing Then
				Set GetViewsCollection = startNode.Views
			End If
		End Function
		Public Function GetNomenclatureCollection(db, route)
			Dim startNode
			Set GetNomenclatureCollection = CreateDictionary
			Set startNode = NavigateRoute(db,route,False)
			If Not startNode Is Nothing Then
				Set GetNomenclatureCollection = startNode.LoadNomenclatures(db)
			End If
		End Function
		Private Function CheckAccess(db, node, bWrite)
			If CSQLTree_IsJSONObject(node.Access) Then
				CheckAccess = SQLTree_CheckAccess(db, node.Access, bWrite)
			Else
				CheckAccess = True
			End If
		End Function
		' Navigation
		Private Function NavigateRoute(db, route, bWrite)
			Dim node, arr, I, k
			Set node = RootNode
			If Not CheckAccess(db, node, bWrite) Then
				Set NavigateRoute = Nothing
				Exit Function
			End If
			If IsNull(route) Or IsEmpty(route) Then
				Set NavigateRoute = node
				Exit Function
			End If
			arr = Split(route,".")
			If IsArray(arr) Then
				For I = LBound(arr) To UBound(arr)
					k = arr(I)
					If Len(k) > 0 Then
						If node.Nodes.KeyExists(k) And IsObject(node.Nodes(k)) Then
							Set node = node.Nodes(k)
							If Not CheckAccess(db, node, bWrite) Then
								Set NavigateRoute = Nothing
								Exit Function
							End If
						Else
							db.AddError "Node " & k & " not found in route " & route
							Set NavigateRoute = Nothing
							Exit Function
						End If
					Else
						db.AddError "Syntax error in the requested route " & route
						Set NavigateRoute = Nothing
						Exit Function
					End If
				Next
			End If
			Set NavigateRoute = node
		End Function
		
		Function LoadFromDirectory(sdir,sfile)
			Dim xdir
			Set LoadFromDirectory = Nothing
			xdir = sdir
			If Right(xdir,1) <> "\" Then xdir = xdir & "\"
			If InStr(sfile, "\") > 0 Or InStr(sfile, "/") Or InStr(sfile, ".") > 0 Then
				Exit Function
			End If
			Set LoadFromDirectory = LoadFromFile(xdir & sfile & ".json")
		End Function
		
		' Loading definitions
		Function LoadFromFile(sfile)
			Dim sf, treeDef
			Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
			Dim file, s
			Set file = sf.OpenFile(sfile,&H20)
			file.codepage = 65001
			file.maxTextBuff = 10048576 
			s = file.ReadText(-2)
			file.Close
			Set treeDef = JSON.Parse(s)
			Set RootNode = ConstructTreeNodes(treeDef)
			if Not IsEmpty(treeDef("database")) And Not IsNull(treeDef("database")) Then 
				DeclaredDatabaseName = ConvertTo(vbString, treeDef("database"))
			End If
			Set LoadFromFile = RootNode
		End Function
		Private Function ConstructStatement(s, kind)
			Dim o
			Set o = Nothing
			If IsObject(s) Then
				If Not IsEmpty(s("sql")) And Not IsNull(s("sql")) Then
					Set o = New CSQLTreeStatement
					o.SQL = s("sql")
					o.Kind = kind
				ElseIf IsObject(s("data")) Then
					Set o = New CSQLInlineData
					Set o.Data = s("data")
				ElseIf Not IsEmpty(s("jsonfile")) Then
					Set o = New CSQLJsonFile
					o.Data = s("jsonfile")
				End If
			End If
			Set ConstructStatement = o
		End Function
		Private Function ParseNodeProc(str) ' Some parameters will get here
			Dim re, matches, match, o
			Set ParseNodeProc = Nothing
			Set re = New RegExp
			re.Global = True
			' 0 - func name, 1 - func args (unparsed)
			re.Pattern = "^(?:([a-zA-Z0-9]+)\(([^\}\)]*)\))$"
			Set matches = re.Execute(str)
			If matches.Count > 0 Then
				Set match = matches(0)
				if Len(match.Submatches(0)) > 0 Then
					Set o = New CSQLNodeProc
					o.Func = match.Submatches(0)
					o.Args = match.Submatches(1)
					Set ParseNodeProc = o
				End If
			End If
		End Function
		Private Function ReadNodeProcedures(node, procKind)
			Set ReadNodeProcedures = Nothing
			Dim result, proc, I
			Set result = CreateList
			result.Info = vbArray
			if CSQLTree_IsJSONArray(node(procKind)) Then
				For I = 1 To node(procKind).Count
					Set proc = ParseNodeProc(ConvertTo(vbString, node(procKind)(I)))
					If Not proc Is Nothing Then
						result.Add "", proc
					End If
				Next
			ElseIf VarType(node(procKind)) = vbString Then
				if Len(node(procKind)) > 0 Then
					Set proc = ParseNodeProc(ConvertTo(vbString, node(procKind)))
					If Not proc Is Nothing Then
						result.Add "", proc
					End If
				End If
			End If
			If result.Count > 0 Then
				Set ReadNodeProcedures = result
			End If
		End Function
		Private Function ConstructTreeNodes(node) ' Terminology: node - in the json, treenode - in the object tree
			Dim n, o, I, oo, stmt
			Set n = New CSQLTreeNode
			Set stmt = ConstructStatement(node("select"), "select")
			If stmt Is Nothing Then Set n.sqlSelect = Nothing Else Set n.sqlSelect = stmt
			Set stmt = ConstructStatement(node("insert"), "insert")
			If stmt Is Nothing Then Set n.sqlInsert = Nothing Else Set n.sqlInsert = stmt
			Set stmt = ConstructStatement(node("update"), "update")
			If stmt Is Nothing Then Set n.sqlUpdate = Nothing Else Set n.sqlUpdate = stmt
			Set stmt = ConstructStatement(node("delete"), "delete")
			If stmt Is Nothing Then Set n.sqlDelete = Nothing Else Set n.sqlDelete = stmt
			If CSQLTree_IsJSONObject(node("access")) Then
				Set n.Access = node("access")
			Else
				Set n.Access = Nothing
			End If
			n.IsMultiple = ConvertTo(vbBoolean, node("ismultiple"))
			If IsObject(node("subnodes")) Then
				Set o = node("subnodes")
				For I = 1 To o.Count
					If IsObject(o(I)) Then
						Set oo = ConstructTreeNodes(o(I))
						n.Nodes.Add o.Key(I), oo
					End If
				Next
			End If
			If IsObject(node("views")) Then
				Set o = node("views")
				For I = 1 To o.Count
					If VarType(o(I)) = vbString Then
						n.Views.Add o.Key(I), o(I)
					End If
				Next
			ElseIf Not IsEmpty(node("view")) And Not IsNull(node("view")) Then
				n.Views.Add "normal", ConvertTo(vbString,node("view"))
			End If
			If CSQLTree_IsJSONObject(node("nomenclatures")) Then
				Set o = node("nomenclatures")
				For I = 1 To o.Count
					If CSQLTree_IsJSONObject(o(I)) Then
						Set n.Nomenclatures(o.Key(I)) = ConstructStatement(o(I), "select")
					End If
				Next
			End If
			Set n.PreRead = ReadNodeProcedures(node, "preread")
			Set n.PreWrite = ReadNodeProcedures(node, "prewrite")
			Set n.PostRead = ReadNodeProcedures(node, "postread")
			Set n.PostWrite = ReadNodeProcedures(node, "postwrite")
			' If SQLTree_IsJSONArray(node("preread")) T
			Set ConstructTreeNodes = n
		End Function
	End Class
	
	Class CSQLTreeStatus
		Public Property Get ClassType
			ClassType = "CSQLTreeStatus"
		End Property
		Public IsSuccessful
		Public ValidationErrors
		Sub Class_Initialize
			IsSuccessful = True
		End Sub
	End Class
	
	' Each func has the prototype:
	' Function FName(database: SQLite-Lib, args: Dictionary, byRef IsLiteralResult: Boolean)
	' 	The function returns the result and if it is for literal replacement also must set IsLiteralResult to True
	Public CSQLEntry_Funcs 
	Set CSQLEntry_Funcs = CreateDictionary
	Sub RegisterSQLFunc(strName, strFunction)
		Set CSQLEntry_Funcs(strName) = GetRef(strFunction)
	End Sub
	' Each Func has the prototype:
	' Function FName (database: SQLite-Lib, args: Dictionary, valueToValidate: variant)
	' the function should return True or False depending on whether the value is valid or not
	Public SQLEntryValidator_Funcs
	Set SQLEntryValidator_Funcs = CreateDictionary
	Sub RegisterSQLValidator(strName, strFunction)
		Set SQLEntryValidator_Funcs(strName) = GetRef(strFunction)
	End Sub
	
	' Each Func has the prototype:
	' Function FName(database: SQLite-Lib, args: Dictionary, current: current_record(s), stack: Parent_Stack, bSingleResult: Boolean, state: State_Value)
	' The current_record(s) is an array (JSON array - list actually) on Read and only a single record on write.
	' The Func can add records on read or modify the existing and can modify the record on write
	' the function should return True for success or if the outcome does not matter and False to cancel the processing
	Public CSQLNodeProc_Funcs
	Set CSQLNodeProc_Funcs = CreateDictionary
	Sub RegisterSQLNodeProc(strName, strFunction)
		Set CSQLNodeProc_Funcs(strName) = GetRef(strFunction)
	End Sub
	
	' The built-in variables are registered by simply adding them to the dictionaries in which they should be visible.
	Public CSQLEntry_BuiltIn
	Set CSQLEntry_BuiltIn = CreateDictionary
	Public CSQLEntryValidator_BuiltIn
	Set CSQLEntryValidator_BuiltIn = CreateDictionary
	Public CSQLNodeProc_BuiltIn
	Set CSQLNodeProc_BuiltIn = CreateDictionary
	' Helper for registration in all dictionaries
	Sub CSQLProc_RegisterBuiltInVariable(varName, varValue)
		If Not IsObject(varValue) Then
			CSQLEntry_BuiltIn(varName) = varValue
			CSQLEntryValidator_BuiltIn(varName) = varValue
			CSQLNodeProc_BuiltIn(varName) = varValue
		Else
			Set CSQLEntry_BuiltIn(varName) = varValue
			Set CSQLEntryValidator_BuiltIn(varName) = varValue
			Set CSQLNodeProc_BuiltIn(varName) = varValue
		End If
	End Sub
	
	
	' A registry for access to node check functions
	' The prototype of the function is
	' Function(database: SQLite-Lib, args: Dictionary, IsWrite: Boolean): Boolean
	' The function should output error message(s) into the database
	' The args is from the package "access": { func: "funcName", args: {}}
	Public SQLEntryCheckAccess
	Set SQLEntryCheckAccess = CreateDictionary
	Sub RegisterSQLCheckAccess(strName, strFunction)
		Set SQLEntryCheckAccess(strName) = GetRef(strFunction)
	End Sub
	
	Class CSQLEntry ' Describes an SQL entry we need to process - an embedded escape sequence in the SQL that is replaced with parameter or a literal result.
		Public Property Get ClassType
			ClassType = "CSQLEntry"
		End Property
		Public Func, Args, params, Id ' The Id is the name of the potential parameter for the statement. It may or may not be used dependint on the kind of result (literal or parameter)
		Public IsLiteralResult ' After execution (for sure) marks the result is injectable text and not a bound parameter
		Public Result ' The result of the function
		Property Get Key
			Key = Func & Args
		End Property
		Private Function GetFromParentStack(argName, stack)
			Dim I, entry
			GetFromParentStack = Null
			If IsObject(stack) Then
				For I = stack.Count To 1 Step -1
					If IsObject(stack(I)) Then
						Set entry = stack(I)
						If entry.KeyExists(argName) Then
							GetFromParentStack = entry(argName)
							Exit Function
						End If
					End If
				Next
			End If
		End Function
		Private Function SmartFetch(argName, current, stack)
			SmartFetch = Null
			If IsObject(current) Then
				If current.KeyExists(argName) Then
					SmartFetch = current(argName)
					Exit Function
				Else
					SmartFetch = GetFromParentStack(argName, stack)
				End If
			Else
				SmartFetch = GetFromParentStack(argName, stack)
			End If
		End Function
		Private Function BuiltInFetch(argName)
			BuiltInFetch = Null
			If IsObject(CSQLEntry_BuiltIn) Then
				BuiltInFetch = CSQLEntry_BuiltIn(argName)
			End If
		End Function
		
		Function ParseArgs(db, current, stack)
			Dim re, matches, I, match, s, modifier, argName
			Set params = CreateList
			Set re = New RegExp
			re.Global = True
			' 'string literal', number, ([modifier], identifier)
			' modifier: none-smart fetch, @from current row, ? - from query string, ^ - from post, $ - built in, #get, post or anything, * - current_or_parent, ~ - from parent
			' @{func('sdfsdf',3424,?sdf,^sdfsdf)}
			re.Pattern = "(?:(?:^\s*)|(?:\s*\,\s*))(?:(\'(?:[^\']|(?:\'\'))*\')|([+-]?[0-9]+(?:\.[0-9]+)?)|([\@\$\#\^\?\~]?)([A-Za-z][0-9a-zA-Z_]*))(?=(?:\s*\,)|$)"
			Set matches = re.Execute(Args)
			For I = 0 To matches.Count - 1
				Set match = matches(I)
				If Len(match.Submatches(0)) > 0 Then ' String literal
					s = match.Submatches(0)
					s = Mid(s,2,Len(s) - 2)
					params.Add "", Replace(s, "''","'")
				ElseIf Len(match.Submatches(1)) > 0 Then ' Number
					s = match.Submatches(1)
					if InStr(s,".") > 0 Then
						params.Add "", NullConvertTo(vbDouble,s)
					Else
						params.Add "", NullConvertTo(vbLong,s)
					End If
				ElseIf Len(match.Submatches(3)) > 0 Then ' Identifier
					argName = Trim(match.Submatches(3))
					if Len(match.Submatches(2)) > 0 Then
						modifier = Trim(match.Submatches(2))
						Select Case modifier
							Case "@"
								If IsObject(Current) Then
									params.Add "", Current(argName)
								Else
									params.Add "", Null
								End If
							Case "?"
								params.Add "", db.XASPGET(argName)
							Case "^"
								params.Add "", db.XASPPOST(argName)
							Case "$"
								params.Add "", BuiltInFetch(argName)
							Case "*"
								params.Add "", SmartFetch(argName, current, stack)
							Case "~"
								params.Add "", GetFromParentStack(argName, stack)
							Case "#"
								params.Add "", db.XASPALL(argName)
							Case Else
								params.Add "", Null ' May be we should rise an error here
						End Select
					Else ' Default case
						params.Add "", SmartFetch(argName, current, stack)
					End If
				End If
			Next
		End Function
		Public Function Execute(db) ' Executes the entry after it has been created and ParseArgs called. This is kept separate in order to give us chance to separate the error sources
			Dim proc, errdesc
			On Error Resume Next
			If IsObject(CSQLEntry_Funcs(Func)) Then
				Set proc = CSQLEntry_Funcs(Func)
				Err.Clear
				Result = proc(db, params, IsLiteralResult)
				If Err.Number <> 0 Then
					errdesc = Err.Description
					On Error Goto 0
					Err.Raise 1002, "CSQLEntry", "Error in func " & Func & ": " & errdesc
				End If
			Else
				On Error Goto 0
				Err.Raise 1001, "CSQLEntry", "Func " & Func & " not found"
			End If
		End Function
	End Class
	
	' A registry for output processing funcs
	' The prototype of the function is
	' Function(database: SQLite-Lib, args: Dictionary, fieldname: string/null, record: Dictionary): Boolean
	' The fieldname is specified in [] before the func name and can be * or a field name. If it is * - null is sent to the func
	' The function should output error message(s) into the database
	' The function should return false if critical error occurs.
	' The function does its work by updating the record - note that records can be heterogenous and funcs for such records should take measures to recognize them.
	Public SQLOutputProc
	Set SQLOutputProc = CreateDictionary
	Sub RegisterSQLOutputProc(strName, strFunction)
		Set SQLOutputProc(strName) = GetRef(strFunction)
	End Sub
	
	' Function(
	Class CSQLOutputProc
		Public Property Get ClassType
			ClassType = "CSQLOutputProc"
		End Property
		Public Func, Args, params, Raw
		' Source returns any inline text for the SQL
		Public Property Get Source
			If Raw = "*" Or Raw = "" Then
				Source = ""
			Else
				Source = "[" & Raw & "]"
			End If
		End Property
		' CSQLOutputProc
		Private Function GetFromParentStack(argName, stack)
			Dim I, entry
			GetFromParentStack = Null
			If IsObject(stack) Then
				For I = stack.Count To 1 Step -1
					If IsObject(stack(I)) Then
						Set entry = stack(I)
						If entry.KeyExists(argName) Then
							GetFromParentStack = entry(argName)
							Exit Function
						End If
					End If
				Next
			End If
		End Function
		Private Function SmartFetch(argName, current, stack)
			SmartFetch = Null
			If IsObject(current) Then
				If current.KeyExists(argName) Then
					SmartFetch = current(argName)
					Exit Function
				Else
					SmartFetch = GetFromParentStack(argName, stack)
				End If
			Else
				SmartFetch = GetFromParentStack(argName, stack)
			End If
		End Function
		Private Function BuiltInFetch(argName)
			BuiltInFetch = Null
			If IsObject(CSQLEntry_BuiltIn) Then
				BuiltInFetch = CSQLEntry_BuiltIn(argName)
			End If
		End Function
		Function ParseArgs(db, current, stack)
			Dim re, matches, I, match, s, modifier, argName
			Set params = CreateList
			Set re = New RegExp
			re.Global = True
			' 'string literal', number, ([modifier], identifier)
			' modifier: none-smart fetch, @from current row, ? - from query string, ^ - from post, $ - built in, #get, post or anything, * - current_or_parent, ~ - from parent
			' @{func('sdfsdf',3424,?sdf,^sdfsdf)}
			re.Pattern = "(?:(?:^\s*)|(?:\s*\,\s*))(?:(\'(?:[^\']|(?:\'\'))*\')|([+-]?[0-9]+(?:\.[0-9]+)?)|([\@\$\#\^\?\~]?)([A-Za-z][0-9a-zA-Z_]*))(?=(?:\s*\,)|$)"
			Set matches = re.Execute(Args)
			For I = 0 To matches.Count - 1
				Set match = matches(I)
				If Len(match.Submatches(0)) > 0 Then ' String literal
					s = match.Submatches(0)
					s = Mid(s,2,Len(s) - 2)
					params.Add "", Replace(s, "''","'")
				ElseIf Len(match.Submatches(1)) > 0 Then ' Number
					s = match.Submatches(1)
					if InStr(s,".") > 0 Then
						params.Add "", NullConvertTo(vbDouble,s)
					Else
						params.Add "", NullConvertTo(vbLong,s)
					End If
				ElseIf Len(match.Submatches(3)) > 0 Then ' Identifier
					argName = Trim(match.Submatches(3))
					if Len(match.Submatches(2)) > 0 Then
						modifier = Trim(match.Submatches(2))
						Select Case modifier
							Case "@"
								If IsObject(Current) Then
									params.Add "", Current(argName)
								Else
									params.Add "", Null
								End If
							Case "?"
								params.Add "", db.XASPGET(argName)
							Case "^"
								params.Add "", db.XASPPOST(argName)
							Case "$"
								params.Add "", BuiltInFetch(argName)
							Case "*"
								params.Add "", SmartFetch(argName, current, stack)
							Case "~"
								params.Add "", GetFromParentStack(argName, stack)
							Case "#"
								params.Add "", db.XASPALL(argName)
							Case Else
								params.Add "", Null ' May be we should rise an error here
						End Select
					Else ' Default case
						params.Add "", SmartFetch(argName, current, stack)
					End If
				End If
			Next
		End Function
		Public Function Execute(db, current, stack) ' Executes the entry after it has been created and ParseArgs called. This is kept separate in order to give us chance to separate the error sources
			Dim proc, errdesc, Result
			Result = False
			On Error Resume Next
			If IsObject(SQLOutputProc(Func)) Then
				Set proc = SQLOutputProc(Func)
				Err.Clear
				ParseArgs db, current, stack
				' Pass the 1) db, 2) the params collection, 3) The field name (if not *)
				If Raw <> "" And Raw <> "*" Then
					Result = proc(db, params, Raw, current)
				Else
					Result = proc(db, params, Null, current)
				End If
				
				If Err.Number <> 0 Then
					errdesc = Err.Description
					On Error Goto 0
					Err.Raise 3002, "CSQLOutputProc", "Error in func " & Func & ": " & errdesc
				End If
			Else
				On Error Goto 0
				Err.Raise 3001, "CSQLOutputProc", "Output Func " & Func & " not found"
			End If
			Execute = Result
		End Function
		
	End Class
	
	Class CSQLNodeProc
		Public Property Get ClassType
			ClassType = "CSQLNodeProc"
		End Property
		' Args - unparsed, params collection parsed
		Public Func, Args, params
		Public Result
		Sub Class_Initialize
			Set params = CreateList
		End Sub
		' Because of possible future differences in logic these methods are copied into all classes.
		Private Function GetFromParentStack(argName, stack)
			Dim I, entry
			GetFromParentStack = Null
			If IsObject(stack) Then
				For I = stack.Count To 1 Step -1
					If IsObject(stack(I)) Then
						Set entry = stack(I)
						If entry.KeyExists(argName) Then
							GetFromParentStack = entry(argName)
							Exit Function
						End If
					End If
				Next
			End If
		End Function
		Private Function SmartFetch(argName, current, stack)
			SmartFetch = Null
			If IsObject(current) Then
				If current.KeyExists(argName) Then
					SmartFetch = current(argName)
					Exit Function
				Else
					SmartFetch = GetFromParentStack(argName, stack)
				End If
			Else
				SmartFetch = GetFromParentStack(argName, stack)
			End If
		End Function
		Private Function BuiltInFetch(argName)
			BuiltInFetch = Null
			If IsObject(CSQLNodeProc_BuiltIn) Then
				BuiltInFetch = CSQLNodeProc_BuiltIn(argName)
			End If
		End Function
		Sub ParseArgs(db, current, stack)
			Dim re, matches, match, I
			params.Clear ' Every time start anew
			If Len(Args) > 0 Then
				Set re = New RegExp
				' 0 - string, 1 - number, 2- modifier , 3 - identifier
				' modifier: none - validation constants, $ - built in
				re.Pattern = "(?:(?:^\s*)|(?:\s*\,\s*))(?:(?:\'([^\']|(?:\'\'))*\')|([+-]?[0-9]+(?:\.[0-9]+)?)|([\@\$\#\^\?\~]?)([A-Za-z][0-9a-zA-Z_]*))(?=(?:\s*\,)|$)"
				re.Global = True
				Set matches = re.Execute(Args)
				For I = 0 To matches.Count - 1
					Set match = matches(I)
					If Len(match.Submatches(0)) > 0 Then ' String literal
						s = match.Submatches(0)
						s = Mid(s,2,Len(s) - 2)
						params.Add "", Replace(s, "''","'")
					ElseIf Len(match.Submatches(1)) > 0 Then ' Number
						s = match.Submatches(1)
						if InStr(s,".") > 0 Then
							params.Add "", NullConvertTo(vbDouble,s)
						Else
							params.Add "", NullConvertTo(vbLong,s)
						End If
					ElseIf Len(match.Submatches(3)) > 0 Then ' Identifier
						argName = Trim(match.Submatches(3))
						if Len(match.Submatches(2)) > 0 Then
							modifier = Trim(match.Submatches(2))
							Select Case modifier
								Case "@"
									If IsObject(current) Then
										params.Add "", current(argName)
									Else
										params.Add "", Null
									End If
								Case "?"
									params.Add "", db.XASPGET(argName)
								Case "^"
									params.Add "", db.XASPPOST(argName)
								Case "$"
									params.Add "", BuiltInFetch(argName)
								Case "*"
									params.Add "", SmartFetch(argName, current, stack)
								Case "~"
									params.Add "", GetFromParentStack(argName, stack)
								Case "#"
									params.Add "", db.XASPALL(argName)
								Case Else
									params.Add "", Null ' May be we should rise an error here
							End Select
						Else ' Default case
							params.Add "", SmartFetch(argName, current, stack)
						End If
					End If
				Next
			End If
		End Sub
		Function Execute(db, data, rows, stack, bSingleResult, state)
			Dim proc, e
			Execute = False
			ParseArgs db, data, stack
			On Error Resume Next
			If IsObject(CSQLNodeProc_Funcs(Func)) Then
				Set proc = CSQLNodeProc_Funcs(Func)
				Err.Clear
				Result = proc(db, params, rows, stack, bSingleResult, state)
				If Err.Number <> 0 Then
					e = Err.Description
					On Error Goto 0
					Err.Raise 1012, "CSQLNodeProc", "Error in node func " & Func & ": " & e
				Else
					Execute = Result
				End If
			Else
				On Error Goto 0
				Err.Raise 1011, "CSQLNodeProc", "Node func " & Func & " not found"
			End If
		End Function
	End Class
	
	
	' Validators
	Class CSQLEntryValidator
		Public Property Get ClassType
			ClassType = "CSQLEntryValidator"
		End Property
		' Args - unparsed, params collection parsed
		Public Func, Args, params
		Public Result, SkipTheRest ' Skip the rest is available as ByRef 4-th arg and enables a validator to prevent the execution of the rest of the validators.
		Sub Class_Initialize
			Set params = CreateList
		End Sub
		Private Function GetFromParentStack(argName, stack)
			Dim I, entry
			GetFromParentStack = Null
			If IsObject(stack) Then
				For I = stack.Count To 1 Step -1
					If IsObject(stack(I)) Then
						Set entry = stack(I)
						If entry.KeyExists(argName) Then
							GetFromParentStack = entry(argName)
							Exit Function
						End If
					End If
				Next
			End If
		End Function
		Private Function SmartFetch(argName, current, stack)
			SmartFetch = Null
			If IsObject(current) Then
				If current.KeyExists(argName) Then
					SmartFetch = current(argName)
					Exit Function
				Else
					SmartFetch = GetFromParentStack(argName, stack)
				End If
			Else
				SmartFetch = GetFromParentStack(argName, stack)
			End If
		End Function
		Private Function BuiltInFetch(argName)
			BuiltInFetch = Null
			If IsObject(CSQLEntryValidator_BuiltIn) Then
				BuiltInFetch = CSQLEntryValidator_BuiltIn(argName)
			End If
		End Function
		Sub ParseArgs(db, current, stack)
			Dim re, matches, match, I
			params.Clear ' Every time start anew
			If Len(Args) > 0 Then
				Set re = New RegExp
				' 0 - string, 1 - number, 2- modifier , 3 - identifier
				' modifier: none - validation constants, $ - built in
				re.Pattern = "(?:(?:^\s*)|(?:\s*\,\s*))(?:(?:\'([^\']|(?:\'\'))*\')|([+-]?[0-9]+(?:\.[0-9]+)?)|([\@\$\#\^\?\~]?)([A-Za-z][0-9a-zA-Z_]*))(?=(?:\s*\,)|$)"
				re.Global = True
				Set matches = re.Execute(Args)
				For I = 0 To matches.Count - 1
					Set match = matches(I)
					If Len(match.Submatches(0)) > 0 Then ' String literal
						s = match.Submatches(0)
						s = Mid(s,2,Len(s) - 2)
						params.Add "", Replace(s, "''","'")
					ElseIf Len(match.Submatches(1)) > 0 Then ' Number
						s = match.Submatches(1)
						if InStr(s,".") > 0 Then
							params.Add "", NullConvertTo(vbDouble,s)
						Else
							params.Add "", NullConvertTo(vbLong,s)
						End If
					ElseIf Len(match.Submatches(3)) > 0 Then ' Identifier
						argName = Trim(match.Submatches(3))
						if Len(match.Submatches(2)) > 0 Then
							modifier = Trim(match.Submatches(2))
							Select Case modifier
								Case "@"
									If IsObject(Current) Then
										params.Add "", Current(argName)
									Else
										params.Add "", Null
									End If
								Case "?"
									params.Add "", db.XASPGET(argName)
								Case "^"
									params.Add "", db.XASPPOST(argName)
								Case "$"
									params.Add "", BuiltInFetch(argName)
								Case "*"
									params.Add "", SmartFetch(argName, current, stack)
								Case "~"
									params.Add "", GetFromParentStack(argName, stack)
								Case "#"
									params.Add "", db.XASPALL(argName)
								Case Else
									params.Add "", Null ' May be we should rise an error here
							End Select
						Else ' Default case
							params.Add "", SmartFetch(argName, current, stack)
						End If
					End If
				Next
			End If
		End Sub
		Function Execute(db, row, stack, bSingleResult, v)
			Dim proc
			ParseArgs db, row, stack
			On Error Resume Next
			If IsObject(SQLEntryValidator_Funcs(Func)) Then
				Set proc = SQLEntryValidator_Funcs(Func)
				Err.Clear
				Result = proc(db, params, v, SkipTheRest)
				If Err.Number <> 0 Then
					On Error Goto 0
					Err.Raise 1012, "CSQLEntryValidator", "Error in validator func " & Func & ": " & Err.Description
				End If
			Else
				On Error Goto 0
				Err.Raise 1011, "CSQLEntryValidator", "Validator func " & Func & " not found"
			End If
		End Function
	End Class
	' This class is used in the parsed statement list to hold information about the expressions found there
	Class CSQLEntryPlaceHolder
		Public Property Get ClassType
			ClassType = "CSQLEntryPlaceHolder"
		End Property
		Public Entry ' As CSQLEntry
		Public Validators ' As List Of CSQLEntryValidator
		Sub Class_Initialize
			Set Validators = CreateList
		End Sub
		Sub AddValidator(v)
			Validator.Add "", v
		End Sub
		Sub ParseValidators(s)
			Dim reVld, matches, match, vld, I, J
			Set reVld = New RegExp
			reVld.Pattern = "(?:^|(?:\s*:\s*))([a-zA-Z0-9]+)\(([^\)\}]*)\)"
			reVld.Global = True
			Set matches = reVld.Execute(s)
			For I = 0 To matches.Count - 1
				Set match = matches(I)
				If Len(match.Submatches(0)) > 0 Then
					Set vld = New CSQLEntryValidator
					vld.Func = match.Submatches(0)
					vld.Args = match.Submatches(1)
					Validators.Add "", vld
				End If
			Next
		End Sub
		Function ExecuteValidators(db, row, stack, bSingleResult, ByRef v)
			Dim I
			ExecuteValidators = True
			If Validators.Count > 0 Then
				For I = 1 To Validators.Count
					Validators(I).Execute db, row, stack, bSingleResult, v
					' It is recommended validators to cancel the transaction, but in case they just post a message ...
					If Validators(I).Result = False Then 
						db.InvalidateTransaction
						' This is needed in case there is no transaction
						db.CustomData("SQLTree").IsSuccessful = False
						ExecuteValidators = False
						Exit Function
					ElseIf Validators(I).SkipTheRest Then
						Exit Function
					End If
				Next
			End If
		End Function
	End Class
	Class CSQLTreeStatement
		Public Property Get ClassType
			ClassType = "CSQLTreeStatement"
		End Property
		Public SQL, IsParsed, Kind ' Kind is store or load/read
		Public parsed, funcRegister, outProcedures
		Public ValidationErrors ' Set to true to prevent statement execution
		Sub Class_Initialize
			Set parsed = CreateList
			Set funcRegister = CreateDictionary
			Set outProcedures = CreateList
		End Sub
		Function ParseSQL() ' Some parameters will get here
			Dim re, matches, I, s, m, entry, entryKey, holder
			Dim pos ' 0 based
			Set re = New RegExp
			re.Global = True
			' 0 - SQL to repeat, 1 - output field, 2 - func name, 3 - func args (unparsed), 4 - validators (unparsed)
			' @{funcname(arg,arg ...):validator1(arg,arg ...):validator2(arg,arg ...)}
			re.Pattern = "(\'(?:[^\']|(?:\'\'))*\')|(?:@\{(?:\[(\*|[a-zA-Z0-9_]+)\])?([a-zA-Z0-9]+)\(([^\}\)]*)\)(?:\:([^\}]+))?\})"
			
			Set parsed = CreateList
			Set funcRegister = CreateDictionary
			Set outProcedures = CreateList
			Set matches = re.Execute(SQL)
			pos = 0
			For I = 0 To matches.Count - 1
				Set m = matches(I)
				s = ""
				If m.FirstIndex > pos Then
					s = Mid(SQL,pos+1,m.FirstIndex - pos)
				End If
				If m.Submatches(0) <> "" Then
					' A string literal in the SQL statement - we need to put it back
					s = s & m.Value
					parsed.Add "", s ' Put the text here
					pos = m.FirstIndex + m.Length
				ElseIf m.Submatches(2) <> "" Or m.Submatches(3) <> "" Then
					' Add the text up to this point (if anything)
					If Len(s) > 0 Then
						parsed.Add "", s ' Put the text here
					End If
					If m.Submatches(1) <> "" Then
						Set entry = New CSQLOutputProc
						entry.Func = m.Submatches(2)
						entry.Args = m.Submatches(3)
						entry.Raw = m.Submatches(1)
						parsed.Add "", entry
						outProcedures.Add "", entry
					Else
						' The same entries are represented with the same instance in a register
						' from which we will actually execute them
						' Create the entry key so we can decide what to do next
						entryKey = m.Submatches(2) & m.Submatches(3)
						If IsObject(funcRegister(entryKey)) Then
							' Use existing
							Set entry = funcRegister(entryKey)
						Else
							' Create new
							Set entry = New CSQLEntry
							entry.Func = m.Submatches(2)
							entry.Args = m.Submatches(3)
							' And put it in the register
							entry.Id = "P" & (funcRegister.Count + 1)
							Set funcRegister(entryKey) = entry
						End If
						Set holder = New CSQLEntryPlaceHolder
						Set holder.Entry = entry
						If Len(m.Submatches(4)) > 0 Then
							holder.ParseValidators m.Submatches(4)
						End If
						parsed.Add entry.Func, holder ' We name the entry as its func, but this is only a debugging help
						' parsed.Add entry.Func, entry ' We name the entry as its func, but this is only a debugging help
						' Move the pos
					End If
					pos = m.FirstIndex + m.Length
					
				End If
			Next
			' If there is remaining text collect it
			If pos < Len(SQL) Then
				parsed.Add "", Mid(SQL, pos + 1, Len(SQL) - pos)
			End If
			IsParsed = True
		End Function
		Sub ClearArgs
			Dim I
			If IsObject(funcRegister) Then
				For I = 1 To funcRegister.Count
					funcRegister(I).Result = Null
					Set funcRegister(I).params = CreateDictionary
				Next
			End If
			If IsObject(Parsed) Then
				For I = 1 To outProcedures.Count
					outProcedures(I).params = CreateDictionary
				Next
			End If
		End Sub
		' All the dynamic sources are passed to this routine in order to pass them to the ParseArgs of each entry
		Function ExecuteFuncs(db, current, stack)
			Dim I, func, entry
			If IsObject(funcRegister) Then
				ClearArgs
				For I = 1 To funcRegister.Count
					Set entry = funcRegister(I)
					If IsObject(CSQLEntry_Funcs(entry.Func)) Then
						' Set func = CSQLEntry_Funcs(entry.Func)
						entry.ParseArgs db, current, stack
						entry.Execute db
					Else
						' Ths is a serious mistake - rise an error
						Err.Raise 1001, "CSQLTreeStatement", "The Func " & entry.Func & " cannot be found in the register."
					End If
				Next
			End If
		End Function
		Function GenerateSQL(db, row, stack, bSingleResult)
			GenerateSQL = ""
			If Not IsParsed Then Exit Function
			Dim gsql, I, holder
			gsql = ""
			' TODO: We need to execute the funcs before generating the SQL
			' This way we can clearly identify those entries that will bind not parameters, but will
			' inject text instead
			For I = 1 To Parsed.Count
				If IsObject(Parsed(I)) Then
					Set holder = Parsed(I)
					If holder.classType = "CSQLEntryPlaceHolder" Then
						If holder.ExecuteValidators(db, row, stack, bSingleResult, holder.entry.Result) Then
							If holder.entry.IsLiteralResult Then
								gsql = gsql & holder.entry.Result
							Else
								gsql = gsql & "$" & holder.entry.Id
							End If
						Else
							ValidationErrors = True ' Some validation errors
						End If
					ElseIf holder.classType = "CSQLOutputProc" Then
						gsql = gsql & holder.Source
					End If
				Else
					gsql = gsql & Parsed(I)
				End If
			Next
			GenerateSQL = gsql
		End Function
		
		Function Execute(db, row, stack, bSingleResult)
			Dim sqlStatment ' Regenerated on each call to accomodate potential literal results
			Dim sqlParameters
			Dim I, J, entry, outprocs
			' 1. Check if parsed and parse if not
			If Not IsParsed Then ParseSQL
			' 2. Execute funcs
			ExecuteFuncs db, row, stack
			' 3. Pack the parameters in a collection
			Set sqlParameters = CreateDictionary
			sqlParameters.Missing = Null ' Make sure missing params will turn into nulls (should be no missing ones, but this is safer)
			If IsObject(funcRegister) Then
				For I = 1 To funcRegister.Count
					Set entry = funcRegister(I)
					If Not entry.IsLiteralResult Then
						sqlParameters.Add entry.Id, entry.Result
					End If
				Next
			End If
			' 4. Generate the SQL statement, this will also put the literal results in place
			sqlStatement = GenerateSQL(db, row, stack, bSingleResult)
			' 4.1. Check if there are any validation errors and return an empty result if so
			If ValidationErrors Then
				' Signals that there are some validation errors
				db.CustomData("SQLTree").ValidationErrors = True
				Set Execute = CreateCollection
				Exit Function
			End If
			' 5. Execute the statement and return the result
			'Dim r, r1
			'Set r = CreateList
			'Set r1 = CreateDictionary
			'r1.Add "a", sqlStatement
			'r1.Add "paramcount", sqlParameters.Count
			'r.Add "", r1
			'Set Execute = r
			'Exit Function
			Dim result
			If bSingleResult Then
				Set result = db.db.CExecute(sqlStatement, sqlParameters, 1, 1)
			Else
				Set result = db.db.CExecute(sqlStatement, sqlParameters, 1, 0)
			End If
			For I = 1 To outProcedures.Count
				For J = 1 To result.Count
					If Not outProcedures(I).Execute(db, result(J), stack) Then
						Err.Raise 1008, "CSQLTreeStatement", "The output Func " & outProcedures(I).Func & " failed."
					End If
				Next
			Next
			Set Execute = result
		End Function
	End Class
	Class CSQLInlineData
		Public Property Get ClassType
			ClassType = "CSQLInlineData"
		End Property
		Public Data
		Sub Class_Initialize
			Set Data = Nothing
		End Sub
		Function Execute(db, row, stack, bSingleResult)
			Dim r
			Set r = CreateList
			If Not Data Is Nothing Then
				If CSQLTree_IsJSONArray(Data) Then
					Set Execute = Data
				Else
					r.Add "1", Data
					Set Execute = r
				End If
			Else
				Set Execute = r
			End If
		End Function
	End Class
	Class CSQLJsonFile
		Public Property Get ClassType
			ClassType = "CSQLJsonFile"
		End Property
		Public Data
		Sub Class_Initialize
			Data = Null
		End Sub
		Function Execute(db, row, stack, bSingleResult)
			Dim r
			Set r = CreateList
			If Not IsNull(Data) Then
				Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
				Dim file, s, tree
				Set file = sf.OpenFile(MapPath(Data),&H20)
				s = file.ReadText(-2)
				file.Close
				Set tree = JSON.Parse(s)
				If CSQLTree_IsJSONArray(tree) Then
					Set Execute = tree
				Else
					r.Add "1", tree
					Set Execute = r
				End If
			Else
				Set Execute = r
			End If
		End Function
	End Class
	
	Class CSQLTreeNode
		Public Property Get ClassType
			ClassType = "CSQLTreeNode"
		End Property
		Public sqlSelect, sqlInsert, sqlUpdate, sqlDelete
		Public PreRead, PreWrite, PostRead, PostWrite ' Node procedures
		Public IsMultiple, SkipMissingOperations
		Public Nodes, Views
		Public Access ' Raw JSON node from the JSON definition
		Public Nomenclatures
		Sub Class_Initialize
			Set Nodes = CreateDictionary
			Set Views = CreateDictionary
			Set Nomenclatures = CreateDictionary
			Set PreRead = Nothing
			Set PreWrite = Nothing
			Set PostRead = Nothing
			Set PostWrite = Nothing
		End Sub
		
		' Helper functions
		Public Function IsJSONArray(o)
			IsJSONArray = False
			If IsArray(o) Then
				IsJSONArray = True
			ElseIf IsObject(o) Then
				If IsObject(o.Info) Then
					If Not o.Info.Type Then
						IsJSONArray = True
					End If
				Else 
					If o.Info = vbArray Then
						IsJSONArray = True
					End If
				End If
			End If
		End Function
		Public Function LoadNomenclatures(db)
			Dim r, params, stmt, I, results, stack, J
			Set params = CreateDictionary ' No parameters - the nomenclatures must be independent of parameters
			Set results = CreateDictionary ' Result holder
			results.Info = vbObject
			Set stack = CreateList ' Empty stack
			For I = 1 To Nomenclatures.Count
				If IsObject(Nomenclatures(I)) Then
					Set stmt = Nomenclatures(I)
					Set r = stmt.Execute(db, params, stack, False)
					r.Info = vbArray
					' Remove the type info to avoid mix ups
					For J = 1 To r.Count
						r(J).Info = vbObject
					Next
					results.Add Nomenclatures.Key(I), r
				End If
				
			Next
			Set LoadNomenclatures = results
		End Function
		
		' params are set as row/current to all the statements and they do not change on select
		Public Function Read(db, params, stack, ByVal overrideState)
			Dim r, I, J, nr, result
			Set Read = Nothing ' The default result is empty/null and no cascading occurs
			If CSQLTree_IsJSONObject(Access) Then
				If Not SQLTree_CheckAccess(db, Access, False) Then
					Exit Function
				End If
			End If
			Set result = CreateList
			result.Info = vbArray
			If Not PreRead Is Nothing Then
				For I = 1 To PreRead.Count
					If Not PreRead(I).Execute(db, params, result, stack, IsMultiple, cEntityState_Unchanged) Then ' State is unimportant on read
						Set Read = result
						Exit Function
					End If
				Next
			End If
			If Not sqlSelect Is Nothing Then
				Set r = sqlSelect.Execute(db, params, stack, Not IsMultiple)
				If r.Count > 0 Then
					For I = 1 To r.Count
						result.Add "", r(I)
					Next
					Set r = result
					If IsMultiple Then
						r.Info = vbArray
						For I = 1 To r.Count
							r(I).Info = vbObject
							r(I).itemsAssignmentAllowed = True
							r(I).extractValues = False
							r(I)(cEntityStateName) = cEntityState_Unchanged
							If Nodes.Count > 0 Then
								stack.Push r(I)
								For J = 1 To Nodes.Count
									If IsObject(Nodes(J)) Then
										Set nr = Nodes(J).Read(db, params, stack, overrideState)
										Set r(I)(Nodes.Key(J)) = nr
									End If
								Next
								stack.Drop
							End If
						Next
						Set Read = r
					Else
						r(1).Info = vbObject
						r(1).itemsAssignmentAllowed = True
						r(1).extractValues = False
						r(1)(cEntityStateName) = cEntityState_Unchanged
						If Nodes.Count > 0 Then
							stack.Push r(1)
							For J = 1 To Nodes.Count
								If IsObject(Nodes(J)) Then
									Set nr = Nodes(J).Read(db, params, stack, overrideState)
									Set r(1)(Nodes.Key(J)) = nr
								End If
							Next
							stack.Drop
						End If
						Set Read = r(1)
					End If
				Else
					If IsMultiple Then
						r.Info = vbArray 
						Set Read = r
					End If
				End If
			End If
			If Not PostRead Is Nothing Then
				For I = 1 To PostRead.Count
					If Not PostRead(I).Execute(db, params, result, stack, IsMultiple, cEntityState_Unchanged) Then ' State is unimportant on read
						Exit Function
					End If
				Next
			End If
		End Function
		Private Sub TransferResultsToData(result, data)
			Dim I, J, row
			For I = 1 To result.Count
				Set row = result(I)
				For J = 1 To row.Count
					data(row.Key(J)) = row(J)
				Next
			Next
			data(cEntityStateName) = cEntityState_Unchanged
		End Sub
		' data - refe to the current data node (object not array, the arrays are processed from the parent)
		Public Function Store(db, data, stack, ByVal overrideState)
			Dim state, r, I, J
			Set Store = Nothing
			If IsObject(data) Then
				If Not IsEmpty(overrideState) And Not IsNull(overrideState) Then
					state = overrideState
				Else
					If data.KeyExists(cEntityStateName) Then
						state = data(cEntityStateName)
					Else
						' Assume unchanged for safety reasons - to avoid attempt to save helper (client interest only) data that got accidentally on the server
						state = cEntityState_Unchanged
					End If
				End If
				If Not PreWrite Is Nothing Then
					For I = 1 To PreWrite.Count
						If Not PreWrite(I).Execute(db, data, Nothing, stack, IsMultiple, state) Then ' State is unimportant on read
							Set Store = data
							Exit Function
						End If
					Next
				End If
				Select Case state
					Case cEntityState_New
						If Not sqlInsert Is Nothing Then
							Set r = sqlInsert.Execute(db, data, stack, Not IsMultiple)
						Else
							If SkipMissingOperations Or cBehaviour_SkipMissingOperations Then
								' Probably log and make the above conditions more precise
							Else
								Err.Raise 1003, "CSQLTreeNode", "Insert operation is requested, but is missing"
							End If
						End If
						TransferResultsToData r, data
						' Go to children
						ExecuteChildren db, data, stack, overrideState
						Set Store = data
					Case cEntityState_Updated
						If Not sqlUpdate Is Nothing Then
							Set r = sqlUpdate.Execute(db, data, stack, Not IsMultiple)
						Else
							If SkipMissingOperations Or cBehaviour_SkipMissingOperations Then
								' Probably log and make the above conditions more precise
							Else
								Err.Raise 1003, "CSQLTreeNode", "Update operation is requested, but is missing"
							End If
						End If
						TransferResultsToData r, data
						' Go to children
						ExecuteChildren db, data, stack, overrideState
						Set Store = data
					Case cEntityState_Deleted
						' Go to children
						ExecuteChildren db, data, stack, state ' Overriding the state for cascading deletion
						If Not sqlDelete Is Nothing Then
							Set r = sqlDelete.Execute(db, data, stack, Not IsMultiple)
						Else
							If SkipMissingOperations Or cBehaviour_SkipMissingOperations Then
								' Probably log and make the above conditions more precise
							Else
								Err.Raise 1003, "CSQLTreeNode", "Delete operation is requested, but is missing"
							End If
						End If
						' No transfer - deleted items are replaced with nulls
					Case cEntityState_Unchanged
						ExecuteChildren db, data, stack, overrideState
						Set Store = data
				End Select
				If Not PostWrite Is Nothing Then
					For I = 1 To PostWrite.Count
						If Not PostWrite(I).Execute(db, data, Nothing, stack, IsMultiple, state) Then ' State is unimportant on read
							Set Store = data
							Exit Function
						End If
					Next
				End If
			End If
		End Function
		' Entry point for writing data
		Function Write(db, data, stack,ByVal overrideState)
			Set Write = StoreNode(Me, db, data, stack, overrideState)
		End Function
		Function StoreNode(node, db, data, stack,ByVal overrideState)
			Dim resultNode, row, r
			If CSQLTree_IsJSONObject(Access) Then
				If Not SQLTree_CheckAccess(db, Access, True) Then
					Set StoreNode = Nothing
					Exit Function
				End If
			End If
			If IsJSONArray(data) Then
				' Process further only if it is an object (or array) - otherwise leave it be
				Set resultNode = CreateList
				resultNode.Info = vbArray ' Treat this as array
				If IsObject(data) Then
					For J = 1 To data.Count
						If IsObject(data(J)) Then
							Set row = data(J)
							Set r = node.Store(db, row, stack, overrideState)
							If Not r Is Nothing Then
								resultNode.Add "", r
							End If
						End If
					Next
				ElseIf IsArray(data) Then
					For J = LBound(data) To UBound(data)
						If IsObject(data(J)) Then
							Set row = data(J)
							Set r = node.Store(db, row, stack, overrideState)
							If Not r Is Nothing Then
								resultNode.Add "", r
							End If
						End If
					Next
				End If
				Set StoreNode = resultNode ' Give the caller chance to replace the node with regular array implementation
			ElseIf IsObject(data) Then
				' Not an array - process as single record
				Set StoreNode = node.Store(db, data, stack, overrideState)
			Else
				Set StoreNode = Nothing
			End If
		End Function
		Private Function ExecuteChildren(db, data, stack, ByVal overrideState)
			Dim I, J, subdata, row, node, r, resultnode
			If Nodes.Count > 0 Then
				stack.Push data ' The data here is not an array - this method is called from Store which is called for a single record always
				For I = 1 To Nodes.Count
					If data.KeyExists(Nodes.Key(I)) Then
						Set node = Nodes(I) ' The current subnode
						Set data(Nodes.Key(I)) = StoreNode(node, db, data(Nodes.Key(I)), stack, overrideState) 
					End If
				Next
				stack.Drop
			End If
		End Function
		
		
	End Class
	
	' Some standard funcs
	' Function FName(database: SQLite, args: Dictionary, byRef IsLiteralResult: Boolean)
	' 	The function returns the result and if it is for literal replacement also must set IsLiteralResult to True
	
	' Just returns the parameter passed
	Function Func_var(db, args, ByRef IsLiteralResult)
		Func_var = Null
		Dim t
		If args.Count > 0 Then
			If args.Count > 1 Then
				t = NullConvertTo(vbString, args(2))
				If IsNull(t) Then
					Func_var = args(1)
				Else
					Select Case LCase(t)
						Case "int"
							Func_var = NullConvertTo(vbLong, args(1))
						Case "float"
							Func_var = NullConvertTo(vbDouble, args(1))
						Case "double"
							Func_var = NullConvertTo(vbDouble, args(1))
						Case "string"
							Func_var = NullConvertTo(vbString, args(1))
						Case "text"
							Func_var = NullConvertTo(vbString, args(1))
						Case "bool"
							Func_var = IfThenElse(ConvertTo(vbBoolean, args(1)), 1, 0)
						Case "date"
							Func_var = NullConvertTo(vbDouble, args(1))
						Case Else
							Err.Raise 2002, "Func_var", "The second parameter is not recognised."
					End Select
				End If
			Else
				Func_var = args(1)
			End If
		End If
	End Function
	Function Func_val(db, args, ByRef IsLiteralResult)
		Func_val = Null
		Dim t
		If args.Count > 0 Then
			If args.Count > 1 Then
				t = NullConvertTo(vbString, args(2))
				If IsNull(t) Then
					Func_val = args(1)
				Else
					Select Case LCase(t)
						Case "int"
							Func_val = TryConvertTo(vbLong, args(1))
						Case "float"
							Func_val = TryConvertTo(vbDouble, args(1))
						Case "double"
							Func_val = TryConvertTo(vbDouble, args(1))
						Case "string"
							Func_val = TryConvertTo(vbString, args(1))
						Case "text"
							Func_val = TryConvertTo(vbString, args(1))
						Case "bool"
							Func_val = IfThenElse(ConvertTo(vbBoolean, args(1)), 1, 0)
						Case "date"
							Func_val = TryConvertTo(vbDouble, args(1))
						Case Else
							Err.Raise 2002, "Func_val", "The second parameter is not recognised."
					End Select
				End If
			Else
				Func_val = args(1)
			End If
		End If
	End Function
	Function Func_Int(db, args, ByRef IsLiteralResult)
		Func_Int = Null
		If args.Count > 0 Then
			Func_Int = TryConvertTo(vbLong, args(1))
		End If
	End Function
	Function Func_Double(db, args, ByRef IsLiteralResult)
		Func_Double = Null
		If args.Count > 0 Then
			Func_Double = TryConvertTo(vbDouble, args(1))
		End If
	End Function
	Function Func_String(db, args, ByRef IsLiteralResult)
		Func_String = Null
		If args.Count > 0 Then
			Func_String = TryConvertTo(vbString, args(1))
		End If
	End Function
	Function Func_Bool(db, args, ByRef IsLiteralResult)
		Func_Bool = Null
		If args.Count > 0 Then
			Func_Bool = IfThenElse(ConvertTo(vbBoolean, args(1)),1,0)
		End If
	End Function
	Function Func_currentLanguage(db, args, ByRef IsLiteralResult)
		Func_currentLanguage = PageUILanguage
	End Function
	' offset, limit, default limit
	Function Func_Paging(db, args, ByRef IsLiteralResult)
		IsLiteralResult = True
		Dim offset, limit, result, defLimit
		defLimit = Null
		offset = Null
		limit = Null
		If args.Count > 0 Then
			offset = NullConvertTo(vbLong, args(1))
		End If
		If args.Count > 1 Then
			limit = NullConvertTo(vbLong, args(2))
		End If
		If args.Count > 2 Then
			defLimit = NullConvertTo(vbLong, args(3))
		End If
		result = ""
		If Not IsNull(limit) Then
			result = result & "LIMIT " & limit
			If Not IsNull(offset) Then
				result = result & "OFFSET " & offset - 1
			End If
		End If
		If Len(result) = 0 And Not IsNull(defLimit) Then
			result = "LIMIT " & defLimit
		End If
		Func_Paging = result
	End Function
	' allowed, field, dir
	Function Func_OrderBy(db, args, ByRef IsLiteralResult)
		IsLiteralResult = True
		Dim allowed, field, dir, arrAllowed
		defDir = "ASC"
		defField = Null
		allowed = Null
		dir = Null
		If args.Count > 0 Then
			allowed = NullConvertTo(vbString, args(1))
		End If
		If IsNull(allowed) Or IsEmpty(allowed) Then
			Err.Raise 2001, "Func_OrderBy", "The allowed fields list parameter is required"
			Func_OrderBy = ""
			Exit Function
		End If
		If args.Count > 1 Then
			field = NullConvertTo(vbString, args(2))
		End If
		If IsNull(field) Or IsEmpty(field) Then
			If args.Count > 3 Then 
				field = NullConvertTo(vbString, args(4))
			Else
				Func_OrderBy = ""
				Exit Function
			End If
		End If
		If Not IsOneOf(allowed,field,",") Then
			Err.Raise 2002, "Func_OrderBy", "The field specified is not in the list of allowed fields list."
			Func_OrderBy = ""
			Exit Function
		End If
		If args.Count > 2 Then
			dir = NullConvertTo(vbLong, args(3))
			If IsNull(dir) Then
				dir = NullConvertTo(vbString, args(3))
				If Not IsNull(dir) Then
					If LCase(dir) = "asc" Or LCase(dir) = "desc" Then
						dir = LCase(dir)
					Else
						dir = Null
					End If
				End If
			Else
				If dir < 0 Then
					dir = "desc"
				Else
					dir = "asc"
				End If
			End If
		End If
		If IsNull(dir) And args.Count > 4 Then
			dir = NullConvertTo(vbString, args(5))
			If Not IsOneOf("desc,asc",LCase(dir),",") Then dir = Null
		End If
		
		If IsNull(dir) Then
			Func_OrderBy = "ORDER BY [" & field & "]"
		Else
			Func_OrderBy = "ORDER BY [" & field & "] " & dir
		End If
		
	End Function
	' text, bLeft, bRight
	Function Func_Like(db, args, ByRef IsLiteralResult)
		IsLiteralResult = True
		Dim text, bLeft, bRigth, v, result
		text = Null
		bLeft = True
		bRight = True
		If args.Count > 0 Then
			text = NullConvertTo(vbString, args(1))
		End If
		If IsNull(text) Then
			Func_Like = "NULL"
			Exit Function
		End If
		If args.Count > 1 Then
			v = NullConvertTo(vbBoolean, args(2))
			If Not IsNull(v) Then bLeft = v
		End If
		If args.Count > 2 Then
			v = NullConvertTo(vbBoolean, args(3))
			If Not IsNull(v) Then bRight = v
		End If
		result = "'" & IfThenElse(bLeft, "%","") & Replace(text,"'","''") & IfThenElse(bRight, "%","") & "'"
		Func_Like = result
	End Function
	
	' Validator funcs
	Function Val_Required(db, args, ByRef v, ByRef bSkipRest)
		Val_Required = True
		If IsNull(v) Or IsEmpty(v) Then 
			Val_Required = False
			db.AddMessage "Validation failed: A required value is missing"
		End If
	End Function
	Function Val_Optional(db, args, ByRef v, ByRef bSkipRest)
		Val_Optional = True
		If IsNull(v) Or IsEmpty(v) Then
			bSkipRest = True
		End If
	End Function
	Function Val_Int(db, args, ByRef v, ByRef bSkipRest)
		Val_Int = True
		If Not IsNull(v) And Not IsEmpty(v) Then
			If VarType(v) = vbLong Or VarType(v) = vbInt Then
				Val_Int = True
			Else
				Val_Int = False
				db.AddMessage "Validation failed: The value must be integer."
			End If
		End If
	End Function
	Function Val_Double(db, args, ByRef v, ByRef bSkipRest)
		Val_Double = True
		If Not IsNull(v) And Not IsEmpty(v) Then
			If VarType(v) = vbDouble Or VarType(v) = vbSingle Or VarType(v) = vbDate Then
				Val_Double = True
			Else
				Val_Double = False
				db.AddMessage "Validation failed: The value must be double or float."
			End If
		End If
	End Function
	Function Val_String(db, args, ByRef v, ByRef bSkipRest)
		Val_String = True
		If Not IsNull(v) And Not IsEmpty(v) Then
			If VarType(v) = vbString Then
				Val_String = True
			Else
				Val_String = False
				db.AddMessage "Validation failed: The value must be string."
			End If
		End If
	End Function
	Function Val_Length(db, args, ByRef v, ByRef bSkipRest)
		Val_Length = True
		Dim vv
		vv = ConvertTo(vbString, v)
		Dim xmin, xmax
		xmin = 0
		xmax = 0
		If args.Count > 0 Then xmin = ConvertTo(vbLong, args(1))
		If args.Count > 1 Then xmax = ConvertTo(vbLong, args(2))
		If xmin > 0 Then
			If Len(vv) < xmin Then 
				Val_Length = False
				db.AddError "Validation failed: A value is shorter than " & xmin & " characters."
				Exit Function
			End If
		End If
		If xmax > 0 Then
			If Len(vv) > xmax Then 
				Val_Length = False
				db.AddError "Validation failed: A value is longer than " & xmax & " characters."
				Exit Function
			End If
		End If
	End Function
	Function Val_Range(db, args, ByRef v, ByRef bSkipRest)
		Val_Range = True
		If IsNull(v) Then Exit Function
		Dim xmin, xmax
		xmin = Null
		xmax = Null
		If args.Count > 0 Then xmin = args(1)
		If args.Count > 1 Then xmax = args(2)
		If Not IsNull(xmin) Then
			If v < xmin Then
				Val_Range = False
				db.AddError "Validation failed: The value must be greater or equal to " & xmin & "."
				Exit Function
			End If
		End If
		If Not IsNull(xmax) Then
			If v > xmax Then 
				Val_Range = False
				db.AddError "Validation failed: The value must be lower or equal to " & xmax & "."
				Exit Function
			End If
		End If
	End Function
	' Argument modifiers
	' modifier: none-smart fetch, @from current row, ? - from query string, ^ - from post, $ - built in, #get, post or anything, * - current_or_parent, ~ - from parent
	
	' Output procedures
	Function Out_ConvertTo(db, args, name, row)
		If IsNull(name) Then Err.Raise 5001, "to - name is required. Please use [<somename>]to('<type>') syntax."
		If args.Count < 1 Then Err.Raise 5002, "to - type name is required. Please use [<somename>]to('<type>') syntax."
		Dim t, v
		t = args(1)
		If row.KeyExists(name) Then
			v = row(name)
			If Not IsNull(v) Then
				Select Case LCase(t)
					Case "int"
						v = TryConvertTo(vbLong, v)
					Case "integer"
						v = TryConvertTo(vbLong, v)
					Case "double"
						v = TryConvertTo(vbDouble, v)
					Case "float"
						v = TryConvertTo(vbDouble, v)
					Case "real"
						v = TryConvertTo(vbDouble, v)
					Case "date"
						v = TryConvertTo(vbDate, v)
					Case "time"
						v = TryConvertTo(vbDate, v)
					Case "datetime"
						v = TryConvertTo(vbDate, v)
					Case "string"
						v = TryConvertTo(vbString, v)
					Case "text"
						v = TryConvertTo(vbString, v)
					Case "bool"
						v = TryConvertTo(vbBoolean, v)
					Case "boolean"
						v = TryConvertTo(vbBoolean, v)
				End Select
				row.itemsAssignmentAllowed = True
				row(name) = v
			End If
		End If
		Out_ConvertTo = True
	End Function
	Function Out_ConvertToDate(db, args, name, row)
		If IsNull(name) Then Err.Raise 5001, "to - name is required. Please use [<somename>]to('<type>') syntax."
		Dim t, v
		t = args(1)
		If row.KeyExists(name) Then
			If Not IsNull(v) Then
				v = row(name)
				v = TryConvertTo(vbDate, v)
				row.itemsAssignmentAllowed = True
				row(name) = v
			End If
		End If
		Out_ConvertToDate = True
	End Function
	Function Out_ConvertToInt(db, args, name, row)
		If IsNull(name) Then Err.Raise 5001, "to - name is required. Please use [<somename>]to('<type>') syntax."
		Dim t, v
		t = args(1)
		If row.KeyExists(name) Then
			If Not IsNull(v) Then
				v = row(name)
				v = TryConvertTo(vbLong, v)
				row.itemsAssignmentAllowed = True
				row(name) = v
			End If
		End If
		Out_ConvertToInt = True
	End Function
	Function Out_ConvertToDouble(db, args, name, row)
		If IsNull(name) Then Err.Raise 5001, "to - name is required. Please use [<somename>]to('<type>') syntax."
		Dim t, v
		t = args(1)
		If row.KeyExists(name) Then
			If Not IsNull(v) Then
				v = row(name)
				v = TryConvertTo(vbDouble, v)
				row.itemsAssignmentAllowed = True
				row(name) = v
			End If
		End If
		Out_ConvertToDouble = True
	End Function
	Function Out_ConvertToBool(db, args, name, row)
		If IsNull(name) Then Err.Raise 5001, "to - name is required. Please use [<somename>]to('<type>') syntax."
		Dim t, v
		t = args(1)
		If row.KeyExists(name) Then
			If Not IsNull(v) Then
				v = row(name)
				v = TryConvertTo(vbBoolean, v)
				row.itemsAssignmentAllowed = True
				row(name) = v
			End If
		End If
		Out_ConvertToBool = True
	End Function
	Function Out_ConvertToString(db, args, name, row)
		If IsNull(name) Then Err.Raise 5001, "to - name is required. Please use [<somename>]to('<type>') syntax."
		Dim t, v
		t = args(1)
		If row.KeyExists(name) Then
			If Not IsNull(v) Then
				v = row(name)
				v = TryConvertTo(vbString, v)
				row.itemsAssignmentAllowed = True
				row(name) = v
			End If
		End If
		Out_ConvertToString = True
	End Function
	
	RegisterSQLFunc "var", "Func_var"
	RegisterSQLFunc "val", "Func_val"
	RegisterSQLFunc "int", "Func_Int"
	RegisterSQLFunc "double", "Func_Double"
	RegisterSQLFunc "string", "Func_String"
	RegisterSQLFunc "bool", "Func_Bool"
	RegisterSQLFunc "currentLanguage", "Func_currentLanguage"
	RegisterSQLFunc "paging", "Func_Paging"
	RegisterSQLFunc "like", "Func_Like"
	RegisterSQLFunc "orderby", "Func_OrderBy"
	
	
	RegisterSQLValidator "required", "Val_Required"
	RegisterSQLValidator "int", "Val_Int"
	RegisterSQLValidator "double", "Val_Double"
	RegisterSQLValidator "string", "Val_String"
	RegisterSQLValidator "length", "Val_Length"
	RegisterSQLValidator "range", "Val_Range"
	RegisterSQLValidator "optional", "Val_Optional"
	
	
	RegisterSQLOutputProc "to", "Out_ConvertTo"
	RegisterSQLOutputProc "toint", "Out_ConvertToInt"
	RegisterSQLOutputProc "todate", "Out_ConvertToDate"
	RegisterSQLOutputProc "todouble", "Out_ConvertToDouble"
	RegisterSQLOutputProc "tobool", "Out_ConvertToBool"
	RegisterSQLOutputProc "tostring", "Out_ConvertToString"
%>
<!-- #include file="json-utils-morefuncs.asp" -->