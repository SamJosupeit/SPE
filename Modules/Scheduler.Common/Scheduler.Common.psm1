#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-Module                                            #
# #####################################################################
# Name:        Scheduler.Common.psm1                                  #
# Description: This PowerShell-Module contains functions to be used   #
#              by the Scheduler scripts                               #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | G.Krieger | Initial Release                    | 01.02.2017 #
######################################################################>
#endregion

#region Status
<#
22.02.2017
- Erstellen der Listen funktioniert
- Import der Testdaten funktioniert
- Publishing von Scheduler Objects funktioniert
#>
#endregion

#region fertig, aber undokumentiert

#region Variables
    Set-Variable -Name "subscriptionStates" -Value @("Registered","Booked","Completed","No Show","Canceled") -Scope Global
#endregion

#region Functions for the Installer

    #region Function Get-SchedulerWebsite
    Function Get-SchedulerWebsite{
        <#
            .SYNOPSIS
            This Cmdlet gets one of the Schedulers websites by its URL
            
            .DESCRIPTION
            This Cmdlet gets one of the Schedulers websites by its URL. The credentials will be taken by an upcoming dialog. If an 404 error occurs it is returned. if an 401 error occurs, the user is allowed to correct the credentials, or to cancel the progress. On success the CSOM webobject is returned

            .PARAMETER Url
            The tURL of the Website 
        #>
        [CmdletBinding()]
        param(
            [String]$Url
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
        }
        Process{
            $foundWeb = $false
            do{
                Show-SPETextLine -text "Erfasse Website mit Url '$Url'..."
                if($SPO){
                    $web = Get-SPECsomWeb -Url $Url -Credentials $global:cred -SPO
                } 
                else {
                    $web = Get-SPECsomWeb -Url $Url -Credentials $global:cred
                }
                if($web.GetType().ToString() -eq "Microsoft.SharePoint.Client.Web"){
                    $ctx = $web.Context
                    Show-SPETextLine -text "Website wurde erfasst. Fahre fort..."
                    lm -Category $LogCat -level High -message "...connection to SharePoint site '$Url' succesfully established."
                    $foundWeb = $true
                } 
                elseif($web -eq "401"){
                    Show-SPETextArray -textArray ("Server meldet Fehler 401: Nicht authorisiert.","","Vermutlich wurden falsche Anmeldedaten eingegeben.","","Möchten Sie die Anmeldedaten (n)ochmal eingeben oder (a)bbrechen?)")
                    $choice = Use-SPEChoice -Choices "n,a"
                    if($choice -eq "a"){ 
                        Show-SPETextLine -text "Script wird abgebrochen."
                        return $null 
                    } 
                    else {
                        Remove-Variable -Name "Cred"
                        Remove-Variable -Name "SPEStoredCred"
                        Remove-SPECredentialsInConfig
                        if($SPO){
                            Approve-SPECredentialsInConfig -SPO
                        } 
                        else {
                            Approve-SPECredentialsInConfig
                        }
                   }
                } 
                elseif($web -eq "404"){
                    Show-SPETextArray -textArray ("Server meldet Fehler 404: Seite existiert nicht.","","Bitte URL in Config überprüfen.","","Script wird beendet.")
                    return $null
                } 
                else {
                    Show-SPETextArray -textArray ("Unbekannter Fehler bei Erfassung der Rootwebsite.","","Bitte Config überprüfen und Log auswerten.","","Script wird beendet")
                    return $null
                }
            }
            while($foundWeb -eq $false)
            return $web
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function New-SchedulerList
    Function New-SchedulerList{
        <#
            .SYNOPSIS
            This Cmdlet creates a list inside the addressed website
            
            .DESCRIPTION
            This Cmdlet creates a list inside the addressed website based on the XML-Definition called to parameter xmlList

            .PARAMETER Web
            The Microsoft.SharePoint.Client.Web object

            .PARAMETER xmlList
            The XmlElement in which the list is defined
        #>
        [CmdletBinding()]
        param(
            [Microsoft.SharePoint.Client.Web]$Web,
            [System.Xml.XmlElement]$xmlList
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
            $curCtx = $Web.Context
        }
        Process{
            Exit-SPEOnCtrlC
            #region Create the list itself
            $ListCreationSuccessfull = $true
            $listName = $xmlList.Name
            Show-SPETextLine -text "Beginne mit Erstellung der Liste '$listName'..."
            $listDescription = $xmlList.Description
            $listTemplateName = $xmlList.Template.Replace(" ","_")
            lm -Category $LogCat -level Verbose -message "Start creation of list $listName..."
            try
            {
                $newList = New-SPECsomList -Web $Web -ListTitle $listName -ListDescription $listDescription -ListTemplateName $listTemplateName
                if($newList.ServerObjectIsNull){
                    return $null
                }
                return $newList
            } 
            catch 
            {
	            $info = "Error at creation of list '$listName'."
                lx -Stack $_ -info $info -Category $LogCat
                $global:foundErrors = $true
                return $null
            }
            #endregion
            
        }
        End{
            $curCtx = $null
        }
    }
    #endregion
    #EndOfFunction

    #region Function New-SchedulerLists
    Function New-SchedulerLists{
        <#
            .SYNOPSIS
            This Cmdlet creates all Lists declared in Scheduler_SetupData.xml file
            
            .DESCRIPTION
            This Cmdlet creates all Lists declared in Scheduler_SetupData.xml file.

            .PARAMETER SetupData
            The XMLDocument for the Scheduler_SetupData.xml file
        #>
        [CmdletBinding()]
        param(
            [Xml]$SetupData 
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
        }
        Process{
            lm -category $LogCat -level Medium -message "Start creation of Lists..."
            foreach($xmlWebsite in $SetupData.Scheduler.Websites.ChildNodes)
            {
                $CurrentWebScriptInternalName = $xmlWebsite.Attributes["ScriptInternalName"].Value
                lm -Category $LogCat  -message "Start working on Website '$CurrentWebScriptInternalName'"
                    $pathWebSite = $xmlWebsite.relativeUrl
                    $rootWebUrl = $UrlRootWeb.TrimEnd("/")
                    $currentWebUrl = $rootWebUrl + $pathWebSite
                    $currentWeb = Get-SchedulerWebsite -Url $currentWebUrl
                    if($currentWeb -ne $null){
                        foreach($xmlList in $xmlWebsite.Lists.ChildNodes)
                        {
                            $fieldDefinitions = $xmlList.Fields #.ChildNodes
                            $viewDefinitions = $xmlList.Views
                            $listName = $xmlList.Name
                            $newList = New-SchedulerList -Web $currentWeb -xmlList $xmlList
                            #region Add the fields and views
                            try
                            {
                                if($newList -ne $null){
                                    lm -Category $LogCat  -message "List was created successfully and will now be used to create to corresponding fields..."
                                    Add-SchedulerFieldsToList -list $newList -fieldDefinitions $fieldDefinitions
                                    lm -Category $LogCat  -message "Finished adding fields."
                                    if($viewDefinitions -ne $null){
                                        lm -Category $LogCat  -message "Start adding views..."
                                        Show-SPETextLine -text "Erzeuge nun Views..."
                                        Add-SchedulerViewsToList -list $newList -viewsDefinition $viewDefinitions -Overwrite $true
                                        lm -Category $LogCat  -message "Finished addings views."
                                        Show-SPETextLine -text "Erstellung der Views abgeschlossen."
                                    }
                                } else {
                                    lm -Category $LogCat -level Unexpected -message "List '$listname' on Website '$CurrentWebScriptInternalName' could not be created. Maybe it already exists."
                                    lm -Category $LogCat  -message "Trying to get the list..."
                                    $existingList = Get-SPECsomList -Web $currentWeb -ListTitle $listName
                                    if(!$existingList.ServerObjectIsNull)
                                    {
                                        lm -Category $LogCat  -message "List was found and will now be used to create to corresponding fields..."
                                        $fieldDefinitions = $xmlList.Fields.ChildNodes
                                        Add-SchedulerFieldsToList -list $existingList -fieldDefinitions $fieldDefinitions
                                        lm -Category $LogCat  -message "Finished adding fields."
                                        if($viewDefinitions -ne $null){
                                            lm -Category $LogCat  -message "Start adding views..."
                                            Show-SPETextLine -text "Erzeuge nun Views..."
                                            Add-SchedulerViewsToList -list $existingList -viewsDefinition $viewDefinitions -Overwrite $true
                                            lm -Category $LogCat  -message "Finished addings views."
                                            Show-SPETextLine -text "Erstellung der Views abgeschlossen."
                                        }
                                    } 
                                    else {
                                        lm -Category $LogCat -level Unexpected -message "List could not be found. Script will be aborted."
                                        $global:foundErrors = $true
                                        $false
                                    }
                                }
                            }
                            catch 
                            {
	                            $exMessage = $_.Exception.Message
	                            $innerException = $_.Exception.InnerException
	                            $info = "Error at creation of fields to list '$listName' on Website '$CurrentWebScriptInternalName'."
                                lx -Stack $_ -Category $LogCat -info $info
                                $global:foundErrors = $true
                            }
                            #endregion
                            #region Activate SPLogging after creation of LogList
                            if($listName -eq "Scheduler_Log"){
                                lm -Category $LogCat -message "Initiate Logging to SPLogList"
                                Show-SPETextArray -textArray @("SharePoint-Loglist ist created.","","Shall Logging to SharePoint-List be enabled?")
                                $choice = Select-SPEYN
                                if($choice){
                                    $Global:logList = $null
                                    Update-SPEConfigVariable -Name "LogToSPList" -Value '$true'
                                    Update-SPEConfigVariable -Name "UrlToLogWeb" -Value $('"' + $currentWebUrl + '"')
                                    Update-SPEConfigVariable -Name "LogListName" -Value $('"' + $listName + '"')
                                    lm -Category $LogCat -message "Now logging to SPLogList is activated."
                                }
                            }
                            #endregion
                        }
                    }
                lm -Category $LogCat  -message "Finished working on Website '$CurrentWebScriptInternalName'"
            }
            lm -Category $LogCat -level Medium -message "..succesfully finished creation of lists."
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Remove-SchedulerList
    Function Remove-SchedulerList{
        <#
            .SYNOPSIS
            This Cmdlet deletes a single list inside a website
            
            .DESCRIPTION
            This Cmdlet deletes a single list inside a website

            .PARAMETER Web
            The Website

            .PARAMETER ListName
            The Title of the list to delete
        #>
        [CmdletBinding()]
        param(
            [Microsoft.SharePoint.Client.Web]$Web,
            [String]$ListName
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
        }
        Process{
            Exit-SPEOnCtrlC
            $listName = $xmlList.Attributes["Name"].Value 
            Show-SPETextLine -text "Lösche Liste '$ListName'..."
            if($ListName -eq "Scheduler_Log"){
                Update-SPEConfigVariable -Name "LogToSPList" -Value '$false'
            }                      
            $listToDelete = Get-SPECsomList -Web $Web -ListTitle $ListName
            if($listToDelete -ne $null -or !$listToDelete.ServerObjectIsNull){
                lm -Category $LogCat  -message "deleting list '$ListName'..."
                #$listToDelete.Recycle() | out-null
                try{ 
                    $listToDelete.DeleteObject() | out-null
                    $listToDelete.Update()
                    $listToDelete.Context.ExecuteQuery() 
                } catch {
	                $exMessage = $_.Exception.Message
                    $noExceptionEN = "The page you selected contains a list that does not exist.  It may have been deleted by another user"
                    $noExceptionDE = "Die gewählte Seite verweist auf eine nicht vorhandene Liste. Möglicherweise wurde sie von einem anderen Benutzer gelöscht"
                    if(!$($exMessage -match $noExceptionEN) -and !$($exMessage -match $noExceptionDE)){
	                    $info = "Error at deletion of list '$ListName'."
                        lx -Stack $_ -info $info -Category $LogCat
                    }
                }
                lm -Category $LogCat  -message "...successfully deleted list '$ListName'."
                Show-SPETextLine -text "Liste '$ListName' wurde gelöscht."                       
            } else {
                Show-SPETextLine -text "Liste '$ListName' konnte nicht erfasst und daher auch nicht gelöscht werden."                       
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Remove-SchedulerLists
    Function Remove-SchedulerLists{
        <#
            .SYNOPSIS
            This Cmdlet deletes all Lists of the Scheduler defined by Scheduler_SetupData.xml
            
            .DESCRIPTION
            This Cmdlet deletes all Lists of the Scheduler defined by Scheduler_SetupData.xml

            .PARAMETER SetupData
            The XML Document of the Scheduler_SetupData.xml

            .PARAMETER Web
            The CSOM RootWebsite
        #>
        [CmdletBinding()]
        param(
            [Xml]$SetupData,
            [Microsoft.SharePoint.Client.Web]$Web
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
        }
        Process{
            Exit-SPEOnCtrlC
            lm -Category $LogCat -level Medium -message "Start deletion of Lists..."
            foreach($xmlWebsite in $SetupData.Scheduler.Websites.ChildNodes)
            {
                $CurrentWebScriptInternalName = $xmlWebsite.Attributes["ScriptInternalName"].Value
                lm -Category $LogCat  -message "Start working on Website '$CurrentWebScriptInternalName'"
                $pathWebSite = $xmlWebsite.Attributes["relativeUrl"].Value
                $WebUrl = $Web.Url.ToString().TrimEnd("/")
                $currentWebUrl = $WebUrl + $pathWebSite
                $currentWeb = Get-SchedulerWebsite -Url $currentWebUrl
                if($currentWeb -ne $null){
                    foreach($xmlList in $xmlWebsite.Lists.ChildNodes)
                    {
                        $listName = $xmlList.Name
                        Remove-SchedulerList -Web $currentWeb -ListName $listName
                    }
                }
            }
        }
    }
    #endregion
    #EndOfFunction

    #region Function Update-SchedulerLists
    Function Update-SchedulerLists{
        [CmdletBinding()]
        param(
            [Xml]$SetupData,
            [Microsoft.SharePoint.Client.Web]$Web
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
        }
        Process{
            Exit-SPEOnCtrlC
            lm -category $LogCat -level Medium -message "Start updating Lists..."
            foreach($xmlWebsite in $SetupData.Scheduler.Websites.ChildNodes)
            {
                $CurrentWebScriptInternalName = $xmlWebsite.Attributes["ScriptInternalName"].Value
                lm -category $LogCat  -message "Start working on Website '$CurrentWebScriptInternalName'"
                $pathWebSite = $xmlWebsite.Attributes["relativeUrl"].Value
                $WebUrl = $Web.Url.ToString().TrimEnd("/")
                $currentWebUrl = $WebUrl + $pathWebSite
                $currentWeb = Get-SchedulerWebsite -Url $currentWebUrl
                if($currentWeb -ne $null){
                    foreach($xmlList in $xmlWebsite.Lists.ChildNodes)
                    {
                        $listName = $xmlList.Name
                        $listUpdate = [System.Convert]::ToBoolean($xmlList.Update)
                        if($listUpdate){
                            lm -category $LogCat -level High -message "Start Updating List '$listName'..."
                            Remove-SchedulerList -Web $currentWeb -ListName $listName
                            $newList = New-SchedulerList -Web $currentWeb -xmlList $xmlList
                            $fieldDefinitions = $xmlList.Fields
                            $viewDefinitions = $xmlList.Views
                            Add-SchedulerFieldsToList -list $newList -fieldDefinitions $fieldDefinitions
                            if($viewDefinitions -ne $null){
                                Add-SchedulerViewsToList -list $newList -viewsDefinition $viewDefinitions -Overwrite $true
                            }
                            lm -category $LogCat -level High -message "...finished Updating List '$listName'."
                        }
                    }
                }
                
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Add-SchedulerFieldsToList
    Function Add-SchedulerFieldsToList{
        <#
            .SYNOPSIS
            This Cmdlet adds fields defined in the Scheduler_SetupData.xml to their lists
            
            .DESCRIPTION
            This Cmdlet adds fields defined in the Scheduler_SetupData.xml to their lists

            .PARAMETER list
            the base CSOM-List into which the fields are added

            .PARAMETER fieldDefinitions
            .the XMLElement containing the fieldDefinitions
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)][Microsoft.SharePoint.Client.List]$list,
            [Parameter(Mandatory=$true)][System.Xml.XmlElement]$fieldDefinitions
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
            lm -Category $LogCat  -message "Start adding fields..."
            $curCtx = $list.Context
        }
        Process{
            Exit-SPEOnCtrlC
            foreach($fieldDefinition in $fieldDefinitions.ChildNodes)
            {
                try
                {
                $fieldName = $fieldDefinition.Name 
                lm -Category $LogCat  -message "Start adding field '$fieldName'..."
                    
                    $fieldDefBase = Convert-SPEStringToXMLElement -string $fieldDefinition.OuterXml
                    $fieldDefAddFieldOptions = $fieldDefBase.AddFieldOptions;
                    if($fieldDefAddFieldOptions -ne $null -and $fieldDefAddFieldOptions.HasChildNodes){
                        $fieldOptions = $fieldDefAddFieldOptions.ChildNodes | %{$_.LocalName};
                        $fieldDefBase.RemoveChild($fieldDefAddFieldOptions) | out-null;
                    } else {
                        $fieldOptions = $null;
                    }
                    $fieldDefMultiLookup = $fieldDefBase.MultiLookup;
                    if($fieldDefMultiLookup -ne $null -and $fieldDefMultiLookup.HasChildNodes){;
                        $fieldMultiLookup = $fieldDefMultiLookup.ChildNodes | %{$_.LocalName};
                        $fieldDefBase.RemoveChild($fieldDefMultiLookup) | out-null;
                    } else {
                        $fieldMultiLookup = $null;
                    }
                    $fieldType = $fieldDefinition.Type
                    if($fieldType -eq "Lookup" -or $fieldType -eq "LookupMulti"){ 
                        $lookupListName = $fieldDefinition.List
                        $parentWeb = $list.ParentWeb
                        $curCtx.Load($parentWeb)
                        $curCtx.ExecuteQuery()
                        $parentWebId = $parentWeb.Id
                        $lookupList = Get-SPECsomList -Web $parentWeb -ListTitle $lookupListName
                        if(!$lookupList.ServerObjectIsNull -and $lookupList -ne $null){
                            $lookupListId = "{" + $($lookupList.Id.ToString().TrimEnd("}").TrimStart("{")) + "}"
                            $fieldDefBase.List = $lookupListId
                            $fieldDefinitionXMLString = $fieldDefBase.OuterXml
                            Add-SPECsomListField -list $list -fieldDefinition $fieldDefinitionXMLString -FieldOptions $fieldOptions
                            if($fieldDefMultiLookup){
                                lm -Category $LogCat -level Verbose -message "Start adding additional lookups..."
                                $1stLookupFieldName = $fieldDefBase.Name 
                                $listFields = $list.Fields
                                $curCtx.Load($listFields)
                                $curCtx.ExecuteQuery()
                                $1stLookupField = $listFields.GetByInternalNameOrTitle($1stLookupFieldName)
                                $curCtx.Load($1stLookupField)
                                $curCtx.ExecuteQuery()
                                foreach($multiLookupDef in $fieldDefMultiLookup.ChildNodes){
                                    $multiLookupDisplayName = $multiLookupDef.DisplayName
                                    $multiLookupShowFieldName = $multiLookupDef.ShowField
#                                    lm -category $LogCat -level High -message "Trying to add multilookupfield with values multiLookupDisplayName = '$multiLookupDisplayName', 1stLookupFieldName = '$1stLookupFieldName', multiLookupShowFieldName = '$multiLookupShowFieldName'"
                                    $addLookupField = $listFields.AddDependentLookup($multiLookupDisplayName, $1stLookupField, $multiLookupShowFieldName)
                                    $curCtx.Load($addLookupField)
                                    $curCtx.ExecuteQuery()
                                    $addLookupField.Title = $multiLookupDisplayName
                                    $addLookupField.Update()
                                    $list.Update()
                                }
                                lm -Category $LogCat -level Verbose -message "...succesfully finished adding additional lookups."
                            }
                        }
                    }
                    elseif($fieldType -eq "User"){
                        $lookupListName = $fieldDefinition.List
                        $parentWeb = $curCtx.Site.RootWeb
                        $curCtx.Load($parentWeb)
                        $curCtx.ExecuteQuery()
                    
                        $lookupList = Get-SPECsomList -Web $parentWeb -ListTitle $lookupListName
                        if(!$lookupList.ServerObjectisNull -and $lookupList -ne $null){
                            $lookupListId = "{" + $($lookupList.Id.ToString().TrimEnd("}").TrimStart("{")) + "}"
                            $fieldDefBase.List = $lookupListId
                            $fieldDefinitionXMLString = $fieldDefBase.OuterXml
                        }
                        Add-SPECsomListField -list $list -fieldDefinition $fieldDefinitionXMLString -FieldOptions $fieldOptions
                    } 
                    else {
                        $fieldDefinitionXMLString = $fieldDefBase.OuterXml
                        Add-SPECsomListField -list $list -fieldDefinition $fieldDefinitionXMLString -FieldOptions $fieldOptions
                    }
                    lm -Category $LogCat  -message "...successfully finished adding field '$fieldName'."
                } 
                catch {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Error at creation of field '$fieldName'."
                    lx -Stack $_ -Category $LogCat -info $info
                    $global:foundErrors = $true
                } 
                finally {
                    $parentWeb = $null
                }
            }
        }
        End{
            lm -Category $LogCat  -message "...finished adding fields."
            $curCtx = $null
        }
    }
    #endregion
    #EndOfFunction

    #region Function Add-SchedulerViewsToList
    Function Add-SchedulerViewsToList{
        <#
            .SYNOPSIS
            This Cmdlet adds views defined in the Scheduler_SetupData.xml to their list
            
            .DESCRIPTION
            This Cmdlet adds views defined in the Scheduler_SetupData.xml to their list

            .PARAMETER List
            The CSOM list object

            .PARAMETER viewDefinition
            The XMLElement containing the defined views

            .PARAMETER Overwrite
            If the view already exists, it will be changed by the defintion
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)][Microsoft.SharePoint.Client.List]$list,
            [Parameter(Mandatory=$true)][System.Xml.XmlElement]$viewsDefinition,
            [Parameter(Mandatory=$true)][Boolean]$Overwrite=$false
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
            lm -Category $LogCat  -message "Start adding views..."
        }
        Process{
            foreach($viewDefinition in $viewsDefinition.ChildNodes){
                $catchOut = New-SPECsomListViewFromXml -List $list -XmlElement $viewDefinition -Overwrite $Overwrite
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction

#endregion

#region Functions for Import

    #region Function Import-SchedulerTestData
    Function Import-SchedulerTestData{
        [cmdletbinding()]
        param()
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
            lm -Category $LogCat -level High -message "Start import of Scheduler Testdata..."
            $xmlTestData = Test-SPEAndSetXMLFile -FilePath $PathXmlTestData
            $aiq = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
        }
        Process{
            foreach($xmlWebSite in $xmlTestData.Scheduler.Websites.ChildNodes){
                $curWebUrl = $UrlRootWeb + $($xmlWebsite.relativeUrl)
                $curWeb = Get-SPECsomWeb -Url $curWebUrl -Credentials $cred
                foreach($xmlList in $xmlWebSite.Lists.ChildNodes){
                    $list = Get-SPECsomList -Web $curWeb -ListTitle $($xmlList.Name)
                    Show-SPETextLine "Start deletion of items on list '$($list.Title)'"
                    lm -category $LogCat -m "Start deletion of items on list '$($list.Title)'"
                    $listCtx = $list.Context
                    $listItems = $list.GetItems($aiq)
                    $listCtx.Load($listItems)
                    $listCtx.ExecuteQuery()
                    if ($listItems.Count -gt 0){
                        for ($i = $listItems.Count-1; $i -ge 0; $i--)
                        {
                            $listItems[$i].DeleteObject()
                        } 
                        $listCtx.ExecuteQuery()
                    }
                    Show-SPETextLine "Finished deletion of items on list '$($list.Title)'"
                    lm -category $LogCat -m "Finished deletion of items on list '$($list.Title)'"
                    Show-SPETextLine "Start creation of items on list '$($list.Title)'"
                    lm -category $LogCat -m "Start creation of items on list '$($list.Title)'"
                    foreach($xmlItem in $xmlList.Items.ChildNodes){
                        $FieldValues = New-Object System.Collections.ArrayList;
                        foreach($attribute in $xmlItem.Attributes){
                            $fieldValuePair = New-Object System.Web.UI.Pair;
                            $fieldValuePair.First = $attribute.Name;
                            $fieldValuePair.Second = $attribute.Value;
                            if($fieldValuePair.Second -ne ""){
                                $FieldValues.Add($fieldValuePair) | Out-Null;
                            }
                        }
                        if($FieldValues.Count -gt 0){
                            $catchout = New-SchedulerListItem -List $list -FieldValues $FieldValues;
                        }
                    }
                    Show-SPETextLine "Finished creation of items on list '$($list.Title)'"
                    lm -category $LogCat -m "Finished creation of items on list '$($list.Title)'"
                }
            }
        }
        End{
            lm -Category $LogCat -level High -message "...finished import of Scheduler Testdata."
        }
    }
    #endregion
    #EndOfFunction
    
    #region Function New-SchedulerListItem
    Function New-SchedulerListItem {
        [CmdletBinding()]
        param(
		    [Microsoft.SharePoint.Client.List]
		    $List,
		    [System.Collections.ArrayList]
		    $FieldValues,
            [String]$message
        )
        begin{
            Test-SPEAndLoadCsomDLLs
            $ctx = $List.Context
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
            $ListName = $List.Title
            $ListFunctionalName = Get-SchedulerListFunctionalName -ListName $ListName
        }
        process{
            try{
                Show-SPEDots -message $message
                $itemCreateInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
                $fields = $List.Fields
                $ctx.Load($fields)
                $ctx.ExecuteQuery()
                $newitem = $List.AddItem($itemCreateInfo)
                $newitem.Update()
                $ctx.ExecuteQuery()
                foreach($fieldValuePair in $FieldValues)
                {
                    Show-SPEDots -message $message
                    #region reload the newitem for its version is changing after each newitem.update, which will lead to a "version conflict" error
                    try{
                        $ctx.Load($newitem)
                        $ctx.ExecuteQuery()
                    }
                    catch{
                        lx -Stack $_ -info "Error at reloading newitem to prohibit 'Version Conflict' error" -Category $LogCat
                    }
                    #endregion
                    $fieldExistsInList = $true
                    try{
                        $fieldName = $fieldValuePair.First
                        
                        $fieldIsTitleField = $false
                        if($fieldName -ne "Title"){
                            $fieldValue = $fieldValuePair.Second
                            $field = $fields.GetByInternalNameOrTitle($fieldName);
                            $ctx.Load($field);
                            $ctx.ExecuteQuery();
                        } else {
                            $fieldIsTitleField = $true
                        }
                    }
                    catch{
                        $noError = "does not exist"
                        if(!($_.Exception.Message -match $noError)){
                            $info = "Error at retrieving Field"
                            lx -Stack $_ -info $info
                        }
                        $fieldExistsInList = $false
                    }
                    if($fieldExistsInList -and !$fieldIsTitleField){
                        try{
                            $fieldType = $field.FieldTypeKind.ToString()
                            switch($fieldType){
                                "Text"{
                                    $newitem[$fieldName] = $fieldValue
                                    $newItem.Update()
                                    break;
                                }
                                "Lookup"{
                                    $curWeb = $List.ParentWeb
                                    $ctx.Load($curWeb)
                                    $ctx.ExecuteQuery()
                                
                                    $fieldSchemaXml = Convert-SPEStringToXMLElement -string $($field.SchemaXml)
                                    $lookupListId = $fieldSchemaXml.List
                                    $lookupList = Get-SPECsomList -Web $curWeb -ListId $lookupListId
                                    if($fieldValue -match ","){
                                        $CacheArray = New-Object System.Collections.ArrayList
                                        $fieldValueArray = $fieldValue.Split(",")
                                        foreach($el in $fieldValueArray){
                                            Show-SPEDots -message $message
                                            if($ListFunctionalName -ne $null){
                                                if($fieldName -match "Topic" -and !$($fieldName -match "TopicDescription")){
                                                    $lookupFieldName = $fieldName.Replace($ListFunctionalName,"")
                                                } else {
                                                    $lookupFieldName = $fieldName
                                                }
                                            } else {
                                                $lookupFieldName = $fieldName
                                            }
                                            $query = New-Object Microsoft.SharePoint.Client.CamlQuery;
                                            $query.ViewXml = "<View><Query><Where><Eq><FieldRef Name='$lookupFieldName' /><Value Type='Text'>$el</Value></Eq></Where></Query></View>";
                                            $lookupListItems = $lookupList.GetItems($query);
                                            $ctx.Load($lookupListItems);
                                            $ctx.ExecuteQuery();
                                            $flv = new-object Microsoft.SharePoint.Client.FieldLookupValue
                                            $flv.LookupId = $lookupListItems[0].Id.ToString()
                                            $CacheArray.Add($flv)
                                        }
                                        [Microsoft.SharePoint.Client.FieldLookupValue[]]$flvArray = $CacheArray
                                        $newitem[$fieldName] = $flvArray
                                    } 
                                    else {
                                        if($ListFunctionalName -ne $null){
                                            if($fieldName -match "Topic" -and !$($fieldName -match "TopicDescription")){
                                                $lookupFieldName = $fieldName.Replace($ListFunctionalName,"")
                                            } else {
                                                $lookupFieldName = $fieldName
                                            } 
                                        } else {
                                            $lookupFieldName = $fieldName
                                        }
                                        $query = New-Object Microsoft.SharePoint.Client.CamlQuery;
                                        $query.ViewXml = "<View><Query><Where><Eq><FieldRef Name='$lookupFieldName' /><Value Type='Text'>$fieldvalue</Value></Eq></Where></Query></View>";
                                        $lookupListItems = $lookupList.GetItems($query);
                                        $ctx.Load($lookupListItems);
                                        $ctx.ExecuteQuery();
                                        $lookupItem = $lookupListItems[0];
                                        $lookupItemId = $lookupItem.ID.ToString();
                                        $flv = new-object Microsoft.SharePoint.Client.FieldLookupValue
                                        $flv.LookupId = $lookupListItems[0].Id.ToString()
                                        $CacheArray = New-Object System.Collections.ArrayList
                                        $CacheArray.Add($flv)
                                        [Microsoft.SharePoint.Client.FieldLookupValue[]]$flvArray = $CacheArray
                                        #$fieldValueString = $lookupItem.Id.toString() + ";#" + $lookupItem[$fieldname];
                                        #$newItem[$fieldName] = $fieldValueString
                                        $newItem[$fieldName] = $flvArray
                                    }
                                    $newItem.Update();
                                    break;
                                }
                                "Boolean"{
                                    $newItem[$fieldName] = [System.Convert]::ToBoolean($fieldValue)
                                    $newitem.Update()
                                    break;
                                }
                                "Number"{
                                    $newitem[$fieldName] = [System.Convert]::ToDecimal($fieldValue)
                                    $newItem.Update()
                                    break;
                                }
                                "DateTime"{
                                    $newitem[$fieldName] = [System.Convert]::ToDateTime($fieldValue)
                                    $newItem.Update()
                                    break;
                                }
                                Default{
                                    $newitem[$fieldName] = $fieldValue
                                    $newItem.Update()
                                    break;
                                }
                            }
                        }
                        catch{
                            lx -Stack $_ -info "Error at creating Value for field '$fieldName' with value '$fieldvalue' and type '$fieldtype' on list '$($List.Title)'." -Category $LogCat
                        }
                    }
                }
                lm -m "setting new item to list '$($List.Title)'" -category $LogCat
                $newItem.Update()
                $ctx.ExecuteQuery()
                return $newitem
            }
            catch{
                $noCall = "The list item could not be added or updated because duplicate values were found "
                if($_.Exception.Message -match $noCall){
                    lm  -category $LogCat -message "Item already exists and will not be added again." -level Unexpected
                } else {
                    lx -Stack $_ -info "Error at creating new Item on list '$($List.Title)'." -Category $LogCat
                }
            }
        }
        End{
            $ctx = $null
        }
    }
    #endregion
    #EndOfFunction

#endregion

#region Functions for Workflows

    #region Function Add-SchedulerLookupDataToObject
    Function Add-SchedulerLookupDataToObject{
        [CmdletBinding()]
        param(

            [Microsoft.SharePoint.Client.FieldLookupValue]$lookupItem,
            [Microsoft.SharePoint.Client.FieldCollection]$curListFields,
            [String]$curFieldDisplayName,
            [String]$curFieldName,
            [Microsoft.SharePoint.Client.Web]$curWeb,
            [Microsoft.SharePoint.Client.ClientContext]$curCtx,
            [int]$levelToLog,
            [guid]$thisCorrelationId,
            [psobject]$obj,
            [String]$message
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)" 
        }
        Process{
            $lookupId = $lookupItem.LookupId
            $lookupValue = $lookupItem.LookupValue

            $curListField = $curListFields | ?{$_.Title -eq $curFieldDisplayName}
            if($curListField){
                $lookupListId = $curListField.LookupList
                $lookupList = Get-SPECsomList -Web $curWeb -ListId $lookupListId
                try{
                    if(![bool]($obj.psobject.Properties -match $curFieldName)){
                        $obj | Add-Member -MemberType NoteProperty -Name $curFieldName -Value $lookupValue
                    }
                    else {
                        if($obj.$curFieldName){
                            try{$TestDateTime = [datetime]$($obj.$curFieldName)}catch{}
                            if($TestDateTime -eq $null){
                                if(!($obj.$curFieldName -match $lookupValue)){
                                    $obj.$curFieldName = $obj.$curFieldName + "," + $lookupValue
                                }
                            } else {
                                $TimesAreEqual = Compare-SPETimeStrings -DateTimeString1 $($obj.$curFieldName) -DateTimeString2 $lookupvalue
                                if(!$TimesAreEqual){
                                    $obj.$curFieldName = $lookupvalue
                                }
                            }
                        } else {
                            $obj.$curFieldName = $lookupvalue
                        }
                    }
                    $lookupSrcItem = $lookupList.GetItemById($lookupId)
                    $curCtx.Load($lookupSrcItem)
                    $curCtx.ExecuteQuery()
                    $returnObj = Get-SchedulerListItemComplete -ListItem $lookupSrcItem -ParentList $lookupList -ParentWeb $curWeb -Context $curCtx -levelToLog $($levelToLog + 1) -curCorrelationId $thisCorrelationId
                    $returnObjNoteProperties = $returnObj.psobject.properties.name
                    foreach($propertyName in $returnObjNoteProperties){
                        Show-SPEDots -message $message
                        if($propertyName -ne $curFieldName){
                            $propertyvalue = $returnObj.$propertyName
                            if(![bool]($obj.psobject.Properties.Name -match $propertyName)){
                                $obj | Add-Member -MemberType NoteProperty -Name $propertyName -Value $propertyvalue
                            } 
                            else {
                                if($propertyName -eq $curFieldDisplayName){
                                    $obj.$curFieldName = $propertyValue
                                }
                                else {
                                    if([String]::IsNullOrEmpty($obj.$propertyName)){
                                        try{
                                            $obj.$propertyName = $propertyvalue
                                        }
                                        catch {
                                            $obj | Add-Member -MemberType NoteProperty -Name $propertyName -Value $propertyvalue
                                        }
                                    } 
                                    else {
                                        try{$TestDateTime = [datetime]$($obj.$propertyName)}catch{}
                                        if($TestDateTime -eq $null){
                                            if(!($obj.$propertyName -match $propertyvalue)){
                                                $obj.$propertyName = $obj.$propertyName + "," + $propertyvalue
                                            }
                                        } else {
                                            $TimesAreEqual = Compare-SPETimeStrings -DateTimeString1 $($obj.$propertyName) -DateTimeString2 $lookupvalue
                                            if(!$TimesAreEqual){
                                                $obj.$propertyName = $propertyvalue
                                            }
                                        }
                                    }
                                }
                            }
                        } 
                    }
                }
                catch{
                    lx -Stack $_ -info "Error at retrieving LookupItem with Id '$lookupId' from list '$($lookupList.Title)'" -Category $LogCat -CorrId $thisCorrelationId
                }
            }
            return $obj
        }
        End{
        }
    }
    #endregion
    #EndOfFunction

    #region Function Get-SchedulerListItemComplete
    Function Get-SchedulerListItemComplete{
        <#
            .SYNOPSIS
            This Cmdlet iterates a ListItems fields defined by the Schedulers XMLSetupData to get all Lookup fields and put the together in one object
            
            .DESCRIPTION
            This Cmdlet iterates a ListItems fields defined by the Schedulers XMLSetupData to get all Lookup fields and put the together in one object. Therefor it scans the XMLSetupData for corresponding fields and adds them to the returned object.

            .PARAMETER ListItem
            the base CSOM-ListItem from which the iteration is started
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position=0, Mandatory=$true)]
            [Microsoft.SharePoint.Client.ListItem]$ListItem,
            [Parameter()]
            [Microsoft.SharePoint.Client.List]$ParentList,
            [Parameter()]
            [Microsoft.SharePoint.Client.Web]$ParentWeb,
            [Parameter()]
            [Microsoft.SharePoint.Client.ClientContext]$Context,
            [Parameter()]
            [int]$levelToLog=0,
            [Parameter()]
            [Guid]$curCorrelationId=$Global:CorrelationId,
            [Parameter()]
            [String]$message
        )
        Begin{
            $thisCorrelationId = [Guid]::NewGuid() #Set-SPEGuidIncrement -guid $curCorrelationId
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
            $global:xmlSetupData = Test-SPEAndSetXMLFile -FilePath $PathXmlSetupData
            $allItemsQuery = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery();
        }
        Process{
            $obj = New-Object psobject;
            #region get the source objects
            if($Context -eq $null){
                $curCtx = $ListItem.Context;
            } 
            else {
                $curCtx = $Context
            }
            if($ParentList -eq $null){
                $curList = $ListItem.ParentList;
                $curCtx.Load($curList);
                $curCtx.ExecuteQuery();
            } 
            else {
                $curList = $ParentList
            }
            if($ParentWeb -eq $null){
                $curWeb = $curList.ParentWeb;
                $curCtx.Load($curWeb);
                $curCtx.ExecuteQuery();
            } 
            else {
                $curWeb = $ParentWeb
            }
            $curListName = $curList.Title;
            $curListFunctionalName = Get-SchedulerListFunctionalName -ListName $curListName
            $curWebUrl = $($curWeb.Url.TrimEnd("/") + "/").Replace($UrlRootWeb,"");
            $curListFields = $curList.Fields
            $curCtx.Load($curListFields)
            $curCtx.ExecuteQuery()
            #endregion
            #region get the XML fields
            $curWebXml = $xmlSetupData.Scheduler.Websites.ChildNodes | ?{$_.relativeUrl -eq $curWebUrl};
            $curListXml = $curWebXml.Lists.ChildNodes | ?{$_.Name -eq $curListName};
            $xmlStr = "<Fields>";
            foreach($el in $($curListXml.Fields.ChildNodes)){
                if($el.Name -ne "Title"){
                    $xmlStr += $el.OuterXml;
                }
            }
            foreach($el in $($curListXml.Fields.ChildNodes)){
                if($el.MultiLookup -ne $null){
                    foreach($subEl in $($el.MultiLookup.Childnodes)){
                        $xmlStr += $subEl.OuterXml;
                    }
                }
            }
            $xmlStr += "</Fields>";
            $curFields = Convert-SPEStringToXMLElement -string $xmlStr
            #endregion
            #region clean up XML-Object
            for($i = 0; $i -le 2; $i++){ 
                foreach($xmlElement in $curFields.ChildNodes){
                    if($xmlElement.HasChildNodes){
                        foreach($childnode in $xmlElement.ChildNodes){
                            $xmlElement.RemoveChild($childnode) | Out-Null;
                        }
                    }
                }
            }
            #endregion
            foreach($curField in $curFields.ChildNodes){
                Show-SPEDots -message $message
                try{
                    $curfieldType = $curField.Attributes["Type"].Value
                    $curFieldName = $curField.Attributes["Name"].Value
                    $curFieldDisplayName = $curField.Attributes["DisplayName"].Value
                    $curFieldList = $curField.Attributes["List"].Value
                    $obj | Add-Member -MemberType NoteProperty -Name $curFieldName -Value $null -ErrorAction SilentlyContinue
                    if($curfieldType -match "Lookup"){
                        #region processing for lookup
                        $curItemLookups = $ListItem[$curFieldDisplayName]
                        if([String]::IsNullOrEmpty($curItemLookups)){
                            $curItemLookups = $ListItem[$curFieldName]
                            if([String]::IsNullOrEmpty($curItemLookups)){
                                lm -category $LogCat -CorrelationId $thisCorrelationId -message "Cannot retrieve lookup items for FieldName '$curFieldName' or FieldDisplayName '$curFieldDisplayName' on current list '$curListName'" -level High
                                $curItemLookups = $null
                            }
                        } 
                        if($curItemLookups){
                            $curItemLookupBaseType = Get-SPEBaseTypeNameFromObject -object $curItemLookups
                            switch($curItemLookupBaseType){
                                "Array"{
                                    foreach($lookupItem in $curItemLookups){
                                        if([String]::IsNullOrEmpty($obj.$curFieldName)){
                                            $obj.$curFieldName = $lookupItem.LookupValue
                                        } else {
                                            try{$TestDateTime = [datetime]$($obj.$curFieldName)}catch{}
                                            try{$TestNumber = [int]$($obj.$curFieldName)}catch{}
                                            if(!$TestDateTime -and !$TestNumber){
                                                if($($obj.$curFieldName -match $lookupItem.LookupValue)){
                                                    $obj.$curFieldName = $obj.$curFieldName + "," + $lookupItem.LookupValue
                                                }
                                            } else {
                                                $obj.$curFieldName = $lookupItem.LookupValue
                                            }
                                        }
                                        $obj = Add-SchedulerLookupDataToObject -lookupItem $lookupItem -curListFields $curListFields -curFieldDisplayName $curFieldDisplayName -curFieldName $curFieldName -curWeb $curWeb -curCtx $curCtx -levelToLog $levelToLog -thisCorrelationId $thisCorrelationId -obj $obj -message $message
                                    }
                                    break;
                                }
                                "FieldLookupValue"{
                                    $lookupItem = $curItemLookups
                                    if([String]::IsNullOrEmpty($obj.$curFieldName)){
                                        $obj.$curFieldName = $lookupItem.LookupValue
                                    } else {
                                        try{$TestDateTime = [datetime]$($obj.$curFieldName)}catch{}
                                        try{$TestNumber = [int]$($obj.$curFieldName)}catch{}
                                        if(!$TestDateTime -and !$TestNumber){
                                            if(!($obj.$curFieldName -match $lookupItem.LookupValue)){
                                                $obj.$curFieldName = $obj.$curFieldName + "," + $lookupItem.LookupValue
                                            }
                                        } else {
                                            $obj.$curFieldName = $lookupItem.LookupValue
                                        }
                                    }
                                    $obj = Add-SchedulerLookupDataToObject -lookupItem $lookupItem -curListFields $curListFields -curFieldDisplayName $curFieldDisplayName -curFieldName $curFieldName -curWeb $curWeb -curCtx $curCtx -levelToLog $levelToLog -thisCorrelationId $thisCorrelationId -obj $obj
                                    break;
                                }
                                Default{
                                    lm -category $LogCat -level High -CorrelationId $thisCorrelationId -message "LookupBaseType is undefined"
                                    break;
                                }
                            }
                        }
                        #endregion
                    } 
                    else{
                        #region processing for non-lookup-value
                        $currentFieldValue = $ListItem[$curFieldDisplayName]
                        if([String]::IsNullOrEmpty($currentFieldValue)){
                            $currentFieldValue = $ListItem[$curFieldName]
                            if([String]::IsNullOrEmpty($currentFieldValue)){
                                lm -category $LogCat -CorrelationId $thisCorrelationId -message "Cannot retrieve non-lookup value for FieldName '$curFieldName' or FieldDisplayName '$curFieldDisplayName' on current list '$curListName'" -level High
                                $currentFieldValue = $null
                            }
                        }
                        if($currentFieldValue){
                            try{$TestDateTime = [datetime]$currentFieldValue}catch{}
                            try{$TestNumber = [int]$currentFieldValue}catch{}
                            if($TestDateTime -or $TestNumber){
                                $obj.$curFieldName = $currentFieldValue
                            } else {
                                if($obj.$curFieldName){
                                    if(!($obj.$curFieldName -match $currentFieldValue)){
                                        $obj.$curFieldName = $obj.$curFieldName + "," + $currentFieldValue
                                    }
                                }
                                else{
                                    $obj.$curFieldName = $currentFieldValue
                                }
                            }
                        }
                        #endregion
                    }
                }
                catch {
                    lx -Stack $_ -info "Error at setting obj.Property. Cannot find Property" -Category $LogCat -CorrId $thisCorrelationId
                    lm -category $LogCat -level Unexpected -message "obj is $obj" -CorrelationId $thisCorrelationId
                }
            }
            return $obj
        }
        End{
            $curctx = $null;
            $curWeb = $null;
            $curList = $null;
        }
    }
    #endregion
    #EndOfFunction

    #region Function Convert-SchedulerCompleteItemToFieldValuesArrayList
    Function Convert-SchedulerCompleteItemToFieldValuesArrayList{
        [CmdletBinding()]
        param(
            [psobject]$obj,
            [String]$message
        )
        Begin{
        }
        Process{
            $fieldValues = new-object System.Collections.ArrayList
            #region transform the SrcItemObject to an ArrayList of Field-Value-Pairs
            $objKeys = $srcItemObject | gm | ?{$_.MemberType -eq "NoteProperty"}
            foreach($key in $objKeys){
                Show-SPEDots -message $curMessage
                $newFieldValuePair = new-object System.Web.UI.Pair;
                $newFieldValuePair.First = $key.Name;
                if($newFieldValuePair.First -ne "Title"){
                    $newFieldValuePair.Second = $srcItemObject.$($key.Name);
                    $fieldValues.Add($newFieldValuePair) | out-null;
                }
            }
            #endregion
            return $fieldValues
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Publish-SchedulerObjects
    Function Publish-SchedulerObjects{
        [CmdletBinding()]
        param(
            [Xml]$SetupData,
            [Microsoft.SharePoint.Client.Web]$RootWeb,
            [String]$message
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)";
            $curCtx = $RootWeb.Context;
            $subwebs = $RootWeb.Webs;
            $curCtx.Load($subwebs);
            $curCtx.ExecuteQuery();
            $allItemsQuery = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery();
            $curCorrId = [guid]::NewGuid();
            lm -Category $LogCat -level High -message "Start publishing Scheduler objects...";
        }
        Process{
            $objCnt = 0;
            $srcLists = New-Object System.Collections.ArrayList
            #region iterate the lists
            foreach($listNameToPublish in $listNamesToPublish){
                $curMessage = "$message - Aktuelle Liste: $listNameToPublish";
                Show-SPEDots -message $curMessage;
                lm -category $LogCat -message "Trying to retrieve source list '$listNameToPublish'..." -level Verbose -CorrelationId $curCorrId;
                $srcList = Get-SPECsomList -Web $RootWeb -ListTitle $listNameToPublish;
                $srcItems = Get-SPECsomListItemsAsArrayList -List $srcList -Context $curCtx -curCorrId $curCorrId
                # $curCtx.Load($srcItems);
                # $curCtx.ExecuteQuery();
                #region iterate the subwebs
                foreach($subweb in $subwebs){
                    Show-SPEDots -message $curMessage
                    #get the target list
                    lm -category $LogCat -message "Trying to retrieve target list '$listNameToPublish' on website '$($subweb.Title)'" -level Verbose -CorrelationId $curCorrId
                    $trgList = Get-SPECsomList -Web $subweb -ListTitle $listNameToPublish
                    $testItems = Get-SPECsomListItemsAsArrayList -List $trgList -Context $curCtx -curCorrId $curCorrId
                    if($trgList -ne $null -and $trgList.GetType().Name -eq "List"){
                        #get the lcid
                        $lcid = $subweb.Language;
                        switch($lcid){
                            1031 {
                                $languageShortcut = "DE";
                                break;
                            }
                            1033 {
                                $languageShortcut = "EN";
                                break;
                            }
                            Default{
                                lm -Category $LogCat -level Unexpected -message "Can not get LCID on Object" -CorrelationId $curCorrId
                                break;
                            }
                        }
                        lm -category $LogCat -message "target list '$listNameToPublish' has language '$languageShortcut'." -level Verbose -CorrelationId $curCorrId
                        #get the baseField from the current listname
                        $baseFieldName = $listNameToPublish.Replace("Scheduler_","").TrimEnd("s") + $languageShortcut
                        #region iterate the source items
                        lm -category $LogCat -message "now looping through the source items..." -level Verbose -CorrelationId $curCorrId
                        foreach($srcItem in $srcItems){
                            $objCnt++
                            Show-SPEDots -message $curMessage
                            lm -category $LogCat -message "obj no.:'$objCnt' - processing item with id '$($srcItem.Id)'..." -level Verbose -CorrelationId $curCorrId
                            if($srcItem["LanguageShortcut"].LookupValue -eq $languageShortcut){
                                #complete the scrItem with its lookups iteratively to create the new items completed by their corresponding data
                                $srcItemBaseFieldValue = $srcItem[$baseFieldName]
                                try{
                                    $testItem = $testItems | ?{$_[$baseFieldName] -eq $srcItemBaseFieldValue};
                                }
                                catch {
                                    $noError = " und die folgende Argumenteanzahl kann keine Überladung gefunden werden"
                                    if($_.Exception.Message -match $noError){
                                        lm -m "A possibly published item cannot be found. Setting value for testitem to NULL" -Category $LogCat -level Verbose -CorrelationId $curCorrId
                                    } else {
                                        lx -Stack $_ -info "Error at retrieving a possibly published item. Setting value for testitem to NULL" -Category $LogCat -CorrId $curCorrId
                                    }
                                    $testItem = $null
                                }
                                if($srcItem["Published"] -eq $true){ #item is set to be published
                                    lm -category $LogCat -message "Source item with id '$($srcItem.Id)' is set to be published" -level Verbose -CorrelationId $curCorrId
                                    #region test, if a corresponding published item already exists
                                    if($testItem.ServerObjectIsNull -or $testItem -eq $null){ #corresponding item does not exist
                                        lm -category $LogCat -message "Target item does not exist and will be created now. Collecting data..." -level Verbose -CorrelationId $curCorrId
                                        $srcItemObject = Get-SchedulerListItemComplete -ListItem $srcItem -message $curMessage
                                        #region workaround for upcoming decimal points
                                        if($srcItemObject.psobject.Properties.Name -match "AvailablePCs"){
                                            [String]$strCurrentFieldValue = $srcItemObject.AvailablePCs
                                            if($strCurrentFieldValue.Contains(".")){
                                                $arrCurrentFieldValue = $strCurrentFieldValue.Split(".")
                                            } elseif($strCurrentFieldValue.Contains(",")){
                                                $arrCurrentFieldValue = $strCurrentFieldValue.Split(",")
                                            }
                                            if($arrCurrentFieldValue.Length -gt 1){
                                                [int]$curValueToSet = $arrCurrentFieldValue[0]
                                            } else {
                                                $curValueToSet = $currentFieldValue
                                            }
                                            $srcItemObject.AvailablePCs = $curValueToSet
                                        }
                                        #endregion
                                        lm -category $LogCat -message "converting object to FieldValuesArrayList..." -level Verbose -CorrelationId $curCorrId
                                        $fieldValues = Convert-SchedulerCompleteItemToFieldValuesArrayList -obj $srcItemObject -message $curMessage
                                        lm -category $LogCat -message "creating listitem..." -level Verbose -CorrelationId $curCorrId
                                        $newitem = New-SchedulerListItem -List $trgList -FieldValues $fieldValues -message $curMessage
                                        lm -category $LogCat -message "... successfully created target item." -level Verbose -CorrelationId $curCorrId
                                    }
                                    else { #corresponding item exists
                                        lm -category $LogCat -message "Item is already published" -level Verbose -CorrelationId $curCorrId
                                    }
                                    #endregion
                                }
                                else { #Item is set to be unpublished
                                    lm -category $LogCat -message "Source item with id '$($srcItem.Id)' is set to be unpublished." -level Verbose -CorrelationId $curCorrId
                                    lm -category $LogCat -message "testing for an existing target item" -level Verbose -CorrelationId $curCorrId
                                    if($testItem.ServerObjectIsNull -or $testItem -eq $null){ #corresponding item does not exist
                                        lm -category $LogCat -message "No item found to be deleted. Maybe the source item has not been published before." -level Medium -CorrelationId $curCorrId
                                    }
                                     else {
                                        try{
                                            lm -category $LogCat -message "Target item exists and will be deleted now..." -level Verbose -CorrelationId $curCorrId
                                            $testItem.DeleteObject()
                                            $curCtx.ExecuteQuery()
                                            lm -category $LogCat -message "...successfully deleted target item." -level Verbose -CorrelationId $curCorrId
                                        }
                                        catch{
                                            lx -Stack $_ -info "Error at deletion of a published item" -Category $LogCat -CorrId $curCorrId
                                        }

                                    }
                                }
                                lm -category $LogCat -message "...finished processing item with id '$($srcItem.Id)'..." -level Verbose -CorrelationId $curCorrId
                            }
                            else {
                                lm -category $LogCat -message "current item is not set for the current language." -level Verbose -CorrelationId $curCorrId
                            }
                        }
                        lm -category $LogCat -message "...finished iterating the source items." -level Verbose -CorrelationId $curCorrId
                        #endregion 
                    }
                    else {
                        lm -category $LogCat -message "TargetList '$listNameToPublish' cannot be found." -level Unexpected -CorrelationId $curCorrId
                    }
                }
                #endregion
            }
            #endregion
        }
        End{
            $curCtx = $null
            lm -Category $LogCat -level High -message "Finished publishing Scheduler objects..."
        }
    }
    #endregion
    #EndOfFunction

    #region Function Get-SchedulerListFunctionalName
    Function Get-SchedulerListFunctionalName{
        [CmdletBinding()]
        param(
            [String]$ListName
        )
        Begin{}
        Process{
            if(Get-Variable -Name "ListFunctionalNames" -ErrorAction SilentlyContinue){
                if(![String]::IsNullOrEmpty($ListFunctionalNames[$ListName])){
                    return $ListFunctionalNames[$ListName]
                } else {
                    return $null
                }
            } else {
                return $null
           }
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Get-SchedulerSubscriptionStateCase
    Function Get-SchedulerSubscriptionStateCase{
        [CmdletBinding()]
        param(
            [String]$FrontendState,
            [String]$BackendState
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)";
        }
        Process{
            $SubscriptionStates = @{
                "Registered" = @{
                    "Registered" = 1;
                    "Booked" = 2;
                    "Completed" = 3;
                    "No Show" = 4;
                    "Canceled" = 5;
                };
                "Booked" = @{
                    "Registered" = 6;
                    "Booked" = 7;
                    "Completed" = 8;
                    "No Show" = 9;
                    "Canceled" = 10;
                };
                "Completed" = @{
                    "Registered" = 11;
                    "Booked" = 12;
                    "Completed" = 13;
                    "No Show" = 14;
                    "Canceled" = 15;
                };
                "No Show" = @{
                    "Registered" = 16;
                    "Booked" = 17;
                    "Completed" = 18;
                    "No Show" = 19;
                    "Canceled" = 20;
                };
                "Canceled" =@{
                    "Registered" = 21;
                    "Booked" = 22;
                    "Completed" = 23;
                    "No Show" = 24;
                    "Canceled" = 25;
                };
            }
            return $($SubscriptionStates.$FrontendState.$BackendState)
        }
        End{}
    }
    #endregion
    #EndOfFunction

#endregion

#endregion

#region fertig und dokumentiert
#endregion

#region Entwicklungsstadium

#region Functions for Workflows

    #region Function Get-SchedulerWorkflowStatus
    Function Get-SchedulerWorkflowStatus{
        [CmdletBinding()]
        param()
        Begin{}
        Process{}
        End{}
    }
    #endregion

    #region Function Set-SchedulerWorkflowStatus
    Function Set-SchedulerWorkflowStatus{
        [CmdletBinding()]
        param()
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)"
        }
        Process{}
        End{}
    }
    #endregion
    
    #region Function Group-SchedulerSubScriptionsByState
    Function Group-SchedulerSubScriptionsByState{
        [CmdletBinding()]
        param(
            [System.Collections.ArrayList]$ListItemsArrayList
        )
        Begin{}
        Process{
            foreach($state in $subscriptionStates){
                Set-Variable -Name $($state.Replace(" ","")) -Value (New-Object System.Collections.ArrayList) -Scope Script;
            }
            foreach($item in $ListItemsArrayList){
                $currentItemState = $item["State"];
                switch($currentItemState){
                    "Registered"{
                        $Registered.Add($item) | Out-Null;
                        break;
                    }
                    "Booked"{
                        $Booked.Add($item) | Out-Null;
                        break;
                    }
                    "Completed"{
                        $Completed.Add($item) | Out-Null;
                        break;
                    }
                    "No Show"{
                        $NoShow.Add($item) | Out-Null;
                        break;
                    }
                    "Canceled"{
                        $Canceled.Add($item) | Out-Null;
                        break;
                    }
                }
            }
            $obj = New-Object psobject;
            $obj | Add-Member -MemberType NoteProperty -Name "Registered" -Value $Registered;
            $obj | Add-Member -MemberType NoteProperty -Name "Booked" -Value $Booked;
            $obj | Add-Member -MemberType NoteProperty -Name "Completed" -Value $Completed;
            $obj | Add-Member -MemberType NoteProperty -Name "No Show" -Value $NoShow;
            $obj | Add-Member -MemberType NoteProperty -Name "Canceled" -Value $Canceled;
            return $obj;
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Sync-SchedulerSubscriptions
    Function Sync-SchedulerSubscriptions{
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true,Position=0)][Microsoft.SharePoint.Client.Web]$RootWeb,
            [guid]$curCorrId = [Guid]::NewGuid()
        )
        Begin{
            $LogCat = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)";
            $curCtx = $RootWeb.Context;
            $subwebs = $RootWeb.Webs;
            $curCtx.Load($subwebs);
            $curCtx.ExecuteQuery();
            $allItemsQuery = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery();
            $curCorrId = [guid]::NewGuid();
            $listTitleSubscriptions = "Scheduler_Subscriptions";
        }
        Process{
            try{
                #region get the Trainingsdates
                lm -level VerboseEx -category $LogCat -CorrelationId $curCorrId -message "get the trainingsdates from rootsite";
                $trainingsList = Get-SPECsomList -Web $RootWeb -ListTitle "Scheduler_Dates";
                $trainingsCollection = Get-SPECsomListItemsAsArrayList -List $trainingsList -curCorrId $curCorrId -Context $curCtx;
                #endregion
                if($trainingsCollection.Count -gt 0){
                    #region get the source items from subsites
                    lm -level VerboseEx -category $LogCat -CorrelationId $curCorrId -message "get the source items from subsites";
                    $srcItemsCollection = New-Object System.Collections.ArrayList;
                    # get object of listitems grouped by status

                    foreach($subweb in $subwebs){
                        $subscriptionsList = Get-SPECsomList -Web $subweb -ListTitle $listTitleSubscriptions;
                        $subscriptionsListItems = Get-SPECsomListItemsAsArrayList -List $subscriptionsList -curCorrId $curCorrId -Context $curCtx;
                        if($subscriptionsListItems.Count -gt 0){
                            $subscriptionsListItems | %{$srcItemsCollection.Add($_) | out-null}
                        }
                    }
                    $SubscriptionsGroupedByState = Group-SchedulerSubScriptionsByState -ListItemsArrayList $subscriptionsListItems
                    #endregion
                    if($srcItemsCollection.Count -gt 0){
                        #region get the target items from rootsite
                        $rootList = Get-SPECsomList -Web $RootWeb -ListTitle $listTitleSubscriptions;
                        $trgItemsCollection = Get-SPECsomListItemsAsArrayList -List $rootList -curCorrId $curCorrId -Context $curCtx;
                        #endregion
                        #region sync items
                        foreach($srcItem in $srcItemsCollection){
                            $itemExists = $false;
                            if($trgItemsCollection.Count -gt 0){
                                foreach($trgItem  in $trgItemsCollection){
                                    $curCtx.Load($trgItem);
                                    $curCtx.ExecuteQuery();
                                    if($($srcItem["SubscriptionID"]) -eq $($trgItem["SubscriptionID"])){
                                        $itemExists = $true;
                                        $curTrgItem = $srcItem;
                                        $curCtx.Load($curTrgItem);
                                        $curCtx.ExecuteQuery();
                                        break;
                                    }
                                }
                            } 
                            else {
                                lm -level High -category $LogCat -CorrelationId $curCorrId -message "No User Subscriptions found in backend.";
                            }
                            if(!$itemExists){
                                $srcItemObject = Get-SchedulerListItemComplete -ListItem $srcItem;
                                $srcItemFieldValues = Convert-SchedulerCompleteItemToFieldValuesArrayList -obj $srcItemObject;
                                $curTrgItem = New-SchedulerListItem -List $rootList -FieldValues $srcItemFieldValues;
                            } 
                            else {
                                lm -level VerboseEx -category $LogCat -CorrelationId $curCorrId -message "Item exists, no need to create it";
                            }
                            #region Item (now) exists, check and set Status
                            $curTrgSubScriptionID = $curTrgItem["SubscriptionID"];
                            $curTrgSubScriptionIDSplitArray = $curTrgSubScriptionID.split("-");
                            $correspondingTrainingsDateName = $curTrgSubScriptionID.Replace($($curTrgSubScriptionIDSplitArray[0] + "-"),"");
                            $correspondingTrainingsDate = $trainingsCollection | ?{$_["DateEN"] -eq $correspondingTrainingsDateName}
                            if(!$correspondingTrainingsDate){
                                $correspondingTrainingsDate = $trainingsCollection | ?{$_["DateDE"] -eq $correspondingTrainingsDateName}
                            }
                            if($correspondingTrainingsDate){        
                                $CorrespondingRoomId = $correspondingTrainingsDate["RoomName"].LookupId
                                $RootRoomsList = Get-SPECsomList -Web $RootWeb -ListTitle "Scheduler_Rooms"
                                $CorrespondingRoom = $RootRoomsList.GetItemById($RootRoomId)
                                if($CorrespondingRoom){
                                    $curTrgStatus = $curTrgItem["State"];
                                    $curSrcStatus = $srcItem["State"];
                                    $stateCase = Get-SchedulerSubscriptionStateCase -BackendState $curTrgStatus -FrontendState $curSrcStatus
                                    lm -message "statecase is $stateCase"
                                    switch($stateCase){
                                        1{ #F:Registered - F:Registered
                                            
                                            break;
                                        }
                                        2{#F:Registered - F:Booked
                                            break;
                                        }
                                        3{#F:Registered - F:Completed
                                            break;
                                        }
                                        4{#F:Registered - F:No-Show
                                            break;
                                        }
                                        5{#F:Registered - F:Canceled
                                            break;
                                        }
                                        6{#F:Booked - F:Registered
                                            break;
                                        }
                                        7{#F:Booked - F:Booked
                                            break;
                                        }
                                        8{#F:Booked - F:Completed
                                            break;
                                        }
                                        9{#F:Booked - F:No-Show
                                            break;
                                        }
                                        10{#F:Booked - F:Canceled
                                            break;
                                        }
                                        11{#F:Completed - F:Registered
                                            break;
                                        }
                                        12{#F:Completed - F:Booked
                                            break;
                                        }
                                        13{#F:Completed - F:Completed
                                            break;
                                        }
                                        14{#F:Completed - F:No-Show
                                            break;
                                        }
                                        15{#F:Completed - F:Canceled
                                            break;
                                        }
                                        16{#F:No-Show - F:Registered
                                            break;
                                        }
                                        17{#F:No-Show - F:Booked
                                            break;
                                        }
                                        18{#F:No-Show - F:Completed
                                            break;
                                        }
                                        19{#F:No-Show - F:No-Show
                                            break;
                                        }
                                        20{#F:No-Show - F:Canceled
                                            break;
                                        }
                                        21{#F:Canceled - F:Registered
                                            break;
                                        }
                                        22{#F:Canceled - F:Booked
                                            break;
                                        }
                                        23{#F:Canceled - F:No-Show
                                            break;
                                        }
                                        24{#F:Canceled - F:Canceled
                                            break;
                                        }
                                        25{#F:Canceled - F:Registered
                                            break;
                                        }
                                        Default{
                                            lm -level Unexpected -category $LogCat -CorrelationId $curCorrId -message "can not find a StateCase for frontend status '$curSrcStatus' and backend status '$curTrgStatus'";
                                            break;
                                        }
                                    }
                                }
                                else {
                                    lm -level High -category $LogCat -CorrelationId $curCorrId -message "can not find corresponding room.";
                                }
                            } 
                            else {
                                lm -level High -category $LogCat -CorrelationId $curCorrId -message "can not find corresponding trainingsdate.";
                            }
                            #endregion    
                        }
                        #endregion
                    } else {
                        lm -level High -category $LogCat -CorrelationId $curCorrId -message "No User Subscriptions found in frontend."
                    }
                }
            }
            catch{
                $info = "Error at Syncing the subscriptions"
                lx -Stack $_ -info $info -Category $LogCat -CorrId $curCorrId
            }
        }
        End{
            $curCtx = $null
        }
    }
    #endregion

    #region Function Set-SchedulerDateBookedSeats
    Function Set-SchedulerDateBookedSeats{
        [CmdletBinding()]
        param(
            [Microsoft.SharePoint.Client.ListItem]$TrainingsDate,
            #[Microsoft.SharePoint.Client.ListItem]$TrainingsRoom,
            [Parameter(ParameterSetName="Decrement")][Switch]$Decrement,
            [Parameter(ParameterSetName="Increment")][Switch]$Increment
        )
        Begin{}
        Process{
            #region get numbers for seats
                $RoomAvailableSeats = $TrainingsRoom["NoTraineeSeats"]

            #endregion
        }
        End{}
    }
    #endregion
    #EndOffunction

#endregion

#region Functions for Import


#endregion

#endregion

#EndOfFile