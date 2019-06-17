<!-- 
	We are not currently using this, but in case we decide to put it in action again ...
	include file="../apps/jsloader.asp" 
-->
<%
MasterCancelProcessing = False

If PageRequiresAdmin Then
    If Not IsAdmin Then MasterCancelProcessing = True
End If
If PageRequiresLogin Then
    If Not IsLoggedOn Then MasterCancelProcessing = True
End If
' PageIsUserPage

PageStyleSheet = VirtPath("/jsonstyles.css")
AddLinkRel "stylesheet", VirtPath("/scripts/Source/framework/dependencies/jquery-ui/jquery-ui.css")
AddLinkRel "stylesheet", VirtPath("/apps/modules/DaemonConsumerApp/styles/styles.css")
ASPCTL_PageDocType = "<!DOCTYPE html>"
AddMeta "viewport", "width=device-width"



' MASTER CONTROLS
'Set uLogin = New UCLogin
'uLogin.LongView = True 'PageIsUserPage
'Set uGlobalErrorMessages = Create_UCErrorMessages(Empty)
'Set uGlobalErrorMessages.Database = Database

'Set hint = New UCHint
'hint.CloseImage = VirtPath("/img/icon-close.png")
'hint.OpenImage = VirtPath("/img/help-big.png")
'ApplySkin

' LoadJSDirs "/apps/scripts/;/examples/scripts/;/test/scripts/;" & customScriptsPath
' LoadJSDirsModular modularAppPath

' ClientScripts.RegisterBlock "syspath","g_ApplicationBasePath = '" & VirtPath("/") & "';"

' To remind you ;)  ClientScripts.RegisterFile "mnggpx.js", VirtPath("/scripts/Apps/mnggpx.js")
ClientScripts.RegisterFile "googlemapsv3", "http://maps.googleapis.com/maps/api/js?v=3.16&key=AIzaSyBwCok86DSomtmnsLass_w3vOe3kaopkJI&sensor=true"
 ' ClientScripts.RegisterFile "googlemapsv3", "http://maps.googleapis.com/maps/api/js?v=3.16&key=AIzaSyCKCpYJjIOxWrce5cDCAg-Qw_S76rgnN2g&sensor=true"

Sub RenderMaster
Begin_Page Empty ' This routine takes care for the whole head of the page - meta, keywords, link, title and so on.
' TO DO: Add the design below and place the standard elements where you want them
%>
      
	  <div id="container" style="width:100%;height:100%;background-color:#CCCC88;">
	  
	  </div>
	  <div style="display:none">
      <!-- #include file="json-control-calendartemplates.asp" -->
	  <!-- #include file="json-window-templates.asp" -->
	  <!-- #include file="json-control-templates.asp" -->
	  <!-- #include file="json-dynamic-field-templates.asp" -->
	  <!-- #include file="json-window-app-templates.asp" -->
	  </div>
      
      
<%
' TO DO: Uncomment temporarily if you need tracing and summary information to be displayed at the bottom of the page.
' DumpRequest
' hint.Render
' ClientScripts.RenderStandardAsyncCover
End_Page
End Sub

' If uLogin.LongView Then uLogin.MasterProcessPage

StandardMasterPageProcessing VirtPath("/")
%>
