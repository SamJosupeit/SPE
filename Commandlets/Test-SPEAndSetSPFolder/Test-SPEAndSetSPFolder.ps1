#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPEAndSetSPFolder.ps1                             #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Test-SPEAndSetSPFolder
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	Function Test-SPEAndSetSPFolder
	{
		[CmdletBinding()]
		Param(
			[String]$subFolderName,
			[Microsoft.SharePoint.SPFolder]$parentSPFolder
		)
		Begin{
		}
		Process{
			$newSPFolder = $null
			try
			{
				#$subFolderName = $directorySubFolder.Name
				Write-SPELogMessage -message "Testing for Subfolder '$subFolderName'..."
				if(($newSPFolder = $targetSPFolder.SubFolders[$subFolderName]) -eq $null){
					Write-SPELogMessage -message "...Folder does not exist and will be created."
					$newSPFolder = $targetSPFolder.SubFolders.Add($subFolderName)
					$newSPFolderURL = $newSPFolder.ServerRelativeUrl
					Write-SPEReportMessage -message "Created SPFolder '$newSPFolderURL'"
				} else {
					Write-SPELogMessage -message "...Folder exists an will be used."
				}
			}
	        catch
	        {
                if($global:ActivateTestLoggingException)
                {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Error at Testing for SPFolder '$subFolderName'."
	                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                }
	        }
			return $newSPFolder
				
		}
	}
	#endregion
    #EndOfFunction
