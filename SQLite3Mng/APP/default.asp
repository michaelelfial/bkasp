<html>

<head>
<title>SQLite3 DB Manager</title>
<SCRIPT SRC="menucompiler.asp?menuname=MainMenu&menufile=mainmenu.txt&createvariables=1"></SCRIPT>
<SCRIPT SRC="menucompiler.asp?menuname=CtxMenus&menufile=ctxmenus.txt&createvariables=1"></SCRIPT>
<SCRIPT>
    function initPage() {
        external.MainMenu = MainMenu;
    }
    function unInitPage() {
        external.MainMenu = null;
        external.Menus.MenuTree.Subs.Clear();
    }
    function OnFileAction(sender) {
        switch (sender.info) {
            case "Open":
                top.frames("DBManM").location = "open.asp";
            break;
            case "ImpExp":
                top.frames("DBManM").location = "impexp.asp";
            break;
            case "Home":
                top.frames("DBManM").location = "welcome.asp";
            break;
            case "Exit":
                external.Exit();
            break;
        }
    }
    function OnNavMain(sender) {
        top.frames("DBManM").location = sender.Info;
    }
    function OnNavigateTop(sender) {
        window.location = sender.Info;
    }
    function OnNavigateNew(sender) {
        window.open(sender.Info);
    }
    function OnEdit(sender) {
        switch (sender.info) {
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
    function OnInsert(sender) {
        var d = window.frames["DBManM"].document
        var tr = d.selection.createRange();
        tr.text = sender.info;
    }
    function OnOpenTable(sender) {
        document.frames["DBManM"].location = "table.asp?Object=" + sender.Info;
    }
    function OnOpenView(sender) {
        document.frames["DBManM"].location = "view.asp?Object=" + sender.Info;
    }
    function OnOpenIndex(sender) {
        document.frames["DBManM"].location = "defindex.asp?Object=" + sender.Info;
    }
    function OnOpenTrigger(sender) {
        document.frames["DBManM"].location = "deftrigger.asp?Object=" + sender.Info;
    }
    function OnOpenNote(sender) {
        document.frames["DBManM"].location = "note.asp?NOTEID=" + sender.Info;
    }
    function OnDefTable(sender) {
        document.frames["DBManM"].location = "deftable2.asp?Object=" + sender.Info;
    }
    function OnDefTable2(sender) {
        document.frames["DBManM"].location = "deftable.asp?Object=" + sender.Info;
    }
    function OnDefTableIndex(sender) {
        document.frames["DBManM"].location = "defindex2.asp?Object=" + sender.Info;
    }
    function OnDefView(sender) {
        document.frames["DBManM"].location = "defview.asp?Object=" + sender.Info;
    }
    function OnDefIndex(sender) {
        document.frames["DBManM"].location = "defindex.asp?Object=" + sender.Info;
    }
    function OnDefTrigger(sender) {
        document.frames["DBManM"].location = "deftrigger.asp?Object=" + sender.Info;
    }
    function OnDropTable(sender) {
        document.frames["DBManM"].location = "drop.asp?Type=Table&Object=" + sender.Info;
    }
    function OnDropView(sender) {
        document.frames["DBManM"].location = "drop.asp?Type=View&Object=" + sender.Info;
    }
    function OnDropIndex(sender) {
        document.frames["DBManM"].location = "drop.asp?Type=Index&Object=" + sender.Info;
    }
    function OnDropTrigger(sender) {
        document.frames["DBManM"].location = "drop.asp?Type=Trigger&Object=" + sender.Info;
    }
    function OnDropNote(sender) {
        document.frames["DBManM"].location = "dropnote.asp?NOTEID=" + sender.Info;
    }
    function OnCopyQry(sender) {
        document.frames["DBManM"].location = "predefqry.asp?Type=CopyTable&Object=" + sender.Info;
    }
    function OnGetDataQry(sender) {
        document.frames["DBManM"].location = "predefqry.asp?Type=GetData&Object=" + sender.Info;
    }
    function OnSelQry(sender) {
        document.frames["DBManM"].location = "predefqry.asp?Type=Select&Object=" + sender.Info;
    }
    function OnUpdQry(sender) {
        document.frames["DBManM"].location = "predefqry.asp?Type=Update&Object=" + sender.Info;
    }
    function OnInsQry(sender) {
        document.frames["DBManM"].location = "predefqry.asp?Type=Insert&Object=" + sender.Info;
    }
    function OnDelQry(sender) {
        document.frames["DBManM"].location = "predefqry.asp?Type=Delete&Object=" + sender.Info;
    }
</SCRIPT>
</head>

<frameset framespacing="2" rows="30,*" onLoad="initPage()" onUnload="unInitPage()">
  <frame name="DBManT" scrolling="no" noresize target="main" marginwidth="2" marginheight="2" src="toolbar.asp">
  <frameset cols="200,*" framespacing="2">
    <frame name="DBManC" marginwidth="2" marginheight="2" scrolling="auto" src="dbobjects.asp">
    <frame name="DBManM" scrolling="auto" marginwidth="2" marginheight="2" src="welcome.asp" target="main">
  </frameset>
  <noframes>
  <body topmargin="0" leftmargin="0">

  <p>This page uses frames, but your browser doesn't support them.</p>

  </body>
  </noframes>
</frameset>

</html>
