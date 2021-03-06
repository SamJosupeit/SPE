#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        New-SPECsomList.ps1                                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function New-SPECsomList
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function New-SPECsomList {
        [CmdletBinding()]
        param
        (
		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNull()]
		    [Microsoft.SharePoint.Client.Web]
		    $Web,
 		    [Parameter(Position=1, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.String]
		    $ListTitle,
 		    [Parameter(Position=2, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.String]
		    $ListDescription,
 		    [Parameter(Position=3, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [Int]
		    $ListTemplateId
       )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
            $ctx = $web.Context
        }

        process 
        {
            try{
            $listCreationInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
            $listCreationInfo.Title = $ListTitle
            $listCreationInfo.TemplateType = $ListTemplateId
            $list = $web.Lists.Add($listCreationInfo)
            $list.Description = $ListDescription
            $list.Update()
            $ctx.Load($list)
            $ctx.ExecuteQuery()
            return $list
            }
	        catch
	        {
                if($global:ActivateTestLoggingException)
                {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Fehler bei Erzeugen einer neuen Liste mit Titel '" + $ListTitle + "' in Website '" + $Web.Url + "'."
	                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                }
	        }
        }
    }
    #endregion
    #EndOfFunction
