<div style="display:none">
    <div id="mw_main_window_template" class="mw_position_relative">
      <div class="f_windowframe f_tabset" data-key="_window">
        <table class="c_full_width c_font_size_14 mw_background_white  mw_bottom_border_none" data-sys-height="true">
            <tbody>
            <tr>
                <td class="mw_ribbon_background">
                    <table data-class="CBase" data-context-border="true" data-bind-$data="{read service=PMockVisitWorkflow path=$ribbondata}">
                        <tbody>
                            <tr>
                                <td class="c_vertical_align_top mw_margin_bottom_20">
                                    <img class="c_margin_top_10 c_margin_left_25 c_margin_Right_10" src="img/3M_Logo.png">
                                </td>
                                <td class="c_vertical_align_top c_padding_top_12">
                                    <div class="c_display_inline_block mw_font_color_white">
                                        <div class="c_display_inline_block c_vertical_align_super" data-bind-text="{read path=workflowheader.nameandage}"></div>

                                        <div class="c_display_inline_block c_vertical_align_super c_margin_left_10">
                                            <span class="c_font_weight_bold">VisitID: </span>
                                            <span data-bind-text="{read path=workflowheader.accountnumber}"></span>
                                        </div>

                                        <div class="c_display_inline_block c_vertical_align_super c_margin_left_10">
                                            <span class="c_font_weight_bold">MRN: </span>
                                            <span data-bind-text="{read path=workflowheader.medicalrecordnumber}"></span>
                                        </div>
                                        <div class="c_display_inline_block c_vertical_align_super c_margin_left_10" data-bind-text="{read path=workflowheader.visittype}"></div>
                                        <div class="c_display_inline_block c_vertical_align_super c_margin_left_10" data-bind-text="{read path=workflowheader.facilityabbreviation}"></div>
                                        <div class="c_display_inline_block c_vertical_align_super c_margin_left_10 c_margin_right_10" data-bind-text="{read path=workflowheader.location}"></div>
                                    </div>
                                </td>
                                <td class="c_vertical_align_top c_padding_top_12">
                                    <div class="c_display_inline_block mw_font_color_white mw_padding_left_150">
                                        <span data-bind-text="{read path=workflowheader.i9i10mode}"></span>
                                        <span data-bind-text="{read path=workflowheader.labelworkingdrg}"></span>
                                    </div>
                                </td>
                                <td class="c_vertical_align_top c_padding_top_12">
                                    <div class="c_display_inline_block mw_font_color_white mw_padding_left_150">
                                        <span data-bind-text="{read path=workflowheader.financialclass}"></span>
                                        <span>LOS: </span>
                                        <span data-bind-text="{read path=workflowheader.lengthofstay}"></span>
                                        <span class="c_font_weight_bold">ADt: </span>
                                        <span data-bind-text="{read path=workflowheader.admitdate}"></span>
                                        <span class="c_font_weight_bold">DDt: </span>
                                    </div>
                                </td>
                                <td class="c_vertical_align_top c_padding_top_12">
                                    <div class="c_display_inline_block mw_font_color_white mw_padding_left_150">
                                        <a href="#" class="mw_font_color_white">About</a>
                                        <a href="#" class="mw_font_color_white">Help</a>
                                    </div>
                                </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td colspan="2" class="mw_text_align_right c_margin_left_10">
                                <input type="button" class="c_main_button c_margin_left_5" value="Assign/Unassign...">
                                <input type="button" class="c_main_button c_margin_left_5" value="Create Query...">
                                <input type="button" class="c_main_button c_margin_left_5" value="Add Finding..."  data-on-click="{bind service=AddFindingButtonService path=onAddFindingClick}">
                                <input type="button" class="c_main_button c_margin_left_5" value="Follow-Up..." data-on-click="{bind service=FollowUpButtonService path=onFollowUpClick}">
                                <input type="button" class="c_main_button c_margin_left_5" value="Send Notifications...">
                                <input type="button" class="c_main_button c_margin_left_5" value="Open Next">
                                <input type="button" class="c_main_button c_margin_left_5" value="Close" data-on-click="{bind service=FollowUpButtonService path=onAppCloseClick}">
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </td>
            </tbody>
        </table>
        <div data-key="_client" style="position: relative;background-color: #FFFFFF;"></div>
      </div>
    </div>
</div>