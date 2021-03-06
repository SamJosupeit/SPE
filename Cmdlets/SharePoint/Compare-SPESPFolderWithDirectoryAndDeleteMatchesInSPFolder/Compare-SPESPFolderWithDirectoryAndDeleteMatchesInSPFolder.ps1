#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:                                                               # # Compare-SPESPFolderWithDirectoryAndDeleteMatchesInSPFolder.ps1      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Compare-SPESPFolderWithDirectoryAndDeleteMatchesInSPFolder
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Compare-SPESPFolderWithDirectoryAndDeleteMatchesInSPFolder
	{
        [CmdletBinding()]
        param
        (
			[Microsoft.SharePoint.SPFolder]$sourceFolder,
			[String]$directoryRoot
		)

        begin {
			$folderRelativeUrl = $sourceFolder.ServerRelativeUrl
        }

        process {
			if(!($sourceFolder.ServerRelativeUrl -match "/Forms"))
			{
				if($sourceFolder.Files.Count -gt 0)
				{
					$filesToDelete = New-Object System.Collections.ArrayList
					$files = $sourceFolder.Files
					foreach($file in $files)
					{
						$fileName = $file.name
						if($global:ActivateTestLoggingVerbose){Write-Host "filename to delete is $filename"}
						if(!(Test-SPESPFileExistsInDirectory -SPFile $file -directoryRoot $directoryRoot))
						{
							$fileName = $file.Name
							if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Collecting file '$fileName' for Deletion"}
							$filesToDelete.Add($file)
						}
					}
					if($filesToDelete.Count -gt 0)
					{
						foreach($file in $filesToDelete)
						{
							$fileName = $file.Name
							if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Deleting file '$fileName'..."}
							$sourceFolder.Files.Delete($file)
							if($global:ActivateTestLoggingVerbose){Write-SPEReportMessage -message "Deleted file '$fileName' from SPFolder '$folderRelativeUrl'"}
						}
					}
				}
				if($sourceFolder.SubFolders.Count -gt 0)
				{
					foreach($subFolder in $sourceFolder.SubFolders)
					{
						$subfolderSRU = $subFolder.ServerRelativeUrl
						Compare-SPESPFolderWithDirectoryAndDeleteMatchesInSPFolder -sourceFolder $subFolder -directoryRoot $directoryRoot
					}
				}
				if(!(Test-SPESPFolderExistsInDirectory -SPFolder $sourceFolder -directoryRoot $directoryRoot) -and ($sourceFolder.files -eq $null))
				{
					$folderName = $sourceFolder.Name
					$folderUrl = $sourceFolder.ServerRelativeUrl
					if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Folder '$folderName' does not exist in Directory and will now be deleted in Library."}
					$parentFolder = $sourceFolder.ParentFolder
					$parentFolder.SubFolders.Delete($sourceFolder)
					if($global:ActivateTestLoggingVerbose){Write-SPEReportMessage -message "Deleted SPFolder '$folderUrl'."}
				}
			} else {
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Current Folder is FORMS-Folder"}
			}
		}
    }
	#endregion
    #EndOfFunction
