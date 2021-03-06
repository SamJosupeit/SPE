#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPEConsoleTitle.ps1                                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Set-SPEConsoleTitle
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleTitle
	{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [string]$newTitle
        )
        Begin{}
        Process{
		    $oldTitle = $Host.UI.RawUI.WindowTitle
		    $Host.UI.RawUI.WindowTitle = $newTitle
		    return $oldTitle
        }
        End{}
	}
    #endregion
    #EndOfFunction
