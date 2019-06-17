/*
	See the example bkconfig.js for mor information
*/


var JBCoreConstants = {
		CompileTimeLogTypes: {					// Which kind of messages to log (CompileTime console logger honors this, the others should too)
					log: true,
					warn: true,
					err: true,
					info: true,
					notice:true,
					trace:true
				},
		CompileTimeThrowOnErrors: false,
		AlwaysCalcBasePath: true, // Always set g_ApplicationBasePath to the base path calculated from the initial load URL, if false this will happen only if the variable is missing.
		DontSetPageBase: false	  // Do not create/replace the base element of the workspoace page and its href.
	};
