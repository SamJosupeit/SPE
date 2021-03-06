#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPESPOnlineObjectByCtx.ps1                         #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPESPOnlineObjectByCtx
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    function Get-SPESPOnlineObjectByCtx {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [PSObject]$ParentObject,
            [Parameter(Position=1,Mandatory=$false)]
            [ValidateNotNullOrEmpty()]
            $ChildObject,
            [Parameter(Position=2,Mandatory=$false)]
            [Microsoft.SharePoint.Client.ClientContext]$Ctx=$global:ctx
        )

        begin 
        {
            Test-SPEAndLoadCsomDLLs
        }

        process 
        {
            try
            {
                $objToLoad = $ParentObject.($ChildObject)
                $ctx.Load($objToLoad)
                $ctx.ExecuteQuery()
                return $objToLoad
            }
            catch
            {
                if($global:ActivateTestLoggingException)
                {
                    $exMessage = $_.Exception.Message
                    $innerException = $_.Exception.InnerException
                    $info = "Fehler bei Erfassen des ChildObjects '$ChildObject'"
                    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                }
                return $null
            }
        }
    }
    #endregion
    #EndOfFunction
