<%
    ' Simply include this file if you need to use encrypted parameters
    Const ASPCTL_EncryptedParameters = "ASPCTL_Encrypted"
    
    ' Helper class - use it to create and maintain encrypted parameters and place them in links or render them in the form
    Class CEncryptedParameters
        Private p_params
        Private Sub Class_Initialize
            Set p_params = CreateTSSection(Empty)
            Set p_params.Missing = CreateTSRecord
        End Sub
        ' Private
        Sub InternalInit(p)
            Set p_params = p.Clone
        End Sub
        
        Public Function Clone
            Dim o
            Set o = New CEncryptedParameters
            o.InternalInit p_params
            Set Clone = o
        End Function
        
        Public Property Let Value(vname,vvalue)
            Dim r
            p_params.Remove vname
            Set r = CreateTSRecord
            r.Add "", vvalue
            Set p_params(vname) = r
        End Property
        Public Default Property Get Value(vname)
            Set Value = p_params(vname)
        End Property
        
        Public Function Add(vname, vvalue)
            Dim r
            Set r = p_params(vname)
            If r.Count = 0 Then
                Set p_params(vname) = CreateTSRecord
            End If
            p_params(vname).Add "", vvalue
            Set Add = Me
        End Function
        Public Function Remove(vname)
            Remove = p_params.Remove(vname)
        End Function
        Public Property Get Count
            Count = p_params.Count
        End Property
        
        ' Render as hidden field
        Public Sub RenderEncrypted
            %>
            <input type="hidden" name="<%= ASPCTL_EncryptedParameters %>" value="<%= TSToHex(p_params, True) %>" />
            <%
        End Sub
        Public Sub RenderPlain
            Dim I, J, p
            For I = 1 To p_params.Count
                Set p = p_params(I)
                For J = 1 To p.Count
                    %>
                    <input type="hidden" name="<%= p_params.Key(I) %>" value="<%= HTMLEncode(ConvertTo(vbString, p(J))) %>" />
                    <%
                Next
            Next
        End Sub
        Public Function URLEncrypted
            URLEncrypted = ASPCTL_EncryptedParameters & "=" & TSToHex(p_params, True)
        End Function
        Public Function URLPlain
            Dim I, J, p, s
            s = ""
            For I = 1 To p_params.Count
                Set p = p_params(I)
                For J = 1 To p.Count
                    If Len(s) > 0 Then s = s & "&"
                    s = s & p_params.Key(I) & "=" & ConvertTo(vbString, p(J))
                Next
            Next
            URLPlain = s
        End Function
        Public Function URLRender(bEncrypted)
            If bEncrypted Then
                URLRender = URLEncrypted
            Else
                URLRender = URLPlain
            End If
        End Function
    End Class
    
    ' Access the encrypted parameters through this collection
    Dim ASPENCRYPTED
    Set ASPENCRYPTED = CreateTSSection(Empty)
    Set ASPENCRYPTED.Missing = CreateTSRecord
    
    Private Sub ASPCTL_DecryptRequestCollectionElements(coll)
        Dim s, I, t, r, J, tr
        s = ConvertTo(vbString,coll(ASPCTL_EncryptedParameters))
        If Len(s) > 0 Then
            Set t = TSFromHex(s,True)
            For I = 1 To t.Count
                Set tr = t(I)
                Set r = ASPENCRYPTED(t.Key(I))
                If r.Count > 0 Then
                    ' Combine the record
                    For J = 1 To tr.Count
                        r.Add "", tr(J)
                    Next
                Else
                    ' Replace the record
                    Set ASPENCRYPTED(t.Key(I)) = tr
                End If
            Next
        End If
    End Sub

    ASPCTL_DecryptRequestCollectionElements ASPGET
    ASPCTL_DecryptRequestCollectionElements ASPPOST

%>