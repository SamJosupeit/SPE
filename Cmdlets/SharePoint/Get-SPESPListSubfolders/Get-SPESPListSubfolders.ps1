#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPESPListSubfolders.ps1                            #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Get-SPESPListSubfolders
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Get-SPESPListSubfolders
	{
        [CmdletBinding()]
        param
        ([Microsoft.SharePoint.SPFolder]$folder)

        begin {
        }

        process {
			$subFolders = $null
			if($folder.Subfolders.Count -gt 0)
			{
				$subFolders = $folder.SubFolders
			}
			return $subFolders
		}
    }
	#endregion
    #EndOfFunction
