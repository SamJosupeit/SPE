#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Copy-SPEFileFromDirectoryToSPFolder.ps1                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Copy-SPEFileFromDirectoryToSPFolder
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	Function Copy-SPEFileFromDirectoryToSPFolder
	{
		[CmdletBinding()]
		Param(
			[System.IO.FileInfo]$sourceFile,
			[System.IO.DirectoryInfo]$directoryFolder,
			[Microsoft.SharePoint.SPFolder]$targetSPFolder
		)
		Begin{
		}
		Process{
			$fileName = $sourceFile.Name
			$filePath = $sourceFile.FullName
			$SPFolderUrl = $targetSPFolder.Url
			$dirPath = $directoryFolder.FullName
			$fileLastWriteTimeUTC = $sourceFile.LastWriteTimeUTC
			try{
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Found file '$filePath' in directory '$dirPath'."}
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Determing if file already exists in Library-Folder '$SPFolderUrl'..."}
				$doCopy = $true
				$doUpdate = $false
				if( ($spFile = $targetSPFolder.Files[$fileName]) -ne $null)
				{
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "File exists. Comparing 'Last Modification TimeStamps'..."}
					# file exists. check for lastmodified-property
					$spFileLastModified = $spFile.TimeLastModified
					if($spFileLastModified -gt $fileLastWriteTimeUTC)
					{
					    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Corresponding file to '$filePath' in SPFolder '$SPFolderUrl' is newer than the sourcefile."}
						if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Skipping copying the sourcefile."}
						$doCopy = $false
					} else {
						$doUpdate = $true
					}
				}
				if($doCopy){
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Copying file '$filePath' from directory '$dirPath' to SPFolder '$SPFolderUrl'..."}
					$fileStream = $sourceFile.OpenRead()
					[Microsoft.SharePoint.SPFile]$spFile = $targetSPFolder.Files.Add($SPFolderUrl + "/" + $fileName, $fileStream, $true)
					$fileStream.Close()
					if($doUpdate)
					{
						if($global:ActivateTestLoggingVerbose){Write-SPEReportMessage -message "Updated file '$filePath' from directory '$dirPath' to SPFolder '$SPFolderUrl'..."}
					}
					else
					{
						if($global:ActivateTestLoggingVerbose){Write-SPEReportMessage -message "Copied file '$filePath' from directory '$dirPath' to SPFolder '$SPFolderUrl'..."}
					}
				}
			}
			catch
	        {
                if($global:ActivateTestLoggingException)
                {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Error at copying file '$filePath' from directory '$dirPath' to SPFolder '$SPFolderUrl'"
	                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                }
	        }
		}
	}
	#endregion
    #EndOfFunction
