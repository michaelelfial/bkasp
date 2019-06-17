// TODO: Tranlate this to the new syntax
// Shortcuts
System.ShellShortcuts().regKeylaunchShortcut("T", "launchapp NotchShellApp");
System.ShellShortcuts().regAppShortcut("NotchShell", "NotchShell", "launchapp NotchShell");
System.ShellShortcuts().regStartShortcut("NotchShell", "launchone NotchShell", "NotchShell self start (Stupid I know)").icon("notchshell","run.svg");

(function(init) {
	init.commandUrlGlobal(function(g) {
		g.prefix("$run");
		g.script("systools","launchone SysToolsApp");
	});
	init.commandUrlAlias("sys", function(a) {
		a.appclass("SysToolsApp").clear().addscript("systools").addcommands("alert 'hello'");
		
	});
	init.commandUrlAlias("init", function(a) {
		a.clear();
	});
})(BkInit);