#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPEConsoleBufferSize.ps1                           #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Set-SPEConsoleBufferSize
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleBufferSize
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
		    $buffer = $Host.UI.RawUI.BufferSize
		    $buffer.Width = $width
		    $buffer.Height = $height
		    $Host.UI.RawUI.BufferSize = $buffer
        }
        End{}
	}
    #endregion
    #EndOfFunction
