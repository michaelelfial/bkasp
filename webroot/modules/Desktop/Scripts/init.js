System.BootFS().writeMasterBoot("\
startshell \
createworkspace \
'bindkraft/workspacewindowtemplate' \
initculture 'en' \
initframework \
set 'topmodule' 'Desktop' \
runurlcommands \
inithistory \
gcall 'system/startapps'");
System.BootFS().writeScript("system/startapps","launchapp NotchShellApp");// launchapp XTApp");



