#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Convert-SPEStringToBlock.ps1                           #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Convert-SPEStringToBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Convert-SPEStringToBlock
    {
        [CmdletBinding()]
        param
        (
            [string]$Content,
            [int]$Width
        )

        begin {
        }

        process {
            $line = ""
            $WordCounter = 0
            $wordCounterLastLine = 0
            $lines = New-Object System.Collections.ArrayList
            $FullTextLength = $Content.Length
            $LengthRestText = $FullTextLength
            $Input_Words = $Content.Split(" ")
            $Count_Words = $Input_Words.Count
            foreach($word in $Input_Words){
                $WordCounter++
                if($width -le $FullTextLength) #$LengthRestText)
                {
                    if($WordCounter -eq 1)
                    {
                        $line = $word #schreibe erstes Wort
                        $LengthRestText = $LengthRestText - $word.Length
                        $Count_Words--
                    }
                    else
                    {
                        if(($line.Length + $word.Length + 1) -lt $width){
                            $line = $line + " " + $word
                            $Count_Words--
                            $LengthRestText = $LengthRestText - $word.Length
                        }
                        else
                        {
                            $lines.Add($line) | Out-Null
                            $line = $word
                            $Count_Words--
                            $LengthRestText = $LengthRestText - $word.Length
                        }
                    }
                }
                else
                {
                    $wordCounterLastLine++
                    if($wordCounterLastLine -eq 1)
                    {
                        if($line -ne ""){
                            $lines.Add($line) | Out-Null
                        }
                        $line = $word #schreibe erstes Wort
                        $Count_Words--
                    }
                    else
                    {
                        if($Count_Words -gt 0)
                        {
                            $line = $line + " " + $word
                            $Count_Words--
                        }
                    }
                }
            }
            $lines.Add($line) | Out-Null
            return $lines
        }
    }
    #endregion
    #EndOfFunction
