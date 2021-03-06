#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPEVariable.ps1                                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Set-SPEVariable
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Set-SPEVariable {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [System.String]$VariableName,

            [Parameter(Position=1,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [System.String]$CommandString
        )

        begin {
        }

        process {
            $commandBlock = "Set-Variable -Name $VariableName -Value ($CommandString) -Scope Global"
            iex $commandBlock # invoke-Expression
            $CommandBlock = $null
        }
    }
    #endregion
    #EndOfFunction
