param(
    [String]$WorkingDir,
    [ValidateSet("SP2010","SP2013","SP2016")][String]$PreselectedSystem,
    [Switch]$Install
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# Firma   : Sam                                                       #
# Kunde   :                                                           #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Start-SAMDEV.ps1.ps1                                      #
# Funktion: Dieses Script startet die Virtuellen Maschinen für den    #
# lokalen Hyper-V Host.                                               #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | S.Krieger  | Erst-Erstellung                    | 14.03.2016 #
# 0.2  | S.Krieger  | Switch für VM-Status eingebunden   | 14.04.2016 #
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
    $MachineNames = @{
        "DC" = @(
            "SAMDEV-DC", #VM-MachineName
            "dc.samdev.local", #ComputerName
            "Administrator" #AdminUsername
            );
        "DC16" = @("SAMDEV-DC16","dc16.samdev.local","Administrator");
        "SQL2012" = @("SAMDEV-SQL2012","sql.samdev.local","SP_Admin");
        "SQL2014" = @("SAMDEV-SQL2014","sql2014.samdev.local","SP_Admin");
        "SP2010" = @("SAMDEV-SP2010","sp2010.samdev.local","SP_Admin");
        "SP2013" = @("SAMDEV-SP2013","sp2013.samdev.local","SP_Admin");
        "SP2016" = @("SAMDEV-SP2016","sp2016.samdev.local","SP_Admin");
    }
    $SystemsToSelect = @(
        "SharePoint 2010",
        "SharePoint 2013",
        "SharePoint 2016"
    )
    #endregion
    #region Welcome-Screen
    Wait-SPELoop -text "Willkommen zum Start Script für die lokalen Hyper-V-Maschinen." -time 3
    #endregion
    #region Install to Registry Auto Run
    if($Install){
        if([String]::IsNullOrEmpty($PreselectedSystem)){
            Write-SPELogAndTextMessage -message "Schreibe allgemeinen Autostart-Eintrag in die Registry..."
            $restartValue = $powershell + ' -ExecutionPolicy ByPass -NoProfile -command "& {cd ' + $StringWorkingDir + ';' + $StringWorkingDir + $MyInvocation.MyCommand.Name + '}"'
        } else {
            Write-SPELogAndTextMessage -message "Schreibe Autostart-Eintrag für $PreselectedSystem in die Registry..."
            $restartValue = $powershell + ' -ExecutionPolicy ByPass -NoProfile -command "& {cd ' + $StringWorkingDir + ';' + $StringWorkingDir + $MyInvocation.MyCommand.Name + ' -PreselectedSystem ' + $PreselectedSystem + '}"'
        }
        #remove RegistryKey and write it newly
        if(Test-SPERegistryKey -path $RegRunKey -key $restartKey)
        {
            Remove-SPERegistryKey -path $RegRunKey -key $restartKey
        }
        Set-SPERegistryKey -path $RegRunKey -key $restartKey -value $restartValue
        #endregion
    } else {
        #region Ask for start of VM's
        if([String]::IsNullOrEmpty($PreselectedSystem))
        {
            Show-SPETextArray -textArray @(
                "Dieses Script startet automatisch virtuelle Maschinen nach Auswahl des entsprechenden Systems.",
                "Soll es ausgeführt werden?"
            )
            $start = Select-SPEJN
        } else {
            $start = $true
        }
        #endregion
        if($start){
            #region Select System
            if([String]::IsNullOrEmpty($PreselectedSystem))
            {
                Show-SPETextArray @(
                    "Folgende Systeme stehen zur Auswahl:",
                    "(a) SharePoint 2010",
                    "(b) SharePoint 2013",
                    "(c) SharePoint 2016",
                    "(jeweils verbunden mit SQL-Server und DC)",
                    "bitte auswählen"
                )
                $choice = Use-SPEChoice -Choices "a,b,c"
            } else {
                switch($PreselectedSystem){
                    "SP2010"{
                        $choice = "a"
                        break
                    }
                    "SP2013"{
                        $choice = "b"
                        break
                    }
                    "SP2016"{
                        $choice = "c"
                        break
                    }
                }
            }
            $selectedSystem = ""
            $MachinesToStart = new-object System.Collections.ArrayList
            switch($choice){
                "a"{
                    $MachinesToStart.Add($MachineNames.DC)
                    $MachinesToStart.Add($MachineNames.SQL2012)
                    $MachinesToStart.Add($MachineNames.SP2010)
                    $selectedSystem = "SharePoint 2010"
                    break;
                }
                "b"{
                    $MachinesToStart.Add($MachineNames.DC16)
                    $MachinesToStart.Add($MachineNames.SQL2014)
                    $MachinesToStart.Add($MachineNames.SP2013)
                    $selectedSystem = "SharePoint 2013"
                    break;
                }
                "c"{
                    $MachinesToStart.Add($MachineNames.DC16)
                    $MachinesToStart.Add($MachineNames.SQL2014)
                    $MachinesToStart.Add($MachineNames.SP2016)
                    $selectedSystem = "SharePoint 2016"
                    break;
                }
            }
            Write-SPELogMessage -message "Ausgewähltes System: $selectedSystem"
            #endregion
            #region Run Tasks
            foreach($Machine in $MachinesToStart)
            {
                $MachineToStart = $Machine[0]
                $ComputerName = $Machine[1]
                Write-SPELogAndTextMessage -message "Starte virtuelle Maschine '$MachineToStart'..."
                #region Prüfung, ob VM eventuell gespeichert ist
                $vm = Get-VM -Name $MachineToStart -ErrorAction SilentlyContinue
                if($vm -ne $null)
                {
                    $vmStatus = $vm.State.ToString()
                    switch($vmStatus){
                        "Off"{
                            Show-SPETextLine -text "...virtuelle Maschine '$MachineToStart' ist ausgeschaltet und wird nun gestartet ..."
                            Start-VM -Name $MachineToStart
                            sleep 3
                            do{
                                ipconfig.exe /flushdns | out-null
                                $vmPingResult = (tnc $ComputerName).PingSucceeded
                                Show-SPETextLine -text "...virtuelle Maschine '$MachineToStart' steht noch nicht bereit..."
                                sleep 1
                            }until($vmPingResult)
                            break
                        }
                        "Running"{
                            Show-SPETextLine -text "...virtuelle Maschine '$MachineToStart' läuft bereits ..."
                            break
                        }
                        "Saved"{
                            Show-SPETextLine -text "...virtuelle Maschine '$MachineToStart' ist gespeichert und wird nun gestartet ..."
                            Start-VM -Name $MachineToStart
                            sleep 3
                            do{
                                ipconfig.exe /flushdns out-null
                                $vmPingResult = (tnc $ComputerName).PingSucceeded
                                Show-SPETextLine -text "...virtuelle Maschine '$MachineToStart' steht noch nicht bereit..."
                                sleep 1
                            }until($vmPingResult)
                            break
                        }
                        Default{
                            break
                        }
                    }
                }
                #endregion
                Write-SPELogAndTextMessage -message "...virtuelle Maschine '$MachineToStart' steht bereit."
                Wait-SPELoop -time 5 -text "...virtuelle Maschine '$MachineToStart' steht bereit."
            }
            #endregion
            #region Reset VLAN Intern
            Write-SPELogAndTextMessage -message "Reset des internen VLAN-Netzwerkadapters wird nun durchgeführt..."
            netsh interface set interface "vEthernet (VLAN Intern)" admin=disable
            netsh interface set interface "vEthernet (VLAN Intern)" admin=enable
            Write-SPELogAndTextMessage -message "Interner VLAN-Netzwerkadapter wurde zurückgesetzt. Starte mRemoteNG."
            #endregion
            #region Finish
            Show-SPETextArray -textArray @(
                "Alle virtuellen Maschinen zum gewünschten System '$selectedSystem' wurden gestartet.",
                "Viel Spaß beim Arbeiten ;-)"
            )
            #endregion
            #region manipulate the confCons.xml of mRemoteNG
            [xml]$XmlDocument = Get-Content -Path $mRemoteNGConfig
            #
            foreach($Machine in $MachinesToStart)
            {
                ((($XmlDocument.Connections.Node | ?{$_.Name -eq "SAMDEV"}).Node | ?{$_.Name -eq $Machine[2]}).Node | ?{$_.Name -eq $Machine[0]}).Connected = "True"
            }
            #save confCons.xml
            $XmlDocument.Save($mRemoteNGConfig)
            #endregion
            #region Open mRemoteNG
            & $mRemoteNG
            #endregion
        } else {
            Write-SPELogAndTextMessage -message "Script wird nicht ausgeführt."
        }
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
