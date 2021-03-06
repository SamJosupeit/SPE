#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPECsomContext.ps1                                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPECsomContext
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    function Get-SPECsomContext {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.String]
		    $Url,
		    [Parameter(Position=1)]
		    [ValidateNotNull()]
		    [PSCredential]
		    $Credentials,
            [Switch]
            $SPO

       )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
        }

        process 
        {
            if($SPO)
            {
                $credUsername = $Credentials.UserName
                $credSecPass = $Credentials.Password
                $cred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($credUsername, $credSecPass)
            } else {
                $credUsername = $Credentials.GetNetworkCredential().UserName
                $credDomain = $Credentials.GetNetworkCredential().Domain
                $credSecPass = $Credentials.GetNetworkCredential().SecurePassword
                $cred = New-Object System.Net.NetworkCredential($credUsername, $credSecPass, $credDomain)
            }
            $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($url)
            $ctx.Credentials = $cred

            if(!$ctx.ServerObjectIsNull.Value)
            {
                return $ctx
            }
            else
            {
                return $null
            }
        }
    }
    #endregion
    #EndOfFunction
