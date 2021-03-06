#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Limit-SPEDirectorySize.ps1                             #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Limit-SPEDirectorySize
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Limit-SPEDirectorySize
	{
		[CmdletBinding()]
		Param(
			[String]$dirPath
		)
		Begin{}
		Process{
			[System.IO.DirectoryInfo]$dir = Get-Item $dirPath
			$dirSize = 0
			$dir.GetFiles() | %{$dirSize += $_.Length}
			if($dirSize -gt $global:maxSizeOfULSDirectory)
			{
				$oldestFile = gci $dirPath | Sort LastWriteTime | select -First 1
				Remove-Item -Path $($oldestFile.FullName) -Force
			}
		}
		End{}
	}
    #endregion
    #EndOfFunction
