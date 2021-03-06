#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Add-SPEXmlChildNode.ps1                                #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

    #region Function Add-SPEXmlChildNode
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Add-SPEXmlChildNode
    {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [System.Xml.XmlDocument]
		    $XmlDocument,
 		    [Parameter(Position=1, Mandatory=$true)]
		    #[ValidateNotNullOrEmpty()]
		    [System.Xml.XmlNode]
		    $ParentNode,
 		    [Parameter(Position=2, Mandatory=$true)]
		    [System.String]
		    $NewNodeName,
 		    [Parameter(Position=3, Mandatory=$false)]
		    [System.Collections.ArrayList]
		    $NewNodeAttributes,
 		    [Parameter(Position=4, Mandatory=$false)]
		    [System.String]
		    $NewNodeInnerText
        )

        begin 
        {
        }

        process 
        {
            $newXMLNode = $XmlDocument.CreateElement($NewNodeName)
            $ParentNode.AppendChild($newXMLNode)
            return $newXMLNode
        }
        end
        {
        }
    }
    #endregion
    #EndOfFunction
