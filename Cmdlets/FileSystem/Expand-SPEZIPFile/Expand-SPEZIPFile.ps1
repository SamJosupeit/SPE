#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Expand-SPEZIPFile.ps1                                  #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Expand-SPEZIPFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Expand-SPEZIPFile
    {
        [CmdletBinding()]
        param
        (
 		        [Parameter(Position=0, Mandatory=$true)]
		        #[ValidateNotNullOrEmpty()]
		        [System.String]
		        $PathToZIP,
 		        [Parameter(Position=1, Mandatory=$true)]
		        [ValidateNotNullOrEmpty()]
		        [System.String]
		        $DestinationPath
        )
        begin{}
        process
        {
            $shell = new-object -com shell.application
            $zip = $shell.NameSpace($PathToZIP)
            foreach($item in $zip.items())
            {
                $shell.Namespace($DestinationPath).copyhere($item)
            }
        }
    }
    #endregion
    #EndOfFunction
