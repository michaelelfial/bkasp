<html>

<head>
<!-- #include file="common.asp" -->
<% LangMetaTag %>
<title>Toolbar</title>
<link rel=stylesheet href="/stylestb.css" type="text/css">
<base target="DBManM">
<SCRIPT>
    function OnGo(info) {
        window.top.document.frames["DBManM"].location = info;
    }
    function OnEdit(info) {
        window.top.document.frames["DBManM"].focus();
        switch (info) {
            case "Undo":
                external.Undo();
            break;
            case "Cut":
                external.Cut();
            break;
            case "Copy":
                external.Copy();
            break;
            case "Paste":
                external.Paste();
            break;
            case "All":
                external.SelectAll();
            break;
        }
    }
</SCRIPT>
</head>
<body BGCOLOR="buttonface" text="buttontext" topmargin="0" leftmargin="0">
<TABLE CELLPADDING="1" CELLSPACING="1" style="border: 1px outset" HEIGHT="100%" WIDTH="100%"><TR>
    <TD VALIGN="MIDDLE"><A HREF="welcome.asp"><IMG ALT="Start page" SRC="BG.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE"><A HREF="open.asp"><IMG ALT="Open/create database" SRC="of.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE">&nbsp;</TD>
    <TD VALIGN="MIDDLE"><A TARGET="DBManC" HREF="dbobjects.asp"><IMG ALT="Reload objects list" SRC="refresh.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE">&nbsp;</TD>
    <TD VALIGN="MIDDLE">New:</TD>
    <TD VALIGN="MIDDLE"><A HREF="deftable.asp"><IMG ALT="New Table" SRC="table.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE"><A HREF="defview.asp"><IMG ALT="New View" SRC="view.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE"><A HREF="defindex.asp"><IMG ALT="New Index" SRC="index.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE"><A HREF="deftrigger.asp"><IMG ALT="New Trigger" SRC="trigger.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE"><A HREF="dbscheme-crdeltrigger.asp"><IMG ALT="New cascaded deletion trigger" SRC="deltrigger.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE">Tools:</TD>
    <TD VALIGN="MIDDLE"><A HREF="sqlconsole.asp"><IMG ALT="SQL Console" SRC="console.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE"><A HREF="dbscheme.asp"><IMG ALT="DB Schema" SRC="dbstruct.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE"><A HREF="help.asp"><IMG ALT="Help" SRC="help.gif" BORDER="0" hspace="1" vspace="1"></A></TD>
    <TD VALIGN="MIDDLE" ALIGN="RIGHT" WIDTH="100%"><IFRAME FRAMEBORDER="0" SCROLLING="no" NAME="DBManT2" SRC="toolbar2.asp" HEIGHT="100%" WIDTH="100%"></IFRAME></TD>
</TR></TABLE>
</body>

</html>
