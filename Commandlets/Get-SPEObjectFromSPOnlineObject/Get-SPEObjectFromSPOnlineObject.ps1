#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEObjectFromSPOnlineObject.ps1                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPEObjectFromSPOnlineObject
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Get-SPEObjectFromSPOnlineObject
    {
        [CmdletBinding()]
        param(
            [Parameter(Position=0,Mandatory=$false)]
            [Microsoft.SharePoint.Client.ClientContext]
            $Ctx,
            [Parameter(Position=1)]
            [ValidateNotNullOrEmpty()]
            $object,
            [Parameter(Position=2)]
            [String]
            $PropertyName,
            [Parameter(Position=3)]
            [Array]
            $PriorObjects,
            [Parameter(Position=4)]
            [int]
            $Level,
            [Parameter(Position=5)]
            [int]
            $CollectionCount,
            [Parameter(Position=6)]
            [int]
            $CollectionCurrent

        )
        Begin
        {
            Test-SPEAndLoadCsomDLLs
        }
        Process
        {
#            $textArray = @()
#            if($CollectionCount -and $CollectionCurrent)
#            {
#                $textArray += @(
#                    "CollectionItems : $CollectionCount",
#                    "Akt. Item Nr.   : $CollectionCurrent",
#                    ""
#                )
#            }
#            $textArray += @(
#                "Iterationstiefe : $Level",
#                "",
#                "PropertyName    : $PropertyName",
#                "",
#                "PriorObjects    :")
#            foreach($pObj in $PriorObjects)
#            {
#                $textArray += $pObj
#            }
            #Show-SPETextArray -textArray $textArray
#            $textMessage = ""
#            foreach($textString in $textArray)
#            {
#                $textMessage += $textString
#            }
            #Write-SPELogMessage -message $textMessage
            $Level++

            #region Parameter für Logging
            $curCorrId = $global:CorrelationId
            $fctCorrId = Set-SPEGuidIncrement4thBlock -guid $curCorrId
            #endregion
            if($PriorObjects -is [Array] -and !([String]::IsNullOrEmpty($PropertyName))) # -and $PriorObjects.Contains($PropertyName))
            {
                foreach($priorObject in $PriorObjects)
                {
                    $POName = $priorObject.Split(" - ")[0]
                    if($POName -eq $PropertyName)
                    {
                        return $null
                    }
                }
            } 
#            else 
#            {
                if(!($PriorObjects -is [Array]))
                {
                    $PriorObjects = @()
                    $PriorObjects = Get-SPEBaseTypeNameFromObject -object $object
                } else {
                    $PriorObjects += "$PropertyName - $CollectionCount - $CollectionCurrent"
                }
                $speObject = New-Object PsObject
                if((Get-SPEBaseTypeNameFromObject -object $object) -eq "Web")
                {
                    $speObject | Add-Member -MemberType NoteProperty -Name Context -Value $Ctx
                }

                #region Erfasse alle Properties
                $Properties = $object | gm -force | ?{$_.MemberType -eq "Property"} | ?{$_.Name.ToString() -ne ""} | select Name, Definition
                #endregion
                
                #region Erfasse Values der NON-SPC-Properties
                foreach($PropertyItem in $Properties)
                {
                    $fctCorrId = Set-SPEGuidIncrement4thBlock -guid $fctCorrId
  
                    $Property = $PropertyItem.Name.ToString()
                    $Definition = $PropertyItem.Definition.ToString()
                    if($Property -ne "TypedObject")
                    {
                        if($Definition.StartsWith("Microsoft.SharePoint.Client"))
                        {
                            try
                            {
                                $isComplexObject = $true
                                $childObject = Get-SPESPOnlineObjectByCtx -ParentObject $object -ChildObject $Property
                                if($childObject)
                                {
                                    if($Definition.Contains("Collection"))
                                    {
                                        $CurCollectionCount = $childObject.Count
                                        $collection = @()
                                        $collCnt = 0
                                        foreach($CollectionItem in $childObject)
                                        {
#                                            if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Schreibe SPC-Object '$Property'..." -level Verbose -CorrelationId $fctCorrId  -eventId $eventid -process $Property}
                                            $ChildObjects = Get-SPEObjectFromSPOnlineObject -object $childObject[$collCnt] -Ctx $Ctx -PropertyName $Property -PriorObjects $PriorObjects -Level $Level -CollectionCount $CurCollectionCount -CollectionCurrent $collCnt
                                            $collection += $ChildObjects
                                            $collCnt++
                                        }
                                        $speObject | Add-Member  -MemberType NoteProperty -Name $Property -Value $collection
                                        $collection.Clear()
                                    }
                                    else
                                    {
#                                        if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Schreibe SPC-Object '$Property'..." -level Verbose -CorrelationId $fctCorrId  -eventId $eventid -process $Property}
                                        $ChildObjects = Get-SPEObjectFromSPOnlineObject -object $childObject -Ctx $Ctx -PropertyName $Property -PriorObjects $PriorObjects -Level $Level
                                        $speObject | Add-Member  -MemberType NoteProperty -Name $Property -Value $ChildObjects
                                    }
                                }
                            }
                            catch
                            {
                                $isComplexObject = $false
                                #vielleicht doch ein Simple Object?
#                                if($global:ActivateTestLoggingException)
#                                {
#                                    $exMessage = $_.Exception.Message
#                                    $innerException = $_.Exception.InnerException
#                                    $info = "Fehler bei Erfassen des Property-Object '$Property_SPC'"
#                                    #Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
#                                }
                            }
                            if($isComplexObject)
                            {
                                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Schreiben von SPC-Object '$Property' erfolgreich abgeschlossen." -level Verbose -CorrelationId $fctCorrId  -eventId $eventid -process $Property}
                            }
                            else
                            {
                                try
                                {
#                                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "SPC-Object '$Property' konnte nicht als Object erfasst werden. Versuche als SimpleObject zu erfassen..." -level High -CorrelationId $fctCorrId  -eventId $eventid -process $Property}
                                    $isSimpleObject = $true
                                    $speObject | Add-Member -Name $Property -Value $($object.($Property)) -MemberType NoteProperty
                                }
                                catch
                                {
                                    $isSimpleObject = $false
#                                    if($global:ActivateTestLoggingException)
#                                    {
#                                        $exMessage = $_.Exception.Message
#                                        $innerException = $_.Exception.InnerException
#                                        $info = "Fehler bei nachträglichem Erfassen des Property-Object '$Property' als SimpleObject"
#                                        #Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
#                                    }
                                }
#                                if($isSimpleObject)
#                                {
#                                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...SPQ-Object '$Property' konnte als SimpleObject erfasst werden." -level Verbose -CorrelationId $fctCorrId  -eventId $eventid -process $Property}
#                                } 
#                                else
#                                {
#                                    if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...SPQ-Object '$Property' konnte nicht erfasst werden." -level High -CorrelationId $fctCorrId  -eventId $eventid -process $Property}
#                                }
                    
                            }
                        }
                        else
                        {
                            try
                            {
#                                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Schreibe NON-SPC-Property '$Property'..." -CorrelationId $fctCorrId -eventId $eventid -process $Property}
                                $speObject | Add-Member -Name $Property -Value $($object.($Property)) -MemberType NoteProperty -force
#                                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "...Schreiben von NON-SPC-Property '$Property' abgeschlossen." -CorrelationId $fctCorrId -eventId $eventid -process $Property}
                            }
                            catch
                            {
#                                if($global:ActivateTestLoggingException)
#                                {
#                                    $exMessage = $_.Exception.Message
#                                    $innerException = $_.Exception.InnerException
#                                    $info = "Fehler bei direktem Erfassen des Property-Values '$Property' als SimpleObject"
#                                    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
#                                }
                            }
                        }
                    }
                }
                #endregion
                
                return $speObject
 #           }
        }
    }
    #endregion
    #EndOfFunction
