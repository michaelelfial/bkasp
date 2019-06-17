<!-- #include file="common.asp" -->
<%
    Dim lastTable
    lastTable = ""
    
    Sub PlaceHeader(newR, rowKey)
        If rowKey = lastTable Then
            Exit Sub
        End If
        lastTable = rowKey
        Dim I
        %>
        </TABLE>
        <table border="0" bgcolor="#000000" cellspacing="1">
        <tr>
            <% For I = 1 To newR.Count %>
                <th bgcolor="#406080" nowrap><font color="#FFFFFF"><%= newR.Key(I) %></font></th>
            <% Next %>
        </tr>
        <tr>
            <% For I = 1 To newR.Count %>
                <th bgcolor="#8080F0" nowrap><font color="#FFFFFF"><%= newR.Info(I) %></font></th>
            <% Next %>
        </tr>
        <%        
    End Sub
    
If db.IsOpened Then
%>    
    
    
    <html>
    
    <head>
    <% LangMetaTag %>
    <meta name="GENERATOR" content="Microsoft FrontPage 4.0">
    <meta name="ProgId" content="FrontPage.Editor.Document">
    <link REL="stylesheet" HREF="/styles.css">
    <title>DB Sample</title>
    <SCRIPT>
        function onShortcutMenu() {
            if (event.button != 2) return;
            external.DisplayPopupMenu(external.Menus.MenuTree("CtxMenus")("Item1")("CtxMenuEditSQL"),event.screenX,event.screenY);
        }
    </SCRIPT>
    </head>
    
    <body topmargin="0" leftmargin="0">
    <FORM METHOD="POST" ACTION="<%= Request.ServerVariables("SCRIPT_NAME") %>">
        <table border="0" width="100%" bgcolor="#004080" cellspacing="1">
          <tr>
            <td width="100%" COLSPAN="2" NOWRAP ALIGN="CENTER"><B><FONT COLOR="#FFFFFF">SQL Console</FONT></B></td>
          </tr>
          <tr>
            <td width="100%" bgcolor="#FFFFFF" COLSPAN="2" align="center" NOWRAP>Write a query<br>
              <%
                QUERY = Request("QUERY")
                If QUERY = "" Then QUERY = Request("NOTE")
              %>
              <textarea onMouseUp="onShortcutMenu()"
                NAME="QUERY" 
                rows="12" cols="100" 
                class="normalFont" style="border: 1px inset; width: 100%"><%= QUERY %></textarea><BR>
                <I><FONT COLOR="#808000">Right click in the query to invoke the helper menu.</FONT></I>
              </td>
          </tr>
          <tr>
            <td WIDTH="50%" bgcolor="#FFFFFF" align="left" VALIGN="TOP" COLSPAN="1" NOWRAP>
                Show records from number: <input class="smallFont" style="border: 1px inset" type="TEXT" NAME="RFIRST" VALUE="1" SIZE="10">
            </TD>
            <td WIDTH="50%" bgcolor="#FFFFFF" align="left" VALIGN="TOP"  COLSPAN="1" NOWRAP>
                Show <input type="TEXT" NAME="RCOUNT" VALUE="0" class="smallFont" style="border: 1px inset" SIZE="10"> records max (0 - all).
            </td>
          </tr>
          <tr>
            <td bgcolor="#FFFFFF" align="center" VALIGN="TOP"  COLSPAN="2" NOWRAP>
                <I><FONT COLOR="#808000">If you expect large results set some limits. This can be used also for paged results.</FONT></I>
            </td>
          </tr>
          <tr>
            <td width="100%" COLSPAN="2" bgcolor="#FFFFFF" align="center" NOWRAP><input type="submit" NAME="Execute" value="Execute">
            &nbsp;<input type="submit" NAME="SaveNote" value="Save as note">
            </td>
          </tr>
        </table>
    </FORM>
    <% 
        If Request.ServerVariables("REQUEST_METHOD") = "POST" And Request("SaveNote").Count > 0 Then 
            EnsureTableExistsSysNotes
            db.VExecute "INSERT INTO SysDBMan_Notes (NOTE) VALUES ($1)",1,0,CStr(Request("QUERY"))
            %>
            <SCRIPT>
            window.top.frames["DBManC"].location = "dbobjects.asp"
            </SCRIPT>
            <%
        End If 
    %>
    <% If Request.ServerVariables("REQUEST_METHOD") = "POST" And Request("Execute").Count > 0 Then %>
        
          <%
            On Error Resume Next
            Set r = db.Execute(Request("QUERY"),Request("RFIRST"),Request("RCOUNT"))
            If Err.Number <> 0 Then
                %>
                <table border="0" bgcolor="#C0C0C0" cellspacing="1">
                <tr>
                <td VALIGN="TOP" width="100%" bgcolor="#FFFF00">
                    Error occurred: <B><%= db.LastError %></B>
                </td>
                </tr>
                </table>
                <%
            Else
                On Error Goto 0
                If r.Count > 0 Then
                %>
                  <table border="0" bgcolor="#000000" cellspacing="1">
                    <%
                        For I = 1 To r.Count
                            PlaceHeader r(I), r.Key(I)
                            %>
                            <tr>
                                <% For J = 1 To r(I).Count %>
                                    <% Select Case UCase(r(I).Info(J))
                                           Case "INTEGER" %>
                                            <td VALIGN="TOP" bgcolor="#FFFFFF"><%= su.Sprintf("%d",r(I)(J)) %></td>
                                        <% Case "REAL" %>
                                            <td VALIGN="TOP" bgcolor="#FFFFFF"><%= su.Sprintf("%M",r(I)(J)) %></td>
                                        <% Case "TEXT" %>                                                                
                                            <td VALIGN="TOP" bgcolor="#FFFFFF"><%= su.Sprintf("%s",r(I)(J)) %></td>
                                        <% Case "BLOB" %>                                                                
                                            <td VALIGN="TOP" bgcolor="#FFFFFF">(BLOB)</td>
                                        <% Case "NULL" %>                                                                
                                            <td VALIGN="TOP" bgcolor="#FFFFFF">NULL</td>
                                        <% Case Else %>
                                            <td VALIGN="TOP" bgcolor="#FFFFFF"><%= su.Sprintf("%Na",r(I)(J)) %></td>
                                    <% End Select %>
                                <% Next %>
                            </tr>
                            <%
                        Next
                    %>                    
                  </table>
                <% Else %>
                    Empty result. Your query have returned an empty set.
                <% End If%>
                Last insert row ID=<%= r.Info %>
            <% End If %>
    <% End If %>
    <p>Warning! The column types reported may not correspond to the declared types, because of a limitation of the SQLite3 engine.</p>
    
    </body>
    
    </html>
<% Else %>
    <html>
    
    <head>
    <% LangMetaTag %>
    <link rel=stylesheet href="/styles.css" type="text/css">
    <title>DBObjects</title>
    </head>
    
    <body topmargin="0" leftmargin="0">
    <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
    <TR>
        <TD COLSPAN="2">
        Database not opened.
        </TD>
    </TR>
    <TR>
        <TD COLSPAN="2">
        <IMG SRC="of.gif"><A TARGET="DBManM" HREF="open.asp">Click to open or create</A>
        </TD>
    </TR>
    </TABLE>
    </body>
    
    </html>
<% End If %>