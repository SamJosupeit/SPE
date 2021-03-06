#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Edit-SPETextFileByFilterToNewFile.ps1                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Edit-SPETextFileByFilterToNewFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Edit-SPETextFileByFilterToNewFile 
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [String]
            $sourcePath,
            [Parameter(Position=1, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [String]
            $targetPath,
            [Parameter(Position=2, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [Array]
            $filterStringArray,
            [Parameter(Position=3, Mandatory=$false)]
            [Switch]
            $returnNewFile
        )

        begin {
        }

        process {
            if(get-item $sourcePath)
            {
                $sr = New-Object System.IO.StreamReader $sourcePath
                while(!$sr.EndOfStream)
                {
                    $line = $sr.ReadLine()
                    $lineContainsFilter = $false
                    if($line -ne "" -and $line -ne $null)
                    {
                        foreach($filterString in $filterStringArray)
                        {
                            if($line.Contains($filterString))
                            {
                                $lineContainsFilter = $true
                            }
                        }
                    }
                    if(!$lineContainsFilter)
                    {
                        $line >> $targetPath
                    }
                }
                if($returnNewFile)
                {
                    $newfile = get-item $targetPath
                    return $newfile
                }
            } else {
                if($global:ActivateTestLoggingException){Write-SPELogMessage -message "Fehler in Function 'Edit-SPETextFileByFilterToNewFile': Source-File konnte unter Pfad '$sourcePath' nicht gefunden werden."}
                if($returnNewFile)
                {
                    return $null
                }
            }
        }

        end{
        }
    }
    #endregion
    #EndOfFunction
