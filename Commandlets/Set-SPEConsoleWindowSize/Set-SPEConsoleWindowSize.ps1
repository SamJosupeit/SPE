#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPEConsoleWindowSize.ps1                           #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Set-SPEConsoleWindowSize
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleWindowSize
	{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [int]$width,
            [Parameter(Position=1,Mandatory=$true)]
            [int]$height
        )
        Begin{}
        Process{
		    $size = $Host.UI.RawUI.WindowSize
		    $size.Width = $width
		    $size.Height = $height
		    $Host.UI.RawUI.WindowSize = $size
        }
        End{}
	}
    #endregion
    #EndOfFunction
