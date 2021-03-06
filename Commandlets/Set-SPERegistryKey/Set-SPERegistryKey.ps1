#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPERegistryKey.ps1                                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Set-SPERegistryKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Set-SPERegistryKey 
    {        
        [CmdletBinding()]
        param
        ([string] $path, [string] $key, [string] $value, [Switch]$Reboot)

        begin {
        }

        process {
            Set-ItemProperty -path $path -name $key -value $value    
            if($Reboot)
            {
                Restart-Computer
                exit
            }
        }
    }
    #endregion
    #EndOfFunction
