<%
	ClientScripts.RegisterFile "jquery.js", VirtPath("/scripts/jquery.js")
	ClientScripts.RegisterFile "raphael.js", VirtPath("/scripts/raphael.js")
	' ClientScripts.RegisterFile "jquery.tools.min.js", VirtPath("/scripts/jquery.tools.min.js")
	ClientScripts.RegisterFile "jquery-ui.js", VirtPath("/scripts/jquery-ui.js")
	ClientScripts.RegisterFile "jquery.ui.touch-punch.js", VirtPath("/scripts/jquery.ui.touch-punch.js")
	
	' ClientScripts.RegisterFile "jquery.ui.widget.js", VirtPath("/scripts/jquery.ui.widget.js")
	ClientScripts.RegisterFile "jquery.iframe-transport.js", VirtPath("/scripts/jquery.iframe-transport.js")
	ClientScripts.RegisterFile "jquery.fileupload.js", VirtPath("/scripts/jquery.fileupload.js")
	
	ClientScripts.RegisterFile "globalize.js", VirtPath("/scripts/Framework/globalize.js")
	ClientScripts.RegisterFile "culture.bg.js", VirtPath("/scripts/Localization/culture.bg.js")
	ClientScripts.RegisterFile "culture.de.js", VirtPath("/scripts/Localization/culture.de.js")
	ClientScripts.RegisterFile "stacktrace.js", VirtPath("/scripts/stacktrace.js") ' Added by Marin, for removing after
	ClientScripts.RegisterFile "jquery.qtip.js", VirtPath("/scripts/jquery.qtip-1.0.0-rc3.js")
	
	ClientScripts.RegisterFile "mmm.jquery.extensions.js", VirtPath("/scripts/Framework/mmm.jquery.extensions.js")
	ClientScripts.RegisterFile "mmm.utilities.js", VirtPath("/scripts/Framework/mmm.utilities.js")
	ClientScripts.RegisterFile "mmm.postMessage.js", VirtPath("/scripts/Framework/mmm.postMessage.js")
	ClientScripts.RegisterFile "mmm.pnotify.js", VirtPath("/scripts/Framework/mmm.pnotify.js")
	ClientScripts.RegisterFile "mmm.datetostringconverter.js", VirtPath("/scripts/Framework/mmm.datetostringconverter.js")
	
	
	ClientScripts.RegisterFile "mmm.core.js", VirtPath("/scripts/Framework/mmm.core.js")
	ClientScripts.RegisterFile "mmm.core.protocols.js", VirtPath("/scripts/Framework/mmm.core.protocols.js")
	ClientScripts.RegisterFile "mmm.core.classes.js", VirtPath("/scripts/Framework/mmm.core.classes.js")
	ClientScripts.RegisterFile "mmm.core.connectorhelpers.js", VirtPath("/scripts/Framework/mmm.core.connectorhelpers.js")
	ClientScripts.RegisterFile "mmm.core.classes.foreign.js", VirtPath("/scripts/Framework/mmm.core.classes.foreign.js")
	ClientScripts.RegisterFile "mmm.client.view.enums.js", VirtPath("/scripts/Framework/mmm.client.view.enums.js")
	ClientScripts.RegisterFile "mmm.client.view.protocols.js", VirtPath("/scripts/Framework/mmm.client.view.protocols.js")
	ClientScripts.RegisterFile "mmm.client.view.potatoes.js", VirtPath("/scripts/Framework/mmm.client.view.potatoes.js")
	ClientScripts.RegisterFile "mmm.client.view.messages.js", VirtPath("/scripts/Framework/mmm.client.view.messages.js")
	ClientScripts.RegisterFile "mmm.client.view.base.js", VirtPath("/scripts/Framework/mmm.client.view.base.js")
	ClientScripts.RegisterFile "mmm.client.windowing.protocols.js", VirtPath("/scripts/Framework/mmm.client.windowing.protocols.js")
	' keyboard comes here in order to be available in CWindowsBase
	ClientScripts.RegisterFile "mmm.client.keyboard.js", VirtPath("/scripts/Framework/mmm.client.keyboard.js")
	ClientScripts.RegisterFile "mmm.client.keyboard1.js", VirtPath("/scripts/Framework/mmm.client.keyboard1.js")
	ClientScripts.RegisterFile "mmm.client.keyboard2.js", VirtPath("/scripts/Framework/mmm.client.keyboard2.js")
	
	ClientScripts.RegisterFile "mmm.client.windowing.js", VirtPath("/scripts/Framework/mmm.client.windowing.js")
	ClientScripts.RegisterFile "mmm.client.windowing3.js", VirtPath("/scripts/Framework/mmm.client.windowing3.js")
	ClientScripts.RegisterFile "mmm.client.windowing1.js", VirtPath("/scripts/Framework/mmm.client.windowing1.js")
	ClientScripts.RegisterFile "mmm.client.windowing2.js", VirtPath("/scripts/Framework/mmm.client.windowing2.js")
	ClientScripts.RegisterFile "mmm.client.windowing.modeless.js", VirtPath("/scripts/Framework/mmm.client.windowing.modeless.js")
	
	ClientScripts.RegisterFile "mmm.client.view.sysformatters.js", VirtPath("/scripts/Framework/mmm.client.view.sysformatters.js")
	ClientScripts.RegisterFile "mmm.client.view.formatters.js", VirtPath("/scripts/Framework/mmm.client.view.formatters.js")
	ClientScripts.RegisterFile "mmm.client.view.lib.js", VirtPath("/scripts/Framework/mmm.client.view.lib.js")
	' keyboard was originally here
	ClientScripts.RegisterFile "mmm.client.view.misc.js", VirtPath("/scripts/Framework/mmm.client.view.misc.js")
	ClientScripts.RegisterFile "mmm.client.view.misc2.js", VirtPath("/scripts/Framework/mmm.client.view.misc2.js")
	ClientScripts.RegisterFile "mmm.client.view.graphics.js", VirtPath("/scripts/Framework/mmm.client.view.graphics.js")
	ClientScripts.RegisterFile "mmm.client.view.graphics1.js", VirtPath("/scripts/Framework/mmm.client.view.graphics1.js")
	ClientScripts.RegisterFile "mmm.client.view.graphics.optimized.js", VirtPath("/scripts/Framework/mmm.client.view.graphics.optimized.js")
	ClientScripts.RegisterFile "mmm.client.view.librule.js", VirtPath("/scripts/Framework/mmm.client.view.librule.js")
	ClientScripts.RegisterFile "mmm.client.view.behaviors.js", VirtPath("/scripts/Framework/mmm.client.view.behaviors.js")
	ClientScripts.RegisterFile "mmm.client.view.validatorrules.js", VirtPath("/scripts/Framework/mmm.client.view.validatorrules.js")
	ClientScripts.RegisterFile "mmm.client.view.bindlib.js", VirtPath("/scripts/Framework/mmm.client.view.bindlib.js")
	ClientScripts.RegisterFile "mmm.client.view.controls.js", VirtPath("/scripts/Framework/mmm.client.view.controls.js")
	ClientScripts.RegisterFile "mmm.client.view.generic.js", VirtPath("/scripts/Framework/mmm.client.view.generic.js")
	ClientScripts.RegisterFile "mmm.client.view.generic.conf.js", VirtPath("/scripts/Framework/mmm.client.view.generic.conf.js")
	
	ClientScripts.RegisterFile "mmm.client.system.js", VirtPath("/scripts/Framework/mmm.client.system.js")
	ClientScripts.RegisterFile "mmm.client.shell.main.js", VirtPath("/scripts/Framework/mmm.client.shell.main.js")
	ClientScripts.RegisterFile "mmm.client.shell.potatoes.js", VirtPath("/scripts/Framework/mmm.client.shell.potatoes.js")
	ClientScripts.RegisterFile "mmm.client.shell.messages.js", VirtPath("/scripts/Framework/mmm.client.shell.messages.js")
	
	ClientScripts.RegisterFile "mmm.framework.conf.js", VirtPath("/scripts/Framework/mmm.framework.conf.js")
	
	ClientScripts.RegisterFile "mmm.framework.tools.js", VirtPath("/scripts/Framework/mmm.framework.tools.js")
	ClientScripts.RegisterFile "mmm.framework.systools.js", VirtPath("/scripts/Framework/mmm.framework.systools.js")
	ClientScripts.RegisterFile "mmm.card_opener.js", VirtPath("/scripts/Cards/mmm.card_opener.js")
	ClientScripts.RegisterFile "mmm.sys_info.js", VirtPath("/scripts/Cards/mmm.sys_info.js")
	ClientScripts.RegisterFile "mmm.dev.works.js", VirtPath("/scripts/Cards/mmm.dev.works.js")
	
	ClientScripts.RegisterFile "mmm.card_export.js", VirtPath("/scripts/Cards/mmm.card_export.js")
	
	ClientScripts.RegisterFile "mmm.michael.temp.js", VirtPath("/scripts/Framework/mmm.michael.temp.js")
	
	' Experimental
	ClientScripts.RegisterFile "m4.workes.js", VirtPath("/scripts/Framework/m4.workes.js")
	' End experimental
	
	ClientScripts.RegisterFile "mmm.client.shell.boot.js", VirtPath("/scripts/Framework/mmm.client.shell.boot.js")
	
	' Accelerator enabled dropdown - for testing purposes
	ClientScripts.RegisterFile "mmm.client.view.controls1.js", VirtPath("/scripts/Framework/mmm.client.view.controls1.js")
%>