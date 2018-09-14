function aContainsB (a, b) {
	/// <summary>Checks, if string "b" is contained in string "a"</summary>
	///	<param name="a" type="String">The string to test.</param>
	/// <param name="b" type="String">The string which might be contained in "a"</param>
	/// <returns type="Boolean">"true" if a contains b, otherwise "false"</returns>
	return a.indexOf(b) >= 0;
}

function RenderCalculatedFields(){
	var theTDs = $("td[id='SPFieldCalculated']");
	var curTD;
	for(var i = 0; i <= theTDs.length; i++){
		curTD = theTDs[i];
		if(aContainsB(curTD.innerHTML,'FieldInternalName="NewSubscription')){
			curTD.setAttribute("SchedulerId","NewSubscription");
			break;
		}
	}
	var targetTD = $("td[SchedulerId='NewSubscription']");
	targetContent = targetTD.text();
	targetTD.html(targetContent);
}
_spBodyOnLoadFunctionNames.push("RenderCalculatedFields");