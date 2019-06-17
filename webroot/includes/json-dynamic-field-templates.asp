<div class="j_framework_dynamic_field_text">
	<label style="width: inherit; min-width: 250px; text-align: right; vertical-align: middle; display: inline-block; padding-right: 10px;"
		   data-bind-text="{read source=__control path=$displayname customformat=__control:RequiredFieldFormatter,__control:ColonSignFormatter}"
	>
	</label>
	<input style="vertical-align: middle;" type="text" class="c_main_text_box" data-bind-val="{bind source=__control path=$valueinternal validator='../validator'}" />
	<img data-class="CValidator" style="width: 20px; height: 20px; vertical-align: middle;" data-key="validator"
		 data-bind-$rules="{read source=__control path=$validatorrules}" 
	/>
</div>

<div class="j_framework_dynamic_field_numeric">
	<label style="width: inherit; min-width: 250px; text-align: right; vertical-align: middle; display: inline-block; padding-right: 10px;"
		   data-bind-text="{read source=__control path=$displayname customformat=__control:RequiredFieldFormatter,__control:ColonSignFormatter}"
	>
	</label>
	<input style="vertical-align: middle;" type="text" class="c_main_text_box" data-bind-val="{bind source=__control path=$valueinternal validator='../validator'}" />
	<img data-class="CValidator" style="width: 20px; height: 20px; vertical-align: middle;" data-key="validator"		
		 data-bind-$rules="{read source=__control path=$validatorrules}"		 
	/>
</div>

<div class="j_framework_dynamic_field_boolean">
	<label style="width: inherit; min-width: 250px; text-align: right; vertical-align: middle; display: inline-block; padding-right: 10px;"
		   data-bind-text="{read source=__control path=$displayname customformat=__control:ColonSignFormatter}"
	>
	</label>
	<div style="display: inline-block; vertical-align: middle;" data-class="UCheckBox" data-bind-$value="{bind source=__control path=$valueinternal}"></div>
</div>

<div class="j_framework_dynamic_field_date">
	<label style="width: inherit; min-width: 250px; text-align: right; vertical-align: middle; display: inline-block; padding-right: 10px;"
		   data-bind-text="{read source=__control path=$displayname customformat=__control:RequiredFieldFormatter,__control:ColonSignFormatter}"
	>
	</label>
	<div class="c_expander" 
		 style="width: inherit; display: inline-block; vertical-align: middle;"
		 data-key="CalendarPanel" 
		 data-class="CExpander" 
		 data-on-$expandeddevent="{bind source=__control/callendarinstance path=onOpen}"
	>
		<div data-key="InactiveHeader">
			<input type="text" class="c_main_text_box" data-class="CCalendarDropDown" data-key="userSelectedDate" data-bind-$calendar="{bind source=__control/callendarinstance path=$selectedDate readdata=$daySelection format=DateLong}"/>
		</div>
		<div data-key="ActiveHeader"></div>
		<div data-key="Body" style="margin:0; border: 1px solid black;">
			<input type="text" class="c_main_text_box" data-class="CCalendarDropDown" data-key="userSelectedDate" data-bind-$calendar="{bind source=__control/callendarinstance path=$selectedDate readdata=$daySelection format=DateLong}"/>
			<div data-key="callendarinstance" data-class="CCalendarElement selectedCssClass='ExampleCalendarSelectedDay' expanderpath='__control/CalendarPanel'"></div>
		</div>
	</div>
</div>

<div class="j_framework_dynamic_field_lookup">
	<label style="width: inherit; min-width: 250px; text-align: right; vertical-align: middle; display: inline-block; padding-right: 10px;"
		   data-bind-text="{read source=__control path=$displayname customformat=__control:RequiredFieldFormatter,__control:ColonSignFormatter}"
	>
	</label>
	<div style="display: inline-block; vertical-align: middle;"
		 data-class="UDropDown keyproperty='lookupkey' descproperty='lookupdescription'"
		 data-bind-$items="{read(0) source=__control path=$lookup}"
		 data-bind-$value="{bind(1) source=__control path=$valueinternal}"
	>
	</div>
</div>

<div class="j_framework_dynamic_field_multiple_inputs">
	<label style="width: inherit; min-width: 250px; text-align: right; vertical-align: top; display: inline-block; padding-right: 10px;"
		   data-bind-text="{read source=__control path=$displayname customformat=__control:RequiredFieldFormatter,__control:ColonSignFormatter}"
	>
	</label>
	<div style="display: inline-block; vertical-align: middle; padding: 5px 5px 5px 2px; border: 1px dotted #ccc; background-color: #F0F0F0;"
		 data-class="CBase" 
		 data-key="multiInputs"
	>
		<div data-class="CRepeater" data-bind-$items="{bind source=__control path=$valueinternal format=__control:Gg flags=workdata}" data-parameters="storeIndexIn='index'">
			<div>
				<input type="text" class="c_main_text_box" data-bind-val="{bind path=value flags=values}" />
				<div style="cursor: pointer; display: inline-block; padding: 4px;"
					 data-on-click="{bind source=__control path=onRemoveInput ref[fieldset]=multiInputs@}"
				>
					<img width="16px"
						 style="vertical-align: middle;"					 
						 data-class="CImage basePath='img/blue/'" 
						 data-bind-$src="{read source=static text='minus-128.png'}"					 
					/>
				</div>
			</div>
		</div>
		<div style="cursor: pointer; display: inline-block; padding: 4px;"
			 data-on-click="{bind source=__control path=onAddInput ref[fieldset]=multiInputs@}"
		>
			<img width="16px"
				 style="vertical-align: middle;"
				 data-class="CImage basePath='img/blue/'" 
				 data-bind-$src="{read source=static text='plus-128.png'}"
			/>
		</div>
	</div>
</div>

<div class="j_framework_dynamic_view_template">
	<div data-class="CDynamicViewBase" data-key="viewroot">
		<h1 data-bind-text="{read source=viewroot path=$configurations.title}"></h1>		
		{{complexFieldTemplate}}
		<br />
		<input type="button" class="client_tools_buttons" value="Save" data-on-click="{bind source=viewroot path=onSave ref[r]=viewroot/response@}" />
		<br />
		<br />
		<div style="border: 2px dotted #ccc; display: inline-block; padding: 5px; background-color: #F2F2F2">
			<strong style="vertical-align: top;">Response from server: </strong>
			<div style="display: inline-block;" data-class="UDataViewer !expanded='true'" data-key="response"></div>
		</div>
	</div>
	<style>
		.borderedComplexFieldsCss {
			border: 3px dashed red;
			padding: 15px;
			margin: 5px;
		}
	</style>
</div>

<div class="j_framework_complex_field_linear_template">
	<div data-class="CComplexDynamicField"
		 data-bind-$configurations="{read source=__control path=$configurations.{{complexFieldId}}.fields}"
		 data-context="{bind source=__control path=$data.{{complexFieldId}} createleaf=object}"
		 data-bind-cssclass="{read service=PDynamicFieldDefinitionsApp path=$borderedComplexFieldsCss}"
	>
		{{fieldsHtml}}
	</div>
</div>

<div class="j_framework_complex_field_colonial_template">
	<div data-class="CComplexDynamicField"
		 data-bind-$configurations="{read source=__control path=$configurations.{{complexFieldId}}.fields}"
		 data-context="{bind source=__control path=$data.{{complexFieldId}} createleaf=object}"
		 data-bind-cssclass="{read service=PDynamicFieldDefinitionsApp path=$borderedComplexFieldsCss}"
	>
		{{fieldsHtml}}
	</div>
</div>

<div class="j_framework_........" data-class="........"	data-bind-$cssdefinitions="....">
	{{validator}}
</div>