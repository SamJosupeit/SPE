#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - 40882 Ratingen                                              #
# Powershell-Script                                                   #
# #####################################################################
# Name:     Functions_Registry.ps1                                    #
# Funktion: Dieses Script dient der globalen Bereitstellung von       #
#           Windows-Registry bezogenen Functions                      #
# ################################################################### #
# # Versionsverlauf:                                                # #
# ################################################################### #
# Ver. | Autor      | Änderungen                         | Datum      #
# ################################################################### #
# 0.1  | S.Josupeit | Erst-Erstellung                    | 02.12.2014 #
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

    #region Function Test-Key
    function Test-Key
    {        
        <#
        .SYNOPSIS
        Überprüft das Vorhandensein eines Registry-Keys unter dem angegebenen Pfad
        .DESCRIPTION
        Überprüft das Vorhandensein eines Registry-Keys unter dem angegebenen Pfad und gibt als Resultat $true oder $false aus
        .EXAMPLE
        Test-Key -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -key "Restart-And-Resume"
        .PARAMETER path
        Vollständiger Registry-Pfad zum zu prüfenden Registry-Key
        .PARAMETER key
        Bezeichner des zu prüfenden Registry-Keys
        #>
        [CmdletBinding()]
        param
        ([string] $path, [string] $key)

        begin {
        }

        process {
    
            return ((Test-Path $path) -and ((Get-Key $path $key) -ne $null))       
        }
    }
    #endregion

    #region Function Remove-Key
    function Remove-Key
    {        
        <#
        .SYNOPSIS
        Löscht einen Registry-Key mit dem angegebenen Namen unter dem angegebenen Pfad
        .DESCRIPTION
        Löscht einen Registry-Key mit dem angegebenen Namen unter dem angegebenen Pfad
        .EXAMPLE
        Remove-Key -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -key "Restart-And-Resume"
        .PARAMETER path
        Vollständiger Registry-Pfad zum zu löschenden Registry-Key
        .PARAMETER key
        Bezeichner des zu löschenden Registry-Keys
        #>
        [CmdletBinding()]
        param
        ([string] $path, [string] $key)

        begin {
        }

        process {
            Remove-ItemProperty -path $path -name $key    
        }
    }
    #endregion

    #region Function Set-Key
    function Set-Key 
    {        
        <#
        .SYNOPSIS
        Erstellt einen Registry-Key mit dem angegebenen Namen unter dem angegebenen Pfad
        .DESCRIPTION
        Erstellt einen Registry-Key mit dem angegebenen Namen unter dem angegebenen Pfad mit dem angegebenen Wert
        .EXAMPLE
        Set-Key -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -key "Restart-And-Resume" -value "c:\ps1\autostart.ps1"
        .PARAMETER path
        Vollständiger Registry-Pfad zum zu erstellenden Registry-Key
        .PARAMETER key
        Bezeichner des zu erstellenden Registry-Keys
        .PARAMETER value
        Wert des zu erstellenden Registry-Keys
        #>
        [CmdletBinding()]
        param
        ([string] $path, [string] $key, [string] $value)

        begin {
        }

        process {
            Set-ItemProperty -path $path -name $key -value $value    
        }
    }
    #endregion

    #region Function Get-Key
    function Get-Key 
    {        
        <#
        .SYNOPSIS
        Liest den Wert eines Registry-Keys mit dem angegebenen Namen unter dem angegebenen Pfad
        .DESCRIPTION
        Liest den Wert eines Registry-Keys mit dem angegebenen Namen unter dem angegebenen Pfad und gibt diesen als STRING aus
        .EXAMPLE
        Get-Key -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -key "Restart-And-Resume"
        .PARAMETER path
        Vollständiger Registry-Pfad zum auszulesenden Registry-Key
        .PARAMETER key
        Bezeichner des auszulesenden Registry-Keys
        #>
        [CmdletBinding()]
        param
        ([string] $path, [string] $key)

        begin {
        }

        process {
            return (Get-ItemProperty $path).$key    
        }
    }
    #endregion
        
    #region Function Restart-And-Run 
    function Restart-And-Run 
    {
        <#
        .SYNOPSIS
        Trägt im Autostart-Pfad das angegebene Script in die Registry ein und startet den Computer neu
        .DESCRIPTION
        Trägt im Autostart-Pfad das angegebene Script in die Registry ein und startet den Computer neu. Diese Function kann dazu genutzt werden, um ein PowerShell-Script in der Registry zu installieren, um es beim Reboot automatisch auszuführen.
        .EXAMPLE
        $global:RegRunKey ="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        $global:restartKey = "Restart-And-Resume"
        Restart-And-Run -key $global:restartKey -run [Scriptname] -reboot
    
        Trägt das Script in den Autostart der Registry ein und bootet den Computer neu.
        .EXAMPLE
        $global:RegRunKey ="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        $global:restartKey = "Restart-And-Resume"
        Restart-And-Run -key $global:restartKey -run [Scriptname]
    
        Trägt das Script in den Autostart der Registry ein, ohne den Computer neu zu booten. Kann dazu benutzt werden, um ein laufendes Script nach einem Reboot neuzustarten.
        .PARAMETER key
        Der 
        .PARAMETER logname
        The name of a file to write failed computer names to. Defaults to errors.txt.
        #>
        [CmdletBinding()]
        param
        ([string] $key, [string] $run, [switch] $reboot)

        begin {
        }

        process {
            Set-Key $global:RegRunKey $key $run
            if($reboot)
            {
                Restart-Computer
                exit
            }
        }
    }
    #endregion

    #region Function Clear-Any-Restart
    function Clear-Any-Restart 
    {
        <#
        .SYNOPSIS
        Löscht den Autostart-Eintrag aus der Registry
        .DESCRIPTION
        Löscht den Autostart-Eintrag aus der Registry
        .EXAMPLE
        Clear-Any-Restart
        .PARAMETER key
        Registry-Key "Restart-And-Resume"
        #>
        [CmdletBinding()]
        param
        ([string] $key=$global:restartKey)

        begin {
        }

        process {
            if (Test-Key $global:RegRunKey $key) {
                Remove-Key $global:RegRunKey $key
            }
        }
    }
    #endregion
        
    #region Function Restart-And-Resume    
    function Restart-And-Resume 
    {
        <#
        .SYNOPSIS
        Trägt den Autostart-Eintrag in die Registry mit Step-Vermerk ein
        .DESCRIPTION
        Trägt den Autostart-Eintrag in die Registry mit Step-Vermerk ein, um nach dem Reboot des Computers an der entsprechenden Stelle das Script fortzusetzen. Das setzt natürlich eine entsprechende Script-Struktur voraus.
        .EXAMPLE
        Restart-And-Resume -script [ScriptName] -Step "3"
        .PARAMETER script
        Name des einzutragenden Scripts
        .PARAMETER step
        Angabe des zu speichernden Programmschritts als STRING
        #>
        [CmdletBinding()]
        param
        ([string] $script, [string] $step)

        begin {
        }

        process {
            Restart-And-Run $global:restartKey "$global:powershell $script -Step $step"
        }
    }
    #endregion

#endregion