#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        New-SPEStandardScript.ps1                              #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function New-SPEStandardScript
    #.ExternalHelp SPE.Common.psm1-help.xml
    function New-SPEStandardScript
    {
        [CmdletBinding()]
        param()
        Begin
        {
            $error.Clear()
            $global:SPEGeneratorActive = $true
            #region Auslesen der aktuellen Werte und Parameter
            $oldValues = @{
                "LogToConsole" = $global:LogToConsole;
                "LogToLogFile" = $global:LogToLogFile;
                "LogToULSFile" = $global:LogToULSFile;
                "ReportToFile" = $global:ReportToFile;
                "ReportToULS" = $global:ReportToULS;
                "UseInfoHeader" = $global:UseInfoHeader;
                "RunAsAdmin" = $global:RunAsAdmin;
                "ULsHeader" = $global:ULsHeader;
                "maxAgeOfULSFile" = $global:maxAgeOfULSFile;
                "maxSizeOfULSFile" = $global:maxSizeOfULSFile;
                "maxSizeOfULSDirectory" = $global:maxSizeOfULSDirectory;
                "InfoHeaderWidth" = $global:InfoHeaderWidth;
                "InfoHeaderSuperScription" = $global:InfoHeaderSuperScription;
                "InfoHeaderSubScription" = $global:InfoHeaderSubScription;
                "GivenBackGroundColor" = $global:GivenBackGroundColor;
                "InfoHeaderForeGroundColor" = $global:InfoHeaderForeGroundColor;
                "InfoHeaderBackGroundColor" = $global:InfoHeaderBackGroundColor;
                "DisplayForeGroundColor_Normal" = $global:DisplayForeGroundColor_Normal;
                "DisplayForeGroundColor_Error" = $global:DisplayForeGroundColor_Error;
                "DisplayBackGroundColor_Normal" = $global:DisplayBackGroundColor_Normal;
                "DisplayBackGroundColor_Error" = $global:DisplayBackGroundColor_Error;
                "DisplayFrameChar" = $global:DisplayFrameChar;
                "ActivateTestLoggingVerbose" = $global:ActivateTestLoggingVerbose;
                "ActivateTestLoggingException" = $global:ActivateTestLoggingException;
                "ActivateTestLogging" = $global:ActivateTestLogging;
            }
            #endregion
            #region Setzen der SPE-Werte und -Parameter
                $global:dirLog = $SPEVars.LogFolder;
                $global:StringWorkingDir = $SPEVars.ScriptFolder;
                $global:LogToConsole = $SPEvars.LogToConsole;
                $global:LogToLogFile = $SPEvars.LogToLogFile;
                $global:LogToULSFile = $SPEvars.LogToULSFile;
                $global:ReportToFile = $SPEvars.ReportToFile;
                $global:ReportToULS = $SPEvars.ReportToULS;
                $global:UseInfoHeader = $SPEvars.UseInfoHeader;
                $global:RunAsAdmin = $SPEvars.RunAsAdmin;
                $global:ULsHeader = $SPEvars.ULsHeader;
                $global:maxAgeOfULSFile = $SPEvars.maxAgeOfULSFile;
                $global:maxSizeOfULSFile = $SPEvars.maxSizeOfULSFile;
                $global:maxSizeOfULSDirectory = $SPEvars.maxSizeOfULSDirectory;
                $global:InfoHeaderWidth = $SPEvars.InfoHeaderWidth;
                $global:InfoHeaderSuperScription = $SPEvars.InfoHeaderSuperScription;
                $global:InfoHeaderSubScription = $SPEvars.InfoHeaderSubScription;
                $global:GivenBackGroundColor = $SPEvars.GivenBackGroundColor;
                $global:InfoHeaderForeGroundColor = $SPEvars.InfoHeaderForeGroundColor;
                $global:InfoHeaderBackGroundColor = $SPEvars.InfoHeaderBackGroundColor;
                $global:DisplayForeGroundColor_Normal = $SPEvars.DisplayForeGroundColor_Normal;
                $global:DisplayForeGroundColor_Error = $SPEvars.DisplayForeGroundColor_Error;
                $global:DisplayBackGroundColor_Normal = $SPEvars.DisplayBackGroundColor_Normal;
                $global:DisplayBackGroundColor_Error = $SPEvars.DisplayBackGroundColor_Error;
                $global:DisplayFrameChar = [Char]$SPEvars.DisplayFrameChar;
                $global:ActivateTestLoggingVerbose = $SPEvars.ActivateTestLoggingVerbose;
                $global:ActivateTestLoggingException = $SPEvars.ActivateTestLoggingException;
                $global:ActivateTestLogging = $SPEvars.ActivateTestLogging;
            #endregion
        }
        Process
        {

            $global:starttime = get-date
            #region Abfragen
            Show-SPETextArray -textArray @("Willkomen zum Script-Generator für SPE-Standard-Scripts.","")
            Wait-SPEForKey

            $Input_ScriptName = Show-SPEQuestion -text "Bitte den Namen des Scripts eingeben:"
            $Input_Description = Show-SPEQuestion -text "Bitte die Beschreibung des Scripts eingeben:"
            Show-SPETextLine -text "Soll das Script für einen Kunden erstellt werden?"
            if(Select-SPEJN){
                $Input_Customer = Show-SPEQuestion -text "Bitte den Namen des Kunden eingeben:"
            }
            #endregion
            #region fixe Daten
            $currentDate = "{0:dd'.'MM'.'yyyy}" -f (Get-Date) 
            #endregion
            #region Erzeugen bzw. Erfassen der Config-XML-Datei
            if(!(Test-Path -Path $SPEVars.ScriptFolder))
            {
                $catchOutput = New-Item -Path ($SPEVars.ScriptFolder) -ItemType "Directory"
            }
            if(!(Test-Path -Path $SPEVars.ConfigXMLFile))
            {
                $newConfigXML = [xml]$global:XMLConfigDefault # > $SPEVars.ConfigXMLFile
                Save-SPEXmlDocumentObjectAsUTF8 -XmlDocumentObject $newConfigXML -Path ($SPEVars.ConfigXMLFile)
                $newConfigXML = $null
            }
            [xml]$XMLConfigDoc = Get-Content -Path $SPEVars.ConfigXMLFile
            if(!$XMLConfigDoc){$global:SPEGeneratorActive = $false;break}
            #endregion
            #region Abfrage der Default-Parameter aus Config-XML-Datei und schreiben in HashTable zur späteren Anpassung
            $hashParameterGroups = @{
                "Pfade" = @{
                    "PathToSharePointDLLs" = $XMLConfigDoc.SPE_Config.Default.Pfade.PathToSharePointDLLs.Wert.ToString();
                    "dirLog" = $XMLConfigDoc.SPE_Config.Default.Pfade.dirLog.Wert.ToString();
                }
                "Logging" = @{
                    "LogToConsole" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToConsole.Wert.ToString();
                    "LogToLogFile" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToLogFile.Wert.ToString();
                    "LogToULSFile" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToULSFile.Wert.ToString();
                    "ReportToFile" = $XMLConfigDoc.SPE_Config.Default.Logging.ReportToFile.Wert.ToString();
                    "ReportToULS" = $XMLConfigDoc.SPE_Config.Default.Logging.ReportToULS.Wert.ToString();
                    "ActivateTestLoggingVerbose" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLoggingVerbose.Wert.ToString();
                    "ActivateTestLoggingException" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLoggingException.Wert.ToString();
                    "ActivateTestLogging" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLogging.Wert.ToString();
                }
                "Scriptverhalten" = @{
                    "TestModus" = $XMLConfigDoc.SPE_Config.Default.Scriptverhalten.TestModus.Wert.ToString();
                    "RunAsAdmin" = $XMLConfigDoc.SPE_Config.Default.Scriptverhalten.RunAsAdmin.Wert.ToString();
                    "DefaultCorrId" = $XMLConfigDoc.SPE_Config.Default.Scriptverhalten.DefaultCorrId.Wert.ToString();
                }
                "Registry" = @{
                    "powershell" = $XMLConfigDoc.SPE_Config.Default.Registry.powershell.Wert.ToString();
                    "RegRunKey" = $XMLConfigDoc.SPE_Config.Default.Registry.RegRunKey.Wert.ToString();
                    "restartKey" = $XMLConfigDoc.SPE_Config.Default.Registry.restartKey.Wert.ToString();
                }
                "ULS" = @{
                    "UlsHeader" = $XMLConfigDoc.SPE_Config.Default.ULS.UlsHeader.Wert.ToString();
                    "maxAgeOfULSFile" = $XMLConfigDoc.SPE_Config.Default.ULS.maxAgeOfULSFile.Wert.ToString();
                    "maxSizeOfULSFile" = $XMLConfigDoc.SPE_Config.Default.ULS.maxSizeOfULSFile.Wert.ToString();
                    "maxSizeOfULSDirectory" = $XMLConfigDoc.SPE_Config.Default.ULS.maxSizeOfULSDirectory.Wert.ToString();
                }
                "Display" = @{
                    "UseInfoHeader" = $XMLConfigDoc.SPE_Config.Default.Display.UseInfoHeader.Wert.ToString();
                    "InfoHeaderWidth" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderWidth.Wert.ToString();
                    "InfoHeaderSuperScription" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderSuperScription.Wert.ToString();
                    "InfoHeaderSubScription" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderSubScription.Wert.ToString();
                    "GivenBackGroundColor" = $XMLConfigDoc.SPE_Config.Default.Display.GivenBackGroundColor.Wert.ToString();
                    "InfoHeaderForeGroundColor" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderForeGroundColor.Wert.ToString();
                    "InfoHeaderBackGroundColor" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderBackGroundColor.Wert.ToString();
                    "DisplayForeGroundColor_Normal" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayForeGroundColor_Normal.Wert.ToString();
                    "DisplayForeGroundColor_Error" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayForeGroundColor_Error.Wert.ToString();
                    "DisplayBackGroundColor_Normal" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayBackGroundColor_Normal.Wert.ToString();
                    "DisplayBackGroundColor_Error" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayBackGroundColor_Error.Wert.ToString();
                    "DisplayFrameChar" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayFrameChar.Wert;
                }

            }
            #endregion
            #region Inserts
            $line_Company        = Convert-SPETextToFramedBlock -InputText "MT AG - D-40882 Ratingen" -width 70 -char '#'
            $line_ScriptName     = Convert-SPETextToFramedBlock -InputText ("Name    : $Input_ScriptName" + ".ps1") -width 70 -char '#'
            $line_Description    = Convert-SPETextToFramedBlock -InputText ("Funktion: $Input_Description") -width 70 -char '#'
            $line_ConfigDescription = Convert-SPETextToFramedBlock -InputText ("Funktion: Dieses Script dient der lokalen Bereitstellung von Script-relevanten Parametern und Variablen für das PowerShell-Script '$Input_ScriptName.ps1'") -width 70 -char '#'
            $line_Customer       = Convert-SPETextToFramedBlock -InputText ("Kunde   : $Input_Customer") -width 70 -char '#'
            #endregion
            #region Manipulation des FullCodeSnippets
            $FullCode1 = $FullScriptCode1.Replace("[line_Company]",$line_Company)
            $FullCode1 = $FullCode1.Replace("[line_ScriptName]",$line_ScriptName)
            $FullCode1 = $FullCode1.Replace("[line_Customer]",$line_Customer)
            $FullCode2 = $FullScriptCode2.Replace("[line_dat]",$currentDate)
            $userShortName = Get-SPECurrentUsersShortName -Length 10
            $FullCode2 = $FullCode2.Replace("[UserName]",$userShortName)
            #endregion
            #region Abfragen zu Config-Parametern
                Show-SPETextArray -textArray ("Standardmäßig werden Log- und Report-Files im ULS-Format ausgegeben und der Infoheader aktiviert.","","Ebenso werden Status- und Exception-Meldungen aus den Cmdlets des SPE-Modules in das Log geschrieben.","Soll diese Vorgabe übernommen werden?")
                if(!(Select-SPEJN)){
                    #region Log to Console
                    Show-SPETextLine -text "Soll das Logging auf die Console erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.LogToSonsole = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToSonsole = '$false'
                    }
                    #endregion
                    #region Log To File
                    Show-SPETextLine -text "Soll das Logging in eine Textdatei erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.LogToLogFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToLogFile = '$false'
                    }
                    #endregion
                    #region Log to ULS
                    Show-SPETextLine -text "Soll das Logging in ULS-File erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.LogToULSFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToULSFile = '$false'
                    }
                    #endregion
                    #region Report to File
                    Show-SPETextLine -text "Soll das Reporting in eine Textdatei erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ReportToFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.ReportToFile = '$false'
                    }
                    #endregion
                    #region Report to ULS
                    Show-SPETextLine -text "Soll das Reporting in eine ULS-Datei erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ReportToULS = '$true'
                    } else {
                        $hashParameterGroups.Logging.ReportToULS = '$false'
                    }
                    #endregion
                    #region Use Infoheader
                    Show-SPETextLine -text "Soll bei Consolen-Ausgabe der InfoHeader genutzt werden?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Display.UseInfoHeader = '$true'
                    } else {
                        $hashParameterGroups.Display.UseInfoHeader = '$false'
                    }
                    #endregion
                    #region ActivateTestLogging
                    Show-SPETextLine -text "Sollen allgemeine Meldungen der SPE-Cmdlets in das Log geschrieben werden?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ActivateTestLogging = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLogging = '$false'
                    }
                    #endregion
                    #region ActivateTestLoggingVerbose
                    Show-SPETextLine -text "Sollen Status-Meldungen der SPE-Cmdlets in das Log geschrieben werden?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ActivateTestLoggingVerbose = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLoggingVerbose = '$false'
                    }
                    #endregion
                    #region ActivateTestLoggingException
                    Show-SPETextLine -text "Sollen Exception-Meldungen der SPE-Cmdlets in das Log geschrieben werden?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ActivateTestLoggingException = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLoggingException = '$false'
                    }
                    #endregion
                } 
                #region TestModus aktivieren
                Show-SPETextLine -text "Soll der TestModus aktiviert werden?"
                if(Select-SPEJN){
                    $hashParameterGroups.Scriptverhalten.TestModus = '$true'
                } else {
                    $hashParameterGroups.Scriptverhalten.TestModus = '$false'
                }
                #endregion
                #region RunAsAdmin aktivieren
                Show-SPETextLine -text "Sind für die Ausführung des Scripts voraussichtlich Administrator-Berechtigungen erforderlich?"
                if(Select-SPEJN){
                    $hashParameterGroups.Scriptverhalten.RunAsAdmin = '$true'
                } else {
                    $hashParameterGroups.Scriptverhalten.RunAsAdmin = '$false'
                }
                #endregion

            #endregion

            #region weitere Parameter ohne Abfrage

                #region Sammeln aller vorhandenen Correlation IDs und erzeugen einer neuen
                if($XMLConfigDoc.SPE_Config.HasChildNodes -and $XMLConfigDoc.SPE_Config.ChildNodes.Count -gt 1)
                {
                    $xmlScriptNodes = $XMLConfigDoc.SPE_Config.ChildNodes
                    $arrayCorrIDs = New-Object System.Collections.ArrayList
                    foreach($xmlScriptNode in $xmlScriptNodes)
                    {
                        Set-SPEVariable -VariableName tempGuid -CommandString ($xmlScriptNode.Scriptverhalten.DefaultCorrId.Wert)
                        $catchOutput = $arrayCorrIDs.Add($tempGuid)
                    }
                    $arrayCorrIDs = [Array]$arrayCorrIDs | Sort-Object
                    $newCorrID = Set-SPEGuidIncrement1stBlock -guid $arrayCorrIDs[$arrayCorrIDs.GetUpperBound(0)]
                } else {
                    Set-SPEVariable -VariableName tempGuid -CommandString ($hashParameterGroups.Scriptverhalten.DefaultCorrid)
                    $newCorrID = Set-SPEGuidIncrement1stBlock -guid $tempGuid
                }
                $hashParameterGroups.Scriptverhalten.DefaultCorrId = '[Guid]"' + $newCorrID.ToString() + '"'
                #endregion

                #region Registry-Restart-Key
                $hashParameterGroups.Registry.restartKey = '"' + $hashParameterGroups.Registry.restartKey.ToString().Replace('"','') + "_" + $Input_ScriptName + '"'
                #endregion

                #region InfoheaderSubScription
                $hashParameterGroups.Display.InfoHeaderSubScription = '"' + $Input_Description.ToString() + '"'
                #endregion

                #region InfoheaderSuperScription
                $hashParameterGroups.Display.InfoHeaderSuperScription = '"' + $hashParameterGroups.Display.InfoHeaderSuperScription.ToString().Replace('"','') + " - Kunde: " + $Input_Customer + '"'
                #endregion

            #endregion

            #region Definition der Quell- und Ziel-Pfade
            if(!(Test-Path $StringWorkingDir))
            {
                $catchOutput = New-Item -Path $StringWorkingDir -ItemType "Directory"
            }
            $scriptfilePath = $StringWorkingDir + $Input_ScriptName + ".ps1"
            #endregion
            #region Erzeugen des Ausgabe-Scripts
            $FullCode1 > $scriptfilePath
            $line_Description >> $scriptfilePath
            $FullCode2 >> $scriptfilePath
            #endregion
            #region Erzeugen und Einfügen der neuen Script-Node
            $xmlScriptNode = $XMLConfigDoc.CreateElement($Input_ScriptName)
            $XMLConfigDoc.SPE_Config.AppendChild($xmlScriptNode) | Out-Null
            $xmlScriptNode.InnerXml = $XMLConfigDoc.SPE_Config.Default.InnerXml
            #endregion
            #region Anpassen der Script-ChildNodes mit den erfassten Parametern
            $xmlScriptNode.Pfade.PathToSharePointDLLs.Wert = $hashParameterGroups.Pfade.PathToSharePointDLLs
            $xmlScriptNode.Pfade.dirLog.Wert = $hashParameterGroups.Pfade.dirLog
            $xmlScriptNode.Logging.LogToConsole.Wert = $hashParameterGroups.Logging.LogToConsole
            $xmlScriptNode.Logging.LogToLogFile.Wert = $hashParameterGroups.Logging.LogToLogFile
            $xmlScriptNode.Logging.LogToULSFile.Wert = $hashParameterGroups.Logging.LogToULSFile
            $xmlScriptNode.Logging.ReportToFile.Wert = $hashParameterGroups.Logging.ReportToFile
            $xmlScriptNode.Logging.ReportToULS.Wert = $hashParameterGroups.Logging.ReportToULS
            $xmlScriptNode.Logging.ActivateTestLogging.Wert = $hashParameterGroups.Logging.ActivateTestLogging
            $xmlScriptNode.Logging.ActivateTestLoggingVerbose.Wert = $hashParameterGroups.Logging.ActivateTestLoggingVerbose
            $xmlScriptNode.Logging.ActivateTestLoggingException.Wert = $hashParameterGroups.Logging.ActivateTestLoggingException
            $xmlScriptNode.Scriptverhalten.TestModus.Wert = $hashParameterGroups.Scriptverhalten.TestModus
            $xmlScriptNode.Scriptverhalten.RunAsAdmin.Wert = $hashParameterGroups.Scriptverhalten.RunAsAdmin
            $xmlScriptNode.Scriptverhalten.DefaultCorrId.Wert = $hashParameterGroups.Scriptverhalten.DefaultCorrId
            $xmlScriptNode.Registry.powershell.Wert = $hashParameterGroups.Registry.powershell
            $xmlScriptNode.Registry.RegRunKey.Wert = $hashParameterGroups.Registry.RegRunKey
            $xmlScriptNode.Registry.restartKey.Wert = $hashParameterGroups.Registry.restartKey
            $xmlScriptNode.ULS.UlsHeader.Wert = $hashParameterGroups.ULS.UlsHeader
            $xmlScriptNode.ULS.maxAgeOfULSFile.Wert = $hashParameterGroups.ULS.maxAgeOfULSFile
            $xmlScriptNode.ULS.maxSizeOfULSFile.Wert = $hashParameterGroups.ULS.maxSizeOfULSFile
            $xmlScriptNode.ULS.maxSizeOfULSDirectory.Wert = $hashParameterGroups.ULS.maxSizeOfULSDirectory
            $xmlScriptNode.Display.UseInfoHeader.Wert = $hashParameterGroups.Display.UseInfoHeader
            $xmlScriptNode.Display.InfoHeaderWidth.Wert = $hashParameterGroups.Display.InfoHeaderWidth
            $xmlScriptNode.Display.InfoHeaderSuperScription.Wert = $hashParameterGroups.Display.InfoHeaderSuperScription
            $xmlScriptNode.Display.InfoHeaderSubScription.Wert = $hashParameterGroups.Display.InfoHeaderSubScription
            $xmlScriptNode.Display.GivenBackGroundColor.Wert = $hashParameterGroups.Display.GivenBackGroundColor
            $xmlScriptNode.Display.InfoHeaderForeGroundColor.Wert = $hashParameterGroups.Display.InfoHeaderForeGroundColor
            $xmlScriptNode.Display.InfoHeaderBackGroundColor.Wert = $hashParameterGroups.Display.InfoHeaderBackGroundColor
            $xmlScriptNode.Display.DisplayForeGroundColor_Normal.Wert = $hashParameterGroups.Display.DisplayForeGroundColor_Normal
            $xmlScriptNode.Display.DisplayForeGroundColor_Error.Wert = $hashParameterGroups.Display.DisplayForeGroundColor_Error
            $xmlScriptNode.Display.DisplayBackGroundColor_Normal.Wert = $hashParameterGroups.Display.DisplayBackGroundColor_Normal
            $xmlScriptNode.Display.DisplayBackGroundColor_Error.Wert = $hashParameterGroups.Display.DisplayBackGroundColor_Error
            $xmlScriptNode.Display.DisplayFrameChar.Wert = $hashParameterGroups.Display.DisplayFrameChar
            #endregion
            #region Schreibe XML-Config-File
            Save-SPEXmlDocumentObjectAsUTF8 -XmlDocumentObject $XMLConfigDoc -Path $SPEVars.ConfigXMLFile
            $XMLConfigDoc = $null
            #endregion
            #region Öffnen des Windows-Explorers
            $ExplorePath = $StringWorkingDir 
            explorer $ExplorePath
            #endregion
            #region Abschliessende Ausgabe
            Show-SPETextLine -text "PowerShell-Script '$($Input_ScriptName + ".ps1")' wurde erfolgreich erstellt und unter '$StringWorkingDir' abgelegt."
            #endregion
        }
        End
        {
            #region Zurückschreiben der ursprünglichen Werte und Parameter
            $global:LogToConsole = $oldValues.LogToConsole;
            $global:LogToLogFile = $oldValues.LogToLogFile;
            $global:LogToULSFile = $oldValues.LogToULSFile;
            $global:ReportToFile = $oldValues.ReportToFile;
            $global:ReportToULS = $oldValues.ReportToULS;
            $global:UseInfoHeader = $oldValues.UseInfoHeader;
            $global:RunAsAdmin = $oldValues.RunAsAdmin;
            $global:ULsHeader = $oldValues.ULsHeader;
            $global:maxAgeOfULSFile = $oldValues.maxAgeOfULSFile;
            $global:maxSizeOfULSFile = $oldValues.maxSizeOfULSFile;
            $global:maxSizeOfULSDirectory = $oldValues.maxSizeOfULSDirectory;
            $global:InfoHeaderWidth = $oldValues.InfoHeaderWidth;
            $global:InfoHeaderSuperScription = $oldValues.InfoHeaderSuperScription;
            $global:InfoHeaderSubScription = $oldValues.InfoHeaderSubScription;
            $global:GivenBackGroundColor = $oldValues.GivenBackGroundColor;
            $global:InfoHeaderForeGroundColor = $oldValues.InfoHeaderForeGroundColor;
            $global:InfoHeaderBackGroundColor = $oldValues.InfoHeaderBackGroundColor;
            $global:DisplayForeGroundColor_Normal = $oldValues.DisplayForeGroundColor_Normal;
            $global:DisplayForeGroundColor_Error = $oldValues.DisplayForeGroundColor_Error;
            $global:DisplayBackGroundColor_Normal = $oldValues.DisplayBackGroundColor_Normal;
            $global:DisplayBackGroundColor_Error = $oldValues.DisplayBackGroundColor_Error;
            $global:DisplayFrameChar = $oldValues.DisplayFrameChar;
            $global:ActivateTestLoggingVerbose = $oldValues.ActivateTestLoggingVerbose;
            $global:ActivateTestLoggingException = $oldValues.ActivateTestLoggingException;
            $global:ActivateTestLogging = $oldValues.ActivateTestLogging;
            $oldValues = $null
            #endregion
            $global:SPEGeneratorActive = $null
            $error
        }
    }
    #endregion
    #EndOfFunction
