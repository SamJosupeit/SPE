#region SP.CSOM.Modules
# Source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/tree/master/SharePoint-CSOM/Modules

#region Columns
#Source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Columns.psm1
function Add-SiteColumn {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$fieldXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $field = $web.Fields.AddFieldAsXml($fieldXml, $false, ([Microsoft.SharePoint.Client.AddFieldOptions]::AddToNoContentType))
        $ClientContext.load($field)
        $ClientContext.ExecuteQuery()
        $field
    }
    end {} 
}
function Get-SiteColumn {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$fieldId,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $fields = $web.Fields
        $ClientContext.Load($fields)
        $ClientContext.ExecuteQuery()

        $field = $null
        $field = $fields | Where {$_.Id -eq $fieldId}
        $field
    }
    end {} 
}
function Remove-SiteColumn {
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$fieldId,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $field = Get-SiteColumn -FieldId $fieldId -Web $web -ClientContext $ClientContext
        if($field -ne $null) {
            $field.DeleteObject()
            $ClientContext.ExecuteQuery()
        }
    }
}
function Remove-SiteColumns {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$fieldsXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {

        $ClientContext.Load($web.Fields)
        $ClientContext.ExecuteQuery()
        
        $deletedSiteColumns = $false
        foreach ($fieldXml in $fieldsXml.RemoveField) {
            $field = $web.Fields | Where {$_.Id -eq $fieldXml.ID}
            if($field -ne $null) {
                Write-Output "Deleting Site Column $($fieldXml.Name)"
                $field.DeleteObject()
            } else {
                Write-Verbose "Site Column $($fieldXml.Name) already deleted"
            }
        }
        if($deletedSiteColumns) {
            $ClientContext.ExecuteQuery()
            Write-Output "Deleted Site Columns"
        }
    }
}
function Update-SiteColumns {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$fieldsXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        Write-Verbose "Updating Site Columns" -Verbose
        $taxonomySession = Get-TaxonomySession -ClientContext $ClientContext
        $defaultSiteCollectionTermStore = Get-DefaultSiteCollectionTermStore -TaxonomySession $taxonomySession -ClientContext $ClientContext
        $ClientContext.Load($web.Fields)
        $ClientContext.ExecuteQuery()
        
        foreach ($fieldXml in $fieldsXml.Field) {
            $field = $web.Fields | Where {$_.Id -eq $fieldXml.ID}
	        if($field -eq $null) {
                $fieldStr = $fieldXml.OuterXml.Replace(" xmlns=`"http://schemas.microsoft.com/sharepoint/`"", "")
                $field = $web.Fields.AddFieldAsXml($fieldStr, $false, ([Microsoft.SharePoint.Client.AddFieldOptions]::AddToNoContentType))
                if(($fieldXml.Type -eq "TaxonomyFieldType") -or ($fieldXml.Type -eq "TaxonomyFieldTypeMulti")) {
                    $termSetId = $null
                    $field = [SharePointClient.PSClientContext]::CastToTaxonomyField($ClientContext, $field)
                    $field.SspId = $defaultSiteCollectionTermStore.Id
                    foreach($property in $fieldXml.Customization.ArrayOfProperty.Property) {
                        if($property.Name -eq "TermSetId") {
                            $termSetId = $property.Value.InnerText
                        }
                    }
                    if($termSetId) {                      
                        $field.TermSetId = $termSetId   
                    }
                    $field.UpdateAndPushChanges($false)
                }
                $ClientContext.ExecuteQuery()
		        Write-Verbose "Created Site Column $($fieldXml.Name)" -Verbose
	        } else {
                $updatedField = $false
                if($fieldXml.Name -ne $field.InternalName) {
                    $SchemaXml = $field.SchemaXml
                    $SchemaXml = $SchemaXml -replace " Name=""$($field.InternalName)"" ", " Name=""$($fieldXml.Name)"" "
                    Write-Verbose "Updating field schema xml $($SchemaXml)" -Verbose
                    $field.SchemaXml = $SchemaXml
                    $field.UpdateAndPushChanges($true)
                    $ClientContext.Load($field)
                    $ClientContext.ExecuteQuery()
                    $updatedField = $true
                    
                }
                if($fieldXml.StaticName -ne $field.StaticName) {
                    $field.StaticName = $fieldXml.StaticName
                    $updatedField = $true
                }
                if($fieldXml.DisplayName -ne $field.Title) {
                    $field.Title = $fieldXml.DisplayName
                    $updatedField = $true
                }
                if($fieldXml.UnlimitedLengthInDocumentLibrary) {
                    $unlimitedLengthInDocumentLibrary = [bool]::Parse($fieldXml.UnlimitedLengthInDocumentLibrary)
                    if($field.UnlimitedLengthInDocumentLibrary -ne $unlimitedLengthInDocumentLibrary) {
                        #TODO Append SchemaXml UnlimitedLengthInDocumentLibrary="True"
                        #$updatedField = $true
                    }
                }
                if($updatedField) {
                    $field.UpdateAndPushChanges($true)
                    $ClientContext.ExecuteQuery()
                    Write-Verbose "Updated Site Column $($fieldXml.Name)" -Verbose
                } else {
		            Write-Verbose "Site Column $($fieldXml.Name) already exists"
                }
	        }
        }
        Write-Verbose "Updated Site Columns" -Verbose
    }
}
#endregion

#region ContentTypes
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/ContentTypes.psm1
function Get-ContentType {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $contentTypes = $web.AvailableContentTypes
        $ClientContext.Load($contentTypes)
        $ClientContext.ExecuteQuery()

        $contentType = $contentTypes | Where {$_.Name -eq $ContentTypeName}
        $contentType
    }
    end {}
}
function Get-ContentTypeWithID {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeID,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $contentTypes = $web.AvailableContentTypes
        $ClientContext.Load($contentTypes)
        $ClientContext.ExecuteQuery()

        $contentType = $contentTypes | Where {$_.Id -eq $ContentTypeID}
        $contentType
    }
    end {}
}
function Remove-ContentType {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $contentType = Get-ContentType -ContentTypeName $ContentTypeName -Web $web -ClientContext $ClientContext
        if($contentType -ne $null) {
            $contentType.DeleteObject()
            $ClientContext.ExecuteQuery()
        }
    }
    end {}
}
function Add-ContentType {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipeline=$true)][string]$Description = "Create a new $Name",
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Group,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ParentContentTypeName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $parentContentType = Get-ContentType -ContentTypeName $ParentContentTypeName -Web $web -ClientContext $ClientContext
        $contentType = $null
        if($parentContentType -eq $null) {
            Write-Warning "Error loading parent content type $ParentContentTypeName" -WarningAction Continue
        } else {

            $contentTypeCreationInformation = New-Object Microsoft.SharePoint.Client.ContentTypeCreationInformation
            $contentTypeCreationInformation.Name = $Name
            $contentTypeCreationInformation.Description = "Create a new $Name"
            $contentTypeCreationInformation.Group = $Group
            $contentTypeCreationInformation.ParentContentType = $parentContentType
            
            $contentType = $web.ContentTypes.Add($contentTypeCreationInformation)
            $ClientContext.load($contentType)
            $ClientContext.ExecuteQuery()
        }
        $contentType
    }
    end {}
}
function Add-ContentTypeWithID {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipeline=$true)][string]$Description = "Create a new $Name",
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Group,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ID,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $contentTypeCreationInformation = New-Object Microsoft.SharePoint.Client.ContentTypeCreationInformation
        $contentTypeCreationInformation.Name = $Name
        $contentTypeCreationInformation.Description = "Create a new $Name"
        $contentTypeCreationInformation.Group = $Group
        $contentTypeCreationInformation.ID = $ID
            
        $contentType = $web.ContentTypes.Add($contentTypeCreationInformation)
        $ClientContext.load($contentType)
        $ClientContext.ExecuteQuery()

        $contentType
    }
    end {}
}

function Add-FieldToContentType {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldId,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ContentType]$ContentType,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $field = Get-SiteColumn -fieldId $FieldId -Web $web -ClientContext $ClientContext
        $fieldlink = $null
        if($field -eq $null) {
            Write-Warning "Error getting field $FieldId" -ErrorAction Continue
        } else {
            $ClientContext.Load($ContentType.FieldLinks)
            $ClientContext.ExecuteQuery()
            $fieldlinkCreation = New-Object Microsoft.SharePoint.Client.FieldLinkCreationInformation
            $fieldlinkCreation.Field = $field
            $fieldlink = $ContentType.FieldLinks.Add($fieldlinkCreation)
            $ContentType.Update($true)
            $ClientContext.ExecuteQuery()
        }
        $fieldlink
    }
    end {}
}
function Get-FieldForContentType {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldId,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ContentType]$ContentType,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $fields = $ContentType.Fields
        $ClientContext.Load($fields)
        $ClientContext.ExecuteQuery()

        $field = $null
        $field = $fields | Where {$_.Id -eq $FieldId}
        $field
    }
    end {}
}
function Remove-FieldFromContentType {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldId,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ContentType]$ContentType,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $fieldLinks = $ContentType.FieldLinks
        $ClientContext.Load($fieldLinks)
        $ClientContext.ExecuteQuery()

        $fieldLink = $fieldLinks | Where {$_.Id -eq $FieldId}
        if($fieldLink -ne $null) {
            $fieldLink.DeleteObject()
            $ContentType.Update($true)
            $ClientContext.ExecuteQuery()
            Write-Verbose "Deleted field $fieldId from content type $($ContentType.Name)" -Verbose
        } else {
            Write-Verbose "Field $fieldId already deleted from content type $($ContentType.Name)"
        }
    }
    end {}
}
function Update-ContentTypeFieldLink {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Nullable[bool]]$Required,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Nullable[bool]]$Hidden,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.FieldLink]$FieldLink,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ContentType]$ContentType,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if($fieldLink -ne $null) {      
            $needsUpdating = $false
            if($Required -ne $null -and $fieldLink.Required -ne $Required) {
                $fieldLink.Required = $Required
                $needsUpdating = $true
            }
            if($Hidden -ne $null -and $fieldLink.Hidden -ne $Hidden) {
                $fieldLink.Hidden = $Hidden
                $needsUpdating = $true
            }
            if($needsUpdating) {
                $ContentType.Update($true)
                $ClientContext.ExecuteQuery()
                Write-Verbose "`tUpdated field link $fieldId for content type $($ContentType.Name)" -Verbose
            } else {
                Write-Verbose "`tDid not update field link $fieldId for content type $($ContentType.Name)"
            }
        } else {
            Write-Warning "Could not find field link $fieldId for content type $($ContentType.Name)" -WarningAction Continue
        }
    }
    end {}
}

function Remove-ContentTypes {
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$contentTypesXml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $ClientContext.Load($web.ContentTypes)
        $ClientContext.ExecuteQuery()

        # delete content types
        $contentTypesDeleted = $false
        foreach ($contentTypeXml in $contentTypesXml.RemoveContentType) {
            $contentType = $web.ContentTypes | Where {$_.Name -eq $ContentTypeXml.Name}
            if($contentType -ne $null) {
                 $contentType.DeleteObject()
                 $contentTypesDeleted = $true
            }
        }
        if($contentTypesDeleted) {
            $ClientContext.Load($web.ContentTypes)
            $ClientContext.ExecuteQuery()
        }
    }

}

function Update-ContentTypes {
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$contentTypesXml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $ClientContext.Load($web.ContentTypes)
        $ClientContext.Load($web.AvailableContentTypes)
        $ClientContext.Load($web.Fields)
        $ClientContext.ExecuteQuery()

        # delete content types
        $contentTypesDeleted = $false
        foreach ($contentTypeXml in $contentTypesXml.RemoveContentType) {
            $contentType = $web.ContentTypes | Where {$_.Name -eq $ContentTypeXml.Name}
            if($contentType -ne $null) {
                 $contentType.DeleteObject()
                 $contentTypesDeleted = $true
            }
        }
        if($contentTypesDeleted) {
            $ClientContext.Load($web.ContentTypes)
            $ClientContext.Load($web.AvailableContentTypes)
            $ClientContext.ExecuteQuery()
        }

        # Now add / update content types
        foreach ($contentTypeXml in $contentTypesXml.ContentType) {
            $contentType = $null

            # Perfer using content type id
            if($ContentType.ID) {
                $contentType = $web.ContentTypes | Where {$_.Id -eq $contentTypeXml.ID}
            }

            # Try using content type name
            if($contentType -eq $null) {
                $contentType = $web.ContentTypes | Where {$_.Name -eq $contentTypeXml.Name}
            }

            # need to create it
            if($contentType -eq $null) {
                
                # check to see if we have the parent content type avilable, if not, then can't create content type.
                $parentContentType = $web.AvailableContentTypes | Where {$_.Name -eq $contentTypeXml.ParentContentType}
                if($parentContentType -ne $null) {

                    $contentTypeCreationInformation = New-Object Microsoft.SharePoint.Client.ContentTypeCreationInformation
                    $contentTypeCreationInformation.Name = $contentTypeXml.Name
                    $contentTypeCreationInformation.Group = $contentTypeXml.Group

                    if($contentTypeXml.Description) {
                        $contentTypeCreationInformation.Description = $contentTypeXml.Description
                    } else {
                        $contentTypeCreationInformation.Description = "Create a new $Name"
                    }
                
                
                
                    if($contentTypeXml.ID) {
                        $contentTypeCreationInformation.ID = $contentTypeXml.ID
                    } else {
                        $contentTypeCreationInformation.ParentContentType = $parentContentType
                    }

                    $contentType = $web.ContentTypes.Add($contentTypeCreationInformation)
                    
                    $ClientContext.load($contentType)
                    $ClientContext.Load($web.ContentTypes)
                    $ClientContext.Load($web.AvailableContentTypes)
                    $ClientContext.ExecuteQuery()

                    if($contentType -eq $null) {
                        Write-Error "Could Not Create Content Type $($ContentType.Name)"
                    } else {
                        Write-Verbose "Created Content Type $($ContentType.Name)" -Verbose
                    }
                } else {
                    Write-Warning "Skipping Content Type $($contentTypeXml.Name), parent content type $($contentTypeXml.ParentContentType) unavilable" -WarningAction Continue
                }
            # rename if needed
            } elseif ($contentType.Name -ne $contentTypeXml.Name) {
                $contentType.Name = $contentTypeXml.Name
                $contentType.Update($true)
                $ClientContext.load($contentType)
                $ClientContext.Load($web.ContentTypes)
                $ClientContext.Load($web.AvailableContentTypes)
                $ClientContext.ExecuteQuery()
                Write-Verbose "Renamed Content Type $($ContentType.Name) ." -Verbose
            } else {
                Write-Verbose "Content Type $($ContentType.Name)  already created."
            }

            ## add / edit/ remove fieldlinks if we have a content type
            if($contentType -ne $null) {
                $ClientContext.Load($contentType.Fields)
                $ClientContext.Load($contentType.FieldLinks)
                $ClientContext.ExecuteQuery()


                # Delete fieldLinks
                $fieldLinksRemoved = $false
                foreach ($removeFieldRefXml in $contentTypeXml.FieldRefs.RemoveFieldRef) {
                    $fieldLinkToRemove = $contentType.FieldLinks | Where {$_.Id -eq $removeFieldRefXml.ID}
                    if($fieldLinkToRemove -ne $null) {
                        $fieldLinkToRemove.DeleteObject()
                        $fieldLinksRemoved = $true
                        Write-Verbose "Deleted field $($removeFieldRefXml.ID) from content type $($ContentType.Name)" -Verbose
                    } else {
                        Write-Verbose "Field $($removeFieldRefXml.ID) already deleted from content type $($ContentType.Name)"
                    }
                }
                if($fieldLinksRemoved) {
                    $contentType.Update($true)
                    $ClientContext.Load($contentType.FieldLinks)
                    $ClientContext.Load($contentType.Fields)
                    $ClientContext.ExecuteQuery()
                }


                # Add fieldLinks
                $fieldLinksAdded = $false
                foreach ($fieldRefXml in $contentTypeXml.FieldRefs.FieldRef) {
                    $field = $contentType.Fields | Where {$_.Id -eq $fieldRefXml.ID}
                
                    if($field -eq $null) {
                        $webField = $web.Fields | Where {$_.Id -eq $fieldRefXml.ID}
                        $fieldlinkCreation = New-Object Microsoft.SharePoint.Client.FieldLinkCreationInformation
                        $fieldlinkCreation.Field = $webField
                        $fieldlink = $contentType.FieldLinks.Add($fieldlinkCreation)
                        $fieldLinksAdded = $true

                        Write-Verbose "`tAdded field $($fieldRefXml.ID) to Content Type $($ContentType.Name)" -Verbose
                    } else {
                        Write-Verbose "`tField $($fieldRefXml.ID) already added to Content Type $($ContentType.Name)"
                    }
                }
                if($fieldLinksAdded) {
                    $contentType.Update($true)
                    $ClientContext.Load($contentType.Fields)
                    $ClientContext.Load($contentType.FieldLinks)
                    $ClientContext.ExecuteQuery()
                }

                # Update fieldLinks
                $needsUpdating = $false
                foreach ($fieldRefXml in $contentTypeXml.FieldRefs.FieldRef) {
                
                    $fieldLink = $contentType.FieldLinks | Where {$_.Id -eq $fieldRefXml.ID}

                    $Required = $null
                    if($fieldRefXml.Required) {
                        $Required = [bool]::Parse($fieldRefXml.Required)
                    }
                    $Hidden = $null
                    if($fieldRefXml.Hidden) {
                        $Hidden = [bool]::Parse($fieldRefXml.Hidden)
                    }

                    if($fieldLink -ne $null) {      

                        if($Required -ne $null -and $fieldLink.Required -ne $Required) {
                            $fieldLink.Required = $Required
                            $needsUpdating = $true
                        }
                        if($Hidden -ne $null -and $fieldLink.Hidden -ne $Hidden) {
                            $fieldLink.Hidden = $Hidden
                            $needsUpdating = $true
                        }
                        if($needsUpdating) {
                            Write-Verbose "`tUpdated field link $($fieldRefXml.ID) for content type $($contentType.Name)" -Verbose
                        } else {
                            Write-Verbose "`tDid not update field link $($fieldRefXml.ID) for content type $($contentType.Name)"
                        }
                    } else {
                        Write-Error "Could not find field link $($fieldRefXml.ID) for content type $($contentType.Name)"
                    }
                }
                if($needsUpdating) {
                    $ContentType.Update($true)
                    $ClientContext.ExecuteQuery()
                    Write-Verbose "`tUpdated field links for content type $($contentType.Name)" -Verbose
                } else {
                    Write-Verbose "`tDid not update field links for content type $($contentType.Name)"
                }
            }
        }
    }
}
#endregion

#region Features
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Features.psm1
function Add-Feature {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][guid]$FeatureId,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool]$fromSandboxSolution = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool]$force = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.FeatureCollection] $Features,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $FeatureDefinitionScope = [Microsoft.SharePoint.Client.FeatureDefinitionScope]::Farm
        if($fromSandboxSolution) {
            $FeatureDefinitionScope = [Microsoft.SharePoint.Client.FeatureDefinitionScope]::Site
        }
        $feature = $features | Where {$_.DefinitionId -eq $FeatureId}
        if($feature -eq $null) {
            $Features.Add($FeatureId, $force, $FeatureDefinitionScope)
            $ClientContext.ExecuteQuery()
            Write-Verbose "Activating Feature $FeatureId" -Verbose
        }
    }
}
function Remove-Feature {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][guid]$FeatureId,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool]$force = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.FeatureCollection] $Features,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $feature = $features | Where {$_.DefinitionId -eq $FeatureId}
        if($feature) {
            $features.Remove($featureId, $force)
            $ClientContext.ExecuteQuery()
             Write-Verbose "Deactivating Feature $FeatureId" -Verbose
        }
    }
}
function Add-Features {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FeaturesXml,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if($web) {
            $features = $web.Features
        } elseif($site) {
            $features = $site.Features
        }
        $ClientContext.Load($features)
        $ClientContext.ExecuteQuery()
        foreach($featureXml in $FeaturesXml.Feature) {
            $featureId = [guid] $featureXml.FeatureID
            $force = $false
            if($featureXml.Force) {
                $force = [bool]::Parse($featureXml.Force)
            }
            $SandboxSolution = $false
            if($featureXml.SandboxSolution) {
                $SandboxSolution = [bool]::Parse($featureXml.SandboxSolution)
            }
            Add-Feature -featureId $featureId -force $force -fromSandboxSolution $SandboxSolution -features $features -ClientContext $ClientContext
        }
    }
}
function Remove-Features {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FeaturesXml,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if($web) {
            $features = $web.Features
        } elseif($site) {
            $features = $site.Features
        }
        $ClientContext.Load($features)
        $ClientContext.ExecuteQuery()

        foreach($featureXml in $FeaturesXml.Feature) {
            $featureId = [guid] $featureXml.FeatureID
            $force = $false
            if($featureXml.Force) {
                $force = [bool]::Parse($featureXml.Force)
            }
            
            $feature = $features | Where {$_.DefinitionId -eq $FeatureId}
            if($feature) {
                $features.Remove($featureId, $force)
            }
            $ClientContext.ExecuteQuery()
        }
    }
}
#endregion

#region Files
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Files.psm1
function Get-ResourceFile {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FilePath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ResourcesPath,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext
    )
    process {
        $file = $null
        if ($RemoteContext) {
            $fileURL = $resourcesPath+"/"+$filePath.Replace('\', '/')
            $web = $RemoteContext.Web
            $file = $web.GetFileByServerRelativeUrl($fileURL)

            $data = $file.OpenBinaryStream();
            $RemoteContext.Load($file)
            $RemoteContext.ExecuteQuery()
            
            $memStream = New-Object System.IO.MemoryStream
            $data.Value.CopyTo($memStream)
            $file = $memStream.ToArray()

        } else {
             $file = Get-Content -Encoding byte -Path "$resourcesPath\$filePath"
        }
        $file
    }
}

function Get-XMLFile {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FilePath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ConfigPath,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext
    )
    process {
        $xml = New-Object XML
        if ($RemoteContext) {
            $fileURL = $configPath+"/"+$filePath.Replace('\', '/')
            $web = $RemoteContext.Web
            $file = $web.GetFileByServerRelativeUrl($fileURL)

            $data = $file.OpenBinaryStream();
            $RemoteContext.Load($file)
            $RemoteContext.ExecuteQuery()

            [System.IO.Stream]$stream = $data.Value

            $xml.load($stream);
        } else {
            $xml.load("$configPath\$filePath");
        }
        $xml

    }
}


function Upload-File {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FileXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ResourcesPath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $MinorVersionsEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $MajorVersionsEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $ContentApprovalEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $CheckOutRequired = $false
    )
    process {
        
        $folderServerRelativeUrl = $Folder.ServerRelativeUrl
		$fileRelativeUrl = $folderServerRelativeUrl + "/" + $FileXml.Url
        Write-Verbose "$($fileRelativeUrl)" -Verbose

		#get file and check it out if necessary
		if ($CheckOutRequired) {
			try {
				#Write-Verbose "`tFile check-out..." -Verbose
				$file = $ClientContext.web.GetFileByServerRelativeUrl($fileRelativeUrl)
				$file.CheckOut()
				$ClientContext.Load($file)
				$ClientContext.ExecuteQuery()
			}
			catch {
				#Write-Verbose "File not found, could not check it out before uploading." -Verbose
			}
		}

        $fileCreationInformation = New-Object Microsoft.SharePoint.Client.FileCreationInformation
        $fileCreationInformation.Url = "$($fileRelativeUrl)"
        $fileCreationInformation.Content = Get-ResourceFile -FilePath $FileXml.Path -ResourcesPath $ResourcesPath -RemoteContext $RemoteContext
        if($FileXml.ReplaceContent) {
            $replaceContent = $false
            $replaceContent = [bool]::Parse($FileXml.ReplaceContent)
            $fileCreationInformation.Overwrite = $replaceContent
        }
        
        
        $file = $Folder.Files.Add($fileCreationInformation)
        foreach($property in $FileXml.Property) {
            $property.Value = $property.Value -replace "~folderUrl", $folderServerRelativeUrl
            if($property.Name -ne "ContentType") {
                $file.ListItemAllFields[$property.Name] = $property.Value
            }
        }
        $file.ListItemAllFields.Update()
        $ClientContext.load($file)
        $ClientContext.ExecuteQuery()

        if($file.CheckOutType -ne [Microsoft.SharePoint.Client.CheckOutType]::None) {
			#Write-Verbose "`tFile check-in..." -Verbose
            $file.CheckIn("Check-in file", [Microsoft.SharePoint.Client.CheckinType]::MinorCheckIn)
            $ClientContext.Load($file)
            $ClientContext.ExecuteQuery()
        }

        if($FileXml.Level -eq "Published" -and $MinorVersionsEnabled -and $MajorVersionsEnabled) {
			#Write-Verbose "`tPublishing..." -Verbose
            $file.Publish("Published via scripted deployment.")
            $ClientContext.Load($file)
            $ClientContext.ExecuteQuery()
           # $file.CheckIn("Publishing File", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
        }

        if($FileXml.Approval -eq "Approved" -and $ContentApprovalEnabled) {
			#Write-Verbose "`tApproving..." -Verbose
            $file.Approve("Approving file")
            $ClientContext.ExecuteQuery()
        }
        
        $file
    }
}
function Add-Files {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FolderXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ResourcesPath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $MinorVersionsEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $MajorVersionsEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $ContentApprovalEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $CheckOutRequired = $false
    )
    process {
        Write-Verbose "$($folderXml.Path)" -Verbose

        foreach($fileXml in $FolderXml.File) {
            Write-Verbose "$($fileXml.Path)"
            $file = Upload-File -Folder $Folder -FileXml $fileXml -ResourcesPath $ResourcesPath `
                        -MinorVersionsEnabled $MinorVersionsEnabled -MajorVersionsEnabled $MajorVersionsEnabled -ContentApprovalEnabled $ContentApprovalEnabled `
                        -ClientContext $clientContext -RemoteContext $RemoteContext -CheckOutRequired $CheckOutRequired
        }

        foreach ($ProperyBagValue in $folderXml.PropertyBag.PropertyBagValue) {
            $Indexable = $false
            if($PropertyBagValue.Indexable) {
                $Indexable = [bool]::Parse($PropertyBagValue.Indexable)
            }

            Set-PropertyBagValue -Key $ProperyBagValue.Key -Value $ProperyBagValue.Value -Indexable $Indexable -Folder $Folder -ClientContext $ClientContext
        }

        foreach($childfolderXml in $FolderXml.Folder) {
            $childFolder = Get-Folder -Folder $Folder -Name $childfolderXml.Url -ClientContext $clientContext
            if($childFolder -eq $null) {
                $childFolder = $Folder.Folders.Add($childfolderXml.Url)
                $ClientContext.Load($childFolder)
                $ClientContext.ExecuteQuery()
            }
            Add-Files -Folder $childFolder -FolderXml $childfolderXml -ResourcesPath $ResourcesPath `
                -MinorVersionsEnabled $MinorVersionsEnabled -MajorVersionsEnabled $MajorVersionsEnabled -ContentApprovalEnabled $ContentApprovalEnabled `
                -ClientContext $clientContext -RemoteContext $RemoteContext -CheckOutRequired $CheckOutRequired
        }
    }
}

function Get-RootFolder {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $ClientContext.Load($List.RootFolder)
        $ClientContext.ExecuteQuery()
        $List.RootFolder
    }
}
function Get-Folder {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $folderToReturn = $null
        $ClientContext.Load($Folder.Folders)
        $ClientContext.ExecuteQuery()
        $folderToReturn = $Folder.Folders | Where {$_.Name -eq $Name}

        if($folderToReturn -ne $null) {
            $ClientContext.Load($folderToReturn)
            $ClientContext.ExecuteQuery()
        }

        $folderToReturn
    }
}

function Delete-File {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ServerRelativeUrl,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $file = $ClientContext.Web.GetFileByServerRelativeUrl($ServerRelativeUrl)
        $ClientContext.Load($file)
        $file.DeleteObject()
        $ClientContext.ExecuteQuery()
    }
}

#endregion

#region Items
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Items.psm1
function New-ListItem {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$listItemXml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List] $list,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    begin {
    }
    process {
        $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation 
        $newItem = $list.AddItem($listItemCreationInformation);
        Write-Verbose "Creating List Item"
        foreach($propertyXml in $listItemXml.Property) {
            if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                Write-Verbose "Setting TaxonomyField $($propertyXml.Name) to $($propertyXml.Value)"
                $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)

                if ($taxField.AllowMultipleValues) {
                    $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                    $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)

                    $taxField.SetFieldValueByValueCollection($newItem, $taxFieldValueCol);
                } else {
                    $newItem[$propertyXml.Name] = $propertyXml.Value
                }

            } else {
                Write-Verbose "Setting Field $($propertyXml.Name) to $($propertyXml.Value)"
                $newItem[$propertyXml.Name] = $propertyXml.Value
            }
        }
        $newItem.Update();
        $clientContext.Load($newItem)
        $clientContext.ExecuteQuery()
        Write-Verbose "Created List Item"
        $newItem
    }
    end {
    }
}
function Add-ListItems {
[cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$ItemsXml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List] $list,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    begin {
    }
    process {
        $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation 
        $newItem = $list.AddItem($listItemCreationInformation);
        Write-Verbose "Creating List Item"
        foreach($propertyXml in $listItemXml.Property) {
            if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                Write-Verbose "Setting TaxonomyField $($propertyXml.Name) to $($propertyXml.Value)"
                $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)
                $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)
                $taxField.SetFieldValueByValueCollection($newItem, $taxFieldValueCol);
            } else {
                Write-Verbose "Setting Field $($propertyXml.Name) to $($propertyXml.Value)"
                $newItem[$propertyXml.Name] = $propertyXml.Value
            }
        }
        $newItem.Update();
        $clientContext.Load($newItem)
        $clientContext.ExecuteQuery()
        Write-Verbose "Created List Item"
        $newItem
    }
    end {
    }
}
function Get-ListItem {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$itemUrl,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$folder = $null,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$list,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$clientContext
    )
    process {
        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($itemUrl)</Value></Eq></Where></Query></View>"
        if($folder) {
            $clientContext.Load($list.RootFolder)
            $clientContext.ExecuteQuery()
            $camlQuery.FolderServerRelativeUrl = "$($list.RootFolder.ServerRelativeUrl)/$($folder)"
            Write-Verbose "CamlQuery FolderServerRelativeUrl: $($camlQuery.FolderServerRelativeUrl)" -Verbose
        }
        $items = $list.GetItems($camlQuery)
        $clientContext.Load($items)
        $clientContext.ExecuteQuery()
        
        $item = $null
        if($items.Count -gt 0) {
            $item = $items[0]
            $clientContext.Load($item)
            $clientContext.ExecuteQuery()
        }
        $item
    }
    end {
    }
}
function Update-ListItem {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$listItemXml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$list,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$clientContext
    )
    process {
        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($listItemXml.Url)</Value></Eq></Where></Query></View>"
        if($listItemXml.folder) {
            $clientContext.Load($list.RootFolder)
            $clientContext.ExecuteQuery()
            $camlQuery.FolderServerRelativeUrl = "$($list.RootFolder.ServerRelativeUrl)/$($listItemXml.folder)"
            Write-Verbose "CamlQuery FolderServerRelativeUrl: $($camlQuery.FolderServerRelativeUrl)" -Verbose
        }
        $items = $list.GetItems($camlQuery)
        $clientContext.Load($items)
        $clientContext.ExecuteQuery()
        
        $item = $null
        if($items.Count -gt 0) {
            $item = $items[0]
            $clientContext.Load($list)
            $clientContext.Load($item)
            $clientContext.Load($item.File)
            $clientContext.Load($list.Fields)
            $clientContext.ExecuteQuery()
        }
        if($item -ne $null) {

            $MajorVersionsEnabled = $list.EnableVersioning
            $MinorVersionsEnabled = $list.EnableMinorVersions
            $ContentApprovalEnabled = $list.EnableModeration
            $CheckOutRequired = $list.ForceCheckout

            if($CheckOutRequired) {
                Write-Verbose "Checking-out item"
                $item.File.CheckOut()
            }

            foreach($propertyXml in $listItemXml.Property) {
                if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                    Write-Verbose "Setting TaxonomyField $($propertyXml.Name) to $($propertyXml.Value)"
                    $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                    $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)
                    $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                    $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)
                    $taxField.SetFieldValueByValueCollection($item, $taxFieldValueCol);
                } else {
                    Write-Verbose "Setting Field $($propertyXml.Name) to $($propertyXml.Value)"
                    $item[$propertyXml.Name] = $propertyXml.Value
                }
            }

            $item.Update()
            $ClientContext.load($item)
            $ClientContext.ExecuteQuery()

            $ClientContext.load($item.File)
            $ClientContext.ExecuteQuery()

            if($item.File.CheckOutType -ne [Microsoft.SharePoint.Client.CheckOutType]::None) {
                if($MinorVersionsEnabled) {
                    $item.File.CheckIn("Draft Check-in", [Microsoft.SharePoint.Client.CheckinType]::MinorCheckIn)
                } else {
                    $item.File.CheckIn("Check-in", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
                }
                $ClientContext.Load($item)
                $ClientContext.load($item.File)
                $ClientContext.ExecuteQuery()
            }
        
            if($listItemXml.Level -eq "Published" -and $MinorVersionsEnabled -and $MajorVersionsEnabled) {
                $item.File.Publish("Publishing Item")
                $ClientContext.Load($item)
                $ClientContext.ExecuteQuery()
            }
        }
    }
    end {
    }
}
function Remove-ListItem {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ListItem] $listItem, 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext] $ClientContext
    )
    process {
        if($listItem -ne $null) {
            $listItem.DeleteObject()
            $ClientContext.ExecuteQuery()
            Write-Verbose "Deleted List Item"
        }
    }
}
#endregion

#region Lists
#Source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Lists.psm1
function New-List {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$ListName,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Type,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Url,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][guid]$TemplateFeatureId,           
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext

   )
    process {
        
        $listCreationInformation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
        $listCreationInformation.Title = $ListName
        $listCreationInformation.TemplateType = $Type
        $listCreationInformation.Url = $Url
        
        if($TemplateFeatureId) {
            $listCreationInformation.TemplateFeatureId = $TemplateFeatureId
        }

        New-ListWithListCreationInformation -listCreationInformation $listCreationInformation -web $web -ClientContext $ClientContext
    }
    end {}
}
function New-ListFromXml {
 
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$listxml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
   )
    process {
        
        $listCreationInformation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
        if($listxml.Description) {
            $listCreationInformation.Description = $listxml.Description
        }
        if($listxml.OnQuickLaunchBar) {
            $onQuickLaunchBar = [bool]::Parse($listxml.OnQuickLaunchBar)
            if($onQuickLaunchBar){
                $listCreationInformation.QuickLaunchOption = [Microsoft.SharePoint.Client.QuickLaunchOptions]::On
            } elseif(!$onQuickLaunchBar) {
                $listCreationInformation.QuickLaunchOption = [Microsoft.SharePoint.Client.QuickLaunchOptions]::Off
            }
        }
        if($listxml.QuickLaunchOption) {
            $listCreationInformation.QuickLaunchOption = [Microsoft.SharePoint.Client.QuickLaunchOptions]::$($listxml.QuickLaunchOption)
        }
        if($listxml.TemplateFeatureId) {
            $listCreationInformation.TemplateFeatureId = $listxml.TemplateFeatureId
        }
        if($listxml.Type) {
            $listCreationInformation.TemplateType = $listxml.Type
        }
        if($listxml.Title) {
            $listCreationInformation.Title = $listxml.Title
        }
        if($listxml.Url) {
            $listCreationInformation.Url = $listxml.Url
        }

        New-ListWithListCreationInformation -listCreationInformation $listCreationInformation -web $web -ClientContext $ClientContext
    }
    end {}
}
function New-ListWithListCreationInformation {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ListCreationInformation]$listCreationInformation,           
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext

   )
    process {

        $list = $web.Lists.Add($listCreationInformation)
        
        $ClientContext.Load($list)
        $ClientContext.ExecuteQuery()
        
        $list
    }
    end {}
}
function Get-List {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ListName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $lists = $web.Lists
        $ClientContext.Load($lists)
        $ClientContext.ExecuteQuery()
        
        $list = $null
        $list = $lists | Where {$_.Title -eq $ListName}
        if($list -ne $null) {
            $ClientContext.Load($list)
            $ClientContext.ExecuteQuery()
        }
        $list
    }
}
function Remove-List {
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ListName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $list = Get-List -ListName $ListName -Web $web -ClientContext $ClientContext
        if($list -ne $null) {
            $list.DeleteObject()
            $ClientContext.ExecuteQuery()
        }
    }
}

function Get-ListView {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $views = $list.Views
        $ClientContext.load($views)
        $ClientContext.ExecuteQuery()
        
        $view = $null
        $view = $views | Where {$_.Title -eq $ViewName}
        if($view -ne $null) {
            $ClientContext.load($view)
            $ClientContext.ExecuteQuery()
        }
        $view
    }
}
function New-ListView {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$DefaultView,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$Paged,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$PersonalView,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Query,
		[parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Scope,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][int]$RowLimit,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$ViewFields,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewType,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $ViewTypeKind
        switch($ViewType) {
            "none"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::None}
            "html"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Html}
            "grid"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Grid}
            "calendar"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Calendar}
            "recurrence"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Recurrence}
            "chart"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Chart}
            "gantt"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Gantt}
        }
        $vCreation = New-Object Microsoft.SharePoint.Client.ViewCreationInformation
        $vCreation.Paged = $Paged
        $vCreation.PersonalView = $PersonalView
        $vCreation.Query = $Query
		#$vCreation.Scope = $Scope
        $vCreation.RowLimit = $RowLimit
        $vCreation.SetAsDefaultView = $DefaultView
        $vCreation.Title = $ViewName -replace '\s+', ''
        $vCreation.ViewFields = $ViewFields
        $vCreation.ViewTypeKind = $ViewTypeKind

        $view = $list.Views.Add($vCreation)

		$view.Title = $ViewName
		$view.Update()
        
		$list.Update()
        $ClientContext.ExecuteQuery()
        $view
    }
}
function Update-ListView {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$DefaultView,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$Paged,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Query,
		[parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Scope,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][int]$RowLimit,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$ViewFields,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $view = Get-ListView -List $List -ViewName $ViewName -ClientContext $ClientContext
        
        if($view -ne $null) {
            $view.Paged = $Paged
            $view.ViewQuery = $Query
            $view.RowLimit = $RowLimit
            $view.DefaultView = $DefaultView
			$view.Scope = $Scope
            #Write-Host $ViewFields
            $view.ViewFields.RemoveAll()
            ForEach ($vf in $ViewFields) {
                $view.ViewFields.Add($vf)
                #$ctx.Load($view.ViewFields)
                #$view.Update()
                #$List.Update()
                #$ClientContext.ExecuteQuery()
                #Write-Host "Add column $vf to view"
                #Write-Host $view.ViewFields
            }

            $view.Update()
            $List.Update()
            $ClientContext.ExecuteQuery()
        }
        $view
    }
}

function Get-ListContentType {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $contentTypes = $List.ContentTypes
        $ClientContext.load($contentTypes)
        $ClientContext.ExecuteQuery()
        
        $contentType = $null
        $contentType = $contentTypes | Where {$_.Name -eq $ContentTypeName}
        if($contentType -ne $null) {
            $ClientContext.load($contentType)
            $ClientContext.ExecuteQuery()
        }
        $contentType
    }
}
function Add-ListContentType {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext

   )
    process {
        $contentTypes = $web.AvailableContentTypes
        $ClientContext.Load($contentTypes)
        $ClientContext.ExecuteQuery()

        $contentType = $contentTypes | Where {$_.Name -eq $ContentTypeName}
        if($contentType -ne $null) {
            if(!$List.ContentTypesEnabled) {
                $List.ContentTypesEnabled = $true
            }
            $ct = $List.ContentTypes.AddExistingContentType($contentType);
            $List.Update()
            $ClientContext.ExecuteQuery()
        } else {
            $ct = $null
        }
        $ct
    }
    end {}
}
function Remove-ListContentType {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext

   )
    process {
        $contentTypeToDelete = Get-ListContentType $List $ClientContext -ContentTypeName $ContentTypeName
        
        if($contentTypeToDelete -ne $null) {
            if($contentTypeToDelete.Sealed) {
                $contentTypeToDelete.Sealed = $false
            }
            $contentTypeToDelete.DeleteObject()
            $List.Update()
            $ClientContext.ExecuteQuery()
        }
    }
}

function New-ListField {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
   )
    process {
        $field = $list.Fields.AddFieldAsXml($FieldXml, $true, ([Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldInternalNameHint))
        $ClientContext.Load($field)
        $ClientContext.ExecuteQuery()
        $field
    }
    end {}
}
function Get-ListField {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $Fields = $List.Fields
        $ClientContext.Load($Fields)
        $ClientContext.ExecuteQuery()
        
        $Field = $null
        $Field = $Fields | Where {$_.InternalName -eq $FieldName}
        $Field
    }
}
function Remove-ListField {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $Fields = $List.Fields
        $ClientContext.Load($Fields)
        $ClientContext.ExecuteQuery()
        
        $Field = $null
        $Field = $Fields | Where {$_.InternalName -eq $FieldName}
        if($Field -ne $null) {
            $Field.DeleteObject()
            $List.Update()
            $ClientContext.ExecuteQuery()
            Write-Verbose "`t`tDeleted List Field: $FieldName" -Verbose
        } else {
            Write-Verbose "`t`tField not found in list: $FieldName"
        }
    }
}

function Update-List {
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$listxml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $SPList = Get-List -ListName $listxml.Title -Web $web -ClientContext $ClientContext
        if($SPList -eq $null) {
            $SPList = New-ListFromXml -listxml $listxml -Web $web -ClientContext $ClientContext
            Write-Verbose "List created: $($listxml.Title)" -Verbose
        } else {
            Write-Verbose "`List already created: $($listxml.Title)" -Verbose
        }

        $MajorVersionsEnabled = $SPList.EnableVersioning
        $MinorVersionsEnabled = $SPList.EnableMinorVersions
        $ContentApprovalEnabled = $SPList.EnableModeration
        $CheckOutRequired = $SPList.ForceCheckout

        Write-Verbose "`tContent Types" -Verbose
	    foreach ($ct in $listxml.ContentType) {
            $spContentType = Get-ListContentType -List $SPList -ContentTypeName $ct.Name -ClientContext $ClientContext
		    if($spContentType -eq $null) {
                $spContentType = Add-ListContentType -List $SPList -ContentTypeName $ct.Name -Web $web -ClientContext $ClientContext
                if($spContentType -eq $null) {
                    Write-Error "`t`tContent Type could not be added: $($ct.Name)"
                } else {
                    Write-Verbose "`t`tContent Type added: $($ct.Name)" -Verbose
                }
            } else {
                Write-Verbose "`t`tContent Type already added: $($ct.Name)"
            }

            if($spContentType -ne $null -and $ct.Default -and [bool]::Parse($ct.Default)) {
                $newDefaultContentType = $spContentType.Id
                $folder = [SharePointClient.PSClientContext]::loadContentTypeOrderForFolder($SPList.RootFolder, $ClientContext)
                $currentContentTypeOrder = $folder.ContentTypeOrder
                $newDefaultContentTypeId = $null
                foreach($contentTypeId in $currentContentTypeOrder) {
                    if($($contentTypeId.StringValue).StartsWith($newDefaultContentType)) {
                        $newDefaultContentTypeId = $contentTypeId
                        break;
                    }
                }
                if($newDefaultContentTypeId) {
                    $currentContentTypeOrder.remove($newDefaultContentTypeId)
                    $currentContentTypeOrder.Insert(0, $newDefaultContentTypeId)
                    $folder.UniqueContentTypeOrder = $currentContentTypeOrder
                    $folder.Update()
                    $ClientContext.ExecuteQuery()
                }
            }
	    }
        foreach ($ct in $listxml.RemoveContentType) {
            $spContentType = Get-ListContentType -List $SPList -ContentTypeName $ct.Name -ClientContext $ClientContext
		    if($spContentType -ne $null) {
                Remove-ListContentType -List $SPList -ContentTypeName $ct.Name -ClientContext $ClientContext
                Write-Verbose "`t`tContent Type deleted: $($ct.Name)" -Verbose
            } else {
                Write-Verbose "`t`tContent Type already deleted: $($ct.Name)"
            }
        }

		Write-Verbose "`tFields" -Verbose
        foreach($field in $listxml.Fields.Field){
            $spField = Get-ListField -List $SPList -FieldName $Field.Name -ClientContext $ClientContext
            if($spField -eq $null) {
                $fieldStr = $field.OuterXml.Replace(" xmlns=`"http://schemas.microsoft.com/sharepoint/`"", "")
                $spField = New-ListField -FieldXml $fieldStr -List $splist -ClientContext $ClientContext
                Write-Verbose "`t`tCreated Field: $($Field.DisplayName)" -Verbose
            } else {
                Write-Verbose "`t`tField already added: $($Field.DisplayName)"
            }
        }
        
        $ClientContext.Load($SPList.Fields)
        $ClientContext.ExecuteQuery()

        foreach($Field in $listxml.Fields.UpdateField) {
            $spField = $null
            if($Field.ID) {
                $spField = $SPList.Fields | Where {$_.Id -eq $Field.ID}
            } elseif ($Field.Name) {
                $spField = Get-ListField -List $SPList -FieldName $Field.Name -ClientContext $ClientContext
            }

            if($spField -ne $null) {
                $needsUpdate = $false

                if($Field.Required) {
                    $Required = [bool]::Parse($Field.Required)
                    if($spField.Required -ne $Required) {
                        $spField.Required = $Required
                        Write-Verbose "`t`tUpdating Required for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

                if($Field.EnforceUniqueValues) {
                    $EnforceUniqueValues = [bool]::Parse($Field.EnforceUniqueValues)
                    if($spField.EnforceUniqueValues -ne $EnforceUniqueValues) {
                        $spField.EnforceUniqueValues = $EnforceUniqueValues
                        Write-Verbose "`t`tUpdating EnforceUniqueValues for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

                if($Field.Indexed) {
                    $Indexed = [bool]::Parse($Field.Indexed)
                    if($spField.Indexed -ne $Indexed) {
                        $spField.Indexed = $Indexed
                        Write-Verbose "`t`tUpdating Indexed for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

                if($Field.DisplayName) {
                    if($Field.DisplayName -ne $spField.Title) {
                        $spField.Title = $Field.DisplayName
                        Write-Verbose "`t`tUpdating DisplayName for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

				if($Field.Description) {
                    if($Field.Description -ne $spField.Description) {
                        $spField.Description = $Field.Description
                        Write-Verbose "`t`tUpdating Description for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

                if($Field.Formula ) {
                    $ValidationFormula = $Field.Formula
                    $ValidationFormula = $ValidationFormula -replace "&lt;","<"
                    $ValidationFormula = $ValidationFormula -replace "&gt;",">"
                    $ValidationFormula = $ValidationFormula -replace "&amp;","&"
                    if($spField.Formula  -ne $ValidationFormula) {
                        $spField.Formula  = $ValidationFormula
						Write-Verbose "`t`tUpdating Formula for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

				if($Field.ValidationFormula) {
                    if($spField.ValidationFormula -ne $Field.ValidationFormula) {
                        $spField.ValidationFormula = $Field.ValidationFormula
						Write-Verbose "`t`tUpdating ValidationFormula for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

				if($Field.ValidationMessage) {
                    if($spField.ValidationMessage -ne $Field.ValidationMessage) {
                        $spField.ValidationMessage = $Field.ValidationMessage
						Write-Verbose "`t`tUpdating ValidationMessage for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

                if($Field.ResultType) {
                    if($spField.OutputType -ne $Field.ResultType) {
                        $spField.OutputType = $Field.ResultType
						Write-Verbose "`t`tUpdating OutputType for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

				if($Field.Default) {
                    if($spField.DefaultValue -ne $Field.Default) {
                        $spField.DefaultValue = $Field.Default
						Write-Verbose "`t`tUpdating DefaultValue for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }

				if($Field.CHOICES) {
					$choicesList = New-Object 'System.Collections.Generic.List[string]'
					foreach($Choice in $Field.CHOICES.CHOICE) {
						$choicesList.Add($Choice)
					}
                    Write-Verbose "`t`tUpdating CHOICES for Field: $($Field.DisplayName)" -Verbose
					$spField.Choices = $choicesList.ToArray()
                    $needsUpdate = $true
                }

				<#
				# CSOM does not support this property
				if($Field.Decimals) {
                    if($spField.DisplayFormat -ne $Field.Decimals) {
                        $spField.DisplayFormat = $Field.Decimals
						Write-Verbose "`t`tUpdating DisplayFormat for Field: $($Field.DisplayName)" -Verbose
                        $needsUpdate = $true
                    }
                }
				#>

                if($needsUpdate -eq $true) {
                    $spField.Update()
                    $ClientContext.ExecuteQuery()
                    Write-Verbose "`t`tUpdated Field: $($Field.DisplayName)" -Verbose
                } else {
                    Write-Verbose "`t`tDid not need to update Field: $($Field.DisplayName)"
                }
            }
        }
        foreach($Field in $listxml.Fields.RemoveField) {
            Remove-ListField -List $SPList -FieldName $Field.Name -ClientContext $ClientContext
        }

        Write-Verbose "`tViews" -Verbose
        foreach ($view in $listxml.Views.RemoveView) {
            $spView = Get-ListView -List $SPList -ViewName $view.DisplayName -ClientContext $ClientContext
            if($spView -ne $null) {
                $spView.DeleteObject()
                $SPList.Update()
                $ClientContext.Load($SPList)
                $ClientContext.ExecuteQuery()
                Write-Verbose "`t`tRemoved List View: $($view.DisplayName)" -Verbose
            }
        }
        foreach ($view in $listxml.Views.View) {
            $spView = Get-ListView -List $SPList -ViewName $view.DisplayName -ClientContext $ClientContext
            if($spView -ne $null) {
            
                $Paged = [bool]::Parse($view.RowLimit.Paged)
                $DefaultView = [bool]::Parse($view.DefaultView)
                $RowLimit = $view.RowLimit.InnerText
                $Query = $view.Query.InnerXml.Replace(" xmlns=`"http://schemas.microsoft.com/sharepoint/`"", "")
                $ViewFields = $view.ViewFields.FieldRef | Select -ExpandProperty Name
				$Scope = $view.Scope
				if(!$Scope){$Scope = "DefaultValue"}
                $spView = Update-ListView -List $splist -ViewName $view.DisplayName -Paged $Paged -Query $Query -Scope $Scope -RowLimit $RowLimit -DefaultView $DefaultView -ViewFields $ViewFields -ClientContext $ClientContext
                Write-Verbose "`t`tUpdated List View: $($view.DisplayName)" -Verbose
            } else {
            
                $Paged = [bool]::Parse($view.RowLimit.Paged)
                $PersonalView = [bool]::Parse($view.PersonalView)
                $DefaultView = [bool]::Parse($view.DefaultView)
                $RowLimit = $view.RowLimit.InnerText
                $Query = $view.Query.InnerXml.Replace(" xmlns=`"http://schemas.microsoft.com/sharepoint/`"", "")
                $ViewFields = $view.ViewFields.FieldRef | Select -ExpandProperty Name
				$Scope = $view.Scope
				if(!$Scope){$Scope = "DefaultValue"}
                $ViewType = $view.Type
                $spView = New-ListView -List $splist -ViewName $view.DisplayName -Paged $Paged -PersonalView $PersonalView -Query $Query -Scope $Scope -RowLimit $RowLimit -DefaultView $DefaultView -ViewFields $ViewFields -ViewType $ViewType -ClientContext $ClientContext
                Write-Verbose "`t`tCreated List View: $($view.DisplayName)" -Verbose
            }
        }

        Write-Verbose "`tFiles and Folders" -Verbose
        if($listxml.DeleteItems) {
            foreach($itemXml in $listxml.DeleteItems.Item) {
                $item = Get-ListItem -itemUrl $itemXml.Url -Folder $itemXml.Folder -List $SPList -ClientContext $clientContext
                if($item -ne $null) {
                    Remove-ListItem -listItem $item -ClientContext $clientContext
                }
            }
        }
        if($listxml.UpdateItems) {
            foreach($itemXml in $listxml.UpdateItems.Item) {
                Update-ListItem -listItemXml $itemXml -List $SPList -ClientContext $clientContext 
            }
        }

        foreach($folderXml in $listxml.Folder) {
            Write-Verbose "`t`t$($folderXml.Url)" -Verbose
            $spFolder = Get-RootFolder -List $SPList -ClientContext $ClientContext
            Add-Files -Folder $spFolder -FolderXml $folderXml -ResourcesPath $ResourcesPath `
                -MinorVersionsEnabled $MinorVersionsEnabled -MajorVersionsEnabled $MajorVersionsEnabled -ContentApprovalEnabled $ContentApprovalEnabled `
                -ClientContext $clientContext -RemoteContext $RemoteContext 
        }

        Write-Verbose "`tPropertyBag Values" -Verbose
        foreach ($ProperyBagValueXml in $listxml.PropertyBag.PropertyBagValue) {
            $Indexable = $false
            if($ProperyBagValueXml.Indexable) {
                $Indexable = [bool]::Parse($ProperyBagValueXml.Indexable)
            }

            Set-PropertyBagValue -Key $ProperyBagValueXml.Key -Value $ProperyBagValueXml.Value -Indexable $Indexable -List $SPList -ClientContext $ClientContext
        }
        
        Write-Verbose "`tUpdating Other List Settings" -Verbose
        $listNeedsUpdate = $false
        
        if($listxml.ContentTypesEnabled) {
            $contentTypesEnabled = [bool]::Parse($listxml.ContentTypesEnabled )
            if($SPList.ContentTypesEnabled -ne $contentTypesEnabled) {
                $SPList.ContentTypesEnabled = $contentTypesEnabled
                Write-Verbose "`t`tUpdating ContentTypesEnabled"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.Description) {
            $description = $listxml.Description
            if($SPList.Description -ne $description) {
                $SPList.Description = $description
                Write-Verbose "`t`tUpdating Description"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableAttachments) {
            $enableAttachments = [bool]::Parse($listxml.EnableAttachments  )
            if($SPList.EnableAttachments -ne $enableAttachments) {
                $SPList.EnableAttachments = $enableAttachments
                Write-Verbose "`t`tUpdating EnableAttachments"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableFolderCreation ) {
            $enableFolderCreation = [bool]::Parse($listxml.EnableFolderCreation  )
            if($SPList.EnableFolderCreation -ne $enableFolderCreation) {
                $SPList.EnableFolderCreation = $enableFolderCreation
                Write-Verbose "`t`tUpdating EnableFolderCreation"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableMinorVersions) {
            $enableMinorVersions = [bool]::Parse($listxml.EnableMinorVersions)
            if($SPList.EnableMinorVersions -ne $enableMinorVersions) {
                $SPList.EnableMinorVersions = $enableMinorVersions
                Write-Verbose "`t`tUpdating EnableMinorVersions"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableModeration) {
            $enableModeration = [bool]::Parse($listxml.EnableModeration)
            if($SPList.EnableModeration -ne $enableModeration) {
                $SPList.EnableModeration = $enableModeration
                Write-Verbose "`t`tUpdating EnableModeration"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableVersioning) {
            $enableVersioning = [bool]::Parse($listxml.EnableVersioning)
            if($SPList.EnableVersioning -ne $enableVersioning) {
                $SPList.EnableVersioning = $enableVersioning
                Write-Verbose "`t`tUpdating EnableVersioning"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.ForceCheckout) {
            $forceCheckout = [bool]::Parse($listxml.ForceCheckout)
            if($SPList.ForceCheckout -ne $forceCheckout) {
                $SPList.ForceCheckout = $forceCheckout
                Write-Verbose "`t`tUpdating ForceCheckout"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.Hidden) {
            $hidden = [bool]::Parse($listxml.Hidden)
            if($SPList.Hidden -ne $hidden) {
                $SPList.Hidden = $hidden
                Write-Verbose "`t`tUpdating Hidden"
                $listNeedsUpdate = $true
            }
        }
        <#
        if($listxml.OnQuickLaunchBar) {
            $onQuickLaunchBar = [bool]::Parse($listxml.OnQuickLaunchBar)
            if($SPList.OnQuickLaunch -ne $onQuickLaunchBar) {
                $SPList.OnQuickLaunch = $onQuickLaunchBar
                Write-Verbose "`t`tUpdating OnQuickLaunchBar"
                $listNeedsUpdate = $true
            }
        }
        #>
        if($listxml.NoCrawl) {
            $noCrawl = [bool]::Parse($listxml.NoCrawl)
            if($SPList.NoCrawl -ne $noCrawl) {
                $SPList.NoCrawl = $noCrawl
                Write-Verbose "`t`tUpdating NoCrawl"
                $listNeedsUpdate = $true
            }
        }

		if ($listxml.Validation.InnerText) {
			if ($SPList.ValidationFormula -ne $listxml.Validation.InnerText) {
				$SPList.ValidationFormula = $listxml.Validation.InnerText
				Write-Verbose "`t`tUpdating ValidationFormula"
                $listNeedsUpdate = $true
			}
		}

		if ($listxml.Validation.Message) {
			if ($SPList.ValidationMessage -ne $listxml.Validation.Message) {
				$SPList.ValidationMessage = $listxml.Validation.Message
				Write-Verbose "`t`tUpdating ValidationMessage"
                $listNeedsUpdate = $true
			}
		}
		
        if($listNeedsUpdate) {
            $SPList.Update()
            $ClientContext.Load($SPList)
            $ClientContext.ExecuteQuery()
            Write-Verbose "`t`tUpdated List Settings" -Verbose
        }
        $SPList
        
    }
    end{
    }
}
#endregion

#region Load-CSOM
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Load-CSOM.psm1
function Add-PSClientContext {
    $assemblies = @( 
        [System.Reflection.Assembly]::GetAssembly([Microsoft.SharePoint.Client.ClientContext]).FullName,
        [System.Reflection.Assembly]::GetAssembly([Microsoft.SharePoint.Client.Taxonomy.TaxonomyField]).FullName,
        [System.Reflection.Assembly]::GetAssembly([Microsoft.SharePoint.Client.ClientRuntimeContext]).FullName
    )
    Add-Type -ReferencedAssemblies $assemblies -TypeDefinition @"
using Microsoft.SharePoint.Client;
using Microsoft.SharePoint.Client.Taxonomy;
namespace SharePointClient
{
    public class PSClientContext: ClientContext
    {
        public PSClientContext(string siteUrl)
            : base(siteUrl)
        {
        }
        // need a plain Load method here, the base method is a generic method
        // which isn't supported in PowerShell.
        public void Load(ClientObject objectToLoad)
        {
            base.Load(objectToLoad);
        }
        public static TaxonomyField CastToTaxonomyField (ClientContext ctx, Field field)
        {
            return ctx.CastTo<TaxonomyField>(field);
        }
        public static void Load (ClientContext ctx, ClientObject objectToLoad)
        {
            ctx.Load(objectToLoad);
        }
        public TaxonomyField CastToTaxonomyField (Field field)
        {
            return base.CastTo<TaxonomyField>(field);
        }
        public static Folder loadContentTypeOrderForFolder(Folder folder, ClientContext ctx) {
            ctx.Load(folder, f => f.UniqueContentTypeOrder, f => f.ContentTypeOrder);
            ctx.ExecuteQuery();
            return folder;
        }
        public static void CreateWebRoleAssignment(ClientContext clientContext, Web web, string groupName, string roleDefName) {
            clientContext.Load(web);
            clientContext.ExecuteQuery(); 
            
            var grp = web.SiteGroups.GetByName(groupName);
            
            RoleDefinitionBindingCollection rdb = new RoleDefinitionBindingCollection(clientContext);
            rdb.Add(web.RoleDefinitions.GetByName(roleDefName));
            web.RoleAssignments.Add(grp, rdb);
            
            clientContext.ExecuteQuery(); 
        } 
        public static void AddUserToGroup(ClientContext clientContext, Web web, string groupName, string userLoginName) {
            
            var grp = web.SiteGroups.GetByName(groupName);
            clientContext.Load(grp);
            clientContext.ExecuteQuery(); 
            
		    grp.Users.Add(new UserCreationInformation() {LoginName = userLoginName});
		    grp.Update();
            
            clientContext.ExecuteQuery(); 
        } 
    }
}
"@

}


function Add-CSOM {
    $CSOMdir = "${env:CommonProgramFiles}\microsoft shared\Web Server Extensions\16\ISAPI"
    $excludeDlls = "*.Portable.dll"
    
    if ((Test-Path $CSOMdir -pathType container) -ne $true)
    {
        $CSOMdir = "${env:CommonProgramFiles}\microsoft shared\Web Server Extensions\15\ISAPI"
        if ((Test-Path $CSOMdir -pathType container) -ne $true)
        {
            Throw "Please install the SharePoint 2013[1] or SharePoint Online[2] Client Components SDK`n `n[1] http://www.microsoft.com/en-us/download/details.aspx?id=35585`n[2] http://www.microsoft.com/en-us/download/details.aspx?id=42038`n `n "
        }
    }
    
    
    $CSOMdlls = Get-Item "$CSOMdir\*.dll" -exclude $excludeDlls
    
    ForEach ($dll in $CSOMdlls) {
        [System.Reflection.Assembly]::LoadFrom($dll.FullName) | Out-Null
    }

    Add-PSClientContext
    
}

function Add-TenantCSOM {
    $tenantDllPath = "${env:ProgramFiles}\SharePoint Client Components\16.0\Assemblies"
    if((Test-Path $tenantDllPath -pathType container) -ne $true) {
        Throw "Please install the SharePoint Online Client Components SDK[1]`n `n[1] http://www.microsoft.com/en-us/download/details.aspx?id=42038`n `n "
    }

    $tenantDll =  Get-Item "$tenantDllPath\Microsoft.Online.SharePoint.Client.Tenant.dll"
    [System.Reflection.Assembly]::LoadFrom($tenantDll.FullName) | Out-Null

}

function Add-PreloadedSPdlls {
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Taxonomy") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Publishing") | Out-Null
    
    Add-PSClientContext
}


function Add-PreloadedSPTenantdlls {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Online.SharePoint.Client.Tenant") | Out-Null

}

function Add-InternalDlls {
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string] $assemblyPath,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool]$loadversion15dlls = $true,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool]$loadversion16dlls = $false
    )
    process {
        if($loadversion15dlls) {
            $spVersion15Dlls = Get-Item "$assemblyPath\15\*.dll"
    
            ForEach ($dll in $spVersion15Dlls) {
                [System.Reflection.Assembly]::LoadFrom($dll.FullName) | Out-Null
            }
        } elseif ($loadversion16dlls) {
            $spVersion16Dlls = Get-Item "$assemblyPath\16\*.dll"
    
            ForEach ($dll in $spVersion16Dlls) {
                [System.Reflection.Assembly]::LoadFrom($dll.FullName) | Out-Null
            }
        }

        $internalDlls = Get-Item "$assemblyPath\*.dll"
    
        ForEach ($dll in $internalDlls) {
            [System.Reflection.Assembly]::LoadFrom($dll.FullName) | Out-Null
        }

        Add-PSClientContext
    }
}
#endregion

#region ManagedProperties
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/ManagedProperties.psm1
function Update-ManagedProperty {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][string]$ManagedPropertyName,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][string]$CrawledProperties = "",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][string]$Level = "tenant",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][string]$Alias = "",
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    begin {
    }
    process {
        $managedProperty = New-Object SharePointCSOM.Remote.Core.HttpCommands.RequestManagedPropertySettings($ClientContext.Url, $ClientContext.Credentials);
        $managedProperty.ManagedProperty = $ManagedPropertyName #"RefinableString99";
        $managedProperty.CrawledProperties = $CrawledProperties #'"ows_Title"+"00130329-0000-0130-c000-000000131346;ows_Title"+'#"People:JLLRegion"+"00110329-0000-0110-c000-000000111146;urn:schemas-microsoft-com:sharepoint:portal:profile:JLLRegion"+';
        $managedProperty.Level = $Level;
        $managedProperty.Alias = $Alias;
        $managedProperty.Execute();
    }
    end {}
}
#endregion

#region Permissions
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Permissions.psm1
function Set-BreakRoleInheritance  {
    <#
    http://msdn.microsoft.com/en-us/library/office/microsoft.sharepoint.client.securableobject.breakroleinheritance(v=office.15).aspx
    #>
    param (
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool] $copyRoleAssignments = $true,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool] $clearSubscopes = $true,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.SecurableObject] $securableObject,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $securableObject.BreakRoleInheritance($copyRoleAssignments, $clearSubscopes)
        $clientContext.ExecuteQuery();
    }
    end {} 
}
function Reset-RoleInheritance  {
    <#
    http://msdn.microsoft.com/en-us/library/office/microsoft.sharepoint.client.securableobject.resetroleinheritance(v=office.15).aspx
    #>
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.SecurableObject] $securableObject,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $securableObject.ResetRoleInheritance()
        $clientContext.ExecuteQuery();
    }
    end {} 
}

function Get-SiteGroup {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$GroupName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $groups = $web.SiteGroups
        $ClientContext.Load($groups);
        $ClientContext.ExecuteQuery();
        $group = $groups | Where {$_.Title -eq $GroupName}
        $group
    }
}

function New-SiteGroup {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$GroupName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $groupCreationInformation = New-Object Microsoft.SharePoint.Client.GroupCreationInformation
        $groupCreationInformation.Title = $GroupName
        $spGroup = $web.SiteGroups.Add($groupCreationInformation)
        $spGroup.Update();
        $ClientContext.Load($spGroup);
        $ClientContext.ExecuteQuery();
        $spGroup
    }
}
#endregion

#region PropertyBag
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/PropertyBag.psm1
function Set-IndexableProperty {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Key,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $indexedPropertyBagKey = "vti_indexedpropertykeys"

        $oldIndexedValues = Get-PropertyBagValue -Key $indexedPropertyBagKey -Web $Web -ClientContext $ClientContext

        $keyBytes = [System.Text.Encoding]::Unicode.GetBytes($Key)
        $encodedKey = [Convert]::ToBase64String($keyBytes)
        
        if($oldIndexedValues -NotLike "*$encodedKey*") {
            $Web.AllProperties[$indexedPropertyBagKey] = "$oldIndexedValues$encodedKey|"
        }
    }
}
function Set-PropertyBagValue {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Key,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$Value = $null,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool]$Indexable = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site]$Site,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $indexedPropertyBagKey = "vti_indexedpropertykeys"
        Write-Verbose "Set-PropertyBagValue Key: $Key Value: $Value Indexable: $Indexable" -Verbose
        if($Site) {

            if($Indexable) {
                $oldIndexedValues = Get-PropertyBagValue -Key $indexedPropertyBagKey -Site $Site -ClientContext $ClientContext

                $keyBytes = [System.Text.Encoding]::Unicode.GetBytes($Key)
                $encodedKey = [Convert]::ToBase64String($keyBytes)
        
                if($oldIndexedValues -NotLike "*$encodedKey*") {
                    $Site.RootWeb.AllProperties[$indexedPropertyBagKey] = "$oldIndexedValues$encodedKey|"
                }
            }


            $Site.RootWeb.AllProperties[$Key] = $Value
            $Site.RootWeb.Update()
            $ClientContext.Load($Site)
            $ClientContext.Load($Site.RootWeb)
            $ClientContext.Load($Site.RootWeb.AllProperties)
            $ClientContext.ExecuteQuery()

        } elseif($Web) {
            if($Indexable) {
                $oldIndexedValues = Get-PropertyBagValue -Key $indexedPropertyBagKey -Web $Web -ClientContext $ClientContext

                $keyBytes = [System.Text.Encoding]::Unicode.GetBytes($Key)
                $encodedKey = [Convert]::ToBase64String($keyBytes)
        
                if($oldIndexedValues -NotLike "*$encodedKey*") {
                    $Web.AllProperties[$indexedPropertyBagKey] = "$oldIndexedValues$encodedKey|"
                }
            }

            $Web.AllProperties[$Key] = $Value
            $Web.Update()
            $ClientContext.Load($Web)
            $ClientContext.Load($Web.AllProperties)
            $ClientContext.ExecuteQuery()

        } elseif($List) {
            if($Indexable) {
                $oldIndexedValues = Get-PropertyBagValue -Key $indexedPropertyBagKey -List $List -ClientContext $ClientContext

                $keyBytes = [System.Text.Encoding]::Unicode.GetBytes($Key)
                $encodedKey = [Convert]::ToBase64String($keyBytes)
        
                if($oldIndexedValues -NotLike "*$encodedKey*") {
                    $List.RootFolder.Properties[$indexedPropertyBagKey] = "$oldIndexedValues$encodedKey|"
                }
            }
            $List.RootFolder.Properties[$Key] = $Value
            $List.RootFolder.Update()
            $List.Update()
            $ClientContext.Load($List)
            $ClientContext.Load($List.RootFolder)
            $ClientContext.Load($List.RootFolder.Properties)
            $ClientContext.ExecuteQuery()

        } elseif($Folder) {
            if($Indexable) {
                $oldIndexedValues = Get-PropertyBagValue -Key $indexedPropertyBagKey -Folder $Folder -ClientContext $ClientContext

                $keyBytes = [System.Text.Encoding]::Unicode.GetBytes($Key)
                $encodedKey = [Convert]::ToBase64String($keyBytes)
        
                if($oldIndexedValues -NotLike "*$encodedKey*") {
                    $Folder.Properties[$indexedPropertyBagKey] = "$oldIndexedValues$encodedKey|"
                }
            }
            $Folder.Properties[$Key] = $Value
            $Folder.Update()
            $ClientContext.Load($Folder)
            $ClientContext.Load($Folder.Properties)
            $ClientContext.ExecuteQuery()

        } else {
            return $null
        }
    }
}
function Remove-PropertyBagValue {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Key,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site]$Site,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if($Site) {

            $Site.RootWeb.AllProperties[$Key] = ""
            $Site.RootWeb.Update()
            $ClientContext.Load($Site)
            $ClientContext.ExecuteQuery()

        } elseif($Web) {
            $Web.AllProperties[$Key] = ""
            $Web.Update()
            $ClientContext.Load($Web)
            $ClientContext.ExecuteQuery()

        } elseif($List) {

            $List.RootFolder.Properties[$Key] = ""
            $List.RootFolder.Update()
            $ClientContext.Load($List)
            $ClientContext.ExecuteQuery()

        } elseif($Folder) {

            $Folder.Properties[$Key] = ""
            $Folder.Update()
            $ClientContext.Load($Folder)
            $ClientContext.ExecuteQuery()

        } else {
            return $null
        }
    }
}
function Get-PropertyBagValue {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Key,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site]$Site,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $value = ""

        if($Site) {
            $ClientContext.Load($Site)
            $ClientContext.ExecuteQuery()
            $properties = $Site.RootWeb.AllProperties 
        } elseif($Web) {
            $ClientContext.Load($Web)
            $ClientContext.ExecuteQuery()
            $properties = $Web.AllProperties
        } elseif($List) {
            $ClientContext.Load($List)
            $ClientContext.ExecuteQuery()
            $properties = $List.RootFolder.Properties
        } elseif($Folder) {
            $ClientContext.Load($Folder)
            $ClientContext.ExecuteQuery()
            $properties = $Folder.Properties
        } else {
            return $value 
        }


        $ClientContext.Load($properties)
        $ClientContext.ExecuteQuery()

        $fieldValue = $properties.FieldValues[$Key]
        
        if($fieldValue -ne $null) {
            $value = $fieldValue.ToString()
        }
        $value
    }
}


function Set-PropertyBagMetadataValues {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][Hashtable]$Properties,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][Hashtable]$MetadataSingleFields,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][Hashtable]$MetadataMultiFields,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$MetadataList,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool]$Indexable = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site]$Site,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$MetadataListClientContext
         
    )
    process {
        if (!$MetadataListClientContext) {
            $MetadataListClientContext = $ClientContext
        }

        $metadataMultiValues = {}.Invoke()
        $metadataSingleValues = {}.Invoke()

        foreach($property in $Properties.GetEnumerator()) {
            $key = $property.Key
            $value = $property.Value
            if ($MetadataMultiFields.ContainsKey($key)) {
                $metadataMultiValues.Add($property)
            } Elseif ($MetadataSingleFields.ContainsKey($key)) {
                $metadataSingleValues.Add($property)
            } else {
                 Set-PropertyBagValue -Key $key -Value $value -Indexable $true -Web $Web -ClientContext $clientContext
            }
           
        }

        $xml = [xml]@"
<Item>
<Property Name="Title"  Value="Test item"/>
</Item>
"@


        foreach($property in $metadataMultiValues) {
            $prop = $xml.CreateElement('Property')
            $prop.SetAttribute('Name', $MetadataMultiFields[$property.Key])
            $prop.SetAttribute('Type', 'TaxonomyField')
            $prop.SetAttribute('Value', $property.Value)
            $xml.Item.AppendChild($prop)
        }

        foreach($property in $metadataSingleValues) {
            $prop = $xml.CreateElement('Property')
            $prop.SetAttribute('Name', $MetadataSingleFields[$property.Key])
            $prop.SetAttribute('Type', 'TaxonomyField')
            $prop.SetAttribute('Value', $property.Value)
            $xml.Item.AppendChild($prop)
        }
        Write-Output $xml.OuterXml
        $item = New-ListItem $xml.Item $MetadataList $MetadataListClientContext

        foreach($property in $metadataMultiValues) {
            $fieldValue = $item[$MetadataMultiFields[$property.Key]] 
            $propertyBagKeyPrefix = $property.Key
            $propertyBagValue = ""
            $propertyBagKeySuffix = "00"
            $propertyBagKeyTaxSuffix = "ID"
            $propertyBagKeySearchSuffix = "Search"
            $count = 0
            $maxCount = 9
            foreach($term in $fieldValue) {
                $propertyBagKey = $propertyBagKeyPrefix + $count.ToString().PadLeft(2,"0")
                Set-PropertyBagValue -Key $propertyBagKey -Value $term.Label -Indexable $true -Web $web -ClientContext $ClientContext
                $propertyBagValue += [string]::Format("{0};#{1}|{2};#", $term.WssId, $term.Label, $term.TermGuid)
                $count++
            }
            for($count; $count -le $maxCount; $count++) {
                $propertyBagKey = $propertyBagKeyPrefix + $count.ToString().PadLeft(2,"0")
                Set-PropertyBagValue -Key $propertyBagKey -Indexable $true -Web $web -ClientContext $ClientContext
            }
            # set old key to no value
            Set-PropertyBagValue -Key $propertyBagKeyPrefix -Indexable $true -Web $web -ClientContext $ClientContext
            if($propertyBagValue -ne "") {
                
                $propertyBagValue = $propertyBagValue.Substring(0,$propertyBagValue.Length-2) # remove trailing ;#
                $propertyBagKey = "$propertyBagKeyPrefix$propertyBagKeyTaxSuffix" 
                Set-PropertyBagValue -Key $propertyBagKey -Value $propertyBagValue -Indexable $true -Web $web -ClientContext $ClientContext
                

                $propertyBagSearchValues = ""
                foreach($term in $fieldValue) {

                    $propertyBagSearchValues += [string]::Format("#0{0} ",$term.TermGuid)
                    
                }
                $propertyBagSearchValues = $propertyBagSearchValues.Substring(0,$propertyBagSearchValues.Length-1) # remove trailing space
                $propertyBagKey = "$propertyBagKeyPrefix$propertyBagKeySearchSuffix"
                Set-PropertyBagValue -Key $propertyBagKey -Value $propertyBagSearchValues -Indexable $true -Web $web -ClientContext $ClientContext
            }


        }

        foreach($property in $metadataSingleValues) {
            $fieldValue = $item[$MetadataSingleFields[$property.Key]] 
            $propertyBagKeyPrefix = $property.Key
            $propertyBagValue = ""
            $propertyBagKeySuffix = "00"
            $propertyBagKeyTaxSuffix = "ID"
            $propertyBagKey = $propertyBagKeyPrefix

            $propertyBagKey = "$propertyBagKeyPrefix$propertyBagKeyTaxSuffix"
            if ($fieldValue) {
                Set-PropertyBagValue -Key $propertyBagKeyPrefix -Value $fieldValue.Label -Indexable $true -Web $web -ClientContext $ClientContext
                $propertyBagValue = [string]::Format("{0};#{1}|{2}", $fieldValue.WssId, $fieldValue.Label, $fieldValue.TermGuid)
                Set-PropertyBagValue -Key $propertyBagKey -Value $propertyBagValue -Indexable $true -Web $web -ClientContext $ClientContext

            } else {
                Set-PropertyBagValue -Key $propertyBagKeyPrefix -Indexable $true -Web $web -ClientContext $ClientContext
                Set-PropertyBagValue -Key $propertyBagKey -Value $propertyBagValue -Indexable $true -Web $web -ClientContext $ClientContext
            }
        }


        #Remove-ListItem $item $ClientContext

    }
}
#endregion

#region Publishing
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Publishing.psm1
function Get-PublishingPage {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$pageUrl,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$clientContext
    )
    process {
        Write-Verbose "Getting page $($pageUrl)" -Verbose
        $pagesLibrary = $web.Lists.GetByTitle("Pages")
        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($pageUrl)</Value></Eq></Where></Query></View>"
        $items = $pagesLibrary.GetItems($camlQuery)
        $ClientContext.Load($items)
        $ClientContext.ExecuteQuery()
        
        $page = $null
        if($items.Count -gt 0) {
            $page = $items[0]
            $ClientContext.Load($page)
            $ClientContext.ExecuteQuery()
        }
        $page
    }
    end {
    }
}

function Remove-PublishingPage {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ListItem]$PublishingPage,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $PublishingPage.DeleteObject()
        $ClientContext.ExecuteQuery()
    }
    end{}
}

function New-PublishingPage {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$PageXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $pageAlreadyExists = $false
        $replaceContent = $false
        if($PageXml.ReplaceContent) {
            $replaceContent = [bool]::Parse($PageXml.ReplaceContent)
        }

        # Get List information
        $pagesList = $Web.Lists.GetByTitle("Pages")
		$clientContext.Load($pagesList)

        # Check for existing Page
		$existingPageCamlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
		$existingPageCamlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($PageXml.Url)</Value></Eq></Where></Query></View>"
		$existingPageListItems = $pagesList.GetItems($existingPageCamlQuery)
		$clientContext.Load($existingPageListItems)

        # Get Page Layout
        Write-Verbose "Getting Page Layout $($PageXml.PageLayout) for new page" -Verbose
        $rootWeb = $ClientContext.Site.RootWeb
        $masterPageCatalog = $rootWeb.GetCatalog([Microsoft.SharePoint.Client.ListTemplateType]::MasterPageCatalog)
        $pageLayoutCamlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $pageLayoutCamlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($PageXml.PageLayout)</Value></Eq></Where></Query></View>"
        $pageLayoutItems = $masterPageCatalog.GetItems($pageLayoutCamlQuery)
        $ClientContext.Load($pageLayoutItems)
 

        # Get Publishing Web
        $publishingWeb = [Microsoft.SharePoint.Client.Publishing.PublishingWeb]::GetPublishingWeb($ClientContext, $Web)
        $ClientContext.Load($publishingWeb)

        # Setup Complete, call server
		$clientContext.ExecuteQuery()

        $MajorVersionsEnabled = $pagesList.EnableVersioning
        $MinorVersionsEnabled = $pagesList.EnableMinorVersions
        $ContentApprovalEnabled = $pagesList.EnableModeration
        $CheckOutRequired = $pagesList.ForceCheckout
		
		if ($existingPageListItems.Count -ne 0)
		{
			Write-Verbose "Page $($PageXml.Url) already exists"
			$pageAlreadyExists = $true
			$originalPublishingPageListItem = $existingPageListItems[0]
		}
        
        if($pageAlreadyExists -and $replaceContent -eq $false) {
            Write-Verbose "Page $($PageXml.Url) already Exists and ReplaceContent is set to false" -Verbose
            return
        }
        
        # Load Page Layout Item if avilable
        if ($pageLayoutItems.Count -lt 1)
		{
			Write-Verbose "Missing Page Layout $($PageXml.PageLayout), Can not create $($PageXml.Url)" -Verbose
            return
		} else {
            $pageLayout = $pageLayoutItems[0]
            $ClientContext.Load($pageLayout)
            $ClientContext.ExecuteQuery()
        }

        # Rename existing page if needed
        if($pageAlreadyExists) {
            Write-Verbose "Renaming existing page"
            if($CheckOutRequired) {
                Write-Verbose "Checking-out existing page"
                $originalPublishingPageListItem.File.CheckOut()
            }
			$tempPageUrl = $PageXml.Url.Replace(".aspx", "-temp.aspx");
			$originalPublishingPageListItem["FileLeafRef"] = $tempPageUrl
			$originalPublishingPageListItem.Update()
            $ClientContext.ExecuteQuery()
            if($CheckOutRequired) {
                Write-Verbose "Checking-in existing page"
                $originalPublishingPageListItem.File.CheckIn("Draft Check-in", [Microsoft.SharePoint.Client.CheckinType]::MinorCheckIn)
                $ClientContext.ExecuteQuery()
            }
        }
       

        Write-Verbose "Creating page $($PageXml.Url) using layout $($PageXml.PageLayout)" -Verbose
        
        $publishingPageInformation = New-Object Microsoft.SharePoint.Client.Publishing.PublishingPageInformation
        $publishingPageInformation.Name = $PageXml.Url;
        $publishingPageInformation.PageLayoutListItem = $pageLayout

        $publishingPage = $publishingWeb.AddPublishingPage($publishingPageInformation)
        foreach($property in $PageXml.Property) {
            if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                Write-Verbose "Setting TaxonomyField $($propertyXml.Name) to $($propertyXml.Value)"
                $field = $pagesList.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)

                if ($taxField.AllowMultipleValues) {
                    $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                    $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)

                    $taxField.SetFieldValueByValueCollection($publishingPage.ListItem, $taxFieldValueCol);
                } else {
                    $publishingPage.ListItem[$propertyXml.Name] = $propertyXml.Value
                }

            } elseif ($property.Name -eq "ContentType") {
                // Do Nothing
            } else {
                $publishingPage.ListItem[$property.Name] = $property.Value
            }
        }
        $publishingPage.ListItem.Update()
        $publishingPageFile = $publishingPage.ListItem.File
        $ClientContext.load($publishingPage)
        $ClientContext.load($publishingPageFile)
        $ClientContext.ExecuteQuery()

        if($publishingPageFile.CheckOutType -ne [Microsoft.SharePoint.Client.CheckOutType]::None) {
            $publishingPageFile.CheckIn("Draft Check-in", [Microsoft.SharePoint.Client.CheckinType]::MinorCheckIn)
            $ClientContext.Load($publishingPageFile)
            $ClientContext.ExecuteQuery()
        }
        
        if($PageXml.Level -eq "Published"  -and $MinorVersionsEnabled -and $MajorVersionsEnabled) {
            $publishingPageFile.Publish("Publishing Page")
            $ClientContext.Load($publishingPageFile)
            $ClientContext.ExecuteQuery()
        }
        if($PageXml.Approval -eq "Approved" -and $ContentApprovalEnabled) {
            $publishingPageFile.Approve("Approving Page")
            $ClientContext.Load($publishingPageFile)
            $ClientContext.ExecuteQuery()
        }
        
        if($PageXml.WelcomePage) {
            $isWelcomePage = $false
            $isWelcomePage = [bool]::Parse($PageXml.WelcomePage)
            if($isWelcomePage) {
                Set-WelcomePage -WelcomePageUrl $publishingPageFile.ServerRelativeUrl -Web $Web -ClientContext $ClientContext
            }
        }

        # Delete orginal page
		if ($pageAlreadyExists)
		{
			$originalPublishingPageListItem.DeleteObject()
			$clientContext.ExecuteQuery()
		}
        
    }
}

function Delete-PublishingPage {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$PageXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {

		$pagesList = $Web.Lists.GetByTitle("Pages");
		$clientContext.Load($pagesList)
		$clientContext.ExecuteQuery()

		$camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery;
		$camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>{0}</Value></Eq></Where></Query></View>" -f $PageXml.Url

		$listItems = $pagesList.GetItems($camlQuery);

		$clientContext.Load($listItems)
		$clientContext.ExecuteQuery()

		if ($listItems.Count -ne 0)
		{
			$item = $listItems[0]
			$item.DeleteObject()
			$clientContext.ExecuteQuery()
		}
    }
}
#endregion

#region SearchCenter
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/SearchCenter.psm1

#endregion

#region Sites
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Sites.psm1
function Add-Site {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.Online.SharePoint.TenantAdministration.SiteCreationProperties]$SiteCreationProperties,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        #$tenantAdmin = [SharePointClient.PSTenant]::Tenant($adminContext)
        $tenantAdmin = New-Object Microsoft.Online.SharePoint.TenantAdministration.Tenant($ClientContext)

        $spoOperation = $tenantAdmin.CreateSite($SiteCreationProperties)
        $ClientContext.Load($tenantAdmin)
        $ClientContext.Load($spoOperation)
        $ClientContext.ExecuteQuery()

        while ($spoOperation.IsComplete -eq $false)
        {
            Start-Sleep -s 30
            $spoOperation.RefreshLoad()
            $ClientContext.ExecuteQuery()
        }
    }
}
#endregion

#region Taxonomy
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Taxonomy.psm1

# The taxonomy code is untested

function Get-TaxonomySession {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $session = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($ClientContext)
        $session.UpdateCache()
        $session
    }
}
function Get-DefaultSiteCollectionTermStore {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]$TaxonomySession,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $store = $TaxonomySession.GetDefaultSiteCollectionTermStore()
        $ClientContext.Load($store)
        $ClientContext.ExecuteQuery()
        $store
    }
}

function Get-TermGroup {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$GroupName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermStore]$TermStore,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $group = $TermStore.Groups.GetByName($GroupName)
        $ClientContext.Load($group)
        $ClientContext.ExecuteQuery()
        $group
    }
}
function Add-TermGroup {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipelineByPropertyName = $true)][guid]$Id = [guid]::NewGuid(),
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermStore]$TermStore,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $group = $TermStore.CreateGroup($Name,$Id)
        $TermStore.CommitAll()
        $ClientContext.load($group)
        $ClientContext.ExecuteQuery()
        $group
    }
}

function Get-TermSet {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$SetName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermGroup]$TermGroup,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $termSet = $TermGroup.TermSets.GetByName($SetName)
        $ClientContext.Load($termSet)
        $ClientContext.ExecuteQuery()
        $termSet
    }
}
function Add-TermSet {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipelineByPropertyName = $true)][int]$Language = 1033,
        [parameter(ValueFromPipelineByPropertyName = $true)][guid]$Id = [guid]::NewGuid(),
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermGroup]$TermGroup,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $termSet = $TermGroup.CreateTermSet($Name, $Id, $Language)
        $TermGroup.TermStore.CommitAll()
        $ClientContext.load($termSet)
        $ClientContext.ExecuteQuery()
        $termSet
    }
}
function Add-Term {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName = "Name")][string]$Name,
        [parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Language")][int]$Language = 1033,
        [parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = "Id")][guid]$Id = [guid]::NewGuid(),
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $term = $TermSet.CreateTerm($Name, $Language, $Id)

        $TermSet.TermStore.CommitAll()
        $ClientContext.load($term)
        $ClientContext.ExecuteQuery()
        $term
    }
}
function Get-Term {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][guid]$Id,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $term = $TermSet.GetTerm($Id)
        $ClientContext.Load($term)
        $ClientContext.ExecuteQuery()
        $term
    }
}
function Get-Terms {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $terms = $TermSet.Terms
        $ClientContext.Load($terms)
        $ClientContext.ExecuteQuery()
        $terms
    }
}
function Get-ChildTerms {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.Term]$Term,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $terms = $Term.Terms
        $ClientContext.Load($terms)
        $ClientContext.ExecuteQuery()
        $terms
    }
}

function Get-TermsByName {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $LabelMatchInformation = New-Object Microsoft.SharePoint.Client.Taxonomy.LabelMatchInformation($ClientContext);
        $LabelMatchInformation.Lcid = 1033
        $LabelMatchInformation.TrimUnavailable = $false         
        $LabelMatchInformation.TermLabel = $Name

        $terms = $TermSet.GetTerms($LabelMatchInformation)
        $ClientContext.Load($terms)
        $ClientContext.ExecuteQuery()
        $terms
    }
}

function Add-ChildTerm {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipelineByPropertyName = $true)][int]$Language = 1033,
        [parameter(ValueFromPipelineByPropertyName = $true)][guid]$Id = [guid]::NewGuid(),
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.Term]$parentTerm,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $term = $parentTerm.CreateTerm($Name, $Language, $Id)

        $parentTerm.TermStore.CommitAll()
        $ClientContext.load($term)
        $ClientContext.ExecuteQuery()
        $term
    }
}
#endregion

#region Webs
#source = https://github.com/rgylesbedford/SharePointCSOM-PowerShell-Module/blob/master/SharePoint-CSOM/Modules/Webs.psm1
function Add-Web {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$xml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {

        $webCreationInfo = New-Object Microsoft.SharePoint.Client.WebCreationInformation

        $webCreationInfo.Url = $xml.URL
        $webCreationInfo.Title = $xml.Title
        $webCreationInfo.Description = $xml.Description
        $webCreationInfo.WebTemplate = $xml.WebTemplate

        $newWeb = $web.Webs.Add($webCreationInfo); 
        $ClientContext.Load($newWeb);
        $ClientContext.ExecuteQuery()

        Update-Web -web $newweb -xml $xml -ClientContext $ClientContext
        $newWeb
    }
    end {} 
}
function Add-Webs {

 
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$xml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {

        foreach ($webInfo in $xml.Web) {
            $newweb = Add-Web -web $web -xml $webInfo -ClientContext $ClientContext 
        }
      
    }
    end {} 
}
function Set-WelcomePage {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$WelcomePageUrl,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $rootFolder = $Web.RootFolder
        $ClientContext.Load($rootFolder)
        $ClientContext.ExecuteQuery()

        $newWelcomPageUrl = $WelcomePageUrl -replace "^$($rootFolder.ServerRelativeUrl)", ""
        if($rootFolder.WelcomePage -ne $newWelcomPageUrl) {
            $rootFolder.WelcomePage = $newWelcomPageUrl
            $rootFolder.Update()
            $ClientContext.Load($rootFolder)
            $ClientContext.ExecuteQuery()
            Write-Verbose "Updated WelcomePage settings" -Verbose
        } else {
            Write-Verbose "Did not need to update WelcomePage settings"
        }
    }
}

function Set-MasterPage {
    param (
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$CustomMasterUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$MasterUrl,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $rootWeb = $ClientContext.Site.RootWeb
        $ClientContext.Load($rootWeb)
        $ClientContext.ExecuteQuery()

        $oldCustomMasterUrl = $Web.CustomMasterUrl
        $oldMasterUrl = $Web.MasterUrl
        $serverRelativeUrl = $rootWeb.ServerRelativeUrl -replace "/$", ""

        $performUpdate = $false
        if($CustomMasterUrl) {
            $NewCustomMasterUrl = "$serverRelativeUrl/$CustomMasterUrl"
            if($oldCustomMasterUrl -ne $NewCustomMasterUrl) {
                $Web.CustomMasterUrl = $NewCustomMasterUrl
                $performUpdate = $true
            }
        }

        if($MasterUrl) {
            $NewMasterUrl = "$serverRelativeUrl/$MasterUrl"
            if($oldMasterUrl -ne $NewMasterUrl) {
                $Web.MasterUrl = $NewMasterUrl
                $performUpdate = $true
            }
        }
        
        if($performUpdate) {
            $Web.Update()
            $ClientContext.ExecuteQuery()
            Write-Verbose "Updated MasterPage settings" -Verbose
        } else {
            Write-Verbose "Did not need to update MasterPage settings"
        }
    }
}

function Set-Theme {
    param (
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true )][alias("ColorPaletteUrl")][string]$ThemeUrl = "_catalogs/theme/15/palette001.spcolor",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][alias("BackgroundImageUrl")][string]$ImageUrl = $null,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$FontSchemeUrl = "_catalogs/theme/15/SharePointPersonality.spfont",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool]$shareGenerated = $true,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $rootWeb = $ClientContext.Site.RootWeb
        $ClientContext.Load($rootWeb)
        $ClientContext.ExecuteQuery()

        $ServerRelativeUrl = $rootWeb.ServerRelativeUrl -replace "/$", ""
        $newThemeUrl = "$ServerRelativeUrl/$ThemeUrl"
        
        $newFontSchemeUrl = "$ServerRelativeUrl/_catalogs/theme/15/SharePointPersonality.spfont"
        if($FontSchemeUrl -and $FontSchemeUrl -ne "") {
            $newFontSchemeUrl = "$ServerRelativeUrl/$FontSchemeUrl"
        }

        $newImageUrl = $null
        if($ImageUrl -and $ImageUrl -ne "") {
            $newImageUrl = "$ServerRelativeUrl/$ImageUrl"
        }

        Write-Verbose "Applying Theme for web: $($web.Url)" -Verbose
        if($newImageUrl) {
            $web.ApplyTheme($newThemeUrl, $newFontSchemeUrl, $newImageUrl, $shareGenerated)
        } else {
            # need to pass in a null string value for the image url and $null is not the same thing
            $web.ApplyTheme($newThemeUrl, $newFontSchemeUrl, [System.Management.Automation.Language.NullString]::Value, $shareGenerated)
        }
        $Web.Update()
        $ClientContext.Load($web)
        $ClientContext.ExecuteQuery()
    }
}
function Add-ComposedLook {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Name,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$MasterPageUrl = "_catalogs/masterpage/seattle.master",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$ThemeUrl = "_catalogs/theme/15/palette001.spcolor",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$ImageUrl = "",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$FontSchemeUrl = "",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][int]$DisplayOrder = 100,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$ComposedLooksList,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $rootWeb = $ClientContext.Site.RootWeb
        $ClientContext.Load($rootWeb)
        $ClientContext.ExecuteQuery()
        $serverRelativeUrl = $rootWeb.ServerRelativeUrl -replace "/$", ""

        $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
        $composedLooksListItem = $ComposedLooksList.addItem($listItemCreationInformation)
    
        $composedLooksListItem.Set_Item("Title", $Name)
        $composedLooksListItem.Set_Item("Name", $Name)
        $composedLooksListItem.Set_Item("MasterPageUrl", "$serverRelativeUrl/$MasterPageUrl")
        $composedLooksListItem.Set_Item("ThemeUrl", "$serverRelativeUrl/$ThemeUrl")
        if($ImageUrl -and $ImageUrl -ne "") {
            $composedLooksListItem.Set_Item("ImageUrl", "$serverRelativeUrl/$ImageUrl")
        }
        if($FontSchemeUrl -and $FontSchemeUrl -ne "") {
            $composedLooksListItem.Set_Item("FontSchemeUrl", "$serverRelativeUrl/$FontSchemeUrl")
        }
        $composedLooksListItem.Set_Item("DisplayOrder", "$DisplayOrder")
        $composedLooksListItem.Update()

        $ClientContext.Load($composedLooksListItem) 
        $ClientContext.ExecuteQuery()
    }
}
function Get-ComposedLook {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Name,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$ComposedLooksList,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='Title' /><Value Type='Text'>$Name</Value></Eq></Where></Query></View>"
        $composedLookListItems = $ComposedLooksList.GetItems($camlQuery)
        
        $ClientContext.Load($composedLookListItems)
        $ClientContext.ExecuteQuery()

        if($composedLookListItems.Count -eq 0) {
            return $null
        }
        $composedLookItem = $composedLookListItems[0]
        $ClientContext.Load($composedLookItem)
        $ClientContext.ExecuteQuery()
        return $composedLookItem
    }
}
function Update-ComposedLook {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Name,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$MasterPageUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$ThemeUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$ImageUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$FontSchemeUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][int]$DisplayOrder,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ListItem]$ComposedLook,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        throw NotImplementedException

        $rootWeb = $ClientContext.Site.RootWeb.ServerRelativeUrl
        $ClientContext.Load($rootWeb)
        $ClientContext.ExecuteQuery()
        $serverRelativeUrl = $rootWeb.ServerRelativeUrl -replace "/$", ""

        $needsUpdate = $false

        if($Name -and ($ComposedLook["Title"] -ne $Name -or $ComposedLook["Name"] -ne $Name)) {
            $ComposedLook.
            $ComposedLook.Set_Item("Title", $Name)
            $ComposedLook.Set_Item("Name", $Name)
            $needsUpdate = $true
        }

        $newMasterPageUrl = "$serverRelativeUrl/$MasterPageUrl"
        if($MasterPageUrl -and ($ComposedLook["MasterPageUrl"] -ne $newMasterPageUrl)) {
            $ComposedLook["MasterPageUrl"] = $newMasterPageUrl
            $needsUpdate = $true
        }
        if($ThemeUrl) {
            $ComposedLook.Set_Item("ThemeUrl", "$serverRelativeUrl/$ThemeUrl")
            $needsUpdate = $true
        }
        if($ImageUrl) {
            $ComposedLook.Set_Item("ImageUrl", "$serverRelativeUrl/$ImageUrl")
             $needsUpdate = $true
        }
        if($FontSchemeUrl) {
            $ComposedLook.Set_Item("FontSchemeUrl", "$serverRelativeUrl/$FontSchemeUrl")
             $needsUpdate = $true
        }
        if($DisplayOrder) {
            $ComposedLook.Set_Item("DisplayOrder", "$DisplayOrder")
            $needsUpdate = $true
        }
        if($needsUpdate) {
            $ComposedLook.Update()

            $ClientContext.Load($ComposedLook) 
            $ClientContext.ExecuteQuery()
        }
        return $ComposedLook
    }
}

function Update-Web {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$xml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext,
        [parameter(Mandatory=$false)][string]$ResourcesPath
    )
    process {
        foreach ($RemovePage in $xml.Pages.RemovePage) {
		    Delete-PublishingPage -PageXml $RemovePage -Web $web -ClientContext $ClientContext
		}
        foreach ($listXml in $xml.Lists.RemoveList) {
            Remove-List -ListName $listXml.Title -Web $web -ClientContext $ClientContext
        }
        if($xml.ContentTypes) {
            Remove-ContentTypes -contentTypesXml $xml.ContentTypes -web $web -ClientContext $ClientContext
        }
        if($xml.Fields) {
            Remove-SiteColumns -fieldsXml $xml.Fields -web $web -ClientContext $ClientContext
        }

        if($xml.Features) {
            if($xml.Features.WebFeatures -and $xml.Features.WebFeatures.DeactivateFeatures) {
                Remove-Features -FeaturesXml $xml.Features.WebFeatures.DeactivateFeatures -web $web -ClientContext $ClientContext
            }
            if($xml.Features.SiteFeatures -and $xml.Features.SiteFeatures.DeactivateFeature) {
                Remove-Features -FeaturesXml $xml.Features.SiteFeatures.DeactivateFeatures -site $ClientContext.Site -ClientContext $ClientContext
            }
        }

        # Done removing stuff, now to add/update
        if($xml.Features) {
            if($xml.Features.WebFeatures -and $xml.Features.WebFeatures.ActivateFeatures) {
                Add-Features -FeaturesXml $xml.Features.WebFeatures.ActivateFeatures -web $web -ClientContext $ClientContext
            }
            if($xml.Features.SiteFeatures -and $xml.Features.SiteFeatures.ActivateFeature) {
                Add-Features -FeaturesXml $xml.Features.SiteFeatures.ActivateFeatures -site $ClientContext.Site -ClientContext $ClientContext
            }
        }

        if($xml.Fields) {
            Update-SiteColumns -fieldsXml $xml.Fields -web $web -ClientContext $ClientContext
        }
        

        if($xml.ContentTypes) {
            Update-ContentTypes -contentTypesXml $xml.ContentTypes -web $web -ClientContext $ClientContext
        }
        foreach ($catalogXml in $xml.Catalogs.Catalog) {
			#get by catalog type vs get by title... if catalogtype specified, use that, otherwise get by title.
			if ($catalogXml.Type) {
		        $SPList = $web.GetCatalog([Microsoft.SharePoint.Client.ListTemplateType]::$($catalogXml.Type))
			} else {
	            $SPList = $web.Lists.GetByTitle($catalogXml.Title)
			}
            $ClientContext.Load($SPList)
            $ClientContext.ExecuteQuery()

            if($SPList -eq $null) {
                #throw "List not found: $($catalogXml.Title) for List Type: $($catalogXml.Type)"
                throw "List not found: $($catalogXml.Title)"
            } else {
                Write-Verbose "List loaded: $($catalogXml.Title)" -Verbose
            }

            $MajorVersionsEnabled = $SPList.EnableVersioning
            $MinorVersionsEnabled = $SPList.EnableMinorVersions
            $ContentApprovalEnabled = $SPList.EnableModeration
            $CheckOutRequired = $SPList.ForceCheckout

			if($CheckOutRequired) {
	            Write-Verbose "`tNOTE: ForceCheckout enabled, file processing may be slow." -Verbose
			}

            Write-Verbose "`tFiles and Folders" -Verbose
            if($catalogXml.DeleteItems) {
                foreach($itemXml in $catalogXml.DeleteItems.Item) {
                    $item = Get-ListItem -itemUrl $itemXml.Url -Folder $itemXml.Folder -List $SPList -ClientContext $clientContext
                    if($item -ne $null) {
                        Remove-ListItem -listItem $item -ClientContext $clientContext
                    }
                }
            }
            if($catalogXml.UpdateItems) {
                foreach($itemXml in $catalogXml.UpdateItems.Item) {
                    Update-ListItem -listItemXml $itemXml -List $SPList -ClientContext $clientContext 
                }
            }

            foreach($folderXml in $catalogXml.Folder) {
                Write-Verbose "`t`t$($folderXml.Url)" -Verbose
                $spFolder = Get-RootFolder -List $SPList -ClientContext $ClientContext
                Add-Files -Folder $spFolder -FolderXml $folderXml -ResourcesPath $ResourcesPath `
                    -MinorVersionsEnabled $MinorVersionsEnabled -MajorVersionsEnabled $MajorVersionsEnabled -ContentApprovalEnabled $ContentApprovalEnabled `
                    -ClientContext $ClientContext -RemoteContext $RemoteContext -CheckOutRequired $CheckOutRequired
            }
            if($catalogXml.Type -eq "DesignCatalog") {
                Write-Verbose "`tComposedLooks" -Verbose
                foreach($composedLookXml in $catalogXml.ComposedLook) {
                    $composedLookListItem = Get-ComposedLook -Name $composedLookXml.Title -ComposedLooksList $SPList -Web $web -ClientContext $ClientContext
                    if($composedLookListItem -eq $null) {
                        $composedLookListItem = Add-ComposedLook -Name $composedLookXml.Title -MasterPageUrl $composedLookXml.MasterPageUrl -ThemeUrl $composedLookXml.ThemeUrl -DisplayOrder $composedLookXml.DisplayOrder -ComposedLooksList $SPList -Web $web -ClientContext  $ClientContext
                    }
                }
            }
        }

        foreach ($listXml in $xml.Lists.RenameList) {
            Rename-List -OldTitle $listXml.OldTitle -NewTitle $listXml.NewTitle -Web $web -ClientContext $ClientContext
        }

        foreach ($listXml in $xml.Lists.List) {
            $List = Update-List -ListXml $listXml -Web $web -ClientContext $ClientContext
        }

        foreach ($PageXml in $xml.Pages.Page) {
            New-PublishingPage -PageXml $PageXml -Web $web -ClientContext $ClientContext
        }

        foreach ($ProperyBagValue in $xml.PropertyBag.PropertyBagValue) {
            $Indexable = $false
            if($PropertyBagValue.Indexable) {
                $Indexable = [bool]::Parse($PropertyBagValue.Indexable)
            }

            Set-PropertyBagValue -Key $ProperyBagValue.Key -Value $ProperyBagValue.Value -Indexable $Indexable -Web $web -ClientContext $ClientContext
        }
        
        if($xml.WelcomePage) {
            Set-WelcomePage -WelcomePageUrl $xml.WelcomePage -Web $web -ClientContext $ClientContext
        }

        if($xml.CustomMasterUrl -or $xml.MasterUrl) {
            Set-MasterPage -CustomMasterUrl $xml.CustomMasterUrl -MasterUrl $xml.MasterUrl -Web $web -ClientContext $ClientContext
        }

        if($xml.NoCrawl) {
            $noCrawl = [bool]$xml.NoCrawl
            Update-NoCrawl -NoCrawl $noCrawl -Web $web -ClientContext $ClientContext
        }

        if($xml.ColorPaletteUrl) {
            $FontSchemeUrl = $null
            if($xml.FontSchemeUrl) {
                $FontSchemeUrl = $xml.FontSchemeUrl
            }
            $BackgroundImageUrl = $null
            if($xml.BackgroundImageUrl) {
                $BackgroundImageUrl = $xml.BackgroundImageUrl
            }

            Set-Theme -ColorPaletteUrl $xml.ColorPaletteUrl -FontSchemeUrl $FontSchemeUrl -BackgroundImageUrl $BackgroundImageUrl -Web $web -ClientContext $ClientContext
        }

        if($xml.Webs) {
            Add-Webs -Web $web -Xml $xml.Webs -ClientContext $ClientContext
        }
    }
}

function Remove-RecentNavigationItem {
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Title,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $nodes = $ClientContext.Web.Navigation.QuickLaunch;
        $ClientContext.Load($nodes);
        $ClientContext.ExecuteQuery();

        $recent = $nodes | Where {$_.Title -eq "Recent"}
        if($recent -ne $null) {
            $ClientContext.Load($recent.Children);
            $ClientContext.ExecuteQuery();
            $recentNode = $recent.Children | Where {$_.Title -eq $Title}
            if ($recentNode -ne $null) {
                $recentNode.DeleteObject();
                $ClientContext.ExecuteQuery();
            }
        }
    }
}

function Update-NoCrawl {
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$NoCrawl,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $noCrawlPropName = "NoCrawl"
        $searchVersionPropName = "vti_searchversion"
        $oldValue = Get-PropertyBagValue -Key $noCrawlPropName -Web $Web -ClientContext $ClientContext
        if ([bool]$oldValue -ne $NoCrawl) {
            Set-PropertyBagValue -Key $noCrawlPropName -Value $NoCrawl -Web $Web -ClientContext $clientContext
            $searchVersionOld = Get-PropertyBagValue -Key $searchVersionPropName -Web $Web -ClientContext $ClientContext
            if ($searchVersionOld) {
                $searchVersionNew = [int]$searchVersionOld + 1
            } else {
                $searchVersionNew = 1
            }
            Set-PropertyBagValue -Key $searchVersionPropName -Value $searchVersionNew -Web $Web -ClientContext $clientContext
        }
    }
}

<#
function UnSetup-Web {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$xml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        foreach ($List in $xml.Lists.List) {
            Remove-List -ListName $ContentType.Title -Web $web -ClientContext $ClientContext
        }
        foreach ($ContentType in $xml.ContentTypes.ContentType) {
            Remove-ContentType -ContentTypeName $ContentType.Name -Web $web -ClientContext $ClientContext
        }
        foreach ($Field in $xml.Fields.Field) {
            Remove-SiteColumn -FieldId $Field.ID -Web $web -ClientContext $ClientContext
        }
    }
}
#>
#endregion



#endregion


