#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Wait-SPEOnKey.ps1                                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Wait-SPEOnKey
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Wait-SPEOnKey
	{
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
			if ($host.ui.RawUI.KeyAvailable -and $host.UI.RawUI.ReadKey().Character -eq ' ') {
				Wait-SPEForKey
	 		}
	 		sleep -m 50 # give me chance to press the key ;)
		}
    }
    #endregion
    #EndOfFunction
