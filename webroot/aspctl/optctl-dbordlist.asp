<%

Class OrdererItem
    Public Field
    Public Caption
End Class


Class OrdererList
    Public Name
    Public ClientId
    Public SkinId
    Public CssClass
    Public Style
    
    Private Fields
    
    Sub Class_Initialize()
        Set Fields = CreateCollection()
    End sub
    
    Sub Init(n)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ' Read the request
        ClientId = NewClientId()
        
        If ASPALL(FieldName).Count > 0 Then
            SortField = ASPALL(FieldName)
        End If
        If ASPALL(DirName).Count > 0 Then
            SortDir = ASPALL(DirName)
        End If
        
        Rendered = False
    End Sub
    
    Function Add(fldName)
        Dim o
        Set o = New OrdererItem
        o.Field = fldName
        o.Caption = fldName
        Fields.Add o.Field, o
        Set Add = o
    End Function
    
    Public Default Property Get Field(idx)
        Dim itm
        If IsEmpty(Fields(idx)) Then
            If VarType(idx) = vbString Then
                Set itm = Add(idx)
            Else
                Err.Raise Error_ItemNotFound,"ASPCTL Framework",Text_ItemNotFound
            End If
        Else
            Set itm = Fields(idx)
        End If
        Set Field = itm
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            HttpGetParams = FieldName & "=" & SortField & "&" & DirName & "=" & SortDir
        Else
            HttpGetParams = ""
        End If
    End Property
    
    ' Post variables
    Private pSortField
    Public Property Get SortField
        Dim f
        If IsObject(ClientScripts) Then 
            f = ConvertTo(vbString, PostVariables.GetCtlVar(Me,"F"))
        Else
            f = ConvertTo(vbString, pSortField)
        End If
        If IsObject(Fields(f)) Then ' For Security purposes - disallows injecting SQL
            SortField = f
        Else
            SortField = ""
        End If
    End Property
    Public Property Let SortField(v)
        If IsObject(ClientScripts) Then 
            PostVariables.SetCtlVar Me, "F", ConvertTo(vbString, v)
        Else
            pSortField = ConvertTo(vbString, v)
        End If
    End Property
    Private pSortDir
    Public Property Get SortDir
        If IsObject(ClientScripts) Then
            SortDir = ConvertTo(vbLong, PostVariables.GetCtlVar(Me,"D"))
        Else
            SortDir = ConvertTo(vbLong, pSortDir)
        End If
    End Property
    Public Property Let SortDir(v)
        If IsObject(ClientScripts) Then
            PostVariables.SetCtlVar Me, "D", ConvertTo(vbLong, v)
        Else
            pSortDir = ConvertTo(vbLong, v)
        End If
    End Property
    
    Public Property Get OrderClause
        If SortField <> "" Then
            If SortDir >= 0 Then
                OrderClause = " ORDER BY " & SortField & " ASC"
            Else
                OrderClause = " ORDER BY " & SortField & " DESC"
            End If
        Else
            OrderClause = ""
        End If
    End Property
    Public Property Get OrderClauseElement
        If SortField <> "" Then
            If SortDir >= 0 Then
                OrderClauseElement = ", " & SortField & " ASC"
            Else
                OrderClauseElement = ", " & SortField & " DESC"
            End If
        Else
            OrderClauseElement = ""
        End If
    End Property
    
    Public Property Get ClassType
        ClassType = "OrdererList"
    End Property
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Property Get FieldClientId
        FieldClientId = ClientId & "Fields"
    End Property
    Public Property Get DirClientId
        DirClientId = ClientId & "Dir"
    End Property
    Public Property Get FieldName
        FieldName = Name & "Field"
    End Property
    Public Property Get DirName
        DirName = Name & "Dir"
    End Property
    
    ' PostBack
    Public Property Let AutoPostBack(v)
        PutControlPostBack Me, "change", v
    End Property
    Public Property Set AutoPostBack(o)
        PutControlPostBack Me, "change", o
    End Property
    Public Property Get AutoPostBack
        AutoPostBack = IsControlPostBackEnabled(Me,"change")
    End Property
    
    ' AsyncPostBack
    Public Property Let AsyncPostBack(uCtl,v)
        PutAsyncControlPostBack Me, "change", uCtl, v
    End Property
    Public Property Set AsyncPostBack(uCtl,o)
        PutAsyncControlPostBack Me, "change", uCtl, o
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = IsAsyncControlPostBackEnabled(Me,"change")
    End Property
    
    Public Sub Render
        Dim s, I
        s = "<span " & " id=""" & ClientId & """>" & vbCrLf
            s = s & "<select name=""" & FieldName & """ id=""" & FieldClientId & """"
            If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
            s = s & StyleAndCssString(CssClass,Style) & ">"  & vbCrLf
                s = s & "<option value=""""></option>" & vbCrLf
                For I = 1 To Fields.Count
                    If UCase(Fields(I).Field) = UCase(SortField) Then
                        s = s & "<option value=""" & Fields(I).Field & """ selected>" & HTMLEncode(Fields(I).Caption) & "</option>" & vbCrLf
                    Else
                        s = s & "<option value=""" & Fields(I).Field & """>" & HTMLEncode(Fields(I).Caption) & "</option>" & vbCrLf
                    End If
                Next
            s = s & "</select>"
            s = s & "<select name=""" & DirName & """ id=""" & DirClientId & """"
            If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(Me)
            s = s & StyleAndCssString(CssClass,Style) & ">"  & vbCrLf
                If SortDir >= 0 Then
                    s = s & "<option value=""1"" selected>" & TR("Ascending") & "</option>" & vbCrLf
                    s = s & "<option value=""-1"">" & TR("Descending") & "</option>" & vbCrLf
                Else
                    s = s & "<option value=""1"">" & TR("Ascending") & "</option>" & vbCrLf
                    s = s & "<option value=""-1"" selected>" & TR("Descending") & "</option>" & vbCrLf
                End If
            s = s & "</select>" & vbCrLf
        s = s & "</span>" & vbCrLf
        Response.Write s
        Rendered = True
    End Sub
        
End Class

Function Create_OrdererList(controlName)
    Set Create_OrdererList = InitControl(New OrdererList, True, controlName)
End Function


%>