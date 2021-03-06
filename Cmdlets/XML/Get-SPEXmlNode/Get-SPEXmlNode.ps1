#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEXmlNode.ps1                                     #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPEXmlNode
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Get-SPEXmlNode
    {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.String]
		    $Variable1,

		    [Parameter(Position=1)]
		    [ValidateNotNull()]
		    [System.String]
		    $Variable2
       )

        begin 
        {
        }

        process 
        {
            try
            {
            }
            catch
            {
            }
            finally
            {
            }
        }
    }
    #endregion
    #EndOfFunction
