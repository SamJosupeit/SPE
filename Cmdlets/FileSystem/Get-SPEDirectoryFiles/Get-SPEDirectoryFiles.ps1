#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEDirectoryFiles.ps1                              #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Get-SPEDirectoryFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Get-SPEDirectoryFiles
	{
        [CmdletBinding()]
        param
        (
			[System.IO.DirectoryInfo]$folder
		)

        begin {
			$folderPath = $folder.FullName
        }

        process {
			$files = Get-ChildItem $folderPath | ?{$_.Attributes -notmatch "Directory"}
			if($files -ne $null)
			{
				return $files
			}
			else
			{
				return $null
			}
    	}
    }
    #endregion
    #EndOfFunction
