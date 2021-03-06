#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Save-SPEXmlDocumentObjectAsUTF8.ps1                    #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Save-SPEXmlDocumentObjectAsUTF8
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Save-SPEXmlDocumentObjectAsUTF8
    {
    [CmdletBinding()]
    param
    (
 		[Parameter(Position=0, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
        [System.Xml.XmlDocument]$XmlDocumentObject,
 		[Parameter(Position=1, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
        [String]$Path
    )
    Begin{}
    Process
    {
        [System.Text.Encoding]$enc = New-Object System.Text.UTF8Encoding($true)
        $xmlWriter = New-Object System.Xml.XmlTextWriter($Path, $enc)
        $xmlWriter.Formatting = [System.Xml.Formatting]::Indented
        $XmlDocumentObject.Save($xmlWriter)
        $xmlWriter.Close()
    }
    End{}
    }
    #endregion
    #EndOfFunction
