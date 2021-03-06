#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Show-SPEQuestion.ps1                                   #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Show-SPEQuestion
    #.ExternalHelp SPE.Common.psm1-help.xml
   	Function Show-SPEQuestion
    {
        [CmdletBinding()]
        param
        ([String]$text)

        begin {
        }

        process {
            Show-SPEInfoHeader
            foreach($line in (Convert-SPETextToFramedBlock -Width $global:InfoHeaderWidth -InputText $text -char $global:DisplayFrameChar))
            {
                Write-Host $line -ForegroundColor $global:DisplayForeGroundColor_Normal
            }
            $antwort = Read-Host
            return $antwort
        }
    }
    #endregion
    #EndOfFunction    
