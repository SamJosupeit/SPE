#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Move-SPEFileSystemFolderToZIP.ps1                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Move-SPEFileSystemFolderToZIP
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Move-SPEFileSystemFolderToZIP
    {
        [CmdletBinding()]
        Param(
            [Parameter(Position=0, Mandatory=$true)]
            [String]$SourceFolder,
            [Parameter(Position=0, Mandatory=$true)]
            [String]$Target,
            [Parameter(Position=0, Mandatory=$true)]
            [Switch]$RemoveSource
        )
        Begin{}
        Process{
        # load assembly
            Add-Type -AssemblyName System.IO.Compression.FileSystem
 
            $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
 
            # compress complete folder to ZIP file
            if(Test-Path $Target)
            {
                if($global:UseInfoHeader)
                {
                    Show-SPETextLine -text "Zipfile $Target existiert bereits. Soll es Überschrieben werden?"
                    $OverwriteZIP = Select-SPEJN
                    if($OverwriteZIP){
                        Remove-Item -Path $Target -Force
                        [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceFolder, $Target, $compressionLevel, $True)
                    }
                } else {
                    Write-Host "Zipfile $Target existiert bereits. Soll es Überschrieben werden?"
                    $OverwriteZIP = Select-SPEJN
                    if($OverwriteZIP){
                        Remove-Item -Path $Target -Force
                        [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceFolder, $Target, $compressionLevel, $True)
                    }
                }
            } 
            else
            {
                [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceFolder, $Target, $compressionLevel, $True)
            }
        }
        End{
            if($RemoveSource)
            {
                if(Test-Path $Target)
                {
                    Remove-Item -Path $SourceFolder -Recurse
                }
            }
        }
    }
    #endregion
    #EndOfFunction
