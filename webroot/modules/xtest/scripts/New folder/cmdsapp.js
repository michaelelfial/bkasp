function CmdsDemoTestApp() {
	AppBaseEx.apply(this, arguments);
	this.setFinalAuthority(true);
	//this.$commandregister = new CommandRegister("CmdsDemoTestApp");
	this.set_appcommands([
new Command(this,this.onappcommand, {caption: "Main",visible: true, cmdline: "main"}),
		new Command(this,this.onappcommand, {caption: "List",visible: true, cmdline: "itemlist"}),
		new Command(this,this.onappcommand, {caption: "Item",visible: true, cmdline: "viewitem"})
	]);
}
CmdsDemoTestApp.Inherit(AppBaseEx, "CmdsDemoTestApp");
CmdsDemoTestApp.Implement(IAppCommandsImpl);
CmdsDemoTestApp.Implement(ISupportsEnvironmentContextImpl);
/*
CmdsDemoTestApp.Implement(ISupportsCommandRegisterImpl,
	function(reg) {
		reg.register("itemlist", null,null, function(context,api) {
				var app = context.get_application();
				app.$viewstate("list");
			},"switches to list view");
		reg.register("viewitem", null,null, function(context,api) {
				var app = context.get_application();
				app.$viewstate("item");
			},"switches to item view and selects the item specified in the arg");
		reg.register("main", null,null, function(context,api) {
				var app = context.get_application();
				app.$viewstate("main");
			},"switches to the main app view");
	}
);
*/

CmdsDemoTestApp.Implement(ISupportsCommandRegisterExDefImpl,[
	{ name: "itemlist",alias: null,
		regexp: null,
		action: function(context, api) {
			this.$viewstate("list");
			this.list.currentView.set_data(this.get_sampledata());
		},
		help: "switches to list view"
	},		
	{ name: "main",alias: null,
		regexp: null,
		action: function(context, api) {
			this.$viewstate("main");
		},
		help: "switches to main"
	},		
	{ name: "viewitem",alias: null,
		regexp: null,
		action: function(context, api) {
			this.$viewstate("item");
			var param = api.pullNextToken();
			if (typeof param == "number") {
				this.item.currentView.set_data(this.get_sampledata()[param]);
			} else {
				this.item.currentView.set_data(null);
			}
			
		},
		help: "switches to item view"
	}
]);

CmdsDemoTestApp.Implement(ISupportsCommandContextImpl,"single");
//CmdsDemoTestApp.Implement(IServiceHub);
CmdsDemoTestApp.registerShellCommand("cmdtest",null,function(args) {
	var arg = args.consumeToken();
	Shell.launchAppWindow("CmdsDemoTestApp", null, arg);
},"Framework development work gorund");
CmdsDemoTestApp.prototype.get_caption = function() {
	return "Commands imp";
};
CmdsDemoTestApp.prototype.provideAsServices = new InitializeArray("Demo app services", ["PAppletStorage","CmdsDemoTestApp","IAppCommands"]);
CmdsDemoTestApp.prototype.GetAppInterface = function(iface) {
	var r = AppBaseEx.prototype.GetAppInterface.apply(this,arguments);
	if (r == null) {
		// implementations elsewhere
	}
	return r;
}
// We want to know our windows - we will record them in these properties. This makes our work with them easier (no need to obtain them each time from others).
// CmdsDemoTestApp.prototype.GetServiceHub = function() { // Sync hub, self hub
	// var op = new Operation();
	// op.CompleteOperation(true,this);
	// return op;
// }
// CmdsDemoTestApp.ImplementReadProperty("environment", new InitializeObject("EnvironmentContext instance","EnvironmentContext"));
// CmdsDemoTestApp.prototype.$commandregister = new CommandReg("CmdsDemoTestApp");
// (function(reg) {
	// reg.register("itemlist", null,null, function(context,api) {
			// var app = context.get_application();
			// app.$viewstate("list");
		// },"switches to list view");
	// reg.register("viewitem", null,null, function(context,api) {
			// var app = context.get_application();
			// app.$viewstate("item");
		// },"switches to item view and selects the item specified in the arg");
	// reg.register("main", null,null, function(context,api) {
			// var app = context.get_application();
			// app.$viewstate("main");
		// },"switches to the main app view");
	
// })(CmdsDemoTestApp.prototype.$commandregister);

CmdsDemoTestApp.prototype.get_commandregister = function() {
	return this.$commandregister;
}


CmdsDemoTestApp.prototype.main = null;
CmdsDemoTestApp.prototype.list = null;
CmdsDemoTestApp.prototype.item = null;

CmdsDemoTestApp.prototype.initialize = function (callback, args) {
	//var op = new Operation(null, 10000);
	//op.CompleteOperation(true, null); // What are we going to return here (or not)?
	// return op;
	return buildop = this.$buildStructure();
	
}
CmdsDemoTestApp.prototype.run = function (apparg0) {
	
}
CmdsDemoTestApp.prototype.appshutdown = function () {
    var op = new Operation();
	op.CompleteOperation(true, null); // What are we going to return here (or not)?
	return op;
};

/**
	Initializes the window structure and signals the op when finished.
*/
CmdsDemoTestApp.prototype.$buildStructure = function() {
	var op1 = new Operation(null, 10000);
	var op2 = new Operation(null, 10000);
	var op3 = new Operation(null, 10000);
	this.main = new SimpleViewWindow(
		WindowStyleFlags.fillparent | WindowStyleFlags.visible | WindowStyleFlags.adjustclient,
		{
			loadOnCreate: true,
			url: "/apps/pack.asp?$pread=apps/modules/appforcmds:main/init",
			// url: "/apps/pack.asp?$pread=apps/modules/dev:main/capture"
			on_Create: function() {
				op1.CompleteOperation(true, null);
			}
		}
	);
	this.placeWindow(this.main);
	this.list = new SimpleViewWindow(
		WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient,
		{
			loadOnCreate: true,
			url: "/apps/pack.asp?$pread=apps/modules/appforcmds:main/list",
			// url: "/apps/pack.asp?$pread=apps/modules/dev:main/capture"
			on_Create: function() {
				op2.CompleteOperation(true, null);
			}
		}
	);
	this.placeWindow(this.list);
	this.item = new SimpleViewWindow(
		WindowStyleFlags.fillparent | WindowStyleFlags.adjustclient,
		{
			loadOnCreate: true,
			url: "/apps/pack.asp?$pread=apps/modules/appforcmds:main/item",
			// url: "/apps/pack.asp?$pread=apps/modules/dev:main/capture"
			on_Create: function() {
				op3.CompleteOperation(true, null);
			}
		}
	);
	this.placeWindow(this.item);
	this.$viewstate("main");
	return new OperationAll(op1,op2,op3,10000);
	
}
// Functions we are going to use in the commands (or directly make them commands

//SYNC
CmdsDemoTestApp.prototype.$viewstate = function(focuson) {
	// Hide all first then show the specified
	[this.main,this.list,this.item].Each(function(idx, wnd) {
		wnd.setWindowStyles(WindowStyleFlags.visible, "reset");
	});
	switch (focuson) {
		case "item":
			this.item.setWindowStyles(WindowStyleFlags.visible, "set");
			InfoMessageQuery.emit(this.item, "Test item",InfoMessageTypeEnum.warning);
		break;
		case "list":
			this.list.setWindowStyles(WindowStyleFlags.visible, "set");
			InfoMessageQuery.emit(this.list, "Test list",InfoMessageTypeEnum.warning);
		break;
		case "main":
		default:
			this.main.setWindowStyles(WindowStyleFlags.visible, "set");
			InfoMessageQuery.emit(this.main, "Test main",InfoMessageTypeEnum.warning);
	}
}
CmdsDemoTestApp.prototype.onappcommand = function(sender,dc_uicommand,binding,param) {
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
CmdsDemoTestApp.prototype.runcmdline = function(cmdline) {
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
CmdsDemoTestApp.prototype.get_sampledata = function() {
	return this.$sampledata;
}

CmdsDemoTestApp.prototype.$sampledata = [];
(function(data) {
	for (var i =0; i <100; i++) {
		data.push({
			name: "Item " + i,
			id: i,
			desc: "This is Item " + i +"'s description",
			amount: Math.random()
		});
	}
})(CmdsDemoTestApp.prototype.$sampledata);
