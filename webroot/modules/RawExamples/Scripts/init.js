

/*
    Standard RawExamples for BindKraftJS
	
	Variety of example minimally dependent on the server side capabilities.
	
	Remarks:
		These examples are reffered by the documentation. This module does not include examples that by nature require
		the server to support advanced features or includes replacements that mock/substitute client side implementation
		that closely resembles the demonstrated behavior (not perfectly - please read any accompaning notes)

*/
(function (init) {
    // For better management - some defines
    // These are defined for the most typical cases, change or define more if needed.
    var modulename = "RawExamples";

    // The module may contain one or more than one app, or none - create more if needed
    var appclass = "StdRawExamples";
    
    // The name of the app in memory file name compatible fashion
    var appname = "BindKraftJS raw examples";

    // Longer (100-300 characters recommended) description of the  (main) app
    var appdesc = "Collection of raw examples refered by the documentation. All examples are minimally dependent on the server side capabilities";

    // The app icon file
    var iconfile = "listview.png";
	
	init.StartMenu(function(menu) {
        // Typical entry
            menu.add(appname,"launchone " + appclass)
            .icon(modulename, iconfile) // optional
            .appclass(appclass) // optional
            .description(appdesc); // optional
    });

})(BkInit);