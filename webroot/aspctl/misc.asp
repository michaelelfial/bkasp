<%
    ' Misc.asp - contains miscellaneous helper routines.
    
    Function RegReplace(rexp, repl, str)
        Dim re
        Set re = New RegExp
        re.Pattern = rexp
        re.Global = True
        RegReplace = re.Replace(str,repl)
    End Function
    
    Function GetTextFile(fname, cp)
        Dim sf, f, c
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
		' Response.Write "file=" & BasePath & "<hr/>"
		On Error Resume Next
		Err.Clear
        Set f = sf.OpenFile(MapPath(fname),&H40)
		If Err.Number <> 0 Then
			On Error Goto 0
			Err.Raise 1,"GetTextFile","Failed file operation while openning " & MapPath(fname)
		End If
        c = ConvertTo(vbLong,cp)
        If c < 0 Then f.unicodeText = True
        If c > 0 Then f.CodePage = c
        GetTextFile = f.ReadText(-2)
        f.Close
    End Function

      Function BBCode(text,imgserver,imagepatch)
        BBCode = BBCodeEx(text,imgserver,imagepatch,Empty)
      End Function
      Function BBCodeNoImages(text)
        BBCodeNoImages = BBCodeEx(text, Empty, Empty, "BBCodeNoImageCallback")
      End Function
      
      Function BBCodeNoImageCallback(param, imgserver, imgTag)
        BBCodeNoImageCallback = ""
      End Function
      Function BBCodeDummyCallback(param, imgserver, imgTag)
        BBCodeDummyCallback = "<img class=""bbcode"" " & param & " src=""" & imgserver & imgTag & """/>"
      End Function
      Function BBCodeDummyCustomCallback(param, customTag)
        BBCodeDummyCustomCallback = ""
      End Function
      
      Function BBCodeEx(text,imgserver,imageParam,imageCallBack)
        BBCodeEx = BBCodeEx2(text,imgserver,imageParam,imageCallBack,Empty)
      End Function
      Function BBCodeEx2(text,imgserver,imageParam,imageCallBack,customCallback)
            Dim refICB, refCCB
            If IsEmpty(text) Or IsNull(text) Then
                BBCodeEx2 = ""
                Exit Function
            End If            
            If Len(imageCallBack) > 0 Then
                Set refICB = GetRef(imageCallBack)
            Else
                Set refICB = GetRef("BBCodeDummyCallback")
            End If
            If Len(customCallback) > 0 Then
                Set refCCB = GetRef(customCallback)
            Else
                Set refCCB = GetRef("BBCodeDummyCustomCallback")
            End If
            
            text = Replace(text,"<","&lt;")
            text = Replace(text,">","&gt;")
            text = RegReplace("(\r\n)|\r|\n","<br/>",text)
            Dim URLPattern
            ' URLPattern = "a-zA-Z0-9 \:\/\-\?\&\.\=\_\~\#\'"
            URLPattern = "^\]"
            Dim MAILPattern
            MAILPattern = URLPattern ' & "a-zA-Z0-9\.@\_\-"
            text = RegReplace("\[url\]([" & URLPattern & "]*)\[\/url\]", "<a class=""bbcode"" href=""$1"" target=""_blank"">$1</a>", text)
            text = RegReplace("\[url\=([" & URLPattern & "]*)\](.+?)\[\/url\]", "<a class=""bbcode"" href=""$1"" target=""_blank"">$2</a>", text)
            text = RegReplace("\[link\]([" & URLPattern & "]*)\[\/link\]", "<a class=""bbcode"" href=""$1"">$1</a>", text)
            text = RegReplace("\[link\=([" & URLPattern & "]*)\](.+?)\[\/link\]", "<a class=""bbcode"" href=""$1"">$2</a>", text)
            text = RegReplace("\[mail\]([" & MAILPattern & "]*)\[\/mail\]", "<a class=""bbcode"" href=""mailto:$1"">$1</a>", text)
            text = RegReplace("\[mail\=([" & MAILPattern & "]*)\](.+?)\[\/mail\]", "<a class=""bbcode"" href=""mailto:$1"">$2</a>", text)
            text = RegReplace("\[b\](.+?)\[\/b]","<strong class=""bbcode"">$1</strong>", text)
            text = RegReplace("\[i\](.+?)\[\/i\]", "<em class=""bbcode"">$1</em>", text)
            text = RegReplace("\[u\](.+?)\[\/u\]","<u class=""bbcode"">$1</u>",text)
            text = RegReplace("\[s\](.+?)\[\/s\]","<strike class=""bbcode"">$1</strike>",text)
            text = RegReplace("\[o\](.+?)\[\/o\]","<span class=""overline"" style=""text-decoration: overline;"">$1</span>", text)
            text = RegReplace("\[color=(.+?)\](.+?)\[\/color\]","<font style=""color: $1"" color=""$1"">$2</font>", text)
            ' text = RegReplace("\[size=(\d{1,2})\](.+?)\[\/size\]","<font class=""bbcode"" size=""$1"" style=""font-size: $1pt"">$2</font>", text)
            text = RegReplace("\[size=(\d)\](.+?)\[\/size\]","<font class=""bbcode"" size=""$1"">$2</font>", text)
            text = RegReplace("\[font=(.+?)\](.+?)\[\/font\]","<font class=""bbcode"" style=""font-family: $1;"">$2</font>", text)
            text = RegReplace("\[code\](.+?)\[\/code\]","<code class=""bbcode"">$1</code>", text)
            text = RegReplace("\[source\](.+?)\[\/source\]","<pre class=""bbcodesource"">$1</pre>", text)
            text = RegReplace("\[quote\](.+?)\[\/quote\]","<blockquote class=""bbcode"">$1</blockquote>", text)
            text = RegReplace("\[left\](.+?)\[\/left\]","<p class=""bbcode"" align=""left"" style=""text-align:left"">$1</p>", text)
            text = RegReplace("\[right\](.+?)\[\/right\]","<p class=""bbcode"" align=""right"" style=""text-align:right"">$1</p>", text)
            text = RegReplace("\[center\](.+?)\[\/center\]","<p class=""bbcode"" align=""center"" style=""text-align:center"">$1</p>", text)
            text = RegReplace("\[sup\](.+?)\[\/sup\]","<sup class=""bbcode"">$1</sup>", text)
            text = RegReplace("\[sub\](.+?)\[\/sub\]","<sub class=""bbcode"">$1</sub>", text)
            text = RegReplace("\[list\](.+?)\[\/list\]","<ul class=""bbcode"">$1</ul>", text)
            text = RegReplace("\[topics\](.+?)\[\/topics\]","<ol class=""bbcode"">$1</ol>", text)
            text = RegReplace("\[item\](.+?)\[\/item\]","<li class=""bbcode"">$1</li>", text)
            
            Dim matches, reImg1, reImg2, I, J
            Set reImg1 = New RegExp
            reImg1.Global = True
            reImg1.Pattern = "\[img\](.*?)\[\/img\]"
            Set reImg2 = New RegExp
            reImg2.Global = True
            reImg2.Pattern = "\[image[ ]*(.+?)\]"
            
            Set matches = reImg1.Execute(text)
            For I = matches.Count - 1 To 0 Step -1
                text = Replace(text,matches(I).Value,refICB(imageParam,imgserver,matches(I).SubMatches(0)))
            Next
            Set matches = reImg2.Execute(text)
            For I = matches.Count - 1 To 0 Step -1
                text = Replace(text,matches(I).Value,refICB(imageParam,imgserver,matches(I).SubMatches(0)))
            Next
            
            Set reImg2 = New RegExp
            reImg2.Global = True
            reImg2.Pattern = "\[object[ ]*(.+?)\]"
            Set matches = reImg2.Execute(text)
            For I = matches.Count - 1 To 0 Step -1
                text = Replace(text,matches(I).Value,refCCB(imageParam,matches(I).SubMatches(0)))
            Next
            
           BBCodeEx2 = text
      End Function

      Function BBCodeClean(text)
           If IsEmpty(text) Or IsNull(text) Then
               BBCodeClean = ""
               Exit Function
           End If
           text = Replace(text,"<","&lt;")
           text = Replace(text,">","&gt;")
           text = RegReplace("(\r\n)|\r|\n","<br/>",text)
           text = RegReplace("\[[^\]]*\]","", text)
           BBCodeClean = text
      End Function
      Function BBCodeCleanNoLines(text)
           If IsEmpty(text) Or IsNull(text) Then
               BBCodeCleanNoLines = ""
               Exit Function
           End If
           text = Replace(text,"<","&lt;")
           text = Replace(text,">","&gt;")
           text = RegReplace("(\r\n)|\r|\n"," ",text)
           text = RegReplace("\[[^\]]*\]","", text)
           BBCodeCleanNoLines = text
      End Function

%>