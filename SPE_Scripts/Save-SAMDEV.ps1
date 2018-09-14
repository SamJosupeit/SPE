param(
    [String]$WorkingDir
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# Firma   : Sam                                                       #
# Kunde   :                                                           #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Save-SAMDEV.ps1.ps1                                       #
# Funktion: Dieses Script speichert die Virtuellen Maschinen für den  #
# lokalen Hyper-V Host.                                               #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | S.Krieger  | Erst-Erstellung                    | 14.04.2016 #
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
        Import-Module -Name "SPE.Common"
        #nur entkommentieren, wenn SPE.SharePoint installiert ist und mitgeladen werden soll.
        #Import-Module -Name "SPE.SharePoint" 
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
            if($Install){ $argumentList += " -Install" }
            if(![String]::IsNullOrEmpty($PreselectedSystem)){ $argumentList += " -PreselectedSystem $PreselectedSystem" }
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

    #region Variables
    $MachineNames = @(
        "SAMDEV-SP2016",
        "SAMDEV-SP2013",
        "SAMDEV-SP2010",
        "SAMDEV-SQL2012",
        "SAMDEV-SQL2014",
        "SAMDEV-DC"
    )
    #endregion
    #region Welcome-Screen
    Wait-SPELoop -text "Willkommen zum Save Script für die lokalen Hyper-V-Maschinen." -time 3
    #endregion
    #region Ask for save of VM's
    Show-SPETextArray -textArray @(
        "Dieses Script speichert automatisch alle virtuellen Maschinen angefangen bei den SharePoint-Servern über den SQL-Server bis zum DomainController.",
        "Soll es ausgeführt werden?"
    )
    $start = Select-SPEJN
    #endregion
    if($start){
        #region Get Running VMs
        $MachinesToSave = New-Object System.Collections.ArrayList
        $MessageMachinesToSave = New-Object System.Collections.ArrayList
        $MessageMachinesToSave.Add("Folgende VMs werden in der angegebene Reihenfolge gespeichert:") | Out-Null
        $MessageMachinesToSave.Add("") | Out-Null
        $runningVMs = Get-VM | ?{$_.State -eq "Running"}
        foreach($MachineName in $MachineNames)
        {
            foreach($runningVM in $runningVMs)
            {
                if($MachineName -eq $runningVm.Name)
                {
                    $MachinesToSave.Add($MachineName) | Out-Null
                    $MessageMachinesToSave.Add($MachineName) | Out-Null
                }
            }
        }
        Show-SPETextArray -textArray $MessageMachinesToSave
        Wait-SPEForKey
        #endregion
        #region Run Tasks
        foreach($MachineToSave in $MachinesToSave)
        {
            Write-SPELogAndTextMessage -message "Speichere virtuelle Maschine '$MachineToSave'..."
            Save-VM -Name $MachineToSave
            sleep 3
            do{
                $vm = Get-VM -Name $MachineToSave #English: Heartbeat
                Show-SPETextLine -text "...virtuelle Maschine '$MachineToSave' ist noch nicht abschliessend gespeichert..."
                sleep 1
            }until($vm.State -eq "Saved")
            Write-SPELogAndTextMessage -message "...virtuelle Maschine '$MachineToSave' wurde erfolgreich gespeichert."
            Wait-SPELoop -time 5 -text "...virtuelle Maschine '$MachineToSave' wurde erfolgreich gespeichert."
        }
        #endregion
        #region Finish
        Show-SPETextArray -textArray @(
            "Alle virtuellen Maschinen wurden erfolgreich gespeichert.",
            "Noch einen schönen Feierabend ;-)"
        )
        #endregion
    } else {
        Write-SPELogAndTextMessage -message "Script wird nicht ausgeführt."
    }
    
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
