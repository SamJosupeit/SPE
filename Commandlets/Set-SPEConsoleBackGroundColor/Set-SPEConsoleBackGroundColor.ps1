#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPEConsoleBackGroundColor.ps1                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Set-SPEConsoleBackGroundColor
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleBackGroundColor
	{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateSet("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")][string]$color
        )
        Begin{}
        Process{
		    $host.UI.RawUI.BackgroundColor = $color
        }
        End{}
	}
    #endregion
    #EndOfFunction
