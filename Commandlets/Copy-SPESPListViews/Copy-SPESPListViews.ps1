#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Copy-SPESPListViews.ps1                                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Copy-SPESPListViews
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Copy-SPESPListViews
	{
        [CmdletBinding()]
        param
        (
		    [Microsoft.SharePoint.SPList]$sourceList,
		    [Microsoft.SharePoint.SPList]$targetList
	    )

        begin {
        }

        process {
			foreach($view in $sourceList.Views)
			{
				PauseOnKey
				$name = $view.title
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Kopiere View '$name'..."}
				$query = $view.Query
				$fieldsInternalNames = $view.ViewFields.ToStringCollection()
				#region Manipuliere FieldNamen
				$fieldsTitle = New-Object System.Collections.Specialized.StringCollection
				foreach($internalName in $fieldsInternalNames)
				{
					try
					{
						if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Erfasse Feld mit InternalName '$internalName'"}
						$field = $targetList.Fields.GetFieldByInternalName($internalName)
						if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Feld konnte erfasst werden."}
						$fieldTitle = $internalName
						if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Füge Feld '$fieldTitle' hinzu."}
						$cache = $fieldsTitle.Add($fieldTitle)
					}
				    catch
				    {
                        if($global:ActivateTestLoggingException){
				            $exMessage = $_.Exception.Message
				            $innerException = $_.Exception.InnerException
						    $targetListTitle = $targetList.Title
				            $info = "Fehler bei Kopieren von Views von Source-Liste '$sourceList' auf Target-Liste '$targetListTitle'."
						    if($innerException -match "does not exist. It may have been deleted by another user.")
						    {
							    #Feld existiert nicht
							    Write-SPELogMessage -message "Feld '$fieldTitle' existiert nicht auf Source-Liste '$sourceList'"
						    }
						    else
						    {
				                Push-SPEException -list $targetList -exMessage $exMessage -innerException $innerException -info $info
						    }
                        }
				    }
				}
				#endregion
				$isDefaultView = $view.DefaultView
				$paged = $view.paged
				$rowLimit = $view.RowLimit
				$type = $view.Type
				$personal = $view.PersonalView
					
				$newView = $targetList.Views.Add($name,$fieldsTitle,$query,$rowLimit,$paged,$isDefaultView,$type,$personal)
				$newView.Update()
				$targetList.Update()
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "... Kopieren des Views '$name' erfolgreich abgeschlossen."}
			}
		}
    }
	#endregion
    #EndOfFunction
