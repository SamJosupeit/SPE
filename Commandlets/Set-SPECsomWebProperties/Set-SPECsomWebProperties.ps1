#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Set-SPECsomWebProperties.ps1                           #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Set-SPECsomWebProperties
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    function Set-SPECsomWebProperties
    {
        [CmdletBinding()]
        param
        (
		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNull()]
		    [Microsoft.SharePoint.Client.Web]
		    $Web,
            [Parameter(Position=0, Mandatory=$true)]
            [ValidateNotNull()]
            [System.Collections.ArrayList]
            $Properties
        )
        Begin
        {
            Test-SPEAndLoadCsomDLLs
            #Prüfe, ob alle Properties vom Type System.Web.UI.Pair sind
            foreach($Property in $Properties)
            {
                $PropertyBaseTypeName = Get-SPEBaseTypeNameFromObject $Property
                if($PropertyBaseTypeName -ne "System.Web.UI.Pair")
                {
                    Write-SPELogMessage -level High -category Aborted -area WebSite -message "Fehler in Cmdlet 'Set-SPECSOMWebProperties'. Ein Item der anzugebenen ArrayList 'Properties' ist nicht vom Type 'System.Web.UI.Pair'."
                    break
                }
            }
        }
        Process
        {
            try
            {
                $context = $Web.Context
                $newPropertiesArrayList = new-Object System.Collections.ArrayList
                foreach($Property in $Properties)
                {
                    $PropertyName = $Property.First
                    $PropertyValue = $Property.Second
                    $web.($PropertyName) = $PropertyValue
                    $newPropertiesArrayList.Add($PropertyName)
                }
                $web.Update()
                Get-SPECSOMProperties -object $web -propertyNames ($newPropertiesArrayList.ToArray())
                $context.ExecuteQuery()
                return $web
            }
            catch
            {
                if($global:ActivateTestLoggingException)
                {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Fehler in Cmdlet 'Set-SPECSOMWebProperties"
	                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                }
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction
