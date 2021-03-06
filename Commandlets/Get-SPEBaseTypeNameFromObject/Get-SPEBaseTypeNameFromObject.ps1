#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEBaseTypeNameFromObject.ps1                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

	#region Function Get-SPEBaseTypeNameFromObject
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Get-SPEBaseTypeNameFromObject
	{
		[CmdletBinding()]
		Param(
			$object
		)
		begin{
			
		}
		process
        {
            if($object){
                if(($object.GetType().Name -match "Object") -or ($object.GetType().Name.Contains("[]")))
                {
    			    return $object.GetType().BaseType.Name
                } else {
                    return $object.GetType().Name
                }
            }
		}
	}
    #endregion
    #EndOfFunction
