#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Add-SPESPContentTypesToSPList.ps1                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Add-SPESPContentTypesToSPList
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Add-SPESPContentTypesToSPList
	{
        [CmdletBinding()]
        param
        (
		    [System.Collections.ArrayList]$contentTypeNames,
		    [Microsoft.SharePoint.SPWeb]$targetWeb,
		    [Microsoft.SharePoint.SPList]$newList
	    )

        begin {
        }

        process {
		    foreach($ctName in $contentTypeNames)
		    {
			    try
			    {
				    $ctToAdd = $targetWeb.Site.RootWeb.ContentTypes[$ctName]
				    if($ctToAdd -ne $null){
					    $listCTs = $newList.ContentTypes
					    $ctExists = $false
					    foreach($listCT in $listCTs)
					    {
						    if($listCT.Name -eq $ctToAdd.Name)
						    {
							    $ctExists = $true
								    break
						    }
					    }
					    if(!$ctExists){
						    $ct = $newList.ContentTypes.Add($ctToAdd)
						    $output = "ContentType '" + $ctName + "' wurde der Liste '" + $newList.Title + "' hinzugefügt."
					    } else {
						    $output = "ContentType '" + $ctName + "' existiert bereits auf der Liste '" + $newList.Title + "'."
					    }
					    $newList.Update()
				    } else {
					    $output = "ContentType '" + $ctName + "' konnte nicht gefunden werden."
				    }
				    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message $output}
			    }
		        catch
		        {
		            if($global:ActivateTestLoggingException)
                    {
                        $exMessage = $_.Exception.Message
		                $innerException = $_.Exception.InnerException
		                $info = "Fehler bei Behandlung des ContentTypes $ctName"
				        if(!($innerException -match "A duplicate field name"))
				        {
			                Push-SPEException -list $newList.Title -web $targetWeb.Title -exMessage $exMessage -innerException $innerException -info $info
				        }
                    }
		        }
		    }
	    }
    }
	#endregion
    #EndOfFunction
