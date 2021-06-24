<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VstsPage.aspx.cs" Inherits="PNMsoft.Sequence.AppStudio.Vsts.VstsPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

    <title title="VSTS Page"></title>
   
    <style  type="text/css" >
        
.hidden {
    display: none;
}

.title {
    font: bolder;
    color: dimgray;
    align-content: center;
    font-size: 16px !important;
}

.grdContent {
    width: 100%;
    border: solid 0px Silver;
    min-width: 80%;
    min-height: 25px;
    padding-left: 8px;
    font-weight: 400;
    font-size: 12px !important;
    font-family: "Segoe UI", Verdana, Tahoma !important;
    text-align: left;
}

.header {
    background-color: #9DA4A7;
    font-weight: 100;
    color: White;
    min-height: 25px;
    padding-left: 8px;
    font-weight: 400;
    font-size: 12px !important;
    font-family: "Segoe UI", Verdana, Tahoma !important;
    text-align: left;
    border: solid 2px Silver;
}

.rows {
    font-size: 12px;
    color: black;
    min-height: 25px;
    padding-left: 8px;
    font-weight: 400;
    font-size: 12px !important;
    font-family: "Segoe UI", Verdana, Tahoma !important;
    text-align: left;
    border: solid 2px Silver;
}

.mygrdContent td {
    padding: 5px;
}

.mygrdContent th {
    padding: 5px;
}

#uPanelWorkItems > * {
    margin: 20px 0px;
}

#ButtonsContainer > * {
    margin: 0px 5px;
}
body {
   font-family: "Segoe UI", Verdana, Tahoma !important;
}
CheckBox {
    text-align: center;
    align-content: center;
}

#ButtonAdd {
    color: black;
    background: silver;
    border-radius: 3px;
    border: solid 2px silver;
    width: 150px;
}

.fButton {
    color: #6496c8;
    background: rgba(0,0,0,0);
    border: solid 2px #6496c8;
    border-radius: 3px;
    width: 100px;
    height: 40px;
}

    .fButton:hover, .fButton.hover {
        border-color: #346392;
        color: white;
        background-color: #346392;
        border-radius: 3px;
        width: 100px;
        height: 40px;
    }

    .fButton:active, .fButton.active {
        border-color: #27496d;
        background-color: #27496d;
        color: white;
        border-radius: 3px;
        width: 100px;
        height: 40px;
    }

    .update-progress {
	background: #fff;
	height: 100%;
	left: 0;
	position: absolute;
	top: 0;
	width: 100%;
	opacity: .8;
	filter: alpha(opacity=80);
	zoom:1;
	z-index:9998;
}
    .update-progress-gif {
	background: url(../../Resources/Images/WebControls/BusyIndicator.gif) top left no-repeat;
	position: absolute;
	top: 50%;
	width: 50%;
	left: 50%;
	height: 50%;
	z-index:9999;


    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="PageScriptManager" runat="server" AsyncPostBackTimeout="3600" EnablePageMethods="true">
            <Scripts>
                <asp:ScriptReference Path="~/Shared Resources/js/jQuery/jquery.min.js" />
                <asp:ScriptReference Path="~/Shared Resources/js/jQuery/jQueryInclude.js" />
            </Scripts>
            <Services>
                <asp:ServiceReference Path="PrepareWorkflowForVsts.asmx" />
            </Services>
        </asp:ScriptManager>

        <script type="text/javascript">

            var senderButtonIdGlobal = "";

            function pageLoad(sender, args) {

                if ($("input[id$='WorkflowPreparedCheckBox']").is(':checked')) {

                    $("div[id$='WorkflowPreparationPanel']").css("display", "none");

                    if (typeof successMessage !== "undefined") {
                        alert(successMessage);

                        top.closeDialog(window);

                    }
                }
            }

            function WorkflowPreparationSucceded(status) {

                $("div[id$='WorkflowPreparationPanel']").css("display", "none");
                $("input[id$='OkButton']").prop('disabled', true);
                $("input[id$='WorkflowPreparedCheckBox']").prop('checked', true);

                document.getElementById("<%=HiddenButtonOkClick.ClientID %>").click();
            }

            function WorkflowPreparationFailed(error) {

                $("div[id$='WorkflowPreparationPanel']").css("display", "none");
                $("input[id$='OkButton']").prop('disabled', true);
                $("input[id$='WorkflowPreparedCheckBox']").prop('checked', false);

                alert("Failed to prepare the workflow for upload to VSTS.");
                document.getElementById("<%=HiddenButtonOkClick.ClientID %>").click();
            }




            function WorkflowPreparationGitHubSucceded(status) {

                $("div[id$='WorkflowPreparationPanel']").css("display", "none");
                $("input[id$='OkButton']").prop('disabled', true);
                $("input[id$='WorkflowPreparedCheckBox']").prop('checked', true);

                document.getElementById("<%=HiddenButtonOkGitHubClick.ClientID %>").click();
            }

            function WorkflowPreparationGitHubFailed(error) {

                $("div[id$='WorkflowPreparationPanel']").css("display", "none");
                $("input[id$='OkButton']").prop('disabled', true);
                $("input[id$='WorkflowPreparedCheckBox']").prop('checked', false);

                alert("Failed to prepare the workflow for upload to GitHub.");
                document.getElementById("<%=HiddenButtonOkGitHubClick.ClientID %>").click();
            }





            function getQueryVariable(variable) {

                var query = window.location.search.substring(1);
                var vars = query.split("&");
                for (var i = 0; i < vars.length; i++) {
                    var pair = vars[i].split("=");
                    if (pair[0] == variable) { return pair[1]; }
                }
                return (false);
            }



            function BeginRequestHandler(sender, args) {
                if (sender._postBackSettings.sourceElement.id.indexOf("OkButton") != -1) {
                    okButton.disabled = true;
                    cancelButton.disabled = true;
                }
            }

            function EndRequestHandler(sender, args) {
                document.body.style.cursor = "default";

                if (sender._postBackSettings.sourceElement.id.indexOf("OkButton") != -1
                    && okButton != null) {
                    okButton.disabled = false;
                    cancelButton.disabled = false;
                }

                if (args.get_error() != undefined) {
                    var errorMessage = args.get_error().message;
                    errorMessage = errorMessage.split("Exception:");

                    if (errorMessage.length > 1) {
                        errorMessage = errorMessage[1].trim();
                    }
                    else {
                        errorMessage = errorMessage[0].trim();
                    }

                    if (errorMessage == null || errorMessage == "") {
                        // Error occurred somewhere other than the server page.
                        errorMessage = 'An unspecified error occurred.';
                    }

                    args.set_errorHandled(true);

                    alert(errorMessage);
                }
            }

            function checkAll(gvExample, colIndex) {

                var GridView = gvExample.parentNode.parentNode.parentNode.parentNode;
                for (var i = 1; i < GridView.rows.length; i++) {
                    var chb = GridView.rows[i].cells[colIndex].getElementsByTagName("input")[0];
                    if (chb != "undefined") {
                        try {
                            chb.checked = gvExample.checked;
                        }
                        catch (err) {
                        }
                    }
                }
                CheckEnableOkButton();
            }

            function checkItem_All(objRef, colIndex) {
                var GridView = objRef.parentNode.parentNode.parentNode.parentNode;
                var selectAll = GridView.rows[0].cells[colIndex].getElementsByTagName("input")[0];
                if (!objRef.checked) {
                    selectAll.checked = false;
                }
                else {
                    var checked = true;
                    for (var i = 1; i < GridView.rows.length; i++) {
                        var chb = GridView.rows[i].cells[colIndex].getElementsByTagName("input")[0];
                        if (!chb.checked) {
                            checked = false;
                            break;
                        }
                    }
                    selectAll.checked = checked;
                    CheckEnableOkButton();

                }
            }

            function ClosePopUp() {

                top.closeDialog(window);
            }

            function PrepareWorkflowForGitHub() {
                $("div[id$='WorkflowPreparationPanel']").css("display", "table");
                var workflowId = (getQueryVariable("workflowId"));
                var service = PNMsoft.Sequence.AppStudio.Vsts.PrepareWorkflowForVsts;
                var timeout = window.setTimeout(function () {
                    service.PrepareWorkflowForUploadToVsts(workflowId, WorkflowPreparationGitHubSucceded, WorkflowPreparationGitHubFailed);
                    window.clearTimeout(timeout);
                }, 1000);
            }

            function PrepareWorkflow() {
                //console.log(senderButtonId);

                //senderButtonIdGlobal = senderButtonId;

                if (document.getElementById('WorkItemsGrid').rows[1].cells.length > 1) {
                    $("div[id$='WorkflowPreparationPanel']").css("display", "table");
                    var workflowId = (getQueryVariable("workflowId"));
                    var service = PNMsoft.Sequence.AppStudio.Vsts.PrepareWorkflowForVsts;
                    var timeout = window.setTimeout(function () {
                        service.PrepareWorkflowForUploadToVsts(workflowId, WorkflowPreparationSucceded, WorkflowPreparationFailed);
                        window.clearTimeout(timeout);
                    }, 1000);


                }

            }

            function CheckEnableOkButton() {
                document.getElementById("<%=HiddenButtonEnableOkBtn.ClientID %>").click();
            }


            /*  function EnableOkButton() //Check if there is work item in the gridview and file/SQL/WF is selected
              {
                  if(  document.getElementById('WorkItemsGrid').rows[1].cells.length > 1   && okButton != null) 
                  {
                      okButton.disabled = false;
                  }
  
              }*/
            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(BeginRequestHandler);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
        </script>

        <asp:UpdatePanel ID="uPanelWorkItems" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <asp:ValidationSummary runat="server" ID="validationSummary" ShowMessageBox="true" ShowSummary="false" />
                <asp:Panel runat="server" SkinID="PanelSection" Width="100%">
                    <asp:Label runat="server" CssClass="title" Text="Related Work Items" SkinID="MainInstruction"></asp:Label>
                    <br />
                     <asp:Panel runat="server">
                        <div style="margin-top: 8px">
                            <asp:Label runat="server" Text="Work Item ID" SkinID="MainInstructionMandatory" CssClass="title"></asp:Label>
                            <asp:TextBox runat="server" ID="WorkflowItemIDTextBox" Width="200px" TextMode="Number" DataType="System.Int32"></asp:TextBox>
                            <asp:Button ID="ButtonAdd" runat="server" OnClick="AddWorkItem" Text="Add Work Item" />
                        </div>
                    </asp:Panel>
                    <br />
                    <asp:GridView runat="server" ID="WorkItemsGrid" AutoGenerateColumns="false" ShowHeaderWhenEmpty="True" Width="100%"
                        DataKeyNames="Id" EmptyDataText="No work items were associated with this changeset."
                        OnRowDataBound="WorkItemsGrid_ItemDataBound" OnRowDeleting="WorkItemsGrid_DeleteCommand"
                        CssClass="mygrdContent" HeaderStyle-CssClass="header" PagerStyle-CssClass="pager" RowStyle-CssClass="rows">
                        <Columns>
                            <asp:CommandField ShowDeleteButton="true" />
                            <asp:TemplateField HeaderText="Work Item">
                                <ItemStyle Width="90%" />
                                <HeaderStyle Width="90%" />
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="WorkItemLabel" SkinID="SecondaryInstruction"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                   
                </asp:Panel>
                <asp:Panel runat="server" SkinID="PanelSection">
                    <div>
                        <asp:Label runat="server" Text="Comment" SkinID="MainInstruction" CssClass="title"></asp:Label>
                    </div>
                    <div>
                        <asp:TextBox runat="server" ID="CommentTextBox" TextMode="MultiLine" Rows="5" SkinID="TextAreaFullSize" Width="99%"></asp:TextBox>
                    </div>
                </asp:Panel>


                <asp:Panel runat="server">


                    <asp:Table runat="server" CssClass="grdContent" BorderColor="Transparent" >
                        <asp:TableRow CssClass="rows">
                            <asp:TableCell> 
                            <asp:Label runat="server" Text="Check In" CssClass="title"></asp:Label>
                            </asp:TableCell>
                            <asp:TableCell> 
                            <asp:Label runat="server" Text="Workflow" CssClass="title" Width="200px"></asp:Label>
                            </asp:TableCell>
                            <asp:TableCell> 
                            <asp:Label runat="server" Text="Deployment Method" CssClass="title" Width="200px"></asp:Label>
                            </asp:TableCell>
                        </asp:TableRow>
                        <asp:TableRow CssClass="rows">
                            <asp:TableCell>
                                <asp:Panel runat="server">
                                    <asp:CheckBox runat="server" ID="includeWfCheckBox" Enabled="false" onClick="CheckEnableOkButton()" />
                                </asp:Panel>
                            </asp:TableCell>
                            <asp:TableCell>
                                <asp:TextBox runat="server" ID="txtWorkflowName" ReadOnly="true" Width="400px"></asp:TextBox>
                            </asp:TableCell>
                            <asp:TableCell>
                                <asp:Panel runat="server">
                                    <asp:DropDownList runat="server" ID="ddlDeployMethod" OnSelectedIndexChanged="ddlDeployMethod_SelectedIndexChanged" Width="100%">

                                        <asp:ListItem Text="Standard" Value="1"></asp:ListItem>
                                        <asp:ListItem Text="End Point" Value="2"></asp:ListItem>
                                        <asp:ListItem Text="Data Incremental" Value="3"></asp:ListItem>
                                        <asp:ListItem Text="Data Overwrite" Value="4"></asp:ListItem>

                                    </asp:DropDownList>

                                </asp:Panel>
                            </asp:TableCell>
                        </asp:TableRow>
                    </asp:Table>
                </asp:Panel>
                <TABLE  style="width:100%">
                    <TR>
                        <TD style="width:50%;padding-right:10px" valign="top">
                                <div style="display: inline-block; width: 100%; padding: 0px 0px;>
                    <asp:Panel runat="server" updatemode="Conditional" ID="uPanelFiles">
                        <asp:Label runat="server" Text="Check in External Files" SkinID="MainInstruction" CssClass="title"></asp:Label>
                    </asp:Panel>
                    <asp:Panel runat="server">
                        <asp:GridView runat="server" ID="ExternalFilesGrid" ShowHeaderWhenEmpty="true" AutoGenerateColumns="false"
                            EmptyDataText="No Files" ShowHeader="true" OnRowDataBound="ExternalFilesGrid_RowDataBound" Width="100%"
                            CssClass="mygrdContent" PagerStyle-CssClass="pager" HeaderStyle-CssClass="header" RowStyle-CssClass="rows">
                            <Columns>
                                <asp:TemplateField ItemStyle-Width="20px" HeaderText="Include">
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="cbSelectAllFiles" runat="server" onClick="checkAll(this,0)" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox runat="server" ID="includeFilesCheckBox" onClick="checkItem_All(this,0)" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Include File">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="filesLabel" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Update Date">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="UpdateDateLabel" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField Visible="false">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="filesRealPathLabel" />
                                        <asp:Label runat="server" ID="filesVstsPathLabel" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </asp:Panel>
                </div>
                        </TD>
                        <TD style="width:50%; padding-left:10px"  valign="top">
                                 <div style="display: inline-block; width: 100%; padding: 0px 0px;">
                    <asp:Panel runat="server" updatemode="Conditional">
                        <asp:Label runat="server" Text="Check in SQL Scripts" CssClass="title"></asp:Label>
                    </asp:Panel>
                    <asp:Panel runat="server">
                        <asp:GridView runat="server" ID="ScriptsGrid" ShowHeaderWhenEmpty="true" AutoGenerateColumns="false"
                            EmptyDataText="No Scripts" ShowHeader="true" OnRowDataBound="ScriptsGrid_RowDataBound" Width="100%"
                            CssClass="mygrdContent" PagerStyle-CssClass="pager" HeaderStyle-CssClass="header" RowStyle-CssClass="rows" >
                            <Columns>
                                <asp:TemplateField ItemStyle-Width="20px" HeaderText="Include">
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="cbSelectAllScripts" runat="server" onClick="checkAll(this,0)" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox runat="server" ID="includeScriptsCheckBox" onClick="checkItem_All(this,0)" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                 <asp:TemplateField HeaderText="Connection">
                                    <ItemTemplate>
                                      <asp:Label runat="server" ID="sqlScriptConnection" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                  <asp:TemplateField HeaderText="Schema">
                                    <ItemTemplate>
                                      <asp:Label runat="server" ID="sqlScriptSchema" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Name">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="sqlScriptNameLabel" />
                                    </ItemTemplate>
                                </asp:TemplateField>

                                <asp:TemplateField HeaderText="Type">
                                    <ItemTemplate>
                                      <asp:Label runat="server" ID="sqlScriptType" />
                                    </ItemTemplate>
                                </asp:TemplateField>


                                <asp:TemplateField Visible="false">
                                    <ItemTemplate>
                                        <asp:TextBox runat="server" ID="sqlScriptSQL" TextMode="MultiLine" />
                                        <asp:Label runat="server" ID="sqlScript" />
                                        <asp:Label runat="server" ID="sqlScriptDB" />
                                        
                                        

                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </asp:Panel>
                </div>
                        </TD>
                    </TR>
                </TABLE>
             

           

                <asp:CheckBox runat="server" ID="WorkflowPreparedCheckBox" Checked="false" Style="display: none;" />
                <asp:Panel runat="server" ID="WorkflowPreparationPanel" Style="width: 100%; height: 100%; display: none; z-index: 3000; position: absolute; top: 0; left: 0; background: rgba(255, 255, 255, 0.6); filter: Alpha(Opacity=70);">
                    <div style="display: table-cell; width: 100%; height: 100%; vertical-align: middle; text-align: center;">
                        <asp:Label runat="server" Text="Preparing the workflow for upload to VSTS." SkinID="MainInstruction"></asp:Label>
                        <asp:Image runat="server" ImageUrl="~/Web/UI/Resources/Images/WebControls/BusyIndicator.gif" GenerateEmptyAlternateText="true" />
                    </div>
                </asp:Panel>
                

                <asp:Panel runat="server">
                    <div id="ButtonsContainer" style="text-align: right; width: 100%">
                        <asp:Button runat="server" CssClass="fButton" ID="CancelButton" Text="Cancel" OnClientClick="ClosePopUp()" />
                        <asp:Button runat="server" CssClass="fButton" ID="OkButton" Text="Commit to Azure" OnClientClick='PrepareWorkflow()' />
                        <asp:Button runat="server" CssClass="fButton" ID="OKButtonGitHub" Text="Commit to GitHub" OnClientClick='PrepareWorkflowForGitHub()' />
                        <asp:Button runat="server" ID="HiddenButtonEnableOkBtn"  OnClick="HiddenButtonEnableOkBtn_Click" CssClass="hidden" />
                        <asp:Button runat="server" ID="HiddenButtonOkClick" OnClick="HiddenButtonOkClick_Click" CssClass="hidden" />
                        <asp:Button runat="server" ID="HiddenButtonOkGitHubClick" OnClick="HiddenButtonGitHubOkClick_Click" CssClass="hidden" />
                    </div>
                </asp:Panel>

            </ContentTemplate>
        </asp:UpdatePanel>


        <asp:UpdateProgress ID="UpdateProgress1" runat="server"
            AssociatedUpdatePanelID="uPanelWorkItems">
            <ProgressTemplate>
                <div class="update-progress-gif"></div>
                <div class="update-progress"></div>
                
            </ProgressTemplate>
        </asp:UpdateProgress>

    </form>
</body>
</html>
