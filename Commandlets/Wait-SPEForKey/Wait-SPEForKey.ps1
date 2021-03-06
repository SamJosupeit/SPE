#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Wait-SPEForKey.ps1                                     #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Wait-SPEForKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Wait-SPEForKey
    {
        [CmdletBinding()]
        param()
        begin{}

        process {
			Write-Host "Beliebige Taste zum Fortsetzen drücken..." -ForegroundColor Green
            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        end{}
    }
    #endregion
    #EndOfFunction		
