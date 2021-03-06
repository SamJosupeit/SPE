param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - D-40882 Ratingen                                            #
# Kunde   :                                                           #
# Powershell-Script                                                   #
# #####################################################################
# Name    : New-ITOnlineDocumentFolder.ps1                            #
# Funktion: Dieses Script erstellt einen neuen Ordner für ein         #
# ITOnline Dokument(Manual oder How-To) mit allen Image-Foldern und   #
# Dokumenten-Vorlagen                                                 #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | .          | Erst-Erstellung                    | 10.10.2016 #
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
            $ModuleToLoad = "spe.common"
            $dirModule = $StringWorkingDir + $ModuleToLoad + ".psd1"
        #endregion
    #endregion
    #region Laden des SPEModule
        Import-Module -Name $ModuleToLoad
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

#region Welcome Text
$welcomeText = new-object System.Collections.ArrayList
$welcomeText.Add("Willkommen zum Script " + $ScriptName)
$welcomeText.Add("Dieses Script erstellt einen neuen Dokumenten-Ordner für neue ITOnline-Dokumente.")
$welcomeText.Add("Dazu werden ein paar Variablen abgefragt.")
Show-SPETextArray -textArray $welcomeText
Wait-SPEForKey
#endregion

#region Document Number
Show-SPETextLine -text "Soll automatisch die nächste freie Nummer aus den 'Working Documents' erfasst und für das neue Dokument verwendet werden?"
$choiceAutoGetdocumentNumber = $false #Select-SPEJN
if(!$choiceAutoGetdocumentNumber){
    $docNumber = Show-SPEQuestion -text "Bitte die Nummer für das neue Dokument eingeben"
} else {
    # get number from working documents list
}
#endregion

#region document format
$textDocumentFormats = New-Object System.Collections.ArrayList
$textDocumentFormats.Add("Folgende Dokument-Formate stehen zur Auswahl:")
$textDocumentFormats.Add("---------------------------------------------")
$choicesDocFormat = New-Object System.Collections.Hashtable
$choicesNumbers = 0;
foreach($key in ($documentFormats.Keys)){
    $choicesNumbers++;
    $stringToAdd = "(" + $choicesNumbers.ToString() + ") " + $key
    $textDocumentFormats.Add($stringToAdd)
    $choicesDocFormat.($choicesNumbers) = $key
}
$textDocumentFormats.Add("---------------------------------------------")
$textDocumentFormats.Add("Bitte eine Auswahl treffen:")
$textDocumentFormats.Add("---------------------------------------------")
Show-SPETextArray -textArray $textDocumentFormats
$choices = "";
for($i = 1; $i -le $choicesDocFormat.Keys.Count; $i++){
    if($i -eq 1){
        $choices += $i
    } else {
        $choices += "," + $i
    }
}
$selectedDocumentFormat = $choicesDocFormat.(Use-SPEChoice -Choices $choices)
#endregion

#region base language template
$textTemplateLanguage = New-Object System.Collections.ArrayList
$textTemplateLanguage.Add("Ausgewähltes Format: " + $selectedDocumentFormat)
$textTemplateLanguage.Add("----------------------------------------------")
$textTemplateLanguage.Add("Folgende Template-Sprachen stehen zur Auswahl:")
$textTemplateLanguage.Add("----------------------------------------------")
$choicesTemplateLanguage =  New-Object System.Collections.Hashtable
$choicesNumbers = 0;
foreach($key in ($documentFormats.($selectedDocumentFormat).Keys)){
    $choicesNumbers++;
    $stringToAdd = "(" + $choicesNumbers.ToString() + ") " + $key
    $textTemplateLanguage.Add($stringToAdd)
    $choicesTemplateLanguage.($choicesNumbers) = $key
}
$textTemplateLanguage.Add("---------------------------------------------")
$textTemplateLanguage.Add("Bitte eine Auswahl treffen:")
$textTemplateLanguage.Add("---------------------------------------------")
Show-SPETextArray -textArray $textTemplateLanguage
$choices = "";
for($i = 1; $i -le $choicesTemplateLanguage.Keys.Count; $i++){
    if($i -eq 1){
        $choices += $i
    } else {
        $choices += "," + $i
    }
}
$selectedTemplateLanguage = $choicesTemplateLanguage.(Use-SPEChoice -Choices $choices)
$pathSelectedTemplate = $documentFormats.($selectedDocumentFormat).($selectedTemplateLanguage)
#endregion

#region document title
$docTitle = Show-SPEQuestion -text "Bitte den Namen für das neuen Dokument eingeben (ohne Sprachen-Kürzel und ohne Unterstriche!)"
$docNames = New-Object System.Collections.Hashtable
$fileNameRoot = $docNumber + "_" + $docTitle.toLower().replace(" ","_")
New-Item -Path $folderRoot -Name $fileNameRoot -ItemType Directory
foreach($key in $PwpLanguages){
    $fileName = $fileNameRoot + "_" + $key
    $docNames.Add($key,$fileName)
}
#endregion

#region open application
$applicationExtensionSelectedTemplate = $pathSelectedTemplate.split(".")[-1]
$commandString = "new-object -comobject " + $ExtensionsToApplications.($applicationExtensionSelectedTemplate) + ".Application"
Set-SPEVariable -VariableName "Application" -CommandString $commandString
$document = $Application.documents.open($pathSelectedTemplate)
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
    if($LogToLogFile){
        notepad.exe $PathToLogfile
    }
#endregion
#EndOfFile
