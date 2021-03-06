#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Show-SPETextLine.ps1                                   #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Show-SPETextLine
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Show-SPETextLine
    {
        [CmdletBinding()]
        param
        (
            [String]$text,
            [String]$fgColor = $global:DisplayForeGroundColor_Normal,
            [String]$bgColor = $global:DisplayBackGroundColor_Normal
        )

        begin {
        }

        process {
            Show-SPEInfoHeader
            foreach($line in (Convert-SPETextToFramedBlock -Width $global:InfoHeaderWidth -InputText $text -char $global:DisplayFrameChar))
            {
                Write-Host $line -ForegroundColor $fgColor
            }
        }
    }
    #endregion
    #EndOfFunction    
