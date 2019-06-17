function XTApp() {
	AppBaseEx.apply(this, arguments);
	this.setFinalAuthority(true);
	//this.$commandregister = new CommandRegister("XTApp");
	this.set_appcommands([
		new Command(this,this.onappcommand, {caption: "Main",visible: true, cmdline: "helo"})
	]);
}
XTApp.Inherit(AppBaseEx, "XTApp");
XTApp.Implement(IAppCommandsImpl);
XTApp.Implement(IPlatformUtilityImpl, "xtest");
XTApp.Implement(ISupportsEnvironmentContextImpl);

XTApp.Implement(ISupportsCommandRegisterExDefImpl,[
	{ name: "helo",alias: null,
		regexp: null,
		action: function(context, api) {
			alert("aaa");
			return null;
		},
		help: "switches to list view"
	}
]);
XTApp.Implement(ISupportsCommandContextImpl,"single");
XTApp.prototype.get_caption = function() {
	return "Playground";
};
XTApp.prototype.provideAsServices = new InitializeArray("Playground", ["PAppletStorage","XTApp","IAppCommands"]);
XTApp.prototype.GetAppInterface = function(iface) {
	var r = AppBaseEx.prototype.GetAppInterface.apply(this,arguments);
	if (r == null) {
		// implementations elsewhere
	}
	return r;
}

XTApp.prototype.get_commandregister = function() {
	return this.$commandregister;
}

XTApp.prototype.root = null;
XTApp.prototype.split = null;
XTApp.prototype.contents = null;
XTApp.prototype.work = null;

XTApp.prototype.initialize = function (callback, args) {
	//var op = new Operation(null, 10000);
	//op.CompleteOperation(true, null); // What are we going to return here (or not)?
	// return op;
	this.root = Shell.createStdAppWindow();
	this.placeWindow(this.root);
	this.root.set_windowrect(new Rect(50,50,600,500));
	this.root.updateTargets();
	buildop = this.$buildStructure();
	
	return buildop;
	
}
XTApp.prototype.run = function (apparg0) {
	
}
XTApp.prototype.shutdown = function () {
    var op = new Operation();
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	return op;
};
XTApp.prototype.windowDisplaced = function(w) {
	if (w == this.root) {
		this.ExitApp();
	}
}

/**
	Initializes the window structure and signals the op when finished.
*/
XTApp.prototype.$buildStructure = function() {
	var op_split = new Operation(null, 10000);
	var op_contents = new Operation(null, 10000);
	var op_work = new Operation(null, 10000);
	this.split = new TouchSplitterWindow(
		WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,
		{ 
			autocollapse: true,
			leftthreshold: 20, 
			rightthreshold: 80, 
			initial:25,
			on_Create: function() {
				op_split.CompleteOperation(true, null);
			}
		}
		
	);
	this.root.addChild(this.split);
	this.contents = new SimpleViewWindow(
		WindowStyleFlags.fillparent | WindowStyleFlags.visible | WindowStyleFlags.adjustclient,
		{
			loadOnCreate: true,
			url: this.moduleUrl("read","main","list"), //apps/pack.asp?$pread=apps/modules/xtest:main/list",
			on_Create: function() {
				op_contents.CompleteOperation(true, null);
			}
		}
	);
	this.split.setLeft(this.contents);
	var me = this;
	this.work = new SimpleViewWindow(
		WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,
		{
			loadOnCreate: true,
			url: this.moduleUrl("read","main","init"), // "/apps/pack.asp?$pread=apps/modules/xtest:main/init",
			on_Create: function() {
				op_work.CompleteOperation(true, null);
			}
		}
	);
	this.split.setRight(this.work);
	return new OperationAll(op_contents,op_split,op_work,10000);
}
XTApp.prototype.onOpenWorkView = function(e, dc) {
	this.openWorkView(dc.view);
}
XTApp.prototype.openWorkView = function(packet_nodepath) {
	var op_work = new Operation(null, 10000);
	var w = new SimpleViewWindow(
		WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient | WindowStyleFlags.visible,
		{
			loadOnCreate: true,
			url: "/pack.asp?$pread=xtest:" + packet_nodepath,
			on_Create: function(msg) {
				op_work.CompleteOperation(true, msg.target);
			}
		}
	);
	if (this.work != null) {
		this.work.closeWindow();
	}
	this.work = w;
	this.split.setRight(w);
	
	return op_work;
}
// Functions we are going to use in the commands (or directly make them commands

//SYNC

XTApp.prototype.onappcommand = function(sender,dc_uicommand,binding,param) {
	var commander = new Commander(dc_uicommand.get_cmdline(), this.get_commandcontext());
	var op = commander.run(10000);
	op.whencomplete().tell(function(op) {
		if (op.isOperationSuccessful()) {
			alert("success");
		} else {
			alert("failure");
		}
	});
}
XTApp.prototype.runcmdline = function(cmdline) {
	var commander = new Commander(cmdline, this.get_commandcontext());
	var op = commander.run(10000);
	op.whencomplete().tell(function(op) {
		if (op.isOperationSuccessful()) {
			alert("success");
		} else {
			alert("failure");
		}
	});
}


