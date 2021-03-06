#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEADInfo.ps1                                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPEADInfo
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Get-SPEADInfo
    {
        [CmdletBinding()]
        param()
        begin{}
        process 
        {
            $ADDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
            $ADDomainName = $ADDomain.Name
            $Netbios = $ADDomain.Name.Split(".")[0].ToUpper()
            $ADServer = ($ADDomain.InfrastructureRoleOwner.Name.Split(".")[0])
            $FQDN = "DC=" + $ADDomain.Name -Replace("\.",",DC=")
 
            $Results = New-Object Psobject
            $Results | Add-Member Noteproperty Domain $ADDomainName
            $Results | Add-Member Noteproperty FQDN $FQDN
            $Results | Add-Member Noteproperty Server $ADServer
            $Results | Add-Member Noteproperty Netbios $Netbios
            Return $Results
        }
    }
    #endregion
    #EndOfFunction
