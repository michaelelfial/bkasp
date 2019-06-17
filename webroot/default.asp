<%@ Language=VBScript %>
<!-- #include file="aspctl/aspctl-main.asp" -->
<%
	PageStyleSheet = VirtPath("/styles.css")
	AddLinkRel "stylesheet", VirtPath("/modules/BindKraft/Scripts/dependencies/jquery-ui/jquery-ui.css")
%>
<%
    PageTitle = "BkASP Workspace"
	ASPCTL_PageDocType = "<!DOCTYPE html>"
	AddMeta "viewport", "width=device-width"
	
	' BindKraft server side support includes
%>
<!-- #include file="includes/json-common.asp" -->
<!-- #include file="includes/scriptloader.asp" -->
<%

	' Tune the framework behavior - included first (before framework)
	RegisterScriptRoot "/","./bkconfig.js"
    ' Load main scripts - framework and any global tools
	RegisterScriptRoot "/modules/","Modules.dep"
%>
<%
    Function ProcessPage
        ProcessPage = True ' Set to false if you want to prevent the rendering and when you use Response.Redirect
        
        AddLinkRel "canonical", AbsoluteURL("/")
    End Function
    
    Sub RenderPage
        ' TO DO Implement the page rendering
        %>
		   <div id="container" style="width:100%;height:100%;background-color:#CCCC88;">
	  
		  </div>
		  <div style="display:none">
		  <!-- #include file="includes/json-control-calendartemplates.asp" -->
		  <!-- #include file="includes/json-window-templates.asp" -->
		  <!-- #include file="includes/json-control-templates.asp" -->
		  <!-- #include file="includes/json-dynamic-field-templates.asp" -->
		  <!-- #include file="includes/json-window-app-templates.asp" -->
		  </div>
        <%
    End Sub
%>
<%
If Not MasterCancelProcessing Then
	If ProcessPage Then 
        Begin_Page Empty ' This routine takes care for the whole head of the page - meta, keywords, link, title and so on.
		RenderPage
		End_Page
    ElseIf Len(ASPRedirect) > 0 Then
		Response.Redirect ASPREdirect
        
    Else
        ' Return nothing
    End If
Else
	Response.Redirect VirtPath("/error.html")
End If
%>

