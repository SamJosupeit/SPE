#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPECsomList.ps1                                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPECsomList
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Get-SPECsomList
    {
        [CmdletBinding()]
        param
        (
		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNull()]
		    [Microsoft.SharePoint.Client.Web]
		    $Web,
 		    [Parameter(Position=1)]
		    [System.String]
		    $ListTitle
        )
        begin 
        {
            Test-SPEAndLoadCsomDLLs
            $ctx = $web.Context
        }

        process 
        {
            if($ListTitle) # ListTitle is set, so return specified list
            {
                $list = $Web.Lists.GetByTitle($ListTitle)
                $ctx.Load($list)
                $ctx.ExecuteQuery()
                return $list

            }
            else # ListTitle is not set, so return all lists
            {
                $lists = $web.Lists
                $ctx.Load($lists)
                $ctx.ExecuteQuery()
                return $lists
            }
        }

    }
    #endregion
    #EndOfFunction
