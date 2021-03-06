#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEWindowsPSModulesFolderPath.ps1                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPEWindowsPSModulesFolderPath
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPEWindowsPSModulesFolderPath {
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            $windir = $env:windir
            $modulePaths = ($env:PSModulePath).Split(';')
            foreach($modulePath in $modulePaths)
            {
                if($modulePath.StartsWith($windir))
                {
                    return $modulePath
                }
            }
        }
    }
    #endregion
    #EndOfFunction
