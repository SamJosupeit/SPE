#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Wait-SPELoop.ps1                                       #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Wait-SPELoop
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Wait-SPELoop
	{
	    [CmdletBinding()]
	    param
	    (
	        [Int]$time, 
	        [String[]]$text
	    )

	    begin {
	    }

	    process {
	        for($i = $time; $i -ge 0; $i--){
	            Show-SPETextArray -textArray (
	            $text,
	            " $i seconds to go."
	            )
	            Start-Sleep -Seconds 1
	        }
	    }
	}
    #endregion
    #EndOfFunction
