<%
	
	' 2 Args 
	' Directory - MapPathed 
	' FileName - Appended to the directory, must not contain any / or \
	Function Func_TextFile(db, args, ByRef IsLiteralResult)
		Func_TextFile = Null
		If args.Count > 1 Then
			Dim path, file, cp
			cp = 0
			path = ConvertTo(vbString, args(1))
			file = ConvertTo(vbString, args(2))
			If args.Count > 2 Then
				cp = ConvertTo(vbLong, args(3))
			End If
			If Len(path) > 0 Then
				path = MapPath(path)
				If Right(path, 1) <> "\" Then path = path & "\"
				If InStr(file, "..\") = 0 And InStr(file, "../") = 0 And Len(file) > 0 Then
					file = Replace(file,"/","\")
					Func_TextFile = ReadTextFile(path & file, cp)
				End If
			End If
		End If
	End Function
	' Argument modifiers
	' modifier: none-smart fetch, @from current row, ? - from query string, ^ - from post, $ - built in, #get, post or anything, * - current_or_parent, ~ - from parent
	
	RegisterSQLFunc "textfile", "Func_TextFile"
	' list - string with integer id-s comma delimited
	Function Func_IDList(db, args, ByRef IsLiteralResult)
		IsLiteralResult = True
		Dim text, arr, I, v
		If args.Count > 0 Then
			text = NullConvertTo(vbString, args(1))
		Else
			Func_IDList = "0"
			Exit Function
		End If
		If (IsNull(text)) Then
			Func_IDList = "0"
		Else
			arr = Split(text,",")
			If IsArray(arr) Then
				text = ""
				For I = LBound(arr) To UBound(arr)
					v = NullConvertTo(vbLong, arr(I))
					If Not IsNull(v) Then
						If Len(text) > 0 Then text = text & ","
						text = text & v
					End If
				Next
				If Len(text) > 0 Then
					Func_IDList = text
				Else
					Func_IDList = "0"
				End If
			Else
				Err.Raise 1102, "Func_IDList", "The parameter cannot be split."
			End If
		End If
	End Function
	RegisterSQLFunc "idlist", "Func_IDList"
	
	Function Func_RandomError(db, args, ByRef IsLiteralResult)
		Dim b, r
		b = 5
		IsLiteralResult = False
		Randomize
		r = Rnd
		If args.Count > 0 Then
			b = ConvertTo(vbLong, args(1))
			If b < 0 Or b > 10 Then b = 5
		End If
		If CLng(10 * r) > b Then Err.Raise 1101, "RandomError", "Random error has been raised intentionally."
		Func_RandomError = CLng(10 * r) & " | " & b & " | " & ConvertTo(vbLong, args(1))
	End Function
	
	RegisterSQLFunc "randomerror", "Func_RandomError"
%>