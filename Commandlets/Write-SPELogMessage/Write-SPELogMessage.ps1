#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Write-SPELogMessage.ps1                                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Write-SPELogMessage
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Write-SPELogMessage
    {
        [CmdletBinding()]
        param
        (
            [ValidateSet("Critical","High","Medium","Verbose","VerboseEx","Unexpected")][String]$level = "VerboseEx",
            [ValidateSet("ListView","ViewField","ListField","Script","WebSite","SiteCollection","List","ListItem","misc","other")][String]$area = "Script",
            [ValidateSet("Added","Removed","Started","Stopped","Aborted","Adding","Removing","Determining")][String]$category,
            [Guid]$CorrelationId = $global:CorrelationID,
            [String]$eventId = "0000",
            [String]$process = "powershell.exe (0x0E44)",
            [String]$thread = "0x05BC",
            [String]$message
        )

        begin {
			Get-SPEOrSetLogFiles
        }

        process {
            $strCorrelationId = $CorrelationId.Guid
            $CurrentTimeStamp = Get-SPECurrentTimeForULS
            if($global:LogToConsole){
                if($global:UseInfoHeader)
                {
                    if($level -match "Critical" -or $level -match "High" -or $level -match "Unexpected"){
                        Show-SPETextLine -text $Content -fgColor $global:DisplayForeGroundColor_Error -bgColor $global:DisplayBackGroundColor_Error
                    } else {
                        Show-SPETextLine -text $Content
                    }
                    Wait-SPEForKey

                } else {
			        Write-Host $CurrentTimeStamp -NoNewline #Ausgabe des Log-Eintrags auf Console
				    if($level -match "Critical" -or $level -match "High"-or $level -match "Unexpected"){
                        Write-Host "$content" -ForegroundColor $global:DisplayForeGroundColor_Error -BackgroundColor $global:DisplayBackGroundColor_Error
                    } else {
                        Write-Host "$content" -ForegroundColor $global:DisplayForeGroundColor_Normal -BackgroundColor $global:DisplayBackGroundColor_Normal
                    }
                }
             }
            if($global:LogToLogFile){
                $NewLine = $CurrentTimeStamp + " " + $Content
                $NewLine >> $PathLogfile
            }
            if($global:LogToULSFile){
                $NewLine = "$CurrentTimeStamp	$process	$thread	$area	$category	$eventId	$level	$message	$strCorrelationId" #Do not edit this line! it's TAB-separated!!
			    $NewLine >> $PathULSLogfile #Ausgabe des Log-Eintrags in ULSfile
            }
        }
    }
    #endregion
    #EndOfFunction
