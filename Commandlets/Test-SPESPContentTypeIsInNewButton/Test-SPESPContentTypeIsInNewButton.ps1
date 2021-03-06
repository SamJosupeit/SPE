#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPESPContentTypeIsInNewButton.ps1                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Test-SPESPContentTypeIsInNewButton
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Test-SPESPContentTypeIsInNewButton {
        [CmdletBinding()]
        Param ([parameter(Mandatory=$true)][string] $ContentTypeName,
               [parameter(Mandatory=$true)][Microsoft.SharePoint.SPList] $SPList)
        BEGIN
        {
            if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Prüfe, ob ContentType $ContentTypeName am New-Button der Liste $($SPList.Title) hinterlegt ist..." }
        }
        PROCESS{
            #get the uniquecontenttypes from the list root folder
            $rootFolder = $SPList.RootFolder
            $contentTypesInPlace = [Microsoft.SharePoint.SPContentType[]] $rootFolder.UniqueContentTypeOrder
             
            #Check if any of them are the same as the test content type
            $results = $contentTypesInPlace | where { $_.Name -eq $ContentTypeName} 
            if ($results -ne $null)
            {
                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage "$ContentTypeName ist am New-Button der Liste $($SPList.Title) hinterlegt."}
                return $true
            }
            else
            {
                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage "$ContentTypeName ist nicht am New-Button der Liste $($SPList.Title) hinterlegt."}
                return $false
            }
        }
        END
        {
            if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Prüfung, ob ContentType $ContentTypeName am New-Button der Liste $($SPList.Title) hinterlegt ist, abgeschlossen."}
        }
    }
    #endregion 
    #EndOfFunction
