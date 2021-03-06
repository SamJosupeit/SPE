param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole
)
$error.Clear()
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - D-40882 Ratingen                                            #
# Kunde   :                                                           #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Test-NewSPESPOnlineCmdlets.ps1                            #
# Funktion: Dieses Script soll die neu erstellten                     #
# SPESPOnline-Cmdlets testen                                          #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Krieger  | Erst-Erstellung                    | 04.11.2015 #
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
        $ModuleToLoad = "SamsPowerShellEnhancements"
        $dirModule = $StringWorkingDir + $ModuleToLoad + ".psd1"
        Remove-Module -Name $ModuleToLoad
        
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

    $dontExecuteThis = $true
    #region Erfassen der Credentials
    $global:CorrelationId = Set-SPEGuidIncrement -guid $global:CorrelationId
    if(!$global:cred){
        Write-SPELogMessage -message "Keine Credentials gespeichert. Frage neue Credentials ab..."
        Show-SPETextArray -textArray @(
            "Es sind derzeit keine Credentials gespeichert.",
            "",
            "Es öffnet sich ein Eingabefenster. Dort bitte die Anmeldedaten eingeben."
        )
        Set-SPEVariable -VariableName cred -CommandString "Get-SPESPOnlineCredentials"
        Write-SPELogMessage -message "...Credentials wurden abgefragt und gespeichert"
    } else {
        $username = $global:cred.UserName
        Write-SPELogMessage -message "Für Username '$username' wurden gespeicherte Credentials gefunden. Prüfe, ob diese genutzt werden sollen."
        Show-SPETextArray -textArray @(
            "Für Username '$username' wurden gespeicherte Credentials gefunden.",
            "",
            "Sollen diese benutzt werden?"
        )
        $choice = Select-SPEJN
        if(!$choice)
        {
            Write-SPELogMessage -message "Gespeicherte Credentials sollen ersetzt werden. Frage neue Credentials ab..."
            Set-SPEVariable -VariableName cred -CommandString "Get-SPESPOnlineCredentials"
            Write-SPELogMessage -message "...Credentials wurden abgefragt und gespeichert"
        }
    }
    #endregion

    #region Erfassen des Context
        $global:CorrelationId = Set-SPEGuidIncrement -guid $global:CorrelationId
        $url = $rootUrl
        Write-SPELogAndTextMessage -message "Erfasse nun den Context zur URL '$url'..."
        $global:ctx = Get-SPESPOnlineContext -Url $url -Credentials $cred

        # !!! Es werden bis hierher noch nicht die Credentials geprüft!!!
        # !!! Das geschieht erst im nächsten Schritt !!!

    #endregion

    #region Erfassen der RootWebSite
        $global:CorrelationId = Set-SPEGuidIncrement -guid $global:CorrelationId
        $rootWeb = Get-SPESPOnlineObjectByCtx -ParentObject $ctx -ChildObject "Web"
        if($rootWeb)
        {
            Write-SPELogAndTextMessage -message "RootWebsite wurde erfasst"
        } else {
            Write-SPELogAndTextMessage -message "Website wurde nicht erfasst."
            $ctx.dispose()
            break
        }
    #endregion

    #region Erfassen aller Subwebs der RootWebSite in der ersten Ebene
    if(!$dontExecuteThis)
    {
        $global:CorrelationId = Set-SPEGuidIncrement -guid $global:CorrelationId
        Write-SPELogAndTextMessage -message "Es wurden $subWebsCnt SubWebsites in der ersten Ebene erfasst"

        $subWebs = Get-SPESPOnlineObjectByCtx -ParentObject $rootWeb -ChildObject "Webs"
        if($subWebs)
        {
            $subwebsCnt = $subWebs.Count
            Write-SPELogAndTextMessage -message "Es wurden $subWebsCnt SubWebsites in der ersten Ebene erfasst"
        } else {
            Write-SPELogAndTextMessage -message "SubWebsites der ersten Ebene wurden nicht erfasst."
            $ctx.dispose()
            break
        }
    }
    #endregion

    #region iteratives Erfassen aller Subwebs unter RootWeb
    if(!$dontExecuteThis)
    {
        $global:CorrelationId = Set-SPEGuidIncrement -guid $global:CorrelationId
        Write-SPELogAndTextMessage -message "Es werden nun iterativ alle SubWebsites erfasst..."

        $allSubWebs = Get-SPESPOnlineSubWebsIterative -web $rootWeb -properties $allWebProperties
        
        Write-SPELogAndTextMessage -message "Es wurden $($allSubWebs.Count) SubWebsites in allen Ebenen erfasst."
        $outText = @("Es wurden folgende SubWebs gefunden:","")
        foreach($subWeb in $allSubWebs)
        {
            $outText += @("Title: $($subWeb.Title)","Url  : $($subWeb.Url)")
        }
        Show-SPETextArray -textArray $outText
        Wait-SPEForKey
        return $allSubWebs
    }
    #endregion

    #region Erstellen eines SPE-WebObjects von SPO-WebObject
    # Funktioniert nicht ganz, da mehrfache Zirkelbezüge erzeugt werden, z.B. User-> Group -> Users -> User -> Group, etc.
        Write-SPELogAndTextMessage -message "Erstelle nun ein SPE-WebObject auf Basis der RootWebSite $($rootWeb.title)"
        try{
            $SPEWeb = Get-SPEObjectFromSPOnlineObject -object $rootWeb -Ctx $ctx
        }
        catch
        {
            if($global:ActivateTestLoggingException)
            {
                $exMessage = $_.Exception.Message
                $innerException = $_.Exception.InnerException
                $info = "Bei Erstellung des SPE-WebObjects für Website $($rootWeb.title)"
                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
            }
        }
       #Write-SPELogAndTextMessage -message "Erzeugung des SPE-WebObjects abgeschlossen."
        return $SPEWeb
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
    $ctx.dispose()
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
