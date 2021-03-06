#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Copy-SPESPSubfolderItems.ps1                           #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Copy-SPESPSubfolderItems
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Copy-SPESPSubfolderItems
	{
        [CmdletBinding()]
        param
        (
	        [Microsoft.SharePoint.SPFolder]$sourceFolder,
	        [Microsoft.SharePoint.SPFolder]$targetFolder
        )

        begin {
        }

        process {
			$sourceFolderTitle = $sourceFolder.Name
			$targetFolderTitle = $targetFolder.Name
			if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Kopiere Dateien von Quellordner '$sourceFolderTitle' in Zielordner '$targetFolderTitle'"}
			$sourceWeb = $sourceFolder.ParentWeb
			$targetWeb = $targetFolder.ParentWeb
			$targetFolderFiles = $targetFolder.Files
			
			foreach($sourceFile in $sourceFolder.Files)
			{
				Wait-SPEOnKey
				$global:cntFiles++
				$fileSuccessfullyCopied = $false
				$sourceFileName = $sourceFile.Name
				try{
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "'$global:cntFiles' - Kopiere Datei '$sourceFileName' in Zielordner '$targetFolderTitle'..."}
					$destUrl = $targetFolder.Url + "/" + $sourceFileName
					$binFile = $sourceFile.OpenBinary()
					$targetFile = $targetFolderFiles.Add($destUrl, $binFile, $true)
                    
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Kopieren erfolgreich abgeschlossen."}
                    
					$fileSuccessfullyCopied = $true
                    
				}
				catch
				{
                    if($global:ActivateTestLoggingException)
                    {
		                $exMessage = $_.Exception.Message
		                $innerException = $_.Exception.InnerException
		                $info = "Fehler bei Kopieren des Files '$sourceFileName'"
		                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
					    Wait-SPEOnKey
                    }
				}
				if($fileSuccessfullyCopied){
					Write-SPELogMessage -message "Ãœbertrage Feldwerte..."
					$sourceFields = $sourceFile.Item.Fields | ?{!($_.sealed)}
					foreach($field in $sourceFields)
					{
						$fieldTitle = $field.Title
						try
						{
							Write-SPELogMessage -message "...behandle Feld '$fieldTitle'..."
							if($sourceFile.Properties[$field.Title])
							{
								if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld ist nicht leer..."}
								if(!($targetFile.Properties[$field.Title]))
								{
									if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld existiert nicht auf Zieldatei und wird erstellt..."}
									$newPropCache = $targetFile.AddProperty($field.Title, $sourceFile.Properties[$field.Title])
									if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld wurde erfolgreich erstellt..."}
								} else {
									if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld existiert auf Zieldatei und wird gefÃ¼llt..."}
									$targetFile.Properties[$field.Title] = $sourceFile.Properties[$field.Title]
									if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld erfolgreich gefÃ¼llt..."}
								}
							} else {
								if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld ist leer..."}
							}
						}
						catch
						{
                            if($global:ActivateTestLoggingException)
                            {
				                $exMessage = $_.Exception.Message
				                $innerException = $_.Exception.InnerException
				                $info = "Fehler bei Ãœbertrag des Feldwertes fÃ¼r Feld '$fieldTitle'"
				                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
							    Wait-SPEOnKey
                            }
						}
					}
					$targetFile.Update()
				} else {
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Lfd.Nr '$global:cntFiles' - Fehler bei Kopieren der Datei '$sourceFileName' in Zielordner '$targetFolderTitle'";}
				}
			}
			$targetWeb.Dispose();
			$sourceWeb.Dispose();
		}
    }
	#endregion
    #EndOfFunction
