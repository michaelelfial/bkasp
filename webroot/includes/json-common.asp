<%
    ' Package:  UserAPI 
    ' Version:  2011-04-11
    ' File:     common.asp
    ' Description:
    '   Main include file for pages
    
    ' 1. ASP-CTL includes and UserAPI includes
    '   configuration.asp imports the UserAPI files in turn
    '   TO DO: You can remove features never used in the application
    '
    '   Note that the most frequently used features of the framework are automatically
    '   included by the aspctl-main.asp (the include directive is in the template page)
    '   The rest are listed here, because you may not need all of them.
%>
<!-- #include file="../aspctl/misc.asp" -->
<!-- #include file="../aspctl/aspctl-sesprefs.asp" -->
<!-- #include file="../aspctl/filestore.asp" -->
<!-- #include file="../aspctl/bincache.asp" -->
<!-- #include file="../aspctl/aspctl-encparams.asp" -->
<!-- #include file="../aspctl/client-misc.asp" -->
<!-- #include file="configuration.asp" -->
<!-- #include file="app-utils.asp" -->
<!-- #include file="json-utils.asp" -->
<!-- #include file="json-noms.asp" -->
<!-- #include file="userapi-json-utils.asp" -->
<!-- #include file="userapi-personal-dev.asp" -->
<%
    If cUseCustomHeader Then ASPCTLHeadContent = Configuration.CodeValue("CUSTOMHEADER",Null)
    ' No entries should be added below this line
%>