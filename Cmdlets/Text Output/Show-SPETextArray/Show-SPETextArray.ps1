#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Show-SPETextArray.ps1                                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Show-SPETextArray
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Show-SPETextArray
    {
        [CmdletBinding()]
        param
        ([String[]]$textArray)

        begin {
        }

        process {
            Show-SPEInfoHeader
            foreach($block in $textArray)
            {
                foreach($line in (Convert-SPETextToFramedBlock -Width $global:InfoHeaderWidth -InputText $block -char $global:DisplayFrameChar))
                {
                    Write-Host $line -ForegroundColor $global:DisplayForeGroundColor_Normal
                }
            }
        }
        end{}
    }
    #endregion
    #EndOfFunction    
