#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEUsedMemoryByVariable.ps1                        #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Get-SPEUsedMemoryByVariable
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPEUsedMemoryByVariable 
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [System.String]$VariableName,

            [Parameter(Position=1,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [System.String]$CommandString,

            [Parameter(Position=2,Mandatory=$false)]
            [ValidateSet("Byte","Kilobyte","Megabyte","Gigabyte")]
            [String]$Size = "Kilobyte"
        )

        begin {
        }

        process {
            $MemoryUsageBefore = [gc]::GetTotalMemory($true)
            $commandBlock = "Set-Variable -Name $VariableName -Value ($CommandString) -Scope Global"
            iex $commandBlock # invoke-Expression
            $CommandBlock = $null
            $MemoryUsageAfter = [gc]::GetTotalMemory($true)
            switch($Size)
            {
                "Byte" { $UsedMemoryByVariable = ($MemoryUsageAfter - $MemoryUsageBefore) };
                "Kilobyte" { $UsedMemoryByVariable = ($MemoryUsageAfter - $MemoryUsageBefore) / 1kb };
                "Megabyte" { $UsedMemoryByVariable = ($MemoryUsageAfter - $MemoryUsageBefore) / 1mb };
                "Gigabyte" { $UsedMemoryByVariable = ($MemoryUsageAfter - $MemoryUsageBefore) / 1gb };
                Default { $UsedMemoryByVariable = ($MemoryUsageAfter - $MemoryUsageBefore) };
            }


            return $UsedMemoryByVariable

        }
    }
    #endregion
    #EndOfFunction
