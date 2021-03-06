#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPESPOnlineSubWebsIterative.ps1                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPESPOnlineSubWebsIterative
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Get-SPESPOnlineSubWebsIterative
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [Microsoft.SharePoint.Client.Web]$web,
            [Parameter(Position=1,Mandatory=$false)]
            [Array]$properties,
            [Parameter(Position=2,Mandatory=$false)]
            [Microsoft.SharePoint.Client.ClientContext]$Ctx=$global:ctx

        )
        Begin{
            Test-SPEAndLoadCsomDLLs
        }
        Process
        {
            if($global:ActivateTestLogging){Write-SPELogMessage -message "Erfassung aller SubWebs von Website '$($web.title)' mit URL '$($web.Url)'..."}
            $collectedSubWebs = New-Object System.Collections.ArrayList
            if($global:ActivateTestLoggingVerbose){Write-SPELogAndTextMessage -message "aktueller Zähler collectedSubWebs: $($collectedSubWebs.Count)"}

            $subwebs = Get-SPESPOnlineSubWebs -web $web
            if($global:ActivateTestLoggingVerbose){Write-SPELogAndTextMessage -message "Es wurden $($subwebs.Count) SubWebs erfasst."}
            if($subwebs.Count -gt 0)
            {
                foreach($subweb in $subwebs)
                {
                    if(!$properties)
                    {
                        # Hole pauschal alle Properties des Web-Objects, die durch Get-SPECSOMProperties verarbeitet werden können.
                        $properties = $subweb | 
                            gm -force | 
                            ?{
                                $_.MemberType -eq "Property" -and 
                                $_.Name -ne "Context" -and 
                                $_.Name -ne "ObjectVersion" -and 
                                $_.Name -ne "Path" -and
                                $_.Name -ne "ServerObjectIsNull" -and
                                $_.Name -ne "Tag" -and
                                $_.Name -ne "TypedObject"
                            } | 
                            select name | 
                            %{$_.Name.ToString()}
                    }
                    $deeperSubWebs = Get-SPESPOnlineSubWebsIterative -web $subweb -properties $properties

                    #Get-SPECSOMProperties -object $subweb -propertyNames $properties -executeQuery
                    $collectedSubWebs.add($htweb) | out-null
                 }
            }
                   
            if($global:ActivateTestLogging){Write-SPELogAndTextMessage -message "Anzahl CollectedSubWebs: $($collectedSubWebs.Count)"}


            if($global:ActivateTestLogging){Write-SPELogMessage -message "Erfassung aller Subwebs von Website '$($web.title)' abgeschlossen."}
            return $collectedSubWebs
        }
    }
    #endregion
    #EndOfFunction
