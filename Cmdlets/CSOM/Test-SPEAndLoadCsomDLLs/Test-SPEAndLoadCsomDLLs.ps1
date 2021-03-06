#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPEAndLoadCsomDLLs.ps1                            #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Test-SPEAndLoadCsomDLLs
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Test-SPEAndLoadCsomDLLs
    {
        [CmdletBinding()]
        param()
        Begin{}
        Process
        {
            try
            {
                #Testweise Erfassen, ob DLL Microsoft.SharePoint.Client geladen ist.
                [reflection.assembly]::GetAssembly("Microsoft.SharePoint.Client.ClientContext" -as [type]) | out-null
            }
            catch
            {
                #ist nicht geladen, also laden
                Import-SPECsomDLLs
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction
