function displayLayover(url) {
	var options = SP.UI.$create_DialogOptions();
	options.url = url;
	options.dialogReturnValueCallback = Function.createDelegate(
	null, null);
	SP.UI.ModalDialog.showModalDialog(options);
}

  var personProperties;

  SP.SOD.executeOrDelayUntilScriptLoaded(getCurrentUser, 'SP.UserProfiles.js');

  function getCurrentUser() {
    var clientContext = new SP.ClientContext.get_current();
    personProperties = new SP.UserProfiles.PeopleManager(clientContext).getMyProperties();
    clientContext.load(personProperties);
    clientContext.executeQueryAsync(gotAccount, requestFailed);
  }

  function gotAccount(sender, args) {
    //alert("Display Name: "+ personProperties.get_displayName() + ", Account Name: " + personProperties.get_accountName());
  }

  function requestFailed(sender, args) {
    alert('Cannot get user account information: ' + args.get_message());
  }

