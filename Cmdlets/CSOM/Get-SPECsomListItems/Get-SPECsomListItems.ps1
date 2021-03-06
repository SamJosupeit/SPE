#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPECsomListItems.ps1                               #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPECsomListItems
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Get-SPECsomListItems
    {
        <#
        .SYNOPSIS
        Noch nicht fertig!!!

        #>
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [Microsoft.SharePoint.Client.List]
		    $List
        )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
            $ctx = $List.Context
        }

        process 
        {
            $camlquery = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
            $listItems = $list.GetItems($camlquery)
            $ctx.Load($listItems)
            $ctx.ExecuteQuery()
            return $listItems
        }
    }
    #endregion
    #EndOfFunction
