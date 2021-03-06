#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Clear-SPERegistryAutostart.ps1                         #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Clear-SPERegistryAutostart
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Clear-SPERegistryAutostart 
    {
        [CmdletBinding()]
        param
        ([String]$path=$global:RegRunKey,[string]$key=$global:restartKey)

        begin {
        }

        process {
            if (Test-SPERegistryKey -path $path -key $key) {
                Remove-SPERegistryKey -path $path -key $key
            }
        }
    }
    #endregion
    #EndOfFunction        
