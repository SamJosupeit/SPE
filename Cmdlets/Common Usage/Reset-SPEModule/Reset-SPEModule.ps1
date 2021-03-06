#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Reset-SPEModule.ps1                                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Reset-SPEModule
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Reset-SPEModule
    {
        [CmdletBinding()]
        param(
            [String]$ModuleName="SamsPowerShellEnhancements"
        )
        Begin{}
        Process
        {
            $module = Get-Module $ModuleName
            if($module){
                Write-Host "Module '$ModuleName' ist geladen und wird entladen"
                Remove-Module $ModuleName
                Write-Host "...wurde entladen..."
                Write-Host "...wird geladen..."
                Import-Module $ModuleName
                Write-Host "Module '$ModuleName' wurde geladen"
            } else {
                $availableModules = Get-Module -ListAvailable | ?{$_.Name -eq $ModuleName}
                if($availableModules)
                {
                    Write-Host "Module '$ModuleName' ist nicht geladen und wird geladen..."
                    Import-Module $ModuleName
                    Write-Host "Module '$ModuleName' wurde geladen"
                } else {
                    Write-Host "Module mit Namen '$ModuleName' steht nicht zur VerfÃ¼gung."
                }
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction
