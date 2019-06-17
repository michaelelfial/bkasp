<%
    ' Package:  UserAPI 
    ' Version:  2011-04-10
    ' File:     userapi-util.asp
    ' Description:
    '   Various utilities. Do not add application specific utilities here!
    
    ' Minimal implementation for validation errors and other messages.
    ' Keep this global variable - it is used by many user controls.
    Dim GlobalInfoMessage ' Put a string in this variable if something must be confirmed to the user

    Sub RenderValidatorMessages
        Dim vm, I
        Set vm = GetValidatorMessages(Empty) ' Get the messages from all the validators that have been activated and failed no matter to which group they belong
        If vm.Count > 0 Then
            %>
            <table width="100%">
                <% For I = 1 To vm.Count %>
                <tr>
                    <td class="messageLight"><%= HTMLEncode(vm(I)) %></td>    
                </tr>
                <% Next %>
            </table>
            <%
        End If
    End Sub
    Sub LanguageValueIndicators(ctl)
        Dim I, coll
        Set coll = ctl.Values
        For I = 1 To coll.Count
            If coll(I) <> "" Then
                %><img src="<%= LanguageIcon(coll.Key(I)) %>" alt="<%= coll.Key(I) %>" /><%
            End If
        Next
    End Sub

    
    ' SQL construction (widely used by the UserAPI library)    
    Function CreateSQLParameterList(lst)
        Dim I, arr, s
        s = ""
        If IsObject(lst) Then ' A collection keyed with the field names
            For I = 1 To lst.Count
                If Len(s) > 0 Then s = s & ","
                s = s & lst.Key(I)
            Next
        Else ' Comma separated list of field names
            arr = Split(lst,",")
            For I = LBound(arr) To UBound(arr)
                If Len(s) > 0 Then s = s & ","
                s = s & arr(I)
            Next
        End If
        CreateSQLParameterList = s
    End Function
    Function CreateSQLValuesList(lst)
        Dim I, arr, s
        s = ""
        If IsObject(lst) Then ' A collection keyed with the field names
            For I = 1 To lst.Count
                If Len(s) > 0 Then s = s & ","
                s = s & "$" & lst.Key(I)
            Next
        Else ' Comma separated list of field names
            arr = Split(lst,",")
            For I = LBound(arr) To UBound(arr)
                If Len(s) > 0 Then s = s & ","
                s = s & "$" & arr(I)
            Next
        End If
        CreateSQLValuesList = s
    End Function
    Function CreateSQLInList(lst)
        Dim I, vt, s, v
        s = ""
        If IsObject(lst) Then ' A collection keyed with the field names
            For I = 1 To lst.Count
                If Len(s) > 0 Then s = s & ","
                v = lst(I)
                vt = VarType(v)
                If vt = vbInteger Or vt = vbLong Then
                    s = s & StringUtilities.Sprintf("%d",v)
                ElseIf vt = vbSingle Or vt = vbDouble Or vt = vbDate Then
                    s = s & StringUtilities.Sprintf("%M",v)
                ElseIf vt = vbString Then
                    s = s & StringUtilities.Sprintf("%q",v)
                ElseIf vt = vtNull Then
                    s = s & "NULL"
                End If
            Next
        Else ' Comma separated list of values
            s = lst
        End If
        CreateSQLInList = s
    End Function
    Function CreateSQLAssignList(lst)
        Dim I, arr, s
        s = ""
        If IsObject(lst) Then ' A collection keyed with the field names
            For I = 1 To lst.Count
                If Len(s) > 0 Then s = s & ","
                s = s & lst.Key(I) & "=$" & lst.Key(I)
            Next
        Else ' Comma separated list of field names
            arr = Split(lst,",")
            For I = LBound(arr) To UBound(arr)
                If Len(s) > 0 Then s = s & ","
                s = s & arr(I) & "=$" & arr(I)
            Next
        End If
        CreateSQLAssignList = s
    End Function
    
    ' Common formatting
    Function DoubleAsPriceString(x)
        Dim d
        d = NullConvertTo(vbDouble, x)
        If IsNull(d) Then
            DoubleAsPriceString = ""
        Else
            DoubleAsPriceString = Trim(StringUtilities.Sprintf("%10.2f",d))
        End If
    End Function
    Private Function FileSizeString(size)
        If size < 0 Then
            FileSizeString = "big!"
        ElseIf size <= 999 Then
            FileSizeString = StringUtilities.Sprintf("%dB",size)
        ElseIf size >= 1000 And size < 1000000 Then
            FileSizeString = StringUtilities.Sprintf("%8.1fKB",CDbl(size) / 1024)
        ElseIf size >= 1000000 and size < 1000000000 Then
            FileSizeString = StringUtilities.Sprintf("%8.1fMB",CDbl(size) / (1024 * 1024))
        Else
            FileSizeString = StringUtilities.Sprintf("%8.1fGB",CDbl(size) / (1024 * 1024 * 1024))
        End If
    End Function
    Function FormatDouble(x,dp)
        Dim d
        d = NullConvertTo(vbDouble, x)
        If IsNull(d) Then
            FormatDouble = ""
        Else
            FormatDouble = Trim(StringUtilities.Sprintf("%16." & dp & "f",d))
        End If
    End Function
    Function GetFileExt(FileName)
        Dim n
        n = InStrRev(FileName,".")
        If n > 0 Then
            GetFileExt = Mid(FileName,n + 1)
        Else
            GetFileExt = ""
        End If
    End Function
    
    ' Image operations
    Function ResizeKeepingAspectRatio(wimg, toWidth, toHeight, bIfBigger)
        Dim w, h
        Dim ih, iw
        Dim dw, dh
        ResizeKeepingAspectRatio = False
        If wimg.ImageCount < 1 Then Exit Function
        iw = ConvertTo(vbLong, toWidth)
        ih = ConvertTo(vbLong, toHeight)
        If iw > 0 And ih > 0 Then
            ' Fit it into that rectangle
            dw = ConvertTo(vbDouble,wimg.Width) / ConvertTo(vbDouble,iw)
            dh = ConvertTo(vbDouble,wimg.Height) / ConvertTo(vbDouble,ih)
            If Not (bIfBigger And dw < 1 And dh < 1) Then
                If dw > dh Then
                    ' By width
                    w = iw
                    h = (iw * wimg.Height) / wimg.Width
                    wimg.TransResizeWidth = w
                    wimg.TransResizeHeight = h
                    wimg.ApplyTransform
                    ResizeKeepingAspectRatio = True
                Else
                    h = ih
                    w = (ih * wimg.Width) / wimg.Height
                    wimg.TransResizeWidth = w
                    wimg.TransResizeHeight = h
                    wimg.ApplyTransform
                    ResizeKeepingAspectRatio = True
                End If
            Else
                ResizeKeepingAspectRatio = True
            End If
        ElseIf iw > 0 Then
            ' By width
            dw = ConvertTo(vbDouble,wimg.Width) / ConvertTo(vbDouble,iw)
            If Not (bIfBigger And dw < 1) Then
                w = iw
                h = (iw * wimg.Height) / wimg.Width
                wimg.TransResizeWidth = w
                wimg.TransResizeHeight = h
                wimg.ApplyTransform
                ResizeKeepingAspectRatio = True
            Else
                ResizeKeepingAspectRatio = True
            End If
        ElseIf ih > 0 Then
            dh = ConvertTo(vbDouble,wimg.Height) / ConvertTo(vbDouble,ih)
            If Not (bIfBigger And dh < 1) Then
                h = ih
                w = (ih * wimg.Width) / wimg.Height
                wimg.TransResizeWidth = w
                wimg.TransResizeHeight = h
                wimg.ApplyTransform
                ResizeKeepingAspectRatio = True
            Else
                ResizeKeepingAspectRatio = True
            End If
        End If
    End Function
    
    ' Simple standard text renderers
    Sub RenderStaticTextsEx(table, code, bRandom, bFull, cattype)
        Dim r, I, sct
        If Len(cattype) > 0 Then 
            sct = " CATEGORY_TYPE='" & cattype & "' "
        Else
            sct = " 1=1 "
        End If
        If bRandom Then
            Set r = Database.DB.VExecute("SELECT * FROM " & table & " WHERE CODE LIKE $CODE AND LANGUAGE=$LANGUAGE AND " & sct & " ORDER BY random() LIMIT 1",1,1,NullLikeString(code,False,True),PageUILanguage)
        Else
            Set r = Database.DB.VExecute("SELECT * FROM " & table & " WHERE CODE LIKE $CODE AND LANGUAGE=$LANGUAGE AND " & sct,1,0,NullLikeString(code,False,True),PageUILanguage)
        End If
        If r.Count > 0 Then
            For I = 1 To r.Count
                If bFull Then
                    %>
                    <h4><%= HTMLEncode(r(I)("CAPTION")) %></h4>
                    <%
                    RenderBBText r(I)("BODY"), PageUILanguage
                    Response.Write "<br/>"
                Else
                    %>
                    <h4><%= HTMLEncode(r(I)("NAME")) %></h4>
                    <%
                    If ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then
                        %><img src="<%= VirtPath("/image.asp") & "?image=" & ConvertTo(vbLong, r(I)("IMAGE_SID")) %>" alt="" align="right" /><%
                    End If
                    Response.Write BBCodeNoImages(r(I)("BODY"))
                    Response.Write "<br/>"
                End If
                If IsAdmin Then
                    %>
                    <br/><a href="<%= VirtPath("/cp/help.asp") & "?code=" & r(I)("CODE") %>"><%= TR("Edit text") & ": " & code %></a>
                    <%
                End If
            Next
        End If
        If IsAdmin And (bRandom Or r.Count = 0) Then
            %>
            <br/><a href="<%= VirtPath("/cp/help.asp") & "?code=" & code %>"><%= TR("Create text") & ": " & code %></a>
            <%
        End If
    End Sub
    Sub RenderStaticTexts(table, code, bRandom, bFull)
        RenderStaticTextsEx table, code, bRandom, bFull, cattype
    End Sub
    Sub RenderStaticTextById(table, tid, Lang, bFull)
        Dim r
        Set r = Database.DB.VExecute("SELECT * FROM " & table & " WHERE SID=$ID AND LANGUAGE=$LANGUAGE",1,1,NullConvertTo(vbLong, tid),Lang)
        If r.Count > 0 Then
            RenderStaticTexts table, ConvertTo(vbString,r(1)("CODE")), False, bFull
        End If
    End Sub
    
    ' BBTexts rendering

    Class HImageParams
        Public ObjectSID
        Public Language
        Public WidthMax ' Images wider than this will be shrunk
        Public WidthAlign ' Images under this width are aligned automatically
        Public YouTubeWidth
        Public MaxVideoSize
    End Class
    
    ' BBCodeEx2(texts(I)("CONTENT"),VirtPath("/textimage.asp") & "?text=" & texts(I)("ID") & "&image=",texts(I)("ID"),"TextsBBCodeImageCallBack",ObjectCallback)
    Function TextImageCallBackDefault(imgParams, imgserver, imgTag)
        Dim r, capt, imgWidth
        
        Set r = Database.DB.VExecute("SELECT I.* FROM IMAGE I WHERE I.SID=$SID AND I.LANGUAGE=$LANGUAGE AND " & SQLReadRightsTable("I"), 1, 1, _
                                      NullConvertTo(vbString,imgTag), imgParams.Language)
                                      
        If r.Count <> 0 Then
            If ConvertTo(vbLong, r(1)("WIDTH")) > imgParams.WidthMax Then imgWidth = imgParams.WidthMax Else imgWidth = ConvertTo(vbLong, r(1)("WIDTH"))
            If imgWidth > imgParams.WidthAlign Then
                capt = HTMLEncode(Trim(ConvertTo(vbString,r(1)("CAPTION"))))
                If Len(capt) > 0 Then
                    TextImageCallBackDefault = "<table class=""bbcodefullsizeimg""><tr><td><img class=""bbcode"" width=""" & imgWidth & """ src=""" & imgserver & r(1)("SID") & _
                                               """ alt=""" & HTMLEncode(r(1)("CAPTION")) & """/></td></tr><tr><th>" & HTMLEncode(ConvertTo(vbString,r(1)("CAPTION"))) & "</th></tr></table>"
                Else
                    TextImageCallBackDefault = "<table class=""bbcodefullsizeimg""><tr><td><img class=""bbcode"" width=""" & imgWidth & """ src=""" & imgserver & r(1)("SID") & _
                                               """ alt=""" & HTMLEncode(r(1)("CAPTION")) & """/></td></tr></table>"
                End If
            Else
                capt = HTMLEncode(Trim(ConvertTo(vbString,r(1)("CAPTION"))))
                If Len(capt) > 0 Then
                    TextImageCallBackDefault = "<table class=""bbcodesmallimg""><tr><td><img class=""bbcode"" width=""" & imgWidth & """ src=""" & imgserver & r(1)("SID") & _
                                               """ alt=""" & HTMLEncode(r(1)("CAPTION")) & """/></td></tr><tr><th>" & HTMLEncode(ConvertTo(vbString,r(1)("CAPTION"))) & "</th></tr></table>"
                Else
                    TextImageCallBackDefault = "<table class=""bbcodesmallimg""><tr><td><img class=""bbcode"" width=""" & imgWidth & """ src=""" & imgserver & r(1)("SID") & _
                                               """ alt=""" & HTMLEncode(r(1)("CAPTION")) & """/></td></tr></table>"
                End If
            End If
        Else
            TextImageCallBackDefault = ""
        End If
    End Function
    Function CustomBBTextCallBack(imgParams,custParam)
        Dim s, arr, u, p, k
        Dim pWidth, pHeight, t
        CustomBBTextCallBack = ""
        
        arr = Split(custParam," ")
        k = "" ' autodetect
        If UBound(arr) = 0 Then
            u = arr(0) ' autodetect
        ElseIf UBound(arr) = 1 Then
            k = LCase(arr(0))
            u = arr(1)
        ElseIf UBound(arr) = 2 Then
            k = LCase(arr(0))
            u = arr(2)
            p = arr(1)
        End If
        
        If (InStr(LCase(u),"http://www.youtube.com") = 1 Or InStr(LCase(u),"http://youtube.com")) And (k = "video" Or k = "") Then
            pWidth = imgParams.YouTubeWidth
            pHeight = 0
            If Len(p) > 0 Then
                arr = Split(p,"x")
                If UBound(arr) = 1 Then
                    pWidth = ConvertTo(vbLong,arr(0))
                    pHeight = ConvertTo(vbLong,arr(1))
                    If pWidth <= 0 Then
                        pWidth = imgParams.YouTubeWidth
                        pHeight = 0
                    ElseIf pWidth > 0 And pHeight > 0 Then
                        t = IfThenElse(pWidth > pHeight,pWidth,pHeight)
                        
                        If t > imgParams.MaxVideoSize Then
                            If pWidth > pHeight Then
                                pHeight = CLng((pHeight * imgParams.MaxVideoSize) / pWidth)
                                pWidth = imgParams.MaxVideoSize
                            Else
                                pWidth = CLng((pWidth * imgParams.MaxVideoSize) / pHeight)
                                pHeight = imgParams.MaxVideoSize
                            End If
                        End If
                    Else
                        If pWidth > imgParams.MaxVideoSize Then
                            pWidth = imgParams.MaxVideoSize
                            pHeight = 0
                        End If
                    End If
                End If
            End If
            ' Correct the URL if necessary
            If InStr(u,"watch?v=") > 1 Then
                u = Replace(u,"watch?v=","v/") & "&hl=en&fs=1"
            End If
            s =     "<center>"
            s = s & "<object " & vbCrLf 
            If ConvertTo(vbLong, pWidth) > 0 Then
                s = s & "  width=""" & pWidth & """" & vbCrLf
            End If
            If ConvertTo(vbLong, pHeight) > 0 Then
                s = s & "  height=""" & pHeight & """" & vbCrLf
            End If
            s = s & ">" & vbCrLf
            s = s & "<param name=""movie"" value=""" & u & """></param>" & vbCrLf
            s = s & "<param name=""allowFullScreen"" value=""true""></param>" & vbCrLf
            s = s & "<param name=""allowscriptaccess"" value=""always""></param>" & vbCrLf
            s = s & "<embed src=""" & u & """" & vbCrLf
            s = s & "    type=""application/x-shockwave-flash""" & vbCrLf
            s = s & "    allowscriptaccess=""always""" & vbCrLf
            s = s & "    allowfullscreen=""true""" & vbCrLf
            If ConvertTo(vbLong, pWidth) > 0 Then
                s = s & "  width=""" & pWidth & """" & vbCrLf
            End If
            If ConvertTo(vbLong, pHeight) > 0 Then
                s = s & "  height=""" & pHeight & """" & vbCrLf
            End If
            s = s & "></embed></object>" & vbCrLf
            CustomBBTextCallBack = s
        End If
    End Function
    
    ' text - The text of the unit, must be pre-fetched
    ' ObjectSid - The SID of the object
    ' Lang - The language of the text - so that the images can be fetched with their respective titles and descriptions
    Sub RenderBBText(text, Lang)
        Dim ip
        Set ip = New HImageParams
        ip.ObjectSID = Null
        ip.Language = Lang
        ip.WidthMax = cMaxEmbeddedImageWidth
        ip.WidthAlign = cMaxAlignedImageWidth
        ip.YouTubeWidth = cYouTubeWidth
        ip.MaxVideoSize = cMaxVideoSize
        Response.Write BBCodeEx2(text,VirtPath("/image.asp") & "?image=",ip,"TextImageCallBackDefault","CustomBBTextCallBack")
        Response.Write "<div style=""font-size:1px;clear:both;""></div>"
    End Sub
    
    Sub RenderBriefBBText(text,maxLength)
        Response.Write Ellipsis(BBCodeCleanNoLines(text), maxLength)
    End Sub
    
    ' Quick access to attached/linked records of certain types
    
    Function GetAttachedImages(sid,Limit)
        Dim r, sLimit
        sLimit = ""
        If ConvertTo(vbLong,Limit) > 0 Then sLimit = " LIMIT " & Limit
        Set r = Database.DB.VExecute("SELECT I.* FROM IMAGE I, RELATION R WHERE I.SID=R.TARGET_SID AND R.OBJECT_SID=$OBJECT_SID AND " & _
                                     " NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND OBJECT_TYPE='IMAGE' AND " & SQLReadRightsTable("I") & " ORDER BY R.ORDER_TAG" & sLimit, _
                                             1, 0, sid, PageUILanguage)
        Set GetAttachedImages = r
    End Function
    Function GetAttachedFiles(sid,Limit)
        Dim r, sLimit
        sLimit = ""
        If ConvertTo(vbLong,Limit) > 0 Then sLimit = " LIMIT " & Limit
        Set r = Database.DB.VExecute("SELECT I.* FROM FILE I, RELATION R WHERE I.SID=R.TARGET_SID AND R.OBJECT_SID=$OBJECT_SID AND " & _
                                     " NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND OBJECT_TYPE='FILE' AND " & SQLReadRightsTable("I") & " ORDER BY R.ORDER_TAG" & sLimit, _
                                             1, 0, sid, PageUILanguage)
        Set GetAttachedFiles = r
    End Function
    Function GetAttachedArticles(sid,Limit)
        Dim r, sLimit
        sLimit = ""
        If ConvertTo(vbLong,Limit) > 0 Then sLimit = " LIMIT " & Limit
        Set r = Database.DB.VExecute("SELECT I.* FROM ARTICLE I, RELATION R WHERE I.SID=R.TARGET_SID AND R.OBJECT_SID=$OBJECT_SID AND " & _
                                     " NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND R.OBJECT_TYPE='ARTICLE' AND " & SQLReadRightsTable("I") & " ORDER BY R.ORDER_TAG" & sLimit, _
                                             1, 0, sid, PageUILanguage)
        Set GetAttachedArticles = r
    End Function
    Function GetAttachedItems(sid,Limit)
        Dim r, sLimit
        sLimit = ""
        If ConvertTo(vbLong,Limit) > 0 Then sLimit = " LIMIT " & Limit
        Set r = Database.DB.VExecute("SELECT I.* FROM ITEM I, RELATION R WHERE I.SID=R.TARGET_SID AND R.OBJECT_SID=$OBJECT_SID AND " & _
                                     " NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND R.OBJECT_TYPE='ITEM' AND " & SQLReadRightsTable("I") & " ORDER BY R.ORDER_TAG" & sLimit, _
                                             1, 0, sid, PageUILanguage)
        Set GetAttachedItems = r
    End Function
    Function GetAttachedEvents(sid,Limit)
        Dim r, sLimit
        sLimit = ""
        If ConvertTo(vbLong,Limit) > 0 Then sLimit = " LIMIT " & Limit
        Set r = Database.DB.VExecute("SELECT I.* FROM EVENT I, RELATION R WHERE I.SID=R.TARGET_SID AND R.OBJECT_SID=$OBJECT_SID AND " & _
                                     " NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND R.OBJECT_TYPE='EVENT' AND " & SQLReadRightsTable("I") & " ORDER BY R.ORDER_TAG" & sLimit, _
                                             1, 0, sid, PageUILanguage)
        Set GetAttachedEvents = r
    End Function
    Function GetAttachedContent(sid,Limit)
        Dim r, sLimit
        sLimit = ""
        If ConvertTo(vbLong,Limit) > 0 Then sLimit = " LIMIT " & Limit
        Set r = Database.DB.VExecute("SELECT I.* FROM ARTICLE I, RELATION R WHERE I.SID=R.TARGET_SID AND R.OBJECT_SID=$OBJECT_SID AND " & _
                                     " NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND R.OBJECT_TYPE='ARTICLE' AND " & SQLReadRightsTable("I") & " ORDER BY R.ORDER_TAG" & sLimit & ";" & _
                                     "SELECT I.* FROM EVENT I, RELATION R WHERE I.SID=R.TARGET_SID AND R.OBJECT_SID=$OBJECT_SID AND " & _
                                     " NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND R.OBJECT_TYPE='EVENT' AND " & SQLReadRightsTable("I") & " ORDER BY R.ORDER_TAG" & sLimit & ";" & _
                                     "SELECT I.* FROM ITEM I, RELATION R WHERE I.SID=R.TARGET_SID AND R.OBJECT_SID=$OBJECT_SID AND " & _
                                     " NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND R.OBJECT_TYPE='ITEM' AND " & SQLReadRightsTable("I") & " ORDER BY R.ORDER_TAG" & sLimit & ";", _
                                     1, 0, sid, PageUILanguage)
        Set GetAttachedContent = r
    End Function
    ' Looks into several tables for a given sid and returns the record for the specified language
    Function GetContentEntry(sid,lang)
        Dim r
        Set r = Database.DB.VExecute("SELECT I.*, 'ARTICLE' AS OBJECT_TYPE FROM ARTICLE I WHERE SID=$OBJECT_SID AND NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND " & SQLReadRightsTable("I") & ";" & _
                                     "SELECT I.*, 'EVENT' AS OBJECT_TYPE FROM EVENT I WHERE SID=$OBJECT_SID AND NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND " & SQLReadRightsTable("I") & ";" & _
                                     "SELECT I.*, 'ITEM' AS OBJECT_TYPE FROM ITEM I WHERE SID=$OBJECT_SID AND NOT I.DELETED AND I.LANGUAGE=$LANGUAGE AND " & SQLReadRightsTable("I") & ";",_
                                     1, 0, NullConvertTo(vbLong,sid), lang)
        If r.Count > 0 Then
            Set GetContentEntry = r(1)
        Else
            Set GetContentEntry = r
        End If
    End Function
    
    ' Nomenclature
    '   TO DO: May be apply rights
    
    Function GetNomenclature(Nomenclature, sid, Lang)
        Dim r, o
        Set o = New HNomenclature
        Set r = Database.DB.VExecute("SELECT * FROM [" & Nomenclature & "] WHERE SID=$SID AND LANGUAGE=$LANGUAGE AND " & SQLReadRights, 1, 1, ConvertTo(vbLong, sid), Lang)
        If r.Count <> 0 Then
            o.Caption = ConvertTo(vbString, r(1)("CAPTION"))
            o.Description = ConvertTo(vbString, r(1)("BODY"))
            o.Code = ConvertTo(vbString, r(1)("CODE"))
            o.Image = ConvertTo(vbLong, r(1)("IMAGE_SID"))
        End If
        Set GetNomenclature = o
    End Function
    Function Nomenclature(Nom,sid)
        Set Nomenclature = GetNomenclature(Nom, sid, PageUILanguage)
    End Function
    Class HNomenclature
        Public Caption, Description, Code
        Public Image
        Public Property Get Name
            Name = HTMLEncode(Caption)
        End Property
        Public Property Get NameAndImage
            Dim s
            s = "<table><tr>" & vbCrLf
            If Len(Image) <> 0 Then
                s = s & "<td align=""center"" valign=""middle"" width=""40""><img border=""0"" alt=""" & Name & _
                        """ src=""" & VirtPath("/image.asp") & "?th=" & cImageKindIcon & "&image=" & Image & """/></td>" & vbCrLf
            End If
            If Len(Caption) <> 0 Then
                s = s & "<td align=""center"" valign=""middle"">" & Name & "</td>" & vbCrLf
            End If
            s = s & "</tr></table>" & vbCrLf
            NameAndImage = s
        End Property
    End Class
    
    Function NomenclatureList(nom)
        Set NomenclatureList = Database.DB.VExecute("SELECT * FROM [" & nom & "] WHERE NOT DELETED AND LANGUAGE=$LANGUAGE AND " & SQLReadRights & " ORDER BY NAME",1,0,PageUILanguage)
    End Function
    
    ' The usage of these two routines is strongly discouraged!
    Function SimpleNomenclatureListBox(nom)
        Dim o
        Set o = Create_CList(Empty)
        o.AddItem "", ""
        o.AddSQLiteItems Database.DB.VExecute("SELECT SID, NAME FROM [" & nom & "] WHERE NOT DELETED AND LANGUAGE=$LANGUAGE AND " & SQLReadRights & " ORDER BY NAME",1,0,PageUILanguage),"SID","NAME"
        Set SimpleNomenclatureListBox = o
    End Function
    Function TreeNomenclatureSelector(nom)
        Dim o
        Set o = Create_UCTreeNomReadOnly(Empty)
        o.AsyncPostBack(o) = True
        o.Nomenclature = nom
        o.Width = 400
        o.Height = 200
        Set TreeNomenclatureSelector = o
    End Function
    
    ' Person 
    Function PersonName(r)
        Dim s
        s = ""
        s = IfEmpty(r("TITLE") & " ","") & IfEmpty(r("NAME1") & " ","") & IfEmpty(r("NAME2") & " ","") & IfEmpty(r("NAME3"),"")
        PersonName = s
    End Function
    
    Function GetPerson(pid,Lang)
        Dim o, r
        Set o = New HPerson
        Set r = Database.DB.VExecute("SELECT * FROM PERSON WHERE SID=$SID AND LANGUAGE=$LANGUAGE AND " & SQLReadRights,1,1,NullConvertTo(vbLong, pid),Lang)
        If r. Count > 0 Then
            o.Name1 = ConvertTo(vbString, r(1)("NAME1"))
            o.Name2 = ConvertTo(vbString, r(1)("NAME2"))
            o.Name3 = ConvertTo(vbString, r(1)("NAME3"))
            o.Title = ConvertTo(vbString, r(1)("TITLE"))
            o.Id = ConvertTo(vbLong, r(1)("SID"))
            o.ImageId = ConvertTo(vbLong, r(1)("IMAGE_SID"))
            o.Comment = ConvertTo(vbString, r(1)("COMMENT"))
            o.IsEntity = ConvertTo(vbBoolean, r(1)("ISENTITY"))
            o.IsValid = True
        End If
        Set GetPerson = o
    End Function
    Function GetUserPerson(uid)
        Dim r, p
        Set r = Database.DB.Vexecute("SELECT * FROM USER WHERE ID=$ID",1,1,NullconvertTo(vbLong,uid))
        If r.Count > 0 Then
            Set p = GetPerson(r(1)("PERSON_SID"),PageUILanguage)
        Else
            Set p = GetPerson(0,PageUILanguage)
        End If
        Set GetUserPerson = p
    End Function
    Function Create_HPerson(r)
        Set o = New HPerson
        If r.Count > 0 Then
            o.Name1 = ConvertTo(vbString, r("NAME1"))
            o.Name2 = ConvertTo(vbString, r("NAME2"))
            o.Name3 = ConvertTo(vbString, r("NAME3"))
            o.Title = ConvertTo(vbString, r("TITLE"))
            o.Id = ConvertTo(vbLong, r("SID"))
            o.ImageId = ConvertTo(vbLong, r("IMAGE_SID"))
            o.Comment = ConvertTo(vbString, r("COMMENT"))
            o.IsEntity = ConvertTo(vbBoolean, r("ISENTITY"))
            o.IsValid = True
        End If
        Set Create_HPerson = o
    End Function
    Class HPerson
        Public Name1, Name2, Name3, Title, Comment
        Public ImageId, Id, IsEntity
        Public IsValid
        Public Property Get Name
            Dim s
            s = ""
            If IsEntity Then
                s = Name1
            Else
                If Len(Title) > 0 Then s = s & Title & " "
                If Len(Name1) > 0 Then s = s & Name1 & " "
                If Len(Name2) > 0 Then s = s & Name2 & " "
                If Len(Name3) > 0 Then s = s & Name3 & " "
            End If
            Name = HTMLEncode(Trim(s))
        End Property
        Public Function RenderIconSmall
            If ConvertTo(vbLong,ImageId) <> 0 Then
                RenderIconSmall = "<img src=""" & VirtPath("/image.asp") & "?th=" & cImageKindIcon & "&image=" & ImageId & """ alt=""" & Name & """ border=""0""/>"
            Else
                RenderIconSmall = "<img src=""" & VirtPath("/img/user-icon.png") & """ alt=""" & Name & """ border=""0""/>"
            End If
        End Function
        Public Property Get IconAndName
            Dim s
            If ConvertTo(vbLong,ImageId) <> 0 Then
                s = RenderIconSmall & " "
            End If
            s = s & Name
            IconAndName = s
        End Property
    End Class
    
    Sub RenderUserLink(uid, lnk)
        Dim r, p
        Set r = Database.DB.VExecute("SELECT * FROM USER WHERE ID=$UID", 1, 1, NullConvertTo(vbLong, uid))
        If r.Count > 0 Then
            Set p = GetUserPerson(uid)
            If p.IsValid Then
                %><a href="<%= lnk & uid %>"><%= ConvertTo(vbString,r(1)("LOGIN")) & " - " & p.IconAndName %></a><%
            Else
                %><a href="<%= lnk & uid %>"><%= ConvertTo(vbString,r(1)("LOGIN")) %></a><%
            End If
        End If
    End Sub
    Sub RenderUserImage(uid, lnk)
        Dim r, p
        Set r = Database.DB.VExecute("SELECT * FROM USER WHERE ID=$UID", 1, 1, NullConvertTo(vbLong, uid))
        If r.Count > 0 Then
            Set p = GetUserPerson(uid)
            If p.IsValid Then
                %><a href="<%= lnk & uid %>"><%= p.RenderIconSmall %></a><%
            Else
                %><a href="<%= lnk & uid %>"><img src="<%= VirtPath("/img/user-icon.png") %>" alt="" /></a><%
            End If
        End If
    End Sub
    Sub RenderUserText(uid, lnk)
        Dim r, p
        Set r = Database.DB.VExecute("SELECT * FROM USER WHERE ID=$UID", 1, 1, NullConvertTo(vbLong, uid))
        If r.Count > 0 Then
            Set p = GetUserPerson(uid)
            If p.IsValid Then
                %><a href="<%= lnk & uid %>"><%= ConvertTo(vbString,r(1)("LOGIN")) & " - " & p.Name %></a><%
            Else
                %><a href="<%= lnk & uid %>"><%= ConvertTo(vbString,r(1)("LOGIN")) %></a><%
            End If
        End If
    End Sub

    ' New! All the code should be migrated to use this function for image reference in src to allow reconfiguration (work in progress)
    Function ImageSrc(sid,th)
        ImageSrc = VirtPath("/image.asp") & "?image=" & sid & IfThenElse(th > 0,"&th=" & th,"")
    End Function

    Function DisplayFileIcon(fid,bLink)
        Dim r, s
        s = ""
        If bLink Then
            Set r = Database.DB.VExecute("SELECT * FROM FILE WHERE SID=$SID AND LANGUAGE=$LANGUAGE AND " & SQLReadRights,1,1,NullConvertTo(vbLong,fid),PageUILanguage)
        Else
            Set r = Database.DB.VExecute("SELECT * FROM FILE WHERE SID=$SID AND LANGUAGE=$LANGUAGE",1,1,NullConvertTo(vbLong,fid),PageUILanguage)
        End If
        If r.Count > 0 Then
            Set r = r(1)
            If bLink Then s = s & "<a href=""" & VirtPath("/file.asp") & "?File=" & fid & """ target=""_blank"">"
            s = s & "<img src=""" & FileIcon(GetFileExt(ConvertTo(vbString,r("FILE_NAME")))) & """ alt="""" border=""0""/>" & _
                " " & HTMLEncode(r("FILE_NAME")) & " (" & FileSizeString(ConvertTo(vbLong,r("SIZE"))) & ")"
            If bLink Then s = s & "</a>"
        End If
        DisplayFileIcon = s
    End Function
    Function DisplayFileIconFromRecord(r,bLink)
        Dim  s
        s = ""
        If r.Count > 0 Then
            Set r = r(1)
            If bLink Then s = s & "<a href=""" & VirtPath("/file.asp") & "?File=" & r("SID") & """ target=""_blank"" title=""" & HTMLEncode(r("CAPTION")) & """>"
            s = s & "<img src=""" & FileIcon(GetFileExt(ConvertTo(vbString,r("FILE_NAME")))) & """ alt="""" border=""0""/>" & _
                " " & HTMLEncode(r("FILE_NAME")) & " (" & FileSizeString(ConvertTo(vbLong,r("SIZE"))) & ")"
            If bLink Then s = s & "</a>"
        End If
        DisplayFileIconFromRecord = s
    End Function
    Function DisplayImageIcon(iid, bLink)
        Dim r, s
        s = ""
        If bLink Then
            Set r = Database.DB.VExecute("SELECT * FROM IMAGE WHERE SID=$SID AND LANGUAGE=$LANGUAGE AND " & SQLReadRights,1,1,NullConvertTo(vbLong,iid),PageUILanguage)
        Else
            Set r = Database.DB.VExecute("SELECT * FROM IMAGE WHERE SID=$SID AND LANGUAGE=$LANGUAGE",1,1,NullConvertTo(vbLong,iid),PageUILanguage)
        End If
        If r.Count > 0 Then
            Set r = r(1)
            If bLink Then s = s & "<a href=""" & VirtPath("/image.asp") & "?image=" & iid & """ target=""_blank"">"
            s = s & "<img src=""" & VirtPath("/image.asp") & "?th=" & cImageKindIcon & "&image=" & iid & """ alt="""" border=""0""/>" & _
                " " & HTMLEncode(r("CAPTION")) & " (" & ConvertTo(vbLong,r("WIDTH")) & " x " & ConvertTo(vbLong,r("HEIGHT")) & ")"
            If bLink Then s = s & "</a>"
        End If
        DisplayImageIcon = s
    End Function
    Function DisplayImageThumbnail(iid, bLink, nThumb)
        Dim r, sAlt, s
        s = ""
        Set r = Database.DB.VExecute("SELECT * FROM IMAGE WHERE SID=$SID AND LANGUAGE=$LANGUAGE AND " & SQLExecRights,1,1,NullConvertTo(vbLong,iid),PageUILanguage)
        If r.Count > 0 Then
            If bLink And CurrentUser.CanAccess(r(1),FR_READ) Then
                s = s & "<a href=""" & VirtPath("/image.asp") & "?image=" & iid & """ target=""_blank"">"
                s = s & "<img src=""" & VirtPath("/image.asp") & "?th=" & nThumb & "&image=" & iid & """ alt=""" & HTMLEncode(r("CAPTION")) & """ border=""0""/>"
                s = s & "</a>"
            Else
                s = s & "<img src=""" & VirtPath("/image.asp") & "?th=" & nThumb & "&image=" & iid & """ alt=""" & HTMLEncode(r("CAPTION")) & """ border=""0""/>"
            End If
        End If
        DisplayImageThumbnail = s
    End Function
    
    
    
    
    ' Locatons nomenclature
    Function GetLocation(locId)
        Dim r, curId, o
        curId = ConvertTo(vbLong, locId)
        Set o = New HLocation
        While curId <> 0
            Set r = Database.DB.Vexecute("SELECT * FROM LOCATION WHERE SID=$SID AND LANGUAGE=$LANGUAGE AND " & SQLReadRights,1,1,curId,PageUILanguage)
            If r.Count > 0 Then
                o.Locations.Add "", r(1)
                curId = ConvertTo(vbLong, r(1)("PARENT_SID"))
            Else
                curId = 0
            End If
        Wend
        Set GetLocation = o
    End Function
    
    Class HLocation
        Public Locations
        Sub Class_Initialize
            Set Locations = CreateList
        End Sub
        Public Property Get ShortName
            Dim s
            s = ""
            If Locations.Count > 0 Then
                s = s & Locations(1)("NAME")
            End If
            ShortName = s
        End Property
        Public Property Get FullName
            Dim s, I
            s = ""
            For I = 1 To Locations.Count
                If Len(s) > 0 Then s = s & ", "
                s = s & Locations(I)("NAME")
            Next
            FullName = s
        End Property
        Public Property Get CadCode
            Dim s
            s = ""
            If Locations.Count > 0 Then
                s = s & Locations(1)("CADCODE")
            End If
            CadCode = s
        End Property
        Public Property Get FullCadCode
            Dim s, I
            s = ""
            For I = Locations.Count To 1 Step -1
                If Len(s) > 0 Then s = s & "."
                s = s & Locations(I)("CADCODE")
            Next
            FullCadCode = s
        End Property
    End Class
    
%>