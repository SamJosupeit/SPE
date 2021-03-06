#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Copy-SPESPFolderProperties.ps1                         #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Copy-SPESPFolderProperties
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Copy-SPESPFolderProperties
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
			Wait-SPEOnKey
			if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Ãœbertrage Feldwerte..."}
			$sourceFields = $sourceFolder.Item.Fields | ?{!($_.sealed)}
			foreach($field in $sourceFields)
			{
				$fieldTitle = $field.Title
				try
				{
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...behandle Feld '$fieldTitle'..."}
					if($sourceFolder.Properties[$field.Title])
					{
						if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld ist nicht leer..."}
						if(!($targetFolder.Properties[$field.Title]))
						{
							if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld existiert nicht auf Zielordner und wird erstellt..."}
							$newPropCache = $targetFolder.AddProperty($field.Title, $sourceFolder.Properties[$field.Title])
							if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld wurde erfolgreich erstellt..."}
						} else {
							if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld existiert auf Zielordner und wird gefÃ¼llt..."}
							$targetFolder.Properties[$field.Title] = $sourceFolder.Properties[$field.Title]
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
					    if($exMessage -match "System.ArgumentException: Item has already been added. Key in dictionary")
                        {
				            $info = "Wert fÃ¼r Feld '$fieldTitle' scheint schon gesetzt zu sein. FÃ¼re Update aus."
				            Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
						    $targetFolder.Properties[$field.Title] = $sourceFolder.Properties[$field.Title]
					    } else {
			                $info = "Fehler bei Ãœbertrag des Feldwertes fÃ¼r Feld '$fieldTitle'"
			                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
					        Wait-SPEOnKey
					    }
                    }
				}
			}
		}
    }
	#endregion
    #EndOfFunction
