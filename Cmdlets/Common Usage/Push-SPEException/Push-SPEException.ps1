#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Push-SPEException.ps1                                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Push-SPEException
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Push-SPEException
    {
        [CmdletBinding()]
        param
        (
            [string]$list,
            [string]$web,
            [string]$site,
            [string]$exMessage,
            [string]$innerException,
            [string]$info
            )
        begin {}
        process
        {
            $global:foundErrors = $true
            $LogMessage = "Fehler bei Info   : " + $info
            Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            if($site){
                $LogMessage = "Fehler bei SPSite : " + $site
                Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            }
            if($web){
                $LogMessage = "Fehler bei SPWeb  : " + $web
                Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            }
            if($list){
                $LogMessage = "Fehler bei SPList : " + $list
                Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            }
            $LogMessage = "ExceptionMessage  : " + $exMessage
            Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            $innerException.split([char]10) | foreach{
                $LogMessage = "InnerException    : " + $_.Replace([String][char]13,"")
                Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            }
            $pscmdletData = $PSCmdlet
            $callString = "Fehler trat auf"
            if($pscmdletData.MyInvocation.ScriptName){
                $callScriptname = $pscmdletData.MyInvocation.ScriptName
                $callString += " in Script '$callScriptname' "
            }
            if($pscmdletData.MyInvocation.ScriptLineNumber){
                $callScriptLine = $pscmdletData.MyInvocation.ScriptLineNumber
                $callString += " in Zeile '$callScriptLine'"
            }
            $callString += ". Bitte in vorgeschaltetem TRY-Block nach Fehler suchen."
            Write-SPELogMessage -message $callString -Level "Unexpected"
        }
    }
    #endregion
    #EndOfFunction
