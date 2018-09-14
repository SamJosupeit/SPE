    #region Function New-SPECsomListField
    #.ExternalHelp SPE.SharePoint.psm1-help.xml
    Function New-SPECsomListField
    {
        [CmdletBinding()]
        param(
            [Microsoft.SharePoint.Client.List]$list,
            [System.Collections.HashTable]$fieldDefinitions
        )
        Begin{
            $curCtx = $list.Context
        }
        Process{
        $fieldXml = "<Field "
        foreach($fieldDefinition in $fieldDefinitions){
            if($fieldDefinition.AllowDeletion){$fieldXml += (" " + $fieldDefinition.AllowDeletion)}
            if($fieldDefinition.AllowDuplicateValues){$fieldXml += (" " + $fieldDefinition.AllowDuplicateValues)}
            if($fieldDefinition.AllowHyperlink){$fieldXml += (" " + $fieldDefinition.AllowHyperlink)}
            if($fieldDefinition.AllowMultiVote){$fieldXml += (" " + $fieldDefinition.AllowMultiVote)}
            if($fieldDefinition.AppendOnly){$fieldXml += (" " + $fieldDefinition.AppendOnly)}
            if($fieldDefinition.AuthoringInfo){$fieldXml += (" " + $fieldDefinition.AuthoringInfo)}
            if($fieldDefinition.BaseType){$fieldXml += (" " + $fieldDefinition.BaseType)}
            if($fieldDefinition.CalType){$fieldXml += (" " + $fieldDefinition.CalType)}
            if($fieldDefinition.CanToggleHidden){$fieldXml += (" " + $fieldDefinition.CanToggleHidden)}
            if($fieldDefinition.ClassInfo){$fieldXml += (" " + $fieldDefinition.ClassInfo)}
            if($fieldDefinition.ColName){$fieldXml += (" " + $fieldDefinition.ColName)}
            if($fieldDefinition.Commas){$fieldXml += (" " + $fieldDefinition.Commas)}
            if($fieldDefinition.Customization){$fieldXml += (" " + $fieldDefinition.Customization)}
            if($fieldDefinition.Decimals){$fieldXml += (" " + $fieldDefinition.Decimals)}
            if($fieldDefinition.DefaultListField){$fieldXml += (" " + $fieldDefinition.DefaultListField)}
            if($fieldDefinition.Description){$fieldXml += (" " + $fieldDefinition.Description)}
            if($fieldDefinition.Dir){$fieldXml += (" " + $fieldDefinition.Dir)}
            if($fieldDefinition.DisplaceOnUpgrade){$fieldXml += (" " + $fieldDefinition.DisplaceOnUpgrade)}
            if($fieldDefinition.DisplayImage){$fieldXml += (" " + $fieldDefinition.DisplayImage)}
            if($fieldDefinition.DisplayName){$fieldXml += (" " + $fieldDefinition.DisplayName)}
            if($fieldDefinition.DisplayNameSrcField){$fieldXml += (" " + $fieldDefinition.DisplayNameSrcField)}
            if($fieldDefinition.DisplaySize){$fieldXml += (" " + $fieldDefinition.DisplaySize)}
            if($fieldDefinition.Div){$fieldXml += (" " + $fieldDefinition.Div)}
            if($fieldDefinition.EnableLookup){$fieldXml += (" " + $fieldDefinition.EnableLookup)}
            if($fieldDefinition.ExceptionImage){$fieldXml += (" " + $fieldDefinition.ExceptionImage)}
            if($fieldDefinition.FieldRef){$fieldXml += (" " + $fieldDefinition.FieldRef)}
            if($fieldDefinition.FillInChoice){$fieldXml += (" " + $fieldDefinition.FillInChoice)}
            if($fieldDefinition.Filterable){$fieldXml += (" " + $fieldDefinition.Filterable)}
            if($fieldDefinition.FilterableNoRecurrence){$fieldXml += (" " + $fieldDefinition.FilterableNoRecurrence)}
            if($fieldDefinition.ForcedDisplay){$fieldXml += (" " + $fieldDefinition.ForcedDisplay)}
            if($fieldDefinition.Format){$fieldXml += (" " + $fieldDefinition.Format)}
            if($fieldDefinition.FromBaseType){$fieldXml += (" " + $fieldDefinition.FromBaseType)}
            if($fieldDefinition.Group){$fieldXml += (" " + $fieldDefinition.Group)}
            if($fieldDefinition.HeaderImage){$fieldXml += (" " + $fieldDefinition.HeaderImage)}
            if($fieldDefinition.Height){$fieldXml += (" " + $fieldDefinition.Height)}
            if($fieldDefinition.Hidden){$fieldXml += (" " + $fieldDefinition.Hidden)}
            if($fieldDefinition.HTMLEncode){$fieldXml += (" " + $fieldDefinition.HTMLEncode)}
            if($fieldDefinition.ID){$fieldXml += (" " + $fieldDefinition.ID)}
            if($fieldDefinition.IMEMode){$fieldXml += (" " + $fieldDefinition.IMEMode)}
            if($fieldDefinition.Indexed){$fieldXml += (" " + $fieldDefinition.Indexed)}
            if($fieldDefinition.IsolateStyles){$fieldXml += (" " + $fieldDefinition.IsolateStyles)}
            if($fieldDefinition.IsRelationship){$fieldXml += (" " + $fieldDefinition.IsRelationship)}
            if($fieldDefinition.JoinColName){$fieldXml += (" " + $fieldDefinition.JoinColName)}
            if($fieldDefinition.JoinRowOrdinal){$fieldXml += (" " + $fieldDefinition.JoinRowOrdinal)}
            if($fieldDefinition.JoinType){$fieldXml += (" " + $fieldDefinition.JoinType)}
            if($fieldDefinition.LCID){$fieldXml += (" " + $fieldDefinition.LCID)}
            if($fieldDefinition.LinkToItem){$fieldXml += (" " + $fieldDefinition.LinkToItem)}
            if($fieldDefinition.List){$fieldXml += (" " + $fieldDefinition.List)}
            if($fieldDefinition.Max){$fieldXml += (" " + $fieldDefinition.Max)}
            if($fieldDefinition.MaxLength){$fieldXml += (" " + $fieldDefinition.MaxLength)}
            if($fieldDefinition.Min){$fieldXml += (" " + $fieldDefinition.Min)}
            if($fieldDefinition.Mult){$fieldXml += (" " + $fieldDefinition.Mult)}
            if($fieldDefinition.Name){$fieldXml += (" " + $fieldDefinition.Name)}
            if($fieldDefinition.NegativeFormat){$fieldXml += (" " + $fieldDefinition.NegativeFormat)}
            if($fieldDefinition.Node){$fieldXml += (" " + $fieldDefinition.Node)}
            if($fieldDefinition.NoEditFormBreak){$fieldXml += (" " + $fieldDefinition.NoEditFormBreak)}
            if($fieldDefinition.NumLines){$fieldXml += (" " + $fieldDefinition.NumLines)}
            if($fieldDefinition.Overwrite){$fieldXml += (" " + $fieldDefinition.Overwrite)}
            if($fieldDefinition.OverwriteInChildScopes){$fieldXml += (" " + $fieldDefinition.OverwriteInChildScopes)}
            if($fieldDefinition.Percentage){$fieldXml += (" " + $fieldDefinition.Percentage)}
            if($fieldDefinition.PIAttribute){$fieldXml += (" " + $fieldDefinition.PIAttribute)}
            if($fieldDefinition.PITarget){$fieldXml += (" " + $fieldDefinition.PITarget)}
            if($fieldDefinition.PrependId){$fieldXml += (" " + $fieldDefinition.PrependId)}
            if($fieldDefinition.Presence){$fieldXml += (" " + $fieldDefinition.Presence)}
            if($fieldDefinition.PrimaryKey){$fieldXml += (" " + $fieldDefinition.PrimaryKey)}
            if($fieldDefinition.PrimaryPIAttribute){$fieldXml += (" " + $fieldDefinition.PrimaryPIAttribute)}
            if($fieldDefinition.PrimaryPITarget){$fieldXml += (" " + $fieldDefinition.PrimaryPITarget)}
            if($fieldDefinition.ReadOnly){$fieldXml += (" " + $fieldDefinition.ReadOnly)}
            if($fieldDefinition.ReadOnlyEnforced){$fieldXml += (" " + $fieldDefinition.ReadOnlyEnforced)}
            if($fieldDefinition.RelationshipDeleteBehavior){$fieldXml += (" " + $fieldDefinition.RelationshipDeleteBehavior)}
            if($fieldDefinition.RenderXMLUsingPattern){$fieldXml += (" " + $fieldDefinition.RenderXMLUsingPattern)}
            if($fieldDefinition.Required){$fieldXml += (" " + $fieldDefinition.Required)}
            if($fieldDefinition.RestrictedMode){$fieldXml += (" " + $fieldDefinition.RestrictedMode)}
            if($fieldDefinition.ResultType){$fieldXml += (" " + $fieldDefinition.ResultType)}
            if($fieldDefinition.RichText){$fieldXml += (" " + $fieldDefinition.RichText)}
            if($fieldDefinition.RichTextMode){$fieldXml += (" " + $fieldDefinition.RichTextMode)}
            if($fieldDefinition.RowOrdinal){$fieldXml += (" " + $fieldDefinition.RowOrdinal)}
            if($fieldDefinition.Sealed){$fieldXml += (" " + $fieldDefinition.Sealed)}
            if($fieldDefinition.SeperateLine){$fieldXml += (" " + $fieldDefinition.SeperateLine)}
            if($fieldDefinition.SetAs){$fieldXml += (" " + $fieldDefinition.SetAs)}
            if($fieldDefinition.ShowAddressBookButton){$fieldXml += (" " + $fieldDefinition.ShowAddressBookButton)}
            if($fieldDefinition.ShowField){$fieldXml += (" " + $fieldDefinition.ShowField)}
            if($fieldDefinition.ShowInDisplayForm){$fieldXml += (" " + $fieldDefinition.ShowInDisplayForm)}
            if($fieldDefinition.ShowInEditForm){$fieldXml += (" " + $fieldDefinition.ShowInEditForm)}
            if($fieldDefinition.ShowInFileDlg){$fieldXml += (" " + $fieldDefinition.ShowInFileDlg)}
            if($fieldDefinition.ShowInListSettings){$fieldXml += (" " + $fieldDefinition.ShowInListSettings)}
            if($fieldDefinition.ShowInNewForm){$fieldXml += (" " + $fieldDefinition.ShowInNewForm)}
            if($fieldDefinition.ShowInVersionHistory){$fieldXml += (" " + $fieldDefinition.ShowInVersionHistory)}
            if($fieldDefinition.ShowInViewForms){$fieldXml += (" " + $fieldDefinition.ShowInViewForms)}
            if($fieldDefinition.Sortable){$fieldXml += (" " + $fieldDefinition.Sortable)}
            if($fieldDefinition.SourceID){$fieldXml += (" " + $fieldDefinition.SourceID)}
            if($fieldDefinition.StaticName){$fieldXml += (" " + $fieldDefinition.StaticName)}
            if($fieldDefinition.StorageTZ){$fieldXml += (" " + $fieldDefinition.StorageTZ)}
            if($fieldDefinition.StripWS){$fieldXml += (" " + $fieldDefinition.StripWS)}
            if($fieldDefinition.SuppressNameDisplay){$fieldXml += (" " + $fieldDefinition.SuppressNameDisplay)}
            if($fieldDefinition.TextOnly){$fieldXml += (" " + $fieldDefinition.TextOnly)}
            if($fieldDefinition.Title){$fieldXml += (" " + $fieldDefinition.Title)}
            if($fieldDefinition.Type){$fieldXml += (" " + $fieldDefinition.Type)}
            if($fieldDefinition.UniqueId){$fieldXml += (" " + $fieldDefinition.UniqueId)}
            if($fieldDefinition.UnlimitedLengthInDocumentLibrary){$fieldXml += (" " + $fieldDefinition.UnlimitedLengthInDocumentLibrary)}
            if($fieldDefinition.URLEncode){$fieldXml += (" " + $fieldDefinition.URLEncode)}
            if($fieldDefinition.URLEncodeAsUrl){$fieldXml += (" " + $fieldDefinition.URLEncodeAsUrl)}
            if($fieldDefinition.UserSelectionMode){$fieldXml += (" " + $fieldDefinition.UserSelectionMode)}
            if($fieldDefinition.UserSelectionScope){$fieldXml += (" " + $fieldDefinition.UserSelectionScope)}
            if($fieldDefinition.Viewable){$fieldXml += (" " + $fieldDefinition.Viewable)}
            if($fieldDefinition.Width){$fieldXml += (" " + $fieldDefinition.Width)}
            if($fieldDefinition.WikiLinking){$fieldXml += (" " + $fieldDefinition.WikiLinking)}
            if($fieldDefinition.XName){$fieldXml += (" " + $fieldDefinition.XName)}
        }
        $fieldXml += " />"
        $list.Fields.AddFieldAsXml($fieldXml, $true, [Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
            
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Add-SPECsomListField
    Function Add-SPECsomListField{
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true,Position=0)][Microsoft.SharePoint.Client.List]$List,
            [Parameter(Mandatory=$true,Position=1)][String]$FieldDefinitionAsCAMLString
        )
        Begin{}
        Process{
            $List.Fields.AddFieldAsXml($FieldDefinitionAsCAMLString, $true, [Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
        }
        End{}
    }
    #endregion
    #EndOfFunction


    #region Function New-SPEListFieldDefinitionObject
    Function New-SPEListFieldDefinitionObject
    {
        [CmdletBinding()]
        param(
            [Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)][String]$Name,
            [Parameter(Position=1, Mandatory=$false, ValueFromPipeline = $true)][String]$StaticName=$Name,
            [Parameter(Position=2, Mandatory=$false, ValueFromPipeline = $true)][String]$DisplayName=$Name,
            [Parameter(Position=3, Mandatory=$true, ValueFromPipeline = $true)][String]$Guid=$(New-SPEGuid),
            [Parameter(Position=4, Mandatory=$true, ValueFromPipeline = $true)][Microsoft.SharePoint.Client.List]$List,
            [Parameter(ParameterSetName='TypeText')][switch]$TypeText,
            [Parameter(ParameterSetName='TypeMultiLine')][switch]$TypeMultiLine,
            [Parameter(ParameterSetName='TypeBoolean')][switch]$TypeBoolean,
            [Parameter(ParameterSetName='TypeDateTime')][switch]$TypeDateTime,
            [Parameter(ParameterSetName='TypeNumber')][switch]$TypeNumber,
            [Parameter(ParameterSetName='TypeChoice')][switch]$TypeChoice,
            [Parameter(ParameterSetName='TypePicture')][switch]$TypePicture,
            [Parameter(ParameterSetName='TypeURL')][switch]$TypeURL,
            [Parameter(ParameterSetName='TypeLookup')][switch]$TypeLookup,
            [Parameter(ParameterSetName='TypeUser')][switch]$TypeUser,
            [Parameter(ParameterSetName='TypeManagedMetadata')][switch]$TypeManagedMetadata,
            [Parameter(ParameterSetName='TypeCalculated')][switch]$TypeCalculated,


        )
        Begin{}
        Process{}
        End{}
    }
    #endregion

    #region Function Get-SPECsomListItems
    #.ExternalHelp SPE.SharePoint.psm1-help.xml
    Function Get-SPECsomListItems
    {
        <#
        .SYNOPSIS
        Noch nicht fertig!!!

        #>
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [Microsoft.SharePoint.Client.List]
		    $List
        )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
            $ctx = $List.Context
        }

        process 
        {
            $camlquery = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery()
            $listItems = $list.GetItems($camlquery)
            $ctx.Load($listItems)
            $ctx.ExecuteQuery()
            return $listItems
        }
    }
    #endregion
    #EndOfFunction

    #region Function Update-SPEConfigVariable
    Function Update-SPEConfigVariable
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)][String]$Name,
            [Parameter(Mandatory=$true)][String]$Value
        )
        Begin{}
        Process{
            $pathToConfig = $SPEVars.ConfigXMLFile;
            [xml]$config = Get-Content $pathToConfig;
            if($config.SPE_Config.($ScriptName).ScriptVariablen.($Name) -eq $null){
                #Variable does not exist, create
                $newXMLNode = $XmlDocument.CreateElement($Name)
                $newXMLNodeDesc = $XmlDocument.CreateElement("Beschreibung")
                $newXMLNode.AppendChild($newXMLNodeDesc)
                $newXMLNode.AppendChild($newXMLNodeValue)
                $newXMLNodeValue = $XmlDocument.CreateElement("Wert")
                $config.SPE_Config.($ScriptName).ScriptVariablen.AppendChild($newXMLNode)

            }
            $config.SPE_Config.($ScriptName).ScriptVariablen.($Name).Wert = $Value
            $config.save($pathToConfig)
            Get-SPEConfig -ScriptName $ScriptName
        }
        End{}
    }
    #endregion
    #EndOfFunction

#endregion
