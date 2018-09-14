#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - 40882 Ratingen                                              #
# Powershell-Script                                                   #
# #####################################################################
# Name:     Functions_LogsAndReports.ps1                              #
# Funktion: Dieses Script dient der globalen Bereitstellung von       #
#           Functions für Log- und Report-Ausgabe in Dateien          #
# ################################################################### #
# # Versionsverlauf:                                                # #
# ################################################################### #
# Ver. | Autor      | Änderungen                         | Datum      #
# ################################################################### #
# 0.1  | S.Josupeit | Erst-Erstellung                    | 02.12.2014 #
# 0.2  | S.Josupeit | Mehrere GUID-Functions hinzugefügt | 09.01.2015 #
######################################################################>
#endregion

#region Vorlage
function Do-Something {
    <#
    .SYNOPSIS
        A brief description of the function or script. This keyword can be used
        only once in each topic.

    .DESCRIPTION
        A detailed description of the function or script. This keyword can be
        used only once in each topic.

    .PARAMETER  <Parameter-Name>
        The description of a parameter. Add a .PARAMETER keyword for
        each parameter in the function or script syntax.

        Type the parameter name on the same line as the .PARAMETER keyword. 
        Type the parameter description on the lines following the .PARAMETER
        keyword. Windows PowerShell interprets all text between the .PARAMETER
        line and the next keyword or the end of the comment block as part of
        the parameter description. The description can include paragraph breaks.

        The Parameter keywords can appear in any order in the comment block, but
        the function or script syntax determines the order in which the parameters
        (and their descriptions) appear in help topic. To change the order,
        change the syntax.
 
        You can also specify a parameter description by placing a comment in the
        function or script syntax immediately before the parameter variable name.
        If you use both a syntax comment and a Parameter keyword, the description
        associated with the Parameter keyword is used, and the syntax comment is
        ignored.


    .EXAMPLE
        A sample command that uses the function or script, optionally followed
        by sample output and a description. Repeat this keyword for each example.

    .INPUTS
        The Microsoft .NET Framework types of objects that can be piped to the
        function or script. You can also include a description of the input 
        objects.

    .OUTPUTS
        The .NET Framework type of the objects that the cmdlet returns. You can
        also include a description of the returned objects.

    .NOTES
        Additional information about the function or script.

    .LINK
        The name of a related topic. The value appears on the line below
        the .LINE keyword and must be preceded by a comment symbol (#) or
        included in the comment block. 

        Repeat the .LINK keyword for each related topic.

        This content appears in the Related Links section of the help topic.

        The Link keyword content can also include a Uniform Resource Identifier
        (URI) to an online version of the same help topic. The online version 
        opens when you use the Online parameter of Get-Help. The URI must begin
        with "http" or "https".

    .COMPONENT
        The technology or feature that the function or script uses, or to which
        it is related. This content appears when the Get-Help command includes
        the Component parameter of Get-Help.

    .ROLE
        The user role for the help topic. This content appears when the Get-Help
        command includes the Role parameter of Get-Help.

    .FUNCTIONALITY
        The intended use of the function. This content appears when the Get-Help
        command includes the Functionality parameter of Get-Help.

    .FORWARDHELPTARGETNAME <Command-Name>
        Redirects to the help topic for the specified command. You can redirect
        users to any help topic, including help topics for a function, script,
        cmdlet, or provider. 

    .FORWARDHELPCATEGORY  <Category>
        Specifies the help category of the item in ForwardHelpTargetName.
        Valid values are Alias, Cmdlet, HelpFile, Function, Provider, General,
        FAQ, Glossary, ScriptCommand, ExternalScript, Filter, or All. Use this
        keyword to avoid conflicts when there are commands with the same name.

    .REMOTEHELPRUNSPACE <PSSession-variable>
        Specifies a session that contains the help topic. Enter a variable that
        contains a PSSession. This keyword is used by the Export-PSSession
        cmdlet to find the help topics for the exported commands.

    .EXTERNALHELP  <XML Help File>
        Specifies an XML-based help file for the script or function.  

        The ExternalHelp keyword is required when a function or script
        is documented in XML files. Without this keyword, Get-Help cannot
        find the XML-based help file for the function or script.

        The ExternalHelp keyword takes precedence over other comment-based 
        help keywords. If ExternalHelp is present, Get-Help does not display
        comment-based help, even if it cannot find a help topic that matches 
        the value of the ExternalHelp keyword.

        If the function is exported by a module, set the value of the 
        ExternalHelp keyword to a file name without a path. Get-Help looks for 
        the specified file name in a language-specific subdirectory of the module 
        directory. There are no requirements for the name of the XML-based help 
        file for a function, but a best practice is to use the following format:
        <ScriptModule.psm1>-help.xml

        If the function is not included in a module, include a path to the 
        XML-based help file. If the value includes a path and the path contains 
        UI-culture-specific subdirectories, Get-Help searches the subdirectories 
        recursively for an XML file with the name of the script or function in 
        accordance with the language fallback standards established for Windows, 
        just as it does in a module directory.

        For more information about the cmdlet help XML-based help file format,
        see "How to Create Cmdlet Help" in the MSDN (Microsoft Developer Network) 
        library at http://go.microsoft.com/fwlink/?LinkID=123415.

    #>
    [CmdletBinding()]
    param
    (
 		[Parameter(Position=0, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Variable1,

		[Parameter(Position=1)]
		[ValidateNotNull()]
		[System.String]
		$Variable2
   )

    begin 
    {
    }

    process 
    {
        try
        {
        }
        catch
        {
        }
        finally
        {
        }
    }
}
#endregion

#region Functions

    #region Function Edit-LogFile
    function Edit-LogFile
    {
        <#
        .SYNOPSIS
        Ruft den Notepad-Editor mit dem Script-eigenen Logfile auf
        .DESCRIPTION
        Ruft den Notepad-Editor mit dem Script-eigenen Logfile auf
        .EXAMPLE
        Edit-LogFile
        #>
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            notepad.exe $PathToLogfile
        }
    }
	#endregion

    #region Function Get-CurrentTimeForULS
 	function Get-CurrentTimeForULS 
    {
        <#
        .SYNOPSIS
        Erzeugt einen String vom aktuellen TimeStamp zur Nutzung im ULS-Log
        .DESCRIPTION
        Erzeugt einen String vom aktuellen TimeStamp zur Nutzung im ULS-Log
        .EXAMPLE
        $dtString = GetCurrentTimeForULS

        Dieser Code wird von der Function Log-Uls benutzt, um den TimeStamp für eine Meldung im ULS-Log ULS-konform darzustellen, so dass diese für den ULS-Viewer lesbar ist.
        #>
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
		    $dt = "{0:MM'/'dd'/'yyyy' 'HH':'mm':'ss'.'ff}" -f (Get-Date) # Amerikanisches Format
		    return $dt #Ausgabe des Strings
	    }
    }
    #endregion
       
    #region Function Increment-Guid
    Function Increment-Guid
    {
        <#
        .SYNOPSIS
        Diese Function erhöht die angegebene Guid um den Wert 1.
        .DESCRIPTION
        Diese Function erhöht die angegebene Guid um den Wert 1. Ist keine Guid angegeben oder hat diese $NULL, wird eine neue Guid mit Nullen erzeugt und widergegeben.
        .EXAMPLE
        $global:CorrelationId = Increment-Guid $global:CorrelationId
        .PARAMETER guid
        Die zu inkremetierende GUID
        .NOTES
        Dies dient als Erweiterung zum ULS-Logging, um zusammenhängende Vorgänge auch im ULS-Log filterbar zu machen.
        Da eine CorrelationID eine GUID ist, kann diese nicht einfach mit einem +1 inkrementiert werden, was dann durch diese Function erfolgt.
        #>
        [CmdletBinding()]
        param
        (
            [Guid]$guid
        )

        begin {
        }

        process {
            if($guid){
                $guidString = $guid.Guid
                $guidArray = $guidString.Split('-')
                $guid1 = $guidArray[0]
                $guid2 = $guidArray[1]
                $guid3 = $guidArray[2]
                $guid4 = $guidArray[3]
                $guid5 = $guidArray[4]
                $guid5Int = [Convert]::ToInt64($guid5, 16)
                $guid5Int++
                $guid5 = $guid5Int.ToString("X" + 12)
                if($guid5.Length -gt 12){
                    $guid5 = $guid5.TrimStart("1")
                    $guid4Int = [Convert]::ToInt64($guid4, 16)
                    $guid4Int++
                    $guid4 = $guid4Int.ToString("X" + 4)
                    if($guid4.Length -gt 4){
                        $guid4 = $guid4.TrimStart("1")
                        $guid3Int = [Convert]::ToInt64($guid3, 16)
                        $guid3Int++
                        $guid3 = $guid3Int.ToString("X" + 4)
                        if($guid3.Length -gt 4){
                            $guid3 = $guid3.TrimStart("1")
                            $guid2Int = [Convert]::ToInt64($guid2, 16)
                            $guid2Int++
                            $guid2 = $guid2Int.ToString("X" + 4)
                            if($guid2.Length -gt 4){
                                $guid2 = $guid2.TrimStart("1")
                                $guid1Int = [Convert]::ToInt64($guid1, 16)
                                $guid1Int++
                                $guid1 = $guid1Int.ToString("X" + 8)
                                if($guid1.Length -gt 8){
                                    $guid1 = $guid1.TrimStart("1")
                                }
                            }
                        }
                    }
                }
                return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
            } else {
                return [Guid]"00000000-0000-0000-0000-000000000000"
            }
        }
    }
    #endregion

    #region Function Alter-Guid
    Function Alter-Guid
    {
        <#
        .SYNOPSIS
        Diese Function erhöht die angegebene Guid um den Wert 1.
        .DESCRIPTION
        Diese Function erhöht die angegebene Guid um den Wert 1. Ist keine Guid angegeben oder hat diese $NULL, wird eine neue Guid mit Nullen erzeugt und widergegeben.
        .EXAMPLE
        $global:CorrelationId = Increment-Guid $global:CorrelationId
        .PARAMETER guid
        Die zu inkremetierende GUID
        .NOTES
        Dies dient als Erweiterung zum ULS-Logging, um zusammenhängende Vorgänge auch im ULS-Log filterbar zu machen.
        Da eine CorrelationID eine GUID ist, kann diese nicht einfach mit einem +1 inkrementiert werden, was dann durch diese Function erfolgt.
        #>
        [CmdletBinding()]
        param
        (
            [Guid]$guid,
            [Int64]$hex=1
        )

        begin {
        }

        process {
            if($guid){
                $guidString = $guid.Guid
                $guidArray = $guidString.Split('-')
                $guid1 = $guidArray[0]
                $guid2 = $guidArray[1]
                $guid3 = $guidArray[2]
                $guid4 = $guidArray[3]
                $guid5 = $guidArray[4]
                $guid5Int = [Convert]::ToInt64($guid5, 16)
                $guid5Int = $guid5Int + $hex
                $guid5 = $guid5Int.ToString("X" + 12)
                if($guid5.Length -gt 12){
                    $guid5 = $guid5.TrimStart("1")
                    $guid4Int = [Convert]::ToInt64($guid4, 16)
                    $guid4Int++
                    $guid4 = $guid4Int.ToString("X" + 4)
                    if($guid4.Length -gt 4){
                        $guid4 = $guid4.TrimStart("1")
                        $guid3Int = [Convert]::ToInt64($guid3, 16)
                        $guid3Int++
                        $guid3 = $guid3Int.ToString("X" + 4)
                        if($guid3.Length -gt 4){
                            $guid3 = $guid3.TrimStart("1")
                            $guid2Int = [Convert]::ToInt64($guid2, 16)
                            $guid2Int++
                            $guid2 = $guid2Int.ToString("X" + 4)
                            if($guid2.Length -gt 4){
                                $guid2 = $guid2.TrimStart("1")
                                $guid1Int = [Convert]::ToInt64($guid1, 16)
                                $guid1Int++
                                $guid1 = $guid1Int.ToString("X" + 8)
                                if($guid1.Length -gt 8){
                                    $guid1 = $guid1.TrimStart("1")
                                }
                            }
                        }
                    }
                }
                return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
            } else {
                return [Guid]"00000000-0000-0000-0000-000000000000"
            }
        }
    }
    #endregion

    #region Function Increment-Guid1stBlock
    Function Increment-Guid1stBlock
    {
        <#
        .SYNOPSIS
        Diese Function erhöht die angegebene Guid um den Wert 1.
        .DESCRIPTION
        Diese Function erhöht die angegebene Guid um den Wert 1. Ist keine Guid angegeben oder hat diese $NULL, wird eine neue Guid mit Nullen erzeugt und widergegeben.
        .EXAMPLE
        $global:CorrelationId = Increment-Guid $global:CorrelationId
        .PARAMETER guid
        Die zu inkremetierende GUID
        .NOTES
        Dies dient als Erweiterung zum ULS-Logging, um zusammenhängende Vorgänge auch im ULS-Log filterbar zu machen.
        Da eine CorrelationID eine GUID ist, kann diese nicht einfach mit einem +1 inkrementiert werden, was dann durch diese Function erfolgt.
        #>
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
            if($guid){
                $guidString = $guid.Guid
                $guidArray = $guidString.Split('-')
                $guid1 = $guidArray[0]
                $guid2 = $guidArray[1]
                $guid3 = $guidArray[2]
                $guid4 = $guidArray[3]
                $guid5 = $guidArray[4]
#                $guid5Int = [Convert]::ToInt64($guid5, 16)
#                $guid5Int++
#                $guid5 = $guid5Int.ToString("X" + 12)
#                if($guid5.Length -gt 12){
#                    $guid5 = $guid5.TrimStart("1")
#                    $guid4Int = [Convert]::ToInt64($guid4, 16)
#                    $guid4Int++
#                    $guid4 = $guid4Int.ToString("X" + 4)
#                    if($guid4.Length -gt 4){
#                        $guid4 = $guid4.TrimStart("1")
#                        $guid3Int = [Convert]::ToInt64($guid3, 16)
#                        $guid3Int++
#                        $guid3 = $guid3Int.ToString("X" + 4)
#                        if($guid3.Length -gt 4){
#                            $guid3 = $guid3.TrimStart("1")
#                            $guid2Int = [Convert]::ToInt64($guid2, 16)
#                            $guid2Int++
#                            $guid2 = $guid2Int.ToString("X" + 4)
#                            if($guid2.Length -gt 4){
#                                $guid2 = $guid2.TrimStart("1")
                                $guid1Int = [Convert]::ToInt64($guid1, 16)
                                $guid1Int++
                                $guid1 = $guid1Int.ToString("X" + 8)
                                if($guid1.Length -gt 8){
                                    $guid1 = $guid1.TrimStart("1")
                                }
#                            }
#                        }
#                    }
#                }
                return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
            } else {
                return [Guid]"00000000-0000-0000-0000-000000000000"
            }
        }
    }
    #endregion

    #region Function Increment-Guid2ndBlock
    Function Increment-Guid2ndBlock
    {
        <#
        .SYNOPSIS
        Diese Function erhöht die angegebene Guid um den Wert 1.
        .DESCRIPTION
        Diese Function erhöht die angegebene Guid um den Wert 1. Ist keine Guid angegeben oder hat diese $NULL, wird eine neue Guid mit Nullen erzeugt und widergegeben.
        .EXAMPLE
        $global:CorrelationId = Increment-Guid $global:CorrelationId
        .PARAMETER guid
        Die zu inkremetierende GUID
        .NOTES
        Dies dient als Erweiterung zum ULS-Logging, um zusammenhängende Vorgänge auch im ULS-Log filterbar zu machen.
        Da eine CorrelationID eine GUID ist, kann diese nicht einfach mit einem +1 inkrementiert werden, was dann durch diese Function erfolgt.
        #>
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
#            if($guid){
                $guidString = $guid.Guid
                $guidArray = $guidString.Split('-')
                $guid1 = $guidArray[0]
                $guid2 = $guidArray[1]
                $guid3 = $guidArray[2]
                $guid4 = $guidArray[3]
                $guid5 = $guidArray[4]
#                $guid5Int = [Convert]::ToInt64($guid5, 16)
#                $guid5Int++
#                $guid5 = $guid5Int.ToString("X" + 12)
#                if($guid5.Length -gt 12){
#                    $guid5 = $guid5.TrimStart("1")
#                    $guid4Int = [Convert]::ToInt64($guid4, 16)
#                    $guid4Int++
#                    $guid4 = $guid4Int.ToString("X" + 4)
#                    if($guid4.Length -gt 4){
#                        $guid4 = $guid4.TrimStart("1")
#                        $guid3Int = [Convert]::ToInt64($guid3, 16)
#                        $guid3Int++
#                        $guid3 = $guid3Int.ToString("X" + 4)
#                        if($guid3.Length -gt 4){
#                            $guid3 = $guid3.TrimStart("1")
                            $guid2Int = [Convert]::ToInt64($guid2, 16)
                            $guid2Int++
                            $guid2 = $guid2Int.ToString("X" + 4)
                            if($guid2.Length -gt 4){
                                $guid2 = $guid2.TrimStart("1")
                                $guid1Int = [Convert]::ToInt64($guid1, 16)
                                $guid1Int++
                                $guid1 = $guid1Int.ToString("X" + 8)
                                if($guid1.Length -gt 8){
                                    $guid1 = $guid1.TrimStart("1")
                                }
                            }
 #                       }
 #                   }
 #               }
                return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
 #           }
        }
    }
    #endregion

    #region Function Increment-Guid3rdBlock
    Function Increment-Guid3rdBlock
    {
        <#
        .SYNOPSIS
        Diese Function erhöht die angegebene Guid um den Wert 1.
        .DESCRIPTION
        Diese Function erhöht die angegebene Guid um den Wert 1. Ist keine Guid angegeben oder hat diese $NULL, wird eine neue Guid mit Nullen erzeugt und widergegeben.
        .EXAMPLE
        $global:CorrelationId = Increment-Guid $global:CorrelationId
        .PARAMETER guid
        Die zu inkremetierende GUID
        .NOTES
        Dies dient als Erweiterung zum ULS-Logging, um zusammenhängende Vorgänge auch im ULS-Log filterbar zu machen.
        Da eine CorrelationID eine GUID ist, kann diese nicht einfach mit einem +1 inkrementiert werden, was dann durch diese Function erfolgt.
        #>
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
#            if($guid){
                $guidString = $guid.Guid
                $guidArray = $guidString.Split('-')
                $guid1 = $guidArray[0]
                $guid2 = $guidArray[1]
                $guid3 = $guidArray[2]
                $guid4 = $guidArray[3]
                $guid5 = $guidArray[4]
#                $guid5Int = [Convert]::ToInt64($guid5, 16)
#                $guid5Int++
#                $guid5 = $guid5Int.ToString("X" + 12)
#                if($guid5.Length -gt 12){
#                    $guid5 = $guid5.TrimStart("1")
#                    $guid4Int = [Convert]::ToInt64($guid4, 16)
#                    $guid4Int++
#                    $guid4 = $guid4Int.ToString("X" + 4)
#                    if($guid4.Length -gt 4){
#                        $guid4 = $guid4.TrimStart("1")
                        $guid3Int = [Convert]::ToInt64($guid3, 16)
                        $guid3Int++
                        $guid3 = $guid3Int.ToString("X" + 4)
                        if($guid3.Length -gt 4){
                            $guid3 = $guid3.TrimStart("1")
                            $guid2Int = [Convert]::ToInt64($guid2, 16)
                            $guid2Int++
                            $guid2 = $guid2Int.ToString("X" + 4)
                            if($guid2.Length -gt 4){
                                $guid2 = $guid2.TrimStart("1")
                                $guid1Int = [Convert]::ToInt64($guid1, 16)
                                $guid1Int++
                                $guid1 = $guid1Int.ToString("X" + 8)
                                if($guid1.Length -gt 8){
                                    $guid1 = $guid1.TrimStart("1")
                                }
                            }
                        }
 #                   }
 #               }
                return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
#            }
        }
    }
    #endregion

    #region Function Increment-Guid4thBlock
    Function Increment-Guid4thBlock
    {
        <#
        .SYNOPSIS
        Diese Function erhöht die angegebene Guid um den Wert 1.
        .DESCRIPTION
        Diese Function erhöht die angegebene Guid um den Wert 1. Ist keine Guid angegeben oder hat diese $NULL, wird eine neue Guid mit Nullen erzeugt und widergegeben.
        .EXAMPLE
        $global:CorrelationId = Increment-Guid $global:CorrelationId
        .PARAMETER guid
        Die zu inkremetierende GUID
        .NOTES
        Dies dient als Erweiterung zum ULS-Logging, um zusammenhängende Vorgänge auch im ULS-Log filterbar zu machen.
        Da eine CorrelationID eine GUID ist, kann diese nicht einfach mit einem +1 inkrementiert werden, was dann durch diese Function erfolgt.
        #>
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
#            if($guid){
                $guidString = $guid.Guid
                $guidArray = $guidString.Split('-')
                $guid1 = $guidArray[0]
                $guid2 = $guidArray[1]
                $guid3 = $guidArray[2]
                $guid4 = $guidArray[3]
                $guid5 = $guidArray[4]
#                $guid5Int = [Convert]::ToInt64($guid5, 16)
#                $guid5Int++
#                $guid5 = $guid5Int.ToString("X" + 12)
#                if($guid5.Length -gt 12){
#                    $guid5 = $guid5.TrimStart("1")
                    $guid4Int = [Convert]::ToInt64($guid4, 16)
                    $guid4Int++
                    $guid4 = $guid4Int.ToString("X" + 4)
                    if($guid4.Length -gt 4){
                        $guid4 = $guid4.TrimStart("1")
                        $guid3Int = [Convert]::ToInt64($guid3, 16)
                        $guid3Int++
                        $guid3 = $guid3Int.ToString("X" + 4)
                        if($guid3.Length -gt 4){
                            $guid3 = $guid3.TrimStart("1")
                            $guid2Int = [Convert]::ToInt64($guid2, 16)
                            $guid2Int++
                            $guid2 = $guid2Int.ToString("X" + 4)
                            if($guid2.Length -gt 4){
                                $guid2 = $guid2.TrimStart("1")
                                $guid1Int = [Convert]::ToInt64($guid1, 16)
                                $guid1Int++
                                $guid1 = $guid1Int.ToString("X" + 8)
                                if($guid1.Length -gt 8){
                                    $guid1 = $guid1.TrimStart("1")
                                }
                            }
                        }
                    }
 #               }
                return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
#            }
        }
    }
    #endregion

    #region Function Increment-Guid5thBlock
    Function Increment-Guid5thBlock
    {
        <#
        .SYNOPSIS
        Diese Function erhöht die angegebene Guid um den Wert 1.
        .DESCRIPTION
        Diese Function erhöht die angegebene Guid um den Wert 1. Ist keine Guid angegeben oder hat diese $NULL, wird eine neue Guid mit Nullen erzeugt und widergegeben.
        .EXAMPLE
        $global:CorrelationId = Increment-Guid $global:CorrelationId
        .PARAMETER guid
        Die zu inkremetierende GUID
        .NOTES
        Dies dient als Erweiterung zum ULS-Logging, um zusammenhängende Vorgänge auch im ULS-Log filterbar zu machen.
        Da eine CorrelationID eine GUID ist, kann diese nicht einfach mit einem +1 inkrementiert werden, was dann durch diese Function erfolgt.
        #>
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
            if($guid){
                $guidString = $guid.Guid
                $guidArray = $guidString.Split('-')
                $guid1 = $guidArray[0]
                $guid2 = $guidArray[1]
                $guid3 = $guidArray[2]
                $guid4 = $guidArray[3]
                $guid5 = $guidArray[4]
                $guid5Int = [Convert]::ToInt64($guid5, 16)
                $guid5Int++
                $guid5 = $guid5Int.ToString("X" + 12)
                if($guid5.Length -gt 12){
                    $guid5 = $guid5.TrimStart("1")
                    $guid4Int = [Convert]::ToInt64($guid4, 16)
                    $guid4Int++
                    $guid4 = $guid4Int.ToString("X" + 4)
                    if($guid4.Length -gt 4){
                        $guid4 = $guid4.TrimStart("1")
                        $guid3Int = [Convert]::ToInt64($guid3, 16)
                        $guid3Int++
                        $guid3 = $guid3Int.ToString("X" + 4)
                        if($guid3.Length -gt 4){
                            $guid3 = $guid3.TrimStart("1")
                            $guid2Int = [Convert]::ToInt64($guid2, 16)
                            $guid2Int++
                            $guid2 = $guid2Int.ToString("X" + 4)
                            if($guid2.Length -gt 4){
                                $guid2 = $guid2.TrimStart("1")
                                $guid1Int = [Convert]::ToInt64($guid1, 16)
                                $guid1Int++
                                $guid1 = $guid1Int.ToString("X" + 8)
                                if($guid1.Length -gt 8){
                                    $guid1 = $guid1.TrimStart("1")
                                }
                            }
                        }
                    }
                }
                return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
            } else {
                return [Guid]"00000000-0000-0000-0000-000000000000"
            }
        }
    }
    #endregion

    #region Function Log-Message
    Function Log-Message
    {
        <#

        #>
        [CmdletBinding()]
        param
        (
            [ValidateSet("Critical","High","Medium","Verbose","VerboseEx")][String]$level = "VerboseEx",
            [ValidateSet("ListView","ViewField","ListField","Script","misc")][String]$area = "misc",
            [ValidateSet("Added","Removed","Started","Stopped","Aborted","Adding","Removing","Determining")][String]$category,
            [Guid]$CorrelationId = $global:CorrelationID,
            [String]$eventId = "0000",
            [String]$process = "powershell.exe (0x0E44)",
            [String]$thread = "0x05BC",
            [String]$message
        )

        begin {
            $strCorrelationId = $CorrelationId.Guid
            $CurrentTimeStamp = Get-CurrentTimeForULS
			Ensure-LogFiles
        }

        process {
            if($global:LogToConsole){
                if($global:UseInfoHeader)
                {
                    if($level -match "Critical" -or $level -match "High"){
                        Display-TextLine -text $Content -fgColor $global:DisplayForeGroundColor_Error -bgColor $global:DisplayBackGroundColor_Error
                    } else {
                        Display-TextLine -text $Content
                    }
                    Wait-ForKey

                } else {
			        Write-Host $CurrentTimeStamp -NoNewline #Ausgabe des Log-Eintrags auf Console
				    if($level -match "Critical" -or $level -match "High"){
                        Write-Host "$content" -ForegroundColor $global:DisplayForeGroundColor_Error -BackgroundColor $global:DisplayBackGroundColor_Error
                    } else {
                        Write-Host "$content" -ForegroundColor $global:DisplayForeGroundColor_Normal -BackgroundColor $global:DisplayBackGroundColor_Normal
                    }
                }
             }
            if($global:LogToLogFile){
                $NewLine = $CurrentTimeStamp + " " + $Content
                $NewLine >> $PathLogfile
            }
            if($global:LogToULSFile){
                $NewLine = "$CurrentTimeStamp	$process	$thread	$area	$category	$eventId	$level	$message	$strCorrelationId"
			    $NewLine >> $PathULSLogfile #Ausgabe des Log-Eintrags in ULSfile
            }
        }
    }
    #endregion

    #region Function Report-Message
    Function Report-Message
    {
        <#
    
        #>
        [CmdletBinding()]
        Param(
            [ValidateSet("Critical","High","Medium","Verbose","VerboseEx")][String[]]$level = "VerboseEx",
            [ValidateSet("ListView","ViewField","ListField","Script","misc","ContentType")][String]$area = "misc",
            [ValidateSet("Added","Removed","Started","Stopped","Aborted","Adding","Removing","Determining")][String]$category,
            [Guid]$CorrelationId = $global:CorrelationID,
            [String]$eventId = "0000",
            [String]$process = "powershell.exe (0x0E44)",
            [String]$thread = "0x05BC",
            [String]$message
        )
        Begin{
		    $dtString = Get-CurrentTimeForULS #Abfrage der aktuellen Zeit
            $strCorrelationId = $CorrelationId.Guid
			Ensure-ReportFiles
        }
        Process{
            if($global:ReportToULS){
                $NewLine = "$dtString	$process	$thread	$area	$category	$eventId	$level	$message	$strCorrelationId"
			    $NewLine >> $PathULSReportfile #Ausgabe des Log-Eintrags in Logfile
            }
            if($global:ReportToFile){
		        $NewLine = $dtString + " " + $Content #Erzeugen des Log-Eintrags
			    $NewLine >> $PathReportfile #Ausgabe des Log-Eintrags in Logfile
            }
        }
        End{}    
    }
    #endregion

    #region Function Create-LogFiles
    Function Create-LogFiles
    {
        <#

        #>
        [CmdletBinding()]
        Param(
			[Switch]$RecreateULS
        )
        Begin{
            $StringDateTime = Get-Date -Format yyyyMMdd-HHmm
        }
        Process{
            if($global:LogToLogFile -and !$RecreateULS -and !$LogFileCreated){
                $global:PathLogFile = $dirLog + "Log_" + $ScriptName + "_" + $StringDateTime + ".log" # Pfad zur Log-Text-Datei
                #region Header für Logfile
                    $LoglineBreaker = "###############################################"
                    $LoglineFile = "# Logfile - " + $ScriptName + ".ps1"
                    $LoglineDate = "# erstellt: " + $StringDateTime
                #endregion

                #region Header in Logfile schreiben
                    $LoglineBreaker > $PathLogfile
                    $LoglineFile >> $PathLogfile
                    $LoglineDate >> $PathLogfile
                    $LoglineBreaker >> $PathLogfile
                #endregion
				$global:LogFileCreated = $true
           }
            if($global:LogToULSFile){
                $global:PathULSLogFile = $dirLog + $computerName + "-" + $StringDateTime + ".log" # Pfad zur ULS-Log-Datei
                if(!(Test-Path -Path $global:PathULSLogFile)){
                    $ULSHeader > $PathULSLogfile
                }
             }
        }
    }
    #endregion

    #region Function Create-ReportFiles
    Function Create-ReportFiles
    {
        <#

        #>
        [CmdletBinding()]
        Param(
			[Switch]$RecreateULS
        )
        Begin{
            $StringDateTime = Get-Date -Format yyyyMMdd-HHmm
        }
        Process{
            if($global:ReportToFile -and !$RecreateULS -and !$ReportFileCreated){
                $global:PathReportFile = $dirRep + "Report_" + $ScriptName + "_" + $StringDateTime + ".report" # Pfad zur Report-Text-Datei
                #region Header für Logfile
                    $ReportlineBreaker = "###############################################"
                    $ReportlineFile = "# Report für Script " + $ScriptName + ".ps1"
                    $ReportlineDate = "# erstellt am: " + $StringDateTime
                #endregion

                #region Header in Reportfile schreiben
                    $ReportlineBreaker > $PathReportfile
                    $ReportlineFile >> $PathReportfile
                    $ReportlineDate >> $PathReportfile
                    $ReportlineBreaker >> $PathReportfile
		        #endregion
				$global:ReportFileCreated = $true
             }
            if($global:ReportToULS){
	            $global:PathULSReportFile = $dirRep + $computerName + "-" + $StringDateTime + ".log" # Pfad zur ULS-Datei
	            if(!(Test-Path -Path $global:PathULSReportfile)){
	                $ULSHeader > $PathULSReportfile
	            }
            }
        }
    }
    #endregion

	#region Function Ensure-ReportFiles
    Function Ensure-ReportFiles
    {
        <#
         #>
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
	                Limit-DirectorySize -dirPath $dirRep
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
							Create-ReportFiles -RecreateULS
						}
						else
						{
							$global:PathULSReportFile = $lastFile.FullName
						}
					} else {
						Create-ReportFiles
					}
				} else {
					Create-ReportFiles
				}
			}
			if($global:ReportToFile)
			{
				Create-ReportFiles
			}
        }
    }
    #endregion

    #region Function Ensure-LogFiles
    Function Ensure-LogFiles
    {
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
	                Limit-DirectorySize -dirPath $dirLog
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
							Create-LogFiles -RecreateULS
						}
						else
						{
							$global:PathULSLogFile = $lastFile.FullName
						}
					} else {
						Create-LogFiles
					}
				} else {
					Create-LogFiles
				}
			}
			if($global:LogToLogfile)
			{
				Create-LogFiles
			}
        }
    }
    #endregion

	#region Function Limit-DirectorySize
	Function Limit-DirectorySize
	{
		<#
		
		#>
		[CmdletBinding()]
		Param(
			[String]$dirPath
		)
		Begin{}
		Process{
			[System.IO.DirectoryInfo]$dir = Get-Item $dirPath
			$dirSize = 0
			$dir.GetFiles() | %{$dirSize += $_.Length}
			if($dirSize -gt $global:maxSizeOfULSDirectory)
			{
				$oldestFile = gci $dirPath | Sort LastWriteTime | select -First 1
				Remove-Item -Path $($oldestFile.FullName) -Force
			}
		}
		End{}
	}
	#endregion
	
#endregion