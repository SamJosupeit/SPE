#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPECurrentUsersNames.ps1                           #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPECurrentUsersNames
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPECurrentUsersNames {
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            $outObj = New-Object System.Object
            try
            {
                $strName = $env:USERNAME
                $strFilter = "(&(objectCategory=User)(samAccountName=$strName))"
                $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
                $objSearcher.Filter = $strFilter
                $objPath = $objSearcher.FindOne()
                $objUser = $objPath.GetDirectoryEntry()
                $outObj | Add-Member -NotePropertyName "DisplayName" -NotePropertyValue $objUser.displayName
                $outObj | Add-Member -NotePropertyName "GivenName" -NotePropertyValue $objUser.givenName
                $outObj | Add-Member -NotePropertyName "SurName" -NotePropertyValue $objUser.sn
                return $outObj
            }
            catch
            {
                if($UseInfoHeader){
                    Show-SPETextArray -textArray @(
                        "Es gibt ein Problem beim automatischen Erfassen der UserNames.",
                        "Vermutlich liegt das daran, dass die DomÃ¤ne derzeit nicht erreichbar ist.",
                        "Daher bitte die Daten manuell eingeben"
                    )
                    Wait-SPEForKey
                    $manualDisplayName = Show-SPEQuestion -text "Bitte den Anzeigenamen eingeben"
                    $manualGivenName = Show-SPEQuestion -text "Bitte den Vornamen eingeben"
                    $manualSN = Show-SPEQuestion -text "Bitte den Nachnamen eingeben"
                    $outObj | Add-Member -NotePropertyName "DisplayName" -NotePropertyValue $objUser.displayName
                    $outObj | Add-Member -NotePropertyName "GivenName" -NotePropertyValue $objUser.givenName
                    $outObj | Add-Member -NotePropertyName "SurName" -NotePropertyValue $objUser.sn
                    return $outObj

                }
                if($global:ActivateTestLoggingException)
                {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Fehler bei automatischer Erfassung der Benutzerdaten in Get-SPECurrentUsersNames"
	                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                }
            }
        }
    }
    #endregion
    #EndOfFunction
