#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Convert-SPEDiffTimeToString.ps1                        #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Convert-SPEDiffTimeToString
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Convert-SPEDiffTimeToString
	{
        [CmdletBinding()]
        param
        ([TimeSpan]$difftime)

        begin {
        }

        process {
			$str = "{0:c}" -f $difftime
			return $str
		}
    }
    #endregion
    #EndOfFunction
