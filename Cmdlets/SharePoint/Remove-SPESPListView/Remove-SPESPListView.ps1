#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Remove-SPESPListView.ps1                               #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Remove-SPESPListView
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    function Remove-SPESPListView {
        [CmdletBinding()]
        Param(
            [Microsoft.SharePoint.SPList]$SPList,
            [string]$ViewName
        )
        Begin{}
        Process{
            $View = $List.Views[$ViewName]
            $List.Views.Delete($View.ID)
            $List.Update()
        }
        }
    #endregion
    #EndOfFunction
