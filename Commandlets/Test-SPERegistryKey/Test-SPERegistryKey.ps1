#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPERegistryKey.ps1                                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Test-SPERegistryKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Test-SPERegistryKey
    {        
        [CmdletBinding()]
        param
        ([string] $path, [string] $key)

        begin {
        }

        process {
    
            return ((Test-Path $path) -and ((Get-SPERegistryKey $path $key) -ne $null))       
        }
    }
    #endregion
    #EndOfFunction
