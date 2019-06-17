<%
    ' Various pre-configured parsers of HTML with loader
    
    Function ASPCTL_LoadHTML(sUrl)
        Dim Loader
        Set Loader = Server.CreateObject("Microsoft.XMLHTTP")
        Loader.Open "GET",sUrl, false
        Loader.Send Null
        If Loader.readyState = 4 Then
            ASPCTL_LoadHTML = Loader.responseText
        Else
            ASPCTL_LoadHTML = Empty
        End If
    End Function
    ' Returns an image object always - check if it is empty to determine if the operation is successful
    Function ASPCTL_LoadImage(sUrl)
        Dim Loader, wi
        Set wi = Server.CreateObject("newObjects.media.ImgManipulator")
        Set Loader = Server.CreateObject("Microsoft.XMLHTTP")
        Loader.Open "GET",sUrl, false
        Loader.Send Null
        If Loader.readyState = 4 Then
            wi.AddImage Loader.responseBody, Loader.getResponseHeader("Content-type")
        End If
        Set ASPCTL_LoadImage = wi
    End Function
    ' Loads file
    Function ASPCTL_LoadFile(sUrl,strm)
        Dim Loader, wi
        ASPCTL_LoadFile = False
        Set wi = Server.CreateObject("newObjects.media.ImgManipulator")
        Set Loader = Server.CreateObject("Microsoft.XMLHTTP")
        Loader.Open "GET",sUrl, false
        Loader.Send Null
        If Loader.readyState = 4 Then
            strm.WriteBin Loader.responseBody
            ASPCTL_LoadFile = True
        End If
    End Function
    
    Function StripMetaInfo(s)
        Dim parser, encoder, tree
        Set StripMetaInfo = Nothing
        Set parser = Server.CreateObject("newObjects.utilctls.HTMLParser")
        Set encoder = Server.CreateObject("newObjects.utilctls.HTMLEncoder")
        
        parser.AddTag "META" , True
        parser.AddTag "LINK" , True
        parser.KnownTagsOnly = True
        
        Set tree = parser.Parse(s)
    End Function

%>