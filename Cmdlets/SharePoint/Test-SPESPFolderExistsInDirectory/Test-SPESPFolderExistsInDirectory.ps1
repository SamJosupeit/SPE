#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPESPFolderExistsInDirectory.ps1                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Test-SPESPFolderExistsInDirectory
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	Function Test-SPESPFolderExistsInDirectory
	{
		[CmdletBinding()]
		Param(
			[Microsoft.SharePoint.SPFolder]$SPFolder,
			[String]$directoryRoot
		)
		Begin{
			$relativeFolderPath = $spFolder.ServerRelativeUrl.TrimStart("/")
			$relativeFolderPath = $relativeFolderPath.Replace($dsTargetListName,"")
			if($dsTargetFolderListRelativePath -ne "/")
			{
				$relativeFolderPath = $relativeFolderPath.Replace($dsTargetFolderListRelativePath,"")
			}
			$relativeFolderPath = $relativeFolderPath.Replace("/","\")
			$fullFolderPath = $dsSourceFolder + $relativeFolderPath
		}
		Process{
			if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Determining if Folder '$fullFolderPath' exists in Directory"}
			$folderExists = $false
			if((Test-Path -Path $fullFolderPath))
			{
				$folderExists = $true
			}
			return $folderExists
		}
	}
	#endregion
    #EndOfFunction
