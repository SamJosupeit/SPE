#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        New-SPEReportFiles.ps1                                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function New-SPEReportFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function New-SPEReportFiles
    {
        [CmdletBinding()]
        Param(
			[Switch]$RecreateULS
        )
        Begin{
            $StringDateTime = Get-Date -Format yyyyMMdd-HHmm
        }
        Process{
            if($global:ReportToFile -and !$RecreateULS -and !$ReportFileCreated){
                $global:PathReportFile = $dirRep + "Report_" + $ScriptName + "_" + $StringDateTime + ".report" # Pfad zur Report-Text-Datei
                #region Header für Logfile
                    $ReportlineBreaker = "###############################################"
                    $ReportlineFile = "# Report für Script " + $ScriptName + ".ps1"
                    $ReportlineDate = "# erstellt am: " + $StringDateTime
                #endregion
                #region Header in Reportfile schreiben
                    $ReportlineBreaker > $PathReportfile
                    $ReportlineFile >> $PathReportfile
                    $ReportlineDate >> $PathReportfile
                    $ReportlineBreaker >> $PathReportfile
		        #endregion
				$global:ReportFileCreated = $true
             }
            if($global:ReportToULS){
	            $global:PathULSReportFile = $dirRep + $computerName + "-" + $StringDateTime + ".log" # Pfad zur ULS-Datei
	            if(!(Test-Path -Path $global:PathULSReportfile)){
	                $ULSHeader > $PathULSReportfile
	            }
            }
        }
    }
    #endregion
    #EndOfFunction
