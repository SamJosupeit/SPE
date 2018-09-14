var hideQL = true;
var defineCSS = true;
var definedCssClassesScheduler = { 
	"scheduler-width100" : "width:100%",
	"scheduler-width75" : "width:75%",
	"scheduler-width50" : "width:50%;",
	"scheduler-width25" : "width:25%;",
	"scheduler-formtable" : "width:100%;min-width:850px;margin-top: 8px;border:1px solid black;border-spacing: 10px;border-collapse: separate;",
	"scheduler-formtable .scheduler-block td" : "vertical-align: middle;padding:0;padding-left: 5px;border:1px solid black; border-radius: 10px;border-spacing: 10px;border-collapse: separate;",
	"scheduler-formtable td" : "vertical-align:top;",
	"scheduler-mastercolumn" : "width:50%;",
	"scheduler-formlabel" : "font-weight: bold;",
	"scheduler-formbody" : "",
	"scheduler-block" : "background-color: lightgrey;padding: 5px;",
	"scheduler-headline" : "background-color: darkgrey !important;",
	"scheduler-hidden" : "display:none;",
	"scheduler-visible" : "display:;"
};
var schedulerFormTableInnerHTML = {
	"DE" : '<tr class="scheduler-headline"><td class="scheduler-width100" colspan="2"><table class="scheduler-height34 scheduler-block scheduler-width100"><tr id="DateDE"><td class="ms-formlabel scheduler-formlabel scheduler-width25"></td><td class="ms-formbody scheduler-formbody scheduler-width75"></td></tr></table></td></tr><tr><td class="scheduler-mastercolumn scheduler-width100" colspan="2"><table class="scheduler-height34 scheduler-block scheduler-width100"><tr id="DateDescriptionDE"><td class="ms-formlabel scheduler-formlabel scheduler-width25"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td></tr><tr><td class="scheduler-mastercolumn"><table class="scheduler-height33 scheduler-block scheduler-width100"><tr id="Start"><td class="ms-formlabel scheduler-formlabel scheduler-width50"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="End"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="Duration"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="Bookable"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="NewSubscription"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td><td class="scheduler-mastercolumn"><table class="scheduler-height33 scheduler-block scheduler-width100"><tr id="StageDE"><td class="ms-formlabel scheduler-formlabel scheduler-width25"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="ModuleDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="TrainingDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="TrainingTopicsDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="Trainer"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td></tr><tr><td class="scheduler-mastercolumn"><table class="scheduler-height34 scheduler-block scheduler-width100"><tr id="CountryDE"><td class="ms-formlabel scheduler-formlabel scheduler-width50"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="LocationDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="BuildingDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="RoomName"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="MinSubscriptions"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td><td class="scheduler-mastercolumn"><table class="scheduler-height33 scheduler-block scheduler-width100"><tr id="AvailableSeats"><td class="ms-formlabel scheduler-formlabel scheduler-width75"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="BookedSeats"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="FreeSeats"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="AvailablePCs"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="FreePCs"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td></tr>',
	"EN" : '<tr class="scheduler-headline"><td class="scheduler-width100" colspan="2"><table class="scheduler-height34 scheduler-block scheduler-width100"><tr id="DateDE"><td class="ms-formlabel scheduler-formlabel scheduler-width25"></td><td class="ms-formbody scheduler-formbody scheduler-width75"></td></tr></table></td></tr><tr><td class="scheduler-mastercolumn scheduler-width100" colspan="2"><table class="scheduler-height34 scheduler-block scheduler-width100"><tr id="DateDescriptionDE"><td class="ms-formlabel scheduler-formlabel scheduler-width25"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td></tr><tr><td class="scheduler-mastercolumn"><table class="scheduler-height33 scheduler-block scheduler-width100"><tr id="Start"><td class="ms-formlabel scheduler-formlabel scheduler-width50"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="End"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="Duration"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="Bookable"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="NewSubscription"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td><td class="scheduler-mastercolumn"><table class="scheduler-height33 scheduler-block scheduler-width100"><tr id="StageDE"><td class="ms-formlabel scheduler-formlabel scheduler-width25"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="ModuleDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="TrainingDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="TrainingTopicsDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="Trainer"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td></tr><tr><td class="scheduler-mastercolumn"><table class="scheduler-height34 scheduler-block scheduler-width100"><tr id="CountryDE"><td class="ms-formlabel scheduler-formlabel scheduler-width50"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="LocationDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="BuildingDE"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="RoomName"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="MinSubscriptions"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td><td class="scheduler-mastercolumn"><table class="scheduler-height33 scheduler-block scheduler-width100"><tr id="AvailableSeats"><td class="ms-formlabel scheduler-formlabel scheduler-width75"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="BookedSeats"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="FreeSeats"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="AvailablePCs"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr><tr id="FreePCs"><td class="ms-formlabel scheduler-formlabel"></td><td class="ms-formbody scheduler-formbody"></td></tr></table></td></tr>'
};
var SchedulerStyleElement;
var formTable;
var infoTable;
var formRows;
var curLanguage;
function getInnerHtmlForSchedulerFormTable(language){
	innerHtmlCode = "<tr class='scheduler-headline'><td class='scheduler-width100' colspan='2'><table class='scheduler-height34 scheduler-block scheduler-width100'><tr id='Date" + language + "'><td class='ms-formlabel scheduler-formlabel scheduler-width25'></td><td class='ms-formbody scheduler-formbody scheduler-width75'></td></tr></table></td></tr><tr><td class='scheduler-mastercolumn scheduler-width100' colspan='2'><table class='scheduler-height34 scheduler-block scheduler-width100'><tr id='DateDescription" + language + "'><td class='ms-formlabel scheduler-formlabel scheduler-width25'></td><td class='ms-formbody scheduler-formbody'></td></tr></table></td></tr><tr><td class='scheduler-mastercolumn'><table class='scheduler-height33 scheduler-block scheduler-width100'><tr id='Start'><td class='ms-formlabel scheduler-formlabel scheduler-width50'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='End'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='Duration'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='Bookable'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='NewSubscription'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr></table></td><td class='scheduler-mastercolumn'><table class='scheduler-height33 scheduler-block scheduler-width100'><tr id='Stage" + language + "'><td class='ms-formlabel scheduler-formlabel scheduler-width25'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='Module" + language + "'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='Training" + language + "'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='TrainingTopics" + language + "'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='Trainer'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr></table></td></tr><tr><td class='scheduler-mastercolumn'><table class='scheduler-height34 scheduler-block scheduler-width100'><tr id='Country" + language + "'><td class='ms-formlabel scheduler-formlabel scheduler-width50'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='Location" + language + "'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='Building" + language + "'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='RoomName'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='MinSubscriptions'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr></table></td><td class='scheduler-mastercolumn'><table class='scheduler-height33 scheduler-block scheduler-width100'><tr id='AvailableSeats'><td class='ms-formlabel scheduler-formlabel scheduler-width75'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='BookedSeats'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='FreeSeats'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='AvailablePCs'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr><tr id='FreePCs'><td class='ms-formlabel scheduler-formlabel'></td><td class='ms-formbody scheduler-formbody'></td></tr></table></td></tr>";
	return innerHtmlCode;
}
function getDispFieldNamesToTransform(language){
	var fieldNames = ["Date" + language,"DateDescription" + language,"Start","End","Duration","Bookable","NewSubscription","Stage" + language,"Module" + language,"Training" + language,"TrainingTopics" + language,"Trainer","Country" + language,"Location" + language,"Building" + language,"RoomName","MinSubscriptions","AvailableSeats","BookedSeats","FreeSeats","AvailablePCs","FreePCs"];
	return fieldNames;
}
function defineCssClasses(){
	/// <summary>Creates the needed CSS-classes by creating a new STYLE-element, filling it up by the definitions inside the hashtable 'definedCssClassesScheduler' and adding it to HEAD.</summary>
	var style = document.createElement('style');
	var styleInnerHTML = '';
	for(var key in definedCssClassesScheduler){
		styleInnerHTML += '.' + key + '{' + definedCssClassesScheduler[key] + '}';
	}
	style.innerHTML = styleInnerHTML;
	document.getElementsByTagName('head')[0].appendChild(style);
	SchedulerStyleElement = style;
}
function hideQuickLaunch(){
	///<summary>Hides the Quicklaunch</summary>
		var styleOverwrite = "#sideNavBox{display:none !important;}#contentBox{margin-left: 20px !important;}"
		var style = SchedulerStyleElement.innerHTML + styleOverwrite;
		SchedulerStyleElement.innerHTML = style;
}
function aContainsB (a, b) {
	/// <summary>Checks, if string "b" is contained in string "a"</summary>
	///	<param name="a" type="String">The string to test.</param>
	/// <param name="b" type="String">The string which might be contained in "a"</param>
	/// <returns type="Boolean">"true" if a contains b, otherwise "false"</returns>
	return a.indexOf(b) >= 0;
}
function removeCharFromString(s, c){
	/// <summary>Removes all existing "c"'s from the string "s".</summary>
	/// <param name="s" type="String">The string to be cleaned up.</param>
	/// <param name="c" type="String">The string to be cleaned from "s".</param>
	/// <returns type="String">The cleaned up string.</returns>
	while(aContainsB(s, c)){
		s = s.replace(c, "");
	}
	return s;
}
function RenderCalculatedFields(){
	var SPFieldCalculatedTDs = $("td[id='SPFieldCalculated']");
	var curTD;
	for(var i = 0; i < SPFieldCalculatedTDs.length; i++){
		curTD = SPFieldCalculatedTDs[i];
		if(aContainsB(curTD.innerHTML,'FieldInternalName="NewSubscription')){
			curTD.setAttribute("SchedulerId","NewSubscription");
			break;
		}
	}
	var targetTD = $("td[SchedulerId='NewSubscription']");
	targetContent = targetTD.text();
	targetTD.html(targetContent);
}
function getCurrentLanguageShortcut(){
	// get the current language
	for(var i = 0; i < formRows.length; i++){
		curRow = formRows[i];
		if(aContainsB(curRow.innerHTML, 'FieldInternalName="CountryShortcut"')){
			var valueTD = curRow.getElementsByClassName("ms-formbody")[0];
			var valueTDinnerText = valueTD.innerText;
			var value = valueTDinnerText.replace("/<!--.*?-->/sg", "");
			var valueCleared = removeCharFromString(value, " ");
			break;
		}
	}
	curLanguage = valueCleared;
}
function getCurrentElements(){
	formTable = document.getElementsByClassName("ms-formtable")[0];
//	infoTable = formTable.nextElementSibling;
	formRows = formTable.getElementsByTagName("TR");
}
function getCurrentRowByFieldName(fieldName){
	var row;
	for(var i = 0; i < formRows.length; i++){
		var curRow = formRows[i];
		if(aContainsB(curRow.innerHTML, fieldName)){
			row = curRow;
			break;
		}
	}
	return row;
}
function transformFormTable(){
	getCurrentLanguageShortcut();
	// create the new table
	var schedulerFormTable = document.createElement("table");
	schedulerFormTable.className = "ms-formtable scheduler-formtable scheduler-hidden";
	formTable.parentNode.appendChild(schedulerFormTable);
	// get the innerHTML by language for the new table
	var curInnerHtml = getInnerHtmlForSchedulerFormTable(curLanguage);
	schedulerFormTable.innerHTML = curInnerHtml;
	// loop through the SPFfields
	var spFieldNames = getDispFieldNamesToTransform(curLanguage);
	for(var i = 0; i < spFieldNames.length; i++){
		var curFieldName = spFieldNames[i];
		var curRow = getCurrentRowByFieldName(curFieldName);
		var curRowLabelTD = curRow.getElementsByClassName("ms-formlabel")[0];
		var curRowBodyTD = curRow.getElementsByClassName("ms-formbody")[0];
		var targetRow = document.getElementById(curFieldName);
		var targetRowLabelTD = targetRow.getElementsByClassName("ms-formlabel")[0];
		var targetRowBodyTD = targetRow.getElementsByClassName("ms-formbody")[0];
		targetRowLabelTD.innerHTML = curRowLabelTD.innerHTML;
		targetRowBodyTD.innerHTML = curRowBodyTD.innerHTML;
	}
	formTable.parentNode.replaceChild(schedulerFormTable, formTable);
	schedulerFormTable.className = schedulerFormTable.className.replace("scheduler-hidden","scheduler-visible");
}
if(defineCSS){
	defineCssClasses();
	if(hideQL){
		hideQuickLaunch();
	}
}
if(typeof _spBodyOnLoadFunctionNames === 'function'){
	_spBodyOnLoadFunctionNames.push("getCurrentElements");
	_spBodyOnLoadFunctionNames.push("RenderCalculatedFields");
	_spBodyOnLoadFunctionNames.push("transformFormTable");	
}
