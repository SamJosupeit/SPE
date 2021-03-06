#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Select-SPETF.ps1                                       #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Select-SPETF
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Select-SPETF
	{
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
		    $Ask = ""
		    $Ask = Use-SPEChoice "true,false"
		    switch ($Ask){
			    "true" {return $true}
			    "false" {return $false}
		    }
	    }
    }
    #endregion
    #EndOfFunction
