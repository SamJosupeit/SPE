#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPESPOnlineContext.ps1                             #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPESPOnlineContext
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    function Get-SPESPOnlineContext {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.String]
		    $Url,
		    [Parameter(Position=1)]
		    [ValidateNotNull()]
		    [Microsoft.SharePoint.Client.SharePointOnlineCredentials]
		    $Credentials,
            [Parameter(Position=2)]
            [Switch]$AsGlobal
       )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
        }

        process 
        {
            if(!$Credentials -and !$global:cred)
            {
                $global:cred = Get-SPESPOnlineCredentials
                $Credentials = $cred
            }
            $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($url)
            $ctx.Credentials = $Credentials

            if(!$ctx.ServerObjectIsNull.Value)
            {
                if($AsGlobal)
                {
                    $global:ctx = $ctx
                }
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
