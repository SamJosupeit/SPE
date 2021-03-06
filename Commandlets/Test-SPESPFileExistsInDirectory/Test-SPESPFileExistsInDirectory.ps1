#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPESPFileExistsInDirectory.ps1                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Test-SPESPFileExistsInDirectory
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	Function Test-SPESPFileExistsInDirectory
	{
		[CmdletBinding()]
		Param(
			[Microsoft.SharePoint.SPFile]$SPFile,
			[String]$directoryRoot
		)
		Begin{
			$relativeFilePath = $spFile.ServerRelativeUrl.TrimStart("/")
			$relativeFilePath = $relativeFilePath.Replace($dsTargetListName,"")
			if($dsTargetFolderListRelativePath -ne "/")
			{
				$relativeFilePath = $relativeFilePath.Replace($dsTargetFolderListRelativePath,"")
			}
			$relativeFilePath = $relativeFilePath.Replace("/","\")
			$fullFilePath = $dsSourceFolder + $relativeFilePath
		}
		Process{
			$fileExists = $false
			if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Determining if File '$fullFilePath' exists in directory..."}
			if((Test-Path -Path $fullFilePath))
			{
				$fileExists = $true
			}
			return $fileExists
		}
	}
	#endregion
    #EndOfFunction
