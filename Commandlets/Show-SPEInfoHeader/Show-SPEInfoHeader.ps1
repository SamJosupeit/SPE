#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Show-SPEInfoHeader.ps1                                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Show-SPEInfoHeader
    #.ExternalHelp SPE.Common.psm1-help.xml
   	Function Show-SPEInfoHeader
    {
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            if(!$UseInfoHeader){return}
            clear
            $ArrayHeader = New-SPEInfoHeader
            foreach($line in $ArrayHeader)
            {
                Write-Host $line -ForegroundColor $global:InfoHeaderForeGroundColor -BackgroundColor $global:InfoHeaderBackGroundColor
            }
        }
        end{}
    }
    #endregion
    #EndOfFunction
