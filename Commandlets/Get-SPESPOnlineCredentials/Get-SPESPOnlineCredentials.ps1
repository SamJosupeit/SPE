#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPESPOnlineCredentials.ps1                         #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPESPOnlineCredentials
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Get-SPESPOnlineCredentials
    {
        [CmdletBinding()]
        param
        (
        )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
        }
        process
        {
            $Credential = Get-SPECredentialsFromCurrentUser -SPO
            $SPOCred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credential.UserName, $Credential.Password)
            return $SPOCred
        }

    }
    #endregion
    #EndOfFunction
