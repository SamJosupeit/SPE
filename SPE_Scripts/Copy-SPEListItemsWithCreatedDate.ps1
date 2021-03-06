param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# Alegri International Service GmbH - D-50668 Köln                    #
# Kunde   : Bayer Leverkusen - IT Communications                      #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Copy-SPEListItemsWithCreatedDate.ps1                      #
# Funktion: Dieses Script kopiert Items aus einer Custom SharePoint   #
# List in eine andere. Hierbei wird vor allem das Datum des           #
# "Created"-Felds berücksichtigt.                                     #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Krieger  | Erst-Erstellung                    | 02.12.2016 #
######################################################################>
#endregion

#region Voreinstellungen !!! Nicht ändern !!!

	#region Startzeit
	$global:starttime = get-date
	#endregion

    #region Wechsle in Arbeitsverzeichnis, wenn gesetzt
    if($WorkingDir){
        set-location $WorkingDir
    }
    #endregion
    #region Globale Variablen
        #region Erfassen des Scriptnamens zur Erstellung von Log- und Statusfile
            $global:ScriptName = ($MyInvocation.MyCommand.Name -replace ".ps1","")
            $global:ThisScript = ($MyInvocation.MyCommand.Definition)
        #endregion
        # ComputerName
            $global:computerName = ($env:COMPUTERNAME)
            
        #region Verzeichnispfade
            $global:PathWorkingDir = Get-Location
            $global:StringWorkingDir = $PathWorkingDir.ToString() + "\"
            $global:dirLog = $StringWorkingDir + "Log\"
            $global:dirRep = $StringWorkingDir + "Reports\"
            $ModuleToLoad = "SPE.Common"
            $dirModule = $StringWorkingDir + $ModuleToLoad + ".psd1"
        #endregion
    #endregion
    #region Laden des SPEModule
        Import-Module -Name ".\Modules\SPE.Common\SPE.Common.psd1"
        Import-Module -Name ".\Modules\SPE.SharePoint\SPE.SharePoint.psd1"
    #endregion
    #region Laden der Config
        Get-SPEConfig -ScriptName $ScriptName
    #endregion
    #region ConsoleTitle mit Scriptnamen versehen
    $oldConsoleTitle = Set-SPEConsoleTitle -newTitle "Aktuelles Script: $ScriptName"
    #endregion
    #region Add SharePoint PowerShell Snapin
    if($global:UsingSharePoint){
        if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) {
            Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue
        }
    }
    #endregion
	#region ScriptStatus
	$scriptCorrId = $global:DefaultCorrID
	$global:CorrelationId = $scriptCorrId
	Write-SPELogMessage -message "Script has started." -level "High"
	Write-SPEReportMessage -level "High" -area "Script" -category "Started" -message "Script has started." -CorrelationId $scriptCorrId
	$global:scriptaborted = $false
	$global:foundErrors = $false
	#endregion


    #region Warnmeldungen

        #region Warnung, falls TestModus aktiviert ist
        if($TestModus -eq $true){
            Write-SPELogMessage -message "!!!Achtung!!! TestModus aktiv !!! Es werden keine Daten gelöscht oder geschrieben !!!"
            Write-SPELogMessage -message "!!! Dient nur zum reinen Funktionstest !!!"
        }
        #endregion
        #region Warnung, falls Logging auf Console deaktiviert ist
        if(!$LogToConsole){
            Write-Host "Logging auf Console ist deaktiviert." -ForegroundColor DarkYellow
            if($LogToLogFile){
                Write-Host "Logging erfolgt in Logfile. `nLogfile wird am Ende des Scripts geöffnet.`n" -ForegroundColor DarkYellow
            }
            if($LogToULSFile){
                Write-Host "Logging erfolgt in ULSfile. `nULSfile Bitte mit dem ULSViewer prüfen.`n" -ForegroundColor DarkYellow
            }
        }
        #endregion
    #endregion
    #region Prüfe Console auf Ausführung "als Administrator"
    if($global:RunAsAdmin)
    {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.windowsIdentity]::GetCurrent())
        if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
            $argumentList = "$ThisScript -workingDir $StringWorkingDir"
            start-process powershell -ArgumentList $argumentList -Verb RunAs
            Wait-SPELoop -text "Das Script muss mit Administrator-Berechtigungen ausgeführt werden und wurde daher in einem neuen Konsolen-Fenster neu gestartet. Dieses Fenster wird geschlossen." -time 10
            Stop-Process $PID
        }
    }
    #endregion

#endregion
Exit-SPEOnCtrlC
while($true)
{

#region Hauptprogramm !!! Hier kann gearbeitet werden !!!

    #region Load the HTMLAgilityPack.dll
       Add-Type -AssemblyName System.Web
       Add-Type -Path C:\SPE_Scripts\3rdPartyDlls\HtmlAgilityPack\Net40-client\HtmlAgilityPack.dll
       Add-Type -Path C:\SPE_Scripts\Modules\SPE.SharePoint\sharepointdlls\Microsoft.SharePoint.Client.Taxonomy.dll
    #endregion

    #ItemCounter
    $ItemCounter = 0

    #region get the objects
    try
    {
        Write-SPELogMessage -level High -message "Start getting SP-Objects..."
        Write-SPELogMessage -message "Getting Credentials" -level Verbose
        if(!$global:cred){
            $global:cred = Get-SPECredentialsFromCurrentUser
        }
        Write-SPELogMessage -message "Getting web and source list" -level Verbose
        $web = Get-SPECsomWeb -Url $webUrl -Credentials $cred
        $srcList = Get-SPECsomList -Web $web -ListTitle $srcListName
        $ctx = $web.Context
        
        Write-SPELogMessage -message "Getting items from source list" -level Verbose
        $qry = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
        $srcItems = $srcList.GetItems($qry)
        $ctx.Load($srcItems)
        $ctx.ExecuteQuery()

        Write-SPELogMessage -message "Getting fields from source list" -level Verbose
        $srcListFields = $srcList.Fields
        $ctx.Load($srcListFields)
        $ctx.ExecuteQuery()

        Write-SPELogMessage -message "Getting target list" -level Verbose
        $trgList = Get-SPECsomList -Web $web -ListTitle $trgListName
        $trgListId = $trgList.Id.ToString().Replace("{","%7B").Replace("}","%7D").Replace("-","%2D")
        $trgListFields = $trgList.Fields
        $ctx.Load($trgListFields)
        $ctx.ExecuteQuery()
        
        Write-SPELogMessage -message "Getting taxonomy session" -level Verbose
        $srcTaxonomyListField = $($srcListFields | ?{$_.Title -eq "Area"}) -as [Microsoft.SharePoint.Client.Taxonomy.TaxonomyField]
        $srcTaxonomyTermSetId = $srcTaxonomyListField.TermSetId
        $srcTaxonomyTermStoreId = $srcTaxonomyListField.SspId
        $srcTaxonomySession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($ctx)
        $ctx.Load($srcTaxonomySession)
        $ctx.ExecuteQuery()
        if($srcTaxonomySession.ServerObjectIsNull){
            Write-SPELogMessage -message "TaxonomySession kann nicht erfasst werden." -level Critical
            exit
        }
        Write-SPELogMessage -message "Getting taxonomy termstore" -level Verbose
        $srcTaxonomyTermStores = $srcTaxonomySession.TermStores # | ?{$_.Id -eq $trgTaxonomyTermStoreId}
        $ctx.Load($srcTaxonomyTermStores)
        $ctx.ExecuteQuery()
        $srcTaxonomyTermStore = $srcTaxonomySession.TermStores | ?{$_.Id -eq $srcTaxonomyTermStoreId}
        
        Write-SPELogMessage -message "Getting taxonomy termset" -level Verbose
        $srcTaxonomyTermSet = $srcTaxonomyTermStore.GetTermSet($srcTaxonomyTermSetId)
        $ctx.Load($srcTaxonomyTermSet)
        $ctx.ExecuteQuery()
        Write-SPELogMessage -level High -message "...finished getting SP-Objects."
    } 
    catch 
    {
	    $exMessage = $_.Exception.Message
	    $innerException = $_.Exception.InnerException
	    $info = "Fehler bei Erfassen der SP-Objects."
	    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
        $global:foundErrors = $true
        exit
    }
    #endregion
    #region #iterate the source liste and write the data to the target        
    try{
        Write-SPELogMessage -message "Start iterating the source lists items..." -level High
        for($i = 0; $i -le $srcItems.Count; $i++){
            Exit-SPEOnCtrlC
            $curItem = $srcItems[$i]
            if($curItem.Id -ge $latestItemId){ # Item-Id > latestItemId
                $newFields = New-Object System.Collections.ArrayList
                Write-SPELogMessage -message "Start iterating the current items fields..." -level High
                for($f = 0; $f -lt $fields.Count; $f++){
                    $newFieldName = $fields[$f].Second
                    if($($fields[$f].Second) -eq "TeaserText")
                    {
                        $baseStr = $curItem[$($fields[$f].First)]
                        $htmlDoc = New-Object HtmlAgilityPack.HtmlDocument
                        $htmlDoc.LoadHtml($baseStr)
                        $strClear = $htmlDoc.DocumentNode.InnerText
                        # Keep these lines !!! it's a linebreak!!!
                        $strTrimmed = $strClear.TrimStart(" 
")
                        Write-SPELogMessage -message "calculating Length of TeaserText..."
                        $strLength = $strTrimmed.Length
                        Write-SPELogMessage -message "current Length = '$strLength'"
                        if($strTrimmed.Length -gt 500)
                        {
                            $SubStringLength = 499
                            $charTest = ""
                            do{
                                $SubStringLength++
                                if($SubStringLength -gt $strLength)
                                {
                                    $SubStringLength = $strLength
                                    $charTest = " "
                                } 
                                else 
                                {
                                    $charTest = $strTrimmed.Substring($SubStringLength - 1, 1)
                                }
                                Write-SPELogMessage -message "current SubStringLength = $SubStringLength"
                            } until($charTest -eq " ")
                            $strTrimmed = $strTrimmed.Substring(0,$SubStringLength - 1)  
                        } 
                        $newFieldValue = $strTrimmed
                    } 
                    else
                    {
                        $newFieldValue = $curItem[$($fields[$f].First)]
                    }
                    Write-SPELogMessage -message "Adding Field '$newFieldName' with value '$newFieldValue'."
                    $newFieldItem = New-Object System.Web.UI.Pair($newFieldName,$newFieldValue)
                    $newFields.Add($newFieldItem) | Out-Null
                }
                Write-SPELogMessage -message "...finished iterating the current items fields." -level High
                if(!$TestModus){
                    Write-SPELogMessage -message "Adding new item to target list..."
                    $newItem = New-SPECsomListItem -List $trgList -FieldValues $newFields
                    $newItemId = $newItem.Id
                    $ItemCounter++
                    Write-SPELogMessage -message "Adding new item to target list done."
                    
                    #region moving source field 'Area' as Taxonomy Multivalued Field to target field 'Area' as multiple choice
                    try
                    {
                        Write-SPELogMessage -message "Start processing source field 'Area'..." -level High
                        $taxFieldValueCollection = $curItem["Area"] -as [Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection]
                        $fieldValueCount = $taxFieldValueCollection.Length
                        if($fieldValueCount = 1)
                        {
                            $taxFieldValue = $taxFieldValueCollection[0]
                            Write-SPELogMessage -message "Getting current term." -level Verbose
                            $curTerm = $srcTaxonomyTermStore.GetTerm($(New-Object Guid($taxFieldValue.TermGuid)))
                            $ctx.Load($curTerm)
                            $ctx.ExecuteQuery()
                            $curTermTermGuid = $curTerm.Id.ToString()
                            $curTermName = $curTerm.Name
                            if(!$($curTerm.IsRoot))
                            {
                                Write-SPELogMessage -message "Getting parent of current term." -level Verbose
                                $curTermParent = $curTerm.Parent
                                $ctx.Load($curTermParent)
                                $ctx.ExecuteQuery()
                                $curTermParentName = $curTermParent.Name
                                if($curTermParentName -ne "Basic Services"){
                                    $curTermName = $curTermParentName + "_" + $curTermName
                                }
                            }
                            Write-SPELogMessage -message "Getting choices from target field 'Area'..."
                            $trgChoiceField = $trgListFields | ?{$_.Title -eq "Area"}
                            $trgChoices = $trgChoiceField.Choices -as [System.Collections.ArrayList]
                            if(!$($trgChoices.Contains($curTermName)))
                            {
                                Write-SPELogMessage -message "Start updating choices with choice '$curTermName'..."
                                $trgChoices.Add($curTermName) | Out-Null
                                $trgChoices = $trgChoices | sort
                                $trgChoiceField.Choices = $trgChoices
                                $trgChoiceField.Update()
                                $ctx.Load($trgChoiceField)
                                $ctx.ExecuteQuery()
                                Write-SPELogMessage -message "...finished updating choices with choice '$curTermName'."
                            }
                            Write-SPELogMessage -message "setting choice related to term"
                            $newItem["Area"] = $curTermName
                            $newItem.Update()
                            $ctx.Load($newItem)
                            $ctx.ExecuteQuery()
                            Write-SPELogMessage -message "Term '$curTermName' was added to ." -level Verbose
                        } else {
                            Write-SPELogMessage -message "source field 'Area' has mutliple values set. please check and transfer manually." -level Unexpected
                        }
                        Write-SPELogMessage -message "...finished processing source field 'Area'." -level High
                    } 
                    catch 
                    {
	                    $exMessage = $_.Exception.Message
	                    $innerException = $_.Exception.InnerException
	                    $info = "Fehler bei Erfassen der Taxonomy zu  Item mit Id '$newItemId'."
	                    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                        $global:foundErrors = $true
                        
                    }
                    #endregion
                    #region Add <More>-Link to TeaserText
                    Write-SPELogMessage -message "Adding <more>-Link to Teaser..."
                    # this is not working inside a CQWP for the tags will not be rendered there!
                    #$moreLinkStr = "<a class='ms-listlink ms-draggable' onclick='EditLink2(this,1056);return false;' onfocus='OnLink(this)' href='/sites/030423/ITSpecialist/_layouts/15/listform.aspx?PageType=4&amp;ListId=%7B$trgListId%7D&amp;ID=$newItemId&amp;ContentTypeID=0x0104006EA83B342B748B4B8B36097AF052F572' target='_self' DragId='0'>&lt;more&gt;</a>"
                    # so, this is an alternative:
                    $moreLinkStr = " <click on the title to read more>"
                    $updateItem = $trgList.GetItemById($newItemId)
                    $ctx.Load($updateItem)
                    $ctx.executeQuery()
                    $updateItem["TeaserText"] = $updateItem["TeaserText"].Replace("<more>","") + $moreLinkStr
                    #endregion
                    #region re-writing fields 'Modified' & 'Editor'
                    $updateItem["Modified"] = $curItem["Modified"]
                    $updateItem["Editor"] = $curItem["Editor"]
                    $updateItem.Update()
                    $ctx.Load($updateItem)
                    $ctx.executeQuery()
                    Write-SPELogMessage -message "... adding <more>-Link to Teaser done."
                    #endregion

                    Write-SPELogMessage -message "...Item No.'$ItemCounter' with ID '$newItemId' was written."
                }
            }
        }
        Write-SPELogMessage -message "...finished iterating the source lists items." -level High
    } catch {
	    $exMessage = $_.Exception.Message
	    $innerException = $_.Exception.InnerException
	    $info = "Fehler bei Iteration der Ziel-Liste '$trgListName'."
	    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
        $global:foundErrors = $true
    }
    #endregion

#endregion
break
}
Trap [ExecutionEngineException]{
    Write-SPELogMessage -level High -CorrelationId $scriptCorrId -message "Script terminated by Ctrl-C."
    $global:scriptaborted = $true
    #region Auszuführender Code nach manuellem Abbruch durch Ctrl-C
    if(!$DoNotDisplayConsole){
        Show-SPETextLine -text "Script wurde durch Ctrl-C abgebrochen!" -fgColor Red -bgColor White
        $resetConsoleTitle = Set-SPEConsoleTitle -newTitle $oldConsoleTitle
        Wait-SPEForKey
    }
    continue
    #endregion
}

#region End of Script and opening of the script's logfile
	
	if($global:scriptaborted) {
		Write-SPEReportMessage -level "Critical" -area "Script" -category "Aborted" -message "Script has been aborted. Check Log(s)" -CorrelationId $scriptCorrId
		Write-SPELogMessage -level "Critical" -area "Script" -category "Aborted" -message "Script has been aborted. Check Log(s)" -CorrelationId $scriptCorrId
    } elseif($global:foundErrors){
		Write-SPEReportMessage -level "High" -area "Script" -category "Stopped" -message "Script has finished with errors. Check Log(s)" -CorrelationId $scriptCorrId
		Write-SPELogMessage -level "High" -area "Script" -category "Stopped" -message "Script has finished with errors. Check Log(s)" -CorrelationId $scriptCorrId
	} else {
		Write-SPEReportMessage -message "Script has successfully finished without any error." -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
		Write-SPELogMessage -message "Script has successfully finished without any error." -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
	}

	if($TestMode){
        Wait-SPEForKey
    }
    if($LogToSPList){
        if($Global:logWeb){
            $Global:logWeb = $null
        }
        if($Global:logList){
            $Global:logList = $null
        }
    }
    if($LogToLogFile){
        notepad.exe $PathToLogfile
    }
#endregion
#EndOfFile
