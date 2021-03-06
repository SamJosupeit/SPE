param([String]$WorkingDir)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - D-40882 Ratingen                                            #
# Kunde   : MT Intern                                                 #
# Powershell-Script                                                   #
# #####################################################################
# Name    : Analyze_SPFarm.ps1                                        #
# Funktion: Dieses Script analysiert eine SharePoint-Farm und gibt    #
# die Ergebnisse zur weiteren Auswertung in Log- und Report-Files     #
# aus.                                                                #
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | G.Josupeit | Erst-Erstellung                    | 08.01.2015 #
# 0.2  | G.Josupeit | Funktionen erzeugt                 | 08.01.2015 #
######################################################################>
#endregion

#region Voreinstellungen !!! Nicht ändern !!!

	#region Startzeit
	$global:starttime = get-date
	#endregion

    #region Wechsle in Arbeitsverzeichnis, wenn gesetzt
    if($WorkingDir){
        cd $WorkingDir
    }
    #endregion
	
    #region Globale Variablen
        #region Erfassen des Scriptnamens zur Erstellung von Log- und Statusfile
            Set-Variable -Name ScriptName -Value ($MyInvocation.MyCommand.Name -replace ".ps1","")
            Set-Variable -Name ThisScript -Value ($MyInvocation.MyCommand.Definition)
        #endregion

        # ComputerName
            Set-Variable -Name computerName -Value ($env:COMPUTERNAME)
            
        #region Pfad zum Arbeitsverzeichnis
            Set-Variable -Name PathWorkingDir -Value (Get-Location)
            Set-Variable -Name StringWorkingDir -Value ($PathWorkingDir.ToString() + "\")
            Set-Variable -Name dirLog -Value ($StringWorkingDir + "Log\")
            Set-Variable -Name dirRep -Value ($StringWorkingDir + "Reports\")
            Set-Variable -Name dirResults -Value ($StringWorkingDir + "Results\")
            Set-Variable -Name xmlFilePath -Value ($dirResults + $ScriptName + "_Results.xml")
        #endregion
    #endregion

    #region Dot-Sourcing
        . .\Config.ps1
        . .\Sources.ps1
    #endregion 

    #region Add SharePoint PowerShell Snapin
    if($global:UsingSharePoint){
        if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) {
            Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue
        }
    }
    #endregion


    #region Warnmeldungen

        #region Warnung, falls TestModus aktiviert ist
        if($TestModus -eq $true){
            Log-Message -Content "!!!Achtung!!! TestModus aktiv !!! Es werden keine Daten gelöscht oder geschrieben !!!"
            Log-Message -Content "!!! Dient nur zum reinen Funktionstest !!!"
        }
        #endregion

        #region Warnung, falls Logging auf Console deaktiviert ist
        if(!$LogToConsole){
            Write-Host "Logging auf Console ist deaktiviert." -ForegroundColor DarkYellow
            if($LogToLogFile){
                Write-Host "Logging erfolgt in Logfile. `nLogfile wird am Ende des Scripts geöffnet.`n" -ForegroundColor DarkYellow
            }
            if($LogToULSFile){
                Write-Host "Logging erfolgt in ULSfile. `nULSfile Bitte mit dem ULSViewer prüfen.`n" -ForegroundColor DarkYellow
            }
        }
        #endregion

    #endregion

    #region Prüfe Console auf Ausführung "als Administrator"
    if($global:RunAsAdmin)
    {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.windowsIdentity]::GetCurrent())
        if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
            $argumentList = "$ThisScript -workingDir $StringWorkingDir"
            start-process powershell -ArgumentList $argumentList -Verb RunAs
            Wait-Loop -text "Das Script muss mit Administrator-Berechtigungen ausgeführt werden und wurde daher in einem neuen Konsolen-Fenster neu gestartet. Dieses Fenster wird geschlossen." -time 10
            Stop-Process $PID
        }
    }
    #endregion

	#region ScriptStatus
	$scriptCorrId = $global:InitialCorrelationIDs.($Scriptname)
	$global:CorrelationId = $scriptCorrId
	Log-Message -message "Script has started." -level "High"
	Report-Message -level "High" -area "Script" -category "Started" -message "Script has started." -CorrelationId $scriptCorrId
    Display-TextLine -text "Willkommen zum SharePoint-Farm-Analyse-Script."
    Wait-ForKey
	$scriptaborted = $false
	$foundErrors = $false
	#endregion

#endregion

#region Hauptprogramm !!! Hier kann gearbeitet werden !!!

    Trap-CtrlC
    while($true)
    {
    Trap-CtrlC
    #region Step 1: Erfassen der Websites
    if(!(Test-Path $dirResults))
	{
	    New-Item -Path $dirResults -ItemType "Directory"
	}

    $xmlDoc = Ensure-XmlFile -FilePath $xmlFilePath -RootNodeName "Results"
    $xmlRoot = $xmlDoc.get_DocumentElement()
    #region Berechtigungen 
    #Initiale Correlation ID's
    $corrIdWebApplication = Increment-Guid1stBlock $global:CorrelationId
    $lfdNrWebApp = 0
    $lfdNrSite = 0
    $lfdNrWeb = 0
    $lfdNrList = 0
    $counterUniquePermissionsWebSites = 0
    $counterUniquePermissionsLists = 0
    Log-Message -level Verbose -message "Iteriere WebApplications..." -CorrelationId $scriptCorrId
    Display-TextLine -text "Erfasse nun Berechtigungen bis Listen-Ebene..."
    $newNodeWebApplications = $xmlDoc.CreateElement("WebApplications")
    foreach($webApp in (Get-SPWebApplication))
    {
        Trap-CtrlC
        $lfdNrWebApp++
        #region Creating Node Webapplication
        Log-Message -level Verbose -message "Erstelle Node 'WebApplication'." -CorrelationId $corrIdWebApplication
        $newNodeWebApp = $xmlDoc.CreateElement("WebApplication")
        Log-Message -level Verbose -message "Füge Attribut 'Name' mit Wert '$($webApp.Name)' hinzu." -CorrelationId $corrIdWebApplication
        $catchOut = $newNodeWebApp.SetAttribute("Name", $webApp.Name)
        Log-Message -level Verbose -message "Füge Attribut 'Url' mit Wert '$($webApp.Url)' hinzu." -CorrelationId $corrIdWebApplication
        $catchOut = $newNodeWebApp.SetAttribute("Url", $webApp.Url)
        Log-Message -level Verbose -message "Füge Attribut 'LfdNr' mit Wert '$lfdNrWebApp' hinzu." -CorrelationId $corrIdWebApplication
        $catchOut = $newNodeWebApp.SetAttribute("LfdNr", $lfdNrWebApp)
        $textWebApp = "aktuelle WebApplication: $lfdNrWebApp - $($webApp.Name)"
        #endregion

        #Iterate SiteCollections
        $allSiteCollectionUrls = New-Object System.Collections.ArrayList
        Log-Message -level Verbose -message "Iteriere SiteCollections innerhalb der WebApplication '$($webapp.Name)'" -CorrelationId $corrIdWebApplication
        $corrIdSiteCollection = Increment-Guid2ndBlock $corrIdWebApplication
        foreach($site in $webApp.Sites)
        {
            Trap-CtrlC
            $lfdNrSite++
            #region Creating Node SiteCollection
            #Log-Message -level Verbose -message "Erstelle Node 'SiteCollection'." -CorrelationId $corrIdSiteCollection
            $newNodeSiteCollection = $xmlDoc.CreateElement("SiteCollection")
            #Log-Message -level Verbose -message "Füge Attribut 'Url' mit Wert '$($site.Url)' hinzu." -CorrelationId $corrIdSiteCollection
            $catchOut = $newNodeSiteCollection.SetAttribute("Url", $site.Url)
            #Log-Message -level Verbose -message "Füge Attribut 'LfdNr' mit Wert '$lfdNrSite' hinzu." -CorrelationId $corrIdSiteCollection
            $catchOut = $newNodeSiteCollection.SetAttribute("LfdNr", $lfdNrSite)
            $catchOut = $newNodeSiteCollection.SetAttribute("PrimaryOwner", $site.Owner.DisplayName)
            $catchOut = $newNodeSiteCollection.SetAttribute("SecondaryOwner", $site.SecondaryContact.DisplayName)
            $textSite = "aktuelle SiteCollection: $lfdNrSite - $($site.Url)"
            #endregion

            #region Getting Permissions
            $newNodeSiteCollectionPermissions = $xmlDoc.CreateElement("Permissions")

            $catchOut = $newNodeSiteCollection.AppendChild($newNodeSiteCollectionPermissions)
            #endregion

            #Iterating WebSites
            Log-Message -level Verbose -message "Iteriere WebSites innerhalb SiteCollection '$($site.Url)' innerhalb der WebApplication '$($webapp.Name)'" -CorrelationId $corrIdSiteCollection
            $corrIdWebSite = Increment-Guid3rdBlock $corrIdSiteCollection
            foreach($web in $site.AllWebs)
            {
                Trap-CtrlC
                $lfdNrWeb++
                #region Creating Node WebSite
                #Log-Message -level Verbose -message "Erstelle Node 'WebSite'." -CorrelationId $corrIdWebsite
                $newNodeWebSite = $xmlDoc.CreateElement("WebSite")
                $webTemplate = $web.WebTemplate
                $webTemplateId = $web.WebTemplateId
                $webTemplateName = $webTemplate + "#" + $webTemplateId
                $webLanguage = $web.Language
                $webUIVersion = $web.UIVersion
                $webTemplateTitle = Get-SPWebTemplate | ?{(($_.Name -eq $webTemplateName) -and ($_.LocaleId -eq $webLanguage) -and ($_.CompatibilityLevel -eq $webUIVersion))} | select Title
                $catchOut = $newNodeWebSite.SetAttribute("WebTemplateTitle", $webTemplateTitle.Title)
                $catchOut = $newNodeWebSite.SetAttribute("WebTemplateName", $webTemplateName)

                #Log-Message -level Verbose -message "Füge Attribut 'Title' mit Wert '$($web.Title)' hinzu." -CorrelationId $corrIdWebSite
                $catchOut = $newNodeWebSite.SetAttribute("Title", $web.title)
                #Log-Message -level Verbose -message "Füge Attribut 'Url' mit Wert '$($web.Url)' hinzu." -CorrelationId $corrIdWebSite
                $catchOut = $newNodeWebSite.SetAttribute("Url", $web.Url)
                # Log-Message -level Verbose -message "Füge Attribut 'LfdNr' mit Wert '$lfdNrWeb' hinzu." -CorrelationId $corrIdWebSite
                $catchOut = $newNodeWebSite.SetAttribute("LfdNr", $lfdNrWeb)

                $textWeb = "aktuelle WebSite: $lfdNrWeb - $($web.Title)"
                #endregion
                
                #region Getting Permissions
                $newNodeWebSitePermissions = $xmlDoc.CreateElement("Permissions")
                if($web.HasUniqueRoleAssignments)
                {
                    $newNodeWebSitePermissionsInheritance = $xmlDoc.CreateElement("PermissionsAreInheritedFromParent")
                    $catchOut = $newNodeWebSitePermissions.Appendchild($newNodeWebSitePermissionsInheritance)
                    $counterUniquePermissionsWebSites++
                } 
                else 
                {
                    #region Iterating Permissions
                    foreach($permission in $web.Permissions){
                        Trap-CtrlC
                        $newNodeWSPermMember = $xmlDoc.CreateElement("Member")
                        $catchOut = $newNodeWSPermMember.SetAttribute("Name",$permission.Member)

                        $catchOut = $newNodeWebSitePermissions.AppendChild($newNodeWSPermMember)

                    }
                    #endregion
                    #region Getting Groups
                    $newNodeWebSiteGroups = $xmlDoc.CreateElement("Groups")
                    foreach($group in $web.Groups){
                        Trap-CtrlC
                        $newNodeWebSiteGroup = $xmlDoc.CreateElement("Group")
                        $catchOut = $newNodeWebSiteGroup.SetAttribute("Name",$group.Name)

                        $newNodeWebSiteGroupRoles = $xmlDoc.CreateElement("Roles")
                        foreach($role in $group.Roles)
                        {
                            Trap-CtrlC
                            $newNodeWebSiteGroupRole = $xmldoc.CreateElement("Role")
                            $catchOut = $newNodeWebSiteGroupRole.SetAttribute("Name", $role.Name)

                            $catchOut = $newNodeWebSiteGroupRoles.AppendChild($newNodeWebSiteGroupRole)
                        }
                        $catchOut = $newNodeWebSiteGroup.AppendChild($newNodeWebSiteGroupRoles)

                        $newNodeWebSiteGroupUsers = $xmlDoc.CreateElement("Users")
                        foreach($user in $group.Users)
                        {
                                $newNodeWebSiteGroupUser = $xmlDoc.CreateElement("User")
                                $catchOut = $newNodeWebSiteGroupUser.SetAttribute("UserLogin",$user.UserLogin)
                                $catchOut = $newNodeWebSiteGroupUser.SetAttribute("DisplayName",$user.DisplayName)

                                $catchOut = $newNodeWebSiteGroupUsers.AppendChild($newNodeWebSiteGroupUser)
                        }
                        $catchOut = $newNodeWebSiteGroup.AppendChild($newNodeWebSiteGroupUsers)
                        $catchOut = $newNodeWebSiteGroups.AppendChild($newNodeWebSiteGroup)
                    }
                    $catchOut = $newNodeWebSite.AppendChild($newNodeWebSiteGroups)
                    #endregion
                }

                $catchOut = $newNodeWebSite.AppendChild($newNodeWebSitePermissions)

                #endregion
                

                #Iterating Lists
                Log-Message -level Verbose -message "Iteriere Lists innerhalb der WebSite '$($web.Title)' innerhalb der SiteCollection '$($site.Url)' innerhalb der WebApplication '$($webapp.Name)'" -CorrelationId $corrIdSiteCollection
                $corrIdList = Increment-Guid4thBlock $corrIdWebSite
                $newNodeLists = $xmlDoc.CreateElement("Lists")
                foreach($list in $web.Lists)
                {
                    Trap-CtrlC
                    $lfdNrList++
                    #region Creating Node WebSite
                    #Log-Message -level Verbose -message "Erstelle Node 'List'." -CorrelationId $corrIdList
                    $newNodeList = $xmlDoc.CreateElement("List")
                    #Log-Message -level Verbose -message "Füge Attribut 'ItemCount' mit Wert '$($list.ItemCount)' hinzu." -CorrelationId $corrIdList
                    $catchOut = $newNodeList.SetAttribute("ItemCount", $list.ItemCount)
                    #Log-Message -level Verbose -message "Füge Attribut 'Title' mit Wert '$($list.Title)' hinzu." -CorrelationId $corrIdList
                    $catchOut = $newNodeList.SetAttribute("Title", $list.title)
                    #Log-Message -level Verbose -message "Füge Attribut 'LfdNr' mit Wert '$lfdNrList' hinzu." -CorrelationId $corrIdList
                    $catchOut = $newNodeList.SetAttribute("LfdNr", $lfdNrList)
                    $listTemplate = $list.BaseTemplate
                    $catchOut = $newNodeList.SetAttribute("BaseTemplate", $listTemplate)

                    $textList = "aktuelle Liste: $lfdNrList - $($list.Title)"
                    #endregion
                    Display-TextArray -textArray ($textWebApp,"",$textSite,"",$textWeb,"",$textList,"")
                  
                    #region Getting Permissions
                    $newNodeListPermissions = $xmlDoc.CreateElement("Permissions")
                    if($list.HasUniqueRoleAssignments)
                    {
                        $newNodeListPermissionsInheritance = $xmlDoc.CreateElement("PermissionsAreInheritedFromParent")
                        $catchOut = $newNodeListPermissions.Appendchild($newNodeListPermissionsInheritance)
                        $counterUniquePermissionsLists++
                    } 
                    else 
                    {
                        #region Iterating Permissions
                        foreach($listPermission in $list.Permissions){
                            Trap-CtrlC
                            $newNodeListPermMember = $xmlDoc.CreateElement("Member")
                            $catchOut = $newNodeListPermMember.SetAttribute("Name",$listPermission.Member)

                            $catchOut = $newNodelistPermissions.AppendChild($newNodeListPermMember)

                        }
                        #endregion
                    }
                    $catchOut = $newNodeList.AppendChild($newNodeListPermissions)
                    #endregion

                    $catchOut = $newNodeLists.AppendChild($newNodeList)
                    $corrIdList = Increment-Guid4thBlock $corrIdList
                }
                $catchOut = $newNodeWebSite.AppendChild($newNodeLists)

                $web.Dispose()
                $catchOut = $newNodeSiteCollection.AppendChild($newNodeWebSite)
                $corrIdWebSite = Increment-Guid3rdBlock $corrIdWebsite
            }

            $site.Dispose()
            $catchOut = $newNodeWebApp.AppendChild($newNodeSiteCollection)
            $corrIdSiteCollection = Increment-Guid2ndBlock $corrIdSiteCollection
        }
       
        #Writing Node to Document
        
        $corrIdWebApplication = Increment-Guid1stBlock $corrIdWebApplication
        $catchOut = $newNodeWebApplications.AppendChild($newNodeWebApp)
    }
    #endregion

    #region creating Summaries
    $newNodeSummaries = $xmlDoc.CreateElement("Summaries")

        #region creating Summary 'Berechtigungen'
        $newNodeCounters = $xmlDoc.CreateElement("Zähler")

        #Counter WebApplications
        $newNodeCounterWebApps = $xmlDoc.CreateElement("WebApplications")
        $catchOut = $newNodeCounterWebApps.SetAttribute("AnzahlGesamt",$lfdNrWebApp)
        $catchOut = $newNodeCounters.Appendchild($newNodeCounterWebApps)

        #Counter SiteCollections
        $newNodeCounterSites = $xmlDoc.CreateElement("SiteCollections")
        $catchOut = $newNodeCounterSites.SetAttribute("AnzahlGesamt",$lfdNrSite)
        $catchOut = $newNodeCounters.Appendchild($newNodeCounterSites)

        #Counter WebSites
        $newNodeCounterWebs = $xmlDoc.CreateElement("WebSites")
        $catchOut = $newNodeCounterWebs.SetAttribute("AnzahlGesamt",$lfdNrWeb)
        $catchOut = $newNodeCounterWebs.SetAttribute("WebsitesWithUniquePermissions",$counterUniquePermissionsWebSites)
        $catchOut = $newNodeCounters.Appendchild($newNodeCounterWebs)

        #Counter Lists
        $newNodeCounterLists = $xmlDoc.CreateElement("Listen")
        $catchOut = $newNodeCounterLists.SetAttribute("AnzahlGesamt",$lfdNrList)
        $catchOut = $newNodeCounterLists.SetAttribute("ListsWithUniquePermissions",$counterUniquePermissionsLists)
        $catchOut = $newNodeCounters.Appendchild($newNodeCounterLists)


        $catchOut = $newNodeSummaries.AppendChild($newNodeCounters)
        #endregion

        #Zeiten
        $newNodeTimes = $xmlDoc.CreateElement("Zeiten")

        $newNodeStartTime = $xmlDoc.CreateElement("ScriptStart")
        $catchOut = $newNodeStartTime.set_InnerText($global:starttime.ToString())
        $catchOut = $newNodeTimes.AppendChild($newNodeStartTime)

        $scriptEndTime = Get-Date
        $newNodeEndTime = $xmlDoc.CreateElement("ScriptEnd")
        $catchOut = $newNodeEndTime.set_InnerText($scriptEndTime.ToString())
        $catchOut = $newNodeTimes.AppendChild($newNodeEndTime)

        $scriptDurationTime = $scriptEndTime - $global:starttime
        $newNodeDurationTime = $xmlDoc.CreateElement("ScriptDauer")
        $catchOut = $newNodeDurationTime.set_InnerText("{0:c}" -f $scriptDurationTime)
        $catchOut = $newNodeTimes.AppendChild($newNodeDurationTime)


        $catchout = $newNodeSummaries.AppendChild($newNodeTimes)

    $catchOut = $xmlRoot.AppendChild($newNodeSummaries)
    #endregion
    $catchOut = $xmlRoot.AppendChild($newNodeWebApplications)

    $catchOut = $xmlDoc.Save($xmlFilePath)
    Log-Message -level Verbose -message "...Iterieration der WebApplications abgeschlossen." -CorrelationId $scriptCorrId
    #endregion
    break
    }
    Trap [ExecutionEngineException]{
        Log-Message -level High -CorrelationId $scriptCorrId -message "Script terminated. Saving XML-File..."
        Display-TextLine -text "Script terminated. Saving XML-File..."
        $scriptaborted = $true
                   
        if(($newNodeWebSiteGroupRoles -ne $null) -and ($newNodeWebSiteGroupRole -ne $null)){$catchOut = $newNodeWebSiteGroupRoles.AppendChild($newNodeWebSiteGroupRole)}
        if(($newNodeWebSiteGroupUsers -ne $null) -and ($newNodeWebSiteGroupUser -ne $null)){$catchOut = $newNodeWebSiteGroupUsers.AppendChild($newNodeWebSiteGroupUser)}
        if(($newNodeWebSiteGroup -ne $null) -and ($newNodeWebSiteGroupRoles -ne $null)){$catchOut = $newNodeWebSiteGroup.AppendChild($newNodeWebSiteGroupRoles)}
        if(($newNodeWebSiteGroup -ne $null) -and ($newNodeWebSiteGroupUsers -ne $null)){$catchOut = $newNodeWebSiteGroup.AppendChild($newNodeWebSiteGroupUsers)}
        if(($newNodeWebSiteGroups -ne $null) -and ($newNodeWebSiteGroup -ne $null)){$catchOut = $newNodeWebSiteGroups.AppendChild($newNodeWebSiteGroup)}
        if(($newNodeWebSitePermissions -ne $null) -and ($newNodeWSPermMember -ne $null)){$catchOut = $newNodeWebSitePermissions.AppendChild($newNodeWSPermMember)}
        if(($newNodeListPermissions -ne $null) -and ($newNodeListPermissionsInheritate -ne $null)){$catchOut = $newNodeListPermissions.Appendchild($newNodeListPermissionsInheritate)}
        if(($newNodeList -ne $null) -and ($newNodeListPermissions -ne $null)){$catchOut = $newNodeList.AppendChild($newNodeListPermissions)}
        if(($newNodeLists -ne $null) -and ($newNodeList -ne $null)){$catchOut = $newNodeLists.AppendChild($newNodeList)}
        if(($newNodeWebSite -ne $null) -and ($newNodeWebSiteGroups -ne $null)){$catchOut = $newNodeWebSite.AppendChild($newNodeWebSiteGroups)}
        if(($newNodeWebSitePermission -ne $null) -and ($newNodeWebSitePermissionsInheritate -ne $null)){$catchOut = $newNodeWebSitePermissions.Appendchild($newNodeWebSitePermissionsInheritate)}
        if(($newNodeWebSite -ne $null) -and ($newNodeWebSitePermissions -ne $null)){$catchOut = $newNodeWebSite.AppendChild($newNodeWebSitePermissions)}
        if(($newNodeWebSite -ne $null) -and ($newNodeLists -ne $null)){$catchOut = $newNodeWebSite.AppendChild($newNodeLists)}
        if(($newNodeSiteCollection -ne $null) -and ($newNodeWebSite -ne $null)){$catchOut = $newNodeSiteCollection.AppendChild($newNodeWebSite)}
        if(($newNodeWebApp -ne $null) -and ($newNodeSiteCollection -ne $null)){$catchOut = $newNodeWebApp.AppendChild($newNodeSiteCollection)}
        if(($newNodeWebAppplications -ne $null) -and ($newNodeWebApp -ne $null)){$catchOut = $newNodeWebApplications.AppendChild($newNodeWebapp)}
                #Zeiten
        $newNodeTimes = $xmlDoc.CreateElement("Zeiten")

        $newNodeStartTime = $xmlDoc.CreateElement("ScriptStart")
        $catchOut = $newNodeStartTime.set_InnerText($global:starttime.ToString())
        $catchOut = $newNodeTimes.AppendChild($newNodeStartTime)

        $scriptEndTime = Get-Date
        $newNodeEndTime = $xmlDoc.CreateElement("ScriptEnd")
        $catchOut = $newNodeEndTime.set_InnerText($scriptEndTime.ToString())
        $catchOut = $newNodeTimes.AppendChild($newNodeEndTime)

        $scriptDurationTime = $scriptEndTime - $global:starttime
        $newNodeDurationTime = $xmlDoc.CreateElement("ScriptDauer")
        $catchOut = $newNodeDurationTime.set_InnerText("{0:c}" -f $scriptDurationTime)
        $catchOut = $newNodeTimes.AppendChild($newNodeDurationTime)


        $catchout = $xmlRoot.AppendChild($newNodeTimes)

        $catchOut = $xmlRoot.AppendChild($newNodeWebApplications)
        $catchOut = $xmlDoc.Save($xmlFilePath)
        $web.Dispose()
        $site.Dispose()
        Log-Message -level High -CorrelationId $scriptCorrId -message "...XML-File saved. Stop the script."
        Continue
    }

    #open Result.xml in IE
    $ie = new-Object -com "InternetExplorer.Application"
    $ie.visible = $true
    $ie.navigate("file://" + $xmlFilePath.Replace("\","/"))
#endregion

#region End of Script and opening of the script's logfile
	
	if($scriptaborted) {
		Report-Message -level "Critical" -area "Script" -category "Aborted" -message "Script has been aborted. Check Log(s)" -CorrelationId $scriptCorrId
		Log-Message -level "Critical" -area "Script" -category "Aborted" -message "Script has been aborted. Check Log(s)" -CorrelationId $scriptCorrId
    } elseif($foundErrors){
		Report-Message -level "High" -area "Script" -category "Stopped" -message "Script has finished with errors. Check Log(s)" -CorrelationId $scriptCorrId
		Log-Message -level "High" -area "Script" -category "Stopped" -message "Script has finished with errors. Check Log(s)" -CorrelationId $scriptCorrId
	} else {
		Report-Message -message "Script has successfully finished without any error." -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
		Log-Message -message "Script has successfully finished without any error." -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
	}

	if($TestMode){
        Wait-ForKey
    }
    if($LogToLogFile){
        notepad.exe $PathToLogfile
    }
#endregion
#EndOfFile
