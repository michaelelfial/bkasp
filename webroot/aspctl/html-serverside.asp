<%
    ' This file is currently only a stub. Further developments will add more systematic 
    ' API for HTML/XHTML oriented functionality. The delay is caused by the need to evaluate the
    ' needs of certain API functions according to the conditions enforced by HTML oriented controls
    ' which are not ready yet.

    ' Misc HTML/XHTML oriented routines using the HTMLParser Light 1.x +
    
    Function GetTextFromHTML(htmlSource)
        Dim parser, enc, htmlTree, sf, mem
        Set parser = Server.CreateObject("newObjects.utilctls.HTMLParser")
        parser.ApplySettings "HTMLASP"
        parser.KnownTagsOnly = False
        Set enc = Server.CreateObject("newObjects.utilctls.HTMLEncoder")
        Set sf = Server.CreateObject("newObjects.utilctls.SFMain")
        Set mem = sf.CreateMemoryStream
        mem.unicodeText = True
        
        ' Parse the page
        Set htmlTree = parser.Parse(htmlSource)
        Set body = htmlTree.FindByInfo("body",1,1)(1)
        
        Set txts = body.FindByInfo("text/plain",1,100000)
        Dim fullText
        fullText = ""
        For I = 1 To txts.Count
            mem.WriteText txts(I)(1), 0
        Next
        mem.Pos = 0
        GetTextFromHTML = enc.Decode(mem.ReadText(-2))
    End Function

    
%>