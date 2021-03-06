#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPECurrentTimeForULS.ps1                           #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPECurrentTimeForULS
    #.ExternalHelp SPE.Common.psm1-help.xml
 	function Get-SPECurrentTimeForULS 
    {
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
		    $dt = "{0:MM'/'dd'/'yyyy' 'HH':'mm':'ss'.'ff}" -f (Get-Date) # Amerikanisches Format
		    return $dt #Ausgabe des Strings
	    }
    }
    #endregion
    #EndOfFunction       
