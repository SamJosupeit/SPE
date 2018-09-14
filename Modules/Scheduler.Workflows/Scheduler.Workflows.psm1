#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-Module                                            #
# #####################################################################
# Name:        Scheduler.Common.psm1                                  #
# Description: This PowerShell-Module contains Workflows to be used   #
#              by the Scheduler scripts                               #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | G.Krieger | Initial Release                    | 01.02.2017 #
######################################################################>
#endregion

#region Functions
    

#endregion

#region Workflows

    #region Workflow Test-Workflow
    Workflow Initialize-SchedulerObjects{
        [CmdletBinding()]
        param(
        )
        Sequence{
            #region import modules
            InlineScript{
                Write-SPELogMessage -category $($PSCmdlet.MyInvocation.MyCommand) -message "succesfully imported SPE-Modules."
            }
            #endregion
        }
    }

    #endregion

    #region Workflow Publish-SchedulerItems
    <#
    Workflow Publish-SchedulerItems{
        [CmdletBinding()]
        param(
            [Microsoft.SharePoint.Client.List]$StagesList,
            [Microsoft.SharePoint.Client.List]$ModulesList,
            [Microsoft.SharePoint.Client.List]$TrainingsList,
            [Microsoft.SharePoint.Client.List]$DatesList
        )

    }
    #>
    #endregion

#endregion


