// htmlbox toolbar routines
function htmlBox_doTbCmd(boxId, strCmd, strValue) {
    var box = document.frames[boxId];
    box.focus();
    var oSel = box.document.selection.createRange()
    var sType = box.document.selection.type	
    var oTarget = (sType == "None" ? box.document : oSel)
    
    if (strCmd == "justify") {
    	strCmd = strCmd + strValue;
    	strValue = "";
    }
    if (strCmd == "DialogLink") {
    	oTarget.execCommand("CreateLink",true);
    	box.focus();
    	return true;
    } 
    if (strCmd == "DialogExternalImage") {
    	document.execCommand("InsertImage",true);
    	box.focus();
    	return true;
    }
    oTarget.execCommand(strCmd, false, strValue)
    
    box.focus()
    return true
}