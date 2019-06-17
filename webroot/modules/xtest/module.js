/* 
	APPs have to contain a module.js file in their scripts directory.
	It is recommended to not put any real javascript code, but only include directives.
	The directives can be also used in the other javascript files and they should
	form the javascript file dependency tree.
	
	The loader will traverse the directories and load the module.js and any files referred by it.
	This will guarantee that all the application code is loaded into the runtime environment and ready
	for launch/usage when necessary.
	
	MODULE may contain zero or more apps, utility classes and so on. The exact content will
	vary with module purpose. If the module doesn't need certain features supported by the standard directories,
	these directories can (and is recommended for clarity) be removed.
*/

//#using "./scripts/files.js"
