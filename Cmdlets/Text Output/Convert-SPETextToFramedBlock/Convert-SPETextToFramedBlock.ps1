#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Convert-SPETextToFramedBlock.ps1                       #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Convert-SPETextToFramedBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Convert-SPETextToFramedBlock
    {
        [CmdletBinding()]
        param
        (
                [int]$width,
                [String]$InputText,
                [char]$char
            )

        begin {
        }

        process {
    
            $OutputArray = New-Object System.Collections.ArrayList
        
            $BlockText = Convert-SPEStringToBlock -Content $InputText -Width ($width - 4)

            foreach($line in $BlockText)
            {
                $newLine = $char + " " + $line
                $spaces = $width - $newLine.Length - 1
                for($i=0; $i -le $spaces; $i++)
                {
                    $newLine += " "
                }
                $newLine += $char
                $OutputArray.Add($newLine) | Out-Null
            }
            return $OutputArray
        }
    }
    #endregion
    #EndOfFunction
