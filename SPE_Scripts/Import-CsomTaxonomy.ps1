param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - D-40882 Ratingen                                            #
# Kunde   : TGE                                                       #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Import-O365Taxonomy.ps1                                   #
# Funktion: Dieses Script importiert die mit dem Script               #
# 'Export-O365Taxonomy.ps1' erzeugte XML-Datei in den                 #
# Taxonomy-Speicher einer SharePoint Online SiteCollection            #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  |            | Erst-Erstellung                    | 07.03.2016 #
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
        #endregion
    #endregion
    #region Laden des SPEModule
        Import-Module -Name "SPE.Common"
        Import-Module -Name "SPE.SharePoint"
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

    #region Welcome-Box
    Show-SPETextArray -textArray @(
        "Willkommen zum Script $ScriptName.",
        "",
        "Mit diesem Script wird der Taxonomy-Speicher einer SharePoint Online SiteCollection mit Daten gefüllt, die zuvor mit dem Script 'Export-O365Taxonomy.ps1' in eine XML-Datei exportiert wurden."
    )
    Wait-SPEForKey
    #endregion
    #region Kontrolle der vordefinierten Variablen
    Do{
        Show-SPETextArray @(
            "folgende Variablen sind in der SPE-Config vordefiniert:"
            ""
            "(1): Url", "'$($Global:Url)'",
            "(2): AdminAccountName", "'$($Global:AdminAccountName)'",
            "(3): ExportFileName", "'$($Global:ImportFileName)'",
            "",
            "Wenn diese Werte geändert werden sollen, bitte die entsprechende Nummer eingeben.",
            "",
            "Wenn alles in Ordnung ist, bitte 'w' für weiter eingeben."
        )
        $Choice = Use-SPEChoice -Choices "1,2,3,w"
        switch($Choice)
        {
            "1"{
                $Global:Url = Show-SPEQuestion -text "Bitte neuen Wert für 'URL' eingeben"
                break
            }
            "2"{
                $Global:AdminAccountName = Show-SPEQuestion -text "Bitte neuen Wert für 'AdminAccountName' eingeben"
                break
            }
            "3"{
                $Global:ImportFileName = Show-SPEQuestion -text "Bitte neuen Wert für 'ImportFileName' eingeben"
                break
            }
            "w"{
                break
            }
            Default{
                Show-SPETextLine -text "Werte werden übernommen."
                Wait-SPEForKey
                break
            }
        }
    }
    While($Choice -ne "w")
    #endregion
    #region Abfrage der Credentials
    if(!$Global:Cred){
        Show-SPETextArray -textArray @(
            "In der aktuellen Konsolensitzung wurde bisher keine Credentials gespeichert.",
            "Bitte Passwort für Admin-Konto eingeben:"
        )
        $Global:Cred = Get-SPECredentialsFromCurrentUser
    } else {
        Show-SPETextLine "Credentials wurden in der aktuellen Konsolensitzung bereits gespeichert."
        Wait-SPEForKey
    }
    #endregion
    #region Abfrage des Context
    Show-SPETextLine -text "Erfasse nun den Context zu SharePoint Online SiteCollection $($Global:Url)..."
    $global:ctx = Get-SPECsomContext -Url $Global:Url -Credentials $Global:Cred
    if($ctx){
        Show-SPETextLine -text "Context konnte erfasst werden. Script wird fortgesetzt."
        Wait-SPEForKey
    } else {
        Show-SPETextLine -text "Context konnte nicht erfasst werden. Bitte URL und Credentials prüfen." -bgColor White -fgColor Red
        break
    }
    #endregion
    #region Daten-Import
    Show-SPETextLine -text "Beginne nun Import der Taxonomy-Daten..."
    Wait-SPEForKey
    Import-SPESPOnlineTaxonomy -Path $StringWorkingDir -FileName $Global:ImportFileName -SPOContext $ctx
    Show-SPETextLine -text "Import abgeschlossen."
    Wait-SPEForKey
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
