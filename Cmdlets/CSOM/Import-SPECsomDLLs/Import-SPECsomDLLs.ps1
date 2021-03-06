#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Import-SPECsomDLLs.ps1                                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Import-SPECsomDLLs
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Import-SPECsomDLLs{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0)]
            [System.String]
            $Path,
            [Switch]$UseDocumentManagement,
            [Switch]$UsePublishing,
            [Switch]$UseSearch,
            [Switch]$UseSearchApplications,
            [Switch]$UseServerRuntime,
            [Switch]$UseTaxonomy,
            [Switch]$UseUserProfiles,
            [Switch]$UseWorkflowServices
        )
        Begin{
            if([String]::IsNullOrEmpty($Path))
            {
                $thisModulePath = (Get-Command $PSCmdlet.MyInvocation.MyCommand.Name.ToString()).Module.ModuleBase.ToString()
                $Path = $thisModulePath.TrimEnd("\") + "\"
            }
        }
        Process
        {
            $Path = $Path.TrimEnd("\") + "\"
            Add-Type -Path ($Path + "Microsoft.SharePoint.Client.dll")
            Add-Type -Path ($Path + "Microsoft.SharePoint.Client.Runtime.dll")
            if($UseDocumentManagement)
            {
                $file = "Microsoft.SharePoint.Client.DocumentManagement.dll"
                Import-SPEDLL -Path $Path -File $file
            }
            if($UsePublishing){
                $file = "Microsoft.SharePoint.Client.Publishing.dll"
                Import-SPEDLL -Path $Path -File $file
            }
            if($UseSearch) {
                $file = "Microsoft.SharePoint.Client.Search.dll"
                Import-SPEDLL -Path $Path -File $file
            }
            if($UseSearchApplications){
                $file = "Microsoft.SharePoint.Client.Search.Applications.dll"
                Import-SPEDLL -Path $Path -File $file
            }
            if($UseServerRuntime){
                $file = "Microsoft.SharePoint.Client.ServerRuntime.dll"
                Import-SPEDLL -Path $Path -File $file
            }
            if($UseTaxonomy){
                $file = "Microsoft.SharePoint.Client.Taxonomy.dll"
                Import-SPEDLL -Path $Path -File $file
            }
            if($UseUserProfiles){
                $file = "Microsoft.SharePoint.Client.UserProfiles.dll"
                Import-SPEDLL -Path $Path -File $file
            }
            if($UseWorkflowServices){
                $file = "Microsoft.SharePoint.Client.WorkflowServices.dll"
                Import-SPEDLL -Path $Path -File $file
            }
        }
        End{}
    }
   
    #endregion
    #EndOfFunction
