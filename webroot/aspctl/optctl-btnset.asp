<%

Sub CRadioList_ClientScripts(sKey,appData)
%>
    <script type="text/javascript">
        function ASPCTL_CRadioList_Visibility(e,idset) {
            var s, j, i, ids,l;
            for (var j in idset) {
                ids = idset[j].split(",");
                l = EL(j);
                if (l != null) {
                    if (EL(j).checked) { 
                        for (i = 0;i < ids.length;i++) {
                            EL(ids[i]).style.display = "block";
                        }
                    } else {
                        for (i = 0;i < ids.length;i++) {
                            EL(ids[i]).style.display = "none";
                        }
                    }
                }
            }
        }
    </script>
<%
End Sub

Class RadioBtn
    Private pParent ' Parent list
    Public Checked ' Boolean
    Public ClientId ' String
    Public Value ' The value for this checkbox/radiobutton
    Private Rendered ' Boolean
    Public Caption ' String
    Public SkinId
    Public Hide
    Public pShowList
    
    Sub Class_Initialize
        Set pShowList = CreateList
    End Sub
    
    Public Sub Init(aParent,aValue)
        Set pParent = aParent
        SkinId = aParent.SkinId
        ClientId = pParent.NewItemClientId
        Checked = False
        Value = aValue
        Dim I,vals
        Set vals = ASPALL(pParent.Name)
        For I = 1 to vals.Count
            If vals(I) = ConvertTo(vbString, Value) Then 
                Checked = True 
                Exit For
            End If
        Next
        If Checked Then
            pParent.Selected.Add Value, Me
        End If
    End Sub
    
    Public Sub ShowControl(c,bShow)
        If bShow Then
            pShowList.Add c.Name, c
            pParent.ShowHideControls = True
        Else
            pShowList.Remove c.Name
        End If
    End Sub
    ' Internal
    Public Function GetShowHideIdList
        Dim s, I
        s = ""
        For I = 1 To pShowList.Count
            If Len(s) > 0 Then s = s & ","
            s = s & pShowList(I).ClientId
        Next
        GetShowHideIdList = s
    End Function
    
    Public Property Get ClassType
        ClassType = "RadioBtn"
    End Property
    
    Public Property Get Parent
        Set Parent = pParent
    End Property
    Public Property Get Name
        Name = Parent.Name
    End Property
    
    Public Function PreserveState()
        Dim ts
        Set ts = CreateTSSection(Empty)
        ts("V") = ConvertTo(vbString,Value)
        ts("C") = ConvertTo(vbString,Caption)
        Set PreserveState = ts
    End Function
    
    Public Sub Restore(aParent,ts)
        Set pParent = aParent
        SkinId = aParent.SkinId
        ClientId = pParent.NewItemClientId
        Checked = False
        Value = ConvertTo(vbString,ts("V"))
        Caption = ConvertTo(vbString,ts("C"))
        Dim I,vals
        Set vals = ASPALL(pParent.Name)
        For I = 1 to vals.Count
            If vals(I) = ConvertTo(vbString, Value) Then 
                Checked = True 
                Exit For
            End If
        Next
        If Checked Then
            pParent.Selected.Add Value, Me
        End If
    End Sub
    
    ' PostBack
    Public Property Let AutoPostBack(v)
        parent.AutoPostBack = v
    End Property
    Public Property Set AutoPostBack(o)
        Set parent.AutoPostBack = o
    End Property
    Public Property Get AutoPostBack
        AutoPostBack = parent.AutoPostBack
    End Property
    
    Public Sub Render
        If Hide Then Exit Sub
        Dim s
        Dim inputType
        If pParent.MultiSelect Then inputType = "checkbox" Else inputType = "radio"
        
        s = "<input type=""" & inputType & """ name=""" & pParent.Name & """ id=""" & Me.ClientId & """"
        If Not IsEmpty(pParent.CssClass) Then s = s & " class=""" & pParent.CssClass & """"
        If Not IsEmpty(pParent.Style) Then s = s & " style=""" & pParent.Style & """"
        s = s & " value=""" & Me.Value & """"
        If Me.Checked Then
            s = s & " checked"
        End If
        s = s & RenderAttributes(pParent.Attributes)
        If IsObject(ClientScripts) Then s = s & ClientScripts.RenderControlEventHandlers(pParent)
        s = s & "/>"
        If Not IsEmpty(Me.Caption) Then 
            s = s & " <label"
            If Not IsEmpty(pParent.CssClass) Then s = s & " class=""" & pParent.CssClass & """"
            s = s & " style=""cursor: pointer;"
            If Not IsEmpty(pParent.Style) Then s = s & " " & pParent.Style
            s = s & """"
            s = s & " for=""" & Me.ClientId & """>" & Server.HTMLEncode(Me.Caption) & "</label>"
        End If
        
        Response.Write s
        Rendered = True
    End Sub

End Class

Class CRadioList
    Dim Name ' String
    Public Items ' Collection
    Public Selected ' Selected values
    Public MultiSelect
    
    Public CssClass ' CSS Class names
    Public Style ' CSS explicit style settings
    Public ClientId ' This ClientId is used only for the whole set
    ' Public Caption
    Public Size
    Public Direction ' Horizontal, Vertical
    Private Rendered
    Public SkinId
    Public PreserveOptions
    Public Hide
    
    Private ClientIdCounter
    
    Sub Class_Initialize
        Set Items = CreateCollection()
        Set Selected = CreateCollection()
        Size = 1
        MultiSelect = False
        Direction = "Horizontal"
        PreserveOptions = False
        ClientIdCounter = 0
    End Sub
    Sub Init(n,numItems)
        If IsEmpty(n) Then
            Me.Name = NewCtlName()
        Else
            Me.Name = n
        End If
        ClientId = NewClientId()
        
        If ASPALL(Name & "_Options").Count > 0 Then
            ' Init from the preserved state
            Dim ts, itms, I, o
            Set ts = TSFromHex(ASPALL(Name & "_Options"), EncryptSecondaryData)
            Direction = ConvertTo(vbString,ts("D"))
            Size = ConvertTo(vbLong,ts("S"))
            If ConvertTo(vbLong,ts("M")) <> 0 Then MultiSelect = True
            Set itms = ts("Items")
            For I = 1 To itms.Count
                Set o = New RadioBtn
                o.Restore Me, itms(I)
                Items.Add o.Value, o
            Next
        End If
        Rendered = False
    End Sub
    
    Function NewItemClientId
        NewItemClientId = ClientId & "_" & ClientIdCounter
        ClientIdCounter = ClientIdCounter + 1
    End Function
    
    Private pShowHideControls
    Public Property Get ShowHideControls
        ShowHideControls = pShowHideControls
    End Property
    Public Property Let ShowHideControls(v)
        pShowHideControls = v
        If v Then
            If IsObject(ClientScripts) Then
                ClientScripts.RegisterProcedure "CRadioListSH", "CRadioList_ClientScripts", Empty
                RegisterForPrerender Me
            End If
        End If
    End Property
    
    Public Property Get ClassType
        ClassType = "CRadioList"
    End Property
    
    Public Sub AddItem(aValue,capt)
        Dim o
        Set o = New RadioBtn
        o.Init Me, aValue
        o.Caption = capt
        Items.Add aValue, o
        Controls.Add o.Name, o
    End Sub
    Public Sub AddItems(itms)
        Dim I
        For I = 1 To itms.Count
            AddItem itms.Key(I), itms(I)
        Next
    End Sub
    Public Sub AddValue(aValue)
        Dim o
        Set o = New RadioBtn
        o.Init Me, aValue
        Items.Add aValue, o
        Controls.Add o.Name, o
    End Sub
    Public Sub AddSQLiteItems(results,valField,textField)
        Dim I
        If IsEmpty(textField) Or IsNull(textField) Then
            For I = 1 To results.Count
                AddValue results(I)(valField)
            Next    
        Else
            For I = 1 To results.Count
                AddItem results(I)(valField), results(I)(textField)
            Next    
        End If
    End Sub
    Public Sub SelectSQLiteItems(results,valField,selectField)
        Dim I
        ClearSelection
        For I = 1 To results.Count
            If IsObject(Items( ConvertTo(vbString, results(I)(valField)))) Then
                Items( ConvertTo(vbString, results(I)(valField))).Checked = ConvertTo(vbBoolean, results(I)(selectField))
            End If
        Next    
    End Sub
    
    Public Property Get SelectedIndex
        SelectedIndex = 0
        Dim I
        For I = 1 To Items.Count
            If Items(I).Checked Then
                SelectedIndex = I
                Exit Property
            End If
        Next
    End Property
    Public Property Let SelectedIndex(v)
        ClearSelection
        Dim I
        I = ConvertTo(vbLong,v)
        If I > 0 And I <= Items.Count Then
            Items(I).Checked = True
            Selected.Add Items(I).Value, Items(I)
        End If
    End Property
    Public Property Get SelectedItem
        Set SelectedItem = Nothing
        Dim I
        For I = 1 To Items.Count
            If Items(I).Checked Then
                Set SelectedItem = Items(I)
                Exit Property
            End If
        Next
    End Property
    Public Property Get SelectedValue
        SelectedValue = Empty
        Dim si
        Set si = SelectedItem
        If Not si Is Nothing Then SelectedValue = si.Value
    End Property
    Public Property Let SelectedValue(v)
        ClearSelection
        Dim theVal
        theVal = ConvertTo(vbString,v)
        Dim I
        If theVal <> "" Then
            For I = 1 To Items.Count
                If ConvertTo(vbString,Items(I).Value) = theVal Then
                    Items(I).Checked = True
                    Selected.Add Items(I).Value, Items(I)
                    Exit For
                End If
            Next    
        End If
    End Property
    Public Property Get Checked(vv)
        If IsObject(Items(vv)) Then
            Checked = Items(vv).Checked
        Else
            Checked = False
        End If
    End Property
    Public Property Let Checked(vv,v)
        If Not MultiSelect Then
            If (v) Then 
                SelectedValue = vv
            Else
                ClearSelection
            End If
        Else
            If IsObject(Items(vv)) Then
                Items(vv).Checked = v
                Set Selected(vv) = Items(vv)
            End If
        End If
    End Property
    Public Property Get Value
        Value = SelectedValue
    End Property
    Public Property Let Value(v)
        SelectedValue = v
    End Property
    Public Function SelectedAsString(sep)
        Dim I,s
        s = ""
        For I = 1 To Items.Count
            If Items(I).Checked Then
                If s <> "" Then s = s & sep
                s = s & Items(I).Value
            End If
        Next
        SelectedAsString = s
    End Function
    
    Public Sub RemoveAll
        Items.Clear
        Selected.Clear
    End Sub
    Public Sub ClearSelection
        Selected.Clear
        Dim I
        For I = 1 To Items.Count
            Items(I).Checked = False
        Next
    End Sub
    Public Property Get SelectedCount
        Dim c, I
        c = 0
        For I = 1 to Items.Count
            If Items(I).Checked Then c = c + 1
        Next
        SelectedCount = c
    End Property
    
    Public PreserveInQueryString
    Public Property Get HttpGetParams
        If ConvertTo(vbBoolean,PreserveInQueryString) Then
            Dim s, I
            s = ""
            For I = 1 To Items.Count
                If Items(I).Checked Then
                    If s <> "" Then s = s & "&"
                    s = s & Name & "=" & Items(I).Value
                End If
            Next
            HttpGetParams = s
        Else
            HttpGetParams = ""
        End If
    End Property
    
    ' PostBack
    
    Public Property Let AutoPostBack(v)
        PutControlPostBack Me, "click", v
    End Property
    Public Property Set AutoPostBack(o)
        PutControlPostBack Me, "click", o
    End Property
    Public Property Get AutoPostBack
        AutoPostBack = IsControlPostBackEnabled(Me,"click")
    End Property
    
    ' AsyncPostBack
    Public Property Let AsyncPostBack(uCtl,v)
        PutAsyncControlPostBack Me, "click", uCtl, v
    End Property
    Public Property Set AsyncPostBack(uCtl,o)
        PutAsyncControlPostBack Me, "click", uCtl, o
    End Property
    Public Property Get AsyncPostBack(uCtl)
        AsyncPostBack = IsAsyncControlPostBackEnabled(Me,"click")
    End Property
    
    Private Function GetDirectionAfter(I)
        Dim d
        d = UCase(Direction)
        
        If IsObject(CustomRender) Then
            CustomRender.CustomRenderCallback "OpenItem", Me, Items(I), Empty
        ElseIf d = "HORIZONTAL" Or d = "H" Then
            GetDirectionAfter = ""
        ElseIf d = "VERTICAL" Or d ="V" Then
            GetDirectionAfter = "<br/>"
        ElseIf d = "TABLE" Or d = "T" Then
            If I Mod Size = 0 Then
                GetDirectionAfter = "</td></tr>"
            Else
                If I = Items.Count Then
                    GetDirectionAfter = "</td></tr>"
                Else
                    GetDirectionAfter = "</td>"
                End If
            End If
        Else
            GetDirectionAfter = Direction
        End If
    End Function
    Private Function GetDirectionBefore(I)
        Dim d
        d = UCase(Direction)
        
        If IsObject(CustomRender) Then
            CustomRender.CustomRenderCallback "CloseItem", Me, Items(I), Empty
        ElseIf d = "HORIZONTAL" Or d = "H" Then
            GetDirectionBefore = ""
        ElseIf d = "VERTICAL" Or d ="V" Then
            GetDirection = ""
        ElseIf d = "TABLE" Or d = "T" Then
            If (I - 1) Mod Size = 0 Then
                GetDirectionBefore = "<tr><td align=""left"" valign=""middle"">"
            Else
                GetDirectionBefore = "<td align=""left"" valign=""middle"">"
            End If
        Else
            GetDirectionBefore = Direction
        End If
    End Function
    
    Private Sub PreserveState
        If PreserveOptions Then
            Dim ts, itms, I
            Set ts = CreateTSSection(Empty)
            Set itms = CreateTSSection(Empty)
            ts.Add "Items", itms
            For I = 1 To Items.Count
                itms.Add "", Items(I).PreserveState
            Next
            ts("D") = ConvertTo(vbString,Direction)
            ts("M") = ConvertTo(vbLong,MultiSelect)
            ts("S") = ConvertTo(vbLong,Size)
            Response.Write "<input type=""hidden"" name=""" & Me.Name & "_Options"" value=""" & TSToHex(ts,EncryptSecondaryData) & """/>" & vbCrLf
        End If
    End Sub
    
    Private pAttributes
    Public Property Get Attributes
        If Not IsObject(pAttributes) Then
            Set pAttributes = CreateCollection
        End If
        Set Attributes = pAttributes
    End Property
    
    Public Sub PreRender(Param)
        Dim carr, I
        If IsObject(ClientScripts) And pShowHideControls Then
            Set carr = ClientScripts.ScriptArray("ASPCTL_CRadioList_" & Name)
            For I = 1 To Items.Count
                carr(Items(I).ClientId) = Items(I).GetShowHideIdList
            Next
            ClientScripts.RegisterEventHandlerEx Me, "click", "ASPCTL_CRadioList_Visibility", "ASPCTL_CRadioList_" & Name, "CRadioList_ShowHide", "load"
        End If
    End Sub
    Public CustomRender ' PCustomRenderCallback
    Public Sub Render
        PreserveState
        If Hide Then Exit Sub
        If IsObject(CustomRender) Then
            CustomRender.CustomRenderCallback "Begin", Me, Items(I), Empty
        ElseIf UCase(Direction) = "TABLE" Then
            Response.Write "<table border=""0"" "
            If Not IsEmpty(Me.CssClass) Then s = s & " class=""" & Me.CssClass & """"
            If Not IsEmpty(Me.Style) Then s = s & " style=""" & Me.Style & """"
            Response.Write " id=""" & Me.ClientId & """"
            Response.Write ">"
        Else
            Response.Write "<span"
            Response.Write " id=""" & Me.ClientId & """"
            Response.Write ">"
        End If
        
        Dim I
        For I = 1 To Items.Count
            Response.Write GetDirectionBefore(I)
            If IsObject(CustomRender) Then
                CustomRender.CustomRenderCallback Empty, Me, Items(I), Empty
            Else
                Items(I).Render
            End If
            Response.Write GetDirectionAfter(I) & vbCrLf
        Next
    
        If IsObject(CustomRender) Then
            CustomRender.CustomRenderCallback "End", Me, Items(I), Empty
        ElseIf UCase(Direction) = "TABLE" Then
            Response.Write "</table>"
        Else
            Response.Write "</span>"
        End If
    
        Rendered = True
    End Sub
End Class

Function Create_CRadioList(controlName)
    Dim ctl
    Set ctl = New CRadioList
    Controls.Add ctl.Name, ctl
    ctl.Init controlName, 0
    Set Create_CRadioList = ctl
End Function
Function Create_CCheckList(controlName)
    Dim ctl
    Set ctl = New CRadioList
    ctl.MultiSelect = True
    Controls.Add ctl.Name, ctl
    ctl.Init controlName, o
    Set Create_CCheckList = ctl
End Function




%>