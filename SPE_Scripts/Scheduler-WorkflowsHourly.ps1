param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# Alegri International Service GmbH - D-50668 Köln                    #
# Kunde   :                                                           #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Scheduler-WorkflowsHourly.ps1                             #
# Funktion: In diesem Script werden Functions für die                 #
# Scheduler-Workflows bereitgestellt, die stündlich ausgeführt        #
# werden sollen.                                                      #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Krieger  | Erst-Erstellung                    | 08.02.2017 #
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
            $global:dirCsv = $StringWorkingDir + "Csv\"
            $global:dirXml = $StringWorkingDir + "Xml\"
        #endregion
    #endregion
    #region Laden der SPEModule
    Remove-Module SPE.*, Scheduler.Common
        Import-Module -Name ".\Modules\SPE.Common\SPE.Common.psd1"
        Import-Module -Name ".\Modules\SPE.SharePoint\SPE.SharePoint.psd1"
        Import-Module -Name ".\Modules\Scheduler.Common\Scheduler.Common.psd1"
    #endregion
    #region Laden der Config
        Get-SPEConfig -ScriptName $ScriptName
    #endregion
    #region Laden der Resources
        Get-SPEResource
    #endregion
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
    #region ConsoleTitle mit Scriptnamen versehen
    $oldConsoleTitle = Set-SPEConsoleTitle -newTitle $($SPEResources.("StandardScriptConsoleTitle") + $ScriptName)
    #endregion
    #region Reset der Loglist
        $Global:logList = $null
    #endregion
	#region ScriptStatus
	$scriptCorrId = $global:DefaultCorrID
	$global:CorrelationId = $scriptCorrId
	Write-SPELogMessage -category $($MyInvocation.MyCommand.Name)  -message $($SPEResources.("StandardScriptHasStarted")) -level "High"
	Write-SPEReportMessage -level "High" -area "Script" -category "Started" -message $($SPEResources.("StandardScriptHasStarted")) -CorrelationId $scriptCorrId
	$global:scriptaborted = $false
	$global:foundErrors = $false
	#endregion

    #region Warnmeldungen

        #region Warnung, falls TestModus aktiviert ist
        if($TestModus -eq $true){
            Write-SPELogMessage -category $($MyInvocation.MyCommand.Name)  -message $($SPEResources.("StandardScriptTestModeActive1"))
            Write-SPELogMessage -category $($MyInvocation.MyCommand.Name)  -message $($SPEResources.("StandardScriptTestModeActive2"))
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

    #Load the XML-SetupData and set it global
    $global:xmlSetupData = Test-SPEAndSetXMLFile -FilePath $PathXmlSetupData
    #get the rootweb
    $RootWeb = Get-SPECsomWeb -Url $urlRootWeb -Credentials $cred
    #region Beispiel für TRY-CATCH-Block mit Logmeldung
    try{
        #region Code
        lm -category "$ScriptName_$($MyInvocation.MyCommand.Name)" -message "Start publishing Scheduler objects (Stages, Modules, Trainings and Dates)"
        Publish-SchedulerObjects -SetupData $global:xmlSetupData -RootWeb $RootWeb
        lm -category "$ScriptName_$($MyInvocation.MyCommand.Name)" -message "Finished publishing Scheduler objects"
        #endregion
    } catch {
	    $exMessage = $_.Exception.Message
	    $innerException = $_.Exception.InnerException
	    $info = "Function: $($MyInvocation.MyCommand) - " + $($SPEResources.("StandardScriptGeneralErrorInScript")) + $ScriptName
	    Push-SPEException -Category "$ScriptName_$($MyInvocation.MyCommand.Name)" -exMessage $exMessage -innerException $innerException -info $info 
        $global:foundErrors = $true
    }
    #endregion

#endregion
break
}
Trap [ExecutionEngineException]{
    Write-SPELogMessage -category $($MyInvocation.MyCommand.Name) -level High -CorrelationId $scriptCorrId -message $($SPEResources.("StandardScriptTerminatedByCtrlC"))
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
		Write-SPEReportMessage -level "Critical" -area "Script" -category "Aborted" -message $($SPEResources.("StandardScriptAborted")) -CorrelationId $scriptCorrId
		Write-SPELogMessage -category $($MyInvocation.MyCommand.Name) -level "Critical" -area "Script" -message $($SPEResources.("StandardScriptAborted")) -CorrelationId $scriptCorrId
    } elseif($global:foundErrors){
		Write-SPEReportMessage -level "High" -area "Script" -category "Stopped" -message $($SPEResources.("StandardScriptFinishedWithErrors")) -CorrelationId $scriptCorrId
		Write-SPELogMessage -category $($MyInvocation.MyCommand.Name) -level "High" -area "Script" -message $($SPEResources.("StandardScriptFinishedWithErrors")) -CorrelationId $scriptCorrId
	} else {
		Write-SPEReportMessage -message $($SPEResources.("StandardScriptFinishedWithoutErrors")) -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
		Write-SPELogMessage -category $($MyInvocation.MyCommand.Name)  -message $($SPEResources.("StandardScriptFinishedWithoutErrors")) -level "High" -area "Script" -CorrelationId $scriptCorrId
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
