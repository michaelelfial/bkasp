<%
' Include after aspctl.asp if you want to use it

Class CPostVariables
    Private vars
    Public Initialized
    Public Name
    Sub Init
        If ASPALL(ASPCTL_PostVarsFieldName).Count > 0 Then
            ' We may have some variables
            Set vars = TSFromHex(ASPALL(ASPCTL_PostVarsFieldName),EncryptSecondaryData)
        Else
            Set vars = CreateTSSection(Empty)
        End If
        Initialized = True
    End Sub
    
    Public Property Let Variable(vName,v)
        vars(vName) = v
    End Property
    Public Property Let VariableOnce(vName,v)
        If IsEmpty(vars(vName)) Then vars(vName) = v
    End Property
    Public Default Property Get Variable(vName)
        Variable = vars(vName)
    End Property
    
    Public Property Get PostCollection(cName)
        If Not IsObject(vars(cName)) Then Set vars(cName) = CreateTSRecord
        Set PostCollection = vars(cName)
    End Property
    
    
    Private Function CtlSection(Ctl,bCreate)
        Dim ctls,ctlVars
        Set CtlSection = Nothing
        Set ctlVars = Nothing
        If Not IsObject(vars("__")) Then
            If Not bCreate Then Exit Function
            Set ctls = CreateTSSection(Empty)
            Set vars("__") = ctls
        Else
            Set ctls = vars("__")
        End If
        If Not IsObject(ctls(Ctl.Name)) Then
            If Not bCreate Then Exit Function
            Set ctlVars = CreateTSSection(Ctl.ClassType)
            If Len(Ctl.Name) = 0 Then
                Err.Raise 1,"CPostVariables","The control has no name. Control type:" & Ctl.ClassType
            End If
            Set ctls(Ctl.Name) = ctlVars
        Else
            If ctls(Ctl.Name).Info.Class <> Ctl.ClassType Then
                Set ctlVars = Nothing
                Err.Raise 1,"CPostVariables","The control post data is for different control class. Control:" & Ctl.Name & "/" & Ctl.ClassType & " expected class was: " & ctls(Ctl.Name).Info.Class
            Else
                Set ctlVars = ctls(Ctl.Name)
            End If
        End If
        Set CtlSection = ctlVars
    End Function
    
    Public Sub SetCtlVar(Ctl,vName,v)
        Dim ctlVars
        Set ctlVars = CtlSection(Ctl,True)
        ctlVars(vName) = v
    End Sub
    Public Sub SetCtlVarOnce(Ctl,vName,v)
        Dim ctlVars
        Set ctlVars = CtlSection(Ctl,True)
        If IsEmpty(ctlVars(vName)) Then ctlVars(vName) = v
    End Sub
    Public Function GetCtlVar(Ctl,vName)
        Dim ctlVars
        GetCtlVar = Null
        Set ctlVars = CtlSection(Ctl,False)
        If Not ctlVars Is Nothing Then GetCtlVar = ctlVars(vName)
    End Function
    Public Function CtlPostCollection(Ctl,cName)
        Dim ctlVars
        Set ctlVars = CtlSection(Ctl,True)
        If Not IsObject(ctlVars(cName)) Then
            Set ctlVars(cName) = CreateTSRecord
        End If
        Set CtlPostCollection = ctlVars(cName)
    End Function
    
    Public Property Get ClassType
        ClassType = "CPostVariables"
    End Property
    
    Function Serialize
        Serialize = TSToHex(vars,EncryptSecondaryData)
    End Function
    Sub Render
        If vars.Count > 0 Then
            Response.Write "<input type=""hidden"" name=""" & ASPCTL_PostVarsFieldName & """ value=""" & TSToHex(vars,EncryptSecondaryData) & """>" & vbCrLf
        End If
    End Sub
    Sub RenderPartial
        PartialUpdateValue ASPCTL_PostVarsFieldName,TSToHex(vars,EncryptSecondaryData)
    End Sub
    
    Sub Dump
        Dim I, J, ctls, o, K
        %>
        <table bgcolor="#404080" cellspacing="1" width="100%">
            <tr>
                <th colspan="2"><font color="#FFFFFF">PostVariables - Page</font></th>
            </tr>
        <%
        For I = 1 To vars.Count
            If vars.Key(I) <> "__" Then
                %>
                <tr bgcolor="#FFFFFF">
                    <td>
                        <%= vars.Key(I) %>
                    </td>
                    <td><%= Server.HTMLEncode(vars(I)) %></td>
                </tr>
                <%
            End If
        Next
        %></table><%
        If IsObject(vars("__")) Then
            Set ctls = vars("__")
            %>
            <table bgcolor="#404080" cellspacing="1" width="100%">
                <tr>
                    <th colspan="3"><font color="#FFFFFF">PostVariables - Controls</font></th>
                </tr>
            <%
            For I = 1 To ctls.Count
            %>
            <tr>
               <td colspan="2"><font color="#FFFFFF"><%= ctls(I).Info.Class %> : <%= ctls.Key(I) & " (" & ctls(I).Count & " variables)" %></font></td>
            </tr>
            <%
                For J = 1 To ctls(I).Count
                    %>
                    <tr bgcolor="#FFFFFF">
                        <td>
                            <%= ctls(I).Key(J) %>
                        </td>
                        <td><%
                            If IsObject(ctls(I)(J)) Then
                                Response.Write "<b>Collection</b><br/>"
                                Set o = ctls(I)(J)
                                For K = 1 To o.Count
                                    Response.Write o.Key(K) & ": [" & Server.HTMLEncode(o(K)) & "]<br/>"
                                Next
                            Else
                                Response.Write Server.HTMLEncode(ctls(I)(J)) 
                            End If
                        %></td>
                    </tr>
                    <%
                Next
            Next
            %></table><%
        End If
        
    End Sub
    
End Class

Dim PostVariables
Set PostVariables = New CPostVariables
If ASPCTL_BasicInitializationDone And Not PostVariables.Initialized Then PostVariables.Init
    
' Wrapper class
Class CPostVariable
    Private VName
    Private VType
    
    Public Sub Init(vn,vt)
        VName = ConvertTo(vbString,vn)
        VType = ConvertTo(vbInteger,vt)
    End Sub
    
    Public Default Property Get Value
        Value = ConvertTo(VType,PostVariables.Variable(VName))
    End Property
    Public Property Let Value(v)
        PostVariables.Variable(VName) = ConvertTo(VType,v)
    End Property
    
    Public Sub UnSet
        PostVariables.Variable(VName) = Empty
    End Sub
    Public Property Get IsSet
        If IsEmpty(PostVariables.Variable(VName)) Then IsSet = False Else IsSet = True
    End Property
    
    Public Property Get ClassType
        ClassType = "CPostVariable"
    End Property
    
End Class
Function Create_PostVariable(vName,vType)
    Dim o
    Set o = New CPostVariable
    o.Init vName, vType
    Set Create_PostVariable = o
End Function
Function Create_AutoPostVariable(vName,vType, ReqName)
    Dim o, n
    Set o = Create_PostVariable(vName, vType)
    If Len(ReqName) > 0 Then n = ReqName Else n = vName
    If Not IsPostBack Then
        o.Value = ASPALL(n)
    End If
    Set Create_AutoPostVariable = o
End Function

%>