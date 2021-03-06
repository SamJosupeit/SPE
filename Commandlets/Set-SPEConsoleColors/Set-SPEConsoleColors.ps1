#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPEConsoleColors.ps1                               #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Set-SPEConsoleColors
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleColors
	{
       [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateSet("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")][string]$fore,
            [Parameter(Position=1,Mandatory=$true)]
            [ValidateSet("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")][string]$back
        )
        Begin{}
        Process{
		    Set-SPEConsoleForeGroundColor -color $fore
		    Set-SPEConsoleBackGroundColor -color $back
        }
        End{}
	}
    #endregion
    #EndOfFunction
