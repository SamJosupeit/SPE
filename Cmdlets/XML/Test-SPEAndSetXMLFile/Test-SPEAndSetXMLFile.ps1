#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Test-SPEAndSetXMLFile.ps1                              #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Test-SPEAndSetXMLFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Test-SPEAndSetXMLFile
    {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.String]
		    $FilePath,
 		    [Parameter(Position=1, Mandatory=$false)]
		    [System.String]
		    $RootNodeName="Root"
        )

        begin 
        {
        }

        process 
        {
            if(([xml]$CheckDocument = Get-Content -Path $FilePath -ErrorAction SilentlyContinue) -eq $null)
            {
                #region Create XML-File
                [xml]$XMLFileDoc = New-Object System.Xml.XmlDocument
                # Creating elements and nodes
                $XMLFileRoot = $XMLFileDoc.CreateElement($RootNodeName) 
                $CatchOutput = $XMLFileDoc.AppendChild($XMLFileRoot)

                #delete existing XML-File
                If (Test-Path $FilePath){
                    $curTime = (Get-Date).ToString().Replace(" ", "_").Replace(".","_").Replace(":","_").Replace("/","_")
                    $newFilePath = $filePath.Replace(".xml", ($curTime + ".xml"))
                    Copy-Item -Path $FilePath -Destination $newFilePath
	                Remove-Item $FilePath
                }
                #Write new XMLFile
                Save-SPEXmlDocumentObjectAsUTF8 -XmlDocumentObject $XMLFileDoc -Path $FilePath
                #endregion
            }
            [xml]$getXMLDoc = Get-Content -Path $FilePath
            return $getXMLDoc
        }
    }
    #endregion
    #EndOfFunction
