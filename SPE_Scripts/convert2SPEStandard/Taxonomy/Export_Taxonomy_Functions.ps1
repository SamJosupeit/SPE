﻿#Source: https://cann0nf0dder.wordpress.com/2014/11/12/exporting-taxonomy-from-sharepoint-using-powershell/

function Get-TermStoreInfo($spContext){
 $spTaxSession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($spContext)
 $spTaxSession.UpdateCache();
 $spContext.Load($spTaxSession)
 
 try
 {
 $spContext.ExecuteQuery()
 }
 catch
 {
  Write-host "Error while loading the Taxonomy Session " $_.Exception.Message -ForegroundColor Red
  exit 1
 }
 
 if($spTaxSession.TermStores.Count -eq 0){
  write-host "The Taxonomy Service is offline or missing" -ForegroundColor Red
  exit 1
 }
 
 $termStores = $spTaxSession.TermStores
 $spContext.Load($termStores)
 
 try
 {
  $spContext.ExecuteQuery()
  $termStore = $termStores[0]
  $spcontext.Load($termStore)
  $spContext.ExecuteQuery()
  Write-Host "Connected to TermStore: $($termStore.Name) ID: $($termStore.Id)"
 }
 catch
 {
  Write-host "Error details while getting term store ID" $_.Exception.Message -ForegroundColor Red
  exit 1
 }
 return $termStore
}

function Get-XMLTermStoreTemplateToFile($termStoreName, $path){
 ## Set up an xml template used for creating your exported xml
 

$XmlTemplateSam = @"
<TermStores>
	<TermStore Name="[termStoreName]" IsOnline="True" WorkingLanguage="1033" DefaultLanguage="1033" SystemGroup="c6fb3e37-0997-42b1-8e3c-2706a36adbc4">
		<Groups>
			<Group Id="" Name="" Description="" IsSystemGroup="False" IsSiteCollectionGroup="False">
				<TermSets>
					<TermSet Id="" Name="" Description="" Contact="" IsAvailableForTagging="" IsOpenForTermCreation="" CustomSortOrder="False">
						<CustomProperties>
							<CustomProperty Key="" Value=""/>
						</CustomProperties>
						<Terms>
							<Term Id="" Name="" IsDeprecated="" IsAvailableForTagging="" IsKeyword="" IsReused="" IsRoot="" IsSourceTerm="" CustomSortOrder="False">
								<Descriptions>
									<Description Language="1033" Value="" />
								</Descriptions>
								<CustomProperties>
									<CustomProperty Key="" Value="" />
								</CustomProperties>
								<LocalCustomProperties>
									<LocalCustomProperty Key="" Value="" />
								</LocalCustomProperties>
								<Labels>
									<Label Value="" Language="1033" IsDefaultForLanguage="" />
								</Labels>
								<Terms>
									<Term Id="" Name="" IsDeprecated="" IsAvailableForTagging="" IsKeyword="" IsReused="" IsRoot="" IsSourceTerm="" CustomSortOrder="False">
										<Descriptions>
											<Description Language="1033" Value="" />
										</Descriptions>
										<CustomProperties>
											<CustomProperty Key="" Value="" />
										</CustomProperties>
										<LocalCustomProperties>
											<LocalCustomProperty Key="" Value="" />
										</LocalCustomProperties>
										<Labels>
											<Label Value="" Language="1033" IsDefaultForLanguage="" />
										</Labels>
									</Term>
								</Terms>
							</Term>
						</Terms>
					</TermSet>
				</TermSets>
			</Group>
		</Groups>
	</TermStore>
</TermStores>
"@

$xmlTemplate = $xmlTemplate.Replace("[termStoreName]", $termStoreName)
try
{
 #Save Template to disk
 $xmlTemplate | Out-File($path + "\Template.xml")
 
 #Load file and return
 $xml = New-Object XML
 $xml.Load($path + "\Template.xml")
 return $xml
 }
 catch{
 Write-host "Error creating Template file. " $_.Exception.Message -ForegroundColor Red
 exit 1
 }
}

function Get-XMLFileObjectTemplates($xml){
 #Grab template elements so that we can easily copy them later.
   $global:xmlGroupT = $xml.selectSingleNode('//Group[@Id=""]') 
    $global:xmlTermSetT = $xml.selectSingleNode('//TermSet[@Id=""]') 
    $global:xmlTermT = $xml.selectSingleNode('//Term[@Id=""]')
 $global:xmlTermLabelT = $xml.selectSingleNode('//Label[@Value=""]')
 $global:xmlTermDescriptionT = $xml.selectSingleNode('//Description[@Value=""]')
 $global:xmlTermCustomPropertiesT = $xml.selectSingleNode('//CustomProperty[@Key=""]')
 $global:xmlTermLocalCustomPropertiesT = $xml.selectSingleNode('//LocalCustomProperty[@Key=""]')
}

function Get-Groups($spContext, $groups, $xml, $groupToExport){
 #Loop through all groups, ignoring system Groups
 $groups | Where-Object { $_.IsSystemGroup -eq $false} | ForEach-Object{
 
 #Check if we are getting groups or just group.
 if($groupToExport -ne "")
 {
 if($groupToExport -ne $_.name){
 #Return acts like a continue in ForEach-Object
 return;
 }
 }
 
 #Add each group to export xml by cloning the template group,
 #populating it and appending it
 $xmlNewGroup = $global:xmlGroupT.Clone()
 $xmlNewGroup.Name = $_.name
 $xmlNewGroup.id = $_.id.ToString()
 $xmlNewGroup.Description = $_.description
 $xml.TermStores.TermStore.Groups.AppendChild($xmlNewGroup) | Out-Null
 
 write-Host "Adding Group " -NoNewline
 write-Host $_.name -ForegroundColor Green
 
 $spContext.Load($_.TermSets)
 try
 {
 $spContext.ExecuteQuery()
 }
 catch
 {
 Write-host "Error while loaded TermSets for Group " $xmlNewGroup.Name " " $_.Exception.Message -ForegroundColor Red
 exit 1
 }
 
 Get-TermSets $spContext $xmlNewGroup $_.Termsets $xml
 }
}

function Get-TermSets($spContext, $xmlnewGroup, $termSets, $xml){
 $termSets | ForEach-Object{
 #Add each termset to the export xml
 $xmlNewSet = $global:xmlTermSetT.Clone()
 #Replace SharePoint ampersand with regular
 $xmlNewSet.Name = $_.Name.replace("＆", "&")
 
 $xmlNewSet.Id = $_.Id.ToString()
 
 if ($_.CustomSortOrder -ne $null)
 {
 $xmlNewSet.CustomSortOrder = $_.CustomSortOrder.ToString()
 }
 
 foreach($customprop in $_.CustomProperties.GetEnumerator())
 {
 ## Clone Term customProp node
 $xmlNewTermCustomProp = $global:xmlTermCustomPropertiesT.Clone()    
 
 $xmlNewTermCustomProp.Key = $($customProp.Key)
 $xmlNewTermCustomProp.Value = $($customProp.Value)
 $xmlNewSet.CustomProperties.AppendChild($xmlNewTermCustomProp) | Out-Null
 }
 
 $xmlNewSet.Description = $_.Description.ToString()
 $xmlNewSet.Contact = $_.Contact.ToString()
    $xmlNewSet.IsOpenForTermCreation = $_.IsOpenForTermCreation.ToString()  
    $xmlNewSet.IsAvailableForTagging = $_.IsAvailableForTagging.ToString()  
    $xmlNewGroup.TermSets.AppendChild($xmlNewSet) | Out-Null
 
 Write-Host "Adding TermSet " -NoNewline
 Write-Host $_.name -ForegroundColor Green -NoNewline
 Write-Host " to Group " -NoNewline
 Write-Host $xmlNewGroup.Name -ForegroundColor Green
 
 $spContext.Load($_.Terms)
 try
 {
 $spContext.ExecuteQuery()
 }
 catch
 {
 Write-host "Error while loading Terms for TermSet " $_.name " " $_.Exception.Message -ForegroundColor Red
 exit 1
 }
 # Recursively loop through all the terms in this termset
    Get-Terms $spContext $_.Terms $xml
 }
 }

function Get-Terms($spContext, $terms, $xml){
#Terms could be either the original termset or parent term with children terms
 $terms | ForEach-Object{
 #Create a new term xml Element
 $xmlNewTerm = $global:xmlTermT.Clone()
 #Replace SharePoint ampersand with regular
 $xmlNewTerm.Name = $_.Name.replace("＆", "&")
 $xmlNewTerm.id = $_.Id.ToString()
 $xmlNewTerm.IsAvailableForTagging = $_.IsAvailableForTagging.ToString()
 $xmlNewTerm.IsKeyword = $_.IsKeyword.ToString()
 $xmlNewTerm.IsReused = $_.IsReused.ToString()
 $xmlNewTerm.IsRoot = $_.IsRoot.ToString()
    $xmlNewTerm.IsSourceTerm = $_.IsSourceterm.ToString()
    $xmlNewTerm.IsDeprecated = $_.IsDeprecated.ToString()
 
 if($_.CustomSortOrder -ne $null)
 {
 $xmlNewTerm.CustomSortOrder = $_.CustomSortOrder.ToString()
 }
 
 #Custom Properties
 foreach($customprop in $_.CustomProperties.GetEnumerator())
 {
 # Clone Term customProp node
 $xmlNewTermCustomProp = $global:xmlTermCustomPropertiesT.Clone()    
 
 $xmlNewTermCustomProp.Key = $($customProp.Key)
 $xmlNewTermCustomProp.Value = $($customProp.Value)
 $xmlNewTerm.CustomProperties.AppendChild($xmlNewTermCustomProp)  | Out-Null
 }
 
 #Local Properties
 foreach($localProp in $_.LocalCustomProperties.GetEnumerator())
 {
 # Clone Term LocalProp node
 $xmlNewTermLocalCustomProp = $global:xmlTermLocalCustomPropertiesT.Clone()    
 
 $xmlNewTermLocalCustomProp.Key = $($localProp.Key)
 $xmlNewTermLocalCustomProp.Value = $($localProp.Value)
 $xmlNewTerm.LocalCustomProperties.AppendChild($xmlNewTermLocalCustomProp) | Out-Null
 }
 
 if($_.Description -ne ""){
 $xmlNewTermDescription = $global:xmlTermDescriptionT.Clone()    
 $xmlNewTermDescription.Value = $_.Description
 $xmlNewTerm.Descriptions.AppendChild($xmlNewTermDescription) |Out-Null
 }
 
 $spContext.Load($_.Labels)
 $spContext.Load($_.TermSet)
 $spContext.Load($_.Parent)
 $spContext.Load($_.Terms)
 
 try
 {
 $spContext.ExecuteQuery()
 }
 catch
 {
 Write-host "Error while loaded addition information for Term " $xmlNewTerm.Name " " $_.Exception.Message -ForegroundColor Red
 exit 1
 }
 
 foreach($label in $_.Labels)
 {
 ## Clone Term Label node
 $xmlNewTermLabel = $global:xmlTermLabelT.Clone()
 $xmlNewTermLabel.Value = $label.Value.ToString()
 $xmlNewTermLabel.Language = $label.Language.ToString()
 $xmlNewTermLabel.IsDefaultForLanguage = $label.IsDefaultForLanguage.ToString()
        $xmlNewTerm.Labels.AppendChild($xmlNewTermLabel) | Out-Null
 }
 
 # Use this terms parent term or parent termset in the termstore to find it's matching parent
     # in the export xml
     if ($_.parent.Id -ne $null) {
      # Both guids are needed as a term can appear in multiple termsets
        $parentGuid = $_.parent.Id.ToString()
        $parentTermsetGuid = $_.Termset.Id.ToString()
 #$_.Parent.Termset.Id.ToString()
     }
 else
 {
      $parentGuid = $_.Termset.Id.ToString()
     }     
 
 # Get this terms parent in the xml      
     $parent = Get-TermByGuid $xml $parentGuid $parentTermsetGuid     
 
 $parentGuid = $null;
 
 #Append new Term to Parent
 $parent.Terms.AppendChild($xmlNewTerm) | Out-Null
 
 Write-Host "Adding Term " -NoNewline
 Write-Host $_.name -ForegroundColor Green -NoNewline
 Write-Host " to Parent " -NoNewline
 Write-Host $parent.Name -ForegroundColor Green
 
 #If this term has child terms we need to loop through those
 if($_.Terms.Count -gt 0){
 #Recursively call itself
 Get-Terms $spContext $_.Terms $xml
 }
 }
}

function Get-TermByGuid($xml, $guid, $parentTermsetGuid) {
      if ($parentTermsetGuid) {
        return  $xml.selectnodes('//Term[@Id="' + $guid + '"]')
    } else {
        return  $xml.selectnodes('//TermSet[@Id="' + $guid + '"]')
    }
}

function Clean-Template($xml) {
    #Do not cleanup empty description nodes (this is the default state)
 
 ## Empty Term.Labels.Label
    $xml.selectnodes('//Label[@Value=""]') | ForEach-Object {
        $parent = $_.get_ParentNode()
        $parent.RemoveChild($_)  | Out-Null      
    } 
 ## Empty Term
 $xml.selectnodes('//Term[@Id=""]') | ForEach-Object {
        $parent = $_.get_ParentNode()
        $parent.RemoveChild($_)  | Out-Null      
    } 
 ## Empty TermSet
    $xml.selectnodes('//TermSet[@Id=""]') | ForEach-Object {
        $parent = $_.get_ParentNode()
        $parent.RemoveChild($_)  | Out-Null      
    } 
 ## Empty Group
    $xml.selectnodes('//Group[@Id=""]') | ForEach-Object {
        $parent = $_.get_ParentNode()
        $parent.RemoveChild($_)   | Out-Null     
    }
 ## Empty Custom Properties
 $xml.selectnodes('//CustomProperty[@Key=""]') | ForEach-Object {
 $parent = $_.get_ParentNode()
 $parent.RemoveChild($_) | Out-Null
 }
 
 ## Empty Local Custom proeprties
 $xml.selectnodes('//LocalCustomProperty[@Key=""]') | ForEach-Object {
 $parent = $_.get_ParentNode()
 $parent.RemoveChild($_) | Out-Null
 }
 
 $xml.selectnodes('//Descriptions')| ForEach-Object {
 $childNodes = $_.ChildNodes.Count
 if($childNodes -gt 1)
 {
 $_.RemoveChild($_.ChildNodes[0]) | Out-Null
 }
 }
 
 While ($xml.selectnodes('//Term[@Id=""]').Count -gt 0)
 {
 #Cleanup the XML, remove empty Term Nodes
 $xml.selectnodes('//Term[@Id=""]').RemoveAll() | Out-Null
 }
 }

 function ExportTaxonomy($spContext, $termStore, $xml, $groupToExport, $path, $saveFileName){
 $spContext.Load($termStore.Groups)
 try
 {
 $spContext.ExecuteQuery();
 }
 catch
 {
 Write-host "Error while loaded Groups from TermStore " $_.Exception.Message -ForegroundColor Red
 exit 1
 }
 
 Get-Groups $spContext $termStore.Groups $xml $groupToExport
 
 #Clean up empty tags/nodes
 Clean-Template $xml
 
 #Save file.
 try
 {
 $xml.Save($path + "\NewTaxonomy.xml")
 
 #Clean up empty <Term> unable to work out in Clean-Template.
 Get-Content ($path + "\NewTaxonomy.xml") | Foreach-Object { $_ -replace "<Term><\/Term>", "" } | Set-Content ($path + "\" + $saveFileName)
 Write-Host "Saving XML file " $saveFileName " to " $path
 
 #Remove temp file
 Remove-Item($path + "\Template.xml");
 Remove-Item($path + "\NewTaxonomy.xml");
 }
 catch
 {
 Write-host "Error saving XML File to disk " $_.Exception.Message -ForegroundColor Red
 exit 1
 }
}

#This exports the entire termstore.
#./Export-Taxonomy.ps1 -AdminUser user@sp.com -AdminPassword password -AdminUrl https://sp-admin.onmicrosoft.com -PathToExportXMLTerms c:\myTerms -XMLTermsFileName exportterms.xml -PathToSPClientdlls &quot;C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI&quot;
#This exports just the Term Store Group ‘Client Group Terms’
#./Export-Taxonomy.ps1 -AdminUser user@sp.com -AdminPassword password -AdminUrl https://sp-admin.onmicrosoft.com -PathToExportXMLTerms c:\myTerms -XMLTermsFileName exportterms.xml -PathToSPClientdlls &quot;C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI&quot; -GroupToExport 'Client Group Terms'

