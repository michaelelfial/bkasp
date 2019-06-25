<div style="display:none">

<div id="progress_indicator">
    <table style="width:100%;height:100%"><tr><td style="text-align:center;vertical-align: middle"><img src="<%= VirtPath("/img/loading_card.gif")%>" /></td></tr></table>
</div>
<div id="progress_indicator_horizontal">
    <table style="width:100%;height:100px"><tr><td style="text-align:center;vertical-align: middle"><img src="<%= VirtPath("/img/loading_card.gif")%>" /></td></tr></table>
</div>
<div id="BindKraft_defaultInfoDisplayTemplate">
    <div data-class="WindowInfoDisplay" class="c_window_info_display" data-key="windowinfodisplay" >
        <input type="button" value="Clear" data-on-click="{bind source=__control path=onClearMessages}" 
			class="client_tools_buttons" 
			style="margin:2px 2px 0 0;float:right;cursor:pointer; " />
        <table style="margin-top:15px; border-collapse: collapse; background-color:transparent;width:100%;" >
            <tbody data-class="Repeater" data-bind-$items="{read source=__control path=$reversedc}">
                <tr class="c_window_info_display_row">
                    <td style="width:30px; text-align:center">
                        <img data-class="ImageX"   alt="" class="f_notifyimg" 
                         data-bind-$src="{read path=messageType customformat=__control:CustomImgFormatter}" />
                    </td>
                    <td style="width:auto;">
                        <span  data-bind-text="{read path=message}"></span>
                    </td>
                    <td style="width:50px; text-align:left;">
                        <img data-class="ImageX"   alt="" style="cursor:pointer" 
                             data-bind-$src="{read source=static text='/img/delete__icon.png'}"
                             data-on-click="{bind source=__control path=onRemoveMessage}" />
                    </td>
                </tr>  
            </tbody>      
        </table>
    </div>
</div>

<div id="BindKraft_TouchSplitWindowTemplate">
    <div class="f_windowframe f_splitwindow_main" data-key="_window">
        <div class="f_window_content c_position_relative c_height_100 c_overflow_hidden c_padding_0" data-key="_client" >
            <div data-key="left" style="padding:0px;margin:0px;border:0px;" >
                
            </div>

            <div data-key="resizer" class="c_spliter_band">
                <div data-key="resizer_left" class="c_spliter_div_left " style="display:block">
                    <img  data-class="ImageX" data-bind-$src="{read source=static text='/img/splitter_left.png'}" class="c_left_img_spliter"/>
                </div>

                <div data-key="resizer_right" class="c_spliter_div_right" style="display:block">
                    <img  data-class="ImageX" data-bind-$src="{read source=static text='/img/splitter_right.png'}" class="c_right_img_spliter "/>
                </div>
            </div>
            <div data-key="right" style="padding:0px;margin:0px;border:0px;" >
                
            </div>
            <div data-key="collapsedLeft" class="c_splitter_collapser_left" style="position: absolute; display:none;">
                <div data-key="caption" class="c_splitter_collapsedleft">
                &nbsp;</div>
            </div>
            <div data-key="collapsedRight" class="c_splitter_collapser_right" style="position: absolute; display:none;">
                <div data-key="caption" class="c_splitter_collapsedright">
                    &nbsp;</div>
            </div>

        </div>
    </div>
</div>

<div id="BindKraft_TouchSplitWindowTemplateCF">
    <div class="f_windowframe f_splitwindow_main" data-key="_window">
        <div class="f_window_content c_position_relative c_height_100" data-key="_client" style="overflow:hidden;padding:0px;">
            <div data-key="left" style="padding:0px;margin:0px;border:0px;">
                
            </div>

           <div data-key="resizer" class="c_spliter_band">
                <div data-key="resizer_left" class="c_spliter_div_left" style="display:none">
                    <img  data-class="ImageX" data-bind-$src="{read source=static text='/img/splitter_left.png'}" class="c_left_img_spliter"/>
                </div>

                <div data-key="resizer_right" class="c_spliter_div_right" style="display:none">
                    <img  data-class="ImageX" data-bind-$src="{read source=static text='/img/splitter_right.png'}" class="c_right_img_spliter "/>
                </div>
            </div>
            <div data-key="right" style="padding:0px;margin:0px;border:0px;" >
                
            </div>
            <div data-key="collapsedLeft" class="c_cf_conteiner" >
                <div data-key="caption" class="mmm_icons mmm_document_btn c_margin_top_50 c_margin_left_0">LEFT</div>
            </div>
            <div data-key="collapsedRight" class="c_cf_conteiner">
                <div data-key="caption" class="mmm_icons mmm_document_btn c_margin_top_50">
                    RIGHT</div>
            </div>
        </div>
    </div>
</div>
<div id="WorkspaceWindowTemplateOld">
    <div class="f_windowframe" style="overflow:hidden" data-key="_window" 
		data-on-click="{bind source=./menuroot path=onHide}"
	>
		<div data-key="_windowcaption" class="c_taskbar" data-sys-height="true">
			<div class="c_taskbar_start" title="Launcher" style="margin-right: 10px;padding-left: 2px;" 
				data-on-click="{bind source=_window/menuroot path=onToggle}"
				>
				<img src="<%= VirtPath("/img/System.png")%>"  alt="" class="c_taskbar_start_icon" />
			</div>
			<div data-key="tabs" class="c_taskbar_tasks" data-class="SelectableRepeater selectedCssClass='c_taskbar_selected'"  
							data-bind-$items="{read(0) source=_window path=$children}" 
							data-on-$activatedevent="{bind source=_window path=updateWindows}" 
							data-bind-$selectedindex="{read(2) source=_window path=$currentindex}" >
					<div class="c_taskbar_task"  data-bind-elementtitle="{read path=$caption}">
						<img data-class="ImageX" 
						     src="<%= VirtPath("/img/picture_icon_small.png")%>" 
							 data-bind-$src="{read path=$iconpath}" alt="" class="c_taskbar_icon" />
							 <div class="c_taskbar_text" data-bind-text="{read path=$caption}"></div>
					</div>
			</div>
			
			<div id="loading">
				<div id="loading_count"></div>
			</div>
		</div>
		<div data-class="ActionPanel" data-key="menuroot" class="c_sysmenu"
				data-on-$openedevent="{bind source=./launchmenu path=loadContent}{bind source=./logininfo path=loadContent}"
				data-context-border="true"
			>
			<div data-class="DataArea contentaddress='post:apps/pack.asp?$read=login/info'"
				 data-parameters="connectorType='AjaxXmlConnector'"
				 data-key="logininfo"
				 data-bind-$data="{read source=static object=object}"
				 data-on-click="{bind source=~ path=std.stoppropagation}"
			>
				<div data-class="TemplateSwitcher" data-bind-$item="{read}" data-on-$select="{bind source=menuroot path=OnLoginTemplate}">
					<div data-key="logged">
						<h4>Logged on as</h4>
						<table class="menuform">
							<tr>
								<td><span data-bind-text="{read path=login}"
									></span></td>
								<td><span data-bind-elementvisible="{read path=isadmin}"
									>(admin)</span></td>
								<td style="width:24px"><img alt="Log off" title="Log off" data-class="ImageX staticsource='img/exit.png'" data-on-click="{bind source=menuroot path=OnLogoff ref[info]=logininfo@}" style="width: 24px;height: 24px;border: none;cursor:pointer;" tabindex="-1"/></td>
							</tr>
						</table>
					</div>
					<div data-key="notlogged">
						<h4>Log in</h4>
						<table class="menuform">
							<tr>
								<th>Username</th>
								<th>Password</th>
								<th>&nbsp;</th>
							</tr>
							<tr>
								<td><input type="text" class="text" data-bind-val="{bind source=menuroot path=$login writedata=keyup}" data-on-keyup="{bind source=menuroot path=OnLoginEnter ref[info]=logininfo@}"/></td>
								<td><input type="password" class="text" data-bind-val="{bind source=menuroot path=$password writedata=keyup}" data-on-keyup="{bind source=menuroot path=OnLoginEnter ref[info]=logininfo@}"/></td>
								<td style="width:24px"><img title="Log on" alt="Log on" data-class="ImageX staticsource='img/enter.png'" data-on-click="{bind source=menuroot path=OnLogin ref[info]=logininfo@}" style="width: 24px;height: 24px;border: none;cursor: pointer;" tabindex="-1"/></td>
							</tr>
						</table>
					</div>
				</div>
			</div>
			<div data-class="DataArea contentaddress='post:apps/pack.asp?$read=launcher'"
				 data-parameters="connectorType='AjaxXmlConnector'"
				 data-key="launchmenu"					 
			>
				<h4>Apps</h4>
				<div data-class="Repeater"
					data-bind-$items="{read path=apps}"
				>
					<div data-on-click="{bind source=menuroot path=onLaunch}" style="cursor: pointer;" class="c_launcher_tile">
						<img data-class="ImageX" 
							 data-bind-$src="{read path=icon}" 
							 data-bind-elementtitle="{read path=description}" 
							 class="c_launcher_icon" />
						<p data-bind-text="{read path=name}" data-bind-elementtitle="{read path=description}"></p>
					</div>
				</div>
				<div style="clear:both"></div>
				<h4>Accessories</h4>
				<div data-class="Repeater"
					data-bind-$items="{read path=links}"
				>
					<div data-on-click="{bind source=menuroot path=onLaunch}" style="cursor: pointer;" class="c_launcher_tile">
						<img data-class="ImageX" 
							 data-bind-$src="{read path=icon}" 
							 data-bind-elementtitle="{read path=description}" 
							 class="c_launcher_icon" />
						<p data-bind-text="{read path=name}" data-bind-elementtitle="{read path=description}"></p>
					</div>
				</div>
	            <div style="clear:both"></div>
                <h4>My apps</h4>
                <div data-class="Repeater"
                    data-bind-$items="{read path=mockedwindow}"
                >
                    <div data-on-click="{bind source=menuroot path=onLaunch}" style="cursor: pointer;" class="c_launcher_tile">
                        <img data-class="ImageX"
                             data-bind-$src="{read path=icon}"
                             data-bind-elementtitle="{read path=description}"
                             class="c_launcher_icon" />
                        <p data-bind-text="{read path=name}" data-bind-elementtitle="{read path=description}"></p>
                    </div>
                </div>
				<div style="clear:both"></div>
				<h4 class="alllinks" style="cursor:pointer;" data-on-click="{bind source=menuroot path=onAllLinks}">All links &gt;&gt;&gt;</h4>
			</div>
		</div>
	    <div data-key="_client" style="height: 100%; position:relative;"></div>
    </div>
</div>

<div id="bindkraft_workspacewindowtemplate">
    <div class="f_windowframe" style="overflow:hidden" data-key="_window" 
		data-on-click="{bind source=./menuroot path=onHide}"
	>
		<div data-key="_topclientslot" style="height: 3em; position:relative;border-bottom:1px solid #FFFFFF;z-index:12;" data-sys-height="true"></div>
		<div data-key="_indexclientslot" style="position: absolute;width:200pt; top:3em; height: 90%; border-bottom:1px solid #FFFFFF;z-index:10;"></div>
		<div data-key="_client" style="position:relative;z-index:8;"></div>
    </div>
</div>

<div id="BindKraft_TabSetTemplateTabsDrop">
	<div data-class="ViewBase" 
		class="f_select_drop_pop" data-key="dropper"
		style="position: absolute;right:0px;overflow: auto;">
		<div data-key="tabs" class="f_tabs" data-class="SelectableRepeater selectedCssClass='f_select_item_selected'"  
								style="height: auto;"
						data-bind-$items="{read source=_window path=$pages}" 
						data-bind-$selectedindex="{bind source=_window path=$currentindex writedata=$activatedevent}" >
				<a class="f_select_item"   data-bind-text="{read path=$caption}" style="display:block;" href="#">
						<!--<label tabindex="-1"></label>-->
				</a>
		</div>
	</div>
</div>
<div id="BindKraft_TabSetTemplate">
    <div class="f_windowframe f_tabset" data-key="_window" >
        <div class="f_sub_tabs" style="padding-right: 34px;height:30px;" data-sys-height="true" data-sys-draghandle="true">
            <div style="padding: 0px;margin:0px;">
                <div data-key="tabs" class="f_tabs" data-class="SelectableRepeater selectedCssClass='c_selected_tab'"  
								style="height: auto;"
                                data-bind-$items="{read source=_window path=$pages}" 
                                data-bind-$selectedindex="{bind source=_window path=$currentindex writedata=$activatedevent}" >
                        <span class="c_click_row c_on_select"   data-bind-text="{read path=$caption}">
                                <!--<label tabindex="-1"></label>-->
                        </span>
                </div>
            </div>
        </div>
		<div data-key="mtabs" style="float:right;width:32px;height: 30px;position:absolute;right:0px;top:0px;"
						data-class="PopTemplate bodyTemplate='#TabSetTemplateTabsDrop'" 
						data-bind-$item="{read}"
				>
					<a data-key="InactiveHeader" href="#" style="cursor:pointer;display:block; width:100%;height:100%;" class="f_drop_click_on">
						&nbsp;
					</a>
					<a data-key="ActiveHeader" href="#" style="cursor:pointer;display:block; width:100%;height:100%;" class="f_drop_click_off">
						&nbsp;
					</a>
		</div>
        <div data-key="pages" style="position:relative; background-color: #FFFFFF;">
        </div>
    </div>
</div> 
<div id="BindKraft_TabSetWithLinksTemplate">
    <div class="f_windowframe f_tabset" data-key="_window" >
        <table data-key="tab_nav" class="f_sub_tabs_dashboard c_overflow_hidden c_height_30 dynamic_row" data-sys-height="true" data-sys-draghandle="true">
            <tr class="c_height_30">
                <td class="c_height_30 c_width_350">                        
                    <a class="prev_tab_main browse left f_float_left scroll_nav_sub c_follow_up_imgs" ><img data-class="ImageX" data-bind-$src="{read source=static text='/img/tabs_left_blackarrow.png'}" /></a>
                    <a class="next_tab_main browse right f_float_right scroll_nav_sub c_follow_up_imgs"  ><img data-class="ImageX" data-bind-$src="{read source=static text='/img/tabs_right_blackarrow.png'}"  /></a>
                    <div class="scrollable_tabs_style scrollable_tabs_main" >               
                        <div data-key="tabs" class="f_tabs" data-class="Repeater" 
                             data-bind-$items="{read source=_window path=captions}" 
                            >
                            <span class="c_click_row c_on_select"  data-on-click="{read source=_window path=OnSelectCaption}"
                                  data-bind-text="{read path=$caption}">
                                <!--<label tabindex="-1"></label>-->
                            </span>
                        </div>               
                    </div>
                </td>
                <td class="c_width_270">
                    <div data-key="tablinks" id="tablinks" class="f_dashboard_links c_width_auto c_float_right c_display_inline_block" data-class="Repeater" data-bind-$items="{read source=_window path=linkcaptions}"  >
                        <a data-bind-text="{read path=$caption}" class="f_dashboard_link c_margin_right_5 cursor_pointer f_font_size_14"
                           data-on-click="{read source=_window path=OnSelectLinkCaption}" data-bind-elementvisible="{read path=linkinvisible format=InverseFormatter}"
                           data-bind-elementdisabled="{read path=workonbehalf}">
                        </a>       
                    </div>                    
                </td>
            </tr>
        </table>
        
        <div data-key="pages" class="c_position_relative c_background_white">
        </div>
    </div>
</div>


<div id="mainwindowtemplate_reserves">
    <div class="c_button_effect" data-on-click="{bind source=_window path=maximizeWindow}">^</div>
        <div class="c_button_effect" data-on-click="{bind source=_window path=normalizeWindow}">[]</div>
        <div class="c_button_effect" data-on-click="{bind source=_window path=closeWindow}">X</div>
</div>
<div id="BindKraft_captionInfoDisplayTemplate">
    <div data-class="Base" class="c_window_info_display" data-key="windowinfodisplay" style="position:absolute;z-index:1000;" >
        <input type="button" value="Clear" data-on-click="{bind source=__control path=onClearMessages}" 
			class="client_tools_buttons" 
			style="margin:2px 2px 0 0;float:right;cursor:pointer; " />
        <table style="margin-top:15px; border-collapse: collapse; background-color:transparent;width:100%;" >
            <tbody data-class="Repeater" data-bind-$items="{read}">
                <tr class="c_window_info_display_row">
                    <td style="width:30px; text-align:center">
                        <img data-class="ImageX"   alt="" class="f_notifyimg" 
                         data-bind-$src="{read path=messageType customformat=__control:CustomImgFormatter}" />
                    </td>
                    <td style="width:auto;">
                        <span  data-bind-text="{read path=message}"></span>
                    </td>
                    <td style="width:50px; text-align:left;">
                        <img data-class="ImageX"   alt="" style="cursor:pointer" 
                             data-bind-$src="{read source=static text='/img/delete__icon.png'}"
                             data-on-click="{bind source=__control path=onRemoveMessage}" />
                    </td>
                </tr>  
            </tbody>      
        </table>
    </div>
</div>
<div id="bindkraftworkspace_window-mainwindow-app">
    <div class="f_windowframe window_template shadowed_window" data-key="_window" >
        <div data-key="_windowcaption" class="f_windowcaption" style="height:20px;cursor: arrow;" 
			data-sys-height="true" data-sys-draghandle="true"
				data-on-dblclick="{bind source=_window path=toggleMaximize}"
			>
			<span data-class="SimpleInfoDisplay" style="width:200px;display: none; height: 25px;" data-key="captionInfoDisp">
				<div data-class="PopTemplate bodyTemplate='#captionInfoDisplayTemplate1' bindhost='none'" data-bind-$item="{read}" style=""
					data-bind-elementvisible="{read source=captionInfoDisp path=$infomessagesavailable}"
				>
					<div data-key="InactiveHeader">
						<div>Infos (closed)</div>
					</div>
					<div data-key="ActiveHeader">
						<div>Infos (opened)</div>
					</div>
				</div>   
			</span>
            <span data-bind-text="{read source=_window path=$caption}"></span>
            <div class="c_container_img" data-on-click="{bind source=_window path=closeWindow}" >
                <img title="<%= TR("Close") %>" src="<%= VirtPath("/img/close_card_icon.png")%>"  alt="<%= TR("Close")%>" class="c_command_image" />
            </div>
            <div class="c_container_img" data-on-click="{bind source=_window path=normalizeWindow}" >
                <img  title="<%= TR("Minimize")%>" src = "<%= VirtPath("/img/minimize_icon.png")%>" 
                      alt="<%= TR("Minimize") %>" class="c_command_image" />
            </div>
            <div class="c_container_img" data-on-click="{bind source=_window path=maximizeWindow}">
                <img  title="<%= TR("Maximize")%>" src="<%= VirtPath("/img/maximize_icon.png")%>"  
                      alt="<%= TR("Maximize")%>" class="c_command_image" />
            </div>
        </div>
        <div class = "f_command_line" data-sys-height="true" data-sys-draghandle="true">
            <div class="card_commands">
                <span data-class="Repeater" data-bind-$items="{bind source=_window path=currentView.commands}" data-key="window_CommandBar">
                    <span data-class="RibbonCommand" 
                          data-on-$clickevent="{bind}"
                          data-bind-$disabled="{bind path=disabled}"
                          data-bind-elementvisible="{read path=visible}"
                          data-bind-elementtitle="{read path=caption}" 
						  class="f_ribbon_command"
                          style="cursor: pointer;"  data-key="topMenuItem">
                        <span data-bind-text="{read path=caption}" class="command_bar"
                              data-bind-elementid="{read path=id}" >
                        </span>
                        <img  data-bind-elementtitle="{read path=caption}" data-on-click="{bind source=topMenuItem/cmdSubMenu path=toggleBody}"
                              data-class="ImageX" 
                              data-bind-$src="{read path=image}" 
                              data-bind-elementid="{read path=id}" 
							  style="display:block;height:20px; float:right;width:20px;"
                              alt="Command" />
                    </span>
                </span>
                <img data-class="ImageX" alt= "" data-bind-$src="{read source=static text='/img/separator.png'}" />
            </div>
        </div>
        <div data-key="_client" style="position: relative;background-color: #FFFFFF;"></div>
    </div>
</div>
<div id="BindKraft_appwindowtemplate">
    <div class="f_windowframe window_template shadowed_window" data-key="_window" >
        <div data-key="_windowcaption" class="f_windowcaption" style="height:20px;cursor: pointer;" 
			data-sys-height="true" data-sys-draghandle="true"
				data-on-dblclick="{bind source=_window path=toggleMaximize}"
			>
            <span data-bind-text="{read source=_window path=$caption}"></span>
            <div class="c_container_img" data-on-click="{bind source=_window path=closeWindow}" >
                <img title="<%= TR("Close") %>" src="<%= VirtPath("/img/close_card_icon.png")%>"  alt="<%= TR("Close")%>" class="c_command_image" />
            </div>
            <div class="c_container_img" data-on-click="{bind source=_window path=normalizeWindow}" >
                <img  title="<%= TR("Minimize")%>" src = "<%= VirtPath("/img/minimize_icon.png")%>" 
                      alt="<%= TR("Minimize") %>" class="c_command_image" />
            </div>
            <div class="c_container_img" data-on-click="{bind source=_window path=maximizeWindow}">
                <img  title="<%= TR("Maximize")%>" src="<%= VirtPath("/img/maximize_icon.png")%>"  
                      alt="<%= TR("Maximize")%>" class="c_command_image" />
            </div>
        </div>
        <div class = "f_command_line" data-sys-height="true" data-sys-draghandle="true">
            <div class="card_commands">
                <span data-class="Repeater" data-bind-$items="{bind service=IAppCommands path=$appcommands}" data-key="window_CommandBar">
                    <span data-class="RibbonCommand" 
                          data-on-$clickevent="{bind}"
                          data-bind-$disabled="{bind path=disabled}"
                          data-bind-elementvisible="{read path=visible}"
                          data-bind-elementtitle="{read path=$title}" 
						  class="f_ribbon_command"
                          style="cursor: pointer;"  data-key="topMenuItem">
                        <span data-bind-text="{read path=caption}" class="command_bar"
                              data-bind-elementid="{read path=id}" >
                        </span>
                        <img  data-bind-elementtitle="{read path=caption}" data-on-click="{bind source=topMenuItem/cmdSubMenu path=toggleBody}"
                              data-class="ImageX" 
                              data-bind-$src="{read path=image}" 
                              data-bind-elementid="{read path=id}" 
							  style="display:block;height:20px; float:right;width:20px;"
                              alt="Command" />
                        <!-- <span data-class="CommandSubMenu" class="command_bar command_sub" data-bind-elementvisible="{read path=subCommands}"  data-key="cmdSubMenu">
                            <span class="command_bar_sub_show" data-class="Repeater #multiTemplate='1'" data-bind-$items="{bind path=subCommands}" data-key="Body">
                                <span data-class="RibbonCommand" data-on-$clickevent="{bind}" data-bind-$disabled="{bind path=disabled}" data-bind-elementvisible="{read path=visible}" data-bind-elementtitle="{read path=caption}">
                                    <img data-bind-elementtitle="{read path=caption}" data-class="ImageX"  data-bind-$src="{read path=image}" data-bind-elementid="{read path=id}" alt="Command"/>
                                    <span data-bind-text="{read path=caption}" data-bind-elementid="{read path=id}" ></span>                                
                                </span>
                                <br />
                            </span>
                        </span> -->
                    </span>
                </span>
                <img data-class="ImageX" alt= "" data-bind-$src="{read source=static text='/img/separator.png'}" />
            </div>
        </div>
        <div data-key="_client" style="position: relative;background-color: #FFFFFF;"></div>
    </div>
</div>


<div id="BindKraft_hostedwindowtemplate">
    <div class="f_windowframe hosted_window" data-key="_window" >
        <div class = "f_command_line" data-sys-height="true" data-sys-draghandle="true">
            <div class="card_commands">
				<div class="c_container_img" data-on-click="{bind source=_window path=closeWindow}" style="float:right;">
					<img title="<%= TR("Close") %>" src="<%= VirtPath("/img/close_card_icon.png")%>"  alt="<%= TR("Close")%>" 
						  class="c_command_image" />
				</div>
                <span data-class="Repeater" data-bind-$items="{bind source=_window path=currentView.commands}" data-key="window_CommandBar">
                    <span data-class="RibbonCommand" 
                          data-on-$clickevent="{bind}"
                          data-bind-$disabled="{bind path=disabled}"
                          data-bind-elementvisible="{read path=visible}"
                          data-bind-elementtitle="{read path=caption}" 
						  class="f_ribbon_command"
                          style="cursor: pointer;"  data-key="topMenuItem">
                        <span data-bind-text="{read path=caption}" class="command_bar"
                              data-bind-elementid="{read path=id}" >
                        </span>
                        <img  data-bind-elementtitle="{read path=caption}" data-on-click="{bind source=topMenuItem/cmdSubMenu path=toggleBody}"
                              data-class="ImageX" 
                              data-bind-$src="{read(10) path=$image}" 
							  data-bind-$modulename="{read path=$modulename}"
                              data-bind-elementid="{read path=id}" 
							  style="display:block;height:20px; float:right;width:20px;"
                              alt="Command" />
                    </span>
                </span>
                
            </div>
        </div>
        <div data-key="_client" style="position: relative;background-color: #FFFFFF;overflow: auto;"></div>
    </div>
</div>

<!--Template for Vlado's window with header-->
<!--simple header window-->
<!--<div id="vp_header_window_template">
	<div class="vp_header_window" data-key="_window">
	    &lt;!&ndash;header&ndash;&gt;
		<div data-key="header" style="position:relative; clear: both"></div>
		<hr/>

		&lt;!&ndash;content&ndash;&gt;
		<div data-key="content" style="position:relative; clear: both"></div>
	</div>
</div>-->

<div id="mw_my_splitter_template">
    <div class="f_windowframe f_splitwindow_main" data-key="_window">
        <div class="f_window_content c_position_relative c_height_100 c_overflow_hidden c_padding_0" data-key="_client" >
            <div data-key="left" style="padding:0px;margin:0px;border:0px;" >

            </div>

            <div data-key="resizer" class="mw_spliter_band" style="width: 3px">

            </div>
            <div data-key="right" style="padding:0px;margin:0px;border:0px;" >

            </div>
            <div data-key="collapsedLeft" class="c_splitter_collapser_left" style="position: absolute; display:none;">
                <div data-key="caption" class="c_splitter_collapsedleft">
                &nbsp;</div>
            </div>
            <div data-key="collapsedRight" class="c_splitter_collapser_right" style="position: absolute; display:none;">
                <div data-key="caption" class="c_splitter_collapsedright">
                    &nbsp;</div>
            </div>

        </div>
    </div>
</div>

<div id="mw_left_tabset_template">
    <div class="f_windowframe f_tabset" data-key="_window" >
        <div class="mw_left_sub_tabs" style="padding-right: 34px;height:30px;" data-sys-height="true" data-sys-draghandle="true">
            <div style="padding: 0px;margin:0px;">
                <div data-key="tabs" class="f_tabs" data-class="SelectableRepeater selectedCssClass='c_selected_tab'"
								style="height: auto;"
                                data-bind-$items="{read source=_window path=$pages}"
                                data-bind-$selectedindex="{bind source=_window path=$currentindex writedata=$activatedevent}" >
                        <span class="c_click_row c_on_select"   data-bind-text="{read path=$caption}">
                                <!--<label tabindex="-1"></label>-->
                        </span>
                </div>
            </div>
        </div>
        <div data-key="pages" style="position:relative; background-color: #FFFFFF;">
        </div>
    </div>
</div>

<div id="mw_right_tabset_template">
    <div class="f_windowframe f_tabset" data-key="_window" >
        <div class="mw_right_sub_tabs" style="padding-right: 34px;height:30px;" data-sys-height="true" data-sys-draghandle="true">
            <div style="padding: 0px;margin:0px;">
                <div data-key="tabs" class="f_tabs" data-class="SelectableRepeater selectedCssClass='c_selected_tab'"
								style="height: auto;"
                                data-bind-$items="{read source=_window path=$pages}"
                                data-bind-$selectedindex="{bind source=_window path=$currentindex writedata=$activatedevent}" >
                        <span class="c_click_row c_on_select"   data-bind-text="{read path=$caption}">
                                <!--<label tabindex="-1"></label>--><!---->
                        </span>
                </div>
            </div>
        </div>
        <div data-key="pages" style="position:relative; background-color: #FFFFFF;">
        </div>
    </div>
</div>
<!-- notchshell/startpanel -->
<div id="notchshell_startpanel">
	<div class="f_windowframe" data-key="_window" style="border: 1px solid #000000; background-color: #FFFFFF; border-radius: 10px 10px 10px 10px;box-shadow: 5px 5px 5px 0px rgba(0,0,0,0.5);background: linear-gradient(to bottom, #b5bdc8 0%,#828c95 36%,#28343b 100%);" >
		<div data-key="_windowcaption" class="f_windowcaption" style="height:30px;cursor: pointer; background-color: #BECEDE; border-radius: 10px 10px 0 0"> 
            <span data-bind-text="{read source=_window path=$caption}"></span>
            <div class="" data-on-click="{bind service=NotchShellApp path=toggleUI}" style="float: right; margin-right: 5px;">
                <img data-class="ImageX modulename='notchshell' staticsource='$images/close_icon.svg'" title="Close" style="width: 30px;height:30px;"  alt="Close" class="c_command_image" />
            </div>
        </div>
		<div data-key="_client" style="position: relative; margin: 5px;"></div>
	</div>
</div>
<div id="notchshell_notchtemplate">
	<div class="f_windowframe" data-key="_window" 
		 style="color: #FFFFFF; border-bottom: 1px solid #000000; background: #45484d;color: #FFFFFF;" >
	</div>
</div>

<div id="Djamdji_UIExperiment1">
    <div class="f_windowframe window_template" data-key="_window" >
        <div data-key="_windowcaption" class="f_windowcaption" style="height:20px;cursor: pointer;" 
			data-sys-height="true" data-sys-draghandle="true"
				data-on-dblclick="{bind source=_window path=toggleMaximize}"
			>
            <span data-bind-text="{read source=_window path=$caption}"></span>
            <span data-class="PlaceHolder" 
				data-bind-$template="{read path=inject}"></span>
        </div>
        <div data-key="_client" style="position: relative;background-color: #FFFFFF;"></div>
    </div>
</div>


</div>
