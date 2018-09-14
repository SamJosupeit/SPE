
// script-global vars
var personProperties;
var keySubscriber;
var hideQL = false;
var defineCSS = true;
var SchedulerStyleElement;
var SchedulerDefinedClasses ={
	'SchedulerVisible' : 'display: ;', 
	'SchedulerHidden' : 'display:none;'	
}

// functions
function aContainsB (a, b) {
	/// <summary>Checks, if string "b" is contained in string "a"</summary>
	///	<param name="a" type="String">The string to test.</param>
	/// <param name="b" type="String">The string which might be contained in "a"</param>
	/// <returns type="Boolean">"true" if a contains b, otherwise "false"</returns>
	return a.indexOf(b) >= 0;
}
function getParametersFromUrl(){
	var queryString = location.search.substring(1, location.search.length);
	if(queryString){
		var vals = new Object();
		if(aContainsB(queryString,"&")){
			var args = queryString.split("&");
			for (var i=0; i < args.length; i++) {
				var nameVal = args[i].split("=");
				//var temp = unescape(nameVal[1]).split("+");
				//nameVal[1] = temp.join(" ");
				vals[nameVal[0]] = nameVal[1];
			} 
		} else {
			var nameVal = queryString.split("=");
			//var temp = unescape(nameVal[1]).split("+");
			//nameVal[1] = temp.join(" ");
			vals[nameVal[0]] = nameVal[1];
		}
		return vals;
	} else {
		return null;
	}
}
function setParametersToFields(ParametersFromUrl){
	if(ParametersFromUrl){
		var keys = Object.keys(ParametersFromUrl);
		for(var i = 0; i <= keys.length;i++){
			var key = keys[i];
			var value = ParametersFromUrl[key];
			switch(key){
				case "Schulungstermin":
					var el = document.querySelector('[title="' + key + '"]');
					var options = el.childNodes;
					for(var j = 0; j < options.length; j++){
						var curOption = options[j];
						if(curOption.innerHTML === value){
							var curValue = curOption.attributes["value"].value;
							el.value = curValue;
							break;
						}
					}
					break;
				case "Teilnehmer":
					keySubscriber = key
					SP.SOD.executeOrDelayUntilScriptLoaded(getCurrentUser, 'SP.UserProfiles.js');
					break;
				default:
					break;
			}
		}
	}
}
function fillDefaultValues(){
	var parameters = getParametersFromUrl();
	setParametersToFields(parameters);
}
function getCurrentUser() {
    var clientContext = new SP.ClientContext.get_current();
    personProperties = new SP.UserProfiles.PeopleManager(clientContext).getMyProperties();
    clientContext.load(personProperties);
    clientContext.executeQueryAsync(gotAccount, requestFailed);
}
function gotAccount(sender, args) {
    //alert("Display Name: "+ personProperties.get_displayName() + ", Account Name: " + personProperties.get_accountName());
	var loginName = personProperties.get_accountName();
	var form = jQuery("table[class='ms-formtable']"); 
	var userField = form.find("input[id$='ClientPeoplePicker_EditorInput']").get(0);
	var peoplepicker = SPClientPeoplePicker.PickerObjectFromSubElement(userField);
	peoplepicker.AddUserKeys(loginName);  
}
function requestFailed(sender, args) {
    alert('Cannot get user account information: ' + args.get_message());
}
function calculateSubscriptionID(){
	var inputSubscriptionID = document.querySelector('[title="SubscriptionID"]');
	var inputSchulungstermin = document.querySelector('[title="Schulungstermin"]');
	var selectSchulungstermin = inputSchulungstermin.value;
	var valueSchulungstermin;
	var optionsSchulungstermin = inputSchulungstermin.childNodes;
	for(var i = 0; i < optionsSchulungstermin.length; i++){
		var curOption = optionsSchulungstermin[i];
		if(curOption.getAttribute("value") === selectSchulungstermin){
			valueSchulungstermin = curOption.innerHTML;
			break;
		}
	}
	var form = jQuery("table[class='ms-formtable']"); 
	var userField = form.find("input[id$='ClientPeoplePicker_EditorInput']").get(0);
	var peoplepicker = SPClientPeoplePicker.PickerObjectFromSubElement(userField);
	var userKey = peoplepicker.GetAllUserKeys();
	var cwid = userKey.split('\\')[1];
	var newSubscriptionID = cwid + "-" + valueSchulungstermin;
	inputSubscriptionID.value = newSubscriptionID;
}
function enhanceSaveButton(){
	var saveButtons = document.querySelectorAll('[value="Speichern"]');
	for(var i = 0; i < saveButtons.length; i++){
		var curButton = saveButtons[i];
		var onclickCode = curButton.getAttribute("onclick");
		var newOnclickCode = "calculateSubscriptionID();" + onclickCode;
		curButton.setAttribute("onclick", newOnclickCode);
	}
}
function HideFormFields(){
	// hide Subscriber field be default and set onchange to select
	var selectOtherUser = document.querySelector('[title="Einen anderen Benutzer anmelden?"]');
	selectOtherUser.setAttribute("onchange","toggleSubscriberField(this);");
	toggleSubscriberField(selectOtherUser);
	// hide subscriptionID field
	var inputSubscriptionID = document.querySelector('[title="SubscriptionID"]');
	var rowSubscriptionID = inputSubscriptionID.parentElement.parentElement.parentElement
	if (aContainsB(rowSubscriptionID.className,'SchedulerVisible')){
		rowSubscriptionID.className = rowSubscriptionID.className.replace('SchedulerVisible','SchedulerHidden');
	} else if(!aContainsB(rowSubscriptionID.className,'SchedulerHidden')){
		rowSubscriptionID.className = rowSubscriptionID.className + ' SchedulerHidden';
	}
	// hide Status field
	var inputStatus = document.querySelector('[id^="State"]');
	var rowStatus = inputStatus.parentElement.parentElement.parentElement
	if (aContainsB(rowStatus.className,'SchedulerVisible')){
		rowStatus.className = rowStatus.className.replace('SchedulerVisible','SchedulerHidden');
	} else if(!aContainsB(rowStatus.className,'SchedulerHidden')){
		rowStatus.className = rowStatus.className + ' SchedulerHidden';
	}
}
function toggleSubscriberField(selectElement){
	var statusSelect = selectElement.checked;
	var subscriberInput = document.querySelector('[title="Teilnehmer"]');
	var subscriberRow = subscriberInput.parentElement.parentElement.parentElement;
	if(!statusSelect){
		if (aContainsB(subscriberRow.className,'SchedulerVisible')){
			subscriberRow.className = subscriberRow.className.replace('SchedulerVisible','SchedulerHidden');
		} else if(!aContainsB(subscriberRow.className,'SchedulerHidden')){
			subscriberRow.className = subscriberRow.className + ' SchedulerHidden';
		}
	} else {
		if(aContainsB(subscriberRow.className,'SchedulerHidden')){
			subscriberRow.className = subscriberRow.className.replace('SchedulerHidden','SchedulerVisible');
		} else if(aContainsB(subscriberRow.className,'SchedulerVisible')){
			subscriberRow.className = subscriberRow.className + ' SchedulerVisible';
		}
	}
}
function aContainsB (a, b) {
	/// <summary>Checks, if string "b" is contained in string "a"</summary>
	///	<param name="a" type="String">The string to test.</param>
	/// <param name="b" type="String">The string which might be contained in "a"</param>
	/// <returns type="Boolean">"true" if a contains b, otherwise "false"</returns>
	return a.indexOf(b) >= 0;
}
function defineCssClasses(){
	/// <summary>Creates the needed CSS-classes by creating a new STYLE-element, filling it up by the definitions inside the hashtable 'SchedulerDefinedClasses' and adding it to HEAD.</summary>
	var style = document.createElement('style');
	var styleInnerHTML = '';
	for(var key in SchedulerDefinedClasses){
		styleInnerHTML += '.' + key + '{' + SchedulerDefinedClasses[key] + '}';
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
function toggleVisibility(element){
	///<summary>Toggles visibility of an element.</summary>
	///<param name="elementId" type="String">The id of the element to toggle.</param>
	if(aContainsB(element.className,'SchedulerHidden')){
		changeOrSetCssClassName(elementId,'SchedulerHidden','SchedulerVisible');
	} else if(aContainsB(element.className,'SchedulerVisible')){
		changeOrSetCssClassName(elementId,'SchedulerVisible','SchedulerHidden');
	}
}


// execute on load
if(defineCSS){
	_spBodyOnLoadFunctionNames.push("defineCssClasses");
	_spBodyOnLoadFunctionNames.push("HideFormFields");
	if(hideQL){
		_spBodyOnLoadFunctionNames.push("hideQuickLaunch");
	}
}
_spBodyOnLoadFunctionNames.push("fillDefaultValues");
_spBodyOnLoadFunctionNames.push("enhanceSaveButton");

