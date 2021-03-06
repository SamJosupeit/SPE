#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Copy-SPEFileItem.ps1                                   #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Copy-SPEFileItem
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Copy-SPEFileItem {
	    [CmdletBinding()]
	    [OutputType([System.Int32])]
	    param(
		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.IO.FileInfo]
		    $File,

		    [Parameter(Position=1)]
		    [ValidateNotNull()]
		    [System.String]
		    $Destination
	    )
	    try {
	        #$srcFullFilePath = (Resolve-Path $file).ProviderPath
		    $srcDir = [IO.Path]::GetDirectoryName($file)
		    $srcFile = [IO.Path]::GetFileName($file)
		
		    $dstDir = (Resolve-Path $destination).ProviderPath
		
		    Start-Process -FilePath robocopy -ArgumentList "`"$srcDir`" `"$dstDir`" `"$srcFile`"" -NoNewWindow -Wait
	    }
	    catch {
		    throw
	    }
    }
    #endregion
    #EndOfFunction
