#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - 40882 Ratingen                                              #
# Powershell-Script                                                   #
# #####################################################################
# Name:     Functions_SharePoint.ps1                                  #
# Funktion: Dieses Script dient der globalen Bereitstellung von       #
#           SharePoint-bezogenen Functions.                           #
# ################################################################### #
# # Versionsverlauf:                                                # #
# ################################################################### #
# Ver. | Autor      | Änderungen                         | Datum      #
# ################################################################### #
# 0.1  | S.Josupeit | Erst-Erstellung                    | 02.12.2014 #
######################################################################>
#endregion

$global:UsingSharePoint = $true

#region Functions

	#region Function Iterate-DirectorySubFolders
	Function Iterate-DirectorySubFolders
	{
		<#
			
		#>
		[CmdletBinding()]
		Param(
			[System.IO.DirectoryInfo]$directoryFolder,
			[Microsoft.SharePoint.SPFolder]$targetSPFolder
		)
		Begin{
			$directoryFolderPath = $directoryFolder.FullName
			#$folderRelativePath = $folderpath.Replace($directoryRoot,"")
		}
		Process{
			#region Copy current files from current directory
			$files = Get-DirectoryFiles -folder $directoryFolder
			if($files)
			{
				$resultBasetype = Get-BaseTypeNameFromObject -object $files
				switch($resultBasetype)
				{
					# variable $files contains multiple Items
					"Array"{	
						foreach($file in $files)
						{
							Copy-FileFromDirectoryToSPFolder -sourceFile $file -directoryFolder $directoryFolder -targetSPFolder $targetSPFolder
						}
						break
					}
					# variable $files contains one single Item
					"FileSystemInfo"{ 
						$file = $files
						Copy-FileFromDirectoryToSPFolder -sourceFile $file -directoryFolder $directoryFolder -targetSPFolder $targetSPFolder
						break
					}
					# something else resulting from an error
					"Default"{
						Log-Message -Content "An error occured at determination of files from folder '$directoryFolderPath'."
						break
					}
				}
			}
			#endregion
				
			#region Iterating subfolders
			$directorySubFolders = Get-DirectorySubfolders -folder $directoryFolder
				
			if($directorySubFolders)
			{
				$resultBasetype = Get-BaseTypeNameFromObject -object $directorySubFolders
				switch($resultBasetype)
				{
					# variable $subFolders contains multiple Items
					"Array"{
						foreach($directorySubFolder in $directorySubFolders)
						{
							$subFolderName = $directorySubFolder.FullName.Split("\")[-1]
							if(($newSPFolder = Check-AndSetSPFolder -subFolderName $subFolderName -parentSPFolder $targetSPFolder) -ne $null)
							{
								# Going one level deeper
								Iterate-DirectorySubFolders -directoryFolder $directorySubFolder -targetSPFolder $newSPFolder
							}
							else
							{
								Log-Message -Content "Error at determing subfolder '$subFolderName'. Skipping this Folder."
							}
						}
						break
					}
					# variable $subFolders contains one single Item
					"FileSystemInfo"{ 
						$directorySubFolder = $directorySubFolders
						$subFolderName = $directorySubFolder.FullName.Split("\")[-1]
						if(($newSPFolder = Check-AndSetSPFolder -subFolderName $subFolderName -parentSPFolder $targetSPFolder) -ne $null)
						{
							# Going one level deeper
							Iterate-DirectorySubFolders -directoryFolder $directorySubFolder -targetSPFolder $newSPFolder
						} else {
							Log-Message -Content "Error at determing subfolder '$subFolderName'. Skipping this Folder."
						}
						break
					}
					# something else resulting from an error
					"Default"{
						Log-Message -Content "An error occured at determination of subfolders from folder '$directoryFolderPath'."
						break
					}
				}
			}
			#endregion
		}
	}
	#endregion
		
	#region Function Check-AndSetSPFolder
	Function Check-AndSetSPFolder
	{
		<#
			
		#>
		[CmdletBinding()]
		Param(
			[String]$subFolderName,
			[Microsoft.SharePoint.SPFolder]$parentSPFolder
		)
		Begin{
		}
		Process{
			$newSPFolder = $null
			try
			{
				#$subFolderName = $directorySubFolder.Name
				Log-Message -Content "Testing for Subfolder '$subFolderName'..."
				if(($newSPFolder = $targetSPFolder.SubFolders[$subFolderName]) -eq $null){
					Log-Message -Content "...Folder does not exist and will be created."
					$newSPFolder = $targetSPFolder.SubFolders.Add($subFolderName)
					$newSPFolderURL = $newSPFolder.ServerRelativeUrl
					Report-Message -Content "Created SPFolder '$newSPFolderURL'"
				} else {
					Log-Message -Content "...Folder exists an will be used."
				}
			}
	        catch
	        {
	            $exMessage = $_.Exception.Message
	            $innerException = $_.Exception.InnerException
	            $info = "Error at Testing for SPFolder '$subFolderName'."
	            Catch-Exception -exMessage $exMessage -innerException $innerException -info $info
	        }
			return $newSPFolder
				
		}
	}
	#endregion
		
	#region Function Copy-FileFromDirectoryToSPFolder
	Function Copy-FileFromDirectoryToSPFolder
	{
		<#
			
		#>
		[CmdletBinding()]
		Param(
			[System.IO.FileInfo]$sourceFile,
			[System.IO.DirectoryInfo]$directoryFolder,
			[Microsoft.SharePoint.SPFolder]$targetSPFolder
		)
		Begin{
			$fileName = $sourceFile.Name
			$filePath = $sourceFile.FullName
			$SPFolderUrl = $targetSPFolder.Url
			$dirPath = $directoryFolder.FullName
			$fileLastWriteTimeUTC = $sourceFile.LastWriteTimeUTC
		}
		Process{
			try{
				Log-Message -Content "Found file '$filePath' in directory '$dirPath'."
				Log-Message -Content "Determing if file already exists in Library-Folder '$SPFolderUrl'..."
				$doCopy = $true
				$doUpdate = $false
				if( ($spFile = $targetSPFolder.Files[$fileName]) -ne $null)
				{
					Log-Message -Content "File exists. Comparing 'Last Modification TimeStamps'..."
					# file exists. check for lastmodified-property
					$spFileLastModified = $spFile.TimeLastModified
					if($spFileLastModified -gt $fileLastWriteTimeUTC)
					{
						Log-Message -Content "Corresponding file to '$filePath' in SPFolder '$SPFolderUrl' is newer than the sourcefile."
						Log-Message -Content "Skipping copying the sourcefile."
						$doCopy = $false
					} else {
						$doUpdate = $true
					}
				}
				if($doCopy){
					Log-Message -Content "Copying file '$filePath' from directory '$dirPath' to SPFolder '$SPFolderUrl'..."
					$fileStream = $sourceFile.OpenRead()
					[Microsoft.SharePoint.SPFile]$spFile = $targetSPFolder.Files.Add($SPFolderUrl + "/" + $fileName, $fileStream, $true)
					$fileStream.Close()
					if($doUpdate)
					{
						Report-Message -Content "Updated file '$filePath' from directory '$dirPath' to SPFolder '$SPFolderUrl'..."
					}
					else
					{
						Report-Message -Content "Copied file '$filePath' from directory '$dirPath' to SPFolder '$SPFolderUrl'..."
					}
				}
			}
			catch
	        {
	            $exMessage = $_.Exception.Message
	            $innerException = $_.Exception.InnerException
	            $info = "Error at copying file '$filePath' from directory '$dirPath' to SPFolder '$SPFolderUrl'"
	            Catch-Exception -exMessage $exMessage -innerException $innerException -info $info
	        }
		}
	}
	#endregion
		
	#region Function Remove-EmptySPListSubfolders
	function Remove-EmptySPListSubfolders
	{
        <#
        .SYNOPSIS
        Describe the function here
        .DESCRIPTION
        Describe the function in more detail
        .EXAMPLE
        Give an example of how to use it
        .EXAMPLE
        Give another example of how to use it
        .PARAMETER computername
        The computer name to query. Just one.
        .PARAMETER logname
        The name of a file to write failed computer names to. Defaults to errors.txt.
        #>
        [CmdletBinding()]
        param
        (
			[Microsoft.SharePoint.SPFolder]$sourceFolder
		)

        begin {
        }

        process {
			Log-Message -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Prüfe, ob SPFolder '$($sourceFolder.Name)' leer ist und gelöscht werden kann."
			$folderRelativeUrl = $sourceFolder.ServerRelativeUrl
			$folderName = $sourceFolder.Name
			if(!($sourceFolder.ServerRelativeUrl -match "/Forms"))
			{
				$NoFilesInFolder = $false
				$NoSubFoldersInFolder = $false
				Log-Message -area "SPItem" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Prüfe, ob keine Items vorhanden sind..."
				if($sourceFolder.Items.Count -eq 0)
				{
					Log-Message -area "SPItem" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind keine Items vorhanden."
					$NoFilesInFolder = $true
				}
				else 
				{
					Log-Message -area "SPItem" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind Items vorhanden. Ordner kann nicht gelöscht werden."
				}
				Log-Message -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Prüfe, ob keine SubFolders vorhanden sind..."
				if($sourceFolder.SubFolders.Count -eq 0)
				{
					Log-Message -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind keine SubFolder vorhanden."
					$NoSubFoldersInFolder = $true
				} else {
					foreach($subFolder in $sourceFolder.SubFolders)
					{
						Log-Message -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind SubFolder vorhanden. Iteriere tiefer..."
						Remove-EmptySPListSubfolders -sourceFolder $subFolder
						Log-Message -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Rücksprung nach Iteration. Überprüfe erneut auf vorhandene SubFolder..."
						if($sourceFolder.subFolders.Count -eq 0)
						{
							Log-Message -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Keine weiteren SubFolder vorhanden."
							$NoSubFoldersInFolder = $true
						}
						else
						{
							Log-Message -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Verbose" -message "Es sind weitere SubFolder vorhanden. Folder kann nicht gelöscht werden."
						}
					}
				}
				if($NoFilesInFolder -and -$NoSubFoldersInFolder)
				{
					Log-Message -area "SPFolder" -category "Removing" -CorrelationId $CorrelationID -level "Verbose" -message "Folder '$folderName' besitzt keine Items oder SubFolder und kann gelöscht werden."
					$parentFolder = $sourceFolder.ParentFolder
					Log-Message -area "SPFolder" -category "Removing" -CorrelationId $CorrelationID -level "Verbose" -message "Lösche Folder '$folderName'..."
					if(!$TestModus)
					{
						$parentFolder.SubFolders.Delete($sourceFolder)
					}
					Log-Message -area "SPFolder" -category "Removed" -CorrelationId $CorrelationID -level "Verbose" -message "Folder '$folderName' wurde gelöscht..."
				}
			} else {
				Log-Message -area "SPFolder" -category "Determining" -CorrelationId $CorrelationID -level "Medium" -message "Aktuelle Folder ist der FORMS-Folder"
			}
		}
    }
	#endregion

	#region Function Iterate-SPListSubfolders
	function Iterate-SPListSubfolders
	{
        <#
        .SYNOPSIS
        Describe the function here
        .DESCRIPTION
        Describe the function in more detail
        .EXAMPLE
        Give an example of how to use it
        .EXAMPLE
        Give another example of how to use it
        .PARAMETER computername
        The computer name to query. Just one.
        .PARAMETER logname
        The name of a file to write failed computer names to. Defaults to errors.txt.
        #>
        [CmdletBinding()]
        param
        (
			[Microsoft.SharePoint.SPFolder]$sourceFolder,
			[String]$directoryRoot
		)

        begin {
			$folderRelativeUrl = $sourceFolder.ServerRelativeUrl
        }

        process {
			if(!($sourceFolder.ServerRelativeUrl -match "/Forms"))
			{
				if($sourceFolder.Files.Count -gt 0)
				{
					$filesToDelete = New-Object System.Collections.ArrayList
					$files = $sourceFolder.Files
					foreach($file in $files)
					{
						$fileName = $file.name
						Write-Host "filename to delete is $filename"
						if(!(Check-SPFileExistsInDirectory -SPFile $file -directoryRoot $directoryRoot))
						{
							$fileName = $file.Name
							Log-Message -Content "Collecting file '$fileName' for Deletion"
							$filesToDelete.Add($file)
						}
					}
					if($filesToDelete.Count -gt 0)
					{
						foreach($file in $filesToDelete)
						{
							$fileName = $file.Name
							Log-Message -Content "Deleting file '$fileName'..."
							$sourceFolder.Files.Delete($file)
							Report-Message -Content "Deleted file '$fileName' from SPFolder '$folderRelativeUrl'"
						}
					}
				}
				if($sourceFolder.SubFolders.Count -gt 0)
				{
					foreach($subFolder in $sourceFolder.SubFolders)
					{
						$subfolderSRU = $subFolder.ServerRelativeUrl
						Iterate-SPListSubFolders -sourceFolder $subFolder -directoryRoot $directoryRoot
					}
				}
				if(!(Check-SPFolderExistsInDirectory -SPFolder $sourceFolder -directoryRoot $directoryRoot) -and ($sourceFolder.files -eq $null))
				{
					$folderName = $sourceFolder.Name
					$folderUrl = $sourceFolder.ServerRelativeUrl
					Log-Message -Content "Folder '$folderName' does not exist in Directory and will now be deleted in Library."
					$parentFolder = $sourceFolder.ParentFolder
					$parentFolder.SubFolders.Delete($sourceFolder)
					Report-Message -Content "Deleted SPFolder '$folderUrl'."
				}
			} else {
				Log-Message -Content "Current Folder is FORMS-Folder"
			}
		}
    }
	#endregion

	#region Function Check-SPFileExistsInDirectory
	Function Check-SPFileExistsInDirectory
	{
		<#
			
		#>
		[CmdletBinding()]
		Param(
			[Microsoft.SharePoint.SPFile]$SPFile,
			[String]$directoryRoot
		)
		Begin{
			$relativeFilePath = $spFile.ServerRelativeUrl.TrimStart("/")
			$relativeFilePath = $relativeFilePath.Replace($dsTargetListName,"")
			if($dsTargetFolderListRelativePath -ne "/")
			{
				$relativeFilePath = $relativeFilePath.Replace($dsTargetFolderListRelativePath,"")
			}
			$relativeFilePath = $relativeFilePath.Replace("/","\")
			$fullFilePath = $dsSourceFolder + $relativeFilePath
		}
		Process{
			$fileExists = $false
			Log-Message -Content "Determing if File '$fullFilePath' exists in directory..."
			if((Test-Path -Path $fullFilePath))
			{
				$fileExists = $true
			}
			return $fileExists
		}
	}
	#endregion
		
	#region Function Check-SPFolderExistsInDirectory
	Function Check-SPFolderExistsInDirectory
	{
		<#
			
		#>
		[CmdletBinding()]
		Param(
			[Microsoft.SharePoint.SPFolder]$SPFolder,
			[String]$directoryRoot
		)
		Begin{
			$relativeFolderPath = $spFolder.ServerRelativeUrl.TrimStart("/")
			$relativeFolderPath = $relativeFolderPath.Replace($dsTargetListName,"")
			if($dsTargetFolderListRelativePath -ne "/")
			{
				$relativeFolderPath = $relativeFolderPath.Replace($dsTargetFolderListRelativePath,"")
			}
			$relativeFolderPath = $relativeFolderPath.Replace("/","\")
			$fullFolderPath = $dsSourceFolder + $relativeFolderPath
		}
		Process{
			Log-Message -Content "Determing if Folder '$fullFolderPath' exists in Directory"
			$folderExists = $false
			if((Test-Path -Path $fullFolderPath))
			{
				$folderExists = $true
			}
			return $folderExists
		}
	}
	#endregion
		
	#region Function Get-SPListSubfolders
	function Get-SPListSubfolders
	{
        <#
        .SYNOPSIS
        Gibt die in einem SPListFolder beinhalteten SubFolder oder NULL aus
        .DESCRIPTION
        Gibt die in einem SPListFolder beinhalteten SubFolder oder NULL aus
        .EXAMPLE
        $subfolders = Get-Subfolders $SPListFolder
        .PARAMETER $folder
        Der SPListFolder, dessen Subfolders erfasst werden sollen
        #>
        [CmdletBinding()]
        param
        ([Microsoft.SharePoint.SPFolder]$folder)

        begin {
        }

        process {
			$subFolders = $null
			if($folder.Subfolders.Count -gt 0)
			{
				$subFolders = $folder.SubFolders
			}
			return $subFolders
		}
    }
	#endregion

	#region Function Check-AndSetWeb
	function Check-AndSetWeb
	{
        <#
        .SYNOPSIS
        Überprüft das Vorhandensein einer SPWebSite und erstellt im negativen Falle eine neue SPWebSite mit den gegebenen Parametern
        .DESCRIPTION
        Überprüft das Vorhandensein einer SPWebSite und erstellt im negativen Falle eine neue SPWebSite mit den gegebenen Parametern
        .EXAMPLE
        $web = Check-AndSetWeb -url "http://portal/website" -name "TestSite" -treeViewEnabled $false

        Prüft auf Vorhandensein der Website "http://portal/website". Ist diese nicht vorhanden, wird sie erstellt.
        .PARAMETER url
        URL zur WebSite
        .PARAMETER name
        Name der website
        .PARAMETER treeViewEnabled
        Anzeige in Quicklaunch oder nicht
        #>
        [CmdletBinding()]
        param
        (
			[String]$url,
			[String]$name,
			[Boolean]$treeViewEnabled
		)

        begin {
        }

        process {
			Log-Message -Content "Prüfe WebSite $url"
			$web = Get-SPWeb $url -ErrorAction SilentlyContinue
			if($web -eq $null)
			{
				Log-Message -Content "WebSite $url existiert nicht und wird neu erstellt..."
				$web = New-SPWeb -Url $url -Template "STS#1" -Name $name -AddToQuickLaunch -UseParentTopNav 
				if($treeViewEnabled)
				{
					$web.TreeViewEnabled = $true
				}
				$web.Update()
				Log-Message -Content "...ZielWeb '$url' wurde erstellt"
			} else {
                Log-Message -Content "ZielWeb '$url' existiert bereits und wird verwendet."
            }
			return $web
		}
    }
	#endregion
		
	#region Function Delete-SubWebs
	function Delete-SubWebs
	{
        <#
        .SYNOPSIS
        Löscht iterativ alle SubWebsites unterhalb des angegebene SPWeb-Objekts sowie das SPWeb-Objekt selbst
        .DESCRIPTION
        Löscht iterativ alle SubWebsites unterhalb des angegebene SPWeb-Objekts sowie das SPWeb-Objekt selbst
        .EXAMPLE
        Delete-SubWebs -web $web
        .PARAMETER web
        Das zu löäschende SPWeb-Objekt
        #>
        [CmdletBinding()]
        param
        ([Microsoft.SharePoint.SPWeb]$web)

        begin {
        }

        process {
			$WebUrl = $web.Url
			if($web.Webs.Count -gt 0)
			{
				Log-Message -Content "Weitere SubWebSites vorhanden, iteriere tiefer...)"
				foreach($subweb in $web.Webs)
				{
					Delete-SubWebs -web $subweb
				}
				Log-Message -Content "...Alle SubWebSites auf dieser Ebene gelöscht"
			}
			Remove-SPWeb $webUrl -Confirm:$false
			Log-Message -Content "WebSite mit URL '$webUrl' gelöscht"
		}
    }
	#endregion
	
	#region Function Copy-ListViews
	function Copy-ListViews
	{
        <#
        .SYNOPSIS
        Kopiert alle Views von einer SPList auf eine andere
        .DESCRIPTION
        Kopiert alle Views von einer SPList auf eine andere
        .EXAMPLE
        Copy-ListViews -sourceList $sourceList -targetList $targetList
        .PARAMETER sourceList
        Quellliste
        .PARAMETER targetList
        Zielliste
        #>
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
				Log-Message -Content "Kopiere View '$name'..."
				$query = $view.Query
				$fieldsInternalNames = $view.ViewFields.ToStringCollection()
				#region Manipuliere FieldNamen
				$fieldsTitle = New-Object System.Collections.Specialized.StringCollection
				foreach($internalName in $fieldsInternalNames)
				{
					try
					{
						Log-Message -Content "Erfasse Feld mit InternalName '$internalName'"
						$field = $targetList.Fields.GetFieldByInternalName($internalName)
						Log-Message -Content "...Feld konnte erfasst werden."
						$fieldTitle = $internalName
						Log-Message -Content "Füge Feld '$fieldTitle' hinzu."
						$cache = $fieldsTitle.Add($fieldTitle)
					}
				    catch
				    {
				        $exMessage = $_.Exception.Message
				        $innerException = $_.Exception.InnerException
						$targetListTitle = $targetList.Title
				        $info = "Fehler bei Kopieren von Views von Source-Liste '$sourceList' auf Target-Liste '$targetListTitle'."
						if($innerException -match "does not exist. It may have been deleted by another user.")
						{
							#Feld existiert nicht
							Log-Message -Content "Feld '$fieldTitle' existiert nicht auf Source-Liste '$sourceList'"
						}
						else
						{
				            Catch-Exception -list $targetList -exMessage $exMessage -innerException $innerException -info $info
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
				Log-Message -Content "... Kopieren des Views '$name' erfolgreich abgeschlossen."
			}
		}
    }
	#endregion
	
	#region Function Copy-FolderProperties
	function Copy-FolderProperties
	{
        <#
        .SYNOPSIS
        Überträgt die Properties eines SPListFolders auf einen anderen
        .DESCRIPTION
        Überträgt die Properties eines SPListFolders auf einen anderen
        .EXAMPLE
        Copy-FolderProperties -sourceFolder -$sourceFolder -targetFolder $targetFolder
        .PARAMETER sourceFolder
        QuellOrdner
        .PARAMETER targetFolder
        ZielOrdner
        #>
        [CmdletBinding()]
        param
        (
		    [Microsoft.SharePoint.SPFolder]$sourceFolder,
		    [Microsoft.SharePoint.SPFolder]$targetFolder
	    )

        begin {
        }

        process {
			Pause-OnKey
			Log-Message -Content "Übertrage Feldwerte..."
			$sourceFields = $sourceFolder.Item.Fields | ?{!($_.sealed)}
			foreach($field in $sourceFields)
			{
				$fieldTitle = $field.Title
				try
				{
					Log-Message -Content "...behandle Feld '$fieldTitle'..."
					if($sourceFolder.Properties[$field.Title])
					{
						#Log-Message -Content "...Feld ist nicht leer..."
						if(!($targetFolder.Properties[$field.Title]))
						{
							#Log-Message -Content "...Feld existiert nicht auf Zielordner und wird erstellt..."
							$newPropCache = $targetFolder.AddProperty($field.Title, $sourceFolder.Properties[$field.Title])
							#Log-Message -Content "...Feld wurde erfolgreich erstellt..."
						} else {
							#Log-Message -Content "...Feld existiert auf Zielordner und wird gefüllt..."
							$targetFolder.Properties[$field.Title] = $sourceFolder.Properties[$field.Title]
							#Log-Message -Content "...Feld erfolgreich gefüllt..."
						}
					} else {
						#Log-Message -Content "...Feld ist leer..."
					}
				}
				catch
				{
			        $exMessage = $_.Exception.Message
			        $innerException = $_.Exception.InnerException
					if($exMessage -match "System.ArgumentException: Item has already been added. Key in dictionary")
                    {
				        $info = "Wert für Feld '$fieldTitle' scheint schon gesetzt zu sein. Füre Update aus."
				        Catch-Exception -exMessage $exMessage -innerException $innerException -info $info
						$targetFolder.Properties[$field.Title] = $sourceFolder.Properties[$field.Title]
					} else {
			            $info = "Fehler bei Übertrag des Feldwertes für Feld '$fieldTitle'"
			            Catch-Exception -exMessage $exMessage -innerException $innerException -info $info
					    Pause-OnKey
					}
				}
			}
		}
    }
	#endregion
		
	#region Function Copy-SubfolderItems
	function Copy-SubfolderItems
	{
        <#
        .SYNOPSIS
        Überträgt die Items eines SPListFolders auf einen anderen
        .DESCRIPTION
        Überträgt die Items eines SPListFolders auf einen anderen
        .EXAMPLE
        Copy-SubfolderItems -sourceFolder -$sourceFolder -targetFolder $targetFolder
        .PARAMETER sourceFolder
        QuellOrdner
        .PARAMETER targetFolder
        ZielOrdner
        #>
        [CmdletBinding()]
        param
        (
	        [Microsoft.SharePoint.SPFolder]$sourceFolder,
	        [Microsoft.SharePoint.SPFolder]$targetFolder
        )

        begin {
        }

        process {
			$sourceFolderTitle = $sourceFolder.Name
			$targetFolderTitle = $targetFolder.Name
			Log-StatusToConsole -Content "Kopiere Dateien von Quellordner '$sourceFolderTitle' in Zielordner '$targetFolderTitle'"
			Log-Message -Content "Kopiere Dateien von Quellordner '$sourceFolderTitle' in Zielordner '$targetFolderTitle'"
			$sourceWeb = $sourceFolder.ParentWeb
			$targetWeb = $targetFolder.ParentWeb
			$targetFolderFiles = $targetFolder.Files
			
			foreach($sourceFile in $sourceFolder.Files)
			{
				Pause-OnKey
				$global:cntFiles++
				$fileSuccessfullyCopied = $false
				$sourceFileName = $sourceFile.Name
				try{
					Log-StatusToConsole -Content "'$global:cntFiles' - Kopiere Datei '$sourceFileName' in Zielordner '$targetFolderTitle'..."
					Log-Message -Content "'$global:cntFiles' - Kopiere Datei '$sourceFileName' in Zielordner '$targetFolderTitle'..."
					$destUrl = $targetFolder.Url + "/" + $sourceFileName
					$binFile = $sourceFile.OpenBinary()
					$targetFile = $targetFolderFiles.Add($destUrl, $binFile, $true)
                    
					Log-Message -Content "...Kopieren erfolgreich abgeschlossen."
                    
					$fileSuccessfullyCopied = $true
                    
				}
				catch
				{
		            $exMessage = $_.Exception.Message
		            $innerException = $_.Exception.InnerException
		            $info = "Fehler bei Kopieren des Files '$sourceFileName'"
		            Catch-Exception -exMessage $exMessage -innerException $innerException -info $info
					Pause-OnKey
				}
				if($fileSuccessfullyCopied){
					Log-Message -Content "Übertrage Feldwerte..."
					$sourceFields = $sourceFile.Item.Fields | ?{!($_.sealed)}
					foreach($field in $sourceFields)
					{
						$fieldTitle = $field.Title
						try
						{
							Log-Message -Content "...behandle Feld '$fieldTitle'..."
							if($sourceFile.Properties[$field.Title])
							{
								#Log-Message -Content "...Feld ist nicht leer..."
								if(!($targetFile.Properties[$field.Title]))
								{
									#Log-Message -Content "...Feld existiert nicht auf Zieldatei und wird erstellt..."
									$newPropCache = $targetFile.AddProperty($field.Title, $sourceFile.Properties[$field.Title])
									#Log-Message -Content "...Feld wurde erfolgreich erstellt..."
								} else {
									#Log-Message -Content "...Feld existiert auf Zieldatei und wird gefüllt..."
									$targetFile.Properties[$field.Title] = $sourceFile.Properties[$field.Title]
									#Log-Message -Content "...Feld erfolgreich gefüllt..."
								}
							} else {
								#Log-Message -Content "...Feld ist leer..."
							}
						}
						catch
						{
				            $exMessage = $_.Exception.Message
				            $innerException = $_.Exception.InnerException
				            $info = "Fehler bei Übertrag des Feldwertes für Feld '$fieldTitle'"
				            Catch-Exception -exMessage $exMessage -innerException $innerException -info $info
							Pause-OnKey
						}
					}
					$targetFile.Update()
				} else {
					Log-Message -Content "...Lfd.Nr '$global:cntFiles' - Fehler bei Kopieren der Datei '$sourceFileName' in Zielordner '$targetFolderTitle'";
					Log-ErrorToConsole -Content "...Lfd.Nr '$global:cntFiles' - Fehler bei Kopieren der Datei '$sourceFileName' in Zielordner '$targetFolderTitle'";
				}
			}
			$targetWeb.Dispose();
			$sourceWeb.Dispose();
		}
    }
	#endregion
		
	#region Function Copy-ColumnDefaultValue
	function Copy-ColumnDefaultValue
	{
        <#
        .SYNOPSIS
        Überträgt die Column Default Values eines SPListFolders auf einen anderen
        .DESCRIPTION
        Überträgt die Column Default Values eines SPListFolders auf einen anderen
        .EXAMPLE
        Copy-ColumnDefaultValue -sourceFolder -$sourceFolder -targetFolder $targetFolder
        .PARAMETER sourceFolder
        QuellOrdner
        .PARAMETER targetFolder
        ZielOrdner
        #>
        [CmdletBinding()]
        param
        (
			[Microsoft.SharePoint.SPFolder]$sourceFolder,
			[Microsoft.SharePoint.SPFolder]$targetFolder
		)

        begin {
        }

        process {
			Pause-OnKey
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
				Log-Message -Content "Setze Column Default Value für Folder '$targetFolderTitle' in Spalte '$columnName' mit Wert '$columnValue'"
				$targetDefaultMetadata.SetFieldDefault($targetFolder, $columnName, $columnValue)
				$targetDefaultMetadata.Update()
				$columnValueString = $columnValue.Split('#')[1].Split('|')[0]
				Pause-OnKey
			}
		}
    }
	#endregion

	#region Function Export-SiteColumns
	function Export-SiteColumns
	{
        <#
        .SYNOPSIS
        Exportiert alle SiteColumns einer bestimmten Gruppe aus dem angebenen SPWeb-Objekt
        .DESCRIPTION
        Exportiert alle SiteColumns einer bestimmten Gruppe aus dem angebenen SPWeb-Objekt
        .EXAMPLE
        Export-SiteColumns -xmlFilePath ".\Export.xml" -web $web -groupName "Gruppe"
        .PARAMETER xmlFilePath
        Pfad zur Export-XML-Datei
        .PARAMETER web
        SPWeb-Objekt als Quelle
        .PARAMETER groupName
        Gruppenname der exportierenden SiteColumns
        #>
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
		
	#region Function Import-SiteColumns
	function Import-SiteColumns
	{
        <#
        .SYNOPSIS
        Importiert die zuvor mittels der Function "Export-SiteColumns" exportierten SiteColumns in die angegebene WebSite und gibt die erstellten Felder als ArrayList aus
        .DESCRIPTION
        Importiert die zuvor mittels der Function "Export-SiteColumns" exportierten SiteColumns in die angegebene WebSite und gibt die erstellten Felder als ArrayList aus
        .EXAMPLE
        $ArraList = Import-SiteColumns -web $web -xmlFilePath ".\Export.xml"
        .PARAMETER xmlFilePath
        Pfad zur Export-XML-Datei
        .PARAMETER web
        SPWeb-Objekt als Quelle
        #>
        [CmdletBinding()]
        param
        (
		    [Microsoft.SharePoint.SPWeb]$web,
		    [String]$xmlFilePath
	    )

        begin {
        }

        process {
			$fieldNameList = New-Object system.Collections.ArrayList
			$fieldsXml = [xml](Get-Content($xmlFilePath))
			#region Collect FieldNames
			$fieldsXML.Fields.Field | ForEach-Object {
				$cache = $fieldNameList.Add($_.DisplayName)
			}
			#endregion
			#region Create Fields based on XML
			$fieldsXML.Fields.Field | ForEach-Object {
			
			    #region Configure core properties belonging to all column types
			    $fieldXML = '<Field Type="' + $_.Type + '"
			    Name="' + $_.Name + '"
			    ID="' + $_.ID + '"
			    Description="' + $_.Description + '"
			    DisplayName="' + $_.DisplayName + '"
			    StaticName="' + $_.StaticName + '"
			    Group="' + $_.Group + '"
			    Hidden="' + $_.Hidden + '"
			    Required="' + $_.Required + '"
			    Sealed="' + $_.Sealed + '"'
			    #endregion
				
			    #region Configure optional properties belonging to specific column types – you may need to add some extra properties here if present in your XML file
			    if ($_.ShowInDisplayForm) { $fieldXML = $fieldXML + "`n" + 'ShowInDisplayForm="' + $_.ShowInDisplayForm + '"'}
			    if ($_.ShowInEditForm) { $fieldXML = $fieldXML + "`n" + 'ShowInEditForm="' + $_.ShowInEditForm + '"'}
			    if ($_.ShowInListSettings) { $fieldXML = $fieldXML + "`n" + 'ShowInListSettings="' + $_.ShowInListSettings + '"'}
			    if ($_.ShowInNewForm) { $fieldXML = $fieldXML + "`n" + 'ShowInNewForm="' + $_.ShowInNewForm + '"'}
			        
			    if ($_.EnforceUniqueValues) { $fieldXML = $fieldXML + "`n" + 'EnforceUniqueValues="' + $_.EnforceUniqueValues + '"'}
			    if ($_.Indexed) { $fieldXML = $fieldXML + "`n" + 'Indexed="' + $_.Indexed + '"'}
			    if ($_.Format) { $fieldXML = $fieldXML + "`n" + 'Format="' + $_.Format + '"'}
			    if ($_.MaxLength) { $fieldXML = $fieldXML + "`n" + 'MaxLength="' + $_.MaxLength + '"' }
			    if ($_.FillInChoice) { $fieldXML = $fieldXML + "`n" + 'FillInChoice="' + $_.FillInChoice + '"' }
			    if ($_.NumLines) { $fieldXML = $fieldXML + "`n" + 'NumLines="' + $_.NumLines + '"' }
			    if ($_.RichText) { $fieldXML = $fieldXML + "`n" + 'RichText="' + $_.RichText + '"' }
			    if ($_.RichTextMode) { $fieldXML = $fieldXML + "`n" + 'RichTextMode="' + $_.RichTextMode + '"' }
			    if ($_.IsolateStyles) { $fieldXML = $fieldXML + "`n" + 'IsolateStyles="' + $_.IsolateStyles + '"' }
			    if ($_.AppendOnly) { $fieldXML = $fieldXML + "`n" + 'AppendOnly="' + $_.AppendOnly + '"' }
			    if ($_.Sortable) { $fieldXML = $fieldXML + "`n" + 'Sortable="' + $_.Sortable + '"' }
			    if ($_.RestrictedMode) { $fieldXML = $fieldXML + "`n" + 'RestrictedMode="' + $_.RestrictedMode + '"' }
			    if ($_.UnlimitedLengthInDocumentLibrary) { $fieldXML = $fieldXML + "`n" + 'UnlimitedLengthInDocumentLibrary="' + $_.UnlimitedLengthInDocumentLibrary + '"' }
			    if ($_.CanToggleHidden) { $fieldXML = $fieldXML + "`n" + 'CanToggleHidden="' + $_.CanToggleHidden + '"' }
			    if ($_.List) { $fieldXML = $fieldXML + "`n" + 'List="' + $_.List + '"' }
			    if ($_.ShowField) { $fieldXML = $fieldXML + "`n" + 'ShowField="' + $_.ShowField + '"' }
			    if ($_.UserSelectionMode) { $fieldXML = $fieldXML + "`n" + 'UserSelectionMode="' + $_.UserSelectionMode + '"' }
			    if ($_.UserSelectionScope) { $fieldXML = $fieldXML + "`n" + 'UserSelectionScope="' + $_.UserSelectionScope + '"' }
			    if ($_.BaseType) { $fieldXML = $fieldXML + "`n" + 'BaseType="' + $_.BaseType + '"' }
			    if ($_.Mult) { $fieldXML = $fieldXML + "`n" + 'Mult="' + $_.Mult + '"' }
			    if ($_.ReadOnly) { $fieldXML = $fieldXML + "`n" + 'ReadOnly="' + $_.ReadOnly + '"' }
			    if ($_.FieldRef) { $fieldXML = $fieldXML + "`n" + 'FieldRef="' + $_.FieldRef + '"' }    
			    $fieldXML = $fieldXML + ">"
				#endregion
			    
			    #region Create choices if choice column
			    if ($_.Type -eq "Choice") {
			        $fieldXML = $fieldXML + "`n<CHOICES>"
			        $_.Choices.Choice | ForEach-Object {
			            $fieldXML = $fieldXML + "`n<CHOICE>" + $_ + "</CHOICE>"
			        }
			        $fieldXML = $fieldXML + "`n</CHOICES>"
			    }
			    #endregion
				
			    #region Set Default value, if specified  
			    if ($_.Default) { $fieldXML = $fieldXML + "`n<Default>" + $_.Default + "</Default>" }
			    #endregion
				
			    #region End XML tag specified for this field
			    $fieldXML = $fieldXML + "</Field>"
			    #endregion
				
			    #region Create column on the site
				try{
			    $web.Fields.AddFieldAsXml($fieldXML.Replace("&","&amp;"))
			    write-host "Created site column" $_.DisplayName "on" $web.Url
				}
		        catch
		        {
		            $exMessage = $_.Exception.Message
		            $innerException = $_.Exception.InnerException
		            $info = "Fehler bei Erstellen einer SiteColumn"
					if(!($innerException -match "A duplicate field name"))
					{
			            Catch-Exception -web $web -exMessage $exMessage -innerException $innerException -info $info
					}
		        }
				#endregion
			}
			#endregion
			return $fieldNameList
		}
    }
	#endregion
				
	#region Function Add-SiteColumnToCT
	function Add-SiteColumnToCT
    {
        <#
        .SYNOPSIS
        Fügt einem Contenttype eine SiteColumn hinzu
        .DESCRIPTION
        Fügt einem Contenttype eine SiteColumn hinzu
        .EXAMPLE
        Add-SiteColumnToCT -web $web -fieldName "Name der SiteColumn" -ContentTypeName "Name des ContentTypes"
        .PARAMETER web
        SPWeb
        .PARAMETER fieldName
        Name der SiteColumn
        .PARAMETER contentTypeName
        Name des ContentTypes
        #>
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
		
	#region Function Add-ContentTypesToList
	function Add-ContentTypesToList
	{
        <#
        .SYNOPSIS
        Fügt der angegebenen SPList im angegebenen SPWeb eine Liste von ContentTypes hinzu
        .DESCRIPTION
        Fügt der angegebenen SPList im angegebenen SPWeb eine Liste von ContentTypes hinzu
        .EXAMPLE
        Add-ContentTypesToList -contentTypeNames $ArrayListOfContentTypeNames -targetWeb $web -newList $SPListToAddContentTypesTo
        .PARAMETER contentTypeNames
        ArrayList of ContentTypeNames
        .PARAMETER targetWeb
        SPWeb-Objekt
        .PARAMETER newList
        SPList-Objekt
        #>
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
				    Log-Message -Content $output
			    }
		        catch
		        {
		            $exMessage = $_.Exception.Message
		            $innerException = $_.Exception.InnerException
		            $info = "Fehler bei Behandlung des ContentTypes $ctName"
				    if(!($innerException -match "A duplicate field name"))
				    {
			            Catch-Exception -list $newList.Title -web $targetWeb.Title -exMessage $exMessage -innerException $innerException -info $info
				    }
		        }
		    }
	    }
    }
	#endregion
	
    #region Function Export-SPList
    function Export-SPList
    {
        <#
        .SYNOPSIS
            Exports an SPList

        .DESCRIPTION
            Exports an SPList to FileSystem with several Parameters. For more detail see full help

        .PARAMETER WebUrl 
            Absolute URL of the site containing the list being exported

        .PARAMETER ListName 
            Display name of the list to be exported

        .PARAMETER Path
            Location on the file system where the exported files will be copied. You can also specify a .cmp file if you want the export to be compressed into files

        .PARAMETER ExcludeDependencies
            Exclude dependencies from the export package. Generally, you should always include export dependencies to avoid breaking objects in the export target

        .PARAMETER HaltOnWarning
            Stop the export operation if a warning occurs

        .PARAMETER HaltOnNonfatalError
            Stop the export operation for a non-fatal error

        .PARAMETER AutoGenerateDataFileName
            The file name for the content migration package should be automatically generated. When the export generates multiple .cmp  files, the file names are appended numerically. For example, where the file name is "MyList", and where the export operation produces multiple .cmp files, the migration packages are named "MyList1.cmp", "MyList2.cmp", and so forth

        .PARAMETER TestRun
            Complete a test run to examine the export process and log any warnings or errors

        .PARAMETER IncludeSecurity All
            Site security groups and group membership information is exported.
            The enumeration provide three values:
            All     : Specifies the export of user memberships and role assignments such as out of the box roles like Web Designer, plus any custom roles that extend from the out of the box roles. The ACL for each object is exported to the migration package, as well as user information defined in the DAP or LDAP servers.
            None    : No user role or security group information is exported. This is the default.
            WssOnly : Specifies the export of user memberships and role assignments such as out of the box roles like Web Designer, plus any custom roles that extend from the out of the box roles. The ACL for each object is exported to the migration package; however, user information defined in the DAP or LDAP servers is not exported.
            The default value when no parameter is specified is None.
            Note: Be careful with this parameter. When exporting objects smaller than a web (for example, a list or list item) you should set IncludeSecurity to None; otherwise, security group and membership information for the entire web is exported.

        .PARAMETER IncludeVersions
            Determines what content is selected for export based on version information.
            There are four enumeration values:
            All : which exports all existing versions of selected files.
            CurrentVersion : which exports only the most recent version of selected files.
            LastMajor : which exports only the last major version of selected files. This is the default value.
            LastMajorAndMinor : which exports the last major version and its minor versions.
            Note: LastMajor is the default value when no parameter is specified.
        .PARAMETER FileMaxSize
            Maximum size for a content migration package (.cmp) file that is outputted by the export operation. By default, the .cmp files are limited to 24 MB in size. If set to zero, the value resets to the default. When site data exceeds the specified limit, site data is separated in to two or more migration files. However, if a single site data file exceeds the maximum file size, the operation does  not split the source file, but rather it resizes the .cmp file to accommodate the oversize file. You can have any number of .cmp files. The range of allowable size values for the .cmp file is from 1 MB to 2GB. If you specify a value that is outside this range, the export operation reverts to the default value of 24 MB.

        .PARAMETER Overwrite
            Overwrite an existing content migration package file when running export. If this parameter is not specified, an exception is thrown if the specified data file already exists

        .EXAMPLE
            This one will export a “Team Documents” library and all documents contained within it from the site http://portal/sites/sales to the file C:\Export\TeamDocuments.cmp, overwriting any existing .cmp file with the same name. This time, we are also going to export permissions set on the library by using the IncludeSecurity parameter:
            Export-List -WebUrl “http://portal/sites/sales” -ListName "Team Documents" -Path "C:\Export\TeamDocuments.cmp" -Overwrite -IncludeSecurity All

        .EXAMPLE
            This command will export a “Team Contacts” list and all list items from the site http://portal/sites/sales to the folder C:\Export\TeamContacts on the server, overwriting any existing export in that folder:
            Export-List -WebUrl “http://portal/sites/sales” -ListName "Team Contacts" -Path "C:\Export\TeamContacts" -Overwrite

        #>
        [CmdletBinding()]
	    Param (
		    [parameter(Mandatory=$true)][string]$WebUrl, 
		    [parameter(Mandatory=$true)][string]$ListName,
		    [parameter(Mandatory=$true)][string]$Path,
		    [parameter(Mandatory=$false)][switch]$ExcludeDependencies,
		    [parameter(Mandatory=$false)][switch]$HaltOnWarning,
		    [parameter(Mandatory=$false)][switch]$HaltOnNonfatalError,
		    [parameter(Mandatory=$false)][switch]$AutoGenerateDataFileName,
		    [parameter(Mandatory=$false)][switch]$TestRun,
		    [parameter(Mandatory=$false)][string]$IncludeSecurity,
		    [parameter(Mandatory=$false)][string]$IncludeVersions,
		    [parameter(Mandatory=$false)][int]$FileMaxSize,
		    [parameter(Mandatory=$false)][switch]$Overwrite
	    )
        Begin{
		    #Load SharePoint 2010 cmdlets
		    $ver = $host | select version
		    if ($ver.Version.Major -gt 1)  {$Host.Runspace.ThreadOptions = "ReuseThread"}
		    Add-PsSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		    #Load assemblies (needed for SharePoint Server 2007)
		    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
		
		    #Check parameters have the correct values
		    if (!$IncludeSecurity)
		    { 
			    $IncludeSecurity = "None" 
		    }
		    else
		    {
			    if (($IncludeSecurity -ne "All") `
			    -and ($IncludeSecurity -ne "WssOnly") `
			    -and ($IncludeSecurity -ne "None"))
			    {
				    Throw "The IncludeSecurity parameter must be set to All, WssOnly or None"
			    }
		    }
	
		    if (!$IncludeVersions)
		    { 
			    $IncludeVersions = "LastMajor" 
		    }
		    else
		    {
			    if (($IncludeVersions -ne "All") `
			    -and ($IncludeVersions -ne "CurrentVersion") `
			    -and ($IncludeVersions -ne "LastMajor") `
			    -and ($IncludeVersions -ne "LastMajorAndMinor"))
			    {
				    Throw "The IncludeVersions parameter must be set to All, CurrentVersion, LastMajorAndMinor or LastMajor"
			    }
		    }
	
		    if (!$FileMaxSize)
		    {
			    $FileMaxSize = 0
		    }
 		    $site = New-Object Microsoft.SharePoint.SPSite($WebUrl)
		    $web = $site.OpenWeb()
		    $list = $web.Lists[$ListName]
		    [bool]$FileCompression = $false
       }
        Process{
		    #Set file paths for the export file and logs
		    [string]$exportPath = $Path.TrimEnd("\")
		    if ($exportPath.EndsWith(".cmp")) 
		    { 
			    $FileCompression = $true
			    $exportFile = $Path.Replace($Path.Remove($Path.LastIndexOf("\")+1),"")
			    $exportPath = $Path.Remove($Path.LastIndexOf("\"))
		    }
            Log-Message -message "Export-File created at $exportPath"	
		    $exportObject = New-Object Microsoft.SharePoint.Deployment.SPExportObject
		    $exportObject.Id = $list.ID
		    $exportObject.Type = [Microsoft.SharePoint.Deployment.SPDeploymentObjectType]::Site
	
		    #Create the export settings from the parameters specified
		    $exportSettings = New-Object Microsoft.SharePoint.Deployment.SPExportSettings
		    $exportSettings.SiteUrl = $site.Url
		    $exportSettings.ExportMethod = [Microsoft.SharePoint.Deployment.SPExportMethodType]::ExportAll
		    $exportSettings.FileLocation = $exportPath 
		    $exportSettings.FileCompression = $FileCompression 
		    if ($FileCompression) { $exportSettings.BaseFileName = $exportFile }
		    $exportSettings.ExcludeDependencies = $ExcludeDependencies
		    $exportSettings.OverwriteExistingDataFile = $Overwrite
		    $exportSettings.IncludeSecurity = $IncludeSecurity
		    $exportSettings.IncludeVersions = $IncludeVersions
		    $exportSettings.LogFilePath = $logFilePath
		    $exportSettings.HaltOnWarning = $HaltOnWarning
		    $exportSettings.HaltOnNonfatalError = $HaltOnNonfatalError
		    $exportSettings.AutoGenerateDataFileName = $AutoGenerateDataFileName
		    $exportSettings.TestRun = $TestRun
		    $exportSettings.FileMaxSize = $FileMaxSize
		    $exportSettings.ExportObjects.Add($exportObject)
	
		    #Write the export settings to a log file    
		    $outSiteUrl = $site.Url
            Log-Message -message "SiteUrl = $outSiteUrl"
            $outExportMethod = [Microsoft.SharePoint.Deployment.SPExportMethodType]::ExportAll
		    Log-Message -message "ExportMethod = $outExportMethod"
		    Log-Message -message "FileLocation = $exportPath"
		    Log-Message -message "FileCompression = $FileCompression"
		    if ($FileCompression) { Log-Message -message "BaseFileName = $exportFile" }
		    Log-Message -message "ExcludeDependencies = $ExcludeDependencies"
		    Log-Message -message "OverwriteExistingDataFile = $Overwrite"
		    Log-Message -message "IncludeSecurity = $IncludeSecurity"
		    Log-Message -message "IncludeVersions = $IncludeVersions"
		    Log-Message -message "LogFilePath = $logFilePath"
		    Log-Message -message "HaltOnWarning = $HaltOnWarning"
		    Log-Message -message "HaltOnNonfatalError = $HaltOnNonfatalError"
		    Log-Message -message "AutoGenerateDataFileName = $AutoGenerateDataFileName"
		    Log-Message -message "TestRun = $TestRun"
		    Log-Message -message "FileMaxSize = $FileMaxSize"
		    Log-Message -message "ExportObject = $exportObject"
	
		    #Run the export procedure
		    $export = New-Object Microsoft.SharePoint.Deployment.SPExport($exportSettings)
		    # $exportSettings
		    # "Export läuft"
		    $export.Run()
		    Log-Message -message "Export fertig"
		
        }
        End{
		    #Dispose of the web and site objects after use
		    $web.Dispose()
		    $site.Dispose()
        }
    }
    #endregion

    #region Function Is-ContentTypeInNewButton
    Function Is-ContentTypeInNewButton {
        <#
            .NOTES
            Taken from Website
            http://alexbrassington.com/2013/04/20/adding-content-types-to-the-new-button-on-a-document-library-with-powershell/
        #>
        [CmdletBinding()]
        Param ([parameter(Mandatory=$true)][string] $ContentTypeName,
               [parameter(Mandatory=$true)][Microsoft.SharePoint.SPList] $SPList)
        BEGIN{Log-Message -message "Prüfe, ob ContentType $ContentTypeName am New-Button der Liste $($SPList.Title) hinterlegt ist..." }
        PROCESS{
            #get the uniquecontenttypes from the list root folder
            $rootFolder = $SPList.RootFolder
            $contentTypesInPlace = [Microsoft.SharePoint.SPContentType[]] $rootFolder.UniqueContentTypeOrder
             
            #Check if any of them are the same as the test content type
            $results = $contentTypesInPlace | where { $_.Name -eq $ContentTypeName} 
            if ($results -ne $null)
            {
                Log-Message "$ContentTypeName ist am New-Button der Liste $($SPList.Title) hinterlegt."
                return $true
            }
            else
            {
                Log-Message "$ContentTypeName ist nicht am New-Button der Liste $($SPList.Title) hinterlegt."
                return $false
            }
        }
    END{Log-Message -message "Prüfung, ob ContentType $ContentTypeName am New-Button der Liste $($SPList.Title) hinterlegt ist, abgeschlossen." }
    }
    #endregion 

    #region Function Ensure-ContentTypeInList
    Function Ensure-ContentTypeInList{
        <#
            .NOTES
            Taken from Website
            http://alexbrassington.com/2013/04/20/adding-content-types-to-the-new-button-on-a-document-library-with-powershell/
        #>
        [CmdletBinding()]
        Param ( [parameter(Mandatory=$true,ValueFromPipeline=$true)][string] $ContentTypeName,
               [parameter(Mandatory=$true)][Microsoft.SharePoint.SPList] $SPList)
 
        BEGIN   {Log-Message -message "Stelle sicher, ob ContentType(s) von Liste $($SPList.Title) referenziert wird/werden..." }
        PROCESS { 
 
             #Check to see if the content type is already in the list
             $contentType = $SPList.ContentTypes[$ContentTypeName]
             if ($ContentType -ne $null)
             {
                #Content type already present
                Write-Verbose "$ContentTypeName already present in list"
                Log-Message -message "ContentType $ContentTypeName wird von Liste $($SPList.Title) referenziert."
                Return $true
             }
             else
             {
                Write-Verbose "$ContentTypeName not in list. Attempting to add"
                Log-Message -message "ContentType $ContentTypeName wird nicht von Liste $($SPList.Title). Füge ContentType hinzu..."
                if (!$SPList.ContentTypesEnabled)
                {
                    Write-Verbose "Content Types disabled in list $SPList, Enabling"
                    Log-Message -message "Die Nutzung von ContentTypes in Liste $($SPList.Title) ist deaktiviert. Aktiviere..."
                    $SPList.ContentTypesEnabled = $true
                    $SPList.Update()
                }
                 #Add site content types to the list from the site collection root
                 $ctToAdd = $SPList.ParentWeb.Site.RootWeb.ContentTypes[$ContentTypeName]
                 if($ctToAdd -eq $null)
                 {
                    Log-Message -message "ContentType $ContentTypeName konnte nicht in der übergeordneten SiteCollection gefunden werden."
                    #I don't believe this will be called.
                    return $false
                 }
                 $SPList.ContentTypes.Add($ctToAdd) | Out-Null
                 $SPList.Update()
                 Write-Verbose "$ContentTypeName added to list"
                 Log-Message -message "ContentType $ContentTypeName wurde der Liste $($SPList.Title) hinzugefügt."
                 return $true
             }
            }
        END {Log-Message -message "Sicherstellen, ob ContentType(s) von Liste $($SPList.Title) referenziert wird/werden, abgeschlossen."}
    }
    #endregion 

    #region Function Ensure-ContentTypeInNewButton
    Function Ensure-ContentTypeInNewButton{
    <#
        .NOTES
        Taken from Website
        http://alexbrassington.com/2013/04/20/adding-content-types-to-the-new-button-on-a-document-library-with-powershell/
    #>
    [CmdletBinding()]
    Param ( [parameter(Mandatory=$true,ValueFromPipeline=$true)][string] $ContentTypeName,
            [parameter(Mandatory=$true)][Microsoft.SharePoint.SPList] $SPList)
        BEGIN   { 
                    Log-Message -message "Stelle sicher, ob ContentType(s) am New-Button der Liste $($SPList.Title) hinterlegt ist."
                    #get the uniquecontenttypes from the list root folder
                    $contentTypesInPlace = New-Object 'System.Collections.Generic.List[Microsoft.SharePoint.SPContentType]'
                    $contentTypesInPlace = $SPList.RootFolder.UniqueContentTypeOrder
                    $dirtyFlag = $false
                }
        PROCESS { 
                 
            #Check the content type isn't already present in the content type
            $AlreadyPresent = Is-ContentTypeInNewButton -ContentTypeName $ContentTypeName -SPList $SPList
            if ($AlreadyPresent)
            {
                Log-Message -message "ContentType $ContentTypeName ist bereits am New-Button der Liste $($SPList.Title) hinterlegt."
            }
            else
            {
                #Check that there really is such a content type
                $ContentTypePresent = Ensure-ContentTypeInList $ContentTypeName $SPList
                #Catch error events
                if ($ContentTypePresent)
                {
                    #We now know that the content type is not in the new button and is present in the list. Carry on adding the content type
                 
                    $ctToAdd = $SPList.ContentTypes[$ContentTypeName]
                 
                    #add our content type to the unique content type list
                    $contentTypesInPlace  =  $contentTypesInPlace + $ctToAdd
                    $dirtyFlag = $true
                    Write-Verbose "$ContentTypeName queued to add to the new button"
                    Log-Message -message "ContentType $ContentTypeName wurde der Liste der hinzuzufügenden ContentTypes hinzugefügt."
                }
                else
                {
                    Log-Message -message "ContentType $ContentTypeName konnte nicht hinzugefügt werden."
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
                 Log-Message -message "ContentType(s) wurde(n) dem New-button der Liste $($SPList.Title) hinzugefügt"
            }
            else
            {
                    Write-Verbose "No changes"
            }
             Write-Verbose "Exiting  Ensure-ContentTypeInNewButton"
             Log-Message -message "sicherstellen von ContentType(s) am New-Button der Liste $($SPList.Title) abgeschlossen."    
        }
    }
    #endregion 

    #region Function Remove-ContentTypeFromNewButton
    Function Remove-ContentTypeFromNewButton{
    <#
        .NOTES
        Taken from Website
        http://alexbrassington.com/2013/04/20/adding-content-types-to-the-new-button-on-a-document-library-with-powershell/
    #>
    [CmdletBinding()]
    Param ( [parameter(Mandatory=$true,ValueFromPipeline=$true)][string] $ContentTypeName,
            [parameter(Mandatory=$true)][Microsoft.SharePoint.SPList] $SPList)
     
    BEGIN   {Log-Message -message "Entferne ContentType(s) vom New-Button der Liste $($SPList.Title)..."}
    PROCESS { 
    
                #Check the content type isn't already present in the content type
                $AlreadyPresent = Is-ContentTypeInNewButton -ContentTypeName $ContentTypeName -SPList $SPList
                if ($AlreadyPresent)
                {
                    Log-Message -message "ContentType $ContentTypeName existiert am New-Button der Liste $($SPList.Title) und wird gelöscht..."
                    #get the uniquecontenttypes from the list root folder
                    $rootFolder = $SPList.RootFolder
                 
                    #Get the content types where the names are different to our content type
                    $contentTypesInPlace = [System.Collections.ArrayList] $rootFolder.UniqueContentTypeOrder
                    $contentTypesInPlace = $contentTypesInPlace | where {$_.Name -ne $contentTypeName}
                 
                    #Set the UniqueContentTypeOrder to the collection we made above
                    $rootFolder.UniqueContentTypeOrder = [Microsoft.SharePoint.SPContentType[]]  $contentTypesInPlace
                 
                    #Update the root folder
                    $rootFolder.Update()
                    Log-Message -message "ContentType $ContentTypeName wurde vom New-Button der Liste $($SPList.Title) gelöscht."
                }
                else
                {
                    Log-Message -message "ContentType $ContentTypeName existiert nicht am New-Button der Liste $($SPList.Title)."
                }
            }
    END     {Log-Message -message "Entfernen von ContentType(s) vom New-Button der Liste $($SPList.Title) abgeschlossen."}
 
    }
    #endregion 

    #region Function Remove-SPListView
    function Remove-SPListView {
        Param(
            [Microsoft.SharePoint.SPList]$SPList,
            [string]$ViewName
        )
            $View = $List.Views[$ViewName]
            $List.Views.Delete($View.ID)
            $List.Update()
        }
    #endregion

#endregion

#region Vorlage
function Do-Something {
    <#
    .SYNOPSIS
        A brief description of the function or script. This keyword can be used
        only once in each topic.

    .DESCRIPTION
        A detailed description of the function or script. This keyword can be
        used only once in each topic.

    .PARAMETER  <Parameter-Name>
        The description of a parameter. Add a .PARAMETER keyword for
        each parameter in the function or script syntax.

        Type the parameter name on the same line as the .PARAMETER keyword. 
        Type the parameter description on the lines following the .PARAMETER
        keyword. Windows PowerShell interprets all text between the .PARAMETER
        line and the next keyword or the end of the comment block as part of
        the parameter description. The description can include paragraph breaks.

        The Parameter keywords can appear in any order in the comment block, but
        the function or script syntax determines the order in which the parameters
        (and their descriptions) appear in help topic. To change the order,
        change the syntax.
 
        You can also specify a parameter description by placing a comment in the
        function or script syntax immediately before the parameter variable name.
        If you use both a syntax comment and a Parameter keyword, the description
        associated with the Parameter keyword is used, and the syntax comment is
        ignored.


    .EXAMPLE
        A sample command that uses the function or script, optionally followed
        by sample output and a description. Repeat this keyword for each example.

    .INPUTS
        The Microsoft .NET Framework types of objects that can be piped to the
        function or script. You can also include a description of the input 
        objects.

    .OUTPUTS
        The .NET Framework type of the objects that the cmdlet returns. You can
        also include a description of the returned objects.

    .NOTES
        Additional information about the function or script.

    .LINK
        The name of a related topic. The value appears on the line below
        the .LINE keyword and must be preceded by a comment symbol (#) or
        included in the comment block. 

        Repeat the .LINK keyword for each related topic.

        This content appears in the Related Links section of the help topic.

        The Link keyword content can also include a Uniform Resource Identifier
        (URI) to an online version of the same help topic. The online version 
        opens when you use the Online parameter of Get-Help. The URI must begin
        with "http" or "https".

    .COMPONENT
        The technology or feature that the function or script uses, or to which
        it is related. This content appears when the Get-Help command includes
        the Component parameter of Get-Help.

    .ROLE
        The user role for the help topic. This content appears when the Get-Help
        command includes the Role parameter of Get-Help.

    .FUNCTIONALITY
        The intended use of the function. This content appears when the Get-Help
        command includes the Functionality parameter of Get-Help.

    .FORWARDHELPTARGETNAME <Command-Name>
        Redirects to the help topic for the specified command. You can redirect
        users to any help topic, including help topics for a function, script,
        cmdlet, or provider. 

    .FORWARDHELPCATEGORY  <Category>
        Specifies the help category of the item in ForwardHelpTargetName.
        Valid values are Alias, Cmdlet, HelpFile, Function, Provider, General,
        FAQ, Glossary, ScriptCommand, ExternalScript, Filter, or All. Use this
        keyword to avoid conflicts when there are commands with the same name.

    .REMOTEHELPRUNSPACE <PSSession-variable>
        Specifies a session that contains the help topic. Enter a variable that
        contains a PSSession. This keyword is used by the Export-PSSession
        cmdlet to find the help topics for the exported commands.

    .EXTERNALHELP  <XML Help File>
        Specifies an XML-based help file for the script or function.  

        The ExternalHelp keyword is required when a function or script
        is documented in XML files. Without this keyword, Get-Help cannot
        find the XML-based help file for the function or script.

        The ExternalHelp keyword takes precedence over other comment-based 
        help keywords. If ExternalHelp is present, Get-Help does not display
        comment-based help, even if it cannot find a help topic that matches 
        the value of the ExternalHelp keyword.

        If the function is exported by a module, set the value of the 
        ExternalHelp keyword to a file name without a path. Get-Help looks for 
        the specified file name in a language-specific subdirectory of the module 
        directory. There are no requirements for the name of the XML-based help 
        file for a function, but a best practice is to use the following format:
        <ScriptModule.psm1>-help.xml

        If the function is not included in a module, include a path to the 
        XML-based help file. If the value includes a path and the path contains 
        UI-culture-specific subdirectories, Get-Help searches the subdirectories 
        recursively for an XML file with the name of the script or function in 
        accordance with the language fallback standards established for Windows, 
        just as it does in a module directory.

        For more information about the cmdlet help XML-based help file format,
        see "How to Create Cmdlet Help" in the MSDN (Microsoft Developer Network) 
        library at http://go.microsoft.com/fwlink/?LinkID=123415.

    #>
    [CmdletBinding()]
    param
    (
    )

    begin {
    }

    process {
    }
}
#endregion
