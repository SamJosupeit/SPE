#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Exit-SPEOnCtrlC.ps1                                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Exit-SPEOnCtrlC    
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Exit-SPEOnCtrlC 
    {
        [CmdletBinding()]
        param()
        Begin{}
        Process{
            [console]::TreatControlCAsInput = $true
            if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
            {
                throw (new-object ExecutionEngineException "Ctrl+C Pressed")
            }
        }
    }
    #endregion
    #EndOfFunction
