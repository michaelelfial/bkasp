<%
	' Intended as (usually) intermediary step. Converts to simple xjson which then be further processed with XSLT.

	Class JSONXML
		Private su
		Sub Class_Initialize
			Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
		End Sub
		
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
		
		Private Function EncodeCData(s)
			Dim v
			v = Replace(s, "]]>","]]><![CDATA[]]]]><![CDATA[>]]><![CDATA[")
			EncodeCData = "<![CDATA[" & v & "]]>"
		End Function
		Private Function ISODate(dt)
			
		End Function
		Private Function NameOrIndex(key)
			Dim v
			If VarType(key) = vbLong Or VarType(key) = vbInt Or VarType(key) = vbDouble Or VarType(key) = vbSingle Then
				v = ConvertTo(vbLong, key)
				NameOrIndex = " index=""" & v & """ "
			ElseIf IsNull(key) Or IsEmpty(key) Then
				NameOrIndex = ""
			Else
				v = ConvertTo(vbString, key)
				If Len(v) > 0 Then
					NameOrIndex = " name=""" & v & """ "
				Else
					NameOrIndex = ""
				End If
			End If
		End Function
		Private Function OutputValue(n, key)
			OutputValue = Empty
			Dim k
			k = NameOrIndex(key)
			Select Case VarType(n)
				Case vbEmpty
					OutputValue = su.Sprintf("<null%s/>", k)
				Case vbNull
					OutputValue = su.Sprintf("<null%s/>", k)
				Case vbInteger
					OutputValue = su.Sprintf("<number subtype=""int""%s>%d</number>",k,n)
				Case vbLong
					OutputValue = su.Sprintf("<number subtype=""long""$s>%d</number>",k,n)
				Case vbSingle
					OutputValue = su.Sprintf("<number subtype=""float""%s>%M</number>",k,n)
				Case vbDouble
					OutputValue = su.Sprintf("<number subtype=""double""%s>%M</number>",k,n)
				Case vbCurrency
					OutputValue = su.Sprintf("<number subtype=""double""%s>%M</number>",k,CDbl(n))
				Case vbString
					OutputValue = su.Sprintf("<string%s>",k) & EncodeCData(n) & "</string>"
				Case vbBoolean
					If n Then OutputValue = su.Sprintf("<boolean%s>true</boolean>",k) Else OutputValue = su.Sprintf("<boolean%s>false</boolean>",k)
				Case vbDate
					OutputValue = su.Sprintf("<date subtype=""iso""%s>%04d-%02d-%02dT%02:%02:%02</date>",k, Year(n), Month(n), Day(n), Hour(n), Minute(n), Second(n))
			End Select
		End Function
		Private Function OutputElement(e, key)
			OutputElement = Empty
			Dim t
			t = ElementType(e)
			Dim k
			k = NameOrIndex(key)
			Select Case t
				Case JSON_Value
					OutputElement = OutputValue(e, key)
				Case JSON_Object
					OutputElement = StringifyObject(e, key)
				Case JSON_Array
					OutputElement = StringifyArray(e, True, key)
				Case JSON_Null
					OutputElement = su.Sprintf("<null%s/>", k)
				Case JSON_ObjectArray
					OutputElement = StringifyArray(e, False, key)
			End Select
		End Function
		
		Private Function StringifyArray(obj, bArr, key)
			Dim I, s, v
			Dim k
			k = NameOrIndex(key)
			s = su.Sprintf("<array%s>", k)
			If bArr Then
				For I = LBound(obj) To UBound(obj)
					v = OutputElement(obj(I), I)
					If Not IsEmpty(v) Then
						If Len(s) > 1 Then s = s & vbCrLf
						s = s & v
					End If
				Next
			Else
				For I = 1 To obj.Count
					v = OutputElement(obj(I), I)
					If Not IsEmpty(v) Then
						If Len(s) > 1 Then s = s & vbCrLf
						s = s & v
					End If
				Next
			End If
			s = s & "</array>"
			StringifyArray = s
		End Function
		Public Function StringifyObject(obj, key)
			Dim I, s, v
			Dim k
			k = NameOrIndex(key)
			s = su.Sprintf("<object%s>", k)
			For I = 1 To obj.Count
				v = OutputElement(obj(I), obj.Key(I))
				If Not IsEmpty(v) Then
					s = s & v & vbCrLf
				End If
			Next
			s = s & "</object>"
			StringifyObject = s
		End Function
		
		
		Function ToXML(js)
			ToXml = "<?xml version=""1.0"" encoding=""utf-8""?>" & vbCrLf & OutputElement(js, Null)
		End Function
		
		
End Class
%>