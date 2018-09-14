#Source: https://cann0nf0dder.wordpress.com/2014/11/29/importing-taxonomy-to-sharepoint-using-powershell/

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

function Get-TermsToImport($xmlTermsPath){
 [Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq") | Out-Null
  
 try
 {
     $xDoc = [System.Xml.Linq.XDocument]::Load($xmlTermsPath, [System.Xml.Linq.LoadOptions]::None)
     return $xDoc
 }
 catch
 {
      Write-Host "Unable to read ExportedTermsXML. Exception:$_.Exception.Message" -ForegroundColor Red
      exit 1
 }
}

function Create-Groups($spContext, $termStore, $termsXML){
     foreach($groupNode in $termsXML.Descendants("Group"))
     {
        $name = $groupNode.Attribute("Name").Value
        $description = $groupNode.Attribute("Description").Value;
        $groupId = $groupNode.Attribute("Id").Value;
        $groupGuid = [System.Guid]::Parse($groupId);
        Write-Host "Processing Group: $name ID: $groupId ..." -NoNewline
  
        $group = $termStore.GetGroup($groupGuid);
        $spContext.Load($group);
  
        try
        {
            $spContext.ExecuteQuery();
        }
        catch
        {
            Write-host "Error while finding if " $name " group already exists. " $_.Exception.Message -ForegroundColor Red
            exit 1
        }
  
 
        if ($group.ServerObjectIsNull) {
            $group = $termStore.CreateGroup($name, $groupGuid);
            $spContext.Load($group);
            try
            {
                $spContext.ExecuteQuery();
                write-host "Inserted" -ForegroundColor Green
            }
            catch
            {
                Write-host "Error creating new Group " $name " " $_.Exception.Message -ForegroundColor Red
                exit 1
            }
        }
        else {
            write-host "Already exists" -ForegroundColor Yellow
        }
     
        Create-TermSets $termsXML $group $termStore $spContext
  
     }
 
     try
     {
         $termStore.CommitAll();
         $spContext.ExecuteQuery();
     }
     catch
     {
       Write-Host "Error commiting changes to server. Exception:$_.Exception.Message" -foregroundcolor red
       exit 1
     }
}

function Create-TermSets($termsXML, $group, $termStore, $spContext) {
 
    $termSets = $termsXML.Descendants("TermSet") | Where { $_.Parent.Parent.Attribute("Name").Value -eq $group.Name }
 
    foreach ($termSetNode in $termSets)
    {
        $errorOccurred = $false
        $name = $termSetNode.Attribute("Name").Value;
        $id = [System.Guid]::Parse($termSetNode.Attribute("Id").Value);
        $description = $termSetNode.Attribute("Description").Value;
        $customSortOrder = $termSetNode.Attribute("CustomSortOrder").Value;
        Write-host "Processing TermSet $name ... " -NoNewLine
         
        $termSet = $termStore.GetTermSet($id);
        $spcontext.Load($termSet);
  
        try
        {
            $spContext.ExecuteQuery();
        }
        catch
        {
            Write-host "Error while finding if " $name " termset already exists. " $_.Exception.Message -ForegroundColor Red
            exit 1
        }
         
        if ($termSet.ServerObjectIsNull)
        {
            $termSet = $group.CreateTermSet($name, $id, $termStore.DefaultLanguage);
            $termSet.Description = $description;
 
            if($customSortOrder -ne $null)
            {
                $termSet.CustomSortOrder = $customSortOrder
            }
 
           $termSet.IsAvailableForTagging = [bool]::Parse($termSetNode.Attribute("IsAvailableForTagging").Value);
           $termSet.IsOpenForTermCreation = [bool]::Parse($termSetNode.Attribute("IsOpenForTermCreation").Value);
 
            if($termSetNode.Element("CustomProperties") -ne $null)
            {
                foreach($custProp in $termSetNode.Element("CustomProperties").Elements("CustomProperty"))
                {
                   $termSet.SetCustomProperty($custProp.Attribute("Key").Value, $custProp.Attribute("Value").Value)
                }
            }
  
           try
            {
                $spContext.ExecuteQuery();
            }
            catch
            {
                Write-host "Error occured while create Term Set" $name $_.Exception.Message -ForegroundColor Red
                $errorOccurred = $true
            }
  
            write-host "created" -ForegroundColor Green
        }
        else {
            write-host "Already exists" -ForegroundColor Yellow
        }
             
  
        if(!$errorOccurred)
        {
            if ($termSetNode.Element("Terms") -ne $null)
            {
              foreach ($termNode in $termSetNode.Element("Terms").Elements("Term"))
               {
                  Create-Term $termNode $null $termSet $termStore $termStore.DefaultLanguage $spContext
               }
            }    
        }                        
    }
}

function Create-Term($termNode, $parentTerm, $termSet, $store, $lcid, $spContext){
    $id = [System.Guid]::Parse($termNode.Attribute("Id").Value)
    $name = $termNode.Attribute("Name").Value;
    $term = $termSet.GetTerm($id);
    $errorOccurred = $false
     
 
    $spContext.Load($term);
    try
    {
        $spContext.ExecuteQuery();
    }
    catch
    {
        Write-host "Error while finding if " $name " term id already exists. " $_.Exception.Message -ForegroundColor Red
        exit 1
    }
  
     write-host "Processing Term $name ..." -NoNewLine
    if($term.ServerObjectIsNull)
    {
        if ($parentTerm -ne $null)
        {
            $term = $parentTerm.CreateTerm($name, $lcid, $id);
        }
        else
        {
           $term = $termSet.CreateTerm($name, $lcid, $id);
        }
 
        $customSortOrder = $termNode.Attribute("CustomSortOrder").Value;
        $description = $termNode.Element("Descriptions").Element("Description").Attribute("Value").Value;
        $term.SetDescription($description, $lcid);
        $term.IsAvailableForTagging = [bool]::Parse($termNode.Attribute("IsAvailableForTagging").Value);
 
 
        if($customSortOrder -ne $null)
        {
            $term.CustomSortOrder = $customSortOrder
        }
 
        if($termNode.Element("CustomProperties") -ne $null)
        {
            foreach($custProp in $termNode.Element("CustomProperties").Elements("CustomProperty"))
            {
                $term.SetCustomProperty($custProp.Attribute("Key").Value, $custProp.Attribute("Value").Value)
            }
        }
 
        if($termNode.Element("LocalCustomProperties") -ne $null)
        {
            foreach($localCustProp in $termNode.Element("LocalCustomProperties").Elements("LocalCustomProperty"))
           {
               $term.SetLocalCustomProperty($localCustProp.Attribute("Key").Value, $localCustProp.Attribute("Value").Value)
           }
        }
 
       try
        {
            $spContext.Load($term);
            $spContext.ExecuteQuery();
            write-host " created" -ForegroundColor Green    
        }
        catch
        {
            Write-host "Error occured while create Term" $name $_.Exception.Message -ForegroundColor Red
            $errorOccurred = $true
        }
    }
    else
    {
     write-host "Already exists" -ForegroundColor Yellow
    }
 
   if(!$errorOccurred)
    {
        if ($termNode.Element("Terms") -ne $null)
        {
            foreach ($childTermNode in $termNode.Element("Terms").Elements("Term"))
            {
                Create-Term $childTermNode $term $termSet $store $lcid $spContext
            }
        }
    }
}

#This will import the entire XML into your given SharePoint site, it will add any information that is missing from the given TermStore.
#./Import-Taxonomy.ps1 -AdminUser user@sp.com -AdminPassword password -AdminUrl https://sp-admin.onmicrosoft.com -FilePathOfExportXMLTerms c:\myTerms\exportedterms.xml -PathToSPClientdlls "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI"

 