#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Add-SPESPSiteColumnToSPContentType.ps1                 #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Add-SPESPSiteColumnToSPContentType
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Add-SPESPSiteColumnToSPContentType
    {
        [CmdletBinding()]
        param
        (
	        [Microsoft.SharePoint.SPWeb]$web,
	        [String]$fieldName,
	        [String]$contentTypeName
        )

        begin {
        }

        process {
			#Get SiteColumn as Field from WebSite
			$field = $web.Fields[$fieldName]
			#Get ContentType from WebSite
			$ct = $web.ContentTypes[$contentTypeName]
			#Create FieldLink for Field/SiteColumn
			$link = New-Object Microsoft.SharePoint.SPFieldLink($field)
			#Add FieldLink to ContentType
			$ct.FieldLinks.Add($link)
			#Update ContentType
			$ct.Update($true)
		}
    }
	#endregion
    #EndOfFunction
