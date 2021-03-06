#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Import-SPEDLL.ps1                                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Import-SPEDLL
    #.ExternalHelp SamsPowerShellEnhancements.psm1-help.xml
    Function Import-SPEDLL{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [System.String]
            $Path = $PathToSharePointDLLs,
            [Parameter(Position=1,Mandatory=$true)]
            [System.String]
            $File
        )
        Begin{}
        Process
        {
            $filePath = $Path.TrimEnd("\") + "\" + $File
            if(Test-Path $filePath)
            {
                try{
                   Add-Type -Path ($filePath)
                }
	            catch
	            {
                    if($global:ActivateTestLoggingException)
                    {
	                    $exMessage = $_.Exception.Message
	                    $innerException = $_.Exception.InnerException
	                    $info = "Fehler bei Import der DLL '" + $File + "' aus Ordner '" + $Path + "'"
	                    Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                    }
	            }
            } else {
                Write-SPELogMessage -level "Critical" -area "misc" -category "Adding" -message "DLL with path $filePath could not be found! Please check if folder $Path and file $File exists."
            }
        
        }
        End{}
    }
    #endregion
    #EndOfFunction
