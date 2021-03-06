#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        New-SPEInfoHeader.ps1                                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function New-SPEInfoHeader
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function New-SPEInfoHeader
    {
        [CmdletBinding()]
        param
        (
            [String]$SuperScription = $global:InfoHeaderSuperScription,
            [String]$SubScription = $global:InfoHeaderSubScription,
            [String]$Width = $global:InfoHeaderWidth,
            [Char]$Char = $global:DisplayFrameChar
        )

        begin {
            if($global:SPEGeneratorActive)
            {
                $SubScription = $global:SPEvars.InfoHeaderSubScription
            }
        }

        process {
            #Creating Edge-Line
            $separatorFilled = ""
            for($i = 0; $i -le $Width; $i++){
                $separatorFilled += $Char
            }
            #Creating empty Edge-Line
            $separatorEmpty = $Char
            for($i = 2; $i -le $Width; $i++){
                $separatorEmpty += " "
            }
            $separatorEmpty += $Char
            #Creating outputArray
            $outputArray = New-Object System.Collections.ArrayList
            $outputArray.Add($separatorFilled) | Out-Null
            $outputArray.Add($separatorEmpty) | Out-Null
            $ArraySuperScription = Convert-SPETextToFramedBlock -Width $Width -InputText $SuperScription -char $Char
            foreach($StringSuperScription in $ArraySuperScription)
            {
                $outputArray.Add($StringSuperScription) | Out-Null
            }
            $outputArray.Add($separatorEmpty) | Out-Null
            $outputArray.Add($separatorFilled) | Out-Null
            $outputArray.Add($separatorEmpty) | Out-Null
            $ArraySubScription = Convert-SPETextToFramedBlock -Width $Width -InputText $SubScription -char $Char
            foreach($StringSubScription in $ArraySubScription)
            {
                $outputArray.Add($StringSubScription) | Out-Null
            }
            $outputArray.Add($separatorEmpty) | Out-Null
            $outputArray.Add($separatorFilled) | Out-Null
            $startTimeString = $global:starttime.ToString()
            $CurrentTime = Get-Date
            $CurrentTimeString = $CurrentTime.ToString()
            $CurrentDiffTime = $CurrentTime - $global:starttime
            $CurrentDiffTimeString = "{0:c}" -f $CurrentDiffTime
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText "Start  : $startTimeString" -Width $Width -char $Char)) | Out-Null
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText "Aktuell: $CurrentTimeString" -Width $Width -char $Char)) | Out-Null
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText "Dauer  : $CurrentDiffTimeString" -Width $Width -char $Char)) | Out-Null
            return $outputArray
        }
    }
    #endregion
    #EndOfFunction	    
