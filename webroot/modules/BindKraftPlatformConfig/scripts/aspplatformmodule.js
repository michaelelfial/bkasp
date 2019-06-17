// Platform module implementer for ASP Classic Bindkraft platform
(function() {
	$platformBaseModulesPath = "";
	$platformProcessorName = "/pack.asp";

	IPlatformUtility.moduleUrl = function (moduleName, readWrite, pack, nodePath) {
		var r = $platformProcessorName + "?$" + ((readWrite.charAt(0) == "w")?"write":"read") +
				"=" + $platformBaseModulesPath + moduleName + ":" + pack;
			if (nodePath != null) r += "/" + nodePath;
			return r;
	}
	IPlatformUtility.resourceUrl = function (moduleName, readWrite, restype, resPath) {
		// Read/write is totally ignored
		var r = null; // Null will cause errors - hopefuly
		if (moduleName == null || moduleName == "") {
			if (restype == "$images") {
				if (parseInt(resPath,10) + "" == resPath && !isNaN(parseInt(resPath,10))) {
					return "image.asp?image=" + resPath;
				} else {
					return "img/" + resPath;
				}
			} else if (restype == "$docs") {
				return "/Documentation/" + resPath;
			}
		}
		var moduleRoot = "/modules/" + moduleName + "/";
		
		switch (restype) {
			case "$template":
				r = moduleRoot + "templates/" + resPath;
			break;
			case "$view":
				r = moduleRoot + "views/" + resPath + ".html";
			break;
			case "$images":
				r = moduleRoot + "images/" + resPath;
			break;
			case "$docs":
				r = moduleRoot + "docs/" + resPath;
			break;
		}
		return r;
	}
})();