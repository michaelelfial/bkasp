<%
' The Session Preferences system is primarily for User Controls, but it can be used also by
' pages or from user controls (but on global level - not through the CtlXXX members) if you 
' are concerned about the possibility to get the preferences mixed with other session variables.
' The control parameters are used for type keys, thus using Web controls as arguments is inappropriate
' and even dangerous. It is recommended to implement any preferences an user control supports as 
' properties and then use them in its members.
' MUST BE INCLUDED EXPLICITLY if the feature is used

' Quick ref
' -- Defaults initializer - implement this method in the control (available only for controls)
'   Class <YourClass>
'       Public Sub InitSessionPreferences(vars)
'           vars("someparam") = something
' -- Read Prefs - call these methods in a control
'       x = SessionPreferences.GetCtlVar(Me, "someparam")
' -- Save Prefs - call these methods in a control
'       SessionPreferences.SetCtlVar Me, "someparam", somevalue
' -- pref collections are accessed for both read and write like this
'       Set coll = SessionPreferences.CtlCollection(Me,"yourcollectionname")
' -- Access global session prefs for read and write through this property
'       SessionPreferences.Variable("preferencename")

Class CSessionPreferences
    Private vars
    Sub Class_Initialize
        If IsNotObject(Session(ASPCTL_SessionPrefsName)) Then
            ' We may have some variables
            Set vars = CreateTSSection(Empty)
            Set Session(ASPCTL_SessionPrefsName) = vars
        Else
            Set vars = Session(ASPCTL_SessionPrefsName)            
        End If
    End Sub
    
    Public Property Let Variable(vName,v)
        vars(vName) = v
    End Property
    Public Default Property Get Variable(vName)
        Variable = vars(vName)
    End Property
    
    Public Property Get Collection(cName)
        If Not IsObject(vars(cName)) Then Set vars(cName) = CreateTSRecord
        Set Collection = vars(cName)
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
        If Not IsObject(ctls(Ctl.ClassType)) Then
            If Not bCreate Then Exit Function
            Set ctlVars = CreateTSSection(Ctl.ClassType)
            Set ctls(Ctl.ClassType) = ctlVars
            On Error Resume Next
                Ctl.InitSessionPreferences ctlVars
            Err.Clear
            On Error Goto 0
        Else
            Set ctlVars = ctls(Ctl.ClassType)
        End If
        Set CtlSection = ctlVars
    End Function
    
    Public Sub SetCtlVar(Ctl,vName,v)
        Dim ctlVars
        Set ctlVars = CtlSection(Ctl,True)
        ctlVars(vName) = v
    End Sub
    Public Function GetCtlVar(Ctl,vName)
        Dim ctlVars
        GetCtlVar = Null
        Set ctlVars = CtlSection(Ctl,True)
        If Not ctlVars Is Nothing Then GetCtlVar = ctlVars(vName)
    End Function
    Public Function CtlCollection(Ctl,cName)
        Dim ctlVars
        Set ctlVars = CtlSection(Ctl,True)
        If Not IsObject(ctlVars(cName)) Then
            Set ctlVars(cName) = CreateTSRecord
        End If
        Set CtlCollection = ctlVars(cName)
    End Function
    
    Function Serialize
        If vars.Count > 0 Then
            Serialize = TSToHex(vars,EncryptSecondaryData)
        Else
            Serialize = ""
        End If
    End Function
    Sub Deserialize(s)
        Set Session(ASPCTL_SessionPrefsName) = TSFromHex(s,EncryptSecondaryData)
    End Sub
    Sub Clear
        Set Session(ASPCTL_SessionPrefsName) = CreateTSSection(Empty)
    End Sub
    
    Sub Dump
        Dim I, J, ctls
        %>
        <table bgcolor="#404080" cellspacing="1" width="100%">
            <tr>
                <th colspan="2"><font color="#FFFFFF">SesionPreferences - Page</font></th>
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
                    <th colspan="3"><font color="#FFFFFF">SesionPreferences - Controls</font></th>
                </tr>
            <%
            For I = 1 To ctls.Count
            %>
            <tr>
               <td colspan="2"><font color="#FFFFFF"><%= ctls(I).Info.Class %> : <%= ctls.Key(I) %></font></td>
            </tr>
            <%
                For J = 1 To ctls(I).Count
                    %>
                    <tr bgcolor="#FFFFFF">
                        <td>
                            <%= ctls(I).Key(J) %>
                        </td>
                        <td><%= Server.HTMLEncode(ctls(I)(J)) %></td>
                    </tr>
                    <%
                Next
            Next
            %></table><%
        End If
        
    End Sub
    
End Class

Dim SessionPreferences
Set SessionPreferences = New CSessionPreferences

' Wrapper class
Class CSessionPreference
    Private VName
    Private VType
    
    Public Sub Init(vn,vt)
        VName = ConvertTo(vbString,vn)
        VType = ConvertTo(vbInteger,vt)
    End Sub
    
    Public Default Property Get Value
        Value = ConvertTo(VType,SessionPreferences.Variable(VName))
    End Property
    Public Property Let Value(v)
        SessionPreferences.Variable(VName) = ConvertTo(VType,v)
    End Property
    
    Public Sub UnSet
        SessionPreferences.Variable(VName) = Empty
    End Sub
    Public Property Get IsSet
        If IsEmpty(SessionPreferences.Variable(VName)) Then IsSet = False Else IsSet = True
    End Property
End Class
Function Create_SessionPreference(vName,vType,DefVal)
    Dim o
    Set o = New CSessionPreference
    o.Init vName, vType
    If Not o.IsSet Then o.Value = DefVal
    Set Create_SessionPreference = o
End Function

' Page environment
' Enables control (mostly) setting values to be accessed directly from any depth
' Whenever the value needed depends on some other settings applied to a particular instance of a control
'   the value naming can be decorated (small set of options) or a collection can be used
Class CPageEnvironment
    Private vars
    Sub Class_Initialize
        Set vars = CreateTSSection(Empty)
    End Sub
    
    Public Property Let Variable(vName,v)
        vars(vName) = v
    End Property
    Public Default Property Get Variable(vName)
        Variable = vars(vName)
    End Property
    
    Public Property Get Collection(cName)
        If Not IsObject(vars(cName)) Then Set vars(cName) = CreateTSRecord
        Set Collection = vars(cName)
    End Property
    
    Private Function CtlSection(CtlClassType,bCreate)
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
        If Not IsObject(ctls(CtlClassType)) Then
            If Not bCreate Then Exit Function
            Set ctlVars = CreateTSSection(CtlClassType)
            Set ctls(CtlClassType) = ctlVars
        Else
            Set ctlVars = ctls(CtlClassType)
        End If
        Set CtlSection = ctlVars
    End Function
    
    Public Sub SetCtlVar(Ctl,vName,v)
        Dim ctlVars
        If IsObject(Ctl) Then
            Set ctlVars = CtlSection(Ctl.ClassType,True)
        Else
            Set ctlVars = CtlSection(Ctl,True)
        End If
        ctlVars(vName) = v
    End Sub
    Public Function GetCtlVar(Ctl,vName)
        Dim ctlVars
        GetCtlVar = Null
        If IsObject(Ctl) Then
            Set ctlVars = CtlSection(Ctl.ClassType,True)
        Else
            Set ctlVars = CtlSection(Ctl,True)
        End If
        If Not ctlVars Is Nothing Then GetCtlVar = ctlVars(vName)
    End Function
    Public Function GetCtlVarDefault(Ctl,vName,defVal)
        Dim ctlVars
        GetCtlVarDefault = defVal
        If IsObject(Ctl) Then
            Set ctlVars = CtlSection(Ctl.ClassType,False)
        Else
            Set ctlVars = CtlSection(Ctl,False)
        End If
        If Not ctlVars Is Nothing Then GetCtlVarDefault = ctlVars(vName)
    End Function
    Public Function CtlCollection(Ctl,cName)
        Dim ctlVars
        If IsObject(Ctl) Then
            Set ctlVars = CtlSection(Ctl.ClassType,True)
        Else
            Set ctlVars = CtlSection(Ctl,True)
        End If
        If Not IsObject(ctlVars(cName)) Then
            Set ctlVars(cName) = CreateTSRecord
        End If
        Set CtlCollection = ctlVars(cName)
    End Function
    
    Function Serialize
        If vars.Count > 0 Then
            Serialize = TSToHex(vars,EncryptSecondaryData)
        Else
            Serialize = ""
        End If
    End Function
    Sub Deserialize(s)
        Set vars = TSFromHex(s,EncryptSecondaryData)
    End Sub
    Sub Clear
        vars.Clear
    End Sub
End Class

Set PageEnvironment = New CPageEnvironment

%>