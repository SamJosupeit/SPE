#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEOrSetLogFiles.ps1                               #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPEOrSetLogFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Get-SPEOrSetLogFiles
    {
        [CmdletBinding()]
        param
        (
       	)

        begin 
        {
			if($global:LogToLogFile -or $global:LogToULSFile)
			{
	            if(!(Test-Path $dirLog))
	            {
	                New-Item -Path $dirLog -ItemType "Directory"
	            }
	            else
	            {
	                Limit-SPEDirectorySize -dirPath $dirLog
	            }
			}
			$currentTime = Get-Date
		}
        process 
        {
			if($global:LogToULSFile)
			{
				$lastFile = gci $dirLog | sort LastWriteTime | select -last 1
				if(($lastFile -ne $null))
				{
					if($lastfile.Name.StartsWith($computerName))
					{
						if(($lastFile.Length -gt $global:maxSizeOfULSFile) -or (($currentTime - $lastFile.CreationTime) -gt $global:maxAgeOfULSFile))
						{
							New-SPELogFiles -RecreateULS
						}
						else
						{
							$global:PathULSLogFile = $lastFile.FullName
						}
					} else {
						New-SPELogFiles
					}
				} else {
					New-SPELogFiles
				}
			}
			if($global:LogToLogfile)
			{
				New-SPELogFiles
			}
        }
    }
    #endregion
    #EndOfFunction
