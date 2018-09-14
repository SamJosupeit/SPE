#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MindBusiness GmbH - Alzenau                                         #
# Powershell-Script                                                   #
# #####################################################################
# Name:     AddOrUpdateSolutionsInFolder.ps1                          #
# Funktion: Dieses Script erfasst alle im aktuellen Ordner            #
#           enthaltenen WSP-Dateien, überprüft, ob diese neu erstellt #
#           oder überarbeitet wurden, und fügt diese entweder der     #
#           Farm hinzu oder führt ein Update aus.                     #
#                                                                     #
# ################################################################### #
# # Versionsverlauf:                                                # #
# ################################################################### #
# Ver. | Autor      | Änderungen                         | Datum      #
# ################################################################### #
# 0.1  | Josupeit   | Erst-Erstellung                    | 13.02.2014 #
######################################################################>

#region Variablen-Deklaration
    
    #region Template-eigene Switches !!! Bei Bedarf anpassen !!!
        $writeLogToFile = $false
        $writeLogToConsole = $true
    #endregion

	#region Template-eigene Variablen !!! NICHT BEARBEITEN !!!
		
		#region Ermittlung des Scriptnamens
			$ScriptName = $MyInvocation.MyCommand.Name -replace ".ps1",""
		#endregion

		#region Pfad zum Arbeitsverzeichnis
			$PathWorkingDir = Get-Location
			$StringWorkingDir = $PathWorkingDir.ToString() + "\"
		#endregion
		
		#region Erzeugen der LOG-Datei
			$StringDateTime = (Get-Date).ToString() # aktuelle Zeit zur Erstellung der Protokolldateien
			$StringDateTime = $StringDateTime.Replace(" ","_-_").Replace(".","_").Replace(":","_") # aktuelle Zeit zur Erstellung der Protokolldateien
			$PathLogfile = $StringWorkingDir + "Log" + $ScriptName + $StringDateTime + ".log" # Pfad zur Log-Datei
		#endregion
		
		#region Header für Logfile
			$HeaderLogfile = "###############################################" + "`n" +
							 "# Logfile - " + $ScriptName + ".ps1" + "`n" +
							 "# erstellt: " + $StringDateTime + "`n" +
							 "###############################################" + "`n"
		#endregion

	#endregion

	#region Script-spezifische Variablen !!! Hier kann gearbeitet werden !!!

        #region Vordefinierte Werte
            $xmlFileName = "wsp.xml"
        #endregion

        #region Erfasste Werte
            $loc = Get-Location
            $allFiles = Get-ChildItem . 
        #endregion

        #region Berechnete Werte
            $path = $loc.Path
            $xmlPath = $path + "\" + $xmlFileName
            $wspFiles = $allFiles | ?{$_.Name -match ".wsp"}
            $xmlFile = $allFiles | ?{$_.Name -eq $xmlFileName}
        #endregion

	#endregion

#endregion

#region Initialisierung der Ausgabe-Dateien

	#region Template-eigene Ausgabe-Dateien !!! NICHT BEARBEITEN !!!

		#region Header in Logfile schreiben
        if($writeLogToFile){
			$HeaderLogfile > $PathLogfile 
        }
		#endregion
	
	#endregion
	
	#region Script-spezifische Ausgabe-Dateien !!! Hier kann gearbeitet werden !!!
	
	#endregion
	
#endregion

#region Functions

	#region Template-eigene Functions !!! NICHT BEARBEITEN !!!

		function GetCurrentTimeForLog {
			$DateTimeString = (Get-Date).ToString() #Erfassen der Systemzeit
			$DateTimeString = $DateTimeString.Replace(" ","_-_").Replace(".","_").Replace(":","_") #Anpassen des Strings
			$DateTimeString = $DateTimeString + " : " #Anpassen des Strings
			return $DateTimeString #Ausgabe des Strings
		}

		function OutputToLogfile([string]$Content) {
			$CurrentTimeStamp = GetCurrentTimeForLog #Abfrage der aktuellen Zeit
			$NewLine = $CurrentTimeStamp + $Content #Erzeugen des Log-Eintrags
            if($writeLogToFile){
			    $NewLine >> $PathLogfile #Ausgabe des Log-Eintrags in Logfile
            }
            if($writeLogToConsole){
			    Write-Host $NewLine #Ausgabe des Log-Eintrags auf Console
            }
		}
	
	#endregion

	#region Script-spezifische Functions !!! Hier kann gearbeitet werden !!!

    #region updateSolution: 
    #führt ein Update einer vorhandenen Solution durch
        function updateSolution($solutionName, $solutionPath){
            $output = "Aktualisiere Solution " + $solutionName + " ..."
            OutputToLogfile($output)
            $literalPath = $solutionPath + "\" + $solutionName
            Update-SPSolution -Identity $solutionName -LiteralPath $literalPath -GACDeployment 
            $output = "... abgeschlossen"
            OutputToLogfile($output)
       }
    #endregion

    #region addSolution:
    # fügt eine Solution der Farm hinzu
        function addSolution($solutionName, $solutionPath){
            $literalPath = $solutionPath + "\" + $solutionName
            $checkSolution = Get-SPSolution | ?{$_.Name -eq $solutionName}
            if($checkSolution){
                updateSolution -solutionPath $solutionPath -solutionName $solutionName
            } else {
                $output = "Füge Solution " + $solutionName + " der Farm hinzu..."
                OutputToLogfile($output)
                Add-SPSolution -LiteralPath $literalPath  
                $output = "... abgeschlossen"
                OutputToLogfile($output)
            }
        }
    #endregion


    #region compareFilesWithXml: 
    # vergleicht die vorhandenen WSP-Dateien mit Einträgen in der XML-Datei 
    # zur Überprüfung auf notwendige Aktualisierung und gibt die zu aktualisierenden aus
        function compareFilesWithXml($xmlData, $files){
            $output = "Vergleiche die WSP-Dateien mit der XML-Datei..."
            OutputToLogfile($output)

            $filesToHandle = @()
            foreach($xmlObject in $xmlData){
                $objectToUpdate = New-Object PSObject
                $currentFile = $files | ?{$_.Name -eq $xmlObject.Name}
                if($currentFile -and ($xmlObject.LastWriteTimeUtc -lt $currentFile.LastWriteTimeUtc)){
                    $objectToUpdate | Add-Member -NotePropertyName "FileName" -NotePropertyValue $currentFile.Name
                    $objectToUpdate | Add-Member -NotePropertyName "Mode" -NotePropertyValue "update"
                    $filesToHandle += $objectToUpdate
                    $output = "Solution '" + $objectToUpdate.FileName + "' wurde mit Modus '" + $objectToUpdate.Mode + "' der Ergebnis-Liste hinzugefügt."
                    OutputToLogfile($output)

                }
            }
            foreach($file in $files){
                $fileIsInXML = $false
                foreach($fileToHandle in $filesToHandle){
                    if($fileToHandle.FileName -eq $file.Name){
                        $fileIsInXML = $true
                    }
                }
                foreach($fileInXML in $xmlData){
                    if($fileInXML.Name -eq $file.Name){
                        $fileIsInXML = $true
                    }
                }
                if(!$fileIsInXML){
                    $objectToAdd = New-Object PSObject
                    $objectToAdd | Add-Member -NotePropertyName "FileName" -NotePropertyValue $file.Name
                    $objectToAdd | Add-Member -NotePropertyName "Mode" -NotePropertyValue "add"
                    $filesToHandle += $objectToAdd
                    $output = "Solution '" + $objectToAdd.FileName + "' wurde mit Modus '" + $objectToAdd.Mode + "' der Ergebnis-Liste hinzugefügt."
                    OutputToLogfile($output)
                }
            }
            $output = "... Vergleich abgeschlossen"
            OutputToLogfile($output)
            return $filesToHandle
        }
    #endregion

    #region writeCurrentFilesToXml:
    # schreibt die aktuellen Files in die XML-Datei
        function writeCurrentFilesToXml($files, $outputXmlPath){
            $output = "Erzeuge XML-Datei '" + $outputXmlPath + "'..."
            OutputToLogfile($output)

            $filesToExport = @()
            foreach($file in $files){
                $fileObject = New-Object PSObject
                $fileObject | Add-Member NoteProperty -Name "Name" $file.Name
                $fileObject | Add-Member NoteProperty -Name "LastWriteTimeUtc" $file.LastWriteTimeUtc
                $filesToExport += $fileObject
            }
            $filesToExport | Export-Clixml -Path $outputXmlPath
            $output = "...abgeschlossen"
            OutputToLogfile($output)

        }
    #endregion
	
	#endregion

#endregion

#region Hauptprogramm !!! Hier kann gearbeitet werden !!!


#region Load XML if it exists
OutputToLogfile("Start des Scripts");
$output = "Überprüfe, ob XML-Datei '" + $xmlPath + "' vorhanden ist"
OutputToLogfile($output)
if($xmlFile)
{
    $output = "XML-Datei '" + $xmlFileName + "' ist vorhanden."
    OutputToLogfile($output)
    $output = "Starte Import der XML-Datei..."
    OutputToLogfile($output)
    $xmlData = Import-Clixml $xmlFile
    $output = "...Import abgeschlossen"
    OutputToLogfile($output)
    $solutionsToHandle = compareFilesWithXml -xmlData $xmlData -files $wspFiles
    foreach($solutionToHandle in $solutionsToHandle){
        $name = $solutionToHandle.FileName
        $mode = $solutionToHandle.Mode
        $output = "Solution '" + $name + "' hat Modus '" + $mode + "'."
        OutputToLogfile($output)
        switch($mode)
        {
            "add"{
                addSolution -solutionPath $path -solutionName $name
            }
            "update"{
                updateSolution -solutionPath $path -solutionName $name
            }
            default{

            }
        }
    }
} 
else 
{
    $output = "XML-Datei '" + $xmlFileName + "' ist nicht vorhanden."
    OutputToLogfile($output)
    $output = "Starte Hinzufügen aller Solutions..."
    OutputToLogfile($output)

    foreach($file in $wspFiles){
        addSolution -solutionPath $path -solutionName $file.Name
    }
    $output = "...Hinzufügen abgeschlossen."
    OutputToLogfile($output)
}
writeCurrentFilesToXml -outputXmlPath $xmlPath -files $wspFiles
OutputToLogfile("Ende des Scripts")
#endregion



#endregion

#region Code-Kommentare !!! Hier kann gearbeitet werden !!!
<######################################################################
Hier ist Platz für Kommentare, Informationen und Beispiel-Code
#######################################################################

#region BeispielCode für Log-Eintrag
#           Um Einträge in das Logfile vorzunehmen, ist die folgende  #
#           Prozedur zu beachten:                                     #
#                                                                     #
#           $OutputToLogfile = "[Text des Eintrags]"                  #
#           OutputToLogfile($OutputToLogfile)                         #
#                                                                     #
#           Damit wird im Logfile ein Eintrag mit aktuellem Datum und #
#           dem Inhalt der Variable $OutputToLogfile, der selbst-     #
#           verständlich auch kontext-bezogen sein kann, erzeugt.     #
#endregion

#>
#endregion