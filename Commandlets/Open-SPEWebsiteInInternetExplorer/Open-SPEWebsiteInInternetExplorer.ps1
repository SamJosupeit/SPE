#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Open-SPEWebsiteInInternetExplorer.ps1                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Open-SPEWebsiteInInternetExplorer
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Open-SPEWebsiteInInternetExplorer
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)]
            [String]$Url
        )
        Begin
        {
            $ie = New-Object -ComObject InternetExplorer.Application
            $ie.Navigate2($Url)
            $ie.Visible = $true
        }
    }
    #endregion
    #EndOfFunction
