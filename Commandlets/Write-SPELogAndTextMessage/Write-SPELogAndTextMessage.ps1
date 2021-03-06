#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Write-SPELogAndTextMessage.ps1                         #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Write-SPELogAndTextMessage
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Write-SPELogAndTextMessage
    {
        [CmdletBinding()]
        param
        (
            [String]$message
        )
        Begin{}
        Process{
            Show-SPETextLine -text $message
            Write-SPELogMessage -message $message 
        }
    }
    #endregion
    #EndOfFunction
