#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPESPContentTypeIsInSPEList.ps1                   #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Test-SPESPContentTypeIsInSPEList
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Test-SPESPContentTypeIsInSPEList{
        [CmdletBinding()]
        Param ( [parameter(Mandatory=$true,ValueFromPipeline=$true)][string] $ContentTypeName,
               [parameter(Mandatory=$true)][Microsoft.SharePoint.SPList] $SPList)
 
        BEGIN   {
            if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Stelle sicher, ob ContentType(s) von Liste $($SPList.Title) referenziert wird/werden..." }
        }
        PROCESS { 
 
             #Check to see if the content type is already in the list
             $contentType = $SPList.ContentTypes[$ContentTypeName]
             if ($ContentType -ne $null)
             {
                #Content type already present
                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName wird bereits von Liste $($SPList.Title) referenziert."}
                Return $true
             }
             else
             {
                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName wird nicht von Liste $($SPList.Title). Füge ContentType hinzu..."}
                if (!$SPList.ContentTypesEnabled)
                {
                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Die Nutzung von ContentTypes in Liste $($SPList.Title) ist deaktiviert. Aktiviere..."}
                    $SPList.ContentTypesEnabled = $true
                    $SPList.Update()
                }
                 #Add site content types to the list from the site collection root
                 $ctToAdd = $SPList.ParentWeb.Site.RootWeb.ContentTypes[$ContentTypeName]
                 if($ctToAdd -eq $null)
                 {
                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName konnte nicht in der übergeordneten SiteCollection gefunden werden."}
                    #I don't believe this will be called.
                    return $false
                 }
                 $SPList.ContentTypes.Add($ctToAdd) | Out-Null
                 $SPList.Update()
                 if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "ContentType $ContentTypeName wurde der Liste $($SPList.Title) hinzugefügt."}
                 return $true
             }
            }
        END 
        {
            if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Sicherstellen, ob ContentType(s) von Liste $($SPList.Title) referenziert wird/werden, abgeschlossen."}
        }
    }
    #endregion 
    #EndOfFunction
