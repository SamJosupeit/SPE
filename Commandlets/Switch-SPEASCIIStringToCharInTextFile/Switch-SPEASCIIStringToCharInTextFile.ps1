#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Switch-SPEASCIIStringToCharInTextFile.ps1              #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Switch-SPEASCIIStringToCharInTextFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Switch-SPEASCIIStringToCharInTextFile {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [String]
            $Path,
            [Parameter(Position=1, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [System.Collections.ArrayList]
            $filterArrayList
        )

        begin {
        }

        process {
            if(get-item $Path)
            {
                $newFileLines = new-Object System.Collections.ArrayList
                $sr = New-Object System.IO.StreamReader $Path
                $lineCnt = 0
                while(!$sr.EndOfStream)
                {
                    $lineCnt++
                    $line = $sr.ReadLine()
                    $oldLine = $line
                    $writeNewLine = $false
                    if($line -ne "" -and $line -ne $null)
                    {
                        $writeNewLine = $true
                        $message = "Zeile :$lineCnt, "
                        foreach($filterPair in $filterArrayList){
                            $src = $filterPair.First
                            $trg = $filterPair.Second
                            $line = $line.Replace($src, $trg)
                        }
                        $newLine = $line
                    }
                    $newFileLines.Add($newline) | Out-Null
                }
                $sr.Close()
                foreach($line in $newFileLines)
                {
                    $line >> $Path
                }
            } else {
                if($global:ActivateTestLoggingException){Write-SPELogMessage -message "Fehler in Function 'Switch-SPEASCIIStringToCharInTextFile': Source-File konnte unter Pfad '$sourcePath' nicht gefunden werden."}
            }
        }

        end{
        }
    }
    #endregion
    #EndOfFunction
