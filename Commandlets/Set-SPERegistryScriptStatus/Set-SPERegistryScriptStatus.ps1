#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPERegistryScriptStatus.ps1                        #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Set-SPERegistryScriptStatus    
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Set-SPERegistryScriptStatus 
    {
        [CmdletBinding()]
        param
        ([string] $step)

        begin {
            $script=$PSCmdLet.MyInvocation.PSCommandPath
        }

        process {
            Set-SPERegistryKey -path $global:RegRunKey -key $global:restartKey -value "$global:powershell $script -Step $step"
        }
    }
    #endregion
    #EndOfFunction
