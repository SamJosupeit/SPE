#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEADUsersFromADContainer.ps1                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPEADUsersFromADContainer
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPEADUsersFromADContainer {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [ADSI]
		    $ADRoot,

            [Parameter(Position=1)]
            [System.String]
            $sAMAccountName,

		    [Parameter(Position=2)]
		    [System.String]
		    $SearchScope = "Subtree",

            [Parameter(Position=3)]
            [System.String]
            $Filter = "objectClass=user",

            [Parameter(Position=4)]
            [int]
            $PageSize = 1000,

            [Parameter(Position=5)]
            [String[]]
            $Properties
       )

        begin 
        {
        }

        process 
        {
            try
            {
                $Filter = "(&(" + $Filter + "))"
                if($sAMAccountName)
                {
                    $Filter = $Filter.Replace("))",")(sAMAccountName=" + $sAMAccountName + "))")
                }
                $objDomain = New-Object System.DirectoryServices.DirectoryEntry
                $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
                $objSearcher.SearchRoot = $ADRoot
                $objSearcher.PageSize = $PageSize
                $objSearcher.Filter = $Filter
                $objSearcher.SearchScope = $SearchScope
                if($Properties.Count -gt 0){
                    foreach($prop in $Properties)
                    {
                        $objSearcher.PropertiesToLoad.Add($prop)
                    }
                }
                $results = $objSearcher.FindAll()
                return $results
            }
            catch
            {
	            $exMessage = $_.Exception.Message
	            $innerException = $_.Exception.InnerException
	            $info = "Fehler bei Erfassen von AD-Usern in der Function 'Get-SPEADUsersFromADContainer'"
	            Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                return $null
            }
            finally
            {
            }
        }
    }
    #endregion
    #EndOfFunction
