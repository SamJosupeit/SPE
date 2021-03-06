#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Export-SPESPSiteColumns.ps1                            #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Export-SPESPSiteColumns
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Export-SPESPSiteColumns
	{
        [CmdletBinding()]
        param
        (
			[String]$xmlFilePath,
			[Microsoft.SharePoint.SPWeb]$web,
			[String]$groupName
		)

        begin {
        }

        process {
			New-Item $xmlFilePath -type file -Force
			Add-Content $xmlFilePath "<?xml version=`"1.0`" encoding=`"utf-8`"?>"
			Add-Content $xmlFilePath "`n<Fields>"
			$web.Fields | ForEach-Object{
				if($_.Group -eq $groupName)
				{
					Add-Content $xmlFilePath $_.SchemaXml
				}
			}
			Add-Content $xmlFilePath "`n</Fields>"
		}
    }
	#endregion
    #EndOfFunction
