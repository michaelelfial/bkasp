<%
Const JSON_Unknown = -1
Const JSON_Value = 0
Const JSON_Object = 1
Const JSON_Array = 2
Const JSON_Null = 3
Const JSON_ObjectArray = 4

Class IntegerParser
	Public Charset
	Sub Class_Initialize
		Charset = "0123456789abcdefghijklmnopqrstuvwxyz"
	End Sub
	Function TryParseLng(s, base, result)
		Dim str 
		str = Trim(LCase(s))
		Dim I, r, n, l, c
		r = 0
		l = Len(str)
		TryParseLng = False
		For I = 0 To l - 1
			c = Mid(str,l - I,1)
			n = InStr(Charset, c)
			If n > 0 And n <= base Then
				n = (n - 1) * (base ^ I)
				r = r + n
			Else
				If I = l - 1 Then
					If c = "+" Then
						result = r
						TryParseLng = True
						Exit Function
					ElseIf c = "-" Then
						result = -r
						TryParseLng = True
						Exit Function
					Else
						Exit Function
					End If
				Else
					Exit Function
				End If 
			End If
		Next
		result = r
		TryParseLng = True
	End Function
	Function NullParseLng(s,base)
		Dim result
		If TryParseLng(s, base, result) Then
			NullParseLng = result
		Else
			NullParseLng = Null
		End If
	End Function
	Function ParseLng(s,base)
		Dim result
		If TryParseLng(s, base, result) Then
			NullParseLng = result
		Else
			Err.Raise 1, "IntegerParser", "Failed to parse as integer " & s
		End If
	End Function
End Class

Class JSONProc
    Private vd, su, cf, tc, intparser
	Private JSONMSDateTimeFmtRe
    Sub Class_Initialize
        Set vd = Server.CreateObject("newObjects.utilctls.VarDictionary")
        Set su = Server.CreateObject("newObjects.utilctls.StringUTilities")
        Set cf = Server.CreateObject("newObjects.utilctls.ConfigFile")
        Set tc = Server.CreateObject("newObjects.utilctls.TypeConvertor")
        Set reToken = New RegExp
        reToken.Global = True
        reToken.Pattern = "(?:""((?:[^""\\]|\\""|\\(?!""))*)"")|((?:\+|\-)?\d+(?:\.\d*(?:e|E(?:\+|\-)?\d+)?)?)|(true)|(false)|(null)|(:)|({)|(\})|(\[)|(\])|(,)|([A-Za-z][A-Za-z0-9_]*)"
		Set reEscapes = New RegExp
		reEscapes.Global = True
		reEscapes.Pattern = "(\\\\)|(\\n)|(\\"")|(\\/)|(\\b)|(\\f)|(\\r)|(\\t)|(?:\\u([a-fA-F0-9]{4}))"
		Set JSONMSDateTimeFmtRe = New RegExp
		JSONMSDateTimeFmtRe.Global = True
		JSONMSDateTimeFmtRe.IgnoreCase = True
		JSONMSDateTimeFmtRe.Pattern = "\\{1,2}\/Date\(([+\-]?\d+)\)\\{1,2}\/"
		Set intparser = New IntegerParser
    End Sub
	
	' Utilities
	Function ParseHexNumber(str)
		Dim I, s
		s = LCase(str)
		For I = Len(str) To 1 Step -1
			
		Next
	End Function
	
	
	
	
    ' JSON serialization
    Private Function ElementType(v)
        If IsObject(v) Then
			If v Is Nothing Then
				ElementType = JSON_Null
			ElseIf IsObject(v.Info) Then
                If v.Info.Type Then
                    ElementType = JSON_Object
                Else
                    ElementType = JSON_ObjectArray
                End If
            Else
                If v.Info = vbObject Then
                    ElementType = JSON_Object
                ElseIf v.Info = vbArray Then
                    ElementType = JSON_ObjectArray
                Else
                    ElementType = JSON_Object
                End If
            End If                
        ElseIf IsArray(v) Then
            ElementType = JSON_Array
        Else
            ElementType = JSON_Value
        End If
    End Function
    
    Private Function OutputString(s)
        Dim v
		v = Replace(s, "\", "\\")
        v = Replace(v, """", "\""")
        v = Replace(v, vbTab, "\t")
        v = Replace(v, vbCr, "\r")
        v = Replace(v, vbLf, "\n")
        OutputString = """" & v & """"
    End Function
    Private Function OutputValue(n)
        OutputValue = Empty
        Select Case VarType(n)
            Case vbEmpty
                OutputValue = "null"
            Case vbNull
                OutputValue = "null"
            Case vbInteger
                OutputValue = su.Sprintf("%d",n)
            Case vbLong
                OutputValue = su.Sprintf("%d",n)
            Case vbSingle
                OutputValue = su.Sprintf("%M",n)
            Case vbDouble
                OutputValue = su.Sprintf("%M",n)
            Case vbCurrency
                OutputValue = su.Sprintf("%M",CDbl(n))
            Case vbString
                OutputValue = OutputString(n)
            Case vbBoolean
                If n Then OutputValue = "true" Else OutputValue = "false"
			Case vbDate
				OutputValue = """\/Date(" & JSMilliseconds(n,False) & ")\/"""
        End Select
    End Function
    Private Function OutputElement(e)
        OutputElement = Empty
        Dim t
        t = ElementType(e)
        Select Case t
            Case JSON_Value
                OutputElement = OutputValue(e)
            Case JSON_Object
                OutputElement = StringifyObject(e)
            Case JSON_Array
                OutputElement = StringifyArray(e, True)
            Case JSON_Null
                OutputElement = "null"
            Case JSON_ObjectArray
                OutputElement = StringifyArray(e, False)
        End Select
    End Function
    
    Private Function StringifyArray(obj, bArr)
        Dim I, s, v
        s = "["
        If bArr Then
            For I = LBound(obj) To UBound(obj)
                v = OutputElement(obj(I))
                If Not IsEmpty(v) Then
                    If Len(s) > 1 Then s = s & ","
                    s = s & v
                End If
            Next
        Else
            For I = 1 To obj.Count
                v = OutputElement(obj(I))
                If Not IsEmpty(v) Then
                    If Len(s) > 1 Then s = s & ","
                    s = s & v
                End If
            Next
        End If
        s = s & "]"
        StringifyArray = s
    End Function
    Public Function StringifyObject(obj)
        Dim I, s, v
        s = "{"
        For I = 1 To obj.Count
            v = OutputElement(obj(I))
            If Not IsEmpty(v) Then
                If Len(s) > 1 Then s = s & ","
                s = s & OutputString(obj.Key(I)) & ":" & v
            End If
        Next
        s = s & "}"
        StringifyObject = s
    End Function
    
    ' JSON deserialization
    Private pos, src, tokenType
    Private reToken
    Private Function GetTokens
        ' "(?:""((?:[^""\\]|\\""|\\(?!""))*)"")|((?:\+|\-)?\d+(?:\.\d*(?:e|E(?:\+|\-)?\d+)?)?)|(true)|(false)|(null)|(:)|(\{)|(\})|(\[)|(\])|(,)"
        Set GetToken = reToken.Execute(src)
    End Function
    Public Function ReplaceEscape(istr, r, v)
        Dim str
        str = " " & istr
        Dim re
        Set re = New RegExp
        re.Global = True
        re.Pattern = r
        str = re.Replace(str, "$1" & v)
        ReplaceEscape = Mid(str, 2)
    End Function
	Private reEscapes ' "(\\n)|(\\"")|(\\\\)|(\\/)|(\\b)|(\\f)|(\\r)|(\\t)|(?:\\u([a-fA-F0-9]{4}))"
	Private Function UnescapeString(str)
		Dim matshes, m, I, J, nPos, result, token, n
		nPos = 1
		Set matches = reEscapes.Execute(str)
		result = ""
		For I = 0 To matches.Count - 1
			Set m = matches(I)
			result = result & Mid(str, nPos, m.FirstIndex + 1 - nPos)
			nPos = m.FirstIndex + 1 + m.Length
			For J = 0 To m.Submatches.Count - 1
				token = m.Submatches(J)
				If Len(token) > 0 Then
					Select Case J
						Case 0 ' \\
							result = result & "\"
						Case 1 ' \n
							result = result & vbLf
						Case 2 ' \"
							result = result & """"
						Case 3 ' \/
							result = result & "/"
						Case 4 ' \b
							result = result & Chr(8)
						Case 5 ' \f
							result = result & vbFormFeed
						Case 6 ' \r
							result = result & vbCr
						Case 7 ' \t
							result = result & vbTab
						Case 8 ' \uXXXX
							n = intparser.NullParseLng(token,16)
							If Not IsNull(n) Then
								result = result & ChrW(n)
							End If
					End Select
				End If
			Next
		Next
		result = result & Mid(str,nPos)
		UnescapeString = result
	End Function
    Private Function SetElement(current, key, element, elType, val)
        If elType = vbObject Then ' Array or Object
            Set val = element
        ElseIf elType = vbDouble Then ' Any number
            If InStr(element, ".") > 0 Then ' Double
               val = tc.TryConvertTo(vbDouble, element) 
            Else
               val = tc.TryConvertTo(vbLong, element) 
            End If
        ElseIf elType = vbString Then ' String
            val = tc.TryConvertTo(vbString, element)
            If Not IsNull(val) Then
				val = UnescapeString(val)
            End If
        ElseIf elType = vbBoolean Then ' Boolean
            val = tc.TryConvertTo(vbBoolean, element)
        ElseIf elType = vbNull Then ' Null
            val = Null
        End If    
        
        SetElement = True
        If Not current Is Nothing Then    
            SetElement = False
            If current.Info.Type Then ' Object
                current.Add key, val
            Else ' Array
                current.Add "", val
            End If
        End If
    End Function
    
    Public Function ConvertNode(arr)
		Dim I, x
		x = Null
		If IsArray(arr) Then
			Set x = cf.CreateRecord
            x.extractValues = False
			For I = LBound(arr) To UBound(arr)
				x.Add "", arr(I)
			Next
		End If
		Set ConvertNode = x
	End Function
    
    
    Public Function Stringify(data)
        Stringify = OutputElement(data)
    End Function
    Public LastError
	Private Function JSONMSDateMilliseconds(str) ' returns Null if it is not a datetime string
		Dim ms
		JSONMSDateMilliseconds = Null
		Set ms = JSONMSDateTimeFmtRe.Execute(str)
		If Not ms Is Nothing Then
			If ms.Count > 0 Then
				JSONMSDateMilliseconds = NullConvertTo(vbDouble, ms(0).Submatches(0))
			End If
		End If
	End Function
    Public Function Parse(str)
        Dim I, token, tokens
        Dim stack, current, result, x, key, val, expectKey, expectValue
        LastError = Empty
        Set stack = vd.CreateNewStack
        Set stack.Missing = Nothing
        Set current = Nothing
        Set tokens = reToken.Execute(str)
        expectKey = False
        expectValue = True
        key = ""
        For I = 0 To tokens.Count - 1
            Set token = tokens(I).Submatches
            If Len(token(0)) > 0 Then ' String
                If current Is Nothing Then
                    ' Error
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " outside of an object or array at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If expectKey Then
                    SetElement Nothing, key, token(0), vbString, val
                    key = val
                    expectKey = false
                    expectValue = false ' We need : still
                Else
                    If expectValue Then
						x = JSONMSDateMilliseconds(token(0))
						If IsNull(x) Then
							SetElement current, key, token(0), vbString, val
						Else
							SetElement current, key, token(0), vbDate, FromJSMilliseconds(x,False)
						End If
                        expectValue = False
                    Else
                        Set Parse = Nothing
                        LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                        Exit Function
                    End If
                End If
            ElseIf Len(token(1)) > 0 Then ' Number
                If current Is Nothing Then
                    ' Error
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " outside of an object or array at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If expectKey Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " found but key was expected at pos " & tokens(I).FirstIndex
                    Exit Function
                Else
                    If expectValue Then
                        SetElement current, key, token(1), vbDouble, val
                        expectValue = False
                    Else
                        Set Parse = Nothing
                        LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                        Exit Function
                    End If
                End If
            ElseIf Len(token(2)) > 0 Then ' true
                If current Is Nothing Then
                    ' Error
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " outside of an object or array at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If expectKey Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " found but key was expected at pos " & tokens(I).FirstIndex
                    Exit Function
                Else
                    If expectValue Then
                        SetElement current, key, True, vbBoolean, val
                        expectValue = False
                    Else
                        Set Parse = Nothing
                        LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                        Exit Function
                    End If
                End If
            ElseIf Len(token(3)) > 0 Then ' false
                If current Is Nothing Then
                    ' Error
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " outside of an object or array at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If expectKey Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " found but key was expected at pos " & tokens(I).FirstIndex
                    Exit Function
                Else
                    If expectValue Then
                        SetElement current, key, False, vbBoolean, val
                        expectValue = False
                    Else
                        Set Parse = Nothing
                        LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                        Exit Function
                    End If
                End If
            ElseIf Len(token(4)) > 0 Then ' null
                If current Is Nothing Then
                    ' Error
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " outside of an object or array at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If expectKey Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " found but key was expected at pos " & tokens(I).FirstIndex
                    Exit Function
                Else
                    If expectValue Then
                        SetElement current, key, Null, vbNull, val
                        expectValue = False
                    Else
                        Set Parse = Nothing
                        LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                        Exit Function
                    End If
                End If
            ElseIf Len(token(5)) > 0 Then ' :
                If current Is Nothing Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " not expected outside object, pos " & token.FirstIndex
                    Exit Function
                End If
                If expectKey Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " found is not preceded by key at pos " & token.FirstIndex
                    Exit Function
                End If
                If Not current.Info.Type Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " found inside of an array at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                expectValue = True
                expectKey = False
            ElseIf Len(token(6)) > 0 Then ' {
                Set x = cf.CreateSection
                If expectValue Then
                    SetElement current, key, x, vbObject, val
                Else
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                stack.Push x
                Set current = x
                key = ""
                expectKey = True ' name is expected
                expectValue = False
            ElseIf Len(token(7)) > 0 Then ' }
                If current Is Nothing Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If Not current.Info.Type Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " not expected inside of an array at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If stack.Count = 1 Then ' Closing successfuly
                    Set Parse = current
                    LastError = Empty
                    Exit Function
                End If
                stack.Pull
                Set current = stack.Top
                expectKey = False
                expectValue = False
            ElseIf Len(token(8)) > 0 Then ' [
                Set x = cf.CreateRecord
                x.extractValues = False
                If expectValue Then
                    SetElement current, key, x, vbObject, val
                Else
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                stack.Push x
                Set current = x
                key = ""
                expectKey = False
                expectValue = True
            ElseIf Len(token(9)) > 0 Then ' ]
                If current Is Nothing Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If current.Info.Type Then
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " not expected inside of an object at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If stack.Count = 1 Then ' Closing successfuly
                    Set Parse = current
                    LastError = Empty
                    Exit Function
                End If
                stack.Pull
                Set current = stack.Top
                expectKey = False
                expectValue = False
            ElseIf Len(token(10)) > 0 Then ' ,
                key = ""
                expectKey = False
                If Not current Is Nothing Then
                    If current.Info.Type Then
                        expectKey = True ' name is expected
                        expectValue = False
                    Else
                        expectKey = False ' name is expected
                        expectValue = True
                    End If
                End If
			ElseIf Len(token(11)) > 0 Then 'Literal ([A-Za-z][A-Za-z0-9_]*)
				If current Is Nothing Then
                    ' Error
                    Set Parse = Nothing
                    LastError = tokens(I).Value & " outside of an object or array at pos " & tokens(I).FirstIndex
                    Exit Function
                End If
                If expectKey Then
                    SetElement Nothing, key, token(11), vbString, val
                    key = val
                    expectKey = false
                    expectValue = false ' We need : still
                Else
					Set Parse = Nothing
					LastError = tokens(I).Value & " not expected at pos " & tokens(I).FirstIndex
					Exit Function
                End If
            End If
        Next
        ' If we are here something is wrong
        Set Parse = Nothing
        LastError = "Syntax error. Some objects or arrays are not closed. Current depth=" & stack.Count
    End Function
End Class
%>



<%
' TEST
' Set vd = Server.CreateObject("newObjects.utilctls.VarDictionary")
' Set cf = Server.CreateObject("newObjects.utilctls.ConfigFile")

' Set o = vd.CreateNewList
' o.Add "Alpha", """abcde efg hij kl"" SDFSDF"" SDFS"""
' o.Add "Beta", 15.453534
' o.Add "Gamma", 15.453534E100
' o.Add "Delta", 1234
' Set o1 = vd.CreateNewList
' o.Add "Etta", o1
' o1.Add "A", "assdf"
' o1.Add "BB", 12313
' o1 = Array(1,"23424",Array(1,2,"3"),234.234)
' Set o1 = cf.CreateRecord
  ' o1.extractValues = False
  ' o1.Add "", 1
  ' o1.Add "", "12313"
  ' Set o2 = cf.CreateRecord
    ' o2.Add "", 1
    ' o2.Add "", 2
    ' o2.Add "", "3"
  ' o1.Add "", o2
  ' o1.Add "", 234.234
' o.Add "An Array", o1
' Set o1 = vd.CreateNewList
' o1.Info = vbArray
' o1.Add "", "El 1"
' o1.Add "", "El 2"
' o1.Add "", 3
' o.Add "Another Array", o1

' Set JSON = New JSONProc
' ss = JSON.Stringify(o)
' WScript.Echo ss
' WScript.Echo "==============================================================="
' Set parsed = JSON.Parse(ss)
' If parsed Is Nothing Then
    ' WScript.Echo "Parse error: " & JSON.LastError
' Else
    ' WScript.Echo "Parse successful"
    ' ss = JSON.Stringify(parsed)
    ' WScript.Echo "==============================================================="
    ' WScript.Echo ss
' End If


' JSON Data helper
Class JSONData
	Public Data
	Sub Class_Initialize
		Set Data = Nothing
	End Sub
	Public Function ConvertNode(arr)
		Dim I, x
		x = Null
		If IsArray(arr) Then
			Set x = cf.CreateRecord
            x.extractValues = False
			For I = LBound(arr) To UBound(arr)
				x.Add "", arr(I)
			Next
		End If
		Set ConvertNode = x
	End Function
	Public Property Get Value(vname)
		Value = Data(vname)
	End Property
	Public Property Let Value(vname ,v)
		Data(vname) = v
	End Property
	Public Function AddAsObject(r)
		Dim o, I
		Set o = CreateDataObject(Empty)
		For I = 1 To r.Count
			o.Value(r.Key(I)) = r(I)
		Next
		Set AddAsObject = o
	End Function
	Function NavigateTo(path)
		Dim re, matches, I, match, otoken, atoken, newdata, node, idx, temp
		Set newdata = New JSONData
		Set node = Data
		Set re = New RegExp
		re.Global = True
        re.Pattern = "(?:(?:\.|\]|^)([^\.\[]+))|(?:\[([^\]+)\])"
		Set matches = re.Execute(str)
		If matches.Count = 0 Then
			Set NavigateTo = newdata
			Exit Function
		End If
		For I = 0 To matches.Count - 1
			Set match = matches(I)
			otoken = match.Submatches(0)
			atoken = match.Submatches(1)
			if Len(otoken) > 0 Then
				If IsObject(node(otoken)) Then 
					Set node = node(otoken)
				ElseIf IsArray(node(otoken)) Then
					Set temp = ConvertNode(node(idx))
					If IsObject(temp) Then
						Set node(idx)= temp
					Else
						node(idx) = Null
						Set node = Nothing
						Exit For
					End If
				Else
					Set node = Nothing
					Exit For
				End If
			ElseIf Len(atoken) > 0 Then
				idx = TryConvertTo(vbLong, atoken)
				If IsNull(idx) Then ' Try as string
					If IsObject(node(atoken)) Then 
						Set node = node(atoken)
					ElseIf IsArray(node(atoken)) Then
						Set temp = ConvertNode(node(atoken))
						If IsObject(temp) Then
							Set node(atoken)= temp
						Else
							node(atoken) = Null
							Set node = Nothing
							Exit For
						End If
					Else
						Set node = Nothing
						Exit For
					End If
				Else ' as index
					If IsObject(node(idx)) Then
						Set node = node(idx)
					ElseIf IsArray(node(idx)) Then
						Set temp = ConvertNode(node(idx))
						If IsObject(temp) Then
							Set node(idx)= temp
						Else
							node(idx) = Null
							Set node = Nothing
							Exit For
						End If
					Else
						Set node = Nothing
						Exit For
					End If
				End If
			End If
		Next
		Set newdata.Data = node
		Set NavigateTo = newdata
	End Function
	Function CreateDataObject(name)
		Dim o
		Set o = New JSONData
		Set o.Data = CreateTSSection(Empty)
		If Not IsEmpty(name) And Not IsNull(name) Then
			Set Data(name) = o.Data
		Else
			Data.Add "", o.Data
		End If
		Set CreateDataObject = o
	End Function
	Function CreateDataArray(name)
		Dim o
		Set o = New JSONData
		Set o.Data = CreateTSRecord
		o.Data.extractValues = False
		If Not IsEmpty(name) And Not IsNull(name) Then
			Set Data(name) = o.Data
		Else
			Data.Add "", o.Data
		End If
		Set CreateDataArray = o
	End Function
End Class
Function WrapJSONData(d)
	Dim o
	Set o = New JSONData
	If IsObject(d) Then
		Set o.Data = d
	ElseIf IsArray(d) Then
		o.Data = d
	Else
		Set o = Nothing
	End If
	Set WrapJSONData = o
End Function
Function EmptyJSONData
	Dim o
	Set o = New JSONData
	Set o.Data = CreateTSSection(Empty)
	Set EmptyJSONData = o
End Function
%>


