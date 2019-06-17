<%
Function XCData(s)
	XCData = "<![CDATA[" & s & "]]>"
End Function
Class XmlPackedStatus
	Public IsSuccessful,IsProbing, IsReadOnly ' Booleans
	Public Message ' String
	Public ReturnUrl ' String - redirect to
	Public Title ' String - optional addition to Message
	Public ValidationErrors
	Sub Class_Initialize
		Set ValidationErrors = Nothing
		IsSuccessful = true
		IsProbing = false
		IsReadOnly = false
	End Sub
	Public Sub SpoolOut
	%><status issuccessful="<%= IfThenElse(IsSuccessful,"1","0") %>" isreadonly="<%= IfThenElse(IsSuccessful,"1","0") %>" isprobing="<%= IsProbing %>"><%
		If Message <> "" Then
			%><message><%= XMLEncode2(Message) %></message><%
		End If
		If ReturnUrl <> "" Then
			%><returnurl><%= XMLEncode2(ReturnUrl) %></returnurl><%
		End If
		If Title <> "" Then
			%><title><%= XMLEncode2(Title) %></title><%
		End If
		If Not ValidationErrors Is Nothing Then
			%><messages><%= XCData(JSON.Stringify(ValidationErrors)) %></messages><%
		End If
	%></status><%
	End Sub
End Class
Class XmlPackedViews
	Public Normal, Maximized, Minimized
	Public Others
	Sub Class_Initialize
		Set Others = CreateDictionary
	End Sub
	Public Property Get View(n)
		View = Others(n)
	End Property
	Public Property Let View(n, v)
		Others(n) = v
	End Property
	Public Function LoadViewCollectionFromDirectory(sdir, coll)
		Dim I
		For I = 1 To coll.Count
			LoadFromDirectory sdir, coll(I), coll.Key(I)
		Next
	End Function
	Public Function LoadFromDirectory(sdir, sfile, viewName)
		Dim xdir
		xdir = sdir
		If Right(xdir,1) <> "\" Then xdir = xdir & "\"
		If InStr(sfile, "\") > 0 Or InStr(sfile, "/") Or InStr(sfile, ".") > 0 Then
			Exit Function
		End If
		LoadFromFile xdir & sfile & ".html", viewName
	End Function
	Public Function LoadFromFile(sfile, InViewName)
		Dim sf, viewName
		Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
		Dim file, s
		Set file = sf.OpenFile(sfile,&H20)
		file.codepage = 65001
		s = file.ReadText(-2)
		file.Close
		viewName = ConvertTo(vbString, InViewName)
		If viewName = "0" Or viewName = "normal" Then
			Normal = s
		ElseIf viewName = "-1"  Or viewName = "minimized"  Then
			Minimized = s
		ElseIf viewName = "1"  Or viewName = "maximized" Then
			Maximized = s
		Else
			View(viewName) = s
		End If
	End Function
	Public Sub SpoolView(name, view)
		Response.Write "<" & name & ">" & XCData(view) & "</" & name & ">"
	End Sub
	Public Sub SpoolOut
		If Normal <> "" Or Maximized <> "" Or Minimized <> "" Or Others.Count > 0 Then
			%><views><%
			If Normal <> "" Then SpoolView "normal", Normal
			If Maximized <> "" Then SpoolView "maximized", Maximized
			If Minimized <> "" Then SpoolView "minimized", Minimized
			If Others.Count > 0 Then
				For I = 1 To Others.Count
					If Others(I) <> "" Then SpoolView Others.Key(I), Others(I)
				Next
			End If
			%></views><%
		End If
	End Sub
End Class
Class XmlPackedResources
	Public Resources
	Sub Class_Initialize
		Set Resources = CreateDictionary
	End Sub
	Public Property Get Resource(n)
		Resource = Resources(n)
	End Property
	Public Property Let Resource(n, v)
		Resources(n) = v
	End Property
	Public Sub SpoolOut
		If Resources.Count > 0 Then
			%><resources><%= XCData(JSON.Stringify(Resources)) %></resources><%
		End If
	End Sub
End Class
Class XmlPackedLookups
	Public Lookups
	Sub Class_Initialize
		Set Lookups = CreateDictionary
		Lookups.Info = vbObject
	End Sub
	Sub AddKeyValueLookup (name, dict)
		Dim I, o, lkp
		Set lkp = CreateTSRecord
		Lookups.Add name, lkp
		For I = 1 To dict.Count
			Set o = CreateDictionary
			o("key") = dict.Key(I)
			o("value") = dict(I)
			lkp.Add "", o
		Next
	End Sub
	Sub AddToKeyValueLookup (name, key, value)
		Dim lkp
		If IsObject(Lookups(name)) Then
			Set lkp = Lookups(nam)
		Else
			lkp = CreateTSRecord
			Lookups.Add name, lkp
		End If
		Dim o
		Set o = CreateDictionary
		o("key") = key
		o("value") = value
		lkp.Add "", o
	End Sub
	Sub AddSQLiteRecords(name, recs)
		Dim I, lkp
		If IsObject(Lookups(name)) Then
			Set lkp = Lookups(nam)
		Else
			lkp = CreateTSRecord
			Lookups.Add name, lkp
		End If
		
		For I = 1 To recs.Count
			recs(I).Info = vbObject
			lkp.Add "", recs(I)
		Next
	End Sub
	Sub SpoolOut
		If Lookups.Count > 0 Then
		%><lookups><%= XCData(JSON.Stringify(Lookups)) %></lookups><%
		End If
	End Sub
End Class

Class XmlPackedResponse
	Public Status, Views, RViews, Resources, Lookups, Rules, Scripts, Data, MetaData
	Sub Class_Initialize
		Set Status = New XmlPackedStatus
		Set Views = New XmlPackedViews
		Set Resources = New XmlPackedResources
		Set Lookups = New XmlPackedLookups
	End Sub
	Public Sub SpoolOut
		Response.ContentType = "text/xml"
		%><?xml version="1.0" encoding="UTF-8"?>
		<packet>
		<% Status.SpoolOut %>
		<% Views.SpoolOut %>
		<% Resources.SpoolOut %>
		<% Lookups.SpoolOut %>
		<% If IsObject(Data) Then
			If Not data Is Nothing Then
			%><data><%= XCData(JSON.Stringify(Data)) %></data><%
			End If
		ElseIf VarType(Data) = vbString Then
			%><data><%= XCData(Data) %></data><%
		End If %>
		<% If IsObject(MetaData) Then
			If Not MetaData Is Nothing Then
				%><metadata><%= XCData(JSON.Stringify(MetaData)) %></metadata><%
			End If
		ElseIf VarType(MetaData) = vbString Then
			%><metadata><%= XCData(MetaData) %></metadata><%
		End If %>
		</packet>
		<%
	End Sub
	Function CreateDataObject
		Set CreateDataObject = CreateTSSection(Empty)
	End Function
	Function CreateDataArray
		Dim o
		Set o = CreateTSRecord
		o.extractValues = False
		Set CreateDataArray = o
	End Function
	Sub LoadStaticJSON(sfile)
		Dim sf
		Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
		Dim file, s
		Set file = sf.OpenFile(sfile,&H20)
		s = file.ReadText(-2)
		file.Close
		If Len(s) > 0 Then Data = s
	End Sub
	
End Class

Function CreateJSONObject
	Dim o
	Set o = CreateTSSection(Empty)
	Set CreateJSONObject = o
End Function
Function CreateJSONArray
	Dim o
	Set o = CreateTSRecord
	o.extractValues = False
	Set CreateJSONArray = o
End Function
%>