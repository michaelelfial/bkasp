<%
		' Rev1
		
	Function Func_KeywordIDPositive(db, args, ByRef IsLiteralResult)
		IsLiteralResult = True
		Dim text
		If args.Count > 0 Then
			text = NullConvertTo(vbString, args(1))
		Else
			Func_KeywordIDPositive = "0"
			Exit Function
		End If
		If (IsNull(text)) Then
			Func_KeywordIDPositive = "0"
		Else
			Func_KeywordIDPositive = KeywordIDList(text, True, False)
		End If
	End Function
	RegisterSQLFunc "keywordIdPositive", "Func_KeywordIDPositive"
	
	Function Func_KeywordIDNegative(db, args, ByRef IsLiteralResult)
		IsLiteralResult = True
		Dim text
		If args.Count > 0 Then
			text = NullConvertTo(vbString, args(1))
		Else
			Func_KeywordIDNegative = "0"
		End If
		Func_KeywordIDNegative = KeywordIDList(text, True, False)
	End Function
	RegisterSQLFunc "keywordIdNegative", "Func_KeywordIDNegative"
	
	Function Func_AccessRights(db, args, ByRef IsLiteralResult)
		Dim tblName, bWrite
		IsLiteralResult = True
		Func_AccessRights = " 1=0 "
		tblName = Empty
		bWrite = False
		For I = 1 To args.Count
			If VarType(args(I)) = vbString Then 
				tblName = args(I)
			ElseIf VarType(args(I)) = vbLong Then
				bWrite = ConvertTo(vbBoolean, args(I))
			End If
		Next
		If CurrentUser.IsAdmin Then
			Func_AccessRights = " 1=1 "
		Else
			If Len(tblName) = 0 Then
				If bWrite Then
					Func_AccessRights = SQLAccessRights(FR_WRITE)
				Else
					Func_AccessRights = SQLReadRights
				End If
			Else
				If bWrite Then
					Func_AccessRights = SQLAccessRightsTable(tblName, FR_WRITE)
				Else
					Func_AccessRights = SQLReadRightsTable(tblName)
				End If
			End If
		End If
	End Function
	RegisterSQLFunc "AccessRights", "Func_AccessRights"
	
	Function Func_CurrentUserId(db, args, ByRef IsLiteralResult)
		IsLiteralResult = False
		Func_CurrentUserId = Null
		If IsLoggedOn Then
			Func_CurrentUserId = CurrentUser.Id
		End If		
	End Function
	RegisterSQLFunc "CurrentUserId", "Func_CurrentUserId"
	
	Function Func_CurrentUserLogin(db, args, ByRef IsLiteralResult)
		IsLiteralResult = False
		Func_CurrentUserLogin = Null
		If IsLoggedOn Then
			Func_CurrentUserLogin = CurrentUser.Login
		End If		
	End Function
	RegisterSQLFunc "CurrentUserLogin", "Func_CurrentUserLogin"
	
	Function Func_IsLoggedOn(db, args, ByRef IsLiteralResult)
		IsLiteralResult = False
		Func_IsLoggedOn = False
		If IsLoggedOn Then
			Func_IsLoggedOn = True
		End If		
	End Function
	RegisterSQLFunc "IsLoggedOn", "Func_IsLoggedOn"
	
	Function Func_IsAdmin(db, args, ByRef IsLiteralResult)
		IsLiteralResult = False
		Func_IsAdmin = IsAdmin
	End Function
	RegisterSQLFunc "IsAdmin", "Func_IsAdmin"
	
	Function Func_CurrentUserEmail(db, args, ByRef IsLiteralResult)
		IsLiteralResult = False
		Func_CurrentUserEmail = Null
		If IsLoggedOn Then
			Func_CurrentUserEmail = CurrentUser.Login
		End If		
	End Function
	RegisterSQLFunc "CurrentUserEmail", "Func_CurrentUserEmail"
	
	Function Func_CurrentUserPersonId(db, args, ByRef IsLiteralResult)
		IsLiteralResult = False
		Func_CurrentUserPersonId = Null
		If IsLoggedOn Then
			Func_CurrentUserPersonId = CurrentUser.PersonId
		End If		
	End Function
	RegisterSQLFunc "CurrentUserPersonId", "Func_CurrentUserPersonId"
	
	Function Func_Login(db, args, rows, stack, bSingleResult, state)
		Func_Login = True
		Dim r, l, p
		If args.Count >= 2 Then
			If rows.Count > 0 Then
				Set r = rows(1)
				l = NullConvertTo(vbString, args(1))
				p = NullConvertTo(vbString, args(2))
				If IsNull(l) Or IsNull(p) Then
					Err.Raise 1104, "Func_Login", "Either the login or the password (or both by the way) is/are null."
				Else
					If LogOn(l,p,l,True) Then
						r("logged") = True
					Else
						r("logged") = False
					End If
				End If
			Else
				Func_Login = False
				Exit Function
			End If
		Else
			Err.Raise 1103, "Func_Login", "Not enough parameters - needs two strings."
			Func_Login = False
		End If
	End Function
	RegisterSQLNodeProc "login", "Func_Login"
	
	Function Func_Logoff(db, args, rows, stack, bSingleResult, state)
		Func_Logoff = True
		LogOff
		If rows.Count > 0 Then
			Set r = rows(1)
			r("loggedoff") = True
		End If
	End Function
	RegisterSQLNodeProc "logoff", "Func_Logoff"
	
	Function Func_LoginInfo(db, args, rows, stack, bSingleResult, state)
		Func_LoginInfo = True
		If rows.Count > 0 Then
			Set r = rows(1)
			If CurrentUser.IsLoggedOn Then
				r("isloggedon") = True
				r("login") = CurrentUser.Login
				r("email") = CurrentUser.Email
				r("isadmin") = CurrentUser.IsAdmin
			Else
				r("isloggedon") = False
			End If
		Else
			Func_Login = False
			Exit Function
		End If
	End Function
	RegisterSQLNodeProc "logininfo", "Func_LoginInfo"
	
	' System variables
	CSQLProc_RegisterBuiltInVariable "IsLoggedOn", IsLoggedOn
	CSQLProc_RegisterBuiltInVariable "IsAdmin", IsAdmin
	CSQLProc_RegisterBuiltInVariable "CurrentLanguage", PageUILanguage
	If IsLoggedOn Then
		CSQLProc_RegisterBuiltInVariable "CurrentUserLogin", CurrentUser.Login
		CSQLProc_RegisterBuiltInVariable "CurrentUserId", CurrentUser.Id
		CSQLProc_RegisterBuiltInVariable "CurrentUserPersonId", CurrentUser.PersonId
		CSQLProc_RegisterBuiltInVariable "CurrentUserEmail", CurrentUser.Email
		CSQLProc_RegisterBuiltInVariable "CurrentUserGroupId", CurrentUser.GroupId
		CSQLProc_RegisterBuiltInVariable "CurrentUserLevel", CurrentUser.Level
		CSQLProc_RegisterBuiltInVariable "DefaultUserRigths", CurrentUser.R_USER
		CSQLProc_RegisterBuiltInVariable "DefaultGroupRigths", CurrentUser.R_GROUP
		CSQLProc_RegisterBuiltInVariable "DefaultAllRigths", CurrentUser.R_GROUP
	Else
		CSQLProc_RegisterBuiltInVariable "CurrentUserLogin", Null
		CSQLProc_RegisterBuiltInVariable "CurrentUserId", Null
		CSQLProc_RegisterBuiltInVariable "CurrentUserPersonId", Null
		CSQLProc_RegisterBuiltInVariable "CurrentUserEmail", Null
		CSQLProc_RegisterBuiltInVariable "CurrentUserGroupId", Null
		CSQLProc_RegisterBuiltInVariable "CurrentUserLevel", Null
		CSQLProc_RegisterBuiltInVariable "DefaultUserRigths", Null
		CSQLProc_RegisterBuiltInVariable "DefaultGroupRigths", Null
		CSQLProc_RegisterBuiltInVariable "DefaultAllRigths", Null
	End If
	
	
%>