#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Write-SPEReportMessage.ps1                             #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Write-SPEReportMessage
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Write-SPEReportMessage
    {
        [CmdletBinding()]
        Param(
            [ValidateSet("Critical","High","Medium","Verbose","VerboseEx")][String[]]$level = "VerboseEx",
            [ValidateSet("ListView","ViewField","ListField","Script","misc","ContentType")][String]$area = "misc",
            [ValidateSet("Added","Removed","Started","Stopped","Aborted","Adding","Removing","Determining")][String]$category,
            [Guid]$CorrelationId = $global:CorrelationID,
            [String]$eventId = "0000",
            [String]$process = "powershell.exe (0x0E44)",
            [String]$thread = "0x05BC",
            [String]$message
        )
        Begin{
		    $dtString = Get-SPECurrentTimeForULS #Abfrage der aktuellen Zeit
            $strCorrelationId = $CorrelationId.Guid
			Get-SPEOrSetReportFiles
        }
        Process{
            if($global:ReportToULS){
                $NewLine = "$dtString	$process	$thread	$area	$category	$eventId	$level	$message	$strCorrelationId"
			    $NewLine >> $PathULSReportfile #Ausgabe des Log-Eintrags in Logfile
            }
            if($global:ReportToFile){
		        $NewLine = $dtString + " " + $Content #Erzeugen des Log-Eintrags
			    $NewLine >> $PathReportfile #Ausgabe des Log-Eintrags in Logfile
            }
        }
        End{}    
    }
    #endregion
    #EndOfFunction
