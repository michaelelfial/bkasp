<%
    ' UserAPI applications
    ' Application specific global routines and classes should be defined here
    
    
    ' UserMenuKey
    Function UserMenuItemCss(k)
        UserMenuItemCss = ""
        If UserMenuKey = k Then UserMenuItemCss = "class=""selected"""
    End Function
    
    Sub BBRenderPinned(css,nImgs)
        Dim p, I, arr
        For I = 1 To cPinnedCount
            p = ConvertTo(vbString,Configuration.CodeValue("PIN",I))
            If Len(p) > 0 Then
                arr = Split(p,".")
                If UBound(arr) > 0 Then
                    BBRenderLeftHighlights arr(0),ConvertTo(vbLong,arr(1)), css, nImgs
                End If
            End If
        Next
    
    End Sub
    
    Sub BBRenderLeftHighlights(ct,sid,css,nImgs)
        Dim r, table
        On Error Resume Next
        table = CategoryTypes(ct).fTable
        If Err.Number <> 0 Then Exit Sub
        Set r = Database.DB.VExecute("SELECT * FROM [" & table & "] WHERE NOT DELETED AND SID=$SID AND LANGUAGE=$LANGUAGE AND " & SQLReadRights,1,1, _
                                        NullConvertTo(vbLong, sid), PageUILanguage)
        If r.Count > 0 Then
            Set r = r(1)
            %>
                <div class="lart">
                    <h2><%= HTMLEncode(r("CAPTION")) %></h2>
                    <div class="img" style="background-image: url(img/sideart.jpg);" >
                        <% If ConvertTo(vbLong,r("IMAGE_SID")) <> 0 Then %>
                            <img src="<%= ImageSrc(ConvertTo(vbLong,r("IMAGE_SID")),5) %>" alt="" width="250" />
                        <% End If %>
                    </div>
                    <div class="cont">
                        <% RenderBriefBBText r("BODY"), 128 %><br/>
                        <a href="<%= CategoryTypes(ct).fPage & "?id=" & ConvertTo(vbLong,r("SID")) %>"><%= TR("Read more") %></a>
                    </div>
                </div>
            <%
        End If
    End Sub
    
    
    Sub BBRenderArticle(table, code, bRandom, nLimit, cattype, css, gopage,nImgs)
        Dim r, I, sct, rImgs, nImg
        If Len(cattype) > 0 Then 
            sct = " CATEGORY_TYPE='" & cattype & "' "
        Else
            sct = " 1=1 "
        End If
        If bRandom Then
            Set r = Database.DB.VExecute("SELECT * FROM " & table & " WHERE NOT DELETED AND CODE LIKE $CODE AND LANGUAGE=$LANGUAGE AND " & sct & " ORDER BY random() LIMIT 1",1,1,NullLikeString(code,False,True),PageUILanguage)
        Else
            Set r = Database.DB.VExecute("SELECT * FROM " & table & " WHERE NOT DELETED AND CODE LIKE $CODE AND LANGUAGE=$LANGUAGE AND " & sct,1,0,NullLikeString(code,False,True),PageUILanguage)
        End If
        If r.Count > 0 Then
            For I = 1 To r.Count
                If nImgs > 0 Then
                    Set rImgs = GetAttachedImages(ConvertTo(vbLong,r(I)("SID")), nImgs)
                Else
                    Set rImgs = CreateCollection
                End If
            
                If nLimit = 0 Then
                    %>
                    <div class="<%= css %>">
                    <h4><%= HTMLEncode(r(I)("CAPTION")) %></h4>
                    <%
                    If ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then
                        %><img src="<%= VirtPath("/image.asp") & "?th=1&image=" & ConvertTo(vbLong, r(I)("IMAGE_SID")) %>" alt="" align="left" /><%
                    End If
                    RenderBBText r(I)("BODY"), PageUILanguage
                    Response.Write "<br/>"
                    Response.Write "</div>"
                Else
                    %>
                    <div class="<%= css %>">
                    <h4><%= HTMLEncode(r(I)("CAPTION")) %></h4>
                    <div class="briefcontent">
                    <%
                    If ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then
                        %><img src="<%= VirtPath("/image.asp") & "?th=2&image=" & ConvertTo(vbLong, r(I)("IMAGE_SID")) %>" alt="" align="left" /><%
                    End If
                    RenderBriefBBText r(I)("BODY"), nLimit
                    If rImgs.Count > 0 Then
                     %>
                        <div style="clear:both"></div>
                        <table width="100%" class="minithumbs">
                        <tr>
                            <td>&nbsp;</td>
                        <%
                        For nImg = 1 To rImgs.Count
                            %>
                            <td style="padding: 2px;" class="thumb">
                                <img border="0" src="<%= VirtPath("/image.asp") & "?th=4&image=" & rImgs(nImg)("SID") %>" alt="<%= HTMLEncode(rImgs(nImg)("CAPTION")) %>" title="<%= HTMLEncode(rImgs(nImg)("CAPTION")) %>"/>
                            </td>
                            <%
                        Next
                        %>
                        </tr>
                        </table>
                        <%
                    End If
                    Response.Write "<br/>"
                    %>
                    <a href="<%= VirtPath(gopage) & "?id=" & r(I)("SID") %>"><%= TR("Read more") %></a>
                    <%
                    Response.Write "</div></div>"
                End If
            Next
        End If
    End Sub
    
    ' Example: BBRenderLatest "ARTICLE", 5, "CATEGORY_TYPE='ARTICLE'", "", "/article", 3
    Sub BBRenderLatest(table, nLimit, sct, css, gopage, nImgs)
        Dim r, I, rImgs, nImg, hasImg
        
        Set r = Database.DB.VExecute("SELECT * FROM " & table & " WHERE NOT DELETED AND LANGUAGE=$LANGUAGE AND " & SQLReadRights & " AND " & _
                                     sct & " ORDER BY CREATED DESC LIMIT " & nLimit,1,0,PageUILanguage)
        
        If r.Count > 0 Then
            For I = 1 To r.Count
                If nImgs > 0 Then
                    Set rImgs = GetAttachedImages(ConvertTo(vbLong,r(I)("SID")), nImgs)
                Else
                    Set rImgs = CreateCollection
                End If
                hasImg = False
                If ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then hasImg = True
                %>
                <table class="<%= css %>">
                    <tr>
                        <th <%= IfThenElse(hasImg,"colspan=""2""","") %>><%= HTMLEncode(r(I)("CAPTION")) %></th>
                    </tr>
                    <tr>
                        <%
                        If ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then
                            %><td class="image" rowspan="2"><img src="<%= VirtPath("/image.asp") & "?th=2&image=" & ConvertTo(vbLong, r(I)("IMAGE_SID")) %>" alt="" /></td><%
                        End If  
                        %>
                        <td class="text"><% RenderBriefBBText r(I)("BODY"), 128 %><br/>
                        <a href="<%= VirtPath(gopage) & "?id=" & r(I)("SID") %>"><%= TR("Read more") %></a>
                        </td>
                    </tr>
                    <%
                    If rImgs.Count > 0 Then
                    %>
                    <tr>
                        <td>
                        <table width="100%" class="minithumbs">
                        <tr>
                            <td>&nbsp;</td>
                        <%
                        For nImg = 1 To rImgs.Count
                            %>
                            <td style="padding: 2px;" class="thumb">
                                <img border="0" src="<%= VirtPath("/image.asp") & "?th=4&image=" & rImgs(nImg)("SID") %>" alt="<%= HTMLEncode(rImgs(nImg)("CAPTION")) %>" title="<%= HTMLEncode(rImgs(nImg)("CAPTION")) %>"/>
                            </td>
                            <%
                        Next
                        %>
                        </tr>
                        </table>
                        </td>
                    </tr>
                    <%
                    End If
                    %>
                </table>
                <%                
            Next
        End If
    End Sub
    
    ' Example: BBRenderLatest "ARTICLE", 5, "CATEGORY_TYPE='ARTICLE'", "", "/article", 3
    Sub BBRenderLatestRight(table, nLimit, sct, css, gopage, nImgs)
        Dim r, I, rImgs, nImg
        
        Set r = Database.DB.VExecute("SELECT * FROM " & table & " WHERE NOT DELETED AND LANGUAGE=$LANGUAGE AND " & SQLReadRights & " AND " & _
                                     sct & " ORDER BY CREATED DESC LIMIT " & nLimit,1,0,PageUILanguage)
        
        If r.Count > 0 Then
            For I = 1 To r.Count
                If nImgs > 0 Then
                    Set rImgs = GetAttachedImages(ConvertTo(vbLong,r(I)("SID")), nImgs)
                Else
                    Set rImgs = CreateCollection
                End If
                %>
                <div class="<%= css %>">
                <% If False And ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then %>
                    <h4 style="height: 80px;background-repeat: no-repeat;background-position: left top; background-image: url(<%= VirtPath("/image.asp") & "?th=5&image=" & ConvertTo(vbLong, r(I)("IMAGE_SID")) %>);"><%= HTMLEncode(r(I)("CAPTION")) %></h4>
                <% Else %>
                    <h4><%= HTMLEncode(r(I)("CAPTION")) %></h4>
                <% End If %>
                
                <div class="briefcontent">
                <%
                If ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then
                    %><img src="<%= VirtPath("/image.asp") & "?th=4&image=" & ConvertTo(vbLong, r(I)("IMAGE_SID")) %>" alt="" align="left" /><%
                End If
                RenderBriefBBText r(I)("BODY"), 80
                If rImgs.Count > 0 Then
                 %>
                    <div style="clear:both"></div>
                    <table width="100%" class="minithumbs">
                    <tr>
                        <td>&nbsp;</td>
                    <%
                    For nImg = 1 To rImgs.Count
                        %>
                        <td style="padding: 2px;" class="thumb">
                            <img border="0" src="<%= VirtPath("/image.asp") & "?th=4&image=" & rImgs(nImg)("SID") %>" alt="<%= HTMLEncode(rImgs(nImg)("CAPTION")) %>" title="<%= HTMLEncode(rImgs(nImg)("CAPTION")) %>"/>
                        </td>
                        <%
                    Next
                    %>
                    </tr>
                    </table>
                    <%
                End If
                Response.Write "<br/>"
                %>
                <a href="<%= VirtPath(gopage) & "?id=" & r(I)("SID") %>"><%= TR("Read more") %></a>
                <%
                Response.Write "</div></div>"
            
            Next
        End If
    End Sub
    
    
    Sub BBRenderLatestCenter(table, nLimit, sct, css, gopage, nImgs)
        Dim r, I, rImgs, nImg
        
        Set r = Database.DB.VExecute("SELECT * FROM " & table & " WHERE NOT DELETED AND LANGUAGE=$LANGUAGE AND " & SQLReadRights & " AND " & _
                                     sct & " ORDER BY CREATED DESC LIMIT " & nLimit,1,0,PageUILanguage)
        
        If r.Count > 0 Then
            For I = 1 To r.Count
                If nImgs > 0 Then
                    Set rImgs = GetAttachedImages(ConvertTo(vbLong,r(I)("SID")), nImgs)
                Else
                    Set rImgs = CreateCollection
                End If
                %>
                <div class="<%= css %>">
                <% If ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then %>
                    <div class="portalpict" style="height: 80px;background-repeat: no-repeat;background-position: left top; background-image: url(<%= VirtPath("/image.asp") & "?th=5&image=" & ConvertTo(vbLong, r(I)("IMAGE_SID")) %>);">
                    </div>
                    <h4><%= HTMLEncode(r(I)("CAPTION")) %></h4>
                <% Else %>
                    <h4><%= HTMLEncode(r(I)("CAPTION")) %></h4>
                <% End If %>
                
                <div class="briefcontent">
                <%
                If False And ConvertTo(vbLong, r(I)("IMAGE_SID")) <> 0 Then
                    %><img src="<%= VirtPath("/image.asp") & "?th=4&image=" & ConvertTo(vbLong, r(I)("IMAGE_SID")) %>" alt="" align="left" /><%
                End If
                RenderBriefBBText r(I)("BODY"), 80
                If rImgs.Count > 0 Then
                 %>
                    <div style="clear:both"></div>
                    <table width="100%" class="minithumbs">
                    <tr>
                        <td>&nbsp;</td>
                    <%
                    For nImg = 1 To rImgs.Count
                        %>
                        <td style="padding: 2px;" class="thumb">
                            <img border="0" src="<%= VirtPath("/image.asp") & "?th=4&image=" & rImgs(nImg)("SID") %>" alt="<%= HTMLEncode(rImgs(nImg)("CAPTION")) %>" title="<%= HTMLEncode(rImgs(nImg)("CAPTION")) %>"/>
                        </td>
                        <%
                    Next
                    %>
                    </tr>
                    </table>
                    <%
                End If
                Response.Write "<br/>"
                %>
                <a href="<%= VirtPath(gopage) & "?id=" & r(I)("SID") %>"><%= TR("Read more") %></a>
                <%
                Response.Write "</div></div>"
            
            Next
        End If
    End Sub

%>