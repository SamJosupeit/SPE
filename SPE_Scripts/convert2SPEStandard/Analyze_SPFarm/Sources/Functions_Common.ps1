#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - 40882 Ratingen                                              #
# Powershell-Script                                                   #
# #####################################################################
# Name:     Functions_Common.ps1                                      #
# Funktion: Dieses Script dient der globalen Bereitstellung von       #
#           allgemeinen Functions                                     #
# ################################################################### #
# # Versionsverlauf:                                                # #
# ################################################################### #
# Ver. | Autor      | Änderungen                         | Datum      #
# ################################################################### #
# 0.1  | S.Josupeit | Erst-Erstellung                    | 08.09.2014 #
# 0.2  | S.Josupeit | Added Get-CurrentUsersNames        | 08.01.2015 #
#      |            | Addes Get-CurrentUsersShortName    |            #
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
    )

    begin {
    }

    process {
    }
}
#endregion

#region Functions

	#region Function Catch-Exception
	    function Catch-Exception
	    {
	        <#
	        .SYNOPSIS
	        Ausgabe des CATCH-Blocks in das Log
	        .DESCRIPTION
	        Diese Function erzeugt einen Block mit detaillierten Fehlermeldungen in der Ausgabe. Sie wird wie folgt in einen CATCH-Block eingefügt: 
	        .EXAMPLE
	        [CODE]
	        try
	        {
	            [CODE]
	        }
	        catch
	        {
	            $exMessage = $_.Exception.Message
	            $innerException = $_.Exception.InnerException
	            $info = "Info-Text"
	            Catch-Exception -list $list -web $web -site $site -exMessage $exMessage -innerException $innerException -info $info
	        }
	        .PARAMETER list
	        Erfasst einen SharePoint-Listennamen
	        .PARAMETER web
	        Erfasst den Namen der aktuellen Website
	        .PARAMETER site
	        Erfasst den Namen der aktuellen SiteCollection
	        .PARAMETER exMessage
	        Enthält die Exception.Message des CATCH-Blocks
	        .PARAMETER innerException
	        Enthält die Exception.InnerEception mit StackTrace des CATCH-Blocks
	        .PARAMETER info
	        Weitere Infos zur Ausgabe im Log
	        #>
	        [CmdletBinding()]
	        param
	        (
	            [string]$list,
	            [string]$web,
	            [string]$site,
	            [string]$exMessage,
	            [string]$innerException,
	            [string]$info
	            )
	        begin {}
	        process
	        {
	            $LogMessage = "Fehler bei Info   : " + $info
	            Log-Message -message $LogMessage -Level "Critical"
	            if($site){cat
	                $LogMessage = "Fehler bei SPSite : " + $site
	                Log-Message -message $LogMessage -Level "Critical"
	            }
	            Log-Message -message $LogMessage -Level "Critical"
	            if($web){
	                $LogMessage = "Fehler bei SPWeb  : " + $web
	                Log-Message -message $LogMessage -Level "Critical"
	            }
	            if($list){
	                $LogMessage = "Fehler bei SPList : " + $list
	                Log-Message -message $LogMessage -Level "Critical"
	            }
	            $LogMessage = "ExceptionMessage  : " + $exMessage
	            Log-Message -message $LogMessage -Level "Critical"
	            $innerException.split([char]10) | foreach{
	                $LogMessage = "InnerException    : " + $_.Replace([String][char]13,"")
	                Log-Message -message $LogMessage -Level "Critical"
	            }
	        }
	    }
	#endregion

    #region Function Wait-ForKey
    Function Wait-ForKey()
    {
        <#
        .SYNOPSIS
        Dient als Scriptunterbrechung
        .DESCRIPTION
        Dient als Scriptunterbrechung
        .EXAMPLE
        Wait-ForKey

        Script wird angehalten, bis eine beliebige Taste gedrückt wird.
        .NOTES
        Function kann nur direkt aufgerufen werden.
        #>
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
			Write-Host "Beliebige Taste zum Fortsetzen drücken..." -ForegroundColor Green
            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
    #endregion
		
	#region Function Pause-OnKey
	Function Pause-OnKey()
	{
        <#
        .SYNOPSIS
        Function wird in FOR- oder DO-WHILE-Schleifen benutzt, um ein Pausieren im laufenden Script zu ermöglichen
        .DESCRIPTION
        Function wird in FOR- oder DO-WHILE-Schleifen benutzt, um ein Pausieren im laufenden Script zu ermöglichen.
        Dazu wird bei der nächsten Eingabe einer Leertaste, das Script solange unterbrochen, bis eine beliebige andere Taste gedrückt wird.
        .EXAMPLE
        Pause-OnKey
        #>
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
			if ($host.ui.RawUI.KeyAvailable -and $host.UI.RawUI.ReadKey().Character -eq ' ') {
				#Read-Host -Prompt 'press enter to continue'
				Wait-ForKey
	 		}
	 		sleep -m 50 # give me chance to press the key ;)
		}
    }
	#endregion
		
	#region Function Get-BaseTypeNameFromObject
	Function Get-BaseTypeNameFromObject
	{
		<#
			
		#>
		[CmdletBinding()]
		Param(
			$object
		)
		begin{
			
		}
		process{
			return $object.GetType().BaseType.Name
		}
	}
	#endregion

	#region Function Export-Csv
	<##############################################################
	# Diese Function dient als Workaround für den Fall, dass die  #
	# Powershell älter als Version 3 ist, da dort der Parameter   #
	# "-Append" noch nicht im Cmdlet Export-Csv vorhanden war.    #
	# Daher wird diese Function auch nur dann freigeben, wenn     #
	# Powershell V2 vorhanden sind. In V3 bleibt diese Function   #
	# inaktiv.                                                    #
	##############################################################>
	    
	<#
	This Export-CSV behaves exactly like native Export-CSV
	However it has one optional switch -Append
	Which lets you append new data to existing CSV file: e.g.
	Get-Process | Select ProcessName, CPU | Export-CSV processes.csv -Append
	For details, see
	http://dmitrysotnikov.wordpress.com/2010/01/19/export-csv-append/
	(c) Dmitry Sotnikov
	#>
	    
	$psversion = $PSVersionTable["PSVersion"]
	if($psversion.Major -eq 2){
	    function Export-CSV {
	        [CmdletBinding(DefaultParameterSetName='Delimiter',
	        SupportsShouldProcess=$true, ConfirmImpact='Medium')]
	        param(
	            [Parameter(Mandatory=$true, ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)][System.Management.Automation.PSObject]${InputObject},

	            [Parameter(Mandatory=$true, Position=0)][Alias('PSPath')][System.String]${Path},
	 
	            #region -Append (added by Dmitry Sotnikov)
	            [Switch]${Append},
	            #endregion 

	            [Switch]${Force},

	            [Switch]${NoClobber},

	            [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')][System.String]${Encoding},

	            [Parameter(ParameterSetName='Delimiter', Position=1)][ValidateNotNull()][System.Char]${Delimiter},

	            [Parameter(ParameterSetName='UseCulture')][Switch]${UseCulture},

	            [Alias('NTI')][Switch]${NoTypeInformation}
	        )

	        begin
	        {
	            # This variable will tell us whether we actually need to append
	            # to existing file
	            $AppendMode = $false
	 
	            try {
	                $outBuffer = $null
	                if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
	                {
	                    $PSBoundParameters['OutBuffer'] = 1
	                }
	                $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Export-Csv',[System.Management.Automation.CommandTypes]::Cmdlet)
	        
	        
	                #String variable to become the target command line
	                $scriptCmdPipeline = ''

	                # Add new parameter handling
	                #region Dmitry: Process and remove the Append parameter if it is present
	                if ($Append) {
	  
	                    $PSBoundParameters.Remove('Append') | Out-Null
	    
	                    if ($Path) {
	                        if (Test-Path $Path) {        
	                            # Need to construct new command line
	                            $AppendMode = $true
	    
	                            if ($Encoding.Length -eq 0) {
	                                # ASCII is default encoding for Export-CSV
	                                $Encoding = 'ASCII'
	                            }
	    
	                            # For Append we use ConvertTo-CSV instead of Export
	                            $scriptCmdPipeline += 'ConvertTo-Csv -NoTypeInformation '
	    
	                            # Inherit other CSV convertion parameters
	                            if ( $UseCulture ) {
	                                $scriptCmdPipeline += ' -UseCulture '
	                            }
	                            if ( $Delimiter ) {
	                                $scriptCmdPipeline += " -Delimiter '$Delimiter' "
	                            } 
	    
	                            # Skip the first line (the one with the property names) 
	                            $scriptCmdPipeline += ' | Foreach-Object {$start=$true}'
	                            $scriptCmdPipeline += '{if ($start) {$start=$false} else {$_}} '
	    
	                            # Add file output
	                            $scriptCmdPipeline += " | Out-File -FilePath '$Path'"
	                            $scriptCmdPipeline += " -Encoding '$Encoding' -Append "
	    
	                            if ($Force) {
	                                $scriptCmdPipeline += ' -Force'
	                            }

	                            if ($NoClobber) {
	                                $scriptCmdPipeline += ' -NoClobber'
	                            }   
	                        }
	                    }
	                } 
	                #endregion
	  
	                $scriptCmd = {& $wrappedCmd @PSBoundParameters }
	 
	                if ( $AppendMode ) {
	                    # redefine command line
	                    $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
	                        $scriptCmdPipeline
	                    )
	                } else {
	                    # execute Export-CSV as we got it because
	                    # either -Append is missing or file does not exist
	                    $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
	                        [string]$scriptCmd
	                    )
	                }

	                # standard pipeline initialization
	                $steppablePipeline = $scriptCmd.GetSteppablePipeline(
	                $myInvocation.CommandOrigin)
	                $steppablePipeline.Begin($PSCmdlet)
	 
	                } 
	                catch 
	                {
	                    throw
	                }
	    
	            }

	        process
	        {
	            try 
	            {
	                $steppablePipeline.Process($_)
	            } 
	            catch 
	            {
	                throw
	            }
	        }

	        end
	        {
	            try 
	            {
	                $steppablePipeline.End()
	            } 
	            catch 
	            {
	                throw
	            }
	        }
	    }
	}

	#endregion

    #region Function Get-CurrentUsersNames
    function Get-CurrentUsersNames {
        <#
        .SYNOPSIS
            Gets the GivenName and the SurName of the current User and returns them as an Object

        .DESCRIPTION
            Gets the GivenName and the SurName of the current User and returns them as an Object without the need of having the ActiveDirectory-PowerShell-Snappin enabled to use the GET-ADUSER-Cmdlet.

        .EXAMPLE
            $user = Get-CurrentUsersNames
            $DisplayName = $user.DisplayName

        #>
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            $strName = $env:USERNAME
            $strFilter = "(&(objectCategory=User)(samAccountName=$strName))"
            $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
            $objSearcher.Filter = $strFilter
            $objPath = $objSearcher.FindOne()
            $objUser = $objPath.GetDirectoryEntry()
            $outObj = New-Object System.Object
            $outObj | Add-Member -NotePropertyName "DisplayName" -NotePropertyValue $objUser.displayName
            $outObj | Add-Member -NotePropertyName "GivenName" -NotePropertyValue $objUser.givenName
            $outObj | Add-Member -NotePropertyName "SurName" -NotePropertyValue $objUser.sn
            return $outObj
        }
    }
    #endregion
 
    #region Function Get-CurrentUsersShortName
    function Get-CurrentUsersShortName {
        <#
        .SYNOPSIS
            Gets the short name of the current User as "G. Surname" and fixes it to the desired Length

        .DESCRIPTION
            Gets the short name of the current User as "G. Surname" and fixes it to the desired Length

        .PARAMETER Length
            The returned String will be fixed to this size, wether it will be filled with spaces or truncated

        .EXAMPLE
            $usershortName = Get-CurrentUsersShortName

        #>
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][int]$Length
        )

        begin {
        }

        process {
            $curUser = Get-CurrentUsersNames
            $outStr = ""
            if($gn = $curUser.GivenName -ne ""){
                $gnInitial = $gn.SubString(0,1)
                $outStr += $gnInitial + "."
            }
            $outStr += $curUser.SurName
            if($outStr.Length -le $Length)
            {
                $outStr = $outStr.PadRight($Length)
            } elseif($outStr.Length -gt $Length)
            {
                $outStr = $outStr.SubString(0,$Length)
            }
            return $outStr
        }
    }
    #endregion

    #region Function Trap-CtrlC    
    function Trap-CtrlC {
        [console]::TreatControlCAsInput = $true
        if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
        {
            throw (new-object ExecutionEngineException "Ctrl+C Pressed")
        }
    }
    #endregion

#endregion