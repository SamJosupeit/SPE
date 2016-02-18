param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole,
    [Switch]$Update
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - D-40882 Ratingen                                            #
# Kunde   : Allgemein                                                 #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Install-SPEModule.ps1                                     #
# Funktion: Dieses Script installiert das PSE-Module in das Windows   #
#           PowerShell-Module-Verzeichnis, um es so global zu         #
#           Verfügung zu stellen.                                     #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Josupeit | Erst-Erstellung                    | 29.07.2015 #
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

    #region Auslesen Config-Datei per Dot-Sourcing
        . .\Config.ps1
    #endregion 

    #region Laden des SPEModule
        Import-Module -Name $dirModule
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

	#region ScriptStatus
	$scriptCorrId = $global:InitialCorrelationIDs.($Scriptname)
	$global:CorrelationId = $scriptCorrId
	Write-SPELogMessage -message "Script has started." -level "High"
	Write-SPEReportMessage -level "High" -area "Script" -category "Started" -message "Script has started." -CorrelationId $scriptCorrId
	$global:scriptaborted = $false
	$global:foundErrors = $false
	#endregion

#endregion
Exit-SPEOnCtrlC
while($true)
{

#region Hauptprogramm !!! Hier kann gearbeitet werden !!!

    Show-SPETextArray -textArray @(
        "Willkommen zum Installer-Script für das SPE-Common-Module.",
        "",
        "Dieses Script kopiert die Module-Dateien in das Windows-PowerShell-Module-Verzeichnis und richtet das Module so ein, dass es automatisch beim Öffnen einer PowerShell-Console geladen wird.",
        "",
        "So werden in jeder Session die Cmdlets des Modules verfügbar sein.",
        ""
    )
#    Wait-SPEForKey

    Show-SPETextLine -text "Erfasse nun die Quell-Dateien und kopiere diese ins Windows-PowerShell-Module-Verzeichnis..."
#    Wait-SPEForKey

    $ModulesPath = Get-SPEWindowsPSModulesFolderPath
    $ModuleManifest = Get-ChildItem $directoryOfModule | Where{$_.Extension -match "psd1"}
    $moduleName = $ModuleManifest.BaseName
    Write-SPELogMessage -message "Beginne mit Installation des PowerShell-Modules '$moduleName'..."

    #region Quell-Ordner und Dateien
    $folders = @(
        $moduleName,
        ($moduleName + "\de-DE"),
        ($moduleName + "\en-US")
    )
    $files = @(
        "SPE.Common.psm1",
        "SPE.Common.psd1",
        "de-DE\SPE.Common.psm1-help.xml",
        "en-US\SPE.Common.psm1-help.xml"
    )
    #endregion

    #region Prüfen, ob Ziel-Ordner vorhanden sind, und Erstellen bei Nicht-Vorhandensein
    Write-SPELogMessage -message "Überprüfe Ziel-Ordner und erstelle diese bei Nicht-Vorhandensein..."
    $foldersExist = $true
    foreach($folder in $folders)
    {
        $folderFullName = $ModulesPath.TrimEnd("\") + "\" + $folder
        Write-SPELogMessage -message "Prüfe Ziel-Ordner '$folderFullName'..."
        if(!(Test-Path -Path $folderFullName))
        {
            try
            {
                Write-SPELogMessage -message "Ziel-Ordner '$folderFullName' existiert noch nicht und wird nun erstellt..."
                $catchOutput = New-Item -Path $folderFullName -ItemType "Directory"
                Write-SPELogMessage -message "Ziel-Ordner '$folderFullName' wurde erstellt."
            }
	        catch
	        {
	            $exMessage = $_.Exception.Message
	            $innerException = $_.Exception.InnerException
	            $info = "Fehler bei Erstellen des Ordners '$folderFullName'."
	            Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                $foldersExist = $false
                break
	        }
        }
        else
        {
            Write-SPELogMessage -message "Ziel-Ordner '$folderFullName' existiert bereits und kann genutzt werden."
        }
    }
    #endregion

    #region Kopieren der Dateien
    if($foldersExist)
    {
        Write-SPELogMessage -message "Alle Ziel-Ordner existieren und können genutzt werden."
        Write-SPELogMessage -message "Kopiere nun die Module-Dateien..."
        $copyStatus = "ohne Fehler"
        foreach($file in $files)
        {
            Exit-SPEOnCtrlC
            $srcFileFullname = $StringWorkingDir + $file
            $srcFileObject = Get-Item -Path $srcFileFullname
            $srcFilePath = $srcFileObject.DirectoryName
            $trgFilePath = $srcFilePath.Replace($StringWorkingDir.TrimEnd("\"), ($ModulesPath.TrimEnd("\") + "\" + $moduleName + "\"))
            $newFileFullName = $trgFilePath + $file

            Write-SPELogMessage -message "Prüfe, ob Datei '$newFileFullName' bereits existiert..."
            if(Test-Path -Path $newFileFullName)
            {
                #File exists
                Write-SPELogMessage -message "Datei '$newFileFullName' existiert bereits."
                Write-SPELogMessage -message "Prüfe, ob Update-Switch gesetzt ist..."
                if($Update)
                {
                    Write-SPELogMessage -message "Update-Switch ist gesetzt."
                    Write-SPELogMessage -message "Überschreibe nun bestehende Datei..."
                    try
                    {
                        Write-SPELogMessage -message "kopiere Datei '$file' nach '$trgFilePath'..."
                        Show-SPETextLine -text "kopiere Datei '$file'..."
                        Copy-Item -Path $srcFileFullName -Destination $trgFilePath -Force
                        Write-SPELogMessage -message "Kopieren erfolgreich abgeschlossen."
                    }
	                catch
	                {
	                    $exMessage = $_.Exception.Message
	                    $innerException = $_.Exception.InnerException
	                    $info = "Fehler bei Kopieren der Datei '$file' nach Ordner '$trgFilePath'."
                        Show-SPETextLine -text "Fehler bei Kopieren der Datei '$file'" -fgColor "Red" -bgColor "White"
	                    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                        $copyStatus = "mit Fehler(n)"
	                }
                } 
                else 
                {
                    Write-SPELogMessage -message "Update-Switch ist nicht gesetzt."
                    Show-SPETextLine -text "Module-Datei existiert bereits. Um die bestehenden Dateien zu überschreiben, bitte das Script mit dem Switch 'Update' aufrufen."
#                    Wait-SPEForKey
                    $copyStatus = "mit Fehler(n)"
                }
            }
            else 
            {
                #File not exists
                try
                {
                    Write-SPELogMessage -message "kopiere Datei '$file' nach '$trgFilePath'..."
                    Show-SPETextLine -text "kopiere Datei '$file'..."
                    Copy-Item -Path $srcFileFullName -Destination $trgFilePath -Force
                    Write-SPELogMessage -message "Kopieren erfolgreich abgeschlossen."
                }
	            catch
	            {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Fehler bei Kopieren der Datei '$srcFileFullName' nach Ordner '$trgFilePath'."
	                Show-SPETextLine -text "Fehler bei Kopieren der Datei '$file'" -fgColor "Red" -bgColor "White"
                    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                    $copyStatus = "mit Fehler(n)"
	            }
            }
        }
    }
    else
    {
        Write-SPELogMessage -message "Fehler bei Erstellen der Ziel-Ordner. Installation wird abgebrochen. Bitte Logfile prüfen."
        Show-SPETextline -text "Fehler bei Erstellen der Ziel-Ordner. Installation wird abgebrochen. Bitte Logfile prüfen." -fgColor Red -bgColor White
        $global:foundErrors = $true
#        Wait-SPEForKey
    }
    Show-SPETextline -text "Kopieren der Module-Dateien $copyStatus abgeschlossen"
    Write-SPELogMessage -message "Kopieren der Module-Dateien $copyStatus abgeschlossen"
#    Wait-SPEForKey
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
        Wait-SPEForKey
    }
    continue
    #endregion
}

#region End of Script and opening of the script's logfile

    #region Entladen des Modules
        Remove-Module $ModuleToLoad
    #endregion
	
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
