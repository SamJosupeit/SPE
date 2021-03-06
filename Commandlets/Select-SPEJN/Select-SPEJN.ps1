#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Select-SPEJN.ps1                                       #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Select-SPEJN
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Select-SPEJN
	{
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
		    $Ask = ""
		    $Ask = Use-SPEChoice "J,N"
		    switch ($Ask){
			    "J" {return $true}
			    "N" {return $false}
		    }
	    }
    }
    #endregion
    #EndOfFunction
