#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        New-SPECsomListItem.ps1                                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function New-SPECsomListItem
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function New-SPECsomListItem {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [Microsoft.SharePoint.Client.List]
		    $List,

		    [Parameter(Position=1)]
		    [ValidateNotNull()]
		    [System.Collections.ArrayList]
		    $FieldValues
        )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
            $ctx = $List.Context
        }

        process 
        {
            Write-host "ListTitle: '$($List.Title)'"
            $itemCreateInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $newitem = $List.AddItem($itemCreateInfo)
            foreach($fieldValue in $FieldValues)
            {
                $newItem[$fieldValue.First] = $fieldValue.Second
            }
            $newItem.Update()
            $ctx.ExecuteQuery()
            return $newitem
        }
    }
    #endregion
    #EndOfFunction
