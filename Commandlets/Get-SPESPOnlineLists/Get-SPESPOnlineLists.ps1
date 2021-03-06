#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPESPOnlineLists.ps1                               #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPESPOnlineLists
    Function Get-SPESPOnlineLists
    {
        [CmdletBinding()]
        param(
            [Parameter(
                Position=0, 
                Mandatory=$true , 
                ValueFromPipeline=$True, 
                ValueFromPipelinebyPropertyName=$True
            )]
            [Microsoft.SharePoint.Client.Web]
            $Web
        )
        Begin{
            Test-SPEAndLoadCsomDLLs
            $collectedLists = New-Object psobjectject
        }
        Process{
#            foreach($item in $web)
#            {
                $lists = Get-SPESPOnlineObjectByCtx -ParentObject $web -ChildObject "Lists"
                #return $lists
                foreach($list in $lists){
#                    $catchOut = $collectedLists.Add($list)
                    $collectedLists | Add-Member -MemberType NoteProperty -Name $($list.Title) -Value $list 
                }
#            }
        }
        End{
            return $collectedLists
        }
    }
    #endregion
    #EndOfFunction
