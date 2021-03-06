[CmdletBinding(DefaultParametersetName="Install")]
param(
    [Parameter(Position=3)][String]$WorkingDir,
    [Parameter(Position=2)][Switch]$DoNotDisplayConsole,
    [Parameter(Position=1)][Switch]$SPO,
    [Parameter(ParameterSetName="Reinstall",Position=0)][Switch]$Reinstall,
    [Parameter(ParameterSetName="Uninstall",Position=0)][Switch]$Uninstall,
    [Parameter(ParameterSetName="Install",Position=0)][Switch]$Install
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
            $global:dirCsv = $StringWorkingDir + "csv\"
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

    try{
        #region Initiate Connection to RootWeb
        $CorrelationId = Set-SPEGuidIncrement -guid $CorrelationId
        Write-SPELogMessage -level High -message "Start initiation of connection to SharePoint site '$UrlRootWeb'..."
        if(!$global:cred){
            if($SPO){
                $global:cred = Get-SPECredentialsFromCurrentUser -SPO
                $rootweb = Get-SPECsomWeb -Url $UrlRootWeb -Credentials $global:cred -SPO
            } else {
                $global:cred = Get-SPECredentialsFromCurrentUser
                $rootweb = Get-SPECsomWeb -Url $UrlRootWeb -Credentials $global:cred
            }
        }
        $ctx = $rootweb.Context
        if($rootweb.ServerObjectIsNull -or $rootweb -eq $null){
            Write-SPELogMessage -level Critical -message "Connection to website '$UrlRootWeb' can not be established! Please check url or credentials in config.xml."
            #$global:cred = $null
            exit
        } else {
            Write-SPELogMessage -level High -message "...connection to SharePoint site '$UrlRootWeb' succesfully established."
        }
        #endregion
        
        #region Reading CSV
        $csvLists = Import-Csv -Delimiter ';' -Path $PathCsvLists
        #endregion
        
        switch($PSCmdlet.ParameterSetName){
            "Uninstall"{
                #region delete lists
                foreach($listDefinition in $csvLists){
                    if($listDefinition.Target -eq "Rootweb"){
                        $listname = $listDefinition.Name
                        Write-SPELogMessage -level High -message "Start deletion of list named '$listname'..."
                        $listToDelete = $ctx.Web.Lists.GetByTitle($listname)
                        $ctx.Load($listToDelete)
                        $listToDelete.DeleteObject()
                        $listToDelete.Update() # No ExecuteQuery Needed, for the object is already deleted here!!!
                        Write-SPELogMessage -level High -message "... succesfully deleted list named '$listname'."
                    } else {
                        
                    }
                }
                #endregion
                break;
            }
            "Reinstall"{

            }
            "Install"{
                #region create websites
                #endregion
        
                #region create lists
                Write-SPELogMessage -level Medium -message "Start creation of Lists..."
                foreach($listDefinition in $csvLists){
                    $CorrelationId = Set-SPEGuidIncrement -guid $CorrelationId
                    $listname = $listDefinition.Name
                    Write-SPELogMessage -level Verbose -message "Start creation of list $listname..."
                    $newList = New-SPECsomList -Web $rootweb -ListTitle $listname -ListDescription $($listDefinition.Description) -ListTemplateId $($listTempateNamesToIDs[$listDefinition.Template])
                    Write-SPELogMessage -level Verbose -message "..successfully finished creation of list $listname."
                }
                Write-SPELogMessage -level Medium -message "..succesfully finished creation of lists."
                #endegion
                break;
            }
            Default{
                Write-SPELogAndTextMessage -message "Please choose on of the parameters [Install, Reinstall, Uninstall]."
            }
        }
        
        #region Objects clean up
        $rootweb = $null
        $ctx = $null

        #endregion


    } 
    catch {
	    $exMessage = $_.Exception.Message
	    $innerException = $_.Exception.InnerException
	    $info = "Allgemeiner Scriptfehler im Hauptprogramm."
	    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
        $global:foundErrors = $true
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
