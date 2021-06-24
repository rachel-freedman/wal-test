<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="WorkflowRibbon.ascx.cs"
    Inherits="PNMsoft.Sequence.AppStudio.WorkflowRibbon" %>
<style type="text/css">
    .menu-toggle {
        position: absolute;
        z-index: 1;
        right: 8px;
        top: 8px;
        width: 20px;
        height: 20px;
        cursor: pointer;
        transition: transform 150ms cubic-bezier(0.55, 0, 0.1, 1);
    }

        .menu-toggle span {
            background: #666666;
            position: absolute;
            right: 0;
            left: 0;
            display: block;
            width: 4px;
            height: 4px;
            margin: auto;
            pointer-events: none;
            border-radius: 50%;
        }

        .menu-toggle.open {
            transform: rotate(90deg);
        }

        .menu-toggle span:nth-child(1) {
            top: 0;
        }

        .menu-toggle span:nth-child(2) {
            top: 50%;
            transform: translateY(-50%);
        }

        .menu-toggle span:nth-child(3) {
            bottom: 0;
        }

    .navigation-visible {
        width: calc(100% - 25px);
    }

    .navigation-invisible {
        position: fixed;
        display: table;
        top: 65px;
        border: 1px solid #eee;
        float: right;
        right: 35px;
        background-color: #fff;
        box-shadow: 0px 1px 3px 1px rgba(0, 0, 0, 0.08);
        margin: 0px;
        padding: 0px;
        overflow: auto;
        opacity: 0;
    }

        .navigation-invisible .RibbonSeperator {
            display: none;
        }

        .navigation-invisible .RibbonButton {
            width: 100%;
            text-align: left;
        }

        .navigation-invisible.on {
            width: 200px;
            opacity: 1;
            z-index: 1;
        }

            .navigation-invisible.on:empty {
                display: none;
            }
</style>
<script type="text/javascript">

    (function ($, undefined) {
        $.widget("appstudion.workflowDiagramBreadcumbs", {
            options: {
                diagramPath: []
            },
            scrollTimer: null,
            scrollStep: 1,
            resizeTimer: null,
            _create: function () {
                var self = this;
                var host = $.diagramsManager;

                $(window).bind("resize", function () {
                    if (self.resizeTimer) {
                        clearTimeout(self.resizeTimer);
                    }
                    self.resizeTimer = setTimeout(function () {
                        self.fixSize();
                        self.prepareMenu();
                    }, 100);
                });

                self.prepareMenu();

                $(document).ready($.proxy(self.populatePath(self.options.diagramPath), self));

                var scrollLeftImage = top.$(".scrollLeftButton", $(self.element));
                var scrollRightImage = top.$(".scrollRightButton", $(self.element));

                $(scrollLeftImage).on({
                    mouseover: $.proxy(self.scrollLeft, self),
                    mouseout: $.proxy(self.stopScroll, self)
                }).hide();

                $(scrollRightImage).on({
                    mouseover: $.proxy(self.scrollRight, self),
                    mouseout: $.proxy(self.stopScroll, self)
                }).hide();

                $(self.element).on("click", ".RibbonBreadCrumb a", $.proxy(function (event) {
                    var target = event.target ? event.target : event.srcElement;
                    self._trigger("diagramChanging", null, { diagramId: $(target).attr("diagramId"), diagramName: $(target).text() });
                    $(self.element).find('A').removeClass("selected");
                    $(target).addClass('selected');
                    self.fixSize();
                }, self));

                if (sourceControlImage) {
                    $(".container-list").prepend(sourceControlImage);
                }
            },
            getPath: function () {
                var self = this;
                return self.options.diagramPath;
            },
            addChild: function (diagramId, diagramName) {
                var self = this;
                var bc = $("<li></li>").addClass("RibbonBreadCrumb");
                var childRef = $("<a href='#'></a>")
                    .addClass("selected").text(diagramName);

                $(childRef).attr("diagramId", diagramId);
                bc.append("<span>&nbsp>&nbsp</span>").append(childRef);
                $(".container-list", $(self.element)).find('A').removeClass("selected");
                $(".container-list", $(self.element)).append(bc);
                self.fixSize();
            },
            highlightPath: function (diagramId) {
                var self = this;
                $(self.element).find('A').removeClass("selected");
                $(self.element).find('A[diagramId="' + diagramId + '"]').addClass("selected");
                self.fixSize();
            },
            populatePath: function (diagramPath) {
                var self = this;
                self.options.diagramPath = diagramPath;
                $(".container-list", $(self.element)).empty();
                for (var i = 0; i < diagramPath.length; i++) {
                    var bc = $("<li></li>").addClass("RibbonBreadCrumb");
                    var childRef = $("<a href='#'></a>")
                        .removeClass("selected").text(diagramPath[i].Name);

                    if (i === diagramPath.length - 1) {
                        $(childRef).addClass("selected");
                    }

                    $(childRef).attr("diagramId", diagramPath[i].DiagramId);
                    if (diagramPath.length > 1 && i > 0) {
                        bc.prepend("<span>&nbsp>&nbsp</span>");
                    }
                    bc.append(childRef);
                    $(".container-list", $(self.element)).append(bc);
                }

                self.fixSize();
            },
            renameDiagram: function (diagramId, diagramName) {
                var self = this;
                $(".container-list", $(self.element)).find('A[diagramId="' + diagramId + '"]').text(diagramName);
                self.fixSize();
            },
            fixSize: function () {
                var self = this;
                var tc = $(".container-list", $(self.element));
                var showScroll = tc.get(0).clientWidth < tc.get(0).scrollWidth;
                if (showScroll) {
                    $(".scrollButton", $(self.element)).each(function () {
                        $(this).show();
                    });
                    var st = $("a.selected", $(self.element));
                    if (st.length > 0) {
                        tc.scrollLeft(st.position().left);
                    }
                } else {
                    $(".scrollButton", $(self.element)).each(function () {
                        $(this).hide();
                    });
                }
            },

            prepareMenu: function () {
                var self = this;

                var container = $("#developmentPanel"), firstMenuItem = container.find('.RibbonButton:first'), menuVisible = container.find(".navigation-visible");

                if (container.find(".navigation-invisible").length === 0) {
                    $("<ul class='navigation-invisible'></ul>").appendTo(container);
                }
                else {
                    container.find(".menu-toggle").remove();
                    container.find(".navigation-invisible").toggleClass("on", false);
                    container.find(".navigation-invisible").children().appendTo(menuVisible);
                }

                menuVisible.find(".RibbonButton").each(function (index, element) {
                    if (Math.round(element.getBoundingClientRect().top) > Math.round(firstMenuItem.get(0).getBoundingClientRect().top)) {
                        $(element).before("<div class='menu-toggle'><span></span><span></span><span></span></div></ul>");
                        return false;
                    }
                });

                var toggle = container.find(".menu-toggle");
                toggle.nextAll().appendTo(".navigation-invisible");

                toggle.unbind().bind('click', function () {
                    toggle.toggleClass("open");
                    container.find(".navigation-invisible").toggleClass("on");
                });
            },

            scrollLeft: function () {
                var self = this;
                var tc = $(".container-list", $(self.element));
                try {
                    if (self.scrollTimer) {
                        clearTimeout(self.scrollTimer);
                    }
                    var scroll = tc.scrollLeft() - self.scrollStep;
                    tc.scrollLeft(scroll);
                    self.scrollTimer = setTimeout($.proxy(self.scrollLeft, self), 10);
                } catch (e) {

                }
            },
            scrollRight: function () {
                var self = this;
                var tc = $(".container-list", $(self.element));
                try {
                    if (self.scrollTimer) {
                        clearTimeout(self.scrollTimer);
                    }
                    var scroll = tc.scrollLeft() + self.scrollStep;
                    tc.scrollLeft(scroll);
                    self.scrollTimer = setTimeout($.proxy(self.scrollRight, self), 10);

                } catch (e) {

                }
            },
            stopScroll: function () {
                var self = this;
                try {
                    if (self.scrollTimer) {
                        clearTimeout(self.scrollTimer);
                    }
                } catch (e) {

                }
            }
        });
    })(jQuery);
</script>
<script type="text/javascript">

    var graph;
    var sourceControlStatus;
    var sourceControlImage;
    var diagramWindow;
    var diagramId;


    // Shows the menu with the specified menuWrapper
    function OpenMenu(menuWrapper) {
        $(menuWrapper).toggleClass('RibbonButtonItemWrapDropDownActive');
        GetMenu(menuWrapper).show();
    }

    function HideMenu(menuWrapper) {
        var menu = GetMenu(menuWrapper);
        if (IsDropDownMenuVisible(menu)) {
            $(menuWrapper).toggleClass('RibbonButtonItemWrapDropDownActive');
            menu.hide();
        }
    }

    function GetMenu(menuWrapper) {
        return $(menuWrapper).children(".RibbonButtonDropDownMenu").first();
    }

    function MenuToggleClick(menuWrapper) {
        var menu = GetMenu(menuWrapper);
        var dropDownVisible = IsDropDownMenuVisible(menu);
        HideDropDownMenus();
        if (!dropDownVisible) {
            OpenMenu(menuWrapper);
        }
    }

    // Hides all drop down menus
    function HideDropDownMenus() {
        $(".RibbonButtonItemWrapDropDown").each(function (e) {
            HideMenu(this);
        });
    }

    // Determines whether the drop down menu is visible or not
    function IsDropDownMenuVisible(menu) {

        if (menu.css("display") == 'none') {
            return false;
        }
        return true;
    }

    // Invokes the action for the ribbon button
    function InvokeMenuAction() {
        var isDisabled = $('#' + arguments[0]).hasClass('RibbonButtonItemWrapDisabled');

        if (!isDisabled) {
            if (window.parent.frames[0].DiagramWindow.$ !== undefined) {
                if (window.parent.frames[0].DiagramWindow.$.diagramsManager.getDiagram().InvokeMenuAction) {
                    window.parent.frames[0].DiagramWindow.$.diagramsManager.getDiagram().InvokeMenuAction(arguments);
                }
            }
            else {
                alert("Please wait for workflow diagram to be fully loaded.");
            }
        }
    }

    function EnableDisableRibbonButtons(workflowElementType, diagramElementTypes, onlyActivitiesSelected, canEnableCopy) {
        var diagramsManagerWindow = window.parent.frames[0].DiagramWindow || top.diagramWindow.parent;
        var activeDiagramId = diagramsManagerWindow.$.diagramsManager.activeDiagramId;
        diagramWindow = diagramsManagerWindow.$.diagramsManager.getDiagram();

        if (!diagramId || diagramId != activeDiagramId) {
            graph = window.parent.frames[0].DiagramWindow.$.diagramsManager.getGraph();
            sourceControlStatus = diagramWindow.GetWorkflowElementSourceControlStatus(graph, false);
            diagramId = activeDiagramId;
        }

        switch (workflowElementType) {
            case diagramElementTypes.Workflow:
                OnWorkflowSelected();
                if (onlyActivitiesSelected) {
                    EnableRibbonButton('ConnectActivities');
                }
                break;
            case diagramElementTypes.Start:
            case diagramElementTypes.StartContainer:
            case diagramElementTypes.EndContainer:
                DisableRibbonButton('CopyWorkflowElements');
                DisableRibbonButton('CutWorkflowElements');
                canEnableCopy = false;
                break;
            case diagramElementTypes.Form:
            case diagramElementTypes.Task:
                EnableAllButtons();
                break;
            case diagramElementTypes.Link:
                DisableAllButtons();
                break;
            case diagramElementTypes.Comment:
                DisableAllButtons();
                break;
            case diagramElementTypes.Swimlane:
                DisableAllButtons();
                break;
            case diagramElementTypes.Label:
                DisableAllButtons();
                break;
            case diagramElementTypes.DiagramContainer:
                DisableAllButtons();
                break;
            case diagramElementTypes.MultipleActivities:
                OnMultipleActivitiesSelected(workflowElementType, diagramElementTypes);
                break;
            default:
                OnActivitySelected(workflowElementType, diagramElementTypes);
                break;
        }

        if (!sourceControlStatus.IsCheckedOutByCurrent) {
            DisableRibbonButton('EditActivity');
        }

        if (!sourceControlStatus.IsCheckedOutByCurrent || !diagramWindow.clipboardInUse) {
            DisableRibbonButton('PasteWorkflowElements');
        }
        else {
            EnableRibbonButton('PasteWorkflowElements');
        }

        DisableInactiveButtons();
        UpdateButtonsText(workflowElementType, diagramElementTypes);

        if (canEnableCopy) {
            EnableRibbonButton('CopyWorkflowElements');
            EnableRibbonButton('CutWorkflowElements');
        }
    }

    function OnWorkflowSelected() {
        $('.Togglable').each(
            function (e) {
                DisableRibbonButton(this.id);
            }
        );

        $('.LinkTogglable').each(
            function (e) {
                var button = $(this);
                if (button.hasClass('AccessValidationOption') && isReadOnly === "false") {
                    EnableRibbonButton(this.id);
                }
                else {
                    DisableRibbonButton(this.id);
                }
            }
        );
    }

    function EnableAllButtons() {
        $('.Togglable, .LinkTogglable')
            .removeClass('RibbonButtonItemWrapDisabled')
            .addClass('RibbonButtonItemWrap');
    }

    function DisableAllButtons() {
        $('.Togglable, .LinkTogglable')
            .removeClass('RibbonButtonItemWrap')
            .addClass('RibbonButtonItemWrapDisabled');
    }

    function ManipulateRibbon(action) {
        action();
    }

    function DisableRibbonButton(buttonId) {
        var button = $('#' + buttonId);
        button.removeClass('RibbonButtonItemWrap').addClass('RibbonButtonItemWrapDisabled');
    }

    function EnableRibbonButton(buttonId) {
        if ((buttonId === "PasteWorkflowElements" && isReadOnly === "false") ||
            (buttonId === "DebugWorkflow") ||
            (buttonId === "DeleteWorkflow" && haveDesignTimeEditPermission === "true") ||
            (buttonId === "RefreshWorkflow") ||
            (buttonId === "SourceControlManagement" && isReadOnly === "false") ||
            (buttonId === "CheckIn" && isReadOnly === "false") ||
            (buttonId === "CheckOut" && isReadOnly === "false") ||
            (buttonId === "UndoChanges" && isReadOnly === "false") ||
            (buttonId === "AddComment" && isReadOnly === "false") ||
            (buttonId === "AddSwimlane" && isReadOnly === "false") ||
            (buttonId === "AddLabel" && isReadOnly === "false") ||
            (buttonId === "AddContainer" && isReadOnly === "false") ||
            (buttonId === "ConnectActivities" && isReadOnly === "false") ||
            (buttonId === "CutWorkflowElements" && isReadOnly === "false") ||
            (buttonId === "ExternalObjectsManagement" && haveDesignTimeManageAttachedObjectsPermission === "true") ||
            (buttonId === "SetPermissions" && haveDesignTimeEditRuntimePermissionsPermission === "true") ||
            (buttonId === "SetAccessPermissions" && haveDesignTimeEditRuntimePermissionsPermission === "true") ||
            (buttonId === "EditActivity" && haveDesignTimeEditRuntimePermissionsPermission === "true") ||
            (buttonId === "CopyWorkflowElements")) {
            var button = $('#' + buttonId);
            button.removeClass('RibbonButtonItemWrapDisabled').addClass('RibbonButtonItemWrap');
        }
    }

    function DisableInactiveButtons() {
        $('.Inactive')
            .removeClass('RibbonButtonItemWrap')
            .addClass('RibbonButtonItemWrapDisabled');
    }

    // Disables "Replace Form" button in
    // Toolbar and enables all other buttons
    function OnActivitySelected(workflowElementType, diagramElementTypes) {
        $('.Togglable').each(function (n) {
            var button = $('#' + this.id);
            if (this.id == 'ReplaceForm' || this.id == 'ConnectActivities'
                || (this.id == 'CopyWorkflowElements' && workflowElementType == diagramElementTypes.Start)
                || (this.id == 'CutWorkflowElements' && workflowElementType == diagramElementTypes.Start)) {
                DisableRibbonButton(this.id);
            }
            else {
                if (isReadOnly === "false") {
                    EnableRibbonButton(this.id);
                }
                else {
                    DisableRibbonButton(this.id);
                }
            }
        });

        $('.LinkTogglable').each(
            function (e) {
                var button = $(this);
                if (isReadOnly === "false") {
                    EnableRibbonButton(this.id);
                }
                else {
                    DisableRibbonButton(this.id);
                }
            }
        );
    }

    function OnMultipleActivitiesSelected(workflowElementType, diagramElementTypes) {
        OnActivitySelected(workflowElementType, diagramElementTypes);
    }

    function OnWorkflowElementsCopied() {
        if (diagramWindow.clipboardInUse) {
            EnableRibbonButton('PasteWorkflowElements');
        }
    }

    function OnButtonEnter(evt) {
        if (evt.target.id.length > 0) {
            $('#' + evt.target.id)
                .removeClass('RibbonButtonItemWrap')
                .addClass('RibbonButtonItemWrapHover');
        }
    }

    function OnButtonLeave(evt) {
        if (evt.target.id.length > 0) {
            $('#' + evt.target.id)
                .addClass('RibbonButtonItemWrap')
                .removeClass('RibbonButtonItemWrapHover');
        }
    }

    function ModifyLinkStyle(linkStyle, event) {
        event.stopPropagation();
        HideDropDownMenus();
        InvokeMenuAction('ChangeLinkStyle', linkStyle);
    }

    function UpdateButtonsText(workflowElementType, diagramElementTypes) {
        var text = null;

        //switch (selectionType)
        switch (workflowElementType) {
            case diagramElementTypes.Workflow:
            case diagramElementTypes.DiagramContainer:
                text = "Set Workflow Permissions";
                break;
            default:
                text = "Set Activity Permissions";
                break;
        }

        $("#SetPermissions > div").text(text);
    }

    function EnableOption(menuItem) {
        var actionName = GetOptionHandlerName(menuItem);
        SetDesignerOptionItemImage(menuItem, true);
        OnDesignerOptionChange(menuItem, true);
        InvokeMenuAction(actionName, true);
        HideDropDownMenus();
    }

    function SetPermissions() {
        InvokeMenuAction('SetPermissions', relPath)
    }

    function SetAccessPermissions() {
        InvokeMenuAction('SetAccessPermissions', relPath)
    }


    function DisableOption(menuItem) {
        var actionName = GetOptionHandlerName(menuItem);
        SetDesignerOptionItemImage(menuItem, false);
        OnDesignerOptionChange(menuItem, false);
        InvokeMenuAction(actionName, false);
        HideDropDownMenus();

    }

    function GetOptionHandlerName(menuItem) {
        return $(menuItem).attr("id");
    }

    function OnDesignerOptionChange(designerOption, enable) {
        var ribbonButtonName = designerOption.id;

        if (ribbonButtonName != "") {
            if (enable) {
                EnableRibbonButton(ribbonButtonName);
            }
            else {
                DisableRibbonButton(ribbonButtonName);
            }
        }
    }

    function SetDesignerOptionItemImage(designerOption, enable) {
        var icon = $(designerOption).find("img").first();
        if (enable) {
            icon.attr("src", "../Resources/Images/Shell/check.gif");
        }
        else {
            icon.attr("src", "../Resources/Images/Shell/uncheck.gif");
        }
    }

    function SetInactiveButton(ribbonButton) {
        $(ribbonButton).addClass("Inactive");
    }

    function SetActiveButton(ribbonButton) {
        $(ribbonButton).removeClass("Inactive");
    }

    function setSourceControlStatus(message) {
        sourceControlImage = $("<img class='SourceControlImage'>");
        sourceControlImage.attr("src", message.image);
        sourceControlImage.attr("title", message.tooltip);
        $(".SourceControlImage").remove();
        $(".container-list").prepend(sourceControlImage);
    }

</script>

<script type="text/javascript">
    top.SEQDT.eventBus.subscribe("setSourceControlStatus", setSourceControlStatus);

    $(document).ready(function () {
        // Hide all drop down menus when clicked in body
        $("body").click(function () { HideDropDownMenus(this); });

        //Initialize ribbon drop down
        $(".RibbonButtonItemWrapDropDown").each(function (e) {
            $(this).click(function (e) {
                e.stopPropagation();
                MenuToggleClick(this);
            })
        });

        $(".DesignerOption").each(
            function (e) {
                var enableOption = $(this).attr("enableOption") == "true";
                OnDesignerOptionChange(this, enableOption);
            });

        $(".AccessValidationOption").each(
            function (e) {
                DisableRibbonButton(this.id);
                EnableRibbonButton(this.id);
            });

        // Link-Style Menu Item 1 event handler
        $("#linkStyleEntityRelation").click(function (event) {
            ModifyLinkStyle(0, event);
        });

        // Link-Style Menu Item 2 event handler
        $("#linkStyleOrthConnector").click(function (event) {
            ModifyLinkStyle(5, event);
        });
    });

    function UploadToVSTS() {


        window.returnValue = undefined; // for chrome
        var wId;
        try {
            wId = document.location.search.replace("?", "").split("&").map(function (item) { var namevalue = item.split("="); return { name: namevalue[0], value: namevalue[1] } }).filter(function (it) { return it.name == "workflowId" })[0].value;
        }
        catch (err) {
            wId = window.frames[0].frames["DiagramWindow"].workflowId;
        }
        var width = 1750;
        var height = 650;
        if (width > window.innerWidth) {
            width = window.innerWidth - 50;
        }
        if (height > window.innerHeight) {
            height = window.innerHeight;
        }
        result = window.showModalDialog(
            "VSTS/VstsPage.aspx?workflowId=" + wId,
            null,
            "status:no; dialogWidth:" + width + "px; dialogHeight:" + height + "px; center:yes;");


        if (result == undefined) // for chrome
        {
            result = window.returnValue;
        }


    }
</script>
<div id="ribbonPanel">
    <div runat="server" id="RibbonHeader" class="RibbonHeader">
        <div class="RibbonLogoContainer">
            <div class="RibbonLogo"></div>
        </div>
        <div runat="server" id="RibbonEnvironment" class="RibbonEnvironment"></div>
        <div class="RibbonBreadcrumbsContainer">
            <asp:Image ID="ScrollLeftImage" runat="server" CssClass="scrollLeftButton scrollButton" Style="display: none;" ImageUrl="~/Web/UI/AppStudio/Resources/Images/Breadcrumbs/ArrowsLeft.png" />
            <ul class="container-list"></ul>
            <asp:Image ID="ScrollRightImage" runat="server" CssClass="scrollRightButton scrollButton" Style="display: none;" ImageUrl="~/Web/UI/AppStudio/Resources/Images/Breadcrumbs/ArrowsRight.png" />
        </div>
        <div class="RibbonOptions">
            <div class="RibbonButton">
                <div id="Options" title="Modify Workflow Canvas display settings" onclick="InvokeMenuAction('OpenWorkflowDesignerSettings');">
                    <asp:Image runat="server" ImageUrl="~/Web/UI/Resources/Images/Shell/options.png" AlternateText="Options" CssClass="RibbonOptionsItemImage" />
                </div>
            </div>
            <sq:HelpLinkButton runat="server" Title="AppStudioWizard" UseSmallLogo="true" ID="helpLinkButton" UseBuiltInStyle="false" CssClass="RibbonHelp" />
        </div>
    </div>
    <div id="developmentPanel" class="RibbonPanel">
        <div class="navigation-visible">
            <div class="RibbonButton" title="Reload the workflow. Do not save recent changes">
                <div id="RefreshWorkflow" class="RibbonButtonItemWrap AccessValidationOption" onclick="InvokeMenuAction('RefreshWorkflow');">
                    <img src="Resources/Images/Ribbon/refresh.png" alt="Reload Workflow" class="RibbonItemImage" />
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton" title="Edit and configure the selected activity">
                <div id="EditActivity" class="RibbonButtonItemWrap Togglable AccessValidationOption" onclick="InvokeMenuAction('EditActivity', relPath);">
                    <img src="Resources/Images/Ribbon/edit.png" class="RibbonItemImage" alt="Edit" />
                </div>
            </div>
            <div class="RibbonButton" title="Copy the selected workflow elements">
                <div id="CopyWorkflowElements" class="RibbonButtonItemWrap Togglable" onclick="InvokeMenuAction('CopyWorkflowElements');">
                    <img src="Resources/Images/Ribbon/copy.png" class="RibbonItemImage" alt="Copy" />
                </div>
            </div>
            <div class="RibbonButton" title="Paste the selected workflow elements on the workflow canvas">
                <div id="PasteWorkflowElements" class="RibbonButtonItemWrap Togglable AccessValidationOption" onclick="InvokeMenuAction('PasteWorkflowElements');">
                    <img src="Resources/Images/Ribbon/paste.png" class="RibbonItemImage" alt="Paste" />
                </div>
            </div>
            <div class="RibbonButton" title="Cut the selected workflow elements">
                <div id="CutWorkflowElements" class="RibbonButtonItemWrap Togglable AccessValidationOption" onclick="InvokeMenuAction('CutWorkflowElements');">
                    <img src="Resources/Images/Ribbon/cut.png" class="RibbonItemImage" alt="Cut" />
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton" title="Connect the selected activities">
                <div id="ConnectActivities" class="RibbonButtonItemWrap Togglable AccessValidationOption" onclick="InvokeMenuAction('ConnectActivities');">
                    <img src="Resources/Images/Ribbon/connect.png" alt="Connect Activities" class="RibbonItemImage" />
                </div>
            </div>
            <div class="RibbonButton" title="Change the display style of links between activities">
                <div id="btnLinkStyles" class="RibbonButtonItemWrapDropDown">
                    <img src="Resources/Images/Ribbon/linkStyle.png" alt="Link Style" class="RibbonItemImage" />
                    <div class="RibbonButtonItemWrapDropDownArrow">
                        <img src="../Resources/Images/Shell/arrow_dr4.gif" />
                    </div>
                    <div id="linkStyleDropDownMenu" class="RibbonButtonDropDownMenu">
                        <!-- Menu Item 1 -->
                        <div id="linkStyleEntityRelation" class="DropDownMenuItem" title="">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/images/Ribbon/linkStyleEntityRelation.png" style="border-width: 0; width: 16px; height: 16px; vertical-align: text-top" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">Straight Connector</span><span style="color: #777777"><br />
                                                Display Straight Link Style</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <!-- Menu Item 2 -->
                        <div id="linkStyleOrthConnector" class="DropDownMenuItem" title="">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/images/Ribbon/linkStyleElbowConnector.png" style="border-width: 0; width: 16px; height: 16px; vertical-align: text-top" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">Right Angle Connector</span><span style="color: #777777"><br />
                                                Display Vertical Orth Link (default)</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton" title="Add a comment to the Workflow Canvas">
                <div id="AddComment" class="RibbonButtonItemWrap DesignerOption AccessValidationOption" onclick="InvokeMenuAction('AddComment');">
                    <img src="Resources/Images/Ribbon/add_comment.png" alt="Add Comment" class="RibbonItemImage" />
                </div>
            </div>
            <div class="RibbonButton" title="Add a swimlane to the Workflow Canvas">
                <div id="AddSwimlane" class="RibbonButtonItemWrap DesignerOption AccessValidationOption" onclick="InvokeMenuAction('AddSwimlane');">
                    <img src="Resources/Images/Ribbon/add_swimlane.png" class="RibbonItemImage" alt="Add Swimlane" />
                </div>
            </div>
            <div class="RibbonButton" title="Add a label to the Workflow Canvas">
                <div id="AddLabel" class="RibbonButtonItemWrap DesignerOption AccessValidationOption" onclick="InvokeMenuAction('AddLabel');">
                    <img src="Resources/Images/Ribbon/add_label.png" class="RibbonItemImage" alt="Add Label" />
                </div>
            </div>
            <div class="RibbonButton" title="Add a container to the Workflow Canvas">
                <div id="AddContainer" class="RibbonButtonItemWrap DesignerOption AccessValidationOption " onclick="InvokeMenuAction('AddContainer');">
                    <img src="Resources/Images/Ribbon/add_container.png" class="RibbonItemImage" alt="Add Container" />
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton" title="Attach external objects to this workflow">
                <div id="ExternalObjectsManagement" class="RibbonButtonItemWrap AccessValidationOption" onclick="InvokeMenuAction('ExternalObjectsManagement');">
                    <img src="Resources/Images/Ribbon/attach.png" class="RibbonItemImage" alt="Attach Objects" />
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton" title="Validate the workflow and discover errors and issues">
                <div id="ValidateWorkflow" class="RibbonButtonItemWrap" onclick="InvokeMenuAction('ValidateWorkflow');">
                    <img src="Resources/Images/Ribbon/validate.png" class="RibbonItemImage" alt="Validate Workflow" />
                    <div>
                        Validate
                    </div>
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton" title="Delete this workflow">
                <div id="DeleteWorkflow" class="RibbonButtonItemWrap AccessValidationOption" onclick="InvokeMenuAction('DeleteWorkflow', relPath);">
                    <img src="Resources/Images/Ribbon/deleteProcess.png" class="RibbonItemImage" alt="Delete Process" />
                    <div>
                        Delete Workflow
                    </div>
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton">
                <div id="ExportMenu" class="RibbonButtonItemWrapDropDown">
                    <img src="Resources/Images/Ribbon/export.png" alt="Export" class="RibbonItemImage" />
                    <div class="RibbonButtonItemWrapDropdDownTitle">Export</div>
                    <div class="RibbonButtonItemWrapDropDownArrow">
                        <img src="../Resources/Images/Shell/arrow_dr4.gif" />
                    </div>
                    <div id="linkStyleDropDownMenu" class="RibbonButtonDropDownMenu">
                        <div id="exportToImage" class="RibbonButtonItemWrap DropDownMenuItem" onclick="InvokeMenuAction('ExportToImage');" title="Export and save an image of the workflow diagram to your local machine">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/images/Ribbon/exportImage.png" alt="Manage" class="DropDownMenuItemIcon" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">Export to Image</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div id="generateDocumentation" class="RibbonButtonItemWrap DropDownMenuItem" onclick="InvokeMenuAction('GenerateDocumentation');" title="Generate Documentation">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/Images/Ribbon/Documentation.png" alt="Generate Documentation" class="DropDownMenuItemIcon" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">Generate Documentation</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div runat="server" id="OrganizationAuthorizationModeRibbonButton" class="RibbonButtonContainer">
                <div class="RibbonButton" title="Define end-user access permissions for this workflow">
                    <div id="SetPermissions" class="RibbonButtonItemWrap AccessValidationOption" onclick="SetPermissions();">
                        <img src="Resources/Images/Ribbon/permission.png" class="RibbonItemImage" alt="Set Permissions" />
                        <div>Set Workflow Permissions</div>
                    </div>
                </div>
            </div>
            <div runat="server" id="RoleBasedAuthorizationModeRibbonButton" class="RibbonButtonContainer">
                <div class="RibbonButton" title="Define end-user access permissions for all workflow versions">
                    <div id="SetAccessPermissions" class="RibbonButtonItemWrap AccessValidationOption" onclick="SetAccessPermissions();">
                        <img src="Resources/Images/Ribbon/permission.png" class="RibbonItemImage" alt="Set Access Permission" />
                        <div>Set Permissions</div>
                    </div>
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton">
                <div id="SourceControlMenu" class="RibbonButtonItemWrapDropDown">
                    <img src="Resources/Images/Ribbon/sourceControl.png" alt="Source Control" class="RibbonItemImage" />
                    <div class="RibbonButtonItemWrapDropdDownTitle">Source Control</div>
                    <div class="RibbonButtonItemWrapDropDownArrow">
                        <img src="../Resources/Images/Shell/arrow_dr4.gif" />
                    </div>
                    <div id="linkStyleDropDownMenu" class="RibbonButtonDropDownMenu">
                        <div id="SourceControlManagement" class="DropDownMenuItem AccessValidationOption" onclick="InvokeMenuAction('SourceControlManagement');" title="Manage source control options for the workflow. Check in and check out the workflow or its activities">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/images/Ribbon/manage.png" alt="Manage" class="DropDownMenuItemIcon" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">Manage</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div id="CheckIn" class="DropDownMenuItem LinkTogglable AccessValidationOption" onclick="InvokeMenuAction('CheckIn');" title="Check in the workflow or its activities">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/images/Ribbon/checkIn.png" alt="Check In" class="DropDownMenuItemIcon" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">Check In</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div id="CheckOut" class="DropDownMenuItem LinkTogglable AccessValidationOption" onclick="InvokeMenuAction('CheckOut', false, true);" title="Check out the workflow or its activities">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/images/Ribbon/checkOut.png" alt="Check Out for Edit" class="DropDownMenuItemIcon" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">Check Out for Edit</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div id="ViewHistory" class="DropDownMenuItem" onclick="InvokeMenuAction('ViewHistory');" title="View source control history for the workflow or its activities">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/images/Ribbon/history.png" alt="View History" class="DropDownMenuItemIcon" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">View History</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div id="UndoChanges" class="DropDownMenuItem LinkTogglable AccessValidationOption" onclick="InvokeMenuAction('UndoChanges', false);" title="Undo recent check in/check out actions on the workflow or its activities">
                            <table cellspacing="0" cellpadding="2" border="0" style="border-collapse: collapse">
                                <tbody>
                                    <tr>
                                        <td>
                                            <img src="Resources/images/Ribbon/undo.png" alt="Check Out for Edit" class="DropDownMenuItemIcon" />
                                        </td>
                                        <td>
                                            <span style="padding-bottom: 5px;">Undo Changes</span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="RibbonSeperator">
            </div>
            <div class="RibbonButton" title="Start workflow execution in the Process Lab">
                <div id="DebugWorkflow" class="RibbonButtonItemWrap AccessValidationOption" onclick="InvokeMenuAction('DebugWorkflow', relPath);">
                    <img src="Resources/Images/Ribbon/debug.png" class="RibbonItemImage" alt="Debug" />
                    <div>
                        Process Lab
                    </div>
                </div>
            </div>
             <div class="RibbonButton" title="Commit to Azure DevOps.">
	            <div id="uploadToVSTS" class="RibbonButtonItemWrap" onclick="UploadToVSTS();">
	                <img src="Resources/images/Ribbon/Checkin.png" class="RibbonItemImage" alt="Upload to VSTS" />
	                <div>
        	            Commit to Azure DevOps
	                </div>
	            </div>
	        </div>
	        <div class="RibbonSeperator">
	        </div>
        </div>
    </div>
</div>
