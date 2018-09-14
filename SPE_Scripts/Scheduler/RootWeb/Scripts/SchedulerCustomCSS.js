var hideQL = true;
var defineCSS = true;
var definedCssClassesScheduler = { 
	'ms-rteTable-default' : 'width: 100% !important; border: none !important; vertical-align: top !important;',
	'ms-rteTable-default > tbody > tr > td, .ms-rteTable-default > tbody > tr > th, td.ms-rteTable-default, th.ms-rteTable-default, .ms-rtetablecells' : 'width: 50% !important; border: none !important; vertical-align: top !important;',
	'ms-webpart-chrome-title' : 'border-bottom-style: solid !important; border-width: 1px !important;',
	'tableCol-25' : 'vertical-align:top; width: 25% !important',
	'tableCol-75' : 'vertical-align:top; width: 75% !important',
	'tableCol-33' : 'vertical-align:top; width: 33% !important',
	};
var nonDefinedClasses ={
	'ms-core-pageTitle' : 'display: none !important;',
	'SchedulerArrowDown' : 'border: 5px solid; font-size: 0; line-height: 0; height: 0; padding: 0; margin: 0; border-right-color: transparent; border-bottom-color: transparent; border-left-color: transparent; float: right; margin-right: 5px; vertical-align: center; margin-top: 10px;',
	'SchedulerVisible' : 'display: ;', 
	'SchedulerHidden' : 'display:none;'	
}
var SchedulerStyleElement;

function aContainsB (a, b) {
	/// <summary>Checks, if string "b" is contained in string "a"</summary>
	///	<param name="a" type="String">The string to test.</param>
	/// <param name="b" type="String">The string which might be contained in "a"</param>
	/// <returns type="Boolean">"true" if a contains b, otherwise "false"</returns>
	return a.indexOf(b) >= 0;
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
function toggleVisibility(elementId){
	///<summary>Toggles visibility of an element.</summary>
	///<param name="elementId" type="String">The id of the element to toggle.</param>
	var element = document.getElementById(elementId);
	if(aContainsB(element.className,'SchedulerHidden')){
		changeOrSetCssClassName(elementId,'SchedulerHidden','SchedulerVisible');
	} else if(aContainsB(element.className,'SchedulerVisible')){
		changeOrSetCssClassName(elementId,'SchedulerVisible','SchedulerHidden');
	}
}
function getPercentNumber(a, b){
	/// <summary></summary>
	/// <param name="" type=""></param>
	/// <returns type=""></returns>
	var c = Math.round((a / b * 100) * 100) / 100;
	return c;
}
function getPercentText(a){
	/// <summary>Transfers a number to a percented text.</summary>
	/// <param name="a" type="Number">The number to which the "%"-char will be added.</param>
	/// <returns type="String">The percented number.</returns>
	return a.toString() + "%";
}
if(defineCSS){
	defineCssClasses();
	if(hideQL){
		hideQuickLaunch();
	}
}
