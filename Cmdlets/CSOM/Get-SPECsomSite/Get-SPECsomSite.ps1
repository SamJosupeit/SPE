#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPECsomSite.ps1                                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPECsomSite
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    function Get-SPECsomSite {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.String]
		    $Url,
		    [Parameter(Position=1, Mandatory=$true)]
		    [ValidateNotNull()]
		    [PSCredential]
		    $Credentials,
            [Switch]$SPO

       )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
        }

        process 
        {
            if($SPO)
            {
                $ctx = Get-SPECsomContext -Credentials $Credentials -Url $Url -SPO
            } else {
                $ctx = Get-SPECsomContext -Credentials $Credentials -Url $Url
            }
            if($ctx)
            {
                $site = $ctx.Site
                $ctx.Load($site)
                $ctx.ExecuteQuery()
                return $site
            }
            else
            {
                return $null
            }
        }
    }
    #endregion
    #EndOfFunction
