<%
    If Not IsEmpty(Application("ASPCTLFixedCodePage")) Then Session.CodePage = Application("ASPCTLFixedCodePage")
    Set ASPCTL_TIMER = Server.CreateObject("newObjects.utilctls.SFMain")
    Dim ASPCTL_START_TICKS 
    ASPCTL_START_TICKS = ASPCTL_TIMER.SystemTicks
    Const ASPCTL_Partial = "ASPCTLPartial"
    Const ASPCTL_ControlList = "ASPCTLControlList"
    Const ASPCTL_Version = &H010D ' 1.D
    Const ASPCTLSkinsPath = "Skin" ' Not currently used
    Const ASPCTL_PostVarsFieldName = "ASPCTL_PostVars" ' If the aspctl-postvars.asp is included this name is used
    Const ASPCTL_SessionPrefsName = "ASPCTL_SesPrefs"
    If Application("NEVER_CACHE") Then Response.AddHeader "Cache-Control", "no-cache"
    Dim MasterCancelProcessing
    Dim CancelProcessing ' If set to True all the processing cycles exit. Note that the page's processing cannot be cancelled so if the page wants to respect this
                         ' it should check for it in ProcessPage. DEPRECATED - USE MasterCancelProcessing instead
    Dim ASPRedirect ' If non-empty indicates that a redirection should occur
                    ' The Begin_Page and Begin_PartialRender respect it
                    ' It is recommended to check it in the master page and skip the page rendering if it is non-empty
                    
    Dim ASPCTLHeadContent ' Additional content in the head section of the page                    

    ' Global definitions for the ASPCTL framework
    ' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ' ASP-CTL is configured from outside, but sometimes it might be useful to change something in this section - in case of non-standard deployment for instance
    Function BasePath()
        Dim s
        If IsEmpty(Application("ASPCTLBasePath")) Then
            s = "/"
        Else
            s = Application("ASPCTLBasePath")
            If Right(s,1) <> "/" Then s = s & "/"
        End If
        BasePath = s
    End Function
    Function ASPCTLPath()
        ASPCTLPath = BasePath & "aspctl/"
    End Function
    Function MapPath(p)
        Dim s
        If Left(p,1) = "/" Then s = Mid(p,2) Else s = p
        MapPath = Server.MapPath(BasePath & s)
    End Function
    Function VirtPath(p)
        Dim s
        If Left(p,1) = "/" Then s = Mid(p,2) Else s = p
        VirtPath = BasePath & s
    End Function
    Function AbsoluteURL(p)
        Dim sn, prt
        sn = Request.ServerVariables("SERVER_NAME")
        prt = Request.ServerVariables("SERVER_PORT")
        If prt = "80" Then prt = "" Else prt = ":" & prt
        If IsALP Then
            AbsoluteURL = "alp://" & sn & VirtPath(p)
        Else
            If UCase(Request.ServerVariables("HTTPS")) = "ON" Then
                AbsoluteURL = "https://" & sn & prt & VirtPath(p)
            Else
                AbsoluteURL = "http://" & sn & prt & VirtPath(p)
            End If
        End If
    End Function
    ' reverses virtual path with "/" in the beginning always present
    Function AppPath(p)
        Dim r, s
        s = p
        r = VirtPath("/")
        If InStr(s,r) > 0 Then
            s = Mid(s,Len(r))
        End If
        If Left(s,1) <> "/" Then s = s & "/"
        AppPath = s
    End Function
    Function ASPCTLResDBPath
        If Not IsEmpty(Application("ResourceDatabase")) Then
            ASPCTLResDBPath = MapPath(Application("ResourceDatabase"))
        Else
            ASPCTLResDBPath = MapPath("/aspctl/db/aspctl.sqlite3")
        End If
    End Function
    Function IsALP
		Dim I,execContext,arrDesktop(2)
		IsALP = False
		execContext = Request.ServerVariables("SERVER_SOFTWARE")
		If InStr(execContext,"newObjects-ALP") <> 0 Then 
		    IsALP = True
	    End If
	End Function
	
	' Core status indication
	Dim Self,RequestMethod
    Self = CStr(Request.ServerVariables("SCRIPT_NAME"))
    RequestMethod = UCase(Request.ServerVariables("REQUEST_METHOD"))
    Function IsPostBack
        If RequestMethod <> "GET" Then IsPostBack = True Else IsPostBack = False
    End Function
	
	If IsPostBack And Len(Application("RedirectNewSessions")) <> 0 Then
	    If Clng(Session("ASPCTLSessionMarker")) = 0 Then
            ASPRedirect = VirtPath(Application("RedirectNewSessions"))
            MasterCancelProcessing = True
        End If
    End If
    
    Session("ASPCTLSessionMarker") = 1
	
	Function ThisServer
	    
    End Function
	
	' Page API - general purpose routines
	' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	' Creates a VarDictionary collection 
    ' and sets some common defaults
    Dim ASPCTL_TEMPLATE_COLLECTION
    Private Sub ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set ASPCTL_TEMPLATE_COLLECTION = Server.CreateObject("newObjects.utilctls.VarDictionary")
        With ASPCTL_TEMPLATE_COLLECTION
            .firstItemAsRoot = True
            .itemsAssignmentAllowed = True
            .enumItems = True
            .allowUnnamedValues = True
            .allowDuplicateNames = True
            .RequireSetForObjects = True
        End With
    End Sub
    Function CreateCollection()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateCollection = ASPCTL_TEMPLATE_COLLECTION.CreateNew()
    End Function
    Function CreateStack()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateStack = ASPCTL_TEMPLATE_COLLECTION.CreateNewStack()
    End Function
    Function CreateQueue()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateQueue = ASPCTL_TEMPLATE_COLLECTION.CreateNewQueue()
    End Function
    Function CreateList()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateList = ASPCTL_TEMPLATE_COLLECTION.CreateNewList()
    End Function
    Function CreateDictionary()
        If Not IsObject(ASPCTL_TEMPLATE_COLLECTION) Then ASPCTL_CREATE_TEMPLATE_COLLECTION
        Set CreateDictionary = ASPCTL_TEMPLATE_COLLECTION.CreateNewDictionary()
    End Function
    Sub TransferCollection(dst,src,bClearDst)
        Dim I
        If IsObject(dst) And IsObject(src) Then
            If bClearDst Then dst.Clear
            For I = 1 To src.Count
                dst.Add src.Key(I), src(I)
            Next    
        End If
    End Sub
	
	Sub VarDictSwap(vd, n1,n2)
		Dim t
		If n1 >= 1 And n1 <= vd.Count And n2 >= 1 And n2 <= vd.Count Then
			If IsObject(vd(n1)) Then
				Set t = vd(n1)
			Else
				t = vd(n1)
			End If
			If IsObject(vd(n2)) Then
				Set vd(n1) = vd(n2)
			Else
				vd(n1) = vd(n2)
			End If
			If IsObject(t) Then
				Set vd(n2) = t
			Else
				vd(n2) = t
			End If
		End If
	End Sub
	Function DefaultComparison(e1,e2)
		if e1 > e2 Then DefaultComparison = 1
		If e2 > e1 Then DefaultComparison = -1
		DefaultComparison = 0
	End Function
	Sub SortVarDict(vd, comp)
		Dim swapped, I
		Do
			swapped = false
			For I = 1 To vd.Count - 1
				If comp(vd(I),vd(I+1)) > 0 Then
					VarDictSwap vd,I,I+1
					swapped = true
				End If
			Next
		Loop While Not swapped
	End Sub
   
    Function CreateStringList()
        Dim coll
        Set coll = Server.CreateObject("newObjects.utilctls.StringList")
        Set CreateStringList = coll
    End Function
    
    Dim ASPCTL_UDSProvider
    Function CreateTSSection(className)
        If Not IsObject(ASPCTL_UDSProvider) Then Set ASPCTL_UDSProvider = Server.CreateObject("newObjects.utilctls.Configfile")
        Dim sect
        Set sect = Server.CreateObject("newObjects.utilctls.Configfile").CreateSection()
        sect.Info.Class = className
        Set CreateTSSection = sect
    End Function
    Function CreateTSRecord
        If Not IsObject(ASPCTL_UDSProvider) Then Set ASPCTL_UDSProvider = Server.CreateObject("newObjects.utilctls.Configfile")
        Dim rec
        Set rec = Server.CreateObject("newObjects.utilctls.Configfile").CreateRecord()
        Set CreateTSRecord = rec
    End Function
    

    ' BEGIN Type conversion
    ' Version 1.1 - updated to use the TypeConverter
    Set ASPCTL_TypeConverter = Server.CreateObject("newObjects.utilctls.TypeConverter")
    
    Const vbLargeInteger = 20 ' CAUTION: VT_I8 - Note that vbCurrency is treated as VT_I8 by these routines!!!!
    
    Function ConvertTo(vbType,v)
        ConvertTo = ASPCTL_TypeConverter.ConvertTo(vbType,v)
    End Function
    Function TryConvertTo(vbType,v)
        TryConvertTo = ASPCTL_TypeConverter.TryConvertTo(vbType,v)
    End Function
    Function NullConvertTo(vbType,v)
        NullConvertTo = ASPCTL_TypeConverter.NullConvertTo(vbType,v)
    End Function
    Function IfNull(a,b)
        If IsNull(a) Then IfNull = b Else IfNull = a
    End Function
    Function IfEmpty(a,b)
        If IsNull(a) Or IsEmpty(a) Then IfEmpty = b Else IfEmpty = a
    End Function
    Function IfThenElse(c,a,b)
        If ConvertTo(vbBoolean,c) Then IfThenElse = a Else IfThenElse = b
    End Function
    Function IsNullOrEmpty(c)
        IsNullOrEmpty = True
        If IsNull(c) Then Exit Function
        If IsEmpty(c) Then Exit Function
        IsNullOrEmpty = False
    End Function
    Function IsNotObject(o)
        If IsObject(o) Then
            If o Is Nothing Then
                IsNotObject = True
            Else
                IsNotObject = False
            End If
        Else
            IsNotObject = True
        End If
    End Function
    Function ToUpperCase(v)
        If Not IsNull(v) Then
            ToUpperCase = UCase(v)
        Else
            ToUpperCase = v
        End If
    End Function
    Function ObjectOrNothing(o)
        If IsNotObject(o) Then
            Set ObjectOrNothing = Nothing
        Else
            Set ObjectOrNothing = o
        End If
    End Function
    Function ToLowerCase(v)
        If Not IsNull(v) Then
            ToLowerCase = LCase(v)
        Else
            ToLowerCase = v
        End If
    End Function
    Function NullLikeString(v,w1,w2)
        Dim s
        s = NullConvertTo(vbString,v)
        If IsNull(s) Then
            NullLikeString = Null
            Exit Function
        End If
        If w1 Then s = "%" & s
        If w2 Then s = s & "%"
        NullLikeString = s
    End Function
    ' END Type conversion	

    ' Safe encode
    Function HTMLEncode(x)
        HTMLEncode = Server.HTMLEncode(ConvertTo(vbString,x))
    End Function
    
    Function HTMLEncode2(x)
        Dim text
        text = ConvertTo(vbString,x)
        text = Replace(text,"<","&lt;")
        text = Replace(text,">","&gt;")
        text = Replace(text,"""","&#34;")
        text = Replace(text,"'","&#46;")
        ' text = Replace(text,"&","&amp;")
        HTMLEncode2 = text
    End Function
    Function XMLEncode2(x)
        Dim text
        text = ConvertTo(vbString,x)
        text = Replace(text,"<","&lt;")
        text = Replace(text,">","&gt;")
        text = Replace(text,"""","&#34;")
        text = Replace(text,"'","&#46;")
        text = Replace(text,"&","&amp;")
        XMLEncode2 = text
    End Function
    
    Function Elipsis(t,maxLen)
        Dim txt
        txt = ConvertTo(vbString,t)
        If Len(txt) > maxLen Then
            Elipsis = Left(txt,maxLen) & "..."
        Else
            Elipsis = txt
        End If
    End Function
    Function Ellipsis(txt,maxLen)
        Ellipsis = Elipsis(txt,maxLen)
    End Function
    
    Function IsOneOf(baseSet,strElement,delimiter)
        Dim arr, I
        IsOneOf = False
        arr = Split(baseSet,delimiter)
        If IsArray(arr) Then
            For I = LBound(arr) To UBound(arr)
                If Trim(arr(I)) = strElement Then
                    ISOneOf = True
                    Exit Function
                End If
            Next
        End If
    End Function
    Function ImplementsProtocol(ctl,prot)
        ImplementsProtocol = False
        On Error Resume Next
        Dim p
        p = ctl.Protocols
        If Err.Number <> 0 Then 
            Err.Clear
            Exit Function
        End If
        If IsOneOf(ctl.Protocols, prot,",") Then
            ImplementsProtocol = True
        End If
    End Function
    
    ' Encryption parameters
    ' Change these in the beginning of the page if desired
    '   The settings must remain constant throught the postbacks in order the controls using them to work!
    Dim PageEncryptMethod, PageCryptKey
    Function GeneratePageEncryptionKey
        Dim bd, level
        Set bd = Server.CreateObject("newObjects.crypt.Number")
        level = ConvertTo(vbLong,Application("PageCryptLevel"))
        if level > 2 Or level < 0 then level = 0
        If UCase(PageEncryptMethod) = "DES" Then
            ' Response.Write "BD:" & VarType(bd.Random(8 + (8*level),True,True))
            bd.Random 8 + (8*level),True,True
            Session("PageCryptKey") = UCase(bd.Hex)
        ElseIf UCase(PageEncryptMethod) = "AES" Then
            bd.Random 16 + (8*level),True,True
            Session("PageCryptKey") = UCase(bd.Hex)
        Else
            Session("PageCryptKey") = Empty
        End If
        GeneratePageEncryptionKey = Session("PageCryptKey")
    End Function
    Public Sub InitEncryption
        If Not IsEmpty(Session("PageEncryptMethod")) Then
            PageEncryptMethod = CStr(Session("PageEncryptMethod"))
        ElseIf Not IsEmpty(Application("PageEncryptMethod")) Then
            PageEncryptMethod = CStr(Application("PageEncryptMethod"))
        Else
            PageEncryptMethod = "DES"
        End If
        
        If Not IsEmpty(Session("PageCryptKey")) Then
            PageCryptKey = CStr(Session("PageCryptKey"))
        ElseIf Not IsEmpty(Application("PageCryptKey")) Then
            PageCryptKey = CStr(Application("PageCryptKey"))
        Else
            PageCryptKey = GeneratePageEncryptionKey
        End If
    End Sub
    
    InitEncryption
    
    Dim PageCryptoObjectInstance
    Set PageCryptoObjectInstance = Nothing
    Function PageCryptoObject()
        If PageCryptoObjectInstance Is Nothing Then
            Dim o
            Set o = Server.CreateObject("newObjects.crypt.Symmetric")
            o.Init PageEncryptMethod
            o.Key = PageCryptKey
            Set PageCryptoObjectInstance = o
        End If
        Set PageCryptoObject = PageCryptoObjectInstance
    End Function
    Function PageEncryptString(s)
        Dim bd, su
        Set bd = Server.CreateObject("newObjects.utilctls.SFBinaryData")
        Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
        bd.Size = 4 + (Len(s) * 2) + 2
        bd.Unit(0,vbLong) = Len(s)
        bd.UnicodeString(4) = s
        Dim c
        Set c = PageCryptoObject
        bd.Value = c.Encrypt(bd.Value,True)
        PageEncryptString = su.BinToHex(bd.Value)
    End Function
    Function PageDecryptString(s)
        Dim bd, su
        Set bd = Server.CreateObject("newObjects.utilctls.SFBinaryData")
        Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
        Dim c
        Set c = PageCryptoObject
        bd.Value = su.HexToBin(s)
        bd.Value = c.Decrypt(bd.Value,True)
        If bd.Size > 0 Then
            Dim strLen
            strLen = bd.Unit(0,vbLong)
            PageDecryptString = bd.UnicodeString(4,strLen)
        Else
            PageDecryptString = ""
        End If
    End Function
    Function PageEncryptData(bindata)
        Dim c
        Set c = PageCryptoObject
        PageEncryptData = c.Encrypt(bindata,True)
    End Function
    Function PageDecryptData(bindata)
        Dim c
        Set c = PageCryptoObject
        PageDecryptData = c.Decrypt(bindata,True)
    End Function
    
    ' Persist TS Section
    Function TSToHex(ts,bEncrypt)
        Dim mem, sf, cf, su
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        Set cf = Server.CreateObject("newObjects.utilctls.Configfile")
        cf.PreserveStringsWide = True
        cf.PreserveUnsignedInt = True
        cf.UseStreamTags = True
        cf.RequireStreamTags = True
        Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
        If ts.Count = 0 Then
            TSToHex = ""
            Exit Function
        End If
        Set mem = sf.CreateMemoryStream
        cf.WriteToBinaryStream mem, ts
        mem.Pos = 0
        If bEncrypt Then
            TSToHex = su.BintoHex(PageEncryptData(mem.ReadBin(mem.Size)))
        Else
            TSToHex = su.BintoHex(mem.ReadBin(mem.Size))
        End If
    End Function
    Function TSFromHex(hex,bDecrypt)
        Dim mem, sf, cf, su
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        Set cf = Server.CreateObject("newObjects.utilctls.Configfile")
        If Len(hex) = 0 Then
            Set TSFromHex = cf.CreateSection
            Exit Function
        End If
        cf.PreserveStringsWide = True
        cf.PreserveUnsignedInt = True
        cf.UseStreamTags = True
        cf.RequireStreamTags = True
        Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
        Set mem = sf.CreateMemoryStream
        If bDecrypt Then
            mem.WriteBin PageDecryptData(su.HexToBin(hex))
        Else
            mem.WriteBin su.HexToBin(hex)
        End If
        mem.Pos = 0
        If mem.Size = 0 Then
            Set TSFromHex = cf.CreateSection
        Else
            Set TSFromHex = cf.ReadFromBinaryStream(mem)
        End If
    End Function
    
    ' General options
    If Not IsEmpty(Application("EncryptSecondaryData")) Then
        EncryptSecondaryData = ConvertTo(vbBoolean, Application("EncryptSecondaryData"))
    Else
        EncryptSecondaryData = False
    End If
    
    ' Helper for simple file read operations
    Function ReadTextFile(txtfilePath,cp)
        Dim sf, f, c
        ReadTextFile = Empty
        On Error Resume Next
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        Set f = sf.OpenFile(txtFilePath,&H40)
        If Err.Number <> 0 Then Exit Function
        c = ConvertTo(vbLong, cp)
        If c < 0 Then
            f.unicodeText = True
        ElseIf c > 0 Then
            f.CodePage = c
        End If
        ReadTextFile = f.ReadText(-2)
        f.Close
    End Function
    
    ' Globals used by all controls in this and other files
    Dim G_CurrentControl
    G_CurrentControl = 0
    
    Function NewCtlName()
        NewCtlName = "C" & G_CurrentControl
        G_CurrentControl = G_CurrentControl + 1
    End Function
    
    Dim G_CurrentClientId
    G_CurrentClientId = 0
    Function NewClientId()
        NewClientId = "I" & G_CurrentClientId
        G_CurrentClientId = G_CurrentClientId + 1
    End Function    

%>
<!-- #include file="errconst.asp" -->
<!-- #include file="aspctl-upload.asp" -->
<%    
    
    
    ' Page API
    ' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ' General purpose routines

    Dim UseMultipartFormData ' Automatically set to true by the CFile control
    UseMultipartFormData = CBool(ASPCTL_FileUpload)
    Dim ASPCTLPartial ' If non-empty this is a partial request
    ASPCTLPartial = ConvertTo(vbString,ASPALL(ASPCTL_Partial))
    
    Dim Controls ' A collection of all the controls on the page
    Set Controls = CreateCollection()
    Dim UserControls
    Set UserControls = CreateCollection()
    
    Sub RegisterUserControl(c)
        UserControls.Add c.Name, c
    End Sub
    Sub ReplaceUserControl(c)
        Set UserControls(c.Name) = c
    End Sub
    Sub UserControlPriority(c,cOther)
        If Not IsObject(c) Or Not IsObject(cOther) Then
             Err.Raise 1,"UserControlPriority","One of the arguments is not an object."
             Exit Sub
        End If
        UserControls.Remove c.Name
        If cOther Is Nothing Then
            UserControls.Insert 1, c, c.Name
        Else
            UserControls.Insert cOther.Name, c, c.Name
        End If
    End Sub
    Sub UserControlProcessLast(c)
        UserControls.Remove c.Name
        UserControls.Add c.Name, c
    End Sub
    Sub ProcessUserControls
        Dim I
        For I = 1 To UserControls.Count
            UserControls(I).ProcessPage
            If CancelProcessing Then Exit For
        Next
    End Sub
    
    Dim PreRenderControls
    Set PreRenderControls = CreateCollection
    ' The control must have a PreRender Function with 1 arguments, the return value is ignored for now, the argument is Empty for now
    Sub RegisterForPreRender(ctl)
        PreRenderControls.Add ctl.Name, ctl
    End Sub
    ' Called implicitly by Begin_Page, if you do not use it - call it before the rendering begins
    Sub PerformPreRender
        Dim I
        For I = 1 To PreRenderControls.Count
            PreRenderControls(I).PreRender Empty
        Next
        On Error Resume Next
        PreRenderPage Empty ' Calls a global page routine if there is any
    End Sub
    
    Dim Validators
    Set Validators = CreateCollection()
    
    Const cAllControls = Empty
    Dim ValidateInGroupsOnly
    If IsEmpty(ValidateInGroupsOnly) Then ValidateInGroupsOnly = False
    Dim EnableClientValidation
    
    Function ValidateControls(aGroup)
        Dim b, I
        b = True
        If ValidateInGroupsOnly Then
            For I = 1 To Validators.Count
                If UCase(Validators(I).Group) = UCase(aGroup) Then
                    If Not Validators(I).PerformValidate Then
                        b = False
                    End If
                End If
            Next
        Else
            For I = 1 To Validators.Count
                If IsEmpty(aGroup) Or UCase(Validators(I).Group) = UCase(aGroup) Then
                    If Not Validators(I).PerformValidate Then
                        b = False
                    End If
                End If
            Next
        End If
        ValidateControls = b
    End Function
    Function Validate(aGroups)
        Dim b, I
        b = True
        If ValidateInGroupsOnly Then
            For I = 1 To Validators.Count
                If IsOneOf(aGroups,Validators(I).Group,",") Or (IsEmpty(aGroups) And IsEmpty(Validators(I).Group)) Then
                    If Not Validators(I).PerformValidate Then
                        b = False
                    End If
                End If
            Next
        Else
            For I = 1 To Validators.Count
                If IsEmpty(aGroups) Or IsOneOf(aGroups,Validators(I).Group,",") Then
                    If Not Validators(I).PerformValidate Then
                        b = False
                    End If
                End If
            Next
        End If
        Validate = b
    End Function
    
    Function GetValidatorMessages(aGroup)
        Dim I, coll
        Set coll = CreateCollection
        If IsEmpty(aGroup) Then
            For I = 1 to Validators.Count
                If Not Validators(I).IsValid And Len(Validators(I).Message) > 0 Then coll.Add Validators.Key(I), Validators(I).Message
            Next
        Else
            For I = 1 to Validators.Count
                If UCase(Validators(I).Group) = UCase(aGroup) Then
                    If Not Validators(I).IsValid And Len(Validators(I).Message) > 0 Then coll.Add Validators.Key(I), Validators(I).Message
                End If
            Next
        End If
        Set GetValidatorMessages = coll
    End Function
    ' Foreign date time parsers
	Private Function ParseUTCDate(s)
		Dim re, ms, m, result
		Dim a,b,c
		result = Null
		If IsNull(s) Then Exit Function
		Set re = New RegExp
		re.Pattern = "^(\d{1,4})-(\d{1,2})-(\d{1,2})$"
		Set ms = re.Execute(s)
		If Not ms Is Nothing Then
			If ms.Count > 0 Then
				Set m = ms(0)
				result = DateSerial(ConvertTo(vbLong, m.Submatches(0)),ConvertTo(vbLong, m.Submatches(1)), ConvertTo(vbLong, m.Submatches(2)) )
			End If
		End If
		ParseUTCDate = result
	End Function
	Private Function ParseUTCDateTime(s, zone)
		Dim re, ems, m, result
		Dim a,b,c
		result = Null
		If IsNull(s) Then Exit Function
		Set re = New RegExp
		re.Global = True
		' re.Pattern = "^(\d{1,4})-(\d{1,2})-(\d{1,2})(?:T(\d{1,2}):(\d{1,2}):(\d{1,2})(Z|z|\+|\-)?(\d{1,2}):(\d{1,2}))?$"
		' re.Pattern = "^(\d{1,4})-(\d{1,2})-(\d{1,2})(?:T(\d{1,2}):(\d{1,2}):(\d{1,2})(Z|z|\+|\-)?(?:(\d{1,2}):(\d{1,2})))?$"
		re.Pattern = "^(\d{1,4})-(\d{1,2})-(\d{1,2})(?:T(\d{1,2}):(\d{1,2}):(\d{1,2}))?"
		Set ems = re.Execute(s)
		If Not ems Is Nothing Then
			If ems.Count > 0 Then
				Set m = ems(0)
				result = DateSerial(ConvertTo(vbLong, m.Submatches(0)),ConvertTo(vbLong, m.Submatches(1)), ConvertTo(vbLong, m.Submatches(2)) )
				If Len(m.Submatches(3)) > 0 Then
					result = DateAdd("h",ConvertTo(vbLong,m.Submatches(3)),result)
					result = DateAdd("n",ConvertTo(vbLong,m.Submatches(4)),result)
					result = DateAdd("s",ConvertTo(vbLong,m.Submatches(5)),result)
				End If
			End If
		End If
		ParseUTCDateTime = result
	End Function
    ' Date/Time conversion
    Private Function GetFieldAsLong(dstr,fmt,mask)
        Dim I,J,s
        I = InStr(fmt,mask)
        If I > 0 Then
            For J = I To Len(Fmt) + 1
                If Mid(fmt,J,1) <> mask Then
                    J = J - 1
                    Exit For
                End If
            Next
            s = Mid(dstr,I,J - I + 1)
            GetFieldAsLong = TryConvertTo(vbLong,s)
        Else
            GetFieldAsLong = 0
        End If
    End Function
    Function ParseDateString(dstr,fmtIn)
        Dim fmt
        If Len(fmtIn) = 0 Then fmt = PageUIDateFormat Else fmt = fmtIn
        If dstr = "" Then
            ParseDateString = Null
            Exit Function
        End If
        Dim Y,M,D,H,N,S
        Y = GetFieldAsLong(dstr,fmt,"Y")
        M = GetFieldAsLong(dstr,fmt,"M")
        D = GetFieldAsLong(dstr,fmt,"D")
        H = GetFieldAsLong(dstr,fmt,"h")
        N = GetFieldAsLong(dstr,fmt,"m")
        S = GetFieldAsLong(dstr,fmt,"s")
        On Error Resume Next
        Dim dt
        dt = DateSerial(Y,M,D)
        dt = DateAdd("h",H,dt)
        dt = DateAdd("n",N,dt)
        dt = DateAdd("s",S,dt)
        ParseDateString = dt
        If Err.Number <> 0 Then ParseDateString = Null
        Err.Clear
    End Function
    
    Private Function GetFieldMask(fmt,mask)
        Dim I,J,s
        I = InStr(fmt,mask)
        If I > 0 Then
            For J = I To Len(Fmt) + 1
                If Mid(fmt,J,1) <> mask Then
                    J = J - 1
                    Exit For
                End If
            Next
            GetFieldMask = String(J-I+1,mask)
        Else
            GetFieldMask = ""
        End If
    End Function
    Public Function GetDateTimeFormatRegExp(fmt)
        Dim p, I, numpats
        numpats = "YMDhms"
        p = ""
        For I = 1 To Len(fmt)
            If InStr(numpats,Mid(fmt,I,1)) > 0 Then
                p = p & "\d"
            ElseIf Mid(fmt,I,1) = " " Then
                p = p & "\s"
            Else
                p = p & "\" & Mid(fmt,I,1)
            End If
        Next
        GetDateTimeFormatRegExp = p
    End Function
    Sub SetUTCTimeOffset(t) ' In minutes
        Session("ASPCTL_TIMEOFFSET") = ConvertTo(vbLong, t)
    End Sub
    Function GetUTCTimeOffset
        GetUTCTimeOffset = ConvertTo(vbLong, Session("ASPCTL_TIMEOFFSET"))
    End Function
    Function UTCToLocal(t)
        Dim m, d
        UTCToLocal = t
        d = NullConvertTo(vbDate, t)
        If IsNull(d) Then Exit Function
        UTCToLocal = DateAdd("n",GetUTCTimeOffset,d)        
    End Function
    Function LocalToUTC(t)
        Dim m, d
        LocalToUTC = t
        d = NullConvertTo(vbDate, t)
        If IsNull(d) Then Exit Function
        LocalToUTC= DateAdd("n",(- GetUTCTimeOffset),d)        
    End Function
	Dim ASPCTL_dtBase
	ASPCTL_dtBase = DateSerial(1970,1,1)
	Function JSMilliseconds(dt, bLocal)
		If bLocal Then
			JSMilliseconds = DateDiff("s",DateSerial(1970,1,1), LocalToUTC(dt)) * 1000
		Else
			JSMilliseconds = DateDiff("s",DateSerial(1970,1,1), dt) * 1000
		End If
	End Function
	Function FromJSMilliseconds(ms, bLocal)
		FromJSMilliseconds = Null
		If IsNull(ms) Or IsEmpty(ms) Then
			Exit Function
		End If
		Dim dt
		If ms = 0 Then
			dt = DateSerial(1970,1,1)
		Else
			dt = DateAdd("s",ms / 1000,DateSerial(1970,1,1))
		End If
		If bLocal Then
			dt = UTCToLocal(dt)
		End If
		FromJSMilliseconds = dt
	End Function
	Function FromJSONMSDateTime(str, bLocal)
		Dim ms, re, mm
		FromJSONMSDateTime = Null
		Set re = New RegExp
		re.Global = True
		re.IgnoreCase = True
		re.Pattern = "\/Date\(([+-]?\d+)\)\/"
		Set ms = re.Execute(str)
		If Not ms Is Nothing Then
			If ms.Count > 0 Then
				mm = NullConvertTo(vbDouble, ms(0).Submatches(0))
				If Not IsNull(mm) Then
					FromJSONMSDateTime = FromJSMilliseconds(mm, bLocal)
					Exit Function
				End If
			End If
		End If
		re.Pattern = "\\/Date\(([+-]?\d+)\)\\/"
		Set ms = re.Execute(str)
		If Not ms Is Nothing Then
			If ms.Count > 0 Then
				mm = NullConvertTo(vbDouble, ms(0).Submatches(0))
				If Not IsNull(mm) Then
					FromJSONMSDateTime = FromJSMilliseconds(mm, bLocal)
					Exit Function
				End If
			End If
		End If
	End Function
    
    Function FormatDateString(dt,fmtIn)
        If IsNull(dt) Or IsEmpty(dt) Then
            FormatDateString = ""
            Exit Function
        End If
        Dim fmt
        If Len(fmtIn) = 0 Then fmt = PageUIDateFormat Else fmt = fmtIn
        Dim su 
        Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
        Dim s,part
        s = Mid(fmt,1)
        
        part = GetFieldMask(s,"Y")
        If part <> "" Then 
            If Len(part) < 4 Then
                s = Replace(s,part,su.Sprintf("%0" & Len(part) & "d",Right(CStr(Year(dt)),Len(part) ) ))
            Else
                s = Replace(s,part,su.Sprintf("%0" & Len(part) & "d",CStr(Year(dt))))
            End If
        End If
        part = GetFieldMask(s,"M")
        If part <> "" Then s = Replace(s,part,su.Sprintf("%0" & Len(part) & "d",CStr(Month(dt))))
        part = GetFieldMask(s,"D")
        If part <> "" Then s = Replace(s,part,su.Sprintf("%0" & Len(part) & "d",CStr(Day(dt))))
        part = GetFieldMask(s,"h")
        If part <> "" Then s = Replace(s,part,su.Sprintf("%0" & Len(part) & "d",CStr(Hour(dt))))
        part = GetFieldMask(s,"m")
        If part <> "" Then s = Replace(s,part,su.Sprintf("%0" & Len(part) & "d",CStr(Minute(dt))))
        part = GetFieldMask(s,"s")
        If part <> "" Then s = Replace(s,part,su.Sprintf("%0" & Len(part) & "d",CStr(Second(dt))))
        FormatDateString = s
    End Function
    Function DateTimeSerial(y,m,d,h,n,s)
        Dim dt
        dt = DateSerial(y,m,d)
        dt = dt + TimeSerial(h,n,s)
        DateTimeSerial = dt
    End Function
    
    Dim PreservedGetParams
    PreservedGetParams = Empty
    
    Function HttpGetParams()
        If Not IsEmpty(PreservedGetParams) Then
            HttpGetParams = PreservedGetParams
            Exit Function
        End If 
        On Error Resume Next
        Dim I, sParams,s
        sParams = ""
        For I = 1 To Controls.Count
            Err.Clear
            If Controls(I).ClassType <> "CLink" Then
                s = Controls(I).HttpGetParams
                If Err.Number = 0 And Len(s) > 0 Then
                    If sParams <> "" Then sParams = sParams & "&" & s Else sParams = sParams & s
                End If
            End If
        Next
        For I = 1 To UserControls.Count
            Err.Clear
            s = UserControls(I).HttpGetParams
            If Err.Number = 0 And Len(s) > 0 Then
                If sParams <> "" Then sParams = sParams & "&" & s Else sParams = sParams & s
            End If
        Next
        PreservedGetParams = sParams
        HttpGetParams = sParams
        Err.Clear
    End Function
    Function PageLink(pg, strParams)
        Dim s
        s = HttpGetParams
        If Len(s) > 0 Then
            s = s & "&" & strParams
        Else
            s = strParams
        End If
        If Len(s) > 0 Then s = pg & "?" & s Else s = pg
        PageLink = s
    End Function
    Function PageLinkExclude(ctl, pg, strParams)
        Dim t, s
        t = ctl.PreserveInQueryString
        ctl.PreserveInQueryString = False
        s = PageLink(pg,strParams)
        ctl.PreserveInQueryString = t
        PageLinkExclude = s
    End Function
    Function SelfLink(strParams)
        SelfLink = PageLink(Self, strParams)
    End Function
    Function SelfLinkExclude(ctl, strParams)
        SelfLinkExclude = PageLinkExclude(ctl, Self, strParams)
    End Function
    
    Function ClassCount(coll,clsType)
        Dim I, cnt
        cnt = 0
        For I = 1 To coll.Count
            Err.Clear
            If coll(I).ClassType = clsType Then
                cnt = cnt + 1
            End If
        Next
        ClassCount = cnt
    End Function
    
    
    Dim PageKeywords 
    Set PageKeywords = CreateCollection()
    Sub AddPageKeyword(w)
        Dim sw
        sw = ConvertTo(vbString, w)
        If Len(sw) > 0 Then
            PageKeywords.Add "", sw
        End If
    End Sub
    Function RenderPageKeywords
        Dim s, I
        s = ""
        For I = 1 To PageKeywords.Count
            s = s & HTMLEncode2(PageKeywords(I))
            If I < PageKeywords.Count Then s = s & ","
        Next
        RenderPageKeywords = s
    End Function
    
    Dim PageDescription
    Dim PageTitle
    If IsEmpty(PageTitle) Then PageTitle = "(unnamed page)"
    Dim PageStyleSheet, EmbeddedStyleSheet
    If IsEmpty(PageStyleSheet) Then PageStyleSheet = "styles.css"
    EmbeddedStyleSheet = False ' Embedding is recommended for mobile sites
        
    Dim PageMetas, PageCustomMetas
    Set PageMetas = CreateCollection
    Sub AddMeta(n,v)
        PageMetas.Add n, v
    End Sub
    AddMeta "Generator", "newObjects [] Active Server Controls (ASP-CTL)"
    Sub RenderPageMetas
        Dim I
        For I = 1 To PageMetas.Count
            %><meta name="<%= PageMetas.Key(I) %>" content="<%= PageMetas(I) %>" />
            <%
        Next
    End Sub
    Set PageCustomMetas = CreateTSSection(Empty)
    Function AddCustomMeta(keyname)
        Dim o
        Set o = CreateTSRecord
        PageCustomMetas.Add CStr(keyname), o
        Set AddCustomMeta = o
    End Function
    Sub RenderPageCustomMetas
        Dim I, J, r
        For I = 1 To PageCustomMetas.Count
            Response.Write "<meta "
            Set r = PageCustomMetas(I)
            For J = 1 To r.Count
                Response.Write r.Key(J) & "=""" & HTMLEncode2(r(J)) & """ "
            Next
            Response.Write "/>" & vbCrLf
        Next
    End Sub
    
    Dim PageXMLNamespaces
    Set PageXMLNamespaces = CreateDictionary
    
    
    Dim PageRels
    Set PageRels = CreateTSSection(Empty)
    Function AddLinkRel(rel,h)
        Dim o
        Set o = CreateTSRecord
        o("rel") = ConvertTo(vbString,rel)
        o("href") = ConvertTo(vbString,h)
        PageRels.Add rel, o
        Set AddLinkRel = o
    End Function
    Function AddLinkRev(rev,h)
        Dim o
        Set o = CreateTSRecord
        o("rev") = ConvertTo(vbString,rev)
        o("href") = ConvertTo(vbString,h)
        PageRels.Add rev, 0
        Set AddLinkRev = o
    End Function
    
    ' Special images
    Function SysImage(imgName)
        Select Case LCase(imgName)
            Case "open"
                SysImage = ASPCTLPath & "img/open.gif"
            Case "save"
                SysImage = ASPCTLPath & "img/save.gif"
            Case "check"
                SysImage = ASPCTLPath & "img/check.gif"
            Case "ok"
                SysImage = ASPCTLPath & "img/ok.gif"
            Case "help"
                SysImage = ASPCTLPath & "img/help.gif"
            Case "reload"
                SysImage = ASPCTLPath & "img/Sychronize.gif"
            Case "folder"
                SysImage = ASPCTLPath & "img/folder.gif"
            Case "upload"
                SysImage = ASPCTLPath & "img/upload.gif"
            Case "clock"
                SysImage = ASPCTLPath & "img/clock.gif"
            Case "calendar"
                SysImage = ASPCTLPath & "img/calendar.gif"
            Case "download"
                SysImage = ASPCTLPath & "img/download.gif"
            Case "home"
                SysImage = ASPCTLPath & "img/home.gif"
            Case "edit"
                SysImage = ASPCTLPath & "img/edit.gif"
            Case "last"
                SysImage = ASPCTLPath & "img/last.gif"
            Case "next"
                SysImage = ASPCTLPath & "img/next.gif"
            Case "prev"
                SysImage = ASPCTLPath & "img/prev.gif"
            Case "url"
                SysImage = ASPCTLPath & "img/url.gif"
            Case "user"
                SysImage = ASPCTLPath & "img/user.gif"
            Case "users"
                SysImage = ASPCTLPath & "img/users.gif"
            Case "err"
                SysImage = ASPCTLPath & "img/err.gif"
            Case "cancel"
                SysImage = ASPCTLPath & "img/cancel.gif"
            Case "delete"
                SysImage = ASPCTLPath & "img/delete.gif"
            Case "first"
                SysImage = ASPCTLPath & "img/first.gif"
            Case "new"
                SysImage = ASPCTLPath & "img/new.gif"
            Case "button"
                SysImage = ASPCTLPath & "img/button.gif"
            Case "poweredby"
                SysImage = ASPCTLPath & "img/powered-by-asp-ctl-and-sqlite.gif"
            Case Else
                SysImage = ASPCTLPath & "img/pixel.gif"
        End Select
    End Function
    Function QuickHTMLImage(src,w,h)
        Dim s, simg
        If Left(src,1) = "#" Then simg = SysImage(Mid(src,2)) Else simg = VirtPath(src)
        s = "<img src=""" & simg & """ alt="""" "
        If Len(w) <> 0 Then s = s & "width=""" & w & """ "
        If Len(h) <> 0 Then s = s & "height=""" & h & """ "
        s = s & "/>"
        QuickHTMLImage = s
    End Function
    Function FileIcon(ext)
        Dim sf
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        If sf.FileExists(Server.MapPath(ASPCTLPath & "fileimg/" & ext & ".gif")) Then
            FileIcon = ASPCTLPath & "fileimg/" & ext & ".gif"
        Else
            FileIcon = ASPCTLPath & "fileimg/unknown.gif"
        End If
        
    End Function
    
    ' Name clean up
    Function GetValueFromFieldName(s,basePart,delimiter)
        Dim pos, v, nameLen, nameBase
        v = s
        If UCase(Right(v,2)) = ".X" Or UCase(Right(v,2)) = ".Y" Then v = Left(v,Len(v) - 2)
        nameLen = Len(basePart)
        pos = InStr(v,delimiter)
        If pos > 0 Then
            GetValueFromFieldName = Mid(v,pos + Len(delimiter))
        Else
            GetValueFromFieldName = ""
        End If
    End Function
    Function GetValuesForFieldName(coll,ctlName,delimiter)
        Dim vcompare, I, result, compareLen
        vcompare = UCase(ctlName & delimiter)
        compareLen = Len(vCompare)
        Set result = CreateCollection
        For I = 1 To coll.Count
            If UCase(Right(coll.Key(I),2)) <> ".Y" And UCase(Left(coll.Key(I),compareLen)) = vcompare Then
                result.Add Empty, GetValueFromFieldName(coll.Key(I),ctlName,delimiter)
            End If
        Next
        Set GetValuesForFieldName = result
    End Function
    Function CollectValuesFromRequest(ctlName,delimiter)
        Dim r1, r2
        Set r1 = GetValuesForFieldName(ASPGET,ctlName,delimiter)
        Set r2 = GetValuesForFieldName(ASPPOST,ctlName,delimiter)
        Dim I
        For I = 1 To r2.Count
            r1.Add Empty, r2(I)
        Next
        Set CollectValuesFromRequest = r1
    End Function
    
    ' Updates also the encoding and the code page as neccessary
    Function PageUILanguage
        If IsEmpty(Session("PageUILanguage")) Then
            SetSessionLanguage(Empty) 'Defaults to English if the language is requested but not set previously
        End If
        PageUILanguage = Session("PageUILanguage")
    End Function
    Function PageUIEncoding
        If IsEmpty(Session("PageUILanguage")) Then
            SetSessionLanguage(Empty) 'Defaults to English if the language is requested but not set previously
        End If
        PageUIEncoding = Session("PageUIEncoding")
    End Function
    Function PageUILanguageName
        If IsEmpty(Session("PageUILanguage")) Then
            SetSessionLanguage(Empty) 'Defaults to English if the language is requested but not set previously
        End If
        PageUILanguageName = Session("PageUILanguageName")
    End Function
    Function PageUICodePage
        If IsEmpty(Session("PageUILanguage")) Then
            SetSessionLanguage(Empty) 'Defaults to English if the language is requested but not set previously
        End If
        PageUICodePage = Session.CodePage
    End Function
    Function PageUIDateFormat
        If IsEmpty(Session("PageUILanguage")) Then
            SetSessionLanguage(Empty)
        End If
        If Not IsEmpty(Session("PageUIDateFormat")) Then PageUIDateFormat = Session("PageUIDateFormat") Else PageUIDateFormat = "YYYY-MM-DD"
    End Function
    Function PageUITimeFormat
        If IsEmpty(Session("PageUILanguage")) Then
            SetSessionLanguage(Empty)
        End If
        If Not IsEmpty(Session("PageUITimeFormat")) Then PageUITimeFormat = Session("PageUITimeFormat") Else PageUITimeFormat = "hh:mm:ss"
    End Function
    Function PageUIDateTimeFormat
        If IsEmpty(Session("PageUILanguage")) Then
            SetSessionLanguage(Empty)
        End If
        If Not IsEmpty(Session("PageUIDateTimeFormat")) Then PageUIDateTimeFormat = Session("PageUIDateTimeFormat") Else PageUIDateTimeFormat = "YYYY-MM-DD hh:mm:ss"
    End Function
    
    Function GetFirstSupportedBrowserLanguage
        ' ASPCTL_RESOURCE_DATABASE must be set prior to calling this routine. Do not use ASPCTLResDB because this will cause unwanted recursion and deadlock
        Dim arrLangsFull, L, arrLang, Lang, MainLang, arr, r
        arrLangsFull = Split(ASPVARS("HTTP_ACCEPT_LANGUAGE"),",")
        If IsArray(arrLangsFull) Then
            For L = LBound(arrLangsFull) To UBound(arrLangsFull)
                arrLang = Split(arrLangsFull(L),";")
                If IsArray(arrLang) Then
                    If UBound(arrLang) >= 0 Then
                        ' We have something
                        Lang = arrLang(0)
                        If ASPCTL_RESOURCE_DATABASE.VExecute("SELECT COUNT(*) FROM LANGUAGES WHERE LANGUAGE=$l",1,1,Lang)(1)(1) > 0 Then
                            GetFirstSupportedBrowserLanguage = Lang
                            Exit Function
                        Else
                            ' Try main language
                            arr = Split(Lang,"-")
                            If IsArray(arr) Then
                                If UBound(arr) >= 0 Then
                                    If arr(0) <> Lang Then
                                        If ASPCTL_RESOURCE_DATABASE.VExecute("SELECT COUNT(*) FROM LANGUAGES WHERE LANGUAGE=$l",1,1,arr(0))(1)(1) > 0 Then
                                            GetFirstSupportedBrowserLanguage = arr(0)
                                            Exit Function
                                        End If
                                    End If
                                End If
                            End If
                        End If
                    End If
                End If
            Next
        End If
        If Not IsEmpty(Application("DefaultFallBackLanguage")) Then
            GetFirstSupportedBrowserLanguage = Application("DefaultFallBackLanguage")
        Else
            GetFirstSupportedBrowserLanguage = "en"
        End If
    End Function
    
    Public SupportedLanguages
    Sub ASPCTL_InitSupportedLanguages
        Dim r, s, I
        If Not IsEmpty(SupportedLanguages) Then
            Exit Sub
        End If
        If IsEmpty(Application("ASPCTL_SupportedLanguages")) Then
            Set r = ASPCTLResDB.Execute("SELECT LANGUAGE FROM LANGUAGES")
            s = ""
            For I = 1 To r.Count
                If I > 1 Then s = s & ","
                s = s & r(I)(1)
            Next
            Application("ASPCTL_SupportedLanguages") = Split(s,",")
        End If
        SupportedLanguages = Application("ASPCTL_SupportedLanguages")
    End Sub
    
    Function IsLanguageSupported(lang)
        Dim I
        IsLanguageSupported = False
        For I = LBound(SupportedLanguages) To UBound(SupportedLanguages)
            If SupportedLanguages(I) = lang Then
                IsLanguageSupported = True
                Exit Function
            End If
        Next
    End Function
    
    Sub SetSessionLanguage(langIn)
        Dim db, r, lang
        If Not IsObject(ASPCTL_RESOURCE_DATABASE) Then
            Set ASPCTL_RESOURCE_DATABASE = Server.CreateObject("newObjects.sqlite3.dbutf8")
            ASPCTL_RESOURCE_DATABASE.Open ASPCTLResDBPath
        End If
        If IsEmpty(langIn) Then
            If Not IsEmpty(Application("PageUILanguage")) Then
                lang = Application("PageUILanguage")
            Else
                lang = GetFirstSupportedBrowserLanguage
            End If
        Else
            lang = langIn            
        End IF
        Set db = ASPCTL_RESOURCE_DATABASE ' We cannot use the internal views here - language parameter is required and we do not know it yet
        Set r = db.VExecute("SELECT * FROM Languages WHERE Language=$Lang",1,1,ConvertTo(vbString,lang))
        If r.Count > 0 Then
            Session("PageUILanguage") = r(1)("LANGUAGE")
            Session("PageUILanguageName") = r(1)("NAME")
            Session("PageUIEncoding") = r(1)("ENCODING")
            Session("PageUICodePage") = r(1)("CODEPAGE")
            If Not IsNull(r(1)("DATEFORMAT")) Then
                Session("PageUIDateFormat") = r(1)("DATEFORMAT")
            End If
            If Not IsNull(r(1)("TIMEFORMAT")) Then
                Session("PageUITimeFormat") = r(1)("TIMEFORMAT")
            End If
            If Not IsNull(r(1)("DATETIMEFORMAT")) Then
                Session("PageUIDateTimeFormat") = r(1)("DATETIMEFORMAT")
            End If
            Session.CodePage = Session("PageUICodePage")
        Else
            Err.Raise 1, "ASPCTL", "Language not found in the resource database"
        End If
    End Sub
    
    ' Code page fixer - the Session.CodePage gets lost on some versions of IIS under some circumstances
    ' Keep the commented code as a hint, current solution works fine, but there should be better ways to treat this
    'If Not IsEmpty(Session("PageUICodePage")) Then
    '     If Session.CodePage <> Session("PageUICodePage") Then Session.CodePage = Session("PageUICodePage")
    'End If
    Session.CodePage = PageUICodePage ' Make sure before we begin
    
    ' ASPCTL REsource database
    Dim ASPCTL_RESOURCE_DATABASE
    Function ASPCTLResDB
        If Not IsObject(ASPCTL_RESOURCE_DATABASE) Then
            Set ASPCTL_RESOURCE_DATABASE = Server.CreateObject("newObjects.sqlite3.dbutf8")
            ASPCTL_RESOURCE_DATABASE.Open ASPCTLResDBPath
        End If
        ASPCTL_RESOURCE_DATABASE.Parameters("Language") = PageUILanguage
        Set ASPCTLResDB = ASPCTL_RESOURCE_DATABASE
    End Function
    
    Function TR(n)
        If DisableTranslation Then
            TR = n
            Exit Function
        End If
        Dim r
        Set r = ASPCTLResDB.VExecute("SELECT CONTENT FROM VTexts WHERE ORIGINAL=$Name AND LANGUAGE=$l",1 , 1, n, PageUILanguage)
        
        If r.Count > 0 Then
            TR = r(1)(1)
        Else
            TR = n
            If ConvertTo(vbBoolean,Application("RecordTexts")) Then
                ASPCTLResDB.VExecute "INSERT INTO MainTexts (CONTENT,LANGUAGE) VALUES ($c,$l)",1,0, n, PageUILanguage
            End If
        End If
    End Function
    Function TRTO(n,lang)
        If DisableTranslation Then
            TRTO = n
            Exit Function
        End If
        Dim r
        Set r = ASPCTLResDB.VExecute("SELECT CONTENT FROM VTexts WHERE ORIGINAL=$Name AND LANGUAGE=$l",1 , 1, n, lang)
        
        If r.Count > 0 Then
            TRTO = r(1)(1)
        Else
            TRTO = n
            If ConvertTo(vbBoolean,Application("RecordTexts")) Then
                ASPCTLResDB.VExecute "INSERT INTO MainTexts (CONTENT,LANGUAGE) VALUES ($c,$l)",1,0, n, lang
            End If
        End If
    End Function
    ' Translate
    Function ResourceText(n)
        ResourceText = TR(n)
    End Function
    
    Function LanguageIcon(lang)
        Dim r
        Set r = ASPCTLResDB.VExecute("SELECT CASE WHEN ICON ISNULL THEN 0 ELSE 1 END AS HASICON FROM Languages WHERE LANGUAGE=$l",1,1,NullConvertTo(vbString,lang))
        If r.Count > 0 Then
            If ConvertTo(vbBoolean,r(1)(1)) Then
                LanguageIcon = ASPCTLPath & "langicon.asp?lang=" & lang
                Exit Function
            End If
        End If
        LanguageIcon = SysImage("pixel")
    End Function
    
    ' Styling helper
    Function StyleAndCssString(cs,ss)
        Dim s
        s = ""
        If Not IsEmpty(cs) Then s = s & " class=""" & cs & """"
        If Not IsEmpty(ss) Then s = s & " style=""" & ss & """"
        If Len(s) > 0 then s = s & " "
        StyleAndCssString = s
    End Function
    ' Additional attributes helper
    Function RenderAttributes(attr)
        Dim s, I
        s = ""
        If IsObject(attr) Then
            If Not attr Is Nothing Then
                s = s & " "
                For I = 1 To attr.Count
                    s = s & attr.Key(I) & "=""" & attr(I) & """ "
                Next
            End If
        End If
        RenderAttributes = s
    End Function

    Function ASPCTL_InheritableSetting(vLocal,sName,vType)
        If Not IsEmpty(vLocal) Then
            ASPCTL_InheritableSetting = ConvertTo(vType,vLocal)
        ElseIf Not IsEmpty(Session(sName)) Then
            ASPCTL_InheritableSetting = ConvertTo(vType,Session(sName))
        ElseIf Not IsEmpty(Application(sName)) Then
            ASPCTL_InheritableSetting = ConvertTo(vType,Application(sName))
        Else
            ASPCTL_InheritableSetting = ConvertTo(vType,Empty)
        End If
    End Function

    Function ASPCTL_UsePostVarsForButtonValues
        ASPCTL_UsePostVarsForButtonValues = ASPCTL_InheritableSetting(UsePostVarsForButtonValues,"UsePostVarsForButtonValues",vbBoolean)
    End Function    
    Function ASPCTL_EnableSubmitShield
        ASPCTL_EnableSubmitShield = ASPCTL_InheritableSetting(EnableSubmitShield,"EnableSubmitShield",vbBoolean)
    End Function
    Function ASPCTL_EnableFullSubmitShield
        ASPCTL_EnableFullSubmitShield = ASPCTL_InheritableSetting(EnableFullSubmitShield,"EnableFullSubmitShield",vbBoolean)
    End Function
    Function ASPCTL_HideSubmitShieldMessage
        ASPCTL_HideSubmitShieldMessage = ASPCTL_InheritableSetting(HideSubmitShieldMessage,"HideSubmitShieldMessage",vbBoolean)
    End Function
    Function ASPCTL_EnableSavePosition
        ASPCTL_EnableSavePosition = ASPCTL_InheritableSetting(EnableSavePosition,"EnableSavePosition",vbBoolean)
    End Function
    Function ASPCTL_EnableClientValidation
        ASPCTL_EnableClientValidation = ASPCTL_InheritableSetting(EnableClientValidation,"EnableClientValidation",vbBoolean)
    End Function
    Function ASPCTL_AggressiveClientValidation
        ASPCTL_AggressiveClientValidation = ASPCTL_InheritableSetting(AggressiveClientValidation,"AggressiveClientValidation",vbBoolean)
    End Function
    
    ' Standard frequently used elements
    Dim ASPCTL_NumFormsRendered
    ASPCTL_NumFormsRendered = 0
    Dim ASPCTL_CurrentFormName
    Function CurrentFormName ' Some controls need to know the form in which they are placed while rendering
        If IsEmpty(ASPCTL_CurrentFormName) Then 
            CurrentFormName = "F0"
        Else
            CurrentFormName = ASPCTL_CurrentFormName
        End If
    End Function
    Sub SetCurrentFormName(v)
        ASPCTL_CurrentFormName = v
    End Sub
    
    ' If more then one form is used the controls need to be declared (created) in the context of the particular form
    ' if there is only one form as usual there is no need to use any of the form declaration routines.
    ' Note that if changes to form sensitive features are made during the processing you need to SetCurrentFormName to the 
    ' correct form while doing this! As multiple forms are extremely rare this feature is left a little raw.
    Dim ASPCTL_NumFormsDeclared
    ASPCTL_NumFormsDeclared = 0
    Function Begin_FormControls(fname)
        Dim theFormName
        If ConvertTo(vbString,fname) <> "" Then theFormName = fname Else theFormName = "F" & ASPCTL_NumFormsDeclared
        ASPCTL_CurrentFormName = theFormName
        Begin_FormControls = theFormName
    End Function
    Sub End_FormControls
        ASPCTL_NumFormsDeclared = ASPCTL_NumFormsDeclared + 1
    End Sub
    
    ' Render form(s)
    Sub Begin_PostBackForm(fname)
        Dim s, fh, theFormName
        s = ""
        fh = ""
        If ConvertTo(vbString,fname) <> "" Then theFormName = fname Else theFormName = "F" & ASPCTL_NumFormsRendered
        ASPCTL_CurrentFormName = theFormName
        If UseMultipartFormData Then
            s = " enctype=""multipart/form-data"""
        End If
        If IsObject(ClientScripts) Then
            If ASPCTL_EnableSavePosition Then
                ClientScripts.AddFormHandler theFormName, "ASPCTL_SaveSubmitPosition('" & theFormName & "')"
            End If
            If ASPCTL_EnableSubmitShield Or ASPCTL_EnableFullSubmitShield Then
                ClientScripts.AddFormHandler theFormName, "ASPCTL_SubmitShield('" & theFormName & "')"
            End If
            fh = ClientScripts.RenderFormHandlers(theFormName)
        End If
        If fh <> "" Then 
            s = s & " onsubmit=""" & fh & """"
        End If
        If fname <> "" Then
            Response.Write "<form method=""post"" action=""" & Self & """" & s & ">" & vbCrLf
        Else
            Response.Write "<form method=""post"" action=""" & Self & """ name=""" & theFormName & """" & s & ">" & vbCrLf
        End If
        If UseMultipartFormData Then
            Response.Write "<input type=""file"" name=""ASPCTL_PatchFileUpload"" style=""display:none"">"
        End If
    End Sub
    Sub End_PostBackForm
        If IsObject(PostVariables) Then PostVariables.Render
        If ASPCTL_EnableSavePosition Then
            Response.Write "<input type=""hidden"" name=""ASPCTL_SavedPosition"" value=""0,0""/>"
            Response.Write "<input type=""hidden"" name=""ASPCTL_PostBackFocus"" value=""""/>"
        End If
        Response.Write "</form>"
        ASPCTL_NumFormsRendered = ASPCTL_NumFormsRendered + 1
    End Sub
    
    ' This dummy object is serving as a pin for certain body features - such as events and others
    ' It should not be used as regular controls by the applications because it is reserved for internal framework use
    Set ASPCTLBodyObject = Create_CDummyControl("ASPCTLBodyObject")
    
    
    
    Sub Begin_Page(bodyAttributes)
        If Len(ASPRedirect) > 0 Then Exit Sub
        PerformPreRender
        Dim I, J, r
		If Not IsEmpty(ASPCTL_PageDocType) Then
			Response.Write ASPCTL_PageDocType
		Else
        %>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><%
		End If
        If PageXMLNamespaces.Count > 0 Then
            Response.Write "<html "
            For I = 1 To PageXMLNamespaces.Count
                Response.Write "xmlns:" & PageXMLNamespaces.Key(I) & "=""" & PageXMLNamespaces(I) & """ "
            Next
            Response.Write ">"
        Else 
            Response.Write "<html>"
        End If
        %>
        <head>
            <% If Len(ASPCTLHeadContent) > 0 Then
                Response.Write ASPCTLHeadContent
            End If %>
            <meta http-equiv="Content-Type" content="text/html; charset=<%= PageUIEncoding %>" />
            <meta http-equiv="Content-Language" content="<%= PageUILanguage %>" />
			<meta http-equiv="X-UA-Compatible" content="IE=edge" />
            <meta name="Keywords" content="<%= RenderPageKeywords %>" />
            <meta name="Description" content="<%= HTMLEncode2(PageDescription) %>" />
            <% RenderPageMetas %>
            <% RenderPageCustomMetas %>
            <% 
            If Len(PageStyleSheet) > 0 Then 
                If EmbeddedStyleSheet Then
                    %>
                    <style>
                        <%= ReadTextFile(Server.MapPath(PageStyleSheet),0) %>
                    </style>
                    <%
                Else
                %>
                <link rel="stylesheet" href="<%= PageStyleSheet %>" />
                <%
                End If
            End If
            For I = 1 To PageRels.Count
                Response.Write "<link "
                Set r = PageRels(I)
                For J = 1 To r.Count
                    Response.Write r.Key(J) & "=""" & HTMLEncode2(r(J)) & """ "
                Next
                Response.Write "/>" & vbCrLf
            Next
            %>
            <% ClientScripts.Render %>
            <title><%= HTMLEncode2(PageTitle) %></title>
        </head>
        <% If bodyAttributes <> "" Then %>
            <body <%= bodyAttributes %> <% ClientScripts.RenderBodyEvents %> >
        <% Else %>
            <body topmargin="0" leftmargin="0" <% ClientScripts.RenderBodyEvents %> >
        <% End If
    End Sub
    Sub End_Page
        If Len(ASPRedirect) > 0 Then 
            Response.Clear
            Response.Redirect ASPRedirect
            Exit Sub
        End If
        If ASPCTL_ShowTimeTaken Then Response.Write "<div>The page was generated in " & ASPCTL_TIMER.SystemTicks - ASPCTL_START_TICKS & "ms</div>"
        Response.Write "</body></html>"
    End Sub
    
    Dim ASPCTLSkinners

    Function SkinControlWith(ctl,skinnerName)
        Dim skinner
        If Not IsObject(ASPCTLSkinners(skinnerName)) Then
            On Error Resume Next
            Err.Clear
            Set skinner = GetRef(skinnerName)    
            If Err.Number <> 0 Then
                SkinControlWith = False
                Err.Clear
                Exit Function
            End If
            On Error Goto 0
            Err.Clear
            Set ASPCTLSkinners(skinnerName) = skinner
        Else
            Set skinner = ASPCTLSkinners(skinnerName)
        End If
        Call skinner(ctl)
        SkinControlWith = True
    End Function
    Function SkinControl(ctl)
        SkinControl = False
        If Not IsObject(ASPCTLSkinners) Then
            Set ASPCTLSkinners = CreateCollection    
        End If
        Dim skinnerName
        skinnerName = "Skin_" & ctl.ClassType
        If SkinControlWith(ctl,skinnerName) Then SkinControl = True
        On Error Resume Next
        Err.Clear
        If Not IsEmpty(ctl.SkinId) Then  skinnerName = skinnerName & "_" & ctl.SkinId
        If Err.Number <> 0 Then
            Response.Write "aspctl.asp::SkinControl - The control " & ctl.ClassType & " does not support skins."
        End If
        On Error Goto 0
        If SkinControlWith(ctl,skinnerName) Then SkinControl = True
        Err.Clear
    End Function
    
    Sub ApplySkin
        Dim I
        For I = 1 To Controls.Count
            SkinControl Controls(I)
        Next
        For I = 1 To Validators.Count
            SkinControl Validators(I)
        Next
        For I = 1 To UserControls.Count
            SkinControl UserControls(I)
        Next
    End Sub    
    
' Partial request routines
    Function ASPCTL_AsyncRequestsEnabled
        ASPCTL_AsyncRequestsEnabled = ASPCTL_InheritableSetting(AsyncRequestsEnabled,"AsyncRequestsEnabled",vbBoolean)
    End Function    
    Function ASPCTL_AsyncRequestsDebug
        ASPCTL_AsyncRequestsDebug = ASPCTL_InheritableSetting(AsyncRequestsDebug,"AsyncRequestsDebug",vbBoolean)
    End Function    

    ' Create the control list
    Dim ASPCTLControlList
    Sub ASPCTLConfigurePartial
        Dim I, o
        If Len(ASPCTLPartial) <> 0 Then
            Set ASPCTLControlList = CreateDictionary
            If LCase(Left(ASPCTLPartial,4)) = "form" Then
                Set o = ASPALL(ASPCTL_ControlList)
                For I = 1 To o.Count
                    ASPCTLControlList(o(I)) = True
                Next
            End If
        End If
    End Sub
    Function IsPartialRequest
        IsPartialRequest = False
        If Len(ASPCTLPartial) <> 0 Then IsPartialRequest = True
    End Function
    ASPCTLConfigurePartial
    
    Sub RegisterForPartialRender(ctl)
        If IsObject(ASPCTLControlList) Then
            ASPCTLControlList(ctl.Name) = True
        End If
    End Sub
    Sub UnRegisterForPartialRender(ctl)
        If IsObject(ASPCTLControlList) Then
            ASPCTLControlList.Remove ctl.Name
        End If
    End Sub
    Sub OvertakePartialRender(ctl)
        If IsObject(ASPCTLControlList) Then
            ASPCTLControlList.Clear
            ASPCTLControlList(ctl.Name) = True
        End If
    End Sub
    Function IsRegisteredForPartialRender(ctl)
        IsRegisteredForPartialRender = ASPCTLControlList(ctl.Name)
    End Function
    
    Sub RenderPartialUserControls
        Dim I, oCtl, scode
        For I = 1 To ASPCTLControlList.Count
            If ASPCTLControlList(I) Then
                If IsObject(UserControls(ASPCTLControlList.Key(I))) Then
                    Set oCtl = UserControls(ASPCTLControlList.Key(I))
                    scode = ClientScripts.GetControlEventHandlersCode(oCtl,"$asyncupdate")
                    %><update type="innerHTML" id="<%= UserControls(ASPCTLControlList.Key(I)).ClientId %>" <%= IfThenElse(IsEmpty(scode),"","code=""" & scode & """") %>><![CDATA[<%
                    UserControls(ASPCTLControlList.Key(I)).RenderPartial
                    %>]]></update><%
                    If ImplementsProtocol(oCtl, "PPartialRenderAddOn") Then
                        UserControls(ASPCTLControlList.Key(I)).RenderPartialAddOn ' Renders additional elements in the partial response.
                    End If
                End If
            End If
        Next
    End Sub
    
    ' In future updates this may change and call other routines for different kinds
    ' of partial requests
    Sub Begin_PartialRender(fname)
        Dim theFormName
        If ConvertTo(vbString,fname) <> "" Then theFormName = fname Else theFormName = "F" & ASPCTL_NumFormsRendered
        ASPCTL_CurrentFormName = theFormName
        PerformPreRender
        ClientScripts.RenderPartial
        Response.ContentType = "text/xml"
        %><?xml version="1.0" encoding="<%= PageUIEncoding %>"?><%
        If Len(ASPRedirect) > 0 Then
            %><aspctlpartial redirect="<%= ASPRedirect %>"><%
        Else
            %><aspctlpartial><%
        End If
    End Sub
    Sub End_PartialRender
        ' To allow limited state changes during rendering (not recommended) we save the state last
        If IsObject(PostVariables) Then PostVariables.RenderPartial
        %></aspctlpartial><%
        ASPCTL_NumFormsRendered = ASPCTL_NumFormsRendered + 1
    End Sub
    
    Sub PartialUpdateValueEx(ctlName,ctlValue,code)
        If Len(ASPCTLPartial) = 0 Then Exit Sub
        %><update type="value" name="<%= ctlName %>" <%= IfThenElse(IsEmpty(code),"","code=""" & code & """") %> ><![CDATA[<%= ctlValue %>]]></update><%
    End Sub
    Sub PartialUpdateValue(ctlName,ctlValue)
        PartialUpdateValueEx ctlName, ctlValue, Empty
    End Sub
    
    Sub PartialUpdateUpdateEx(updType,ClientId,Content,code)
        If Len(ASPCTLPartial) = 0 Then Exit Sub
        %><update type="<%= updType %>" id="<%= ClientId %>" <%= IfThenElse(IsEmpty(code),"","code=""" & code & """") %>><![CDATA[<%= Content %>]]></update><%
    End Sub
    Sub PartialUpdateUpdate(updType,ClientId,Content)
        PartialUpdateUpdateEx updType, ClientId, Content, Empty
    End Sub
    
    Sub PartialUpdateExec(code)
        If Len(ASPCTLPartial) = 0 Then Exit Sub
        %><exec code="<%= code %>" /><%
    End Sub
    
    ' Standard master page processing - put it in the end
    
    MasterCancelProcessing = False
    Public Sub StandardMasterPageProcessing(outpage)
        If Not MasterCancelProcessing Then
            If ProcessPage Then 
                If IsPartialRequest Then
                    Begin_PartialRender(Empty)
                    RenderPartialUserControls
                    End_PartialRender
                Else
                    RenderMaster
                End If
            ElseIf Len(ASPRedirect) > 0 Then
                If IsPartialRequest Then
                    Begin_PartialRender(Empty)
                    ' Skips any content because the redirect makes them redundand
                    End_PartialRender
                Else
                    Response.Redirect ASPREdirect
                End If
            Else
                ' Return nothing
            End If
        Else
            If Len(ASPRedirect) = 0 Then ASPRedirect = outpage
            If IsPartialRequest Then
                Begin_PartialRender(Empty)
                ' Skips any content because the redirect makes them redundand
                End_PartialRender
            Else
                Response.Redirect ASPRedirect
            End If
        End If
    End Sub
    
    ' TRACING AND DEBUGGING ==============    
    Sub DumpRequestCol(col)
        Dim I,J
        %>
        <tr>
            <th><font color="#FFFF80">Name</font></th>
            <th><font color="#FFFF80">VN</font></th>
            <th><font color="#FFFF80">Value</font></th>
        </tr>
        <%
        For I = 1 To col.Count
            If Not col.Key(I) = ASPCTL_PostVarsFieldName Then
                %>
                <tr bgcolor="#FFFFFF">
                    <td rowspan="<%= col(I).Count %>">
                        <%= col.Key(I) %>
                    </td>
                    <td>1</td>
                    <td><%= Server.HTMLEncode(col(I)(1)) %></td>
                </tr>
                <%
                For J = 2 To col(I).Count
                %>
                    <tr bgcolor="#FFFFFF">
                        <td><%= J %></td>
                        <td><%= Server.HTMLEncode(col(I)(J)) %></td>
                    </tr>
                <%
                Next
            End If
        Next 
    End Sub
    Sub DumpFileInfo(f)
        %>
        File name:<b><%= f.FileName %></b><br>
        Raw file name:<b><%= f.RawFileName %></b><br>
        Content type:<b><%= f.ContentType %></b><br>
        File name extension:<b><%= f.FileNameExtension %></b><br>
        Content length:<b><%= f.ContentLength %></b>
        <%
    End Sub
    Sub DumpControls(Coll,Capt)
        %>
        <table bgcolor="#404080" cellspacing="1" width="100%">
            <tr>
                <th colspan="3"><font color="#FFFFFF"><%= Capt %></font></th>
            </tr>
            <tr>
                <th><font color="#FFFF80">Name</font></th>
                <th><font color="#FFFF80">ClassType</font></th>
                <th><font color="#FFFF80">ClientId</font></th>
            </tr>
        <%
        Dim I
        On Error Resume Next
        For I = 1 To Coll.Count
            %>
            <tr bgcolor="#FFFFFF">
                <td valign="top">
                    <%= Coll(I).Name %>
                </td>
                <td valign="top">
                    <%= Coll(I).ClassType %>
                </td>
                <td>
                    <%= Coll(I).ClientId %>
               </td>
            </tr>
            <%
        Next
        Err.Clear
        %></table><%
    End Sub
    Sub DumpValidators()
        %>
        <table bgcolor="#404080" cellspacing="1" width="100%">
            <tr>
                <th colspan="4"><font color="#FFFFFF">Validators</font></th>
            </tr>
            <tr>
                <th><font color="#FFFF80">Name</font></th>
                <th><font color="#FFFF80">Group</font></th>
                <th><font color="#FFFF80">Text</font></th>
                <th><font color="#FFFF80">Disabled</font></th>
                <th><font color="#FFFF80">Controls validated</font></th>
            </tr>
        <%
        Dim I,J
        On Error Resume Next
        For I = 1 To Validators.Count
            %>
            <tr bgcolor="#FFFFFF">
                <td valign="top">
                    <%= Validators(I).Name %>
                </td>
                <td valign="top">
                    <%= Validators(I).Group %>
                </td>
                <td>
                    <%= Validators(I).Text %>
                </td>
                <td>
                    <%= Validators(I).Disabled %>
                </td>
                <td>
                    <% For J = 1 To Validators(I).ValidateControls.Count %>
                    <%= Validators(I).ValidateControls(J).Name %>
                    <% Next %>
                </td>
            </tr>
            <%
        Next
        Err.Clear
        %></table><%
    End Sub
    
    Sub DumpRequest
        
        %>
        <table bgcolor="#404080" cellspacing="1" width="100%">
            <tr>
                <th colspan="3"><font color="#FFFFFF">ASPGET</font></th>
            </tr>
            <% DumpRequestCol ASPGET %>
            
            <tr>
                <th colspan="3"><font color="#FFFFFF">ASPPOST</font></th>
            </tr>
            <% DumpRequestCol ASPPOST %>
            
            <tr>
                <th colspan="3"><font color="#FFFFFF">ASPVARS</font></th>
            </tr>
            <% DumpRequestCol ASPVARS %>
            
            <tr>
                <th colspan="3"><font color="#FFFFFF">ASPFILES</font></th>
            </tr>
            <%
            Dim I, J
                For I = 1 To ASPFILES.Count
                    %>
                    <tr bgcolor="#FFFFFF">
                        <td valign="top" rowspan="<%= ASPFILES(I).Count %>">
                            <%= ASPFILES.Key(I) %>
                        </td>
                        <td valign="top">1</td>
                        <td>
                            <% 
                            DumpFileInfo(ASPFILES(I)(1)) 
                        %></td>
                    </tr>
                    <%
                    For J = 2 To ASPFILES(I).Count
                    %>
                        <tr bgcolor="#FFFFFF">
                            <td><%= J %></td>
                            <td><% DumpFileInfo(ASPFILES(I)(J)) %></td>
                        </tr>
                    <%
                    Next
                Next 
            %>
        </table>
        <%    
        DumpControls Controls, "Controls on the page"
        DumpControls UserControls, "User controls on the page"
        DumpValidators
        If IsObject(PostVariables) Then PostVariables.Dump
    End Sub
    Sub DumpTS(tsRoot)
        Dim ts, I, J
        On Error Resume Next
        Set ts = tsRoot
        %>
        <ul>(<%= td.Info.Class %>)
            <%
            For I = 1 To ts.Count
                If IsObject(ts(I)) Then
                    If ts(I).Info.Type Then ' Section
                        %>
                        <li><b><u><%= ts.Key(I) %></u></b></li><%
                            DumpTS ts(I)
                    Else
                        %><li><%
                        For J = 1 To ts(I).Count
                            %><%= ts.Key(I) %>[<%= ts(I).Key(J) %>]=<%= ts(I)(J) %><br/><%
                        Next
                        %>
                        </li>
                        <%
                    End If
                Else
                    %><li><%= ts.Key(I) %>=<%= ts(I) %></li><%
                End If
            Next
            %>
        </ul>
        <%
    End Sub

    ASPCTL_InitSupportedLanguages
%>
<!-- #include file="clientscripts.asp" -->
<!-- #include file="basectls.asp" -->
<!-- #include file="aspctl-langctls.asp" -->
<%
    Dim ASPCTL_BasicInitializationDone
    ASPCTL_BasicInitializationDone = True

    If ASPCTL_EnableFullSubmitShield Then
        s = ""
        s = s & "function ASPCTL_SubmitShield(fname) {" & vbCrLf 
        If ASPCTL_HideSubmitShieldMessage Then
            s = s & "  var frm = document.forms[fname]; frm.onsubmit = function() { return false; } }" & vbCrLf
        Else
            s = s & "  var frm = document.forms[fname]; frm.onsubmit = function() { alert('" & JSEscape(TR("The form is already submitted!")) & "'); return false; } }" & vbCrLf
        End If
        ClientScripts.Block("ASPCTL_SubmitShield") = s
    ElseIf ASPCTL_EnableSubmitShield Then
        s = ""
        s = s & "function ASPCTL_SubmitShield(fname) {" & vbCrLf 
        s = s & "  var frm = document.forms[fname]; for (var i=0;i<frm.elements.length;i++) { if (frm.elements[i].type == 'submit' || frm.elements[i].type == 'image') frm.elements[i].style.visibility='hidden'; } }" & vbCrLf
        ClientScripts.Block("ASPCTL_SubmitShield") = s
    End If
    ' window.scrollTo(x,y);
    If ASPCTL_EnableSavePosition Then
        ClientScripts.EnableStaticEventsLibrary ' Required for scroll position read
        s = ""
        s = s & "function ASPCTL_SaveSubmitPosition(fname) {" & vbCrLf
        s = s & "  var frm = document.forms[fname]; frm.elements['ASPCTL_SavedPosition'].value = ASPCTL_BodyScrollPosition(); " & vbCrLf
        s = s & "}" & vbCrLf
        ClientScripts.Block("ASPCTL_SavePosition") = s
        If ASPALL("ASPCTL_SavedPosition").Count > 0 Then
            s = ""
            s = s & "function ASPCTL_RestoreSubmitPosition() { window.scrollTo(" & ASPALL("ASPCTL_SavedPosition") & ");" & vbCrLf
            If Len(ASPALL("ASPCTL_PostBackFocus")) > 0 Then
                s = s & "  if (document.getElementById) { if (document.getElementById('" & ASPALL("ASPCTL_PostBackFocus") & "')) document.getElementById('" & ASPALL("ASPCTL_PostBackFocus") & "').focus(); }" & vbCrLf
                s = s & "  else if (document.all) { if (document.all('" & ASPALL("ASPCTL_PostBackFocus") & "')) document.all('" & ASPALL("ASPCTL_PostBackFocus") & "').focus(); }" & vbCrLf
            End If
            s = s & "}" & vbCrLf
            ClientScripts.Block("ASPCTL_RestoreSubmitPosition") = s
            ClientScripts.RegisterInitializer "ASPCTL_RestoreSubmitPosition", "ASPCTL_RestoreSubmitPosition()"
        End If
    End If
%>
