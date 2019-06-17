function CmdsDemoTestApp_Main_View() {
	GenericViewBaseEx.apply(this, arguments);
	this.commander = new Commander(this.get_commandline());
	this.commander.outputevent.add(this.thisCall(function(source,text) { this.set_log(this.get_log() + "\r\n" + text);}));
}
CmdsDemoTestApp_Main_View.Inherit(GenericViewBaseEx, "CmdsDemoTestApp_Main_View");
CmdsDemoTestApp_Main_View.ImplementProperty("commandline", new InitializeStringParameter("","innewapp 'CmdsDemoTestApp2'"));
CmdsDemoTestApp_Main_View.ImplementActiveProperty("log", new InitializeStringParameter("",null));
CmdsDemoTestApp_Main_View.prototype.get_commander = function() {return this.commander;}
CmdsDemoTestApp_Main_View.prototype.onCmdline = function(evt, dc) {
	this.updateSources();
	//var op = new Operation(2000);
	//op.whencomplete().tell(function(){ alert("cmpl");});
	alert("cmd is:" + this.get_commandline());
	this.commander.load(this.get_commandline());
	var runop = this.commander.run(null);	
	runop.whencomplete().tell(this.thisCall(function(op) {
		if (op.isOperationSuccessful()) {
			this.set_log(this.get_log() + "\r\n Script completed successfuly, finish caries:" + op.getOperationResult());
		} else {
			this.set_log(this.get_log() + "\r\n Script completed with FAILURE, err:" + op.getOperationErrorInfo());
		}
	}));
}

