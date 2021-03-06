#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPERegistryScriptStatus.ps1                        #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPERegistryScriptStatus
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPERegistryScriptStatus
    {
        [CmdletBinding()]
        param()
        Begin{}
        Process{
            if(Test-SPERegistryKey -path $global:RegRunKey -key $global:restartKey)
            {
                $regString = Get-SPERegistryKey -path $global:RegRunKey -key $global:restartKey
                $filterString = "$global:powershell $script -Step "
                $stepString = $regString.Replace($filterString, "")
                return $stepString
            } else {
                return $null
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction
