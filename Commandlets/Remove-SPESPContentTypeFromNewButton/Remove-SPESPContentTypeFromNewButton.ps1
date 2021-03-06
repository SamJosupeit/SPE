#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Remove-SPESPContentTypeFromNewButton.ps1               #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Remove-SPESPContentTypeFromNewButton
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Remove-SPESPContentTypeFromNewButton{
   [CmdletBinding()]
    Param ( [parameter(Mandatory=$true,ValueFromPipeline=$true)][string] $ContentTypeName,
            [parameter(Mandatory=$true)][Microsoft.SharePoint.SPList] $SPList)
     
    BEGIN   {if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Entferne ContentType(s) vom New-Button der Liste $($SPList.Title)..."}}
    PROCESS { 
    
                #Check the content type isn't already present in the content type
                $AlreadyPresent = Test-SPESPContentTypeIsInNewButton -ContentTypeName $ContentTypeName -SPList $SPList
                if ($AlreadyPresent)
                {
                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName existiert am New-Button der Liste $($SPList.Title) und wird gelöscht..."}
                    #get the uniquecontenttypes from the list root folder
                    $rootFolder = $SPList.RootFolder
                 
                    #Get the content types where the names are different to our content type
                    $contentTypesInPlace = [System.Collections.ArrayList] $rootFolder.UniqueContentTypeOrder
                    $contentTypesInPlace = $contentTypesInPlace | where {$_.Name -ne $contentTypeName}
                 
                    #Set the UniqueContentTypeOrder to the collection we made above
                    $rootFolder.UniqueContentTypeOrder = [Microsoft.SharePoint.SPContentType[]]  $contentTypesInPlace
                 
                    #Update the root folder
                    $rootFolder.Update()
                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName wurde vom New-Button der Liste $($SPList.Title) gelöscht."}
                }
                else
                {
                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName existiert nicht am New-Button der Liste $($SPList.Title)."}
                }
            }
    END     {if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Entfernen von ContentType(s) vom New-Button der Liste $($SPList.Title) abgeschlossen."}}
 
    }
    #endregion 
    #EndOfFunction
