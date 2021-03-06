#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPESPOnlineWeb.ps1                                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPESPOnlineWeb
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    function Get-SPESPOnlineWeb {
        [CmdletBinding(DefaultParameterSetName="ByUrl")]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true,ParameterSetName="ByUrl")]
		    [ValidateNotNullOrEmpty()]
		    [System.String]
		    $Url,
 		    [Parameter(Position=0, Mandatory=$true,ParameterSetName="ByContext")]
		    [ValidateNotNullOrEmpty()]
            [Microsoft.Sharepoint.Client.ClientContext]
            $Context,
		    [Parameter(Position=1)]
		    [Microsoft.SharePoint.Client.SharePointOnlineCredentials]
		    $Credentials
       )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
        }

        process 
        {
            switch($PSCmdlet.ParameterSetName)
            {
                "ByUrl"{
                    $ctx = Get-SPESPOnlineContext -Url $url -Credentials $Credentials
                    if($ctx)
                    {
                        $web = $ctx.Web
                        $ctx.Load($web)
                        $ctx.ExecuteQuery()
                        return $web
                    }
                    else
                    {
                        return $null
                    }
                }
                "ByContext"{
                    $web = $ctx.Web
                    $ctx.Load($web)
                    $ctx.ExecuteQuery()
                    return $web
                }
            }
        }
    }
    #endregion
    #EndOfFunction
