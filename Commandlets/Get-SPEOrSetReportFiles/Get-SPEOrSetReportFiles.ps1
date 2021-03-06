#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEOrSetReportFiles.ps1                            #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

  	#region Function Get-SPEOrSetReportFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Get-SPEOrSetReportFiles
    {
        [CmdletBinding()]
        param
        (
       	)

        begin 
        {
			if($global:ReportToFile -or $global:ReportToULS)
			{
				if(!(Test-Path $dirRep))
	            {
	                New-Item -Path $dirRep -ItemType "Directory"
	            }
	            else
	            {
	                Limit-SPEDirectorySize -dirPath $dirRep
	            }
			}
			$currentTime = Get-Date
		}
        process 
        {
			if($global:ReportToULS){
				$lastFile = gci $dirRep | sort LastWriteTime | select -last 1
				if(($lastFile -ne $null))
				{
					if($lastfile.Name.StartsWith($computerName))
					{
						if(($lastFile.Length -gt $global:maxSizeOfULSFile) -or (($currentTime - $lastFile.CreationTime) -gt $global:maxAgeOfULSFile))
						{
							New-SPEReportFiles -RecreateULS
						}
						else
						{
							$global:PathULSReportFile = $lastFile.FullName
						}
					} else {
						New-SPEReportFiles
					}
				} else {
					New-SPEReportFiles
				}
			}
			if($global:ReportToFile)
			{
				New-SPEReportFiles
			}
        }
    }
    #endregion
    #EndOfFunction
