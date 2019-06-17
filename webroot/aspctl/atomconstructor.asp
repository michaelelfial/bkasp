<%
    ' Constructor for an Atom feed
    
    Class CAtomFeed
        Public Title, SubTitle, Updated, Published, Id
        Public SiteLink, SelfLink ' Link to the WEB site or its portion, link to the feed itself
        Public Icon, Author, UseXHTML, EncodeHTML, ImageFeed 
        
        Private su
        Public Entries
        
        Sub Class_Initialize
            Set su = Server.CreateObject("newObjects.utilctls.StringUtilities")
            su.DateTimeFormat = "Y-M-dTH:m:sZ"
            Set Entries = CreateList
            Set Author = New CAtomFeedPerson
            Author.Name = "ASP-CTL Atom constructor"
            Updated = LocalToUTC(Now)
            Published = LocalToUTC(Now)
            EncodeHTML = True
        End Sub
        
        Function TextEncode(s)
            TextEncode = XMLEncode2(s)
        End Function
        Function TimeEncode(elname,tt)
            Dim t
            TimeEncode = ""
            t = NullConvertTo(vbDate,tt)
            If Not IsEmpty(t) And Not IsNull(t) Then
                TimeEncode = su.Sprintf("<%s>%lT</%s>",elname,t,elname)
            End If
        End Function
        Sub AutoAdjustUpdateTime
            Dim ut, e, t
            On Error Resume Next
            For I = 1 To Entries.Count
                Set e = Entries(I)
                t = NullconvertTo(vbDouble,e.Updated)
                If Not IsNull(t) Then
                    If IsEmpty(ut) Then
                        ut = t
                    ElseIf ut < t Then
                        ut = t
                    End If
                End If
            Next
            If Not IsEmpty(ut) Then
                Updated = ConvertTo(vbDate, ut)
            End If
        End Sub
        
        Function AddEntry
            Dim o
            Set o = New CAtomFeedEntry
            Set o.Author = Author
            o.Updated = Updated
            o.Published = Published
            Entries.Add "", o
            Set AddEntry = o
        End Function
        
        
        Function GenerateInMemoryStream
            Dim sf, strm
            Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
            Set strm = sf.CreateMemoryStream
            strm.unicodeText = True
            If Generate(strm) Then
                strm.Pos = 0
                Set GenerateInMemoryStream = strm
            Else
                Set GenerateInMemoryStream = Nothing
            End If
        End Function
        Function Generate(strm)
            Dim s, sf, I
            strm.WriteText "<?xml version=""1.0"" encoding=""utf-8""?>", 1
            strm.WriteText "<feed xmlns=""http://www.w3.org/2005/Atom"" xml:lang=""" & PageUILanguage & """>", 1
            
            strm.WriteText "<title type=""html"">" & TextEncode(Title) & "</title>", 1
            If Len(Trim(SubTitle)) > 0 Then
                strm.WriteText "<subtitle type=""html"">" & TextEncode(SubTitle) & "</subtitle>", 1
            End If
            If Len(SiteLink) > 0 Then
                strm.WriteText "  <link rel=""alternate"" type=""text/html"" href=""" & SiteLink & """/>", 1
            End If
            If Len(SelfLink) > 0 Then
                strm.WriteText "  <link rel=""self"" type=""application/atom+xml"" href=""" & SelfLink & """/>", 1
            End If
            If Len(Trim(Icon)) > 0 Then
                strm.WriteText "<icon>" & Icon & "</icon>", 1
            End If
            If Len(Trim(Id)) > 0 Then
                strm.WriteText "  <id>" & Id & "</id>", 1
            ElseIf Len(SelfLink) > 0 Then
                strm.WriteText "  <id>" & SelfLink & "</id>", 1
            End If
            
            strm.WriteText "<generator uri=""http://www.newobjects.com/aspctl"" version=""" & ASPCTL_Version & """>", 1
            strm.WriteText "ASP-CTL Atom constructor", 1
            strm.WriteText "</generator>", 1
            strm.WriteText TimeEncode("updated",Updated), 1
            ' strm.WriteText TimeEncode("published",Published), 1
            
            For I = 1 To Entries.Count
                Entries(I).Generate Me, strm
            Next
            
            strm.WriteText "</feed>", 1
            Generate = True
        End Function
    End Class
    
    Class CAtomFeedEntry
        Public Title, Summary, Updated, Published, Id, Content, Link
        Public CategoryTitle, CategoryScheme, Author, CategoryTerm, Image, ImageWidth
        Sub Class_Initialize
            Updated = LocalToUTC(Now)
            Published = LocalToUTC(Now)
            ImageWidth = 100
        End Sub
        Function Generate(feed, strm)
            strm.WriteText "<entry>", 1
            strm.WriteText "  <title type=""html"">" & feed.TextEncode(Title) & "</title>", 1
            strm.WriteText feed.TimeEncode("updated",Updated), 1
            strm.WriteText feed.TimeEncode("published",Published), 1
            If Len(Trim(Summary)) > 0 Then
                strm.WriteText "  <summary>" & feed.TextEncode(Summary) & "</summary>", 1
            End If
            If Len(Trim(Id)) > 0 Then
                strm.WriteText "  <id>" & Id & "</id>", 1
            ElseIf Len(Link) > 0 Then
                strm.WriteText "  <id>" & Link & "</id>", 1
            End If
            If Len(Link) > 0 Then
                strm.WriteText "  <link rel=""alternate"" type=""text/html"" href=""" & Link & """/>", 1
            End If
            If Len(CategoryTerm) > 0 Then
                strm.WriteText "  <category term=""" & CategoryTerm & """", 0
                If Len(CategoryScheme) > 0 Then strm.WriteText "  scheme=""" & feed.TextEncode(CategoryScheme) & """", 0
                If Len(CategoryTitle) > 0 Then strm.WriteText "  label=""" & feed.TextEncode(CategoryTitle) & """", 0
                strm.WriteText "/>", 1
            End If
            strm.WriteText "<author>", 1
            Author.Generate feed, strm
            strm.WriteText "</author>", 1
            If Len(Image) > 0 And feed.ImageFeed Then
                strm.WriteText "<content type=""image/jpeg"" src=""" & feed.TextEncode(Image) & """/>", 1
                If Len(Trim(Content)) Then
                    strm.WriteText "<summary>" & feed.TextEncode(Content) & "</summary>",1
                End If
            Else
                If Len(Trim(Content)) Then
                    
                    If feed.UseXHTML Then
                        strm.WriteText "  <content type=""html"" xmlns=""http://www.w3.org/1999/xhtml"">", 1
                        strm.WriteText "    <div>", 1
                        'strm.WriteText "    <xhtml:div xmlns:xhtml=""http://www.w3.org/1999/xhtml"">", 1
                        If Len(Image) > 0 Then
                            strm.WriteText "    <img align=""left"" src=""" & feed.TextEncode(Image) & """ alt="""" width=""" & ImageWidth & """/>", 1
                            strm.WriteText feed.TextEncode(Content),1
                        End If
                        strm.WriteText "    </div>", 1
                        strm.WriteText "  </content>", 1
                    Else
                        If Len(Image) > 0 Then
                            strm.WriteText "  <content type=""html"">", 1
                            If feed.EncodeHTML Then
                                strm.WriteText feed.TextEncode("    <img align=""left"" src=""" & Image & """ alt="""" width=""" & ImageWidth & """/>"), 1
                            Else
                                strm.WriteText "    &lt;img align=""left"" src=""" & feed.TextEncode(Image) & """ alt="""" width=""" & ImageWidth & """/>", 1
                            End If
                            strm.WriteText feed.TextEncode(Content), 1
                            strm.WriteText "  </content>", 1
                        Else
                            strm.WriteText "  <content type=""html"">" & feed.TextEncode(Content) & "</content>", 1
                        End If
                    End If
                End If
            End If
            strm.WriteText "</entry>", 1
        End Function
    End Class
 
    Class CAtomFeedPerson
        Public Name, Uri, Email
        Public Function Generate(feed, strm)
            If Len(Name) > 0 Then
                strm.WriteText "<name>" & feed.TextEncode(Name) & "</name>", 1
            End If
            If Len(Uri) > 0 Then
                strm.WriteText "<uri>" & Uri & "</uri>", 1
            End If
            If Len(Email) > 0 Then
                strm.WriteText "<email>" & Email & "</email>", 1
            End If
        End Function
    End Class
 
%>  