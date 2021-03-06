#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPESPOnlineSubWebs.ps1                             #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPESPOnlineSubWebs
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Get-SPESPOnlineSubWebs
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [Microsoft.SharePoint.Client.Web]$web,
            [Parameter(Position=1,Mandatory=$false)]
            [Microsoft.SharePoint.Client.ClientContext]$Ctx=$global:ctx
        )
        Begin{
            Test-SPEAndLoadCsomDLLs
        }
        Process
        {
            try
            {
                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Erfasse SubWebs von Website '$($web.title)'..."}
                $subwebs = Get-SPESPOnlineObjectByCtx -ParentObject $web -ChildObject "Webs"
                if($global:ActivateTestLoggingVerbose){Write-SPELogMessage -message "Es wurden $($subwebs.Count) SubWebs von Website '$($web.title)' erfasst."}
                return $subwebs
            }
            catch 
            {
                if($global:ActivateTestLoggingException)
                {
                    $exMessage = $_.Exception.Message
                    $innerException = $_.Exception.InnerException
                    $info = "Fehler bei Erfassen der SubWebs von Website '$($web.title)'"
                    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                }
                return $null
            }
        }
    }
    #endregion
    #EndOfFunction
