#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Edit-SPELogFile.ps1                                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Edit-SPELogFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Edit-SPELogFile
    {
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            notepad.exe $PathToLogfile
        }
    }
    #endregion
    #EndOfFunction
