<%
    ' Package:  UserAPI 
    ' Version:  2011-04-11
    ' File:     userapi-email.asp
    ' Description:
    '   Defines CMail class which encapsulates mail sending with templates

    Class CMail
        Public  Attachments
        Private SenderProc
        Public  Recipient, Sender
        Public  RecipientName, SenderName
        Public  Subject, Body
        Public  ErrorMessage
        Public  Trace, TraceLog
        Public  NotifyPermission ' If non-empty it is requied by ToUser, It returns false if the permission is not granted
        Public  PreferredLanguage
        
        Public SmtpServer, SmtpPort, SmtpLogin, SmtpPass
        
        Sub Class_Initialize
            Set Attachments = CreateList
            Set SenderProc = GetRef("SendMail_" & cMailMode)
            SmtpServer = ConvertTo(vbString,Configuration("SMTP_SERVER"))
            SmtpPort = ConvertTo(vbLong, Configuration("SMTP_PORT"))
            SmtpLogin = ConvertTo(vbString, Configuration("SMTP_LOGIN"))
            SmtpPass = ConvertTo(vbString, Configuration("SMTP_PASS"))
            PreferredLanguage = PageUILanguage
        End Sub
        
        ' Server
        
        
        'Attachments
        
        Public Sub Attach(path,contentType,inline)
            Dim o
            Set o = New CMailAttachment
            o.FullPath = ConvertTo(vbString,path)
            o.ContentType = ConvertTo(vbString,contentType)
            o.inline = inline
            o.AttachId = Empty
            Attachments.Add "", o
        End Sub
        ' Helpers
        Public Function AttachFile(sid)
            Dim r, p
            AttachFile = False
            p = MapPath(FileStore_Path)
            If Right(p,1) <> "\" Then p = p & "\"
            Set r = Database.DB.VExecute("SELECT * FROM FILE WHERE SID=$SID AND LANGUAGE=$LANGUAGE",1,1,NullConvertTo(vbLong,sid),PageUILanguage)
            If r.Count > 0 Then
                Attach p & ConvertTo(vbString, r(1)("PATH")), r(1)("CONTENT_TYPE"), False
                AttachFile = True
            End If
        End Function
        Public Function AttachImage(sid)
            Dim r, p
            AttachImage = False
            p = MapPath(ImageStore_Path)
            If Right(p,1) <> "\" Then p = p & "\"
            Set r = Database.DB.VExecute("SELECT * FROM IMAGE WHERE SID=$SID AND LANGUAGE=$LANGUAGE",1,1,NullConvertTo(vbLong,sid),PageUILanguage)
            If r.Count > 0 Then
                Attach p & ConvertTo(vbString, r(1)("PATH")), r(1)("CONTENT_TYPE"), False
                AttachImage = True
            End If
        End Function
        
        Public Sub RemoveAttachent(sid)
            Attchments.Remove "A" & sid
        End Sub
        Public Sub ClearAttachments
            Attachments.Clear
        End Sub
        
        ' Addresses
        Sub SetAdminSender(sname)
            Sender = ConvertTo(vbString,Configuration("SMTP_FROM_EMAIL"))
            SenderName = sname
        End Sub
        Function ToUser(uid)
            Dim u
            Set u = New CUser
            Set u.Database = Database
            If u.Load(uid) Then
                If Len(NotifyPermission) Then
                    If Not u.PermitNotification(NotifyPermission) Then
                        Recipient = Empty
                        RecipientName = Empty
                        ToUser = False
                    End If
                End If
                Recipient = u.Email
                RecipientName = u.Login
                If Len(u.Language) > 0 Then PreferredLanguage = u.Language
                ToUser = True
            Else
                Recipient = Empty
                RecipientName = Empty
                ToUser = False
            End If
        End Function
        
        
        Private Function CheckMailSettings
            Dim result
            ErrorMessage = Empty
            result = True
            If Len(Sender) = 0 Then
                ErrorMessage = ErrorMessage & TR("Mail sender is not specified.")
                result = False
            End If
            If Len(Recipient) = 0 Then
                ErrorMessage = ErrorMessage & TR("Mail recipient is not specified.")
                result = False
            End If
            If Len(Subject) = 0 Then
                ErrorMessage = ErrorMessage & TR("Mail subject is not specified.")
                result = False
            End If
            If Len(Body) = 0 Then
                ErrorMessage = ErrorMessage & TR("Empty mail body.")
                result = False
            End If
            CheckMailSettings = result
        End Function
        
        Private Function LoadTemplate(sidOrCode,Lang)
            Dim r, l
            If Len(Lang) = 0 Then l = PreferredLanguage
            Set r = Database.DB.VExecute("SELECT * FROM MAIL_TEMPLATE WHERE CODE=$CODE OR SID=$SID AND LANGUAGE=$LANGUAGE",1,1,_
                                            NullConvertTo(vbString, sidOrCode), NullConvertTo(vbLong, sidOrCode), l)
            If r.Count > 0 Then
                Subject = ConvertTo(vbString, r(1)("CAPTION"))
                Body = ConvertTo(vbString, r(1)("BODY"))
                LoadTemplate = True
            Else
                Subject = Empty
                Body = Empty
                LoadTemplate = False
            End If                                            
        End Function
        Public Function Load(sidOrCode,Lang,params)
            Dim p
            Load = False
            If IsNotObject(params) Then
                Set p = CreateDictionary
            Else
                Set p = params
            End If
            p("SenderAddress") = ConvertTo(vbString,Sender)
            p("SenderName") = ConvertTo(vbString,SenderName)
            p("SiteName") = ConvertTo(vbString,cSiteName)
            p("SiteURL") = ConvertTo(vbString,cSiteURL)
            p("Recipient") = ConvertTo(vbString,Recipient)
            p("RecipientName") = ConvertTo(vbString,RecipientName)
            If LoadTemplate(sidOrCode,Lang) Then
                Subject = StringUtilities.SCprintf(Subject,p)
                Body = "<html><body>" & BBCodeNoImages(Body) & "</body></html>"
                Body = StringUtilities.SCprintf(Body,p)
                Load = True
            End If
        End Function
        
        Public Function Send
            Send = False
            If Not CheckMailSettings Then Exit Function
            Send = SenderProc(Me)
        End Function
        
    End Class
    Class CMailAttachment
        Public FullPath,ContentType,Inline
        Public AttachId ' Used only for inline attachments
    End Class
    
    
    Function SendMail_JMail(m)
        Dim Mail, I
        
        If m.Trace Then m.TraceLog = m.TraceLog & "Tracing on;"
        
        Set Mail = Server.CreateObject("JMail.Message")
        ' Mail.EnableCharsetTranslation = False
        If m.Trace Then Mail.Logging = True
        Mail.Charset = "utf-8"
        Mail.ContentType="text/html; charset=""utf-8"""
        Mail.Silent = True
        
        If Not IsNull(NullConvertTo(vbString, m.SenderName)) Then Mail.FromName = ConvertTo(vbString, m.SenderName)
        Mail.From = ConvertTo(vbString,m.Sender)
        Mail.AddRecipient ConvertTo(vbString,m.Recipient), IfEmpty(m.RecipientName,"")
        If cMailCopyToAdmin Then
            Mail.AddRecipientBCC ConvertTo(vbString,Configuration("SMTP_FROM_EMAIL"))
        End If
        
        Mail.Subject = ConvertTo(vbString,m.Subject)
        Mail.Body = ConvertTo(vbString,m.Body)
        
        If m.Attachments.Count > 0 Then
            For I = 1 To m.Attachments.Count
                Mail.AddAttachment m.Attachments(I).FullPath, False, m.Attachments(I).ContentType
            Next
        End If
        
        If m.Trace Then m.TraceLog = m.TraceLog & "Sender: " & Mail.From & " To: " & m.Recipient & " Subject: " & m.Subject
        
        If Len(m.SmtpLogin) > 0 Then
            Mail.MailServerUserName = m.SmtpLogin
            If Len(m.SmtpPass) > 0 Then
                Mail.MailServerPassWord = m.SmtpPass
            End If
        End If
        
        If m.Trace Then m.TraceLog = m.TraceLog & "Server: " & m.SmtpServer
        
        If Not Mail.Send(m.SmtpServer) Then
            m.ErrorMessage = m.ErrorMessage & "Send mail failed!" & Mail.ErrorSource & " " & Mail.ErrorMessage
            SendMail_JMail = False
        Else
            SendMail_JMail = True
        End If
        
        If m.Trace Then m.TraceLog = m.TraceLog & Mail.Log
        
    End Function

%>