#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPESPContentTypeInNewButton.ps1                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Set-SPESPContentTypeInNewButton
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Set-SPESPContentTypeInNewButton{
    [CmdletBinding()]
    Param ( [parameter(Mandatory=$true,ValueFromPipeline=$true)][string] $ContentTypeName,
            [parameter(Mandatory=$true)][Microsoft.SharePoint.SPList] $SPList)
        BEGIN   { 
                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Stelle sicher, ob ContentType(s) am New-Button der Liste $($SPList.Title) hinterlegt ist."}
                    #get the uniquecontenttypes from the list root folder
                    $contentTypesInPlace = New-Object 'System.Collections.Generic.List[Microsoft.SharePoint.SPContentType]'
                    $contentTypesInPlace = $SPList.RootFolder.UniqueContentTypeOrder
                    $dirtyFlag = $false
                }
        PROCESS { 
                 
            #Check the content type isn't already present in the content type
            $AlreadyPresent = Test-SPESPContentTypeIsInNewButton -ContentTypeName $ContentTypeName -SPList $SPList
            if ($AlreadyPresent)
            {
                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName ist bereits am New-Button der Liste $($SPList.Title) hinterlegt."}
            }
            else
            {
                #Check that there really is such a content type
                $ContentTypePresent = Test-SPESPContentTypeIsInSPEList $ContentTypeName $SPList
                #Catch error events
                if ($ContentTypePresent)
                {
                    #We now know that the content type is not in the new button and is present in the list. Carry on adding the content type
                 
                    $ctToAdd = $SPList.ContentTypes[$ContentTypeName]
                 
                    #add our content type to the unique content type list
                    $contentTypesInPlace  =  $contentTypesInPlace + $ctToAdd
                    $dirtyFlag = $true
                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName wurde der Liste der hinzuzufügenden ContentTypes hinzugefügt."}
                }
                else
                {
                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName konnte nicht hinzugefügt werden."}
                }
            }
        }
        End{
            #Set the UniqueContentTypeOrder to the collection we made above
            if ($dirtyFlag)
            {
               $SPList = $SPList.ParentWeb.Lists[$SPList.ID]
                $rootFolder = $SPList.RootFolder
                $rootFolder.UniqueContentTypeOrder = [Microsoft.SharePoint.SPContentType[]]  $contentTypesInPlace
         
                 #Update the root folder
                 $rootFolder.Update()
                 if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType(s) wurde(n) dem New-button der Liste $($SPList.Title) hinzugefügt"}
            }
            else
            {
                    if($global:ActivateTestLoggingVerbose){Write-SPELogAndTextMessage -message "No changes"}
            }
            if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "sicherstellen von ContentType(s) am New-Button der Liste $($SPList.Title) abgeschlossen."}
        }
    }
    #endregion 
    #EndOfFunction
