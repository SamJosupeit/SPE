param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# Alegri International Service GmbH                                   #
# Kunde   : Bayer                                                     #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Open-SPFolderInWindowsExplorer.ps1                        #
# Funktion: Dieses Script erfragt eine SharePoint-URL und öffnet      #
# den dazugehörigen Ordner im Windows Explorer                        #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Krieger  | Erst-Erstellung                    | 19.10.2016 #
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
            $ModuleToLoad = "SamsPowerShellEnhancements"
            $dirModule = $StringWorkingDir + $ModuleToLoad + ".psd1"
        #endregion
    #endregion
    #region Laden des SPEModule
#        Import-Module -Name $ModuleToLoad
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

    #Welcome-Screen
    Show-SPETextLine -text ("Willkommen zum Script '" + $global:ScriptName + "'.")
    Wait-SPEForKey
    $openNewFolder = $true
    do{
        $outputText = New-Object System.Collections.ArrayList
        $outputText.Add("folgende Ordner sind in 'SPEConfig.xml' vordefiniert:") | out-null
        $choices = ""
        #get the hashtable
        $arrKeys = $PredefinedFolderURLs.Keys | % ToString
        for($i = 0; $i -lt $arrKeys.count; $i++){
            $curKey = $arrKeys[$i]
            $curValue = $PredefinedFolderURLs.$curKey
            $outputText.Add("($($SPE_ChoiceChars[$i])) - $curKey") | out-null
            $outputText.Add("$curValue") | out-null
            $outputText.Add("") | out-null
            if($i -eq 0){
                $choices += "$($SPE_ChoiceChars[$i])"
            } else {
                $choices += ",$($SPE_ChoiceChars[$i])"
            }
        }
        $choiceOwn = $arrKeys.count
        $outputText.Add("(" + $($SPE_ChoiceChars[-2]) + ") - Ich möchte eine neue Url eingeben.") | out-null
        $choices += ",$($SPE_ChoiceChars[-2])"
        $outputText.Add("") | out-null
        $outputText.Add("Ende")
        $choices += ",$($SPE_ChoiceChars[-1])"
        $outputText.Add("Bitte eine Auswahl vornehmen:")
        Show-SPETextArray -textArray $outputText
        $currentChoice = Use-SPEChoice $choices
        $chosenUrl = ""
        if($currentChoice -ne $SPE_ChoiceChars[-1]){
            if($currentChoice -eq $SPE_ChoiceChars[-2]){
                $url = Show-SPEQuestion -text "Bitte geben Sie die URL zur SharePoint-Site, bzw. zum SharePoint-Ordner an, die geöffnet werden soll:"
                $urlProtocol = $url.split("://")[0]
                $urlRoot = $url.split("://")[3]
                $urlPath = ""
                if($url.split("/")[-1].contains(".")){
                    $urlPath = $url.replace($urlRoot,"").replace($urlProtocol,"").replace("://","").replace("/","\").replace(($url.split("/")[-1]),"")
                } else {
                    $urlPath = $url.replace($urlRoot,"").replace($urlProtocol,"").replace("://","").replace("/","\")
                }
                $webDavPath = ""
                switch($urlProtocol){
                    "http"{
                        $webDavPath = "\DavWWWRoot"
                    }
                    "https"{
                        $webDavPath = "@SSL\DavWWWRoot"
                    }
                    default{
                        $webDavPath = "\DavWWWRoot"
                    }
                }
                $chosenpath = "\\$urlRoot$webDavPath$urlPath"
                $askForSave = $true
            } 
            else {
                $chosenPath = $PredefinedFolderURLs.($arrKeys[$currentChoice])
            }
            $outputText.Clear()
            $outputText.Add("Ausgewählter Pfad: $chosenPath wird geöffnet") | out-null
            #open fodler in Windows Explorer
            ii $chosenpath

            # save path to SPEConfig
            if($askForSave){
                $outputText.Add("Soll der Pfad gespeichert werden?") | out-null
                Show-SPETextArray -textArray $outputText
                $savePathToConfig = Select-SPEYN
                if($savePathToConfig){
                    $pathToConfig = $SPEVars.ConfigXMLFile;
                    [xml]$config = Get-Content $pathToConfig;
                    $currentVariableValue = $config.SPE_Config.($ScriptName).ScriptVariablen.("PredefinedFolderURLs").Wert;
                    $itemKeyName = Show-SPEQuestion -text "Bitte den Namen zum Pfad eingeben:";
                    $newVariableValue = $currentVariableValue.replace("}","").TrimEnd(" ").TrimEnd("`n") + ";`n";
                    $newVariableValue += '"' + $itemKeyName + '" = "' + $chosenPath + '"';
                    $newVariableValue += "`n";
                    $newVariableValue += "}";
                    $config.SPE_Config.($ScriptName).ScriptVariablen.("PredefinedFolderURLs").Wert = $newVariableValue
                    $config.save($pathToConfig)
                    Get-SPEConfig -ScriptName $ScriptName
                }
            $askForSave = $false
            }
            Show-SPETextLine -text "Sollen weitere Ordner geöffnet werden?"
            $openNewFolder = Select-SPEYN
        } 
        else {
            $openNewFolder = $false
        }
    }until($openNewFolder -eq $false)
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
    if($LogToLogFile){
        notepad.exe $PathToLogfile
    }
#endregion
#EndOfFile
