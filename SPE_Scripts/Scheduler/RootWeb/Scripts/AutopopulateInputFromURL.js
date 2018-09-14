
var keySubscriber;

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
					for(var j = 0; j <= options.length; j++){
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

 var personProperties;


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
	var peoplepicker = SPClientPeoplePicker.PickerObjectFromSubElement(userField)
	peoplepicker.AddUserKeys(loginName);  
}

function requestFailed(sender, args) {
    alert('Cannot get user account information: ' + args.get_message());
}



_spBodyOnLoadFunctionNames.push("fillDefaultValues");

