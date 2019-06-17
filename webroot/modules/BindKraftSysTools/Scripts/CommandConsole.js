function CommandConsole() {
	ViewBase.apply(this, arguments);
	this.commands.push(new Command(this, this.OnClear, { caption: "Clear", modulename: "systools",image: "$images/delete__icon.png", visible: true }));
	this.commands.push(new Command(this, this.OnHelp, { caption: "Help", modulename: "systools",image: "$images/help.png", visible: true }));
}
CommandConsole.Inherit(ViewBase, "CommandConsole");
CommandConsole.listCommands = function() {
	var arr = CommandProccessor.commandsRegister;
	var s = "";
	var a = [];
	for (var i = 0; i < arr.length; i++) {
		s = arr[i].commandName + " " + (arr[i].alias || "(no alias)") + " " + (arr[i].help?arr[i].help:"(no help available)") + "\n";
		a.push({ output: s, cmd: arr[i].commandName});
	}
	// for (var i = 0; i < arr.length; i++) {
		// s += arr[i].commandName + " " + (arr[i].alias || "(no alias)") + " " + (arr[i].help?arr[i].help:"(no help available)") + "\n";
	// }
	return a;
}
CommandProccessor.register("commands", "help", CommandConsole.listCommands, "Lists the registered/available commands and their help (if available).");
CommandProccessor.register("cmd", "shell", function(tokens) { 
	Shell.openWindowedView({url: "post:/sbin/systools.asp", data: {view: "cmdconsole"}}); 
	while (tokens != null && tokens.length > 0) {
		CommandProccessor.Default.executeCommand(tokens);
	}
}, "Opens a new shell window.");
CommandConsole.ImplementActiveProperty("cmdline", new InitializeStringParameter("Command line from the UI", ""));
CommandConsole.ImplementProperty("timecolor", new InitializeNumericParameter("Color for time stamps", 0xED0000));
CommandConsole.ImplementProperty("cmdcolor", new InitializeNumericParameter("Color for time stamps", 0x4F0004));
CommandConsole.ImplementProperty("outputcolor", new InitializeNumericParameter("Color for time stamps", 0xFFF000));
CommandConsole.ImplementActiveProperty("log", new InitializeArray("Logged outputs"));

CommandConsole.prototype.changecmdevent = new InitializeEvent("Signals to change the command");

CommandConsole.prototype.get_caption = function() {
	return "Command console";
}
CommandConsole.prototype.OnClear = function(e, dc, bind) {
	this.set_log([]);
}
CommandConsole.prototype.OnHelp = function() {
	this.set_cmdline("help");
	this.OnRunCmd();
}
CommandConsole.prototype.OnRunCmd = function(e, dc, bind) {
	var v = null, xerror = null, me = this;
	try {
		v = CommandProccessor.Default.executeCommand(this.get_cmdline());
	} catch (err) {
		xerror = err.message;
	}
	if (v != null) {
		if (typeof v == "string") {
			this.PushLine(v);
			// this.get_log().push({ date: new Date(), output: "" + v, cmd: this.get_cmdline()});
		} else if (BaseObject.is(v,"Array")) {
			v.Each(function(idx, item) {
				me.PushLine(item);
				//me.get_log().push({ date: new Date(), output: "" + item, cmd: this.get_cmdline()});
			});
		} else {
			this.PushLine(v);
		}
	} else {
		this.PushLine("command retunred null." + ((xerror != null)?("Error occured" + xerror):""));
	}
	this.log_changed.invoke(this, v);
	$(this.root).scrollTop(this.child("logview").outerHeight());
}
CommandConsole.prototype.PushLine = function(v) {
	if (v != null) {
		if (typeof v == "string") {
			this.get_log().push({ date: new Date(), output: "" + v, cmd: null});
		} else if (typeof v == "object") {
			this.get_log().push({ date: new Date(), output: "" + v.output, cmd: v.cmd || null});
		}
	}
}
CommandConsole.prototype.OnClickCmd = function(e,dc) {
	if (dc != null && dc.cmd != null) {
		this.set_cmdline(dc.cmd);
		this.changecmdevent.invoke(this,dc);
	}
}
CommandConsole.prototype.OnRunCmdEnter = function(e,dc,bind) {
	if (e.which == 13) {
		this.OnRunCmd(e,dc,bind);
	}
}
CommandConsole.prototype.FocusCmdLine = function() {
	this.child("cmdline").focus();
}