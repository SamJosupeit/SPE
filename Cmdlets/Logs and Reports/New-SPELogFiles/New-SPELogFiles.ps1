#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        New-SPELogFiles.ps1                                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function New-SPELogFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function New-SPELogFiles
    {
        [CmdletBinding()]
        Param(
			[Switch]$RecreateULS
        )
        Begin{
            $StringDateTime = Get-Date -Format yyyyMMdd-HHmm
        }
        Process{
            if($global:LogToLogFile -and !$RecreateULS -and !$LogFileCreated){
                $global:PathLogFile = $dirLog + "Log_" + $ScriptName + "_" + $StringDateTime + ".log" # Pfad zur Log-Text-Datei
                #region Header fÃ¼r Logfile
                    $LoglineBreaker = "###############################################"
                    $LoglineFile = "# Logfile - " + $ScriptName + ".ps1"
                    $LoglineDate = "# erstellt: " + $StringDateTime
                #endregion
                #region Header in Logfile schreiben
                    $LoglineBreaker > $PathLogfile
                    $LoglineFile >> $PathLogfile
                    $LoglineDate >> $PathLogfile
                    $LoglineBreaker >> $PathLogfile
                #endregion
				$global:LogFileCreated = $true
            }
            if($global:LogToULSFile){
                $global:PathULSLogFile = $dirLog + $computerName + "-" + $StringDateTime + ".log" # Pfad zur ULS-Log-Datei
                if(!(Test-Path -Path $global:PathULSLogFile)){
                    $ULSHeader > $PathULSLogfile
                }
             }
        }
    }
    #endregion
    #EndOfFunction
