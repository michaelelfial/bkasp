<div class="j_framework_control_dropdown">
	<div data-class="LookupRepeater identification='key' enabledCss='f_select_enabled' selectedCssClass='f_select_item_selected' #builtinFilter='1' #pendingtimeout='250' #bodyVisible='0' disabledCss='f_select_disabled'" 
			data-key="f_dropdown"
			data-on-$selchangedevent="{bind source=self path=updateSelected}{bind source=self path=UpdateHeaders}{bind source=self path=FocusHeader}{bind source=.. path=onSelectionChanged}"
			data-on-$internalselchangedevent="{bind source=self path=updateSelected}{bind source=self path=UpdateHeaders}"
			data-on-$activatedevent="{bind source=self path=ForceClose}{bind source=.. path=onItemActivated}"
			data-on-$escapeevent="{bind source=self path=Close}"
			data-on-$keyevent="{bind source=self path=Open}"
			data-on-$openevent="{bind source=.. path=onOpen}"
			data-on-$closeevent="{bind source=.. path=onClose}"
			class="f_select_drop_container"
			>
			<div data-key="headerelement" data-class="Base" class="f_select_head_pop">
			<a tabindex="-1" 
				class="f_select_head_anchor" 
				data-on-blur="{bind source=f_dropdown path=Close}"
				data-on-click="{bind source=f_dropdown path=Toggle}"
				data-purpose="focus"
				data-bind-elementtitle="{read source=f_dropdown path=$selecteditem.description format=NullTextFormatter}" 
				data-bind-croptext="{read source=f_dropdown path=$selecteditem.description format=NullTextFormatter}"
			></a>
			</div>
			<div data-key="bodypanel" 
				class="f_select_drop_pop"
				data-on-mousedown="{bind source=f_dropdown path=Open}{bind source=f_dropdown path=FocusHeader}"
			>
				<div data-key="itemtemplate"
						class="">
					<div class="f_select_item" data-bind-text="{read path=description}" data-bind-elementtitle="{read path=title}"></div>
				</div>
			</div>
	</div>
</div>
<div class="j_framework_control_dropdown_if">
	<div data-class="LookupRepeater identification='key' enabledCss='f_select_enabled' selectedCssClass='f_select_item_selected' #builtinFilter='1' #pendingtimeout='250' #bodyVisible='0' disabledCss='f_select_disabled'" 
			data-key="f_dropdown"
			data-on-$selchangedevent="{bind source=self path=updateSelected}{bind source=self path=Open}{bind source=self path=UpdateHeaders}{bind source=self path=FocusHeader}{bind source=.. path=onSelectionChanged}"
			data-on-$internalselchangedevent="{bind source=self path=updateSelected}{bind source=self path=UpdateHeaders}"
			data-on-$activatedevent="{bind source=self path=ForceClose}{bind source=.. path=onItemActivated}"
			data-on-$escapeevent="{bind source=self path=Close}"
			data-on-$keyevent="{bind source=self path=Open}"
			data-on-$openevent="{bind source=.. path=onOpen}"
			data-on-$closeevent="{bind source=.. path=onClose}"
			class="f_select_drop_container"
			>
			<div data-key="headerelement" data-class="Base" class="f_select_head_pop">
			<a tabindex="-1" 
				class="f_select_head_anchor" 
				data-on-blur="{bind source=f_dropdown path=Close}"
				data-on-click="{bind source=f_dropdown path=Toggle}"
				data-purpose="focus"
				data-bind-elementtitle="{read source=f_dropdown path=$selecteditem.description format=NullTextFormatter}" 
				data-bind-croptext="{read source=f_dropdown path=$selecteditem.description format=NullTextFormatter}"
			></a>
			</div>
			<div data-key="bodypanel" style="position: absolute;"
				class="f_select_drop_width"
				data-on-mousedown="{bind source=f_dropdown path=Open}{bind source=f_dropdown path=FocusHeader}"
			>
				<iframe class="f_select_drop_pop" style="z-index:1;"></iframe>
				<div data-key="itemtemplate" style="position:absolute;top:0px;left:0px;z-index:100;"
						class="f_select_drop_pop">
					<div class="f_select_item" data-bind-text="{read path=description}" data-bind-elementtitle="{read path=title}"></div>
				</div>
			</div>
	</div>
</div>
<div id="notchshell_component-icon">
	<img data-class="ImageX" style="width:100%;height:100%"
	  data-bind-$modulename="{read source=__control path=$modulename}"
	  data-bind-$servername="{read source=__control path=$servername}"
	  data-bind-$src="{read(10) source=__control path=$iconpath}"
	  data-on-pluginto="{bind source=__control path=$image}"
	  alt=""
	  />
</div>
<div class="bindkraft_control-vdropdown">
	<div class="f_select_drop_container">
		<div data-key="headerelement" data-class="Base" class="f_select_head_pop">
			<a tabindex="-1" 
				class="f_select_head_anchor" 
				data-on-blur="{bind source=__control path=Close}"
				data-on-click="{bind source=__control path=Toggle}"
				data-purpose="focus"
				data-bind-elementtitle="{read source=__control path=$selectedinternalitem.title format=NullTextFormatter}" 
				data-bind-text="{read source=__control path=$selectedinternalitem.display format=NullTextFormatter}"
			></a>
			<a 
				data-key="clearbutton"
				class="f_select_head_clear" 
				data-on-click="{bind source=__control path=ClearSelection}"
				data-bind-elementtitle="{read source=static text='clear'}"
				data-bind-addcssclass[off]="{read source=__control path=$hasselection readdata=$selchangedevent format=InverseFormatter}"
			>&nbsp;</a>
		</div>
		<div data-class="DataArea @bindhost={bind source=__control} contentaddress='supplyPagedItems' itemscountaddress='supplyPagedItems.length' connectorType='FastProcConnector' #limit='10'" 
			data-key="da"
			data-on-$countsetevent="{bind source=./sa path=onDataAreaChange}"
			data-on-$dataloadedevent="{bind source=./sa path=onDataAreaChange}"
			data-bind-$startloading="{read source=static number='1'}"
			data-on-mousedown="{bind source=__control path=Open}{bind source=__control path=FocusHeader}"
			class="f_select_drop_width f_select_drop_pop"
		>
			<div data-class="ScrollableArea #minvalue='0' #maxvalue='10' #poslimit='10' #smallmove='1' @dataarea={bind source=da}" 
				data-key="sa"
				style="overflow:hidden;"
			>
				<div data-class="SelectableRepeater #nofocus='1' identification='key' #retainindex='1' #nowrap='1' selectedCssClass='f_select_item_selected'"
					data-key="itemslist"
					data-bind-$items="{read}"
					data-on-$activatedevent="{bind source=__control path=onItemActivated}"
					data-on-$selchangedevent="{bind source=__control path=onSelectionChanged}"
					data-bind-$selectedindex="{probe source=static number='-1' readdata=__control:$openevent}"
					class="selectable_list1">
					<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;">
						<a data-bind-text="{read path=display}"  tabindex="-1"></a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<div class="j_framework_control_vmultidropdown">
	<div class="f_select_drop_container" >
		<div data-key="headerelement" data-class="Base" class="f_select_head_pop">
			<a 
				class="f_select_head_anchor" 
				data-on-blur="{bind source=__control path=Close}"
				data-on-click="{bind source=__control path=Toggle}"
				data-purpose="focus"
				data-bind-elementtitle="{read source=__control path=$selectedinternalitem.title format=NullTextFormatter}" 
				data-bind-text="{read source=__control path=$selecteditems format=__control:multiselectionformatter}"
			></a>
			<a 
				data-key="clearbutton"
				class="f_select_head_clear" 
				data-on-click="{bind source=__control path=ClearSelection}"
				data-bind-elementtitle="{read source=static text='clear'}"
				data-bind-addcssclass[off]="{read source=__control path=$hasselection readdata=$selchangedevent format=InverseFormatter}"
			>&nbsp;</a>
		</div>
		<div data-class="DataArea @bindhost={bind source=__control} contentaddress='supplyPagedItems' itemscountaddress='supplyPagedItems.length' connectorType='FastProcConnector' #limit='10'" 
			data-key="da"
			data-on-$countsetevent="{bind source=./sa path=onDataAreaChange}"
			data-on-$dataloadedevent="{bind source=./sa path=onDataAreaChange}"
			data-bind-$startloading="{read source=static number='1'}"
			data-on-mousedown="{bind source=__control path=Open}{bind source=__control path=FocusHeader}"
			class="f_select_drop_width f_select_drop_pop"
		>
			<div data-class="ScrollableArea #minvalue='0' #maxvalue='10' #poslimit='10' #smallmove='1' @dataarea={bind source=da}" 
				data-key="sa"
				style="overflow:hidden;max-height: 200px;min-height: 200px;"
			>
				<div data-class="SelectableRepeater #nofocus='1' identification='key' #retainindex='1' #nowrap='1' selectedCssClass='f_select_item_selected'"
					data-key="itemslist"
					data-bind-$items="{read}"
					data-on-$activatedevent="{bind source=__control path=onItemActivated}"
					data-on-$selchangedevent="{bind source=__control path=onSelectionChanged}"
					data-bind-$selectedindex="{probe source=static number='-1' readdata=__control:$openevent}"
					class="selectable_list1">
					<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;">
						<input type="checkbox" 
							data-class="CheckBox #stoppropagation='1'" 
							data-bind-$checked="{read path=selected}"
							data-on-$activatedevent="{bind source=__control path=onCheckItem ref[value]=self@value ref[item]=self~}{bind source=__control path=FocusHeader}"
							/>
						<a data-bind-text="{read path=display}"  tabindex="-1"></a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<div class="j_framework_control_svdropdown">
	<div class="f_select_drop_container">
		<div data-key="headerelement" data-class="Base" class="f_select_head_pop">
			<input type="text" 
				data-class="TrivialElement"
				data-purpose="focus" 
				data-bind-$val="{read source=__control path=$selectedinternalitem.display format=NullTextFormatter}"
				data-on-click="{bind source=__control path=Toggle}"
				data-on-blur="{bind source=__control path=Close}"
				data-key="selinput"
				data-on-keyup="{bind source=__control/da path=loadContent}"
				/>
		</div>
		<div data-class="DataArea @bindhost={bind source=__control} contentaddress='supplyPagedItems' itemscountaddress='supplyPagedItems.length' connectorType='FastProcConnector' #limit='10'" 
			data-key="da"
			data-on-$countsetevent="{bind source=./sa path=onDataAreaChange}"
			data-on-$dataloadedevent="{bind source=./sa path=onDataAreaChange}"
			data-bind-$startloading="{read source=static number='1'}"
			data-bind-$parameters[filter]="{read source=__control/selinput path=$val readdata=__control/selinput:keyup}"
			data-on-mousedown="{bind source=__control path=Open}{bind source=__control path=FocusHeader}"
			class="f_select_drop_width f_select_drop_pop"
		>
			<div data-class="ScrollableArea #minvalue='0' #maxvalue='10' #poslimit='10' #smallmove='1' @dataarea={bind source=da}" 
				data-key="sa"
				style="overflow:hidden;"
			>
				<div data-class="SelectableRepeater #nofocus='1' identification='key' #retainindex='1' #nowrap='1' selectedCssClass='f_select_item_selected'"
					data-key="itemslist"
					data-bind-$items="{read}"
					data-on-$activatedevent="{bind source=__control path=onItemActivated}"
					data-on-$selchangedevent="{bind source=__control path=onSelectionChanged}"
					data-bind-$selectedindex="{probe source=static number='-1' readdata=__control:$openevent}"
					class="selectable_list1">
					<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;">
						<a data-bind-text="{read path=display}"  tabindex="-1"></a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<div class="j_framework_control_dropchooser">
	<div data-class="DataArea @bindhost={bind source=__control} @contentaddress={read source=__control path=$contentconnector} @itemscountaddress={read source=__control path=$countconnector} #limit='10'" 
		data-key="da"
		data-on-$countsetevent="{bind source=./sa path=onDataAreaChange}"
		data-on-$dataloadedevent="{bind source=./sa path=onDataAreaChange}"
		data-on-$preloadevent="{bind source=__control path=firePreloadEvent}"
		data-bind-$startloading="{read source=static number='1'}"
		data-on-mousedown="{bind source=__control path=Open}"
		class="f_select_drop_width f_select_drop_pop"
	>
		<div data-class="ScrollableArea #minvalue='0' #maxvalue='10' #poslimit='10' #smallmove='1' @dataarea={bind source=da}" 
			data-key="sa"
			style="overflow:hidden;max-height: 200px;min-height: 200px;"
		>
			<div data-class="SelectableRepeater #nofocus='1' identification='key' #retainindex='1' #nowrap='1' selectedCssClass='f_select_item_selected'"
				data-key="itemslist"
				data-bind-$items="{read format=__control:StandardListConvertor(key,display,title) }"
				data-on-$activatedevent="{bind source=__control path=onItemActivated}"
				data-on-$selchangedevent="{bind source=__control path=onSelectionChanged}"
				data-bind-$selectedindex="{probe source=static number='-1' readdata=__control:$openevent}"
				class="selectable_list1">
				<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;">
					<a data-bind-text="{read path=display}"  tabindex="-1"></a>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="j_framework_control_vdropdown_k">
	<div class="f_select_drop_container">
		<div data-key="headerelement" data-class="Base" class="f_select_head_pop">
			<a tabindex="-1" 
				class="f_select_head_anchor" 
				data-on-blur="{bind source=__control path=Close}"
				data-on-click="{bind source=__control path=Toggle}"
				data-purpose="focus"
				data-bind-elementtitle="{read source=__control path=$selectedinternalitem.title format=NullTextFormatter}" 
				data-bind-text="{read source=__control path=$selectedinternalitem.display format=NullTextFormatter}"
			></a>
		</div>
		<div data-class="DataArea @bindhost={bind source=__control} contentaddress='supplyPagedItems' itemscountaddress='supplyPagedItems.length' connectorType='FastProcConnector' #limit='10'" 
			data-key="da"
			data-on-$countsetevent="{bind source=./sa path=onDataAreaChange}"
			data-on-$dataloadedevent="{bind source=./sa path=onDataAreaChange}"
			data-bind-$startloading="{read source=static number='1'}"
			data-on-mousedown="{bind source=__control path=Open}{bind source=__control path=FocusHeader}"
			class="f_select_drop_width f_select_drop_pop"
		>
			<div data-class="ScrollableArea #minvalue='0' #maxvalue='10' #poslimit='10' #smallmove='1' @dataarea={bind source=da}" 
				data-key="sa"
				style="overflow:hidden;max-height: 250px;min-height: 250px;"
			>
				<div data-class="SelectableRepeater #nofocus='1' identification='key' #retainindex='1' #nowrap='1' selectedCssClass='f_select_item_selected'"
					data-key="itemslist"
					data-bind-$items="{read}"
					data-on-$activatedevent="{bind source=__control path=onItemActivated}"
					data-on-$selchangedevent="{bind source=__control path=onSelectionChanged}"
					class="selectable_list1">
					<div class="cursor_pointer c_bucket_item_height" style="height:25px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;">
						<span
							style="display:inline-block;border:1px solid black;margin-right:2px;border-radius:5px;padding:3px;background-color:#FFEBCD;"
							data-bind-text="{read path=acceleratorkey}"
							data-bind-elementvisible="{bind path=acceleratorkey}"
						></span>
						<a data-bind-text="{read path=display}"  tabindex="-1"></a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<div class="j_framework_control_grouperexpander" style="display:none;">
	<div>
		<input type="button" 
			data-bind-val="{read source=__control path=$buttoncaption readdata=$state_changed}" 
			data-on-click="{bind source=__control path=Toggle}" />
		<div data-key="contentSlot">
		</div>
	</div>
</div>

<div class="j_framework_control_vdropdown_if">
	<div class="f_select_drop_container">
		<div data-key="headerelement" data-class="Base" class="f_select_head_pop">
			<a tabindex="-1" 
				class="f_select_head_anchor" 
				data-on-blur="{bind source=__control path=Close}"
				data-on-click="{bind source=__control path=Toggle}"
				data-purpose="focus"
				data-bind-elementtitle="{read source=__control path=$selectedinternalitem.title format=NullTextFormatter}" 
				data-bind-text="{read source=__control path=$selectedinternalitem.display format=NullTextFormatter}"
			></a>
		</div>
		<div data-class="DataArea @bindhost={bind source=__control} contentaddress='supplyPagedItems' itemscountaddress='supplyPagedItems.length' connectorType='FastProcConnector' #limit='10'" 
			data-key="da"
			data-on-$countsetevent="{bind source=./sa path=onDataAreaChange}"
			data-on-$dataloadedevent="{bind source=./sa path=onDataAreaChange}"
			data-bind-$startloading="{read source=static number='1'}"
			data-on-mousedown="{bind source=__control path=Open}{bind source=__control path=FocusHeader}"
			class="f_select_drop_width f_select_drop_pop"
			style="overflow: hidden;"
		>
			<iframe style="overflow:hidden;max-height: 200px;min-height: 200px;position:absolute;top:0px;left:0px;"></iframe>
			<div data-class="ScrollableArea #minvalue='0' #maxvalue='10' #poslimit='10' #smallmove='1' @dataarea={bind source=da}" 
				data-key="sa"
				style="overflow:hidden;max-height: 200px;min-height: 200px;position:absolute;"
			>
				<div data-class="SelectableRepeater #nofocus='1' identification='key' #retainindex='1' #nowrap='1' selectedCssClass='f_select_item_selected'"
					data-key="itemslist"
					data-bind-$items="{read}"
					data-on-$activatedevent="{bind source=__control path=onItemActivated}"
					data-on-$selchangedevent="{bind source=__control path=onSelectionChanged}"
					style="min-width:200px;"
					class="selectable_list1">
					<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;">
						<a data-bind-text="{read path=display}"  tabindex="-1"></a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
	

     
<span class="j_help_in_text_box_control">
	<span class="j_help_in_text_box" data-on-click="{bind source=__control path=OnClick}">
	   <input data-key="textbox" class="j_help_in_text_box_val"
			  data-on-blur="{bind source=__control path=OnBlur}"
			  data-on-focus="{bind source=__control path=OnClick}" 
			  data-bind-val="{bind source=__control path=$textval writedata=change}"
			  type="text"/>
	   <span data-key="hinttext" class="j_hinttext f_display_inline_block f_full_width" data-bind-text="{read source=__control path=$defaulttext}"></span>
	</span>
</span>

<div class="j_framework_control_sortheader">
	<div data-class="Expander #disabled='1'" 
		 style="cursor:pointer;" class="f_arrow_sort"
		 data-bind-$expanded="{read source=__control path=$dataarea.$order format=CompareFormater controlparam='fieldname'}">
			<div data-key="InactiveHeader" data-bind-text="{read source=__control path=$displayname}" 
				 data-on-click="{bind source=__control path=$dataarea.setOrderColumn controlparam='fieldname'}">
			</div>
			<div data-key="ActiveHeader" data-class="Expander #disabled='1'"
				 data-on-click="{bind source=__control path=$dataarea.setOrderDirection parameter='toggle'}"
				 data-bind-$expanded="{read source=__control path=$dataarea.$direction format=PositiveNegativeFormater parameter='neg'}"
				 >
				 <span data-key="InactiveHeader">
					<span style="font-weight: bold;" data-bind-text="{read source=__control path=$displayname}"></span>
					<span class="c_sortheader_arrow_up"></span>
				 </span>
				 <span data-key="ActiveHeader">
					<span style="font-weight: bold;" data-bind-text="{read source=__control path=$displayname}"></span>
					<span class="c_sortheader_arrow_down"></span>
				 </span>
			</div>
	</div>
</div> 
<div class="j_framework_control_checkbox">
	<div data-class="Expander"
		data-key="f_checkbox"
		data-bind-$expanded="{bind source=__control path=$value format=CheckedFormater writedata=$statechangedevent readdata=__control:$value_changed}{bind source=__control path=onCheckedChanged}"
		data-bind-$disabled="{bind source=__control path=$disabled format=BooleanFormatter}"
		data-on-$statechangedevent="{bind source=__control path=onCheckedChanged}"
		>
		<div data-key="InactiveHeader" class="c_height_17">
			<img data-class="ImageX" data-bind-$src="{read source=static text='img/check_box.png'}" />
		</div>
		<div data-key="ActiveHeader" class="c_height_17">
			<img data-class="ImageX" data-bind-$src="{read source=static text='img/checkbox_checked.png'}" />
		</div>
		<div data-key="Body" data-class="Panel"></div>
	</div>
</div>
<div class="bindkraftstyles_control-pager">
	<table class="c_width_207" data-bind-elementvisibility="{read source=__control path=$visible readdata=$pagerupdateevent}">
		<tr>
			<td>
				<span class="c_pager_double_left"
					  data-bind-elementdisabled="{read source=__control path=$hasprevpage format=InverseFormatter readdata=$pagerupdateevent}" 
					  data-on-click="{bind source=__control path=gotoFirstPage}"></span></td>
			<td>
				<span class="c_pager_one_left"
					  data-bind-elementdisabled="{read source=__control path=$hasprevpage format=InverseFormatter readdata=$pagerupdateevent}"
					  data-on-click="{bind source=__control path=gotoPrevPage}"></span></td>
			<td class="padding_left_6 c_padding_right_6" style="padding-left:3px;">
				<div data-class="VirtualDropDownControl keyproperty='key' descproperty='value'" 
					data-key="allPages"
					data-bind-$items="{read source=__control path=$pages readdata(1)=$pagerupdateevent}"
					data-bind-$value="{read(10) source=__control path=$currentpage readdata(2)=$pagerupdateevent writedata=__control:$applypageevent format=IntegerFormatter}" 
					data-on-$activatedevent="{bind source=__control path=OnTriggerApplyPage ref[page]=self@value }"
					class="f_select_drop_width_div_paging_small"
					>
				</div>
			</td>
			<td style="padding-right:0px;">
				<span class=" c_pager_one_right" 
					  data-bind-elementdisabled="{read source=__control path=$hasnextpage format=InverseFormatter readdata=$pagerupdateevent}"
					  data-on-click="{bind source=__control path=gotoNextPage}">
				</span>                    
			</td>
			<td style="padding-left:0px">
				<span class="c_pager_double_right"                           
					  data-bind-elementdisabled="{read source=__control path=$haslastpage format=InverseFormatter readdata=$pagerupdateevent}"
					  data-on-click="{bind source=__control path=gotoLastPage}"></span></td>
		</tr>
	</table>
</div>

<div class="bindkraftstyles_control-shortpager">
	<table class="c_short_pager" data-bind-elementvisibility="{read source=__control path=$visible readdata=$pagerupdateevent}">
		<tr>
			<td>
				<span class="c_pager_double_left"
					  data-bind-elementdisabled="{read source=__control path=$hasprevpage format=InverseFormatter readdata=$pagerupdateevent}" 
					  data-on-click="{bind source=__control path=gotoFirstPage}"></span></td>
			<td>
				<span class="c_pager_one_left"
					  data-bind-elementdisabled="{read source=__control path=$hasprevpage format=InverseFormatter readdata=$pagerupdateevent}"
					  data-on-click="{bind source=__control path=gotoPrevPage}"></span></td>
			<td class="c_padding_left_2 c_padding_right_6 ">
				<div class="c_border_universal">
					<span class="f_display_inline_block">Page:</span>
					<input data-key="currentpage" type="text" class="c_pager_textbox" size="4"
						   data-bind-val="{read source=__control path=$currentpage readdata=$pagerupdateevent writedata=__control:$applypageevent name=currentpagevalue format=IntegerFormatter}"
						   data-on-keypress="{bind(1) source=__control path=OnKeyPress ref[page]=self:currentpagevalue }" />                    
					<span class="f_display_inline_block"> of</span>
					<span class="f_display_inline_block" data-bind-text="{read source=__control path=$totalpages readdata=$pagerupdateevent}"></span>                        
				</div>
			</td>
			<td class="c_padding_right_0">
				<span class=" c_pager_one_right" 
					  data-bind-elementdisabled="{read source=__control path=$hasnextpage format=InverseFormatter readdata=$pagerupdateevent}"
					  data-on-click="{bind source=__control path=gotoNextPage}">
				</span>                    
			</td>
			<td class="c_padding_right_0">
				<span class="c_pager_double_right"                           
					  data-bind-elementdisabled="{read source=__control path=$haslastpage format=InverseFormatter readdata=$pagerupdateevent}"
					  data-on-click="{bind source=__control path=gotoLastPage}"></span>
			</td>
		</tr>
	</table>
</div>

<div class="j_framework_control_bucketselector">
	<table>
		<tr class="blue_gradient_header">
			<td class="blue_gradient_header_text c_border_sample c_width_150" data-bind-text="{read source=__control path=$selectedTitle}">Selected</td>
			<td class="functions"></td>
			<td class="blue_gradient_header_text c_border_sample c_width_150" data-bind-text="{read source=__control path=$nonselectedTitle}">Non-selected</td>
		</tr>
		<tr >
			<td class="c_border_sample">
				<div data-class="SelectableRepeater identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
					data-key="selitems"
					data-bind-$items="{read source=__control path=$selectedproxyitems}"
					data-on-$activatedevent="{bind source=__control path=onUnSelectProxy}"
					class="selectable_list">

						<div data-bind-text="{read path=display}" class="cursor_pointer">
						</div>    
				</div>
			</td>
			<td >
				<span data-on-click="{bind source=__control path=unSelectAll}" class="mmm_icons mmm_small_icons mmm_goto_end_gray" data-bind-elementvisibility="{read source=__control/selitems path=$hasitems readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
				<span data-on-click="{bind source=__control path=onRemoveSelected ref[key]=__control/selitems@value}" class="mmm_icons mmm_small_icons mmm_play_right_gray" data-bind-elementvisibility="{read source=__control/selitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
				<span data-on-click="{bind source=__control path=onAddSelected ref[key]=__control/unselitems@value}" class="mmm_icons mmm_small_icons mmm_play_left_gray" data-bind-elementvisibility="{read source=__control/unselitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
				<span data-on-click="{bind source=__control path=selectAll}" class="mmm_icons mmm_small_icons mmm_goto_start_gray" data-bind-elementvisibility="{read source=__control/unselitems path=$hasitems readdata=$selchangedevent,__control:$selchangedevent}"></span><br/>
			</td>
			<td class="c_border_sample ">
				<div data-class="SelectableRepeater identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
					data-key="unselitems"
					data-bind-$items="{read source=__control path=$nonselectedproxyitems}"
					data-on-$activatedevent="{bind source=__control path=onSelectProxy}"
					class="selectable_list">
					
					<div data-bind-text="{read path=display}" class="cursor_pointer">
					</div>
				</div>
			</td>
		</tr>
	</table>
</div>
<div class="j_framework_control_vbucketselector">
	<table class="c_bucket_selector_height">
		<tr class="blue_gradient_header">
			<td class="blue_gradient_header_text c_border_sample" style="width:180px;padding:1px;" data-bind-text="{read source=__control path=$selectedTitle}">Selected</td>
			<td class="functions" style="padding-left: 0px;"></td>
			<td class="blue_gradient_header_text c_border_sample" style="width:180px;padding:1px;" data-bind-text="{read source=__control path=$nonselectedTitle}">Non-selected</td>
		</tr>
		<tr>
			<td class="c_border_sample whitebackground" style="vertical-align: top;padding:1px;width:180px;"> 
				<div data-class="DataArea @bindhost={bind source=__control} contentaddress='cachedselectedproxyitems' itemscountaddress='cachedselectedproxyitems.length' connectorType='FastArrayConnector' #limit='10'" 
					data-key="da1"
					data-on-$countsetevent="{bind source=./sa1 path=onDataAreaChange}"
					data-on-$dataloadedevent="{bind source=./sa1 path=onDataAreaChange}"
					data-bind-$startloading="{read source=static number='1'}"
				>
					<div data-class="ScrollableArea #minvalue='0' #maxvalue='39' #poslimit='10' #smallmove='1' @dataarea={bind source=da1}" 
						data-key="sa1"
						style="overflow:hidden;max-height: 200px;min-height: 200px;"
						data-on-$poschangedevent="{bind source=viewroot path=onPosChanged}"
					>
						<div data-class="SelectableRepeater #retainindex='1' #nowrap='1' identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
							data-key="selitems"
							data-bind-$items="{read}"
							data-on-$activatedevent="{bind source=__control path=onUnSelectProxy}"
							class="selectable_list1">
							<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;width:133px;cursor:pointer;">
								<a data-bind-text="{read path=display}"  tabindex="-1"></a>
							</div>
						</div>
					</div>
				</div>
			</td>
			<td style="width:16px;padding-left: 0px;">
				<span 
					data-on-click="{bind source=__control path=unSelectAll}" 
					class="system_icons button_small goto_end_gray" 
					data-bind-elementvisibility="{read source=__control path=$hasselecteditems readdata=__control/selitems:$selchangedevent,__control:$selchangedevent}"></span><br />
				<span 
					data-on-click="{bind source=__control path=onRemoveSelected ref[key]=__control/selitems@value}" 
					class="system_icons button_small play_right_gray" 
					data-bind-elementvisibility="{read source=__control/selitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
				<span 
					data-on-click="{bind source=__control path=onAddSelected ref[key]=__control/unselitems@value}" 
					class="system_icons button_small play_left_gray" 
					data-bind-elementvisibility="{read source=__control/unselitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
				<span 
					data-on-click="{bind source=__control path=selectAll}" 
					class="system_icons button_small goto_start_gray" 
					data-bind-elementvisibility="{read source=__control path=$hasunselecteditems readdata=__control/unselitems:$selchangedevent,__control:$selchangedevent}"></span><br/>
			</td>
			<td class="c_border_sample whitebackground" style="vertical-align: top;padding:1px;width:180px;">
				<div data-class="DataArea @bindhost={bind source=__control} contentaddress='cachednonselectedproxyitems' itemscountaddress='cachednonselectedproxyitems.length' connectorType='FastArrayConnector' #limit='10'" 
					data-key="da2"
					data-on-$countsetevent="{bind source=./sa2 path=onDataAreaChange}"
					data-on-$dataloadedevent="{bind source=./sa2 path=onDataAreaChange}"
					data-bind-$startloading="{read source=static number='1'}"
				>
					<div data-class="ScrollableArea #minvalue='0' #maxvalue='39' #poslimit='10' #smallmove='1' @dataarea={bind source=da2}" 
						data-key="sa2"
						style="overflow:hidden; max-height: 200px;min-height: 200px;"
						data-on-$poschangedevent="{bind source=viewroot path=onPosChanged}"
					>
						<div data-class="SelectableRepeater #retainindex='1' #nowrap='1' identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
							data-key="unselitems"
							data-bind-$items="{read}"
							data-on-$activatedevent="{bind source=__control path=onSelectProxy}"
							class="selectable_list1">
							<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;width:133px;cursor:pointer;">
								<a data-bind-text="{read path=display}"  tabindex="-1"></a>
							</div>
						</div>
					</div>
				</div>
			</td>
		</tr>
	</table>
</div>


<div class="j_framework_control_orderedbucketselector">
   <table class="c_bucket_selector_height">
   <tr class="blue_gradient_header">
	   <td class="blue_gradient_header_text c_border_sample c_width_160" style="padding-left:1px;" data-bind-text="{read source=__control path=$selectedTitle}">Selected</td>
	   <td class="functions" style="padding-left:0px;"></td>
	   <td class="blue_gradient_header_text c_border_sample c_width_160" style="padding-left:1px;" data-bind-text="{read source=__control path=$nonselectedTitle}">Non-selected</td>
   </tr>
	   <tr >
		   <td class="c_border_sample whitebackground" style="vertical-align:top; padding:1px; width:180px;">
			   <div data-class="SelectableRepeater identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
				   data-key="selitems"
				   data-bind-$items="{read source=__control path=$selectedproxyitems}"
				   data-on-$activatedevent="{bind source=__control path=onUnSelectProxy}"
				   data-on-$orderchangedevent="{bind source=__control path=onUpdateSelectedKeysFromUI ref[selected]=self@items}"
				   class="selectable_list"
				   style="padding-left:0px;max-height: 200px;min-height: 200px;overflow-y:auto;"
				   >

					   <div data-bind-text="{read path=display}" class="cursor_pointer" style="height:20px;">
					   </div>    
			   </div>
		   </td>
		   <td style="padding-left:0px;">
			   <span data-on-click="{bind source=__control path=unSelectAll}" class="system_icons button_small goto_end_gray" 
					data-bind-elementvisibility="{read source=__control/selitems path=$hasitems readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=onRemoveSelected ref[key]=__control/selitems@value}" class="system_icons button_small play_right_gray" 
					data-bind-elementvisibility="{read source=__control/selitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=onAddSelected ref[key]=__control/unselitems@value}" class="system_icons button_small play_left_gray" 
					data-bind-elementvisibility="{read source=__control/unselitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=selectAll}" class="system_icons button_small goto_start_gray" 
				data-bind-elementvisibility="{read source=__control/unselitems path=$hasitems readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <hr />
			   <span data-on-click="{bind source=__control/selitems path=onMoveSelectedItem parameter='up'}" 
				   data-bind-elementvisibility="{read source=__control/selitems path=$canmoveup readdata=$orderchangedevent,$selchangedevent}"
				   class="system_icons button_small arrow_up"></span><br />
			   <span data-on-click="{bind source=__control/selitems path=onMoveSelectedItem parameter='down'}" 
				   data-bind-elementvisibility="{read source=__control/selitems path=$canmovedown readdata=$orderchangedevent,$selchangedevent}"
				   class="system_icons button_small arrow_down"></span>
		   </td>
		   <td class="c_border_sample whitebackground" style="vertical-align: top;padding:1px;width:180px;">
				<div data-class="DataArea @bindhost={bind source=__control} contentaddress='cachednonselectedproxyitems' itemscountaddress='cachednonselectedproxyitems.length' connectorType='FastArrayConnector' #limit='10'" 
					data-key="da2"
					data-on-$countsetevent="{bind source=./sa2 path=onDataAreaChange}"
					data-on-$dataloadedevent="{bind source=./sa2 path=onDataAreaChange}"
					data-bind-$startloading="{read source=static number='1'}"
				>
					<div data-class="ScrollableArea #minvalue='0' #maxvalue='39' #poslimit='10' #smallmove='1' @dataarea={bind source=da2}" 
						data-key="sa2"
						style="overflow:hidden; max-height: 200px;min-height: 200px;"
						data-on-$poschangedevent="{bind source=viewroot path=onPosChanged}"
					>
						<div data-class="SelectableRepeater #retainindex='1' #nowrap='1' identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
							data-key="unselitems"
							data-bind-$items="{read}"
							data-on-$activatedevent="{bind source=__control path=onSelectProxy}"
							class="selectable_list1">
							<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;width:133px;cursor:pointer;">
								<a data-bind-text="{read path=display}"  tabindex="-1"></a>
							</div>
						</div>
					</div>
				</div>
			</td>
	   </tr>
   </table>
</div>
<div class="j_framework_control_fieldsetbucketselector">
   <table>
   <tr class="blue_gradient_header">
	   <td class="blue_gradient_header_text c_border_sample c_width_150" data-bind-text="{read source=__control path=$selectedTitle}">Selected</td>
	   <td class="functions"></td>
	   <td class="blue_gradient_header_text c_border_sample c_width_150" data-bind-text="{read source=__control path=$nonselectedTitle}">Non-selected</td>
   </tr>
	   <tr >
		   <td class="c_border_sample">
			   <div data-class="SelectableRepeater identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
				   data-key="selitems"
				   data-bind-$items="{read source=__control path=$selectedproxyitems}"
				   data-on-$activatedevent="{bind source=__control path=onUnSelectProxy}"
				   data-on-$orderchangedevent="{bind source=__control path=onUpdateSelectedKeysFromUI ref[selected]=self@items}"
				   class="selectable_list">
				   <div class="mmm_fieldbucket_leftrow">
					   <span data-class="UYesNo"
						   data-parameters="yesvalue='DESC' novalue='ASC' yestitle='desc' notitle='asc' #emptyis='1'"
						   data-bind-$value="{bind path=$order writedata=$changedevent}" ></span>
					   <span data-bind-text="{read path=display}" class="cursor_pointer" style="">
					   </span>    
				   </div>
			   </div>
		   </td>
		   <td >
			   <span data-on-click="{bind source=__control path=unSelectAll}" class="mmm_icons mmm_small_icons mmm_goto_end_gray" data-bind-elementvisibility="{read source=__control/selitems path=$hasitems readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=onRemoveSelected ref[key]=__control/selitems@value}" class="mmm_icons mmm_small_icons mmm_play_right_gray" data-bind-elementvisibility="{read source=__control/selitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=onAddSelected ref[key]=__control/unselitems@value}" class="mmm_icons mmm_small_icons mmm_play_left_gray" data-bind-elementvisibility="{read source=__control/unselitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=selectAll}" class="mmm_icons mmm_small_icons mmm_goto_start_gray" data-bind-elementvisibility="{read source=__control/unselitems path=$hasitems readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <br/>
			   <span data-on-click="{bind source=__control/selitems path=onMoveSelectedItem parameter='up'}" 
				   data-bind-elementvisibility="{read source=__control/selitems path=$canmoveup readdata=$orderchangedevent,$selchangedevent}"
				   class="mmm_icons mmm_small_icons mmm_arrow_up"></span><br />
			   <span data-on-click="{bind source=__control/selitems path=onMoveSelectedItem parameter='down'}" 
				   data-bind-elementvisibility="{read source=__control/selitems path=$canmovedown readdata=$orderchangedevent,$selchangedevent}"
				   class="mmm_icons mmm_small_icons mmm_arrow_down"></span>
		   </td>
		   <td class="c_border_sample ">
			   <div data-class="SelectableRepeater identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
				   data-key="unselitems"
				   data-bind-$items="{read source=__control path=$nonselectedproxyitems}"
				   data-on-$activatedevent="{bind source=__control path=onSelectProxy}"
				   class="selectable_list">
				   
				   <div data-bind-text="{read path=display}" class="cursor_pointer">
				   </div>
			   </div>
		   </td>

	   </tr>
   </table>
</div>
<div class="j_framework_control_vorderedbucketselector">
	<table class="c_bucket_selector_height">
	   <tr class="blue_gradient_header">
		   <td class="blue_gradient_header_text c_border_sample c_width_160" style="padding-left:1px;" data-bind-text="{read source=__control path=$selectedTitle}">Selected</td>
		   <td class="functions" style="padding-left:0px;"></td>
		   <td class="blue_gradient_header_text c_border_sample c_width_160" style="padding-left:1px;" data-bind-text="{read source=__control path=$nonselectedTitle}">Non-selected</td>
	   </tr>
	   <tr >
		   <td class="c_border_sample whitebackground" style="vertical-align:top; padding:1px; width:180px;">
				<input type="search" style="width:100%"
					data-bind-elementvisibility="{read source=__control path=$showselectedfilter readdata=$showselectedfilter_changed}"
					data-bind-elementvisible="{read source=__control path=$anyfiltervisible readdata=$shownonselectedfilter_changed,$showselectedfilter_changed}"
					data-bind-val="{bind source=../da1 path=$parameters.filter writedata=../da1:$preloadevent}"
					data-on-keyup="{bind source=../da1 path=loadContent}"
					data-on-change="{bind source=../da1 path=loadContent}"
				/>
			   <div data-class="DataArea @bindhost={bind source=__control} contentaddress='supplyDynamicSelectedProxyItems' itemscountaddress='supplyDynamicSelectedProxyItems.length' connectorType='FastProcConnector' #limit='10'" 
					data-key="da1"
					data-on-$countsetevent="{bind source=./sa1 path=onDataAreaChange}"
					data-on-$dataloadedevent="{bind source=./sa1 path=onDataAreaChange}"
					data-bind-$startloading="{read source=static number='1'}"
				>
					<div data-class="ScrollableArea #minvalue='0' #maxvalue='39' #poslimit='10' #smallmove='1' @dataarea={bind source=da1}" 
						data-key="sa1"
						style="overflow:hidden; max-height: 200px;min-height: 200px;"
						data-on-$poschangedevent="{bind source=viewroot path=onPosChanged}"
					>
						<div data-class="SelectableRepeater #retainindex='1' #nowrap='1' identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
							data-key="selitems"
							data-bind-$items="{read}"
							data-on-$activatedevent="{bind source=__control path=onRemoveSelected ref[key]=self@value}"
							class="selectable_list1">
							<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;width:133px;cursor:pointer;">
								<a data-bind-text="{read path=display}"  tabindex="-1"></a>
							</div>
						</div>
					</div>
				</div>
		   </td>
		   <td style="padding-left:0px;">
			   <span data-on-click="{bind source=__control path=unSelectAll}" class="system_icons button_small goto_end_gray" 
					data-bind-elementvisibility="{read source=__control/selitems path=$hasitems readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=onRemoveSelected ref[key]=__control/selitems@value}" class="system_icons button_small play_right_gray" 
					data-bind-elementvisibility="{read source=__control/selitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=onAddSelected ref[key]=__control/unselitems@value}" class="system_icons button_small play_left_gray" 
					data-bind-elementvisibility="{read source=__control/unselitems path=$hasselection readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <span data-on-click="{bind source=__control path=selectAll}" class="system_icons button_small goto_start_gray" 
				data-bind-elementvisibility="{read source=__control/unselitems path=$hasitems readdata=$selchangedevent,__control:$selchangedevent}"></span><br />
			   <hr />
			   <span data-on-click="{bind source=__control/selitems path=onMoveSelectedItem parameter='up'}" 
				   data-bind-elementvisibility="{read source=__control/selitems path=$canmoveup readdata=$orderchangedevent,$selchangedevent}"
				   class="system_icons button_small arrow_up"></span><br />
			   <span data-on-click="{bind source=__control/selitems path=onMoveSelectedItem parameter='down'}" 
				   data-bind-elementvisibility="{read source=__control/selitems path=$canmovedown readdata=$orderchangedevent,$selchangedevent}"
				   class="system_icons button_small arrow_down"></span>
		   </td>
		   <td class="c_border_sample whitebackground" style="vertical-align: top;padding:1px;width:180px;">
				<input type="search" style="width:100%"
					data-bind-elementvisibility="{read source=__control path=$shownonselectedfilter readdata=$shownonselectedfilter_changed}"
					data-bind-elementvisible="{read source=__control path=$anyfiltervisible readdata=$shownonselectedfilter_changed,$showselectedfilter_changed}"
					data-bind-val="{bind source=../da2 path=$parameters.filter writedata=../da2:$preloadevent}"
					data-on-keyup="{bind source=../da2 path=loadContent}"
					data-on-change="{bind source=../da2 path=loadContent}"
				/>
				<div data-class="DataArea @bindhost={bind source=__control} contentaddress='supplyDynamicNonSelectedProxyItems' itemscountaddress='supplyDynamicNonSelectedProxyItems.length' connectorType='FastProcConnector' #limit='10'" 
					data-key="da2"
					data-on-$countsetevent="{bind source=./sa2 path=onDataAreaChange}"
					data-on-$dataloadedevent="{bind source=./sa2 path=onDataAreaChange}"
					data-bind-$startloading="{read source=static number='1'}"
				>
					<div data-class="ScrollableArea #minvalue='0' #maxvalue='39' #poslimit='10' #smallmove='1' @dataarea={bind source=da2}" 
						data-key="sa2"
						style="overflow:hidden; max-height: 200px;min-height: 200px;"
						data-on-$poschangedevent="{bind source=viewroot path=onPosChanged}"
					>
						<div data-class="SelectableRepeater #retainindex='1' #nowrap='1' identification='key' #doubleClickToActivate='1' selectedCssClass='f_select_item_selected'"
							data-key="unselitems"
							data-bind-$items="{read}"
							data-on-$activatedevent="{bind source=__control path=onAddSelected ref[key]=self@value}"
							class="selectable_list1">
							<div class="cursor_pointer c_bucket_item_height" style="height:20px;white-space: nowrap;text-overflow: ellipsis;overflow:hidden;width:133px;cursor:pointer;">
								<a data-bind-text="{read path=display}"  tabindex="-1"></a>
							</div>
						</div>
					</div>
				</div>
			</td>
	   </tr>
   </table>
</div>

<div class="j_framework_control_yesno">
	<span class="mmm_yesno_frame">
	   <a tabindex="-1" data-key="yes_key" data-on-click="{bind source=__control path=onSetYes}" data-on-keyup="{bind source=__control path=onSetYes parameter='keyboard'}" data-bind-text="{read source=__control path=$yestitle}" class="mmm_yesno_left"></a><a 
	   tabindex="-1" data-key="no_key" data-on-click="{bind source=__control path=onSetNo}" data-on-keyup="{bind source=__control path=onSetNo parameter='keyboard'}" data-bind-text="{read source=__control path=$notitle}" class="mmm_yesno_right"></a>
	</span>
</div>
<div class="j_framework_control_jsonviewer">
	<div data-class="TemplateSwitcher" 
		 data-bind-$item="{read}" 
		 data-on-$select="{bind source=__control path=onDataTemplate}"
		 data-key="dataitem"
		 style="display:table;"
	>
		<span data-key="null" style="color: #808080;">
			<b>null</b>
		</span>
		<span data-key="value" style="color: #000000;">
			<b data-bind-text="{read customformat=__control:valueFmt}"></b> (<span style="color: #008000;" data-bind-text="{read customformat=__control:typeFmt}"></span>)
		</span>
		<div data-key="object" style="margin: 0px; margin-left: 16px;padding: 1px; color: #000080;">
			{<br />
			<blockquote  data-class="ValueRepeater" data-bind-$items="{read}" style="margin: 0px; margin-left: 1px;padding: 1px;">
				<div style="clear:both;display: table-row;" data-class="Base">
					<div style="display: table-cell;padding-right: 0px;"><span style="font-style:italic;" data-bind-text="{read path=$key}"></span>: </div>&nbsp;
					<div style="display: table-cell;"
						data-class="TemplateSwitcher templateSource='dataitem'" 
						data-bind-$item="{read path=$value}" 
						data-on-$select="{bind source=__control path=onDataTemplate}" ></div>
				</div>
			</blockquote>
			<div style="clear: both;"></div>
			}
		</div>
		<div data-key="array" style="margin: 0px; margin-left: 16px;padding: 1px; color: #800000;">
			[<br />
			<blockquote data-class="ValueRepeater" data-bind-$items="{read}" style="margin: 0px; margin-left: 1px;padding: 1px;">
				<div style="display: table-row;" data-class="Base">
					<div style="padding-right: 0px; display: table-cell">[<span style="font-style:italic;" data-bind-text="{read path=$key}"></span>]: </div>&nbsp;
					<div style="display: table-cell;"
						data-class="TemplateSwitcher templateSource='dataitem'" 
						data-bind-$item="{read path=$value}" 
						data-on-$select="{bind source=__control path=onDataTemplate}" ></div>
				</div>
			</blockquote>
			<div style="clear: both;"></div>
			]
		</div>
	</div>
</div>

<!-- <div class="calendarElement" style="border:1px solid black;" data-class="CalendarElement" data-key="calendar" data-on-$selectedDay="{bind source=viewroot/userSelectedDate path=OnEventMe}"> -->
<div class="calendarElement">
	<a tabindex='1' href="#" data-key="calnedarkeyboardtarget"></a>
	
	<div style="background-color:#3e68ab;text-align:center;width:190px;">
		
		<span style="float:left;" class="ExampleCalendarLeft" data-key="prevMonth" data-on-click="{bind source=__control path=onPrevMonth writedata=click}">&nbsp;</span>
		<!-- <div style="display:inline-block;"><span class="ExampleCalendarLeft" data-on-click="{bind source=__control path=onPrevYear}">&nbsp;</span></div> -->
		<span data-key="month" data-bind-text="{read source=__control path=$date.$month format=DisplacementFormater}"></span>
		&nbsp;
		<span data-bind-text="{read source=__control path=$date.$year}"></span>
		<!-- <div style="display:inline-block;"><span class="ExampleCalendarRight" data-on-click="{bind source=__control path=onNextYear}">&nbsp;</span></div> -->
		
		<span style="float:right;" class="ExampleCalendarRight" data-key="nextMonth" data-on-click="{bind source=__control path=onNextMonth writedata=click}">&nbsp;</span>
		<div style="clear:both;"></div>
	</div>
	
	<div><span class="ExampleCalendarWeekDays">Mo</span><span class="ExampleCalendarWeekDays">Tu</span><span class="ExampleCalendarWeekDays">We</span><span class="ExampleCalendarWeekDays">Th</span><span class="ExampleCalendarWeekDays">Fr</span><span class="ExampleCalendarWeekDays">Sa</span><span class="ExampleCalendarWeekDays">Su</span></div>
	
	<div data-class="Repeater" data-bind-$items="{read source=__control path=$weeks}" class="examplenoselection">
		<div>
			<!-- <span style="margin-right:10px;">Week #<span data-bind-text="{read path=weekCounter format=DisplacementFormater}"></span></span> -->
			<div data-class="Repeater" style="display:inline-block;" data-bind-$items="{read}" class="ExampleCalendarDays">			
				<span
					style="width: 27px; display: inline-block; text-align: center; cursor: pointer; text-decoration: none;"
					data-bind-html="{read path=d flags=days}"
					data-bind-cssclass="{read path=selected}"
					data-on-click="{bind source=__control path=onMouseClick}"
					>
				</span>
			</div>
		</div>
	</div>

	<hr/>
	<!-- <div data-class="ExampleTimeScroller #focushours='1'" data-bind-$focushours="{read source=static number='1'}"></div> -->
	<div
		data-class="TimeScroller"
		data-bind-$value="{bind source=__control path=$date.$date writedata=$time_changed}"
	></div>
	<input type="button" value="close" data-on-click="{bind source=__control path=onClose}{bind source=__control path=updateSourcesOf}{bind source=__control path=updateTargetsOf}" />
</div>
<div class="j_control_timepicker">

	<span style="display:inline-block; width: 50px;">Time:</span>
	<span data-bind-text="{read source=__control path=$myresult readdata=$time_changed}"></span>
	<br/>
	
	<div style="display:inline-block; width: 50px;">Hours:</div>
	<span class="nonSelectable ExampleTimePickerMinusButton" data-on-click="{bind source=__control path=onChangeClick parameter='hours,-1'}">&#8211;</span>
	<div class="ExampleTimePickerScroller" data-key="hoursContainer">
		<a href="#" class="ExampleTimePickerSlider" data-key="hours" data-on-click="{bind source=__control path=onClickScroller}"></a>
	</div>
	<span class="nonSelectable ExampleTimePickerPlusButton" data-on-click="{bind source=__control path=onChangeClick parameter='hours,+1'}">+</span>
	<br/>
	
	<div style="display:inline-block; width: 50px;">Minutes:</div>
	<span class="nonSelectable ExampleTimePickerMinusButton" data-on-click="{bind source=__control path=onChangeClick parameter='minutes,-1'}">&#8211;</span>
	<div class="ExampleTimePickerScroller" data-key="minutesContainer">
		<a data-key="minutes" href="#" class="ExampleTimePickerSlider" data-on-click="{bind source=__control path=onClickScroller}"></a>
	</div>
	<span class="nonSelectable ExampleTimePickerPlusButton" data-on-click="{bind source=__control path=onChangeClick parameter='minutes,+1'}">+</span>
	<br/>
	<input type="button" value="Now" style="float:right;" data-on-click="{bind source=__control path=onClickNow}" data-on-focus="{bind source=__control path=onBlurSomething}" />
</div>
	
<div class="DateTimePicker">
	<div data-key="CalendarPanel" data-class="Expander" data-on-$expandeddevent="{bind source=./callendarinstance path=onOpen}">
		<div data-key="InactiveHeader">
			<input
				type="text" data-class="CalendarDropDown" data-key="userSelectedDate"
				data-bind-$calendar="{bind source=viewroot/callendarinstance path=$selectedDate readdata=$dayselection format=DateTimeLong}"/>
		</div>
		<div data-key="ActiveHeader">
	
			<input type="text" data-class="CalendarDropDown" data-key="userSelectedDate"
				data-bind-$calendar="{bind source=viewroot/callendarinstance path=$selectedDate readdata=$dayselection format=DateTimeLong}"/>			
	
			<div style="border: 1px solid black; width: 190px;" data-key="callendarinstance"
				 data-class="CalendarElement selectedCssClass='ExampleCalendarSelectedDay' expanderpath='viewroot/CalendarPanel'"
				 data-bind-$value="{bind source=__control path=$datetoload}"
			></div>
		</div>
	</div>
</div>
<div class="j_framework_control_file_upload">
	<input type="text" disabled="disabled" placeholder="Choose file" data-bind-val="{read source=__control path=$selectedfile}"
		   style="cursor: pointer; border: 1px solid #ccc; padding: 6px; white-space: nowrap; overflow: hidden !important; -moz-text-overflow: ellipsis; -ms-text-overflow: ellipsis; -o-text-overflow: ellipsis; text-overflow: ellipsis; width: 250px; display: inline-block; vertical-align: middle;"
	/>
	<input type="button" value="Browse"
		   style="margin-left: 5px; -ms-border-radius: 5px; background-color: #F4F3F3; border: 1px solid #C8C7C7; border-radius: 5px; color: #404040; cursor: pointer; font-size: 12px; padding: 5px 7px; z-index: 1000; display: inline-block; vertical-align: middle;"
	/>
</div>
<div id="bindkraft_control-dataviewer">
	<span data-class="DataBrowser #detailed='1'"
		  style="font-weight: bold;"
		  data-bind-$item="{read source=parentcontext}"
		  data-bind-$expanded="{read source=__control path=$expanded}"
	>	
		<div data-class="TemplateSwitcher" data-bind-$item="{read source=__control path=$item}" data-key="nodecontent"
											data-on-$select="{bind source=__control path=TemplateSelector}">
			<span data-key="null">null</span>
			<span data-key="undefined">undefined</span>
			<span data-key="function">function()</span>
			<span data-key="boolean" data-bind-text="{read}" style="color:blue;"></span>
			<span data-key="number" data-bind-text="{read}" style="color:red;"></span>
			<span data-key="string" data-bind-text="{read}" style="color:green;"></span>
			<span data-key="date" data-bind-text="{read}" style="color:orange;"></span>
			<span data-key="object"> 
				<span data-class="DataBrowser #detailed='1'" data-bind-$item="{read}" data-bind-$expanded="{read source=__control path=$expanded}">
					<span data-class="DualTemplate"
						  data-key="datanode"
						  data-bind-$alternatetemplate="{read(0) source=__control path=$expanded}"
						  data-bind-$item="{read(1) source=static object=object}"
					>
						<a href="#" data-key="default" data-on-click="{bind source=datanode path=ToggleTemplate}">[+] {...}</a> 
						<span data-key="alternate">
							<a href="#" data-on-click="{bind source=datanode path=ToggleTemplate}">[-]</a> 
							{
								<div data-class="ValueRepeater" data-bind-$items="{read source=__control path=$item}" style="margin-left:16px;" data-async="I100">
									<span data-bind-text="{read path=$key}"></span><span>:</span>
									<span data-class="TemplateSwitcher templateSource='nodecontent'" data-bind-$item="{read path=$value}"
										data-on-$select="{bind source=__control path=TemplateSelector}">
										<!-- Recurse -->
									</span>
									<br/>
								</div>
							}
						</span>
					</span>
				</span>
			</span>
			<span data-key="BaseObject"> 
				<span data-class="DataBrowser #detailed='1'" data-bind-$item="{read}" data-bind-$expanded="{read source=__control path=$expanded}">
					<span data-class="DualTemplate"
						  data-key="datanode"
						  data-bind-$alternatetemplate="{read(0) source=__control path=$expanded}"
						  data-bind-$item="{read(1) source=static object=object}"
					>
						<a href="#" data-key="default" data-on-click="{bind source=datanode path=ToggleTemplate}">[+] {...} 
							<span data-bind-text="{read source=__control path=$item customformat=__control:FormatObjectBriefInfo}"></span> </a> 
						<span data-key="alternate">
							<a href="#" data-on-click="{bind source=datanode path=ToggleTemplate}">[-] <span data-bind-text="{read source=__control path=$item customformat=__control:FormatCObjectBriefInfo}"></span></a> 
							{
								<div data-class="ValueRepeater" data-bind-$items="{read source=__control path=$item}" style="margin-left:16px;" data-async="I10">
									<span data-bind-text="{read path=$key}"></span><span>:</span>
									<span data-class="TemplateSwitcher templateSource='nodecontent'" data-bind-$item="{read path=$value}"
										data-on-$select="{bind source=__control path=TemplateSelector}">
										<!-- Recurse -->
									</span>
									<br/>
								</div>
							}
						</span>
					</span>
				</span>
			</span>
			<span data-key="array"> 
				<span data-class="DataBrowser #detailed='1'" data-bind-$item="{read}" data-bind-$expanded="{read source=__control path=$expanded}">
					<span data-class="DualTemplate"
						  data-key="datanode"
						  data-bind-$alternatetemplate="{read(0) source=__control path=$expanded}"
						  data-bind-$item="{read(1) source=static object=object}"
					>
						<a href="#" data-key="default" data-on-click="{bind source=datanode path=ToggleTemplate}">[+] [...]</a> 
						<span data-key="alternate">
							<a href="#" data-on-click="{bind source=datanode path=ToggleTemplate}">[-]</a> 
							[
								<div data-class="Repeater" data-bind-$items="{read source=__control path=$item}" style="margin-left:16px;" data-async="I10">
									<div data-class="TemplateSwitcher templateSource='nodecontent'" data-bind-$item="{read}"
										data-on-$select="{bind source=__control path=TemplateSelector}" >
										<!-- Recurse -->
									</div>
								</div>
							]
						</span>
					</span>
				</span>
			</span>
		</div>
	</span>
</div>
<div id="j_framework_multiselector">
	<div style="width: 500px; border: 1px solid black;"
		 data-class="DefaultBase"
		 data-on-$boundevent="{bind source=self path=makeCascadeCall parameter='PPartnershipInitiator.initiatePartnerships'}">		
		<div data-class="UMultipleSelectionConsumer @selector1={bind source=__control/selector}" data-key="consumer">
			<div data-class="SelectableRepeater identification='id' selectedCssClass='f_select_item_selected' unselectedCssClass='f_select_item'"
			 data-bind-$items="{read source=__control path=$selecteditems}"
			 data-key="repeater"
			 style="display: inline-block;">
				<div class="f_select_item" style="display: inline-block; border: 1px solid black; padding: 5px; margin: 5px; border-radius: 5px;">
					<a href="#" style="text-decoration: none; color: auto; outline: 0;"
						data-on-keyup="{bind source=__control path=onKeyUp ref[sr]=__control/repeater@}">
					   <!--data-on-keypress="{bind source=__control path=onKeyPress}"-->
						<div class="exampleDiv" data-bind-text="{read path=capt}"></div>
						<strong data-on-click="{bind source=__control path=onRemove ref[sr]=__control/repeater@}">X</strong>
					</a>
				</div>
			</div>
		</div>
		<input type="text" 
			data-class="USimpleFilterableTextBox #detectenter='1' @selector1={bind source=__control/selector}"
			data-key="filtersource" 
			data-on-keyup="{bind source=__control path=onKeyUpForInput ref[sr]=__control/repeater@}" />
		<div data-class="UDropChooser contentaddress='supplyPagedItems' itemscountaddress='supplyPagedItems.length' connectorType='FastProcConnector' filterfields='id,capt'" 
			 data-parameters="keyproperty='id' descproperty='capt'"
			 data-key="selector" 
			 style="position:relative;"
			 data-bind-$items="{read source=__control path=$items}"></div>
	</div>
</div>
<div class="loanprocess_control-geocode-comparer">
	<div style="border: 1px dashed #FF8040; margin: 10px;">
		<div data-class="GoogleGeocodeQuery" data-key="form"
			data-on-pluginto="{bind source=__control path=$form}" 
			data-bind-$addressresult="{probe source=__control path=$formresults writedata=$addressresultavailable}"
			style="border: 1px dashed #FF8040; margin: 10px;">
				Address: <input type="text" data-bind-val="{bind source=form path=$address writedata=form/geocode:click}"/>
				<input type="button" data-key="geocode" value="&gt;&gt;" data-on-click="{bind source=form path=findAddress}" />
				<input type="button" data-key="zoom" value="zoom" data-on-click="{bind source=__control/map path=zoomToContent}" />
		</div>
		<div data-class="GoogleGeocodeQuery" data-key="static"
			data-on-pluginto="{bind source=__control path=$static}" 
			data-bind-$addressresult="{probe source=__control path=$staticresults writedata=$addressresultavailable}"
			style="display: none;border: 2px dashed #FF8040; margin: 10px;"></div>
		<div data-class="GPXGoogleMapElement" 
			 data-key="map" 
			 style="height: 300px; width: 100%;"
			 data-on-pluginto="{bind source=__control path=$map}"
			 data-bind-$multipoints="{read source=__control path=$combinedresults format=__control:resultsformatter readdata=$resultsavailable}"
			>
		</div>
	</div>
</div>
<div class="notchshell_component-startmenu">
	
	<h4 style="background-color: black; color: white;" data-bind-text="{read source=__control path=$caption}"></h4>
	<div data-class="TemplateSwitcher" data-bind-$item="{read source=__control path=$shortcuts}" data-on-$select="{bind source=__control path=OnSelectTemplate}">
		<div data-key="list" class="c_vmenu" data-class="Repeater" data-bind-$items="{read}">
			<div style="cursor: pointer;" class="c_vmenu_item" data-on-click="{bind source=__control path=onActivateShortcut}">
				<div data-class="NotchShellComponent_Icon @backupicon={read source=__control path=$backupicon}" data-bind-$icon="{read path=value.$icon}" style="width: 32px;height:32px; float:left;"></div>
				<div style="width: 10px;height:10px; float:left;background-color: red;" data-bind-elementvisibility="{read path=apprunning}"></div>
				<div class="c_vmenu_text">
					<h4 data-bind-text="{read path=key}"></h4>
					<p data-bind-text="{read path=value.$description}"></p>
					<em style="color:#808080;" 
						data-bind-elementvisibility="{read source=__control path=$detailed}"
						data-bind-text="{read path=value.$script}"></em>
				</div>
				<div style="clear:both"></div>
			</div>
		</div>
		<div data-key="icons" class="c_vmenu">
			<div data-class="Repeater" data-bind-$items="{read}">
				<div style="cursor: pointer; float:left; width:80px; height:100px;" class="c_vmenu_item" data-on-click="{bind source=__control path=onActivateShortcut}">
					<div data-class="NotchShellComponent_Icon @backupicon={read source=__control path=$backupicon}" data-bind-$icon="{read path=value.$icon}" style="width: 32px;height:32px; float:left;"></div>
					<div class="c_vmenu_text">
						<h4 data-bind-text="{read path=key}"></h4>
						<p data-bind-text="{read path=value.$description}"></p>
						<em style="color:#808080;" 
							data-bind-elementvisibility="{read source=__control path=$detailed}"
							data-bind-text="{read path=value.$script}"></em>
					</div>
					<div style="clear:both"></div>
				</div>
			</div>
			<div style="clear:both"></div>
		</div>
	</div>
</div>
<div class="systools_control-appindicator">
<div data-bind-text="{read source=__control path=$windows}" style="background-color: #FFFFFF; color: #000000;width:100%;height:100%;text-align: center; vertical-align:middle;"></div>
</div>