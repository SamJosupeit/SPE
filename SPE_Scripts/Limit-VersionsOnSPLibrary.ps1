param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# Alegri International Service GmbH - D-50668 Köln                    #
# Kunde   : Bayer Leverkusen                                          #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Limit-VersionsOnSPLibrary.ps1                             #
# Funktion: Dieses Script setzt das Maximum für Versionen einer       #
# SharePoint-Library und bereinigt danach alle überschüssigen         #
# Versionen                                                           #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Krieger  | Erst-Erstellung                    | 06.03.2017 #
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
            $global:PathWorkingDir = Get-Location;
            $global:StringWorkingDir = $PathWorkingDir.ToString() + "\";
            $global:dirLog = $StringWorkingDir + "Log\";
            $global:dirRep = $StringWorkingDir + "Reports\";
            $global:dirCsv = $StringWorkingDir + "Csv\";
            $global:dirXml = $StringWorkingDir + "Xml\";
        #endregion
    #endregion
    #region Laden des SPEModule
        Import-Module -Name ".\Modules\SPE.Common\SPE.Common.psd1"
        Import-Module -Name ".\Modules\SPE.SharePoint\SPE.SharePoint.psd1"
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
	lm -message $($SPEResources.("StandardScriptHasStarted")) -level "High"
	Write-SPEReportMessage -level "High" -area "Script" -category "Started" -message $($SPEResources.("StandardScriptHasStarted")) -CorrelationId $scriptCorrId
	$global:scriptaborted = $false
	$global:foundErrors = $false
	#endregion


    #region Warnmeldungen

        #region Warnung, falls TestModus aktiviert ist
        if($TestModus -eq $true){
            lm -message $($SPEResources.("StandardScriptTestModeActive1"))
            lm -message $($SPEResources.("StandardScriptTestModeActive2"))
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

    #region Beispiel für TRY-CATCH-Block mit Logmeldung
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


        #region get the objects
        $web = Get-SPECsomWeb -Url $UrlWebSite -Credentials $cred
        $list = Get-SPECsomList -Web $web -ListTitle $ListName
        $ctx = $list.Context
        #endregion
        #region set Versioning Limit
        if($list.EnableVersioning -eq $true){
            Show-SPETextLine -text "Setting Versionhistory-Limit to $MaxVersions"
            lm -level Verbose -category $ScriptName -message "Setting Versionhistory-Limit to $MaxVersions"
            $list.MajorVersionLimit = $MaxVersions
            $list.Update()
            $ctx.Load($list)
            $ctx.ExecuteQuery()
        }
        #endregion

        $aiq = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
        $items = $list.GetItems($aiq)
        $ctx.Load($items)
        $ctx.ExecuteQuery()
        $cnt = 0
        foreach($item in $items){
            Exit-SPEOnCtrlC
            try{
                $cnt++
                Show-SPETextLine -text "Truncate versions for file $($item["FileLeafRef"])"
                lm -level Verbose -category $ScriptName -message "Truncate versions for file no. '$cnt' with filename '$($item["FileLeafRef"])'"
                $item.Update()
                $ctx.ExecuteQuery()
            } catch {
                $info = "Error at truncating versions for file $($item["FileLeafRef"])"
                lx -Stack $_ -info $info -Category $ScriptName
            }
        }

        #endregion
    } catch {
	    $exMessage = $_.Exception.Message
	    $innerException = $_.Exception.InnerException
	    $info = $($SPEResources.("StandardScriptGeneralErrorInScript")) + $ScriptName
        lx -Stack $_ -info $info -Category $ScriptName	    
        $global:foundErrors = $true
    }
    #endregion

#endregion
break
}
Trap [ExecutionEngineException]{
    lm -level High -CorrelationId $scriptCorrId -message $($SPEResources.("StandardScriptTerminatedByCtrlC"))
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
    } elseif($global:foundErrors){
        Out-SPESpeakText -text "Script finished with errors. Check logfiles, please."
		Write-SPEReportMessage -level "High" -area "Script" -category "Stopped" -message $($SPEResources.("StandardScriptFinishedWithErrors")) -CorrelationId $scriptCorrId
		lm -level "High" -area "Script" -category "Stopped" -message $($SPEResources.("StandardScriptFinishedWithErrors")) -CorrelationId $scriptCorrId
	} else {
        Out-SPESpeakText -text "Script successfully finished"
		Write-SPEReportMessage -message $($SPEResources.("StandardScriptFinishedWithoutErrors")) -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
		lm -message $($SPEResources.("StandardScriptFinishedWithoutErrors")) -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
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
