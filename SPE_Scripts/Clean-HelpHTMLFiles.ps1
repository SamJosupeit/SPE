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
# Name    : Clean-HelpHTMLFiles.ps1                                   #
# Funktion: Dieses Script bereinigt die vom PowerShell Help Editor    #
# erzeugten HTML-Dateien, die statt deutscher Umlaute                 #
# HTML-ASCII-Codes verwenden.                                         #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Krieger  | Erst-Erstellung                    | 30.10.2015 #
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
        Import-Module -Name $ModuleToLoad
    #endregion

    #region Laden der Config
        Get-SPEConfig -ScriptName $ScriptName
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

    Show-SPETextArray -textArray @("Willkommen zum Script 'Clean-HelpHTMLFiles'","","Dieses Script wird alle HTML-Help-Dateien unterhalb des Root-Ordners '$rootFolderPath' erfassen und die dort enthaltenen ASCII-Codes für die deutschen Umlaute gegen die entsprechenden Chars austauschen.")
    Wait-SPEForKey
    #region Setzen der zu filternden ASCII-Codes
    $filterPairArray = New-Object System.Collections.ArrayList
    $catchOutput = $filterPairArray.Add((New-Object System.Web.UI.Pair("&;252;","ü")))
    $catchOutput = $filterPairArray.Add((New-Object System.Web.UI.Pair("&;246;","ö")))
    $catchOutput = $filterPairArray.Add((New-Object System.Web.UI.Pair("&;228;","ä")))
    $catchOutput = $filterPairArray.Add((New-Object System.Web.UI.Pair("&;214;","Ö")))
    $catchOutput = $filterPairArray.Add((New-Object System.Web.UI.Pair("&;223;","ß")))
    $catchOutput = $filterPairArray.Add((New-Object System.Web.UI.Pair("&;220;","Ü")))
    $catchOutput = $filterPairArray.Add((New-Object System.Web.UI.Pair("&;196;","Ä")))
    $catchOutput = $filterPairArray.Add((New-Object System.Web.UI.Pair("&;39;","'")))
    #endregion

   # $rootFolderPath = "H:/Code/PS/_ScriptGenerator/Modules/SamsPowerShellEnhancements/de-DE/HTML"
    $rootDir = get-item $rootFolderPath
    $subDirs = $rootDir.GetDirectories()
    $dirCorrId = $scriptCorrId
    foreach($subDir in $subDirs)
    {
        $dirCorrId = Set-SPEGuidIncrement2ndBlock -guid $dirCorrId
        $global:CorrelationId = $dirCorrId
        $fileCorrId = $dirCorrId
        $files = $subDir.GetFiles()
        foreach($file in $files)
        {
            $fileCorrId = Set-SPEGuidIncrement3rdBlock -guid $fileCorrId
            $global:CorrelationId = $fileCorrId
            Exit-SPEOnCtrlC
            $outText = @(
                "Erfasse nun die einzelnen Dateien...",
                "Aktuelles Unter-Verzeichnis: '$($subdir.BaseName)'",
                "Aktuelle Datei             : '$($file.BaseName)'"
            )
            Write-SPELogMessage -message "Behandle Datei '$($file.BaseName)' in Verzeichnis '$($subdir.BaseName)'"
            Show-SPETextArray -textArray $outText
            $path = $file.FullName
            Switch-SPEASCIIStringToCharInTextFile -Path $path -filterArrayList $filterPairArray
            $outText.Clear()
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
