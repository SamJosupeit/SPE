#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Out-SPESpeakText.ps1                                   #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Out-SPESpeakText
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Out-SPESpeakText
	{
        [CmdletBinding()]
        param
        ([String]$text)

        begin {
        }

        process {
			$SPVOICE = new-object -com SAPI.SPVOICE;
	   		$SPVOICE.Speak($text)
		}
    }
    #endregion
    #EndOfFunction
