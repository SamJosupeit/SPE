#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPERegistryKey.ps1                                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPERegistryKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPERegistryKey 
    {        
        [CmdletBinding()]
        param
        ([string] $path, [string] $key)

        begin {
        }

        process {
            return (Get-ItemProperty $path).$key    
        }
    }
    #endregion
    #EndOfFunction        
