#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Select-SPEYN.ps1                                       #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Select-SPEYN
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Select-SPEYN
	{
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
		    $Ask = ""
		    $Ask = Use-SPEChoice "Y,N"
		    switch ($Ask){
			    "Y" {return $true}
			    "N" {return $false}
		    }
	    }
    }
    #endregion
    #EndOfFunction
