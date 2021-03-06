#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Step-SPEThroughDirectorySubFolders.ps1                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Step-SPEThroughDirectorySubFolders
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	Function Step-SPEThroughDirectorySubFolders
	{
		[CmdletBinding()]
		Param(
			[System.IO.DirectoryInfo]$directoryFolder,
			[Microsoft.SharePoint.SPFolder]$targetSPFolder
		)
		Begin{
			$directoryFolderPath = $directoryFolder.FullName
			#$folderRelativePath = $folderpath.Replace($directoryRoot,"")
		}
		Process{
			#region Copy current files from current directory
			$files = Get-SPEDirectoryFiles -folder $directoryFolder
			if($files)
			{
				$resultBasetype = Get-SPEBaseTypeNameFromObject -object $files
				switch($resultBasetype)
				{
					# variable $files contains multiple Items
					"Array"{	
						foreach($file in $files)
						{
							Copy-SPEFileFromDirectoryToSPFolder -sourceFile $file -directoryFolder $directoryFolder -targetSPFolder $targetSPFolder
						}
						break
					}
					# variable $files contains one single Item
					"FileSystemInfo"{ 
						$file = $files
						Copy-SPEFileFromDirectoryToSPFolder -sourceFile $file -directoryFolder $directoryFolder -targetSPFolder $targetSPFolder
						break
					}
					# something else resulting from an error
					"Default"{
						if($global:ActivateTestLoggingException){Write-SPELogMessage -message "An error occured at determination of files from folder '$directoryFolderPath'."}
						break
					}
				}
			}
			#endregion
				
			#region Iterating subfolders
			$directorySubFolders = Get-SPEDirectorySubfolders -folder $directoryFolder
				
			if($directorySubFolders)
			{
				$resultBasetype = Get-SPEBaseTypeNameFromObject -object $directorySubFolders
				switch($resultBasetype)
				{
					# variable $subFolders contains multiple Items
					"Array"{
						foreach($directorySubFolder in $directorySubFolders)
						{
							$subFolderName = $directorySubFolder.FullName.Split("\")[-1]
							if(($newSPFolder = Test-SPEAndSetSPFolder -subFolderName $subFolderName -parentSPFolder $targetSPFolder) -ne $null)
							{
								# Going one level deeper
								Step-SPEThroughDirectorySubFolders -directoryFolder $directorySubFolder -targetSPFolder $newSPFolder
							}
							else
							{
								if($global:ActivateTestLoggingException){Write-SPELogMessage -message "Error at determing subfolder '$subFolderName'. Skipping this Folder."}
							}
						}
						break
					}
					# variable $subFolders contains one single Item
					"FileSystemInfo"{ 
						$directorySubFolder = $directorySubFolders
						$subFolderName = $directorySubFolder.FullName.Split("\")[-1]
						if(($newSPFolder = Test-SPEAndSetSPFolder -subFolderName $subFolderName -parentSPFolder $targetSPFolder) -ne $null)
						{
							# Going one level deeper
							Step-SPEThroughDirectorySubFolders -directoryFolder $directorySubFolder -targetSPFolder $newSPFolder
						} else {
							if($global:ActivateTestLoggingException){Write-SPELogMessage -message "Error at determing subfolder '$subFolderName'. Skipping this Folder."}
						}
						break
					}
					# something else resulting from an error
					"Default"{
						if($global:ActivateTestLoggingException){Write-SPELogMessage -message "An error occured at determination of subfolders from folder '$directoryFolderPath'."}
						break
					}
				}
			}
			#endregion
		}
	}
	#endregion
    #EndOfFunction
