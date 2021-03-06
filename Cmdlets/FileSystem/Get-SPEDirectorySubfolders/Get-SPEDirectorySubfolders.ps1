#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEDirectorySubfolders.ps1                         #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Get-SPEDirectorySubfolders
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Get-SPEDirectorySubfolders
	{
        [CmdletBinding()]
        param
        ([System.IO.DirectoryInfo]$folder)

        begin {
			$folderPath = $folder.fullname
        }

        process {
			$folders = Get-ChildItem $folderPath | ?{$_.Attributes -match "Directory"}
			if($folders -ne $null)
			{
				return $folders
			}
			else
			{
				return $null
			}
		}
    }
    #endregion
    #EndOfFunction
