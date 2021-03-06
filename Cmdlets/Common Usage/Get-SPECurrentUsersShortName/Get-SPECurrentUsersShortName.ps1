#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPECurrentUsersShortName.ps1                       #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPECurrentUsersShortName
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPECurrentUsersShortName {
       [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][int]$Length
        )

        begin {
        }

        process {
            $curUser = Get-SPECurrentUsersNames
            $outStr = ""
            if($gn = $curUser.GivenName -ne ""){
                $gnInitial = $gn.SubString(0,1)
                $outStr += $gnInitial + "."
            }
            $outStr += $curUser.SurName
            if($outStr.Length -le $Length)
            {
                $outStr = $outStr.PadRight($Length)
            } elseif($outStr.Length -gt $Length)
            {
                $outStr = $outStr.SubString(0,$Length)
            }
            return $outStr
        }
    }
    #endregion
    #EndOfFunction
