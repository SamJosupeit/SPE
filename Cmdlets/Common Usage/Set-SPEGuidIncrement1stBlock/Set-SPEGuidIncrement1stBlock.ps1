#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPEGuidIncrement1stBlock.ps1                       #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Set-SPEGuidIncrement1stBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Set-SPEGuidIncrement1stBlock
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
            $guidString = $guid.Guid
            $guidArray = $guidString.Split('-')
            $guid1 = $guidArray[0]
            $guid2 = $guidArray[1]
            $guid3 = $guidArray[2]
            $guid4 = $guidArray[3]
            $guid5 = $guidArray[4]
            $guid1Int = [Convert]::ToInt64($guid1, 16)
            $guid1Int++
            $guid1 = $guid1Int.ToString("X" + 8)
            if($guid1.Length -gt 8){
                $guid1 = $guid1.TrimStart("1")
            }
            return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
        }
    }
    #endregion
    #EndOfFunction
