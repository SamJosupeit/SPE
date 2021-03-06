#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Copy-SPESPColumnDefaultValue.ps1                       #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Copy-SPESPColumnDefaultValue
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
	function Copy-SPESPColumnDefaultValue
	{
        [CmdletBinding()]
        param
        (
			[Microsoft.SharePoint.SPFolder]$sourceFolder,
			[Microsoft.SharePoint.SPFolder]$targetFolder
		)

        begin {
        }

        process {
			Wait-SPEOnKey
			$sourceFolderTitle = $sourceFolder.Name
			$sourceListId = $sourceFolder.ParentListId
			$sourceList = $sourceFolder.ParentWeb.Lists[$sourceListId]
			$sourceWebLanguageId = $sourceFolder.ParentWeb.Language
			$sourceDefaultMetadata = New-Object Microsoft.Office.DocumentManagement.MetadataDefaults($sourceList)
			$sourceFolderMetadataDefault = $sourceDefaultMetadata.GetDefaultMetadata($sourceFolder)
			
			$targetFolderTitle = $targetFolder.Name
			$targetListId = $targetFolder.ParentListId
			$targetList = $targetFolder.ParentWeb.Lists[$targetListId]
			$targetWebLanguageId = $targetFolder.ParentWeb.Language
			$targetDefaultMetadata = New-Object Microsoft.Office.DocumentManagement.MetadataDefaults($targetList)
			$targetFolderMetadataDefault = $targetDefaultMetadata.GetDefaultMetadata($targetFolder)
			
			
			foreach($ColumnDefaultValuePair in $sourceFolderMetadataDefault)
			{
				$columnName = $ColumnDefaultValuePair.First
				$columnValue = $ColumnDefaultValuePair.Second
				if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Setze Column Default Value für Folder '$targetFolderTitle' in Spalte '$columnName' mit Wert '$columnValue'"}
				$targetDefaultMetadata.SetFieldDefault($targetFolder, $columnName, $columnValue)
				$targetDefaultMetadata.Update()
				$columnValueString = $columnValue.Split('#')[1].Split('|')[0]
				Wait-SPEOnKey
			}
		}
    }
	#endregion
    #EndOfFunction
