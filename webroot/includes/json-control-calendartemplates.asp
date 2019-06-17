
<!-- BEGIN DATE PICKER TEMPLATES - should be moved elsewhere -->
<div class="j_datepicker_conrol" >
     <div class="indigo">
         <table >
             <tr>
                 <td style="width:70px;"><div data-bind-text="{read source=__control path=$caption}"></div></td>
                 <td><div data-bind-text="{bind source=__control path=$selecteddate format=DateShort}" data-on-click="{bind source=__control path=onShowPicker}"></div></td>
            
            <td style="width:70px;"><div  style="width:20px;" 
                 data-class="VirtualDropDownControl keyproperty='hourval' descproperty='hour'"
                            data-bind-$items="{read source=__control path=$hours}"
                            data-bind-$value="{bind source=__control path=$workhour}" 
                            data-on-$selchangedevent="{bind source=__control path=onHourchange}"
                             >

                        </div></td>
            <td>:</td><td style="width:70px;">
                <div data-class="VirtualDropDownControl keyproperty='minuteval' descproperty='minute'"
                            data-bind-$items="{read source=__control path=$minutes}"
                            data-bind-$value="{bind source=__control path=$workminute}" 
                            data-on-$selchangedevent="{bind source=__control path=onMinutechange}">                            
                 </div>
             </td>
             </tr>
           
        </table>    
        <div data-key="datepicker_view" style="display: none;"></div>

     </div>
</div> 
<div class="j_date_picker_month_view">
	<div data-class="DatePickerMonthView @navdate={read source=__control path=$selecteddate}"
		 data-key="viewroot">
		 <table class="calcontainer" style="margin-left:auto; margin-right:auto;">
						<tr>
							<td><div class="cal-button cal-small cal-theme-action" data-on-click="{bind source=viewroot path=onprevyear}"><span data-bind-text="{read source=viewroot path=$prevyear}"/></div></td>
							<td><div class="cal-button cal-small cal-theme-action" data-on-click="{bind source=viewroot path=onprev}"><span data-bind-text="{read source=viewroot path=$prevmonth}"/></div></td>
							<td class="cal-theme-d3" data-bind-text="{bind source=viewroot path=$navdate format=DateShort}"></td>
							<td><div class="cal-button cal-small cal-theme-action" data-on-click="{bind source=viewroot path=onnext}"><span data-bind-text="{bind source=viewroot path=$nextmonth}"/></div></td>
							<td><div class="cal-button cal-small cal-theme-action" data-on-click="{bind source=viewroot path=onnextyear}"><span data-bind-text="{bind source=viewroot path=$nextyear}"/></div></td>
						</tr>
                </table>
        <table> 
            <tr data-class="Repeater" data-bind-$items="{read source=viewroot path=$weekdayheaders}">
                <td class="cal-theme-d3" style="width:30px;text-align:center;" data-bind-text="{read}"></td>
            </tr>
        </table>
        <table data-class="Repeater" data-bind-$items="{read source=viewroot path=$monthmatrix}">

            <tr data-class="Repeater" data-bind-$items="{read}">
                   <td style="width:30px;text-align:right;vertical-align:top"
                    data-bind-elementattribute[class]="{read path=theme}"
                    data-on-click="{read source=viewroot path=onSelectionChanged}"
                   	>
                    <div data-bind-text="{read path=currenday}"></div>
				                 
                </td>
            </tr>
        </table>
	</div>
</div> 
<div class="j_date_picker_year_view">
	<div data-class="DatePickerView @workdate={read source=__control path=$workdate}"
		 data-key="viewroot"
		 data-on-$workdatechanged="read source=__control path=onWorkDateChanged">
		<table class="calcontainer">
				<tr>
					<td style="width:38px"><div class="btn" data-on-click="{bind source=viewroot path=onprevyear}"><span data-bind-text="{bind source=viewroot path=$prevyear readdata=$workdatechanged}"/></div></td>
					<td style="width:28px"><div class="btn" data-on-click="{bind source=viewroot path=onprev}"><span data-bind-text="{bind source=viewroot path=$prevmonth readdata=$workdatechanged}"/></div></td>
					<td style="width:50px" data-bind-text="{bind source=viewroot path=$workdate format=DateShort readdata=$workdatechanged}"></td>
					<td style="width:28px"><div class="btn" data-on-click="{bind source=viewroot path=onnext}"><span data-bind-text="{bind source=viewroot path=$nextmonth readdata=$workdatechanged}"/></div></td>
					<td style="width:38px"><div class="btn" data-on-click="{bind source=viewroot path=onnextyear}"><span data-bind-text="{bind source=viewroot path=$nextyear readdata=$workdatechanged}"/></div></td>
				</tr>
			</table>
		<table>
		<tr data-class="Repeater" data-bind-$items="{read source=viewroot path=$weekdayheaders}">
			<td style="background-color:tomato;width:26px;text-align:center;" data-bind-text="{read}"></td>
		</tr>
	   </table>
		<table data-class="SelectableRepeater" data-bind-$items="{read source=viewroot path=$monthmatrix}">
			<tr data-class="SelectableRepeater" data-bind-$items="{read}">
				<td style="text-align:right;vertical-align:top;width:26px"
					data-bind-backcolor="{read path=color customformat=viewroot:changeColor}"
					data-on-click="{read source=viewroot path=onSelectionChanged}">
					<div data-bind-text="{read path=currenday}"></div>
				</td>
			</tr>
		</table>
	</div>
</div> 


<!-- END DATE PICKER TEMPLATES - should be moved elsewhere -->


	<div class="j_calendar_conrol">
		<div data-bind-elementattribute[class]="{read source=__control path=$theme}">

			<div  data-class="SelectableRepeater identification='mode' selectedCssClass='sfsf'" 
				data-bind-$items="{read source=__control path=$modes}"
				data-bind-$value="{probe source=__control path=$mode writedata=$activatedevent}"
				>
				<input class="cal-button cal-medium cal-theme-action"  type="button" data-bind-val="{read path=mode}" data-on-click="{bind source=__control path=ChangeMode}" />
			    
		    </div>
            <div style="display:inline-block" data-class="SelectableRepeater identification='theme' selectedCssClass='sfsf'" 
				data-bind-$items="{read source=__control path=$themes}"
				data-bind-$value="{probe source=__control path=$theme writedata=$activatedevent}"
				>
				<input class="cal-button cal-small cal-theme-action"  type="button" 
                    data-bind-val="{read path=theme}" 
                    data-on-click="{bind source=__control path=ChangeTheme}"
                    data-bind-backcolor="{read path=col}"/>
			    
		    </div>
            <div data-key="calendar_view"></div>
	    </div>
    </div>
     
    <div class="j_calendar_month_view">
		<div data-class="CalendarMonthView" data-key="viewroot">
        <table class="calcontainer" style="margin-left:auto; margin-right:auto;">
						<tr>
							<td><div class="cal-button cal-medium cal-theme-action" data-on-click="{bind source=viewroot path=onprevyear}"><span data-bind-text="{bind source=viewroot path=$prevyear}"/></div></td>
							<td><div class="cal-button cal-medium cal-theme-action" data-on-click="{bind source=viewroot path=onprev}"><span data-bind-text="{bind source=viewroot path=$prevmonth}"/></div></td>
							<td class="cal-theme-d3" data-bind-text="{bind source=viewroot path=$navdate format=DateShort}"></td>
							<td><div class="cal-button cal-medium cal-theme-action" data-on-click="{bind source=viewroot path=onnext}"><span data-bind-text="{bind source=viewroot path=$nextmonth}"/></div></td>
							<td><div class="cal-button cal-medium cal-theme-action" data-on-click="{bind source=viewroot path=onnextyear}"><span data-bind-text="{bind source=viewroot path=$nextyear}"/></div></td>
						</tr>
                </table>
        <table style="width:90%; margin-left:auto; margin-right:auto;">
            <tr data-class="Repeater" data-bind-$items="{read source=viewroot path=$weekdayheaders}">
                <td class="cal-theme-d3" style="width:14.28%;min-width:100px;height:50px;text-align:center;" data-bind-text="{read}"></td>
            </tr>
        </table>
        <table style="width:90%; margin-left:auto; margin-right:auto;" data-class="Repeater" data-bind-$items="{read source=viewroot path=$monthmatrix}">

            <tr data-class="Repeater" data-bind-$items="{read}">
                   <td style="width:14.28%;min-width:100px;height:100px; vertical-align:top"
                    data-bind-elementattribute[class]="{read path=theme}"
                    data-on-click="{read source=viewroot path=onSelectionChanged}"
                   	>
                    <div data-bind-text="{read path=currenday}" style="text-align:right;"></div>
					<div data-class="Repeater" data-bind-$items="{read path=items}">
                        <div style="border-radius: .2em;"
                             data-bind-elementattribute[class]="{read path=theme}"
                             data-on-click="{read source=viewroot path=onEditClick}"
                             >
                            <div data-bind-text="{read path=event}"></div>
                            <div data-bind-text="{read path=organizer}"></div>
                        </div>
                    </div>
                    <br />
                    <input class="cal-button cal-medium cal-theme-action" type="button" Value="More" data-bind-elementvisible="{read path=showmore}" data-on-click="{read source=viewroot path=onMoreButtonClick}"/>
                    <input class="cal-button cal-medium cal-theme-action" type="button" Value="Details" data-bind-elementvisible="{read path=isActive}" data-on-click="{read source=viewroot path=onDetailsButtonClick}"/>
                </td>
            </tr>
        </table>
	</div>
</div>
<div class="j_calendar_day_view">
		<div data-class="CalendarDayView" data-key="viewroot">
		     <table class="calcontainer">
                    <tr>
                        <td><div class="cal-button cal-medium cal-theme-action" data-on-click="{bind source=viewroot path=onprevyear}"><span data-bind-text="{bind source=viewroot path=$prevyear}"/></div></td>
                        <td><div class="cal-button cal-medium cal-theme-action" data-on-click="{bind source=viewroot path=onprev}"><span data-bind-text="{bind source=viewroot path=$prevmonth}"/></div></td>
                        <td class="cal-theme-d3" data-bind-text="{bind source=viewroot path=$navdate format=DateShort}"></td>
                        <td><div class="cal-button cal-medium cal-theme-action" data-on-click="{bind source=viewroot path=onnext}"><span data-bind-text="{bind source=viewroot path=$nextmonth}"/></div></td>
                        <td><div class="cal-button cal-medium cal-theme-action" data-on-click="{bind source=viewroot path=onnextyear}"><span data-bind-text="{bind source=viewroot path=$nextyear}"/></div></td>
                    </tr>
             </table>
            <table class="calcontainer">
				<tbody data-class="Repeater" data-bind-$items="{read source=viewroot path=$hours}">
                <tr data-class="Repeater" data-bind-$items="{read path=items}">
                     <td 	data-bind-elementattribute[rowspan]="{read path=durac}" 
							data-bind-elementattribute[class]="{read path=theme}" 
							style="height:50px;vertical-align:top;">
                         <div class="cal-theme-d5" data-bind-text="{read path=hour}"></div>       
                         <div data-bind-text="{read path=event}"></div>
                         <div data-bind-text="{read path=organizer}"></div>
						 <input type="button" data-on-click="{read source=viewroot path=onEditClick}" data-bind-elementvisible="{read path=durac}" Value="Edit"/>
                     </td>
                </tr>
				</tbody>
            </table>
        </div>
	</div>
    <div class="j_calendar_week_view">
		<span data-bind-text="{read path=caldc.month}"></span>
		<span data-bind-text="{read path=caldc.year}"></span>
		<span data-bind-text="{read path=caldc.day}"></span>
		<span>Test</span>	
		<table style="width:1400px">
			<tr data-class="Repeater" data-bind-$items="{read source=__control path=$caldc.days.0}">
				<th style="background-color:tomato;width:200px;height:50px;text-align:center;" data-bind-text="{read}"></th>
			</tr>
			<tr data-class="Repeater" data-bind-$items="{read source=__control path=$caldc.days.0}">
				<td>
					<table data-class="Repeater" data-bind-$items="{bind source=__control path=$caldc.hours}">
						<tr>
							<td class="table-holder" style="min-width:50px; height:50px; vertical-align:top;">
								<div style="text-align:right" data-bind-text="{read}"></div>
							</td>
							<td class="table-holder" style="width:100%; height:50px; vertical-align:top;">
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>