<%
    ' ASP-CTL miscellaneous client effects utilities.
    ' This file contains various routines creating effect on the client side.
    
    ' Call in the prerender of an User Control
    ' Parameters: Parent - the user control that initiates the action or the clientId of the part that invokes the action.
    '             inst - instance (the same parent may have multiple drop panel instances internally - pass a different string for each)
    '             DropControl - the user control or a client Id of the area which plays the role of a drop panel
    '             Transition - Appear | Drop | Reveal
    '             TransStep - pixels for a step (recommended  10-30)
    '             BoundClientId - If the floater should bind to another element pass its id or Empty otherwise
    '             X,Y,W,H - X,Y,Width, Height
    '             AllowScroll - If true the drop is scrolled vertically
    '   Note that only with user control passed as DropControl the size and styling will be fully applied automatically. Otherwise you may need to style the drop
    '       area (most often a div element) appropriately.
    Sub ClientShowDrop(Parent,inst,DropControl,Transition,TransStep,BoundClientId,X,Y,W,H,AllowScroll)
        
            Dim sPanelName, s, sTrans, parentId, dropId
            If IsObject(DropControl) Then
                dropId = DropControl.ClientId
            Else
                dropId = DropControl
            End If
            If IsObject(Parent) Then
                parentId = Parent.ClientId
            Else
                parentId = Parent
            End If
            sPanelName = ClientScripts.GetGlobalVariableName(Parent,ConvertTo(vbString,inst))
            ClientScripts.EnableAsyncLibrary
            ClientScripts.RegisterFile "staticevents-dynamic.js", VirtPath("/aspctl/staticevents-dynamic.js")
            
            
            Select Case Transition
                Case "Appear"
                    sTrans = "ccStaticTransAppear(null," & TransStep & ")"
                Case "Drop"
                    sTrans = "ccStaticTransDrop(null,null," & TransStep & ")"
                Case "Reveal"
                    sTrans = "ccStaticTransReveal(null,null,null," & TransStep & ")"
            End Select
            
            s = "var " & sPanelName & " = new ccStaticFloatPanel('" & sPanelName & "','" & parentId & "," & dropId & "','" & dropId & "'," & _
                    "new " & sTrans & ",'" & IfThenElse(Len(BoundClientId)=0,parentId,BoundClientId) & "');" & vbCrLf
            If X <> 0 Then s = s & sPanelName & ".transition.correctionX = " & X & ";" & vbCrLf
            If Y <> 0 Then s = s & sPanelName & ".transition.correctionY = " & Y & ";" & vbCrLf
            If W <> 0 Then s = s & sPanelName & ".transition.correctionW = " & W & ";" & vbCrLf
            
                    ' "new ccStaticTransAppear(null,10),'" & ClientId & "');" & vbCrLf
            ClientScripts.Block(sPanelName) = s
            
            
            ClientScripts.RegisterInitializer sPanelName, sPanelName & ".attachEvents()"
            If IsObject(DropControl) Then
                DropControl.Style = "z-index:100;display: none;position: absolute; width: " & W & "px;height: " & H & "px;overflow:" & IfThenElse(AllowScroll,"auto","hidden") & ";"
            End If
        
    End Sub

%>