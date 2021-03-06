#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - D-40882 Ratingen                                            #
# Kunde   : MT Intern                                                 #
# Powershell-Script                                                   #
# #####################################################################
# Name:     Config.ps1                                                #
# Funktion: Dieses Script dient der lokalen Bereitstellung von        #
# Script-relevanten Parametern und Variablen für das                  #
# PowerShell-Script 'Analyze_SPFarm.ps1'                              #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Josupeit | Erst-Erstellung                    | 08.01.2015 #
######################################################################>
#endregion

#region Globale Variablen zur Nutzung innerhalb der Functions

    #region Logging
        $global:LogToConsole = $false # Aktiviert das Logging auf die Console
        $global:LogToLogFile = $false # Aktiviert das Logging in die Logdatei
        $global:LogToULSFile = $true # Aktiviert das Logging in die ULS-Datei
        $global:ReportToFile = $false # Aktiviert das Reporting in eine einfache Text-Datei
        $global:ReportToULS = $true  # Aktiviert das Reporting in eine ULS-konforme Datei
        $global:UseInfoHeader = $true # Wenn aktiviert, erfolgt die Consolen-Ausgabe in Verbindung mit dem InfoHeader
    #endregion

    #region Testmodus
        <##############################################################
        # Um den TestModus zu nutzen, die entsprechenden              #
        # Funktionen in den nachfolgenden Block setzen:               #
        ###############################################################
        if(!$TestModus){
            <Code-Block>
        }

        ##############################################################>
        $global:TestModus = $false # Aktiviert den TestModus, um z.B. Löschfunktionen im Testbetrieb vorerst zu deaktivieren
    #endregion

    #region Script-Ausführung als Administrator
        <###############################################################
        # wenn aktiviert, Wird geprüft, ob das Script in einer Console #
        # mit Administrator-Berechtigungen ausgeführt wird. Falls nicht#
        # wird das Script in einer neuen Console mit Administrator-    #
        # Berechtigungen neugestartet.                                 #
        ################################################################>
        $global:RunAsAdmin = $true 
    #endregion

    #region Initiale CorrelationId
    $global:InitialCorrelationIDs = @{
		"Analyze_SPFarm" = [Guid]"00000000-0000-0000-0001-000000000000"
	}
    #endregion

    #region Globale Variablen, erforderlich für Reboot-Functions

        # lokaler Pfad zur Powershell.exe
            $global:powershell = (Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe") 
        # Registry-Pfad zum Autostart-Verzeichnis in der Registry
            $global:RegRunKey ="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 
        # Name des für den Autostart zu setzenden Registry-Keys
            $global:restartKey = "Restart-And-Resume" 

    #endregion

	#region Definitionen für ULS-Files
        # ULS-File-Header
            $global:ULsHeader = "Timestamp              	Process                                 	TID   	Area                          	Category                      	EventID	Level     	Message 	Correlation"
        # Ist das Erstelldatum des aktuellen ULSFiles älter als hier angegeben, wird ein neues erstellt.
	        $global:maxAgeOfULSFile = New-TimeSpan -Minutes 15 
        # Ist das aktuelle ULSFile größer als hier angegeben, wird ein neues erstellt.
	        $global:maxSizeOfULSFile = 10MB 
        # Ist der Inhalt des jeweiligen ULS-Verzeichnisses größer als hier angegeben, wird das jeweils älteste File gelöscht.
            $global:maxSizeOfULSDirectory = 1GB 
	#endregion


    #region Globale Variablen, erfoderlich für die Gestaltung der Display-Functions

        # Switch zur Festlegung, ob Log-Meldungen auf Console mit oder ohne InfoHeader dargestellt werden sollen.
            $global:UseInfoHeader = $true 
        # Breite des InfoHeaders
            $global:InfoHeaderWidth = 54 
        # Inhalt des oberen InfoHeader-Blocks
            $global:InfoHeaderSuperScription = "MT AG Ratingen" 
        # Inhalt des unteren InfoHeader-Blocks
            $global:InfoHeaderSubScription = @{
                "Analyze_SPFarm" = "Dieses Script analysiert eine SharePoint-Farm und gibt die Ergebnisse zur weiteren Auswertung in Log- und Report-Files aus."
                }
        # Gegebene BackgroundColor
            $global:GivenBackGroundColor = $Host.UI.RawUI.BackgroundColor
        # Schriftfarbe des InfoHeaders
            $global:InfoHeaderForeGroundColor = "Green" 
        # Hintergrundfarbe des InfoHeaders
            $global:InfoHeaderBackGroundColor = "DarkCyan" 
        # Schriftfarbe der Ausgabe nach dem Infoheader für normale Meldungen
            $global:DisplayForeGroundColor_Normal = "Yellow" 
        # Schriftfarbe der Ausgabe nach dem Infoheader für Fehler- oder kritische Meldungen
            $global:DisplayForeGroundColor_Error = "Red" 
        # Schriftfarbe der Ausgabe nach dem Infoheader für normale Meldungen
            $global:DisplayBackGroundColor_Normal = $global:GivenBackGroundColor 
        # Schriftfarbe der Ausgabe nach dem Infoheader für Fehler- oder kritische Meldungen
            $global:DisplayBackGroundColor_Error = "White" 
        # Char mit dem der InfoHeader text-grafisch aufgebaut wird
            $global:DisplayFrameChar = '#' 
     
     #endregion

#endregion
