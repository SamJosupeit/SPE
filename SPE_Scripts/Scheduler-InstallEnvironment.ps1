[CmdletBinding(DefaultParametersetName="Install")]
param(
    [Parameter(Position=3)][String]$WorkingDir,
    [Parameter(Position=2)][Switch]$DoNotDisplayConsole,
    [Parameter(Position=1)][Switch]$SPO,
    [Parameter(ParameterSetName="Reinstall",Position=0)][Switch]$Reinstall,
    [Parameter(ParameterSetName="Uninstall",Position=0)][Switch]$Uninstall,
    [Parameter(ParameterSetName="Install",Position=0)][Switch]$Install,
    [Parameter(ParameterSetName="Update",Position=0)][Switch]$Update,
    [Parameter(Position=4)][Switch]$IncludeTestDataImport,
    [Parameter(Position=5)][Switch]$IncludeTestDataPublish
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# Alegri International Service GmbH - D-50668 Köln                    #
# Kunde   : Bayer Leverkusen                                          #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Install-SchedulerEnvironment.ps1                          #
# Funktion: Dieses Script installiert Websites, Listen, Scripts und   #
# andere Artefakte für den Trainings-Scheduler                        #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Krieger  | Erst-Erstellung                    | 16.12.2016 #
######################################################################>
#endregion

#region Selbstverwaltung - Status
<#
Stand 19.12.2016:
- Installation Listen in RootWeb funktioniert, muss aber noch relativiert werden
- Löschen von Listen läuft durch, wenn Verbindung denn mal aufgebaut wird
  Allerdings schönt das Löschen nicht an den Listen anzukommen.

Stand 22.12.2016
- Installation und Löschen von per CSV definierten Listen im Rootweb funktioniert jetzt
- Script kann nicht zweimal mit dem gespeicherten CRED-Object ausgeführt werden. 
  $global:cred muss zwingend auf $null gesetzt werden, bevor das Script neu gestartet wird.

Stand 24.01.2017
- Änderung der Setupdaten von CSV nach XML mit entsprechender Verarbeitung gestartet

Stand 25.01.2017
- Versionierung SetupData eingebunden
- SetupData um Liste "Scheduler_WorkflowStates" erweitert

Stand 02.02.2017
- Listen werden nun richtig aus XML erstellt
- Views werden anscheinend erstellt, erzeugen aber bisher ungeklärte Fehler.
#>
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
            $global:dirCsv = $StringWorkingDir + "Csv\"
            $global:dirXml = $StringWorkingDir + "Xml\"
        #endregion
    #endregion
    #region Laden der SPEModule
        Import-Module -Name ".\Modules\SPE.Common\SPE.Common.psd1";
        Import-Module -Name ".\Modules\SPE.SharePoint\SPE.SharePoint.psd1";
        Import-Module -Name ".\Modules\Scheduler.Common\Scheduler.Common.psd1";
    #endregion
    #region Laden der Config
        Get-SPEConfig -ScriptName $ScriptName
    #endregion
    #region Laden der Resources
        Get-SPEResource
    #endregion
    #region ConsoleTitle mit Scriptnamen versehen
    $oldConsoleTitle = Set-SPEConsoleTitle -newTitle $($SPEResources.("StandardScriptConsoleTitle") + $ScriptName)
    #endregion
	#region ScriptStatus
	$scriptCorrId = $global:DefaultCorrID
	$global:CorrelationId = $scriptCorrId
	lm  -Category $ScriptName  -message $($SPEResources.("StandardScriptHasStarted")) -level "High"
	Write-SPEReportMessage -level "High" -area "Script" -category "Started" -message $($SPEResources.("StandardScriptHasStarted")) -CorrelationId $scriptCorrId
	$global:scriptaborted = $false
	$global:foundErrors = $false
	#endregion

    #region Warnmeldungen

        #region Warnung, falls TestModus aktiviert ist
        if($TestModus -eq $true){
            lm -Category $ScriptName -message $($SPEResources.("StandardScriptTestModeActive1"))
            lm -Category $ScriptName -message $($SPEResources.("StandardScriptTestModeActive2"))
        }
        #endregion
        #region Warnung, falls Logging auf Console deaktiviert ist
        if(!$LogToConsole){
            Write-Host $($SPEResources.("StandardScriptLogToConsoleDeactivated")) -ForegroundColor DarkYellow
            if($LogToLogFile){
                Write-Host $($SPEResources.("StandardScriptLogToLogFileActivated")) -ForegroundColor DarkYellow
            }
            if($LogToULSFile){
                Write-Host $($SPEResources.("StandardScriptLogToULSFileActivated")) -ForegroundColor DarkYellow
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
            Wait-SPELoop -text $($SPEResources.("StandardScriptNeedToRunAsAdmin")) -time 10
            Stop-Process $PID
        }
    }
    #endregion

#endregion
Exit-SPEOnCtrlC
while($true)
{

#region Hauptprogramm !!! Hier kann gearbeitet werden !!!
    try{
        #region Check Credentials
        if(!$global:cred){
            Show-SPETextLine -text "Anmeldedaten werden geprüft..."       
            if($SPO){
                Approve-SPECredentialsInConfig -SPO
            } else {
                Approve-SPECredentialsInConfig
            }
        }           
        #endregion

        #region Initiate Connection to RootWeb
        $global:CorrelationId = Set-SPEGuidIncrement -guid $global:CorrelationId
        lm -category $($MyInvocation.MyCommand.Name) -level High -message "Start initiation of connection to SharePoint site '$UrlRootWeb'..."
        $foundWeb = $false
        #endregion
        $rootweb = Get-SchedulerWebsite -Url $UrlRootWeb
        if($rootweb -ne $null){
            #region Reading SetupData from XML
            Show-SPETextLine -text "Erfasse Setup-Daten..."
            $Global:xmlSetupData = Test-SPEAndSetXMLFile -FilePath $PathXmlSetupData
            #endregion
            Show-SPETextLine -text "Starte Prozess..."
            switch($PSCmdlet.ParameterSetName){
                "Uninstall"{
                    Show-SPETextLine -text "'Uninstall'-Prozess wird gestartet."
                    #region delete lists
                    Exit-SPEOnCtrlC
                    Remove-SchedulerLists -SetupData $xmlSetupData -Web $rootweb
                    Exit-SPEOnCtrlC
                    #endregion
                    Show-SPETextLine -text "'Uninstall'-Prozess wurde beendet."
                    break;
                }
                "Reinstall"{
                    Show-SPETextLine -text "'Reinstall'-Prozess wird gestartet."
                    #region delete lists
                    Exit-SPEOnCtrlC
                    Remove-SchedulerLists -SetupData $xmlSetupData -Web $rootweb
                    Exit-SPEOnCtrlC
                    #endregion

                    #region create lists
                    Exit-SPEOnCtrlC
                    New-SchedulerLists -SetupData $xmlSetupData 
                    Exit-SPEOnCtrlC
                    #endregion

                    #region import test data
                    if($IncludeTestDataImport){
                        lm -category $ScriptName -message "Start importing Scheduler testdata from XML-File '$PathXmlTestData'"
                        Show-SPETextLine -text "Start importing Scheduler testdata from XML-File '$PathXmlTestData'"
                        Import-SchedulerTestData 
                        lm -category $ScriptName -message "Finished importing Scheduler testdata"
                        Show-SPETextLine -text "Finished importing Scheduler testdata"
                    }
                    #endregion

                    #region publish test data
                    if($IncludeTestDataPublish){
                        lm -category $ScriptName -message "Start publishing Scheduler objects"
                        $message = "Veröffentliche Objekte."
                        Show-SPETextLine -text $message
                        Publish-SchedulerObjects -SetupData $global:xmlSetupData -RootWeb $rootweb -message $message
                        lm -category $ScriptName -message "Finished publishing Scheduler objects."
                        Show-SPETextLine -text "Veröffentlichung der Objekte abgeschlossen."
                    }
                    #endregion

                    Show-SPETextLine -text "'Reinstall'-Prozess wurde beendet."


                    break;
                }
                "Install"{
                    Show-SPETextLine -text "'Install'-Prozess wird gestartet."
                    #region create websites
                    #endregion
        
                    #region create lists
                    Exit-SPEOnCtrlC
                    New-SchedulerLists -SetupData $xmlSetupData 
                    Exit-SPEOnCtrlC
                    #endregion

                    #region import test data
                    if($IncludeTestDataImport){
                        lm -category $ScriptName -message "Start importing Scheduler testdata from XML-File '$PathXmlTestData'"
                        Show-SPETextLine -text "Start importing Scheduler testdata from XML-File '$PathXmlTestData'"
                        Import-SchedulerTestData 
                        lm -category $ScriptName -message "Finished importing Scheduler testdata"
                        Show-SPETextLine -text "Finished importing Scheduler testdata"
                    }
                    #endregion

                    #region publish test data
                    if($IncludeTestDataPublish){
                        lm -category $ScriptName -message "Start publishing Scheduler objects"
                        $message = "Veröffentliche Objekte."
                        Show-SPETextLine -text $message
                        Publish-SchedulerObjects -SetupData $global:xmlSetupData -RootWeb $rootweb -message $message
                        lm -category $ScriptName -message "Finished publishing Scheduler objects."
                        Show-SPETextLine -text "Veröffentlichung der Objekte abgeschlossen."
                    }
                    #endregion

                    Show-SPETextLine -text "'Install'-Prozess wurde beendet."
                    break;
                }
                "Update"{
                    Show-SPETextLine -text "'Update'-Prozess wird gestartet."

                    Update-SchedulerLists -SetupData $xmlSetupData -Web $rootweb

                    #region import test data
                    if($IncludeTestDataImport){
                        lm -category $ScriptName -message "Start importing Scheduler testdata from XML-File '$PathXmlTestData'"
                        Show-SPETextLine -text "Start importing Scheduler testdata from XML-File '$PathXmlTestData'"
                        Import-SchedulerTestData 
                        lm -category $ScriptName -message "Finished importing Scheduler testdata"
                        Show-SPETextLine -text "Finished importing Scheduler testdata"
                    }
                    #endregion

                    #region publish test data
                    if($IncludeTestDataPublish){
                        lm -category $ScriptName -message "Start publishing Scheduler objects"
                        $message = "Veröffentliche Objekte."
                        Show-SPETextLine -text $message
                        Publish-SchedulerObjects -SetupData $global:xmlSetupData -RootWeb $rootweb -message $message
                        lm -category $ScriptName -message "Finished publishing Scheduler objects."
                        Show-SPETextLine -text "Veröffentlichung der Objekte abgeschlossen."
                    }
                    #endregion

                    Show-SPETextLine -text "'Update'-Prozess wurde beendet."
                    break;
                }
                Default{
                    Write-SPELogAndTextMessage -message "Please choose on of the parameters [Install, Reinstall, Uninstall]."
                }
            }
        }
    } 
    catch {
	    $info = $($SPEResources.("StandardScriptGeneralErrorInScript")) + $ScriptName
        lx -Stack $_ -Category $ScriptName -info $info
        $global:foundErrors = $true
    } 
    finally{
        #region Objects clean up
        lm -category $($MyInvocation.MyCommand.Name)  -message "Clean-Up of SPObjects variables"
        $rootweb = $null
        $ctx = $null
        #endregion
    }

#endregion
break
}
Trap [ExecutionEngineException]{
    lm -Category $ScriptName -level High -CorrelationId $scriptCorrId -message $($SPEResources.("StandardScriptTerminatedByCtrlC"))
    $global:scriptaborted = $true
    #region Auszuführender Code nach manuellem Abbruch durch Ctrl-C
    if(!$DoNotDisplayConsole){
        Show-SPETextLine -text $($SPEResources.("StandardScriptTerminatedByCtrlC")) -fgColor Red -bgColor White
        $resetConsoleTitle = Set-SPEConsoleTitle -newTitle $oldConsoleTitle
        Wait-SPEForKey
    }
    continue
    #endregion
}

#region End of Script and opening of the script's logfile
	
	if($global:scriptaborted) {
        Out-SPESpeakText -text "Script aborted by control, c"
		Write-SPEReportMessage -level "Critical" -area "Script" -category "Aborted" -message $($SPEResources.("StandardScriptAborted")) -CorrelationId $scriptCorrId
		lm -level "Critical" -area "Script" -category "Aborted" -message $($SPEResources.("StandardScriptAborted")) -CorrelationId $scriptCorrId
        Show-SPETextLine -text $($SPEResources.("StandardScriptAborted"))
    } elseif($global:foundErrors){
        Out-SPESpeakText -text "Script finished with errors. Check logfiles, please."
		Write-SPEReportMessage -level "High" -area "Script" -category "Stopped" -message $($SPEResources.("StandardScriptFinishedWithErrors")) -CorrelationId $scriptCorrId
		lm -level "High" -area "Script" -category "Stopped" -message $($SPEResources.("StandardScriptFinishedWithErrors")) -CorrelationId $scriptCorrId
        Show-SPETextLine -text $($SPEResources.("StandardScriptFinishedWithErrors"))
	} else {
        Out-SPESpeakText -text "Script successfully finished"
		Write-SPEReportMessage -message $($SPEResources.("StandardScriptFinishedWithoutErrors")) -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
		lm -message $($SPEResources.("StandardScriptFinishedWithoutErrors")) -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
        Show-SPETextLine -text $($SPEResources.("StandardScriptFinishedWithoutErrors"))
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
