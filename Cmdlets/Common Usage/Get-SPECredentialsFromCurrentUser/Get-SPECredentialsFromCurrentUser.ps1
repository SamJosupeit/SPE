#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPECredentialsFromCurrentUser.ps1                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPECredentialsFromCurrentUser
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Get-SPECredentialsFromCurrentUser
    {
        [CmdletBinding()]
        param
        (
            [Switch]$SPO
        )

        begin 
        {
        }
        process
        {
            if($SPO)
            {
                $EmailRegex = '^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$'
                $message = "Bitte Web-Zugangsdaten (im Email-Format) eingeben"
                do{
                    $Credential = Get-Credential -Message $message
                    $message = "Anscheinend wurde der Anmeldename nicht im Email-Format eingegeben. Bitte erneut versuchen."
                } until($Credential.UserName -match $EmailRegex)
            } else {
                $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
                $currentUserName = $currentUser.Name
                $Credential = Get-Credential -Message "Bitte Passwort eingeben" -UserName $currentUserName
            }
            return $Credential
        }

    }
    #endregion
    #EndOfFunction
