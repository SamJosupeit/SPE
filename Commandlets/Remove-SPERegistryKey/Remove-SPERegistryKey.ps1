#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Remove-SPERegistryKey.ps1                              #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Remove-SPERegistryKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Remove-SPERegistryKey
    {        
        [CmdletBinding()]
        param
        ([string] $path, [string] $key)

        begin {
        }

        process {
            Remove-ItemProperty -path $path -name $key
        }
    }
    #endregion
    #EndOfFunction
