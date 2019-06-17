<%
    ' Package:  UserAPI 
    ' Version:  2011-04-10
    ' File:     userapi-binder.asp
    ' Description:
    '   Provides binding between controls and fields in a database record
    '   Supports post variable properties and direct value manipulation
    
    Function Create_CRecordBinder(langField)
        Dim o
        Set o = New CRecordBinder
        o.LanguageField = langField
        o.DirectDelete = cDirectDelete
        Set Create_CRecordBinder = o
    End Function
    Function Create_CSimpleRecordBinder(langField)
        Dim o
        Set o = New CRecordBinder
        o.LanguageField = langField
        o.SimpleMode = True
        Set Create_CSimpleRecordBinder = o
    End Function
    
    
    Class CRecordBinder
        Private m_bindings
        Public LanguageField
        Public ActingUser ' As CUser
        Public SimpleMode ' no ownership field, no rights, the SID is still used, but delete operations remove the record and the sid
        Public DirectDelete
        Public R_USER, R_GROUP, R_ALL, OverrideUserRights
        
        Private Sub Class_Initialize
            Set m_bindings = CreateDictionary
            LanguageField = "LANGUAGE"
            Set ActingUser = CurrentUser ' Initializes to the current user by default
            R_USER = CurrentUser.R_USER
            R_GROUP = CurrentUser.R_GROUP
            R_ALL = CurrentUser.R_ALL
        End Sub
        
        ' Logical record producers
        ' Low level
        Function AccessItem(usr, sid, table, bForWrite, bWrite)
            Dim ssid, r, rcoll, I, rec , dt, bNoLang
            bNoLang = False
            If Len(LanguageField) = 0 Then bNoLang = True
                
            ssid = ConvertTo(vbLong, sid)
            
            On Error Resume Next
            If Len(table) = 0 Then
                Database.AddError "Table not specified to AccessItem."
                Set AccessItem = Nothing
                Exit Function
            End If
            
            If ssid <> 0 Then
                Set r = Database.DB.VExecute("SELECT * FROM [" & table & "] WHERE SID=$SID", 1, 0, ssid)
                If Err.Number <> 0 Or r.Count = 0 Then
                    Set AccessItem = Nothing
                    Database.AddError "Item read failed. " & Err.Description & " " & Database.DB.LastError
                    Exit Function
                End If
                If SimpleMode Then
                    For I = 1 To r.Count
                        r(I).allowDuplicateNames = False
                        r(I).itemsAssignmentAllowed = True
                        r(I).enumItems = True
                        r(I).allowUnnamedValues = False
                        r(I).readOnly = False
                    Next
                Else
                    If bForWrite Then
                        If Not usr.CanWriteRecord(r) Then ' *******
                            Database.AddError "You do not have write permission for this entry."
                            Set AccessItem = Nothing
                            Exit Function
                        End If
                    End If
                    For I = 1 To r.Count
                        r(I).allowDuplicateNames = False
                        r(I).itemsAssignmentAllowed = True
                        r(I).enumItems = True
                        r(I).allowUnnamedValues = False
                        r(I).readOnly = False
                        If bForWrite And bWrite Then ' *** This should be set just before the actual write probably
                            r(I)("MODIFIED") = Now ' Should be UTC
                            r(I)("MODIFY_USER_ID") = usr.Id
                            r(I)("CHANGED") = -1
                        End If
                    Next
                End If
                r.Info = "EXISTING"
                Set AccessItem = r
            Else
                ' A new record is to be created
                If bForWrite Then
                    ' Check quotas
                    If Not SimpleMode Then
                        If Not usr.CheckQuota(table) Then
                            Database.AddError TR("Quota exceeded. Please delete some old items.")
                            Database.InvalidateTransaction
                            Set AccessItem = Nothing
                            Exit Function
                        End If
                        If Not usr.CheckDeltaQuota(table) Then
                            Database.AddError TR("You added too much new entries too fast. Please try again later.")
                            Database.InvalidateTransaction
                            Set AccessItem = Nothing
                            Exit Function
                        End If
                    End If
                    ' Create SID
                    If bWrite Then
                        Set r = Database.DB.VExecute("INSERT INTO SYS (UID) VALUES (?)",1,0,Database.NewUID)
                        If Err.Number <> 0 Then
                            Database.AddError TR("Failed to create unique SID. Please retry the operation.") & Err.Description
                            Set AccessItem = Nothing
                            Exit Function
                        End If
                        ssid = r.Info
                    End If
                End If ' TO DO: Revise the policy - we return empty record now
                
                ' Create records
                Set rcoll = CreateList
                Dim nrFirst, nrLast
                If bNoLang Then
                    nrFirst = 0
                    nrLast = 0
                Else
                    nrFirst = LBound(SupportedLanguages)
                    nrLast = UBound(SupportedLanguages)
                End If
                For I = nrFirst To nrLast
                    Set rec = CreateDictionary
                    rec("SID") = ssid
                    If Not bNoLang Then
                        rec(LanguageField) = SupportedLanguages(I)
                    End If
                    If Not SimpleMode Then
                        dt = Now ' *******
                        rec("CREATED") = dt
                        rec("MODIFIED") = dt
                        rec("MODIFY_USER_ID") = NullConvertTo(vbLong, usr.Id)
                        rec("OWNER_USER_ID") = NullConvertTo(vbLong, usr.Id)
                        rec("OWNER_GROUP_ID") = NullConvertTo(vbLong, usr.GroupId)
                        If OverrideUserRights Then
                            rec("R_USER") = ConvertTo(vbLong, R_USER)
                            rec("R_GROUP") = ConvertTo(vbLong, R_GROUP)
                            rec("R_ALL") = ConvertTo(vbLong, R_ALL)
                        Else
                            rec("R_USER") = ConvertTo(vbLong, usr.R_USER)
                            rec("R_GROUP") = ConvertTo(vbLong, usr.R_GROUP)
                            rec("R_ALL") = ConvertTo(vbLong, usr.R_ALL)
                        End If
                        rec("DELETED") = 0
                        rec("CHANGED") = -1
                    End If
                    rcoll.Add CStr(I+1), rec
                Next
                rcoll.Info = "NEW"
                Set AccessItem = rcoll
            End If
        End Function
        
        ' Public item access routines
        Function ItemForRead(sid, table)
            Set ItemForRead = AccessItem(ActingUser, sid, table, False, False)
        End Function
        Function ItemForEdit(sid, table)
            Set ItemForEdit = AccessItem(ActingUser, sid, table, True, False)
        End Function
        Function ItemForWrite(sid, table)
            Set ItemForWrite = AccessItem(ActingUser, sid, table, True, True)
        End Function
        
        ' Writing records to the database
        Function WriteItem(rcoll, table)
            Dim sql, I, bNoLang
            bNoLang = False
            If Len(LanguageField) = 0 Then bNoLang = True
            WriteItem = 0
            If Len(table) = 0 Then 
                Err.Raise 1, "CRecordBinder", "No table specified to WriteItem"
                Exit Function
            End If
            If Not rcoll Is Nothing Then
                If UCase(rcoll.Info) = "NEW" Then
                    For I = 1 To rcoll.Count
                        Database.DB.CExecute "INSERT INTO [" & table & "] (" & CreateFieldList(rcoll(I),False) & ") VALUES (" & CreateFieldList(rcoll(I),True) & ");", rcoll(I)
                    Next
                    If rcoll.Count > 0 Then WriteItem = ConvertTo(vbLong, rcoll(1)("SID"))
                ElseIf UCase(rcoll.Info) = "EXISTING" Then
                    For I = 1 To rcoll.Count
                        If bNoLang Then
                            Database.DB.CExecute "UPDATE [" & table & "] SET " & CreateFieldAssignList(rcoll(I)) & " WHERE SID=$SID", rcoll(I)
                        Else
                            Database.DB.CExecute "UPDATE [" & table & "] SET " & CreateFieldAssignList(rcoll(I)) & " WHERE SID=$SID AND LANGUAGE=$LANGUAGE", rcoll(I)
                        End If
                    Next
                    If rcoll.Count > 0 Then WriteItem = ConvertTo(vbLong, rcoll(1)("SID"))
                Else
                    Err.Raise 1001, "WriteItem", "Unrecognized logical record type (only NEW and EXISTING are allowed)."
                End If
            Else
                Err.Raise 2001, "CRecordBinder", "The logical record is Nothing in the call to WriteItem."
            End If
        End Function
        Private Function CreateFieldAssignList(rec)
            Dim s, I, r
            If rec.Count > 0 Then
                s = ""
                For I = 1 To rec.Count
                    If UCase(rec.Key(I)) <> "SID" And UCase(rec.Key(I)) <> LanguageField Then
                        If Len(s) > 0 Then s = s & ", "
                        s = s & rec.Key(I) & "=$" & rec.Key(I)
                    End If
                Next
                CreateFieldAssignList = s
            Else
                Err.Raise 4001, "CRecordBinder", "No fields in the record (CreateFieldAssignList)"
                CreateFieldAssignList = ""
            End If
        End Function
        Private Function CreateFieldList(rec,bParam)
            Dim s, I, r
            If rec.Count > 0 Then
                s = ""
                For I = 1 To rec.Count
                    If Len(s) > 0 Then s = s & ","
                    If bParam Then s = s & "$"
                    s = s & rec.Key(I)
                Next
                CreateFieldList = s
            Else
                Err.Raise 4002, "CRecordBinder", "No fields in the dataset (CreateFieldList)"
                CreateFieldList = ""
            End If
        End Function
        
        ' Marks item as deleted
        Public Function DeleteItem(sid,table)
            Dim rcoll
            DeleteItem = False
            If SimpleMode Then
                Database.DB.VExecute "DELETE FROM [" & table & "] WHERE SID=$SID",1,0,NullConvertTo(vbLong, sid)
                Database.DB.VExecute "DELETE FROM SYS WHERE ID=$SID",1,0,NullConvertTo(vbLong, sid)
                DeleteItem = True
            Else
                Set rcoll = ItemForWrite(sid, table)
                If Not rcoll Is Nothing Then
                    If DirectDelete Then
                        Database.DB.VExecute "DELETE FROM [" & table & "] WHERE SID=$SID", 1, 0, NullConvertTo(vbLong, sid)
                    Else
                        ' No need to write everything - access is obviously already granted
                        Database.DB.VExecute "UPDATE [" & table & "] SET DELETED=-1,MODIFY_USER_ID=$MODIFY_USER_ID WHERE SID=$SID", 1, 0, ActingUser.Id, NullConvertTo(vbLong, sid)
                    End If
                    DeleteItem = True
                Else
                    Err.Raise 3001, "CRecordBinder", "The record cannot be deleted. You may not have enough rights or a database error has occured."
                End If
            End If
        End Function
        
        
        
        ' Binders
        Public Function BindControl(Control,ValueType,FieldName,FieldType,ReadCallBack,WriteCallBack)
            Dim o
            If Not IsObject(Control) Then Err.Raise 1, "CRecordBinder", "Control is not an object. While binding field: " & FieldName
            Set o = New CRecordBinding
            Set o.Control = Control
            o.ValueType = ValueType
            o.FieldName = FieldName
            o.FieldType = FieldType
            o.ReadCallBack = ReadCallBack
            o.WriteCallBack = WriteCallBack
            o.NullOnZero = True
            o.BindType = 0
            Set o.Parent = Me
            SaveBinding o
            Set BindControl = o
        End Function
        Public Function BindPostVariable(Control,VarName,ValueType,FieldName,FieldType)
            Dim o
            Set o = New CRecordBinding
            Set o.Control = Control
            o.ValueName = VarName
            o.ValueType = ValueType
            o.FieldName = FieldName
            o.FieldType = FieldType
            o.ReadCallBack = "Default"
            o.WriteCallBack = "Default"
            o.NullOnZero = True
            o.BindType = 1
            Set o.Parent = Me
            SaveBinding o
            Set BindPostVariable = o
        End Function
        
        Public Default Property Get Binding(x)
            Set Binding = m_bindings(x)
        End Property
        Public Sub UnBind(x)
            m_bindings.Remove x
        End Sub
        Public Sub ClearBindings
            m_bindings.Clear
        End Sub
        
        Public Function ReadFrom(rcoll)
            Dim I
            For I = 1 To m_bindings.Count
                If Not m_bindings(I).Disabled Then
                    m_bindings(I).ReadFrom rcoll
                End If
            Next
        End Function
        Public Function WriteTo(rcoll)
            Dim I
            For I = 1 To m_bindings.Count
                If Not m_bindings(I).Disabled Then
                    m_bindings(I).WriteTo rcoll
                End If
            Next
        End Function
        
        ' Helpers
        Function PhysicalRecord(rcoll,Lang)
            Dim I
            If Len(LanguageField) <> 0 And Len(Lang) <> 0 Then
                For I = 1 To rcoll.Count
                    If rcoll(I)(LanguageField) = Lang Then
                        Set PhisicalRecord = rcoll(I)
                        Exit Function
                    End If
                Next
                Set PhysicalRecord = Nothing ' To cause error outside if not checked
            Else
                Set PhysicalRecord = rcoll(1)
            End If
        End Function
        
        ' Direct read/write
        Public Property Get Value(rcoll,FieldName)
            If rcoll.Count > 0 Then
                Value = rcoll(1)(FieldName)
            Else
                Value = Null
            End If
        End Property
        Public Property Get LanguageValue(rcoll, FieldName, Lang)
            Dim o
            Set o = PhisicalRecord(rcoll,Lang)
            If o Is Nothing Then
                LanguageValue = Null
            Else
                LanguageValue = o(FieldName)
            End If
        End Property
        Public Property Let Value(rcoll,FieldName,v)
            Dim I
            If rcoll.Count > 0 Then
                For I = 1 To rcoll.Count
                    rcoll(I)(FieldName) = v
                Next
            Else
                Err.Raise 1, "CRecordBinder", "No dataset to write to."
            End If
        End Property
        Public Property Let LanguageValue(rcoll, FieldName, Lang, v)
            Dim o
            Set o = PhisicalRecord(rcoll,Lang)
            If o Is Nothing Then
                Err.Raise 2, "CRecordBinder", "No physical record for the specified language " & Lang
            Else
                o(FieldName) = v
            End If
        End Property
        
        ' Internals
        Private Sub SaveBinding(o)
            Set m_bindings(o.FieldName) = o
        End Sub
        
    End Class
    
    Const cRecordBindingControl         = 0
    Const cRecordBindingPostVariable    = 1
    Const cRecordBindingCustom          = 2
    
    Class CRecordBinding
        ' CONTROL SIDE
        Public ValueName ' For controls supporting more than a single value this is the key for 
                         '      the indexed property accessing their internal values
        Public Control   ' The controls being bound
            Public ValueType, ValueFormat ' The type and representation format (optional) of the value
                                          '     in the control. The control may support a wide variety of types,
                                          '     so we need to know what is required in this case
        ' RECORD SIDE
        Public FieldName ' The name of the field in the logical record
            Public FieldType, NullOnZero  ' The type of the value in the record. Conversion is performed
                                          '     by the write handlers
        ' READ/WRITE HANDLERS        
        Public ReadCallBack     ' (binding,Language,v)
                                '   The readers are responsible to convert/format the value v as requested
                                '    and return it. They are given a value and do not address the record directly.
                                '    They also do not address the control directly - the CRecordBinder does that
        Public WriteCallBack    ' (binding,Language,v)
                                '   The writers are responsible converting the value passed as v from its representation
                                '   in the control to the type required for the record. They return
                                '   the value thus prepared (The CRecordBinder does the actual saving)
            ' The BindType = 2 (Custom) handlers receive as last parameter the currennt physical record
            '   and are responsible to fetch/store the value(s) on their own
            ' Naming of the handlers:
            '   RecordBindingRead_XXXX/RecordBindingWrite_XXXX
        ' OPTIONS
        Public BindType         ' 0 (default) control value, 1 - PostVariable, 
                                ' 2 - Custom (the handler accesses the control's values on its own
        Public Parent           ' The parent CRecordBinder
        Public Disabled         ' Disable this binding
        
        ' Helpers
        Function GetLanguageFromRecord(rec)
            If Len(Parent.LanguageField) > 0 Then
                GetLanguageFromRecord = rec(Parent.LanguageField)
            Else
                GetLanguageFromRecord = Empty
            End If
        End Function
        
        ' Bound read/write
        Public Sub ReadFrom(rcoll) ' Reads from record collection
            Dim I, oread, clang, v, t
            If Len(ReadCallBack) > 0 Then
                Set oread = GetRef("RecordBindingRead_" & ReadCallBack)
            Else
                Exit Sub ' The lack of read handler can be intentional
            End If
            
            On Error Resume Next
            ' Err.Clear
            Select Case BindType
                Case 0 ' Control
                    If ImplementsProtocol(Control, "PLanguageControl") And Len(Parent.LanguageField) > 0 Then
                        Control.Values.Clear
                        For I = 1 To rcoll.Count
                            clang = GetLanguageFromRecord(rcoll(I))
                            Control.LanguageValue(clang) = oread(Me, clang, rcoll(I)(FieldName))
                        Next
                    ElseIf ImplementsProtocol(Control, "PChecked") Then
                        Control.Checked = oread(Me, Empty, rcoll(1)(FieldName))
                    ElseIf ImplementsProtocol(Control, "PDateValue") Then
                        Control.DateValue = oread(Me, Empty, rcoll(1)(FieldName))
                    Else
                        If ImplementsProtocol(Control, "PIndexedValues") And Len(ValueName) > 0 Then
                            Control.Values(ValueName) = oread(Me, Empty, rcoll(1)(FieldName))
                        Else
                            Control.Value = oread(Me, Empty, rcoll(1)(FieldName))
                        End If
                    End If
                Case 1 ' Post variable
                    If Len(ValueName) = 0 Then
                        Err.Raise 10001, "CRecordBinding","No value name specified in binding: " & Me.FieldName & ", BindType is PostVariable and requires ValueName"
                    Else
                        If IsObject(Control) Then
                            PostVariables.SetCtlVar Control, ValueName, oread(Me, Empty, rcoll(1)(FieldName))
                        Else
                            PostVariables.Variable(ValueName) = oread(Me, Empty, rcoll(1)(FieldName))
                        End If
                    End If
                Case 2 ' Custom - requires special handlers (does not work with the standard ones)
                    For I = 1 To rcoll.Count
                        clang = GetLanguageFromRecord(rcoll(I))
                        ' (the return result by the handler is currently ignored)
                        v = oread(Me, clang, rcoll(I)) ' Thinking of using the return result as indicator
                    Next
                Case Else
                    On Error Goto 0
                    Err.Raise 10000, "CRecordBinding","Unsupported binding type in binding: " & Me.FieldName & ", BindType: " & BindType
            End Select
            
            If Err.Number <> 0 Then
                t = Err.Description
                On Error Goto 0
                Err.Raise 1, "CRecordBinding","Read binding failed: " & Me.FieldName & ", Error: " & t
            End If
        End Sub
        Public Sub WriteTo(rcoll)
            Dim I, owrite, clang, v
            If Len(WriteCallBack) > 0 Then
                Set owrite = GetRef("RecordBindingWrite_" & WriteCallBack)
            Else
                Exit Sub ' Can be intentional
            End If
            
            On Error Resume Next
            Err.Clear
            Select Case BindType
                Case 0 ' Control
                    If ImplementsProtocol(Control, "PLanguageControl") And Len(Parent.LanguageField) > 0 Then
                        For I = 1 To rcoll.Count
                            clang = GetLanguageFromRecord(rcoll(I))
                            rcoll(I)(FieldName) = owrite(Me, clang, Control.LanguageValue(clang))
                        Next
                    ElseIf ImplementsProtocol(Control, "PChecked") Then
                        v = owrite(Me, Empty, Control.Checked)
                        For I = 1 To rcoll.Count
                            rcoll(I)(FieldName) = v
                        Next
                    ElseIf ImplementsProtocol(Control, "PDateValue") Then
                        v = owrite(Me, Empty, Control.DateValue)
                        For I = 1 To rcoll.Count
                            rcoll(I)(FieldName) = v
                        Next
                    Else
                        If ImplementsProtocol(Control, "PIndexedValues") And Len(ValueName) > 0 Then
                            v = owrite(Me, Empty, Control.Values(ValueName))
                        Else
                            v = owrite(Me, Empty, Control.Value)
                        End If
                        For I = 1 To rcoll.Count
                            rcoll(I)(FieldName) = v
                        Next
                    End If
                Case 1 ' PostVariable
                    If Len(ValueName) = 0 Then
                        Err.Raise 10001, "CRecordBinding","No value name specified in binding: " & Me.FieldName & ", BindType is PostVariable and requires ValueName"
                    Else
                        If IsObject(Control) Then
                            v = owrite(Me, Empty, PostVariables.GetCtlVar(Control,ValueName))
                        Else
                            v = owrite(Me, Empty, PostVariables.Variable(ValueName))
                        End If
                        For I = 1 To rcoll.Count
                            rcoll(I)(FieldName) = v
                        Next
                    End If
                Case 2 ' Custom (the return result by the handler is currently ignored)
                    For I = 1 To rcoll.Count
                        clang = GetLanguageFromRecord(rcoll(I))
                        v = owrite(Me, clang, Control)
                    Next
                Case Else
                    On Error Goto 0
                    Err.Raise 10000, "CRecordBinding","Unsupported binding type in binding: " & Me.FieldName & ", BindType: " & BindType
            End Select
        End Sub
        
    End Class
    
    ' Built-in handlers
    
        ' === DEFAULT ===
        Function RecordBindingRead_Default(Binding, Language, v)
            Dim vactual
            vactual = ConvertTo(Binding.ValueType,v)
            If Len(Binding.ValueFormat) <> 0 Then
                vactual = StringUtilities.Sprintf(Binding.ValueFormat,vactual)
            End If
            RecordBindingRead_Default = vactual
        End Function
        Function RecordBindingWrite_Default(Binding,Language,v)
            If Binding.NullOnZero Then
                RecordBindingWrite_Default = NullConvertTo(Binding.FieldType,v)
            Else
                RecordBindingWrite_Default = ConvertTo(Binding.FieldType,v)
            End If
        End Function


%>