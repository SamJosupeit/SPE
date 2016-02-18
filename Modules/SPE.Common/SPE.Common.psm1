#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-Module                                            #
# #####################################################################
# Name:        SPE.Common.psm1                                        #
# Description: This PowerShell-Module contains functions to be used   #
#              by scripts generated through the integrated Script-    #
#              Generator. The contained functions DO NOT require      #
#              additional DLLs like the SharePoint.Client-DLLs        #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Josupeit | Initial Release                    | 29.07.2015 #
# 1.2  | S.Krieger  | Fertigstellung XML-Help-File       | 29.10.2015 #
# 1.3  | S.Krieger  | Erweiterungen                   ab | 30.10.2015 #
# 2.0  | S.Krieger  | Neuzusammenstellung als SPE.Common | 07.01.2016 #
######################################################################>
#endregion

#region Version 2.0

#region Functions for ActiveDirectory

    #region Function Get-SPEADInfo
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Get-SPEADInfo
    {
        [CmdletBinding()]
        param()
        begin{}
        process 
        {
            $ADDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
            $ADDomainName = $ADDomain.Name
            $Netbios = $ADDomain.Name.Split(".")[0].ToUpper()
            $ADServer = ($ADDomain.InfrastructureRoleOwner.Name.Split(".")[0])
            $FQDN = "DC=" + $ADDomain.Name -Replace("\.",",DC=")
 
            $Results = New-Object Psobject
            $Results | Add-Member Noteproperty Domain $ADDomainName
            $Results | Add-Member Noteproperty FQDN $FQDN
            $Results | Add-Member Noteproperty Server $ADServer
            $Results | Add-Member Noteproperty Netbios $Netbios
            Return $Results
        }
    }
    #endregion
    #EndOfFunction
    
    #region Function Get-SPEADUsersFromADContainer
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPEADUsersFromADContainer {
        [CmdletBinding()]
        param
        (
 		    [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
		    [ADSI]
		    $ADRoot,

            [Parameter(Position=1)]
            [System.String]
            $sAMAccountName,

		    [Parameter(Position=2)]
		    [System.String]
		    $SearchScope = "Subtree",

            [Parameter(Position=3)]
            [System.String]
            $Filter = "objectClass=user",

            [Parameter(Position=4)]
            [int]
            $PageSize = 1000,

            [Parameter(Position=5)]
            [String[]]
            $Properties
       )

        begin 
        {
        }

        process 
        {
            try
            {
                $Filter = "(&(" + $Filter + "))"
                if($sAMAccountName)
                {
                    $Filter = $Filter.Replace("))",")(sAMAccountName=" + $sAMAccountName + "))")
                }
                $objDomain = New-Object System.DirectoryServices.DirectoryEntry
                $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
                $objSearcher.SearchRoot = $ADRoot
                $objSearcher.PageSize = $PageSize
                $objSearcher.Filter = $Filter
                $objSearcher.SearchScope = $SearchScope
                if($Properties.Count -gt 0){
                    foreach($prop in $Properties)
                    {
                        $objSearcher.PropertiesToLoad.Add($prop)
                    }
                }
                $results = $objSearcher.FindAll()
                return $results
            }
            catch
            {
	            $exMessage = $_.Exception.Message
	            $innerException = $_.Exception.InnerException
	            $info = "Fehler bei Erfassen von AD-Usern in der Function 'Get-SPEADUsersFromADContainer'"
	            Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                return $null
            }
            finally
            {
            }
        }
    }
    #endregion
    #EndOfFunction
    
#endregion

#region Functions for Common Usage

	#region Function Push-SPEException
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Push-SPEException
    {
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
            $global:foundErrors = $true
            $LogMessage = "Fehler bei Info   : " + $info
            Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            if($site){
                $LogMessage = "Fehler bei SPSite : " + $site
                Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            }
            if($web){
                $LogMessage = "Fehler bei SPWeb  : " + $web
                Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            }
            if($list){
                $LogMessage = "Fehler bei SPList : " + $list
                Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            }
            $LogMessage = "ExceptionMessage  : " + $exMessage
            Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            $innerException.split([char]10) | foreach{
                $LogMessage = "InnerException    : " + $_.Replace([String][char]13,"")
                Write-SPELogMessage -message $LogMessage -Level "Unexpected"
            }
            $pscmdletData = $PSCmdlet
            $callString = "Fehler trat auf"
            if($pscmdletData.MyInvocation.ScriptName){
                $callScriptname = $pscmdletData.MyInvocation.ScriptName
                $callString += " in Script '$callScriptname' "
            }
            if($pscmdletData.MyInvocation.ScriptLineNumber){
                $callScriptLine = $pscmdletData.MyInvocation.ScriptLineNumber
                $callString += " in Zeile '$callScriptLine'"
            }
            $callString += ". Bitte in vorgeschaltetem TRY-Block nach Fehler suchen."
            Write-SPELogMessage -message $callString -Level "Unexpected"
        }
    }
    #endregion
    #EndOfFunction
    
    #region Function Wait-SPEForKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Wait-SPEForKey
    {
        [CmdletBinding()]
        param()
        begin{}

        process {
			Write-Host "Beliebige Taste zum Fortsetzen drücken..." -ForegroundColor Green
            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        end{}
    }
    #endregion
    #EndOfFunction		

	#region Function Wait-SPEOnKey
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Wait-SPEOnKey
	{
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
			if ($host.ui.RawUI.KeyAvailable -and $host.UI.RawUI.ReadKey().Character -eq ' ') {
				Wait-SPEForKey
	 		}
	 		sleep -m 50 # give me chance to press the key ;)
		}
    }
    #endregion
    #EndOfFunction
    
	#region Function Get-SPEBaseTypeNameFromObject
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Get-SPEBaseTypeNameFromObject
	{
		[CmdletBinding()]
		Param(
			$object
		)
		begin{
			
		}
		process
        {
            if($object){
                if(($object.GetType().Name -match "Object") -or ($object.GetType().Name.Contains("[]")))
                {
    			    return $object.GetType().BaseType.Name
                } else {
                    return $object.GetType().Name
                }
            }
		}
	}
    #endregion
    #EndOfFunction
    
	#region Function Export-SPECsv
		<##############################################################
		# Diese Function dient als Workaround für den Fall, dass die  #
		# Powershell älter als Version 3 ist, da dort der Parameter   #
		# "-Append" noch nicht im Cmdlet Export-SPECsv vorhanden war.    #
		# Daher wird diese Function auch nur dann freigeben, wenn     #
		# Powershell V2 vorhanden sind. In V3 bleibt diese Function   #
		# inaktiv.                                                    #
		##############################################################>
		    
		<#
		This Export-SPECsv behaves exactly like native Export-Csv
		However it has one optional switch -Append
		Which lets you append new data to existing CSV file: e.g.
		Get-Process | Select ProcessName, CPU | Export-SPECsv processes.csv -Append
		For details, see
		http://dmitrysotnikov.wordpress.com/2010/01/19/Export-Csv-append/
		(c) Dmitry Sotnikov
		#>
		    
		$psversion = $PSVersionTable["PSVersion"]
		if($psversion.Major -lt 3){
		    function Export-SPECsv {
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
		                $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Export-SPECsv',[System.Management.Automation.CommandTypes]::Cmdlet)
		        
		        
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
		                                # ASCII is default encoding for Export-SPECsv
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
		                    # execute Export-SPECsv as we got it because
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
    #EndOfFunction
    
    #region Function Get-SPECurrentUsersNames
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPECurrentUsersNames {
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            $outObj = New-Object System.Object
            try
            {
                $strName = $env:USERNAME
                $strFilter = "(&(objectCategory=User)(samAccountName=$strName))"
                $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
                $objSearcher.Filter = $strFilter
                $objPath = $objSearcher.FindOne()
                $objUser = $objPath.GetDirectoryEntry()
                $outObj | Add-Member -NotePropertyName "DisplayName" -NotePropertyValue $objUser.displayName
                $outObj | Add-Member -NotePropertyName "GivenName" -NotePropertyValue $objUser.givenName
                $outObj | Add-Member -NotePropertyName "SurName" -NotePropertyValue $objUser.sn
                return $outObj
            }
            catch
            {
                if($UseInfoHeader){
                    Show-SPETextArray -textArray @(
                        "Es gibt ein Problem beim automatischen Erfassen der UserNames.",
                        "Vermutlich liegt das daran, dass die Domäne derzeit nicht erreichbar ist.",
                        "Daher bitte die Daten manuell eingeben"
                    )
                    Wait-SPEForKey
                    $manualDisplayName = Show-SPEQuestion -text "Bitte den Anzeigenamen eingeben"
                    $manualGivenName = Show-SPEQuestion -text "Bitte den Vornamen eingeben"
                    $manualSN = Show-SPEQuestion -text "Bitte den Nachnamen eingeben"
                    $outObj | Add-Member -NotePropertyName "DisplayName" -NotePropertyValue $objUser.displayName
                    $outObj | Add-Member -NotePropertyName "GivenName" -NotePropertyValue $objUser.givenName
                    $outObj | Add-Member -NotePropertyName "SurName" -NotePropertyValue $objUser.sn
                    return $outObj

                }
                if($global:ActivateTestLoggingException)
                {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Fehler bei automatischer Erfassung der Benutzerdaten in Get-SPECurrentUsersNames"
	                Push-SPEException -exMessage $exMessage -innerException $innerException -info $info
                }
            }
        }
    }
    #endregion
    #EndOfFunction
    
    #region Function Get-SPECurrentUsersShortName
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPECurrentUsersShortName {
       [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][int]$Length
        )

        begin {
        }

        process {
            $curUser = Get-SPECurrentUsersNames
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
    #EndOfFunction

    #region Function Get-SPEWindowsPSModulesFolderPath
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPEWindowsPSModulesFolderPath {
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            $windir = $env:windir
            $modulePaths = ($env:PSModulePath).Split(';')
            foreach($modulePath in $modulePaths)
            {
                if($modulePath.StartsWith($windir))
                {
                    return $modulePath
                }
            }
        }
    }
    #endregion
    #EndOfFunction

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

    #region Function Set-SPEVariable
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Set-SPEVariable {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [System.String]$VariableName,

            [Parameter(Position=1,Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [System.String]$CommandString
        )

        begin {
        }

        process {
            $commandBlock = "Set-Variable -Name $VariableName -Value ($CommandString) -Scope Global"
            iex $commandBlock # invoke-Expression
            $CommandBlock = $null
        }
    }
    #endregion
    #EndOfFunction

    #region Function Exit-SPEOnCtrlC    
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Exit-SPEOnCtrlC 
    {
        [CmdletBinding()]
        param()
        Begin{}
        Process{
            [console]::TreatControlCAsInput = $true
            if ($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
            {
                throw (new-object ExecutionEngineException "Ctrl+C Pressed")
            }
        }
    }
    #endregion
    #EndOfFunction

    #region Function Reset-SPEModule
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Reset-SPEModule
    {
        [CmdletBinding()]
        param(
            [String]$ModuleName="SamsPowerShellEnhancements"
        )
        Begin{}
        Process
        {
            $module = Get-Module $ModuleName
            if($module){
                Write-Host "Module '$ModuleName' ist geladen und wird entladen"
                Remove-Module $ModuleName
                Write-Host "...wurde entladen..."
                Write-Host "...wird geladen..."
                Import-Module $ModuleName
                Write-Host "Module '$ModuleName' wurde geladen"
            } else {
                $availableModules = Get-Module -ListAvailable | ?{$_.Name -eq $ModuleName}
                if($availableModules)
                {
                    Write-Host "Module '$ModuleName' ist nicht geladen und wird geladen..."
                    Import-Module $ModuleName
                    Write-Host "Module '$ModuleName' wurde geladen"
                } else {
                    Write-Host "Module mit Namen '$ModuleName' steht nicht zur Verfügung."
                }
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Open-SPEWebsiteInInternetExplorer
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Open-SPEWebsiteInInternetExplorer
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)]
            [String]$Url
        )
        Begin
        {
            $ie = New-Object -ComObject InternetExplorer.Application
            $ie.Navigate2($Url)
            $ie.Visible = $true
        }
    }
    #endregion
    #EndOfFunction

#endregion

#region Functions for Console Manipulation

	#region Function Set-SPEConsoleTitle
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleTitle
	{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [string]$newTitle
        )
        Begin{}
        Process{
		    $oldTitle = $Host.UI.RawUI.WindowTitle
		    $Host.UI.RawUI.WindowTitle = $newTitle
		    return $oldTitle
        }
        End{}
	}
    #endregion
    #EndOfFunction
    		
	#region Function Set-SPEConsoleBufferSize
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleBufferSize
	{	
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [int]$width,
            [Parameter(Position=1,Mandatory=$true)]
            [int]$height
        )
        Begin{}
        Process{
		    $buffer = $Host.UI.RawUI.BufferSize
		    $buffer.Width = $width
		    $buffer.Height = $height
		    $Host.UI.RawUI.BufferSize = $buffer
        }
        End{}
	}
    #endregion
    #EndOfFunction
    
	#region Function Set-SPEConsoleWindowSize
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleWindowSize
	{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [int]$width,
            [Parameter(Position=1,Mandatory=$true)]
            [int]$height
        )
        Begin{}
        Process{
		    $size = $Host.UI.RawUI.WindowSize
		    $size.Width = $width
		    $size.Height = $height
		    $Host.UI.RawUI.WindowSize = $size
        }
        End{}
	}
    #endregion
    #EndOfFunction
    
	#region Function Set-SPEConsoleForeGroundColor
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleForeGroundColor
	{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateSet("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")][string]$color
        )
        Begin{}
        Process{
    		$host.UI.RawUI.ForegroundColor = $color
        }
        End{}
	}
    #endregion
    #EndOfFunction
    
	#region Function Set-SPEConsoleBackGroundColor
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleBackGroundColor
	{
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateSet("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")][string]$color
        )
        Begin{}
        Process{
		    $host.UI.RawUI.BackgroundColor = $color
        }
        End{}
	}
    #endregion
    #EndOfFunction
    
	#region Function Set-SPEConsoleColors
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Set-SPEConsoleColors
	{
       [CmdletBinding()]
        param
        (
            [Parameter(Position=0,Mandatory=$true)]
            [ValidateSet("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")][string]$fore,
            [Parameter(Position=1,Mandatory=$true)]
            [ValidateSet("Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")][string]$back
        )
        Begin{}
        Process{
		    Set-SPEConsoleForeGroundColor -color $fore
		    Set-SPEConsoleBackGroundColor -color $back
        }
        End{}
	}
    #endregion
    #EndOfFunction
    
#endregion

#region Functions for FileSystem

	#region Function Get-SPEDirectorySubfolders
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Get-SPEDirectorySubfolders
	{
        [CmdletBinding()]
        param
        ([System.IO.DirectoryInfo]$folder)

        begin {
			$folderPath = $folder.fullname
        }

        process {
			$folders = Get-ChildItem $folderPath | ?{$_.Attributes -match "Directory"}
			if($folders -ne $null)
			{
				return $folders
			}
			else
			{
				return $null
			}
		}
    }
    #endregion
    #EndOfFunction
    
	#region Function Get-SPEDirectoryFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Get-SPEDirectoryFiles
	{
        [CmdletBinding()]
        param
        (
			[System.IO.DirectoryInfo]$folder
		)

        begin {
			$folderPath = $folder.FullName
        }

        process {
			$files = Get-ChildItem $folderPath | ?{$_.Attributes -notmatch "Directory"}
			if($files -ne $null)
			{
				return $files
			}
			else
			{
				return $null
			}
    	}
    }
    #endregion
    #EndOfFunction
    
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

    #region Function Edit-SPETextFileByFilterToNewFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Edit-SPETextFileByFilterToNewFile 
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [String]
            $sourcePath,
            [Parameter(Position=1, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [String]
            $targetPath,
            [Parameter(Position=2, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [Array]
            $filterStringArray,
            [Parameter(Position=3, Mandatory=$false)]
            [Switch]
            $returnNewFile
        )

        begin {
        }

        process {
            if(get-item $sourcePath)
            {
                $sr = New-Object System.IO.StreamReader $sourcePath
                while(!$sr.EndOfStream)
                {
                    $line = $sr.ReadLine()
                    $lineContainsFilter = $false
                    if($line -ne "" -and $line -ne $null)
                    {
                        foreach($filterString in $filterStringArray)
                        {
                            if($line.Contains($filterString))
                            {
                                $lineContainsFilter = $true
                            }
                        }
                    }
                    if(!$lineContainsFilter)
                    {
                        $line >> $targetPath
                    }
                }
                if($returnNewFile)
                {
                    $newfile = get-item $targetPath
                    return $newfile
                }
            } else {
                if($global:ActivateTestLoggingException){Write-SPELogMessage -message "Fehler in Function 'Edit-SPETextFileByFilterToNewFile': Source-File konnte unter Pfad '$sourcePath' nicht gefunden werden."}
                if($returnNewFile)
                {
                    return $null
                }
            }
        }

        end{
        }
    }
    #endregion
    #EndOfFunction

    #region Function Expand-SPEZIPFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Expand-SPEZIPFile
    {
        [CmdletBinding()]
        param
        (
 		        [Parameter(Position=0, Mandatory=$true)]
		        #[ValidateNotNullOrEmpty()]
		        [System.String]
		        $PathToZIP,
 		        [Parameter(Position=1, Mandatory=$true)]
		        [ValidateNotNullOrEmpty()]
		        [System.String]
		        $DestinationPath
        )
        begin{}
        process
        {
            $shell = new-object -com shell.application
            $zip = $shell.NameSpace($PathToZIP)
            foreach($item in $zip.items())
            {
                $shell.Namespace($DestinationPath).copyhere($item)
            }
        }
    }
    #endregion
    #EndOfFunction

#endregion

#region Functions for Logs And Reports

    #region Function Edit-SPELogFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Edit-SPELogFile
    {
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
    #EndOfFunction
    
    #region Function Get-SPECurrentTimeForULS
    #.ExternalHelp SPE.Common.psm1-help.xml
 	function Get-SPECurrentTimeForULS 
    {
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
    #EndOfFunction       

    #region Function Set-SPEGuidIncrement
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Set-SPEGuidIncrement
    {
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
    #EndOfFunction

    #region Function Set-SPEGuidIncrement1stBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Set-SPEGuidIncrement1stBlock
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
            $guidString = $guid.Guid
            $guidArray = $guidString.Split('-')
            $guid1 = $guidArray[0]
            $guid2 = $guidArray[1]
            $guid3 = $guidArray[2]
            $guid4 = $guidArray[3]
            $guid5 = $guidArray[4]
            $guid1Int = [Convert]::ToInt64($guid1, 16)
            $guid1Int++
            $guid1 = $guid1Int.ToString("X" + 8)
            if($guid1.Length -gt 8){
                $guid1 = $guid1.TrimStart("1")
            }
            return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
        }
    }
    #endregion
    #EndOfFunction

    #region Function Set-SPEGuidIncrement2ndBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Set-SPEGuidIncrement2ndBlock
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
            $guidString = $guid.Guid
            $guidArray = $guidString.Split('-')
            $guid1 = $guidArray[0]
            $guid2 = $guidArray[1]
            $guid3 = $guidArray[2]
            $guid4 = $guidArray[3]
            $guid5 = $guidArray[4]
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
            return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
        }
    }
    #endregion
    #EndOfFunction

    #region Function Set-SPEGuidIncrement3rdBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Set-SPEGuidIncrement3rdBlock
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
            $guidString = $guid.Guid
            $guidArray = $guidString.Split('-')
            $guid1 = $guidArray[0]
            $guid2 = $guidArray[1]
            $guid3 = $guidArray[2]
            $guid4 = $guidArray[3]
            $guid5 = $guidArray[4]
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
            return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
        }
    }
    #endregion
    #EndOfFunction

    #region Function Set-SPEGuidIncrement4thBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Set-SPEGuidIncrement4thBlock
    {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][Guid]$guid
        )

        begin {
        }

        process {
            $guidString = $guid.Guid
            $guidArray = $guidString.Split('-')
            $guid1 = $guidArray[0]
            $guid2 = $guidArray[1]
            $guid3 = $guidArray[2]
            $guid4 = $guidArray[3]
            $guid5 = $guidArray[4]
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
            return [Guid]("$guid1-$guid2-$guid3-$guid4-$guid5")
        }
    }
    #endregion
    #EndOfFunction

    #region Function Write-SPELogMessage
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Write-SPELogMessage
    {
        [CmdletBinding()]
        param
        (
            [ValidateSet("Critical","High","Medium","Verbose","VerboseEx","Unexpected")][String]$level = "VerboseEx",
            [ValidateSet("ListView","ViewField","ListField","Script","WebSite","SiteCollection","List","ListItem","misc","other")][String]$area = "Script",
            [ValidateSet("Added","Removed","Started","Stopped","Aborted","Adding","Removing","Determining")][String]$category,
            [Guid]$CorrelationId = $global:CorrelationID,
            [String]$eventId = "0000",
            [String]$process = "powershell.exe (0x0E44)",
            [String]$thread = "0x05BC",
            [String]$message
        )

        begin {
			Get-SPEOrSetLogFiles
        }

        process {
            $strCorrelationId = $CorrelationId.Guid
            $CurrentTimeStamp = Get-SPECurrentTimeForULS
            if($global:LogToConsole){
                if($global:UseInfoHeader)
                {
                    if($level -match "Critical" -or $level -match "High" -or $level -match "Unexpected"){
                        Show-SPETextLine -text $Content -fgColor $global:DisplayForeGroundColor_Error -bgColor $global:DisplayBackGroundColor_Error
                    } else {
                        Show-SPETextLine -text $Content
                    }
                    Wait-SPEForKey

                } else {
			        Write-Host $CurrentTimeStamp -NoNewline #Ausgabe des Log-Eintrags auf Console
				    if($level -match "Critical" -or $level -match "High"-or $level -match "Unexpected"){
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
                $NewLine = "$CurrentTimeStamp	$process	$thread	$area	$category	$eventId	$level	$message	$strCorrelationId" #Do not edit this line! it's TAB-separated!!
			    $NewLine >> $PathULSLogfile #Ausgabe des Log-Eintrags in ULSfile
            }
        }
    }
    #endregion
    #EndOfFunction

    #region Function Write-SPEReportMessage
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Write-SPEReportMessage
    {
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
		    $dtString = Get-SPECurrentTimeForULS #Abfrage der aktuellen Zeit
            $strCorrelationId = $CorrelationId.Guid
			Get-SPEOrSetReportFiles
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
    #EndOfFunction

    #region Function New-SPELogFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function New-SPELogFiles
    {
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
    #EndOfFunction

    #region Function New-SPEReportFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function New-SPEReportFiles
    {
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
    #EndOfFunction

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

    #region Function Get-SPEOrSetLogFiles
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Get-SPEOrSetLogFiles
    {
        [CmdletBinding()]
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
	                Limit-SPEDirectorySize -dirPath $dirLog
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
							New-SPELogFiles -RecreateULS
						}
						else
						{
							$global:PathULSLogFile = $lastFile.FullName
						}
					} else {
						New-SPELogFiles
					}
				} else {
					New-SPELogFiles
				}
			}
			if($global:LogToLogfile)
			{
				New-SPELogFiles
			}
        }
    }
    #endregion
    #EndOfFunction

	#region Function Limit-SPEDirectorySize
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Limit-SPEDirectorySize
	{
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
    #EndOfFunction
    
    #region Function Write-SPELogAndTextMessage
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Write-SPELogAndTextMessage
    {
        [CmdletBinding()]
        param
        (
            [String]$message
        )
        Begin{}
        Process{
            Show-SPETextLine -text $message
            Write-SPELogMessage -message $message 
        }
    }
    #endregion
    #EndOfFunction

#endregion

#region Functions for Registry

    #region Function Test-SPERegistryKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Test-SPERegistryKey
    {        
        [CmdletBinding()]
        param
        ([string] $path, [string] $key)

        begin {
        }

        process {
    
            return ((Test-Path $path) -and ((Get-SPERegistryKey $path $key) -ne $null))       
        }
    }
    #endregion
    #EndOfFunction

    #region Function Remove-SPERegistryKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Remove-SPERegistryKey
    {        
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
    #EndOfFunction

    #region Function Set-SPERegistryKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Set-SPERegistryKey 
    {        
        [CmdletBinding()]
        param
        ([string] $path, [string] $key, [string] $value, [Switch]$Reboot)

        begin {
        }

        process {
            Set-ItemProperty -path $path -name $key -value $value    
            if($Reboot)
            {
                Restart-Computer
                exit
            }
        }
    }
    #endregion
    #EndOfFunction

    #region Function Get-SPERegistryKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPERegistryKey 
    {        
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
    #EndOfFunction        

    #region Function Clear-SPERegistryAutostart
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Clear-SPERegistryAutostart 
    {
        [CmdletBinding()]
        param
        ([String]$path=$global:RegRunKey,[string]$key=$global:restartKey)

        begin {
        }

        process {
            if (Test-SPERegistryKey -path $path -key $key) {
                Remove-SPERegistryKey -path $path -key $key
            }
        }
    }
    #endregion
    #EndOfFunction        

    #region Function Set-SPERegistryScriptStatus    
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Set-SPERegistryScriptStatus 
    {
        [CmdletBinding()]
        param
        ([string] $step)

        begin {
            $script=$PSCmdLet.MyInvocation.PSCommandPath
        }

        process {
            Set-SPERegistryKey -path $global:RegRunKey -key $global:restartKey -value "$global:powershell $script -Step $step"
        }
    }
    #endregion
    #EndOfFunction

    #region Function Get-SPERegistryScriptStatus
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPERegistryScriptStatus
    {
        [CmdletBinding()]
        param()
        Begin{}
        Process{
            if(Test-SPERegistryKey -path $global:RegRunKey -key $global:restartKey)
            {
                $regString = Get-SPERegistryKey -path $global:RegRunKey -key $global:restartKey
                $filterString = "$global:powershell $script -Step "
                $stepString = $regString.Replace($filterString, "")
                return $stepString
            } else {
                return $null
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction

#endregion

#region Functions for Selections

    #region Function Use-SPEChoice
    #.ExternalHelp SPE.Common.psm1-help.xml
		function Use-SPEChoice
		{
        [CmdletBinding()]
        param
        (
            [parameter(Mandatory=$true)][string]$Choices	
        )

        begin {
        }

        process {
		    # Umwandlung des Eingabe-Strings in ein Array    
	        $ChoicesArray = $Choices.Split(",")	
		    # Reset der Anzeige
		    $ChoiceShow = ""
		    # Erzeugen der Optionsanzeige
		    foreach ($Element in $ChoicesArray){	
			    if (!$ChoiceShow)
				    {
					    $ChoiceShow = " (" + $Element
				    } 
				    else
				    {
					    $ChoiceShow = $ChoiceShow + "|" + $Element
				    }
			    }
		    $ChoiceShow = $ChoiceShow + ")"
	
		    # Start der Kontrollschleife  
		    do{
			    # Abfrage der Option
			    $ChosenChoice = Read-Host $ChoiceShow
			    # Überprüfung der Eingabe 
			    $ArrayLength = $ChoicesArray.Length
			    $ChoiceDone = $False
			    for ($i=0; $i -lt $ArrayLength; $i++){
				    if ($ChoicesArray[$i]	-eq $ChosenChoice)
					    {
						    # Eingabe ist eine gegebene Option, dann Ausgabe
						    $ChoiceDone = $True
						    Return $ChosenChoice
						    break
					    } else {
						    # Eingabe ist nicht als Option vorhanden, dann Neustart der Abfrage
						    $ChoiceDone = $False
					    }
				    }
			    # Überprüfung auf Übereinstimmung der Wahl mit den vorgegebenen Optionen
			    if (!$ChoiceDone)
				    {
					    $ChoiceOK = $False
					    Write-Host "Bitte nur aus den vorgegebenen Werten wählen!!" -foregroundcolor Red
				    } Else {
					    $ChoiceOK = $True
				    }
			    } While (!$ChoiceOK)
	    }
    }
    #endregion
    #EndOfFunction

    #region Function Select-SPETF
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Select-SPETF
	{
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
		    $Ask = ""
		    $Ask = Use-SPEChoice "true,false"
		    switch ($Ask){
			    "true" {return $true}
			    "false" {return $false}
		    }
	    }
    }
    #endregion
    #EndOfFunction

    #region Function Select-SPEJN
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Select-SPEJN
	{
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
		    $Ask = ""
		    $Ask = Use-SPEChoice "J,N"
		    switch ($Ask){
			    "J" {return $true}
			    "N" {return $false}
		    }
	    }
    }
    #endregion
    #EndOfFunction

    #region Function Select-SPEYN
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Select-SPEYN
	{
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
		    $Ask = ""
		    $Ask = Use-SPEChoice "Y,N"
		    switch ($Ask){
			    "Y" {return $true}
			    "N" {return $false}
		    }
	    }
    }
    #endregion
    #EndOfFunction

#endregion


#region Functions for Text Output

	#region Function Out-SPESpeakText
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Out-SPESpeakText
	{
        [CmdletBinding()]
        param
        ([String]$text)

        begin {
        }

        process {
			$SPVOICE = new-object -com SAPI.SPVOICE;
	   		$SPVOICE.Speak($text)
		}
    }
    #endregion
    #EndOfFunction
    
    #region Function New-SPEInfoHeader
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function New-SPEInfoHeader
    {
        [CmdletBinding()]
        param
        (
            [String]$SuperScription = $global:InfoHeaderSuperScription,
            [String]$SubScription = $global:InfoHeaderSubScription,
            [String]$Width = $global:InfoHeaderWidth,
            [Char]$Char = $global:DisplayFrameChar
        )

        begin {
            if($global:SPEGeneratorActive)
            {
                $SubScription = $global:SPEvars.InfoHeaderSubScription
            }
        }

        process {
            #Creating Edge-Line
            $separatorFilled = ""
            for($i = 0; $i -le $Width; $i++){
                $separatorFilled += $Char
            }
            #Creating empty Edge-Line
            $separatorEmpty = $Char
            for($i = 2; $i -le $Width; $i++){
                $separatorEmpty += " "
            }
            $separatorEmpty += $Char
            #Creating outputArray
            $outputArray = New-Object System.Collections.ArrayList
            $outputArray.Add($separatorFilled) | Out-Null
            $outputArray.Add($separatorEmpty) | Out-Null
            $ArraySuperScription = Convert-SPETextToFramedBlock -Width $Width -InputText $SuperScription -char $Char
            foreach($StringSuperScription in $ArraySuperScription)
            {
                $outputArray.Add($StringSuperScription) | Out-Null
            }
            $outputArray.Add($separatorEmpty) | Out-Null
            $outputArray.Add($separatorFilled) | Out-Null
            $outputArray.Add($separatorEmpty) | Out-Null
            $ArraySubScription = Convert-SPETextToFramedBlock -Width $Width -InputText $SubScription -char $Char
            foreach($StringSubScription in $ArraySubScription)
            {
                $outputArray.Add($StringSubScription) | Out-Null
            }
            $outputArray.Add($separatorEmpty) | Out-Null
            $outputArray.Add($separatorFilled) | Out-Null
            $startTimeString = $global:starttime.ToString()
            $CurrentTime = Get-Date
            $CurrentTimeString = $CurrentTime.ToString()
            $CurrentDiffTime = $CurrentTime - $global:starttime
            $CurrentDiffTimeString = "{0:c}" -f $CurrentDiffTime
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText "Start  : $startTimeString" -Width $Width -char $Char)) | Out-Null
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText "Aktuell: $CurrentTimeString" -Width $Width -char $Char)) | Out-Null
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText "Dauer  : $CurrentDiffTimeString" -Width $Width -char $Char)) | Out-Null
            return $outputArray
        }
    }
    #endregion
    #EndOfFunction	    

    #region Function Show-SPEInfoHeader
    #.ExternalHelp SPE.Common.psm1-help.xml
   	Function Show-SPEInfoHeader
    {
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            if(!$UseInfoHeader){return}
            clear
            $ArrayHeader = New-SPEInfoHeader
            foreach($line in $ArrayHeader)
            {
                Write-Host $line -ForegroundColor $global:InfoHeaderForeGroundColor -BackgroundColor $global:InfoHeaderBackGroundColor
            }
        }
        end{}
    }
    #endregion
    #EndOfFunction

	#region Function Show-SPEQuestion
    #.ExternalHelp SPE.Common.psm1-help.xml
   	Function Show-SPEQuestion
    {
        [CmdletBinding()]
        param
        ([String]$text)

        begin {
        }

        process {
            Show-SPEInfoHeader
            foreach($line in (Convert-SPETextToFramedBlock -Width $global:InfoHeaderWidth -InputText $text -char $global:DisplayFrameChar))
            {
                Write-Host $line -ForegroundColor $global:DisplayForeGroundColor_Normal
            }
            $antwort = Read-Host
            return $antwort
        }
    }
    #endregion
    #EndOfFunction    

    #region Function Show-SPETextLine
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Show-SPETextLine
    {
        [CmdletBinding()]
        param
        (
            [String]$text,
            [String]$fgColor = $global:DisplayForeGroundColor_Normal,
            [String]$bgColor = $global:DisplayBackGroundColor_Normal
        )

        begin {
        }

        process {
            Show-SPEInfoHeader
            foreach($line in (Convert-SPETextToFramedBlock -Width $global:InfoHeaderWidth -InputText $text -char $global:DisplayFrameChar))
            {
                Write-Host $line -ForegroundColor $fgColor
            }
        }
    }
    #endregion
    #EndOfFunction    

    #region Function Show-SPETextArray
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Show-SPETextArray
    {
        [CmdletBinding()]
        param
        ([String[]]$textArray)

        begin {
        }

        process {
            Show-SPEInfoHeader
            foreach($block in $textArray)
            {
                foreach($line in (Convert-SPETextToFramedBlock -Width $global:InfoHeaderWidth -InputText $block -char $global:DisplayFrameChar))
                {
                    Write-Host $line -ForegroundColor $global:DisplayForeGroundColor_Normal
                }
            }
        }
        end{}
    }
    #endregion
    #EndOfFunction    

    #region Function Convert-SPEStringToBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Convert-SPEStringToBlock
    {
        [CmdletBinding()]
        param
        (
            [string]$Content,
            [int]$Width
        )

        begin {
        }

        process {
            $line = ""
            $WordCounter = 0
            $wordCounterLastLine = 0
            $lines = New-Object System.Collections.ArrayList
            $FullTextLength = $Content.Length
            $LengthRestText = $FullTextLength
            $Input_Words = $Content.Split(" ")
            $Count_Words = $Input_Words.Count
            foreach($word in $Input_Words){
                $WordCounter++
                if($width -le $FullTextLength) #$LengthRestText)
                {
                    if($WordCounter -eq 1)
                    {
                        $line = $word #schreibe erstes Wort
                        $LengthRestText = $LengthRestText - $word.Length
                        $Count_Words--
                    }
                    else
                    {
                        if(($line.Length + $word.Length + 1) -lt $width){
                            $line = $line + " " + $word
                            $Count_Words--
                            $LengthRestText = $LengthRestText - $word.Length
                        }
                        else
                        {
                            $lines.Add($line) | Out-Null
                            $line = $word
                            $Count_Words--
                            $LengthRestText = $LengthRestText - $word.Length
                        }
                    }
                }
                else
                {
                    $wordCounterLastLine++
                    if($wordCounterLastLine -eq 1)
                    {
                        if($line -ne ""){
                            $lines.Add($line) | Out-Null
                        }
                        $line = $word #schreibe erstes Wort
                        $Count_Words--
                    }
                    else
                    {
                        if($Count_Words -gt 0)
                        {
                            $line = $line + " " + $word
                            $Count_Words--
                        }
                    }
                }
            }
            $lines.Add($line) | Out-Null
            return $lines
        }
    }
    #endregion
    #EndOfFunction

    #region Function Convert-SPETextToFramedBlock
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Convert-SPETextToFramedBlock
    {
        [CmdletBinding()]
        param
        (
                [int]$width,
                [String]$InputText,
                [char]$char
            )

        begin {
        }

        process {
    
            $OutputArray = New-Object System.Collections.ArrayList
        
            $BlockText = Convert-SPEStringToBlock -Content $InputText -Width ($width - 4)

            foreach($line in $BlockText)
            {
                $newLine = $char + " " + $line
                $spaces = $width - $newLine.Length - 1
                for($i=0; $i -le $spaces; $i++)
                {
                    $newLine += " "
                }
                $newLine += $char
                $OutputArray.Add($newLine) | Out-Null
            }
            return $OutputArray
        }
    }
    #endregion
    #EndOfFunction

	#region Function Convert-SPEDiffTimeToString
    #.ExternalHelp SPE.Common.psm1-help.xml
	function Convert-SPEDiffTimeToString
	{
        [CmdletBinding()]
        param
        ([TimeSpan]$difftime)

        begin {
        }

        process {
			$str = "{0:c}" -f $difftime
			return $str
		}
    }
    #endregion
    #EndOfFunction
    
	#region Function Wait-SPELoop
    #.ExternalHelp SPE.Common.psm1-help.xml
	Function Wait-SPELoop
	{
	    [CmdletBinding()]
	    param
	    (
	        [Int]$time, 
	        [String[]]$text
	    )

	    begin {
	    }

	    process {
	        for($i = $time; $i -ge 0; $i--){
	            Show-SPETextArray -textArray (
	            $text,
	            " $i seconds to go."
	            )
	            Start-Sleep -Seconds 1
	        }
	    }
	}
    #endregion
    #EndOfFunction
    
#endregion

#region Functions for XML

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

    #region Function Get-SPEXmlNode
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Get-SPEXmlNode
    {
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
    #EndOfFunction

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

#endregion

#region SPE Standard Scripts

    #region Function New-SPEStandardScript
    #.ExternalHelp SPE.Common.psm1-help.xml
    function New-SPEStandardScript
    {
        [CmdletBinding()]
        param()
        Begin
        {
            $error.Clear()
            $global:SPEGeneratorActive = $true
            #region Auslesen der aktuellen Werte und Parameter
            $oldValues = @{
                "LogToConsole" = $global:LogToConsole;
                "LogToLogFile" = $global:LogToLogFile;
                "LogToULSFile" = $global:LogToULSFile;
                "ReportToFile" = $global:ReportToFile;
                "ReportToULS" = $global:ReportToULS;
                "UseInfoHeader" = $global:UseInfoHeader;
                "RunAsAdmin" = $global:RunAsAdmin;
                "ULsHeader" = $global:ULsHeader;
                "maxAgeOfULSFile" = $global:maxAgeOfULSFile;
                "maxSizeOfULSFile" = $global:maxSizeOfULSFile;
                "maxSizeOfULSDirectory" = $global:maxSizeOfULSDirectory;
                "InfoHeaderWidth" = $global:InfoHeaderWidth;
                "InfoHeaderSuperScription" = $global:InfoHeaderSuperScription;
                "InfoHeaderSubScription" = $global:InfoHeaderSubScription;
                "GivenBackGroundColor" = $global:GivenBackGroundColor;
                "InfoHeaderForeGroundColor" = $global:InfoHeaderForeGroundColor;
                "InfoHeaderBackGroundColor" = $global:InfoHeaderBackGroundColor;
                "DisplayForeGroundColor_Normal" = $global:DisplayForeGroundColor_Normal;
                "DisplayForeGroundColor_Error" = $global:DisplayForeGroundColor_Error;
                "DisplayBackGroundColor_Normal" = $global:DisplayBackGroundColor_Normal;
                "DisplayBackGroundColor_Error" = $global:DisplayBackGroundColor_Error;
                "DisplayFrameChar" = $global:DisplayFrameChar;
                "ActivateTestLoggingVerbose" = $global:ActivateTestLoggingVerbose;
                "ActivateTestLoggingException" = $global:ActivateTestLoggingException;
                "ActivateTestLogging" = $global:ActivateTestLogging;
            }
            #endregion
            #region Setzen der SPE-Werte und -Parameter
                $global:dirLog = $SPEVars.LogFolder;
                $global:StringWorkingDir = $SPEVars.ScriptFolder;
                $global:LogToConsole = $SPEvars.LogToConsole;
                $global:LogToLogFile = $SPEvars.LogToLogFile;
                $global:LogToULSFile = $SPEvars.LogToULSFile;
                $global:ReportToFile = $SPEvars.ReportToFile;
                $global:ReportToULS = $SPEvars.ReportToULS;
                $global:UseInfoHeader = $SPEvars.UseInfoHeader;
                $global:RunAsAdmin = $SPEvars.RunAsAdmin;
                $global:ULsHeader = $SPEvars.ULsHeader;
                $global:maxAgeOfULSFile = $SPEvars.maxAgeOfULSFile;
                $global:maxSizeOfULSFile = $SPEvars.maxSizeOfULSFile;
                $global:maxSizeOfULSDirectory = $SPEvars.maxSizeOfULSDirectory;
                $global:InfoHeaderWidth = $SPEvars.InfoHeaderWidth;
                $global:InfoHeaderSuperScription = $SPEvars.InfoHeaderSuperScription;
                $global:InfoHeaderSubScription = $SPEvars.InfoHeaderSubScription;
                $global:GivenBackGroundColor = $SPEvars.GivenBackGroundColor;
                $global:InfoHeaderForeGroundColor = $SPEvars.InfoHeaderForeGroundColor;
                $global:InfoHeaderBackGroundColor = $SPEvars.InfoHeaderBackGroundColor;
                $global:DisplayForeGroundColor_Normal = $SPEvars.DisplayForeGroundColor_Normal;
                $global:DisplayForeGroundColor_Error = $SPEvars.DisplayForeGroundColor_Error;
                $global:DisplayBackGroundColor_Normal = $SPEvars.DisplayBackGroundColor_Normal;
                $global:DisplayBackGroundColor_Error = $SPEvars.DisplayBackGroundColor_Error;
                $global:DisplayFrameChar = [Char]$SPEvars.DisplayFrameChar;
                $global:ActivateTestLoggingVerbose = $SPEvars.ActivateTestLoggingVerbose;
                $global:ActivateTestLoggingException = $SPEvars.ActivateTestLoggingException;
                $global:ActivateTestLogging = $SPEvars.ActivateTestLogging;
            #endregion
        }
        Process
        {

            $global:starttime = get-date
            #region Abfragen
            Show-SPETextArray -textArray @("Willkomen zum Script-Generator für SPE-Standard-Scripts.","")
            Wait-SPEForKey

            $Input_ScriptName = Show-SPEQuestion -text "Bitte den Namen des Scripts eingeben:"
            $Input_Description = Show-SPEQuestion -text "Bitte die Beschreibung des Scripts eingeben:"
            Show-SPETextLine -text "Soll das Script für einen Kunden erstellt werden?"
            if(Select-SPEJN){
                $Input_Customer = Show-SPEQuestion -text "Bitte den Namen des Kunden eingeben:"
            }
            #endregion
            #region fixe Daten
            $currentDate = "{0:dd'.'MM'.'yyyy}" -f (Get-Date) 
            #endregion
            #region Erzeugen bzw. Erfassen der Config-XML-Datei
            if(!(Test-Path -Path $SPEVars.ScriptFolder))
            {
                $catchOutput = New-Item -Path ($SPEVars.ScriptFolder) -ItemType "Directory"
            }
            if(!(Test-Path -Path $SPEVars.ConfigXMLFile))
            {
                $newConfigXML = [xml]$global:XMLConfigDefault # > $SPEVars.ConfigXMLFile
                Save-SPEXmlDocumentObjectAsUTF8 -XmlDocumentObject $newConfigXML -Path ($SPEVars.ConfigXMLFile)
                $newConfigXML = $null
            }
            [xml]$XMLConfigDoc = Get-Content -Path $SPEVars.ConfigXMLFile
            if(!$XMLConfigDoc){$global:SPEGeneratorActive = $false;break}
            #endregion
            #region Abfrage der Default-Parameter aus Config-XML-Datei und schreiben in HashTable zur späteren Anpassung
            $hashParameterGroups = @{
                "Pfade" = @{
                    "PathToSharePointDLLs" = $XMLConfigDoc.SPE_Config.Default.Pfade.PathToSharePointDLLs.Wert.ToString();
                    "dirLog" = $XMLConfigDoc.SPE_Config.Default.Pfade.dirLog.Wert.ToString();
                }
                "Logging" = @{
                    "LogToConsole" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToConsole.Wert.ToString();
                    "LogToLogFile" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToLogFile.Wert.ToString();
                    "LogToULSFile" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToULSFile.Wert.ToString();
                    "ReportToFile" = $XMLConfigDoc.SPE_Config.Default.Logging.ReportToFile.Wert.ToString();
                    "ReportToULS" = $XMLConfigDoc.SPE_Config.Default.Logging.ReportToULS.Wert.ToString();
                    "ActivateTestLoggingVerbose" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLoggingVerbose.Wert.ToString();
                    "ActivateTestLoggingException" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLoggingException.Wert.ToString();
                    "ActivateTestLogging" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLogging.Wert.ToString();
                }
                "Scriptverhalten" = @{
                    "TestModus" = $XMLConfigDoc.SPE_Config.Default.Scriptverhalten.TestModus.Wert.ToString();
                    "RunAsAdmin" = $XMLConfigDoc.SPE_Config.Default.Scriptverhalten.RunAsAdmin.Wert.ToString();
                    "DefaultCorrId" = $XMLConfigDoc.SPE_Config.Default.Scriptverhalten.DefaultCorrId.Wert.ToString();
                }
                "Registry" = @{
                    "powershell" = $XMLConfigDoc.SPE_Config.Default.Registry.powershell.Wert.ToString();
                    "RegRunKey" = $XMLConfigDoc.SPE_Config.Default.Registry.RegRunKey.Wert.ToString();
                    "restartKey" = $XMLConfigDoc.SPE_Config.Default.Registry.restartKey.Wert.ToString();
                }
                "ULS" = @{
                    "UlsHeader" = $XMLConfigDoc.SPE_Config.Default.ULS.UlsHeader.Wert.ToString();
                    "maxAgeOfULSFile" = $XMLConfigDoc.SPE_Config.Default.ULS.maxAgeOfULSFile.Wert.ToString();
                    "maxSizeOfULSFile" = $XMLConfigDoc.SPE_Config.Default.ULS.maxSizeOfULSFile.Wert.ToString();
                    "maxSizeOfULSDirectory" = $XMLConfigDoc.SPE_Config.Default.ULS.maxSizeOfULSDirectory.Wert.ToString();
                }
                "Display" = @{
                    "UseInfoHeader" = $XMLConfigDoc.SPE_Config.Default.Display.UseInfoHeader.Wert.ToString();
                    "InfoHeaderWidth" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderWidth.Wert.ToString();
                    "InfoHeaderSuperScription" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderSuperScription.Wert.ToString();
                    "InfoHeaderSubScription" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderSubScription.Wert.ToString();
                    "GivenBackGroundColor" = $XMLConfigDoc.SPE_Config.Default.Display.GivenBackGroundColor.Wert.ToString();
                    "InfoHeaderForeGroundColor" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderForeGroundColor.Wert.ToString();
                    "InfoHeaderBackGroundColor" = $XMLConfigDoc.SPE_Config.Default.Display.InfoHeaderBackGroundColor.Wert.ToString();
                    "DisplayForeGroundColor_Normal" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayForeGroundColor_Normal.Wert.ToString();
                    "DisplayForeGroundColor_Error" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayForeGroundColor_Error.Wert.ToString();
                    "DisplayBackGroundColor_Normal" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayBackGroundColor_Normal.Wert.ToString();
                    "DisplayBackGroundColor_Error" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayBackGroundColor_Error.Wert.ToString();
                    "DisplayFrameChar" = $XMLConfigDoc.SPE_Config.Default.Display.DisplayFrameChar.Wert;
                }

            }
            #endregion
            #region Inserts
            $line_Company        = Convert-SPETextToFramedBlock -InputText "MT AG - D-40882 Ratingen" -width 70 -char '#'
            $line_ScriptName     = Convert-SPETextToFramedBlock -InputText ("Name    : $Input_ScriptName" + ".ps1") -width 70 -char '#'
            $line_Description    = Convert-SPETextToFramedBlock -InputText ("Funktion: $Input_Description") -width 70 -char '#'
            $line_ConfigDescription = Convert-SPETextToFramedBlock -InputText ("Funktion: Dieses Script dient der lokalen Bereitstellung von Script-relevanten Parametern und Variablen für das PowerShell-Script '$Input_ScriptName.ps1'") -width 70 -char '#'
            $line_Customer       = Convert-SPETextToFramedBlock -InputText ("Kunde   : $Input_Customer") -width 70 -char '#'
            #endregion
            #region Manipulation des FullCodeSnippets
            $FullCode1 = $FullScriptCode1.Replace("[line_Company]",$line_Company)
            $FullCode1 = $FullCode1.Replace("[line_ScriptName]",$line_ScriptName)
            $FullCode1 = $FullCode1.Replace("[line_Customer]",$line_Customer)
            $FullCode2 = $FullScriptCode2.Replace("[line_dat]",$currentDate)
            $userShortName = Get-SPECurrentUsersShortName -Length 10
            $FullCode2 = $FullCode2.Replace("[UserName]",$userShortName)
            #endregion
            #region Abfragen zu Config-Parametern
                Show-SPETextArray -textArray ("Standardmäßig werden Log- und Report-Files im ULS-Format ausgegeben und der Infoheader aktiviert.","","Ebenso werden Status- und Exception-Meldungen aus den Cmdlets des SPE-Modules in das Log geschrieben.","Soll diese Vorgabe übernommen werden?")
                if(!(Select-SPEJN)){
                    #region Log to Console
                    Show-SPETextLine -text "Soll das Logging auf die Console erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.LogToSonsole = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToSonsole = '$false'
                    }
                    #endregion
                    #region Log To File
                    Show-SPETextLine -text "Soll das Logging in eine Textdatei erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.LogToLogFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToLogFile = '$false'
                    }
                    #endregion
                    #region Log to ULS
                    Show-SPETextLine -text "Soll das Logging in ULS-File erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.LogToULSFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToULSFile = '$false'
                    }
                    #endregion
                    #region Report to File
                    Show-SPETextLine -text "Soll das Reporting in eine Textdatei erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ReportToFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.ReportToFile = '$false'
                    }
                    #endregion
                    #region Report to ULS
                    Show-SPETextLine -text "Soll das Reporting in eine ULS-Datei erfolgen?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ReportToULS = '$true'
                    } else {
                        $hashParameterGroups.Logging.ReportToULS = '$false'
                    }
                    #endregion
                    #region Use Infoheader
                    Show-SPETextLine -text "Soll bei Consolen-Ausgabe der InfoHeader genutzt werden?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Display.UseInfoHeader = '$true'
                    } else {
                        $hashParameterGroups.Display.UseInfoHeader = '$false'
                    }
                    #endregion
                    #region ActivateTestLogging
                    Show-SPETextLine -text "Sollen allgemeine Meldungen der SPE-Cmdlets in das Log geschrieben werden?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ActivateTestLogging = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLogging = '$false'
                    }
                    #endregion
                    #region ActivateTestLoggingVerbose
                    Show-SPETextLine -text "Sollen Status-Meldungen der SPE-Cmdlets in das Log geschrieben werden?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ActivateTestLoggingVerbose = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLoggingVerbose = '$false'
                    }
                    #endregion
                    #region ActivateTestLoggingException
                    Show-SPETextLine -text "Sollen Exception-Meldungen der SPE-Cmdlets in das Log geschrieben werden?"
                    if(Select-SPEJN){
                        $hashParameterGroups.Logging.ActivateTestLoggingException = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLoggingException = '$false'
                    }
                    #endregion
                } 
                #region TestModus aktivieren
                Show-SPETextLine -text "Soll der TestModus aktiviert werden?"
                if(Select-SPEJN){
                    $hashParameterGroups.Scriptverhalten.TestModus = '$true'
                } else {
                    $hashParameterGroups.Scriptverhalten.TestModus = '$false'
                }
                #endregion
                #region RunAsAdmin aktivieren
                Show-SPETextLine -text "Sind für die Ausführung des Scripts voraussichtlich Administrator-Berechtigungen erforderlich?"
                if(Select-SPEJN){
                    $hashParameterGroups.Scriptverhalten.RunAsAdmin = '$true'
                } else {
                    $hashParameterGroups.Scriptverhalten.RunAsAdmin = '$false'
                }
                #endregion

            #endregion

            #region weitere Parameter ohne Abfrage

                #region Sammeln aller vorhandenen Correlation IDs und erzeugen einer neuen
                if($XMLConfigDoc.SPE_Config.HasChildNodes -and $XMLConfigDoc.SPE_Config.ChildNodes.Count -gt 1)
                {
                    $xmlScriptNodes = $XMLConfigDoc.SPE_Config.ChildNodes
                    $arrayCorrIDs = New-Object System.Collections.ArrayList
                    foreach($xmlScriptNode in $xmlScriptNodes)
                    {
                        Set-SPEVariable -VariableName tempGuid -CommandString ($xmlScriptNode.Scriptverhalten.DefaultCorrId.Wert)
                        $catchOutput = $arrayCorrIDs.Add($tempGuid)
                    }
                    $arrayCorrIDs = [Array]$arrayCorrIDs | Sort-Object
                    $newCorrID = Set-SPEGuidIncrement1stBlock -guid $arrayCorrIDs[$arrayCorrIDs.GetUpperBound(0)]
                } else {
                    Set-SPEVariable -VariableName tempGuid -CommandString ($hashParameterGroups.Scriptverhalten.DefaultCorrid)
                    $newCorrID = Set-SPEGuidIncrement1stBlock -guid $tempGuid
                }
                $hashParameterGroups.Scriptverhalten.DefaultCorrId = '[Guid]"' + $newCorrID.ToString() + '"'
                #endregion

                #region Registry-Restart-Key
                $hashParameterGroups.Registry.restartKey = '"' + $hashParameterGroups.Registry.restartKey.ToString().Replace('"','') + "_" + $Input_ScriptName + '"'
                #endregion

                #region InfoheaderSubScription
                $hashParameterGroups.Display.InfoHeaderSubScription = '"' + $Input_Description.ToString() + '"'
                #endregion

                #region InfoheaderSuperScription
                $hashParameterGroups.Display.InfoHeaderSuperScription = '"' + $hashParameterGroups.Display.InfoHeaderSuperScription.ToString().Replace('"','') + " - Kunde: " + $Input_Customer + '"'
                #endregion

            #endregion

            #region Definition der Quell- und Ziel-Pfade
            if(!(Test-Path $StringWorkingDir))
            {
                $catchOutput = New-Item -Path $StringWorkingDir -ItemType "Directory"
            }
            $scriptfilePath = $StringWorkingDir + $Input_ScriptName + ".ps1"
            #endregion
            #region Erzeugen des Ausgabe-Scripts
            $FullCode1 > $scriptfilePath
            $line_Description >> $scriptfilePath
            $FullCode2 >> $scriptfilePath
            #endregion
            #region Erzeugen und Einfügen der neuen Script-Node
            $xmlScriptNode = $XMLConfigDoc.CreateElement($Input_ScriptName)
            $XMLConfigDoc.SPE_Config.AppendChild($xmlScriptNode) | Out-Null
            $xmlScriptNode.InnerXml = $XMLConfigDoc.SPE_Config.Default.InnerXml
            #endregion
            #region Anpassen der Script-ChildNodes mit den erfassten Parametern
            $xmlScriptNode.Pfade.PathToSharePointDLLs.Wert = $hashParameterGroups.Pfade.PathToSharePointDLLs
            $xmlScriptNode.Pfade.dirLog.Wert = $hashParameterGroups.Pfade.dirLog
            $xmlScriptNode.Logging.LogToConsole.Wert = $hashParameterGroups.Logging.LogToConsole
            $xmlScriptNode.Logging.LogToLogFile.Wert = $hashParameterGroups.Logging.LogToLogFile
            $xmlScriptNode.Logging.LogToULSFile.Wert = $hashParameterGroups.Logging.LogToULSFile
            $xmlScriptNode.Logging.ReportToFile.Wert = $hashParameterGroups.Logging.ReportToFile
            $xmlScriptNode.Logging.ReportToULS.Wert = $hashParameterGroups.Logging.ReportToULS
            $xmlScriptNode.Logging.ActivateTestLogging.Wert = $hashParameterGroups.Logging.ActivateTestLogging
            $xmlScriptNode.Logging.ActivateTestLoggingVerbose.Wert = $hashParameterGroups.Logging.ActivateTestLoggingVerbose
            $xmlScriptNode.Logging.ActivateTestLoggingException.Wert = $hashParameterGroups.Logging.ActivateTestLoggingException
            $xmlScriptNode.Scriptverhalten.TestModus.Wert = $hashParameterGroups.Scriptverhalten.TestModus
            $xmlScriptNode.Scriptverhalten.RunAsAdmin.Wert = $hashParameterGroups.Scriptverhalten.RunAsAdmin
            $xmlScriptNode.Scriptverhalten.DefaultCorrId.Wert = $hashParameterGroups.Scriptverhalten.DefaultCorrId
            $xmlScriptNode.Registry.powershell.Wert = $hashParameterGroups.Registry.powershell
            $xmlScriptNode.Registry.RegRunKey.Wert = $hashParameterGroups.Registry.RegRunKey
            $xmlScriptNode.Registry.restartKey.Wert = $hashParameterGroups.Registry.restartKey
            $xmlScriptNode.ULS.UlsHeader.Wert = $hashParameterGroups.ULS.UlsHeader
            $xmlScriptNode.ULS.maxAgeOfULSFile.Wert = $hashParameterGroups.ULS.maxAgeOfULSFile
            $xmlScriptNode.ULS.maxSizeOfULSFile.Wert = $hashParameterGroups.ULS.maxSizeOfULSFile
            $xmlScriptNode.ULS.maxSizeOfULSDirectory.Wert = $hashParameterGroups.ULS.maxSizeOfULSDirectory
            $xmlScriptNode.Display.UseInfoHeader.Wert = $hashParameterGroups.Display.UseInfoHeader
            $xmlScriptNode.Display.InfoHeaderWidth.Wert = $hashParameterGroups.Display.InfoHeaderWidth
            $xmlScriptNode.Display.InfoHeaderSuperScription.Wert = $hashParameterGroups.Display.InfoHeaderSuperScription
            $xmlScriptNode.Display.InfoHeaderSubScription.Wert = $hashParameterGroups.Display.InfoHeaderSubScription
            $xmlScriptNode.Display.GivenBackGroundColor.Wert = $hashParameterGroups.Display.GivenBackGroundColor
            $xmlScriptNode.Display.InfoHeaderForeGroundColor.Wert = $hashParameterGroups.Display.InfoHeaderForeGroundColor
            $xmlScriptNode.Display.InfoHeaderBackGroundColor.Wert = $hashParameterGroups.Display.InfoHeaderBackGroundColor
            $xmlScriptNode.Display.DisplayForeGroundColor_Normal.Wert = $hashParameterGroups.Display.DisplayForeGroundColor_Normal
            $xmlScriptNode.Display.DisplayForeGroundColor_Error.Wert = $hashParameterGroups.Display.DisplayForeGroundColor_Error
            $xmlScriptNode.Display.DisplayBackGroundColor_Normal.Wert = $hashParameterGroups.Display.DisplayBackGroundColor_Normal
            $xmlScriptNode.Display.DisplayBackGroundColor_Error.Wert = $hashParameterGroups.Display.DisplayBackGroundColor_Error
            $xmlScriptNode.Display.DisplayFrameChar.Wert = $hashParameterGroups.Display.DisplayFrameChar
            #endregion
            #region Schreibe XML-Config-File
            Save-SPEXmlDocumentObjectAsUTF8 -XmlDocumentObject $XMLConfigDoc -Path $SPEVars.ConfigXMLFile
            $XMLConfigDoc = $null
            #endregion
            #region Öffnen des Windows-Explorers
            $ExplorePath = $StringWorkingDir 
            explorer $ExplorePath
            #endregion
            #region Abschliessende Ausgabe
            Show-SPETextLine -text "PowerShell-Script '$($Input_ScriptName + ".ps1")' wurde erfolgreich erstellt und unter '$StringWorkingDir' abgelegt."
            #endregion
        }
        End
        {
            #region Zurückschreiben der ursprünglichen Werte und Parameter
            $global:LogToConsole = $oldValues.LogToConsole;
            $global:LogToLogFile = $oldValues.LogToLogFile;
            $global:LogToULSFile = $oldValues.LogToULSFile;
            $global:ReportToFile = $oldValues.ReportToFile;
            $global:ReportToULS = $oldValues.ReportToULS;
            $global:UseInfoHeader = $oldValues.UseInfoHeader;
            $global:RunAsAdmin = $oldValues.RunAsAdmin;
            $global:ULsHeader = $oldValues.ULsHeader;
            $global:maxAgeOfULSFile = $oldValues.maxAgeOfULSFile;
            $global:maxSizeOfULSFile = $oldValues.maxSizeOfULSFile;
            $global:maxSizeOfULSDirectory = $oldValues.maxSizeOfULSDirectory;
            $global:InfoHeaderWidth = $oldValues.InfoHeaderWidth;
            $global:InfoHeaderSuperScription = $oldValues.InfoHeaderSuperScription;
            $global:InfoHeaderSubScription = $oldValues.InfoHeaderSubScription;
            $global:GivenBackGroundColor = $oldValues.GivenBackGroundColor;
            $global:InfoHeaderForeGroundColor = $oldValues.InfoHeaderForeGroundColor;
            $global:InfoHeaderBackGroundColor = $oldValues.InfoHeaderBackGroundColor;
            $global:DisplayForeGroundColor_Normal = $oldValues.DisplayForeGroundColor_Normal;
            $global:DisplayForeGroundColor_Error = $oldValues.DisplayForeGroundColor_Error;
            $global:DisplayBackGroundColor_Normal = $oldValues.DisplayBackGroundColor_Normal;
            $global:DisplayBackGroundColor_Error = $oldValues.DisplayBackGroundColor_Error;
            $global:DisplayFrameChar = $oldValues.DisplayFrameChar;
            $global:ActivateTestLoggingVerbose = $oldValues.ActivateTestLoggingVerbose;
            $global:ActivateTestLoggingException = $oldValues.ActivateTestLoggingException;
            $global:ActivateTestLogging = $oldValues.ActivateTestLogging;
            $oldValues = $null
            #endregion
            $global:SPEGeneratorActive = $null
            $error
        }
    }
    #endregion
    #EndOfFunction

    #region Function Get-SPEConfig
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Get-SPEConfig
    {
        [CmdletBinding()]
        param(
            [String]$ScriptName
        )
        Begin{
            $pathToConfig = $SPEVars.ConfigXMLFile
            [xml]$config = Get-Content $pathToConfig
        }
        Process
        {
            if([String]::IsNullOrEmpty($ScriptName))
            {
                $ScriptName = "Default"
            }

            #region Auslesen und Schreiben der Standard-Variablen - Iterativ
            foreach($VariableBlockXML in $config.SPE_Config.($ScriptName).ChildNodes){
                if($VariableBlockXML.LocalName -ne "ScriptVariablen")
                {
                    foreach($VariableXML in $VariableBlockXML.ChildNodes)
                    {
                        Set-SPEVariable -VariableName $VariableXML.LocalName -CommandString $VariableXML.Wert
                    }
                }
            }
            #endregion
            #region Auslesen und Schreiben der Script-spezifischen Variablen
            if($ScriptName -ne "Default")
            {
                foreach($VariableXML in $config.SPE_Config.($ScriptName).ScriptVariablen.ChildNodes)
                {
                    Set-SPEVariable -VariableName $VariableXML.LocalName -CommandString $VariableXML.Wert
                }
            }
            #endregion
        }
        End{
            $config = $null
        }
    }
    #endregion
    #EndOfFunction

    #region Code-Snippets für SPE Standard Scripts

$global:FullScriptCode1 = @'
param(
    [String]$WorkingDir,
    [Switch]$DoNotDisplayConsole
)
#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
[line_Company]
[line_Customer]
# Powershell-Script                                                   #
# #####################################################################
[line_ScriptName]
'@
$global:FullScriptCode2 = @'
#######################################################################
# Versionsverlauf:                                                    #
#######################################################################
# Ver. | Autor      | Änderungen                         | Datum      #
#######################################################################
# 0.1  | [UserName] | Erst-Erstellung                    | [line_dat] #
######################################################################>
#endregion

#region Voreinstellungen !!! Nicht ändern !!!

	#region Startzeit
	$global:starttime = get-date
	#endregion

    #region Wechsle in Arbeitsverzeichnis, wenn gesetzt
    if($WorkingDir){
        set-location $WorkingDir
    }
    #endregion
    #region Globale Variablen
        #region Erfassen des Scriptnamens zur Erstellung von Log- und Statusfile
            $global:ScriptName = ($MyInvocation.MyCommand.Name -replace ".ps1","")
            $global:ThisScript = ($MyInvocation.MyCommand.Definition)
        #endregion
        # ComputerName
            $global:computerName = ($env:COMPUTERNAME)
            
        #region Verzeichnispfade
            $global:PathWorkingDir = Get-Location
            $global:StringWorkingDir = $PathWorkingDir.ToString() + "\"
            $global:dirLog = $StringWorkingDir + "Log\"
            $global:dirRep = $StringWorkingDir + "Reports\"
            $ModuleToLoad = "SamsPowerShellEnhancements"
            $dirModule = $StringWorkingDir + $ModuleToLoad + ".psd1"
        #endregion
    #endregion
    #region Laden des SPEModule
        Import-Module -Name $ModuleToLoad
    #endregion
    #region Laden der Config
        Get-SPEConfig -ScriptName $ScriptName
    #endregion
    #region ConsoleTitle mit Scriptnamen versehen
    $oldConsoleTitle = Set-SPEConsoleTitle -newTitle "Aktuelles Script: $ScriptName"
    #endregion
    #region Add SharePoint PowerShell Snapin
    if($global:UsingSharePoint){
        if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) {
            Add-PSSnapin Microsoft.SharePoint.Powershell -ErrorAction SilentlyContinue
        }
    }
    #endregion
	#region ScriptStatus
	$scriptCorrId = $global:DefaultCorrID
	$global:CorrelationId = $scriptCorrId
	Write-SPELogMessage -message "Script has started." -level "High"
	Write-SPEReportMessage -level "High" -area "Script" -category "Started" -message "Script has started." -CorrelationId $scriptCorrId
	$global:scriptaborted = $false
	$global:foundErrors = $false
	#endregion


    #region Warnmeldungen

        #region Warnung, falls TestModus aktiviert ist
        if($TestModus -eq $true){
            Write-SPELogMessage -message "!!!Achtung!!! TestModus aktiv !!! Es werden keine Daten gelöscht oder geschrieben !!!"
            Write-SPELogMessage -message "!!! Dient nur zum reinen Funktionstest !!!"
        }
        #endregion
        #region Warnung, falls Logging auf Console deaktiviert ist
        if(!$LogToConsole){
            Write-Host "Logging auf Console ist deaktiviert." -ForegroundColor DarkYellow
            if($LogToLogFile){
                Write-Host "Logging erfolgt in Logfile. `nLogfile wird am Ende des Scripts geöffnet.`n" -ForegroundColor DarkYellow
            }
            if($LogToULSFile){
                Write-Host "Logging erfolgt in ULSfile. `nULSfile Bitte mit dem ULSViewer prüfen.`n" -ForegroundColor DarkYellow
            }
        }
        #endregion
    #endregion
    #region Prüfe Console auf Ausführung "als Administrator"
    if($global:RunAsAdmin)
    {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.windowsIdentity]::GetCurrent())
        if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
            $argumentList = "$ThisScript -workingDir $StringWorkingDir"
            start-process powershell -ArgumentList $argumentList -Verb RunAs
            Wait-SPELoop -text "Das Script muss mit Administrator-Berechtigungen ausgeführt werden und wurde daher in einem neuen Konsolen-Fenster neu gestartet. Dieses Fenster wird geschlossen." -time 10
            Stop-Process $PID
        }
    }
    #endregion

#endregion
Exit-SPEOnCtrlC
while($true)
{

#region Hauptprogramm !!! Hier kann gearbeitet werden !!!


#endregion

break
}
Trap [ExecutionEngineException]{
    Write-SPELogMessage -level High -CorrelationId $scriptCorrId -message "Script terminated by Ctrl-C."
    $global:scriptaborted = $true
    #region Auszuführender Code nach manuellem Abbruch durch Ctrl-C
    if(!$DoNotDisplayConsole){
        Show-SPETextLine -text "Script wurde durch Ctrl-C abgebrochen!" -fgColor Red -bgColor White
        $resetConsoleTitle = Set-SPEConsoleTitle -newTitle $oldConsoleTitle
        Wait-SPEForKey
    }
    continue
    #endregion
}

#region End of Script and opening of the script's logfile
	
	if($global:scriptaborted) {
		Write-SPEReportMessage -level "Critical" -area "Script" -category "Aborted" -message "Script has been aborted. Check Log(s)" -CorrelationId $scriptCorrId
		Write-SPELogMessage -level "Critical" -area "Script" -category "Aborted" -message "Script has been aborted. Check Log(s)" -CorrelationId $scriptCorrId
    } elseif($global:foundErrors){
		Write-SPEReportMessage -level "High" -area "Script" -category "Stopped" -message "Script has finished with errors. Check Log(s)" -CorrelationId $scriptCorrId
		Write-SPELogMessage -level "High" -area "Script" -category "Stopped" -message "Script has finished with errors. Check Log(s)" -CorrelationId $scriptCorrId
	} else {
		Write-SPEReportMessage -message "Script has successfully finished without any error." -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
		Write-SPELogMessage -message "Script has successfully finished without any error." -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
	}

	if($TestMode){
        Wait-SPEForKey
    }
    if($LogToLogFile){
        notepad.exe $PathToLogfile
    }
#endregion
#EndOfFile
'@
$global:XMLConfigDefault = '<?xml version="1.0"?>
<SPE_Config Beschreibung="Diese XML-Datei enthält die Konfigurationseinstellungen für SPE-Standard-Scripts.">
	<Default>
		<ScriptVariablen Beschreibung="Hier werden Script-spezifische Variablen deklariert.">
			<VariableName>
				<Beschreibung>Das ist eine Beispiel-Variable</Beschreibung>
				<Wert>"DemoWert"</Wert>
			</VariableName>
		</ScriptVariablen>
		<Pfade Beschreibung="Hier werden Pfade zur Dateien oder Ordnern hinterlegt">
			<PathToSharePointDLLs>
				<Beschreibung>Berechneter Pfad zu den SharePoint-DLLs</Beschreibung>
				<Wert>$StringWorkingDir + "SharePointDLLs\"</Wert>
			</PathToSharePointDLLs>
			<dirLog>
				<Beschreibung>Pfad zu dem Log-Verzeichnis</Beschreibung>
				<Wert>"C:\SPE_Scripts\Logs\"</Wert>
			</dirLog>
		</Pfade>
		<Logging Beschreibung="Hier wird das Logging-Verhalten der SPE-Scripts definiert.">
			<LogToConsole>
				<Beschreibung>Aktiviert das Logging auf die Console</Beschreibung>
				<Wert>$false</Wert>
			</LogToConsole>
			<LogToLogFile>
				<Beschreibung>Aktiviert das Logging in die Logdatei</Beschreibung>
				<Wert>$false</Wert>
			</LogToLogFile>
			<LogToULSFile>
				<Beschreibung>Aktiviert das Logging in die ULS-Datei</Beschreibung>
				<Wert>$true</Wert>
			</LogToULSFile>
			<ReportToFile>
				<Beschreibung>Aktiviert das Reporting in eine einfache Text-Datei</Beschreibung>
				<Wert>$false</Wert>
			</ReportToFile>
			<ReportToULS>
				<Beschreibung>Aktiviert das Reporting in eine ULS-konforme Datei</Beschreibung>
				<Wert>$true</Wert>
			</ReportToULS>
            <ActivateTestLoggingVerbose>
                <Beschreibung>Wenn auf TRUE gesetzt, werden erweiterte Status-Meldungen aus den Module-Cmdlets ins Log geschrieben.</Beschreibung>
                <Wert>$true</Wert>
            </ActivateTestLoggingVerbose>
            <ActivateTestLoggingException>
                <Beschreibung>Wenn auf TRUE gesetzt, werden erweiterte Exception-Meldungen aus den Module-Cmdlets ins Log geschrieben.</Beschreibung>
                <Wert>$true</Wert>
            </ActivateTestLoggingException>
            <ActivateTestLogging>
                <Beschreibung>Wenn auf TRUE gesetzt, werden erweiterte Logging-Meldungen aus den Module-Cmdlets ins Log geschrieben.</Beschreibung>
                <Wert>$true</Wert>
            </ActivateTestLogging>
		</Logging>
		<Scriptverhalten Beschreibung="Hier wird definiert, ob ein Script im Test-Modus und/oder mit Administrator-Berechtigungen auszuführen ist.">
			<TestModus>
				<Beschreibung>Aktiviert den TestModus, um z.B. Löschfunktionen im Testbetrieb vorerst zu deaktivieren</Beschreibung>
				<Wert>$false</Wert>
			</TestModus>
            <UsingSharePoint>
                <Beschreibung>legt fest, ob das SharePoint PowerShell Snappin geladen werden soll.</Beschreibung>
                <Wert>$false</Wert>
            </UsingSharePoint>
			<RunAsAdmin>
				<Beschreibung>prüft, ob das Script in einer Console mit Administrator-Berechtigungen ausgeführt wird. Falls nicht wird das Script in einer neuen Console mit Administrator-Berechtigungen neugestartet.</Beschreibung>
				<Wert>$true</Wert>
			</RunAsAdmin>
			<DefaultCorrId>
				<Beschreibung>GUID als initiale Correlation ID für ULS-Dateien</Beschreibung>
				<Wert>[Guid]"00000001-0000-0000-0000-000000000000"</Wert>
			</DefaultCorrId>
		</Scriptverhalten>
		<Registry Beschreibung="Hier sind Parameter für die Registry-Cmdlets hinterlegt.">
			<powershell>
				<Beschreibung>lokaler Pfad zur Powershell.exe</Beschreibung>
				<Wert>(Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe")</Wert>
			</powershell>
			<RegRunKey>
				<Beschreibung>lokaler Pfad zur Powershell.exe</Beschreibung>
				<Wert>"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"</Wert>
			</RegRunKey>
			<restartKey>
				<Beschreibung>Name des für den Autostart zu setzenden Registry-Keys</Beschreibung>
				<Wert>"SPE_Restart"</Wert>
			</restartKey>
		</Registry>
		<ULS Beschreibung="Hier wird das ULS-Logging definiert.">
			<UlsHeader>
				<Beschreibung>ULS-File-Header. Abstände nicht verändern, sonst ist die ganze ULs-Datei nicht vom ULS-Viewer lesbar.</Beschreibung>
				<Wert>"Timestamp              	Process                                 	TID   	Area                          	Category                      	EventID	Level     	Message 	Correlation"</Wert>
			</UlsHeader>
			<maxAgeOfULSFile>
				<Beschreibung>Ist das Erstelldatum des aktuellen ULSFiles älter als hier angegeben, wird ein neues erstellt.</Beschreibung>
				<Wert>New-TimeSpan -Minutes 15</Wert>
			</maxAgeOfULSFile>
			<maxSizeOfULSFile>
				<Beschreibung>Ist das aktuelle ULSFile größer als hier angegeben, wird ein neues erstellt.</Beschreibung>
				<Wert>"10MB"</Wert>
			</maxSizeOfULSFile>
			<maxSizeOfULSDirectory>
				<Beschreibung>Ist der Inhalt des jeweiligen ULS-Verzeichnisses größer als hier angegeben, wird das jeweils älteste File gelöscht.</Beschreibung>
				<Wert>"1GB"</Wert>
			</maxSizeOfULSDirectory>
		</ULS>
		<Display Beschreibung="Hier wird die Display-Ausgabe für die Console definiert.">
			<UseInfoHeader>
				<Beschreibung>Switch zur Festlegung, ob Log-Meldungen auf Console mit oder ohne InfoHeader dargestellt werden sollen.</Beschreibung>
				<Wert>$true</Wert>
			</UseInfoHeader>
			<InfoHeaderWidth>
				<Beschreibung>Breite des InfoHeaders</Beschreibung>
				<Wert>"54"</Wert>
			</InfoHeaderWidth>
			<InfoHeaderSuperScription>
				<Beschreibung>Inhalt des oberen InfoHeader-Blocks</Beschreibung>
				<Wert>"MT AG Ratingen"</Wert>
			</InfoHeaderSuperScription>
			<InfoHeaderSubScription>
				<Beschreibung>Inhalt des unteren InfoHeader-Blocks</Beschreibung>
				<Wert>"Beschreibender Text zum Script"</Wert>
			</InfoHeaderSubScription>
			<GivenBackGroundColor>
				<Beschreibung>Gegebene BackgroundColor</Beschreibung>
				<Wert>"$Host.UI.RawUI.BackgroundColor"</Wert>
			</GivenBackGroundColor>
			<InfoHeaderForeGroundColor>
				<Beschreibung>Schriftfarbe des InfoHeaders</Beschreibung>
				<Wert>"Green"</Wert>
			</InfoHeaderForeGroundColor>
			<InfoHeaderBackGroundColor>
				<Beschreibung>Hintergrundfarbe des InfoHeaders</Beschreibung>
				<Wert>"DarkCyan"</Wert>
			</InfoHeaderBackGroundColor>
			<DisplayForeGroundColor_Normal>
				<Beschreibung>Schriftfarbe der Ausgabe nach dem Infoheader für normale Meldungen</Beschreibung>
				<Wert>"Yellow"</Wert>
			</DisplayForeGroundColor_Normal>
			<DisplayForeGroundColor_Error>
				<Beschreibung>Schriftfarbe der Ausgabe nach dem Infoheader für Fehler- oder kritische Meldungen</Beschreibung>
				<Wert>"Red"</Wert>
			</DisplayForeGroundColor_Error>
			<DisplayBackGroundColor_Normal>
				<Beschreibung>Schriftfarbe der Ausgabe nach dem Infoheader für normale Meldungen</Beschreibung>
				<Wert>$GivenBackGroundColor</Wert>
			</DisplayBackGroundColor_Normal>
			<DisplayBackGroundColor_Error>
				<Beschreibung>Schriftfarbe der Ausgabe nach dem Infoheader für Fehler- oder kritische Meldungen</Beschreibung>
				<Wert>"White"</Wert>
			</DisplayBackGroundColor_Error>
			<DisplayFrameChar>
				<Beschreibung>Char mit dem der InfoHeader text-grafisch aufgebaut wird</Beschreibung>
				<Wert>"#"</Wert>
			</DisplayFrameChar>
		</Display>
	</Default>
</SPE_Config>
'

    #endregion
    #region Globale Variablen zur Konfiguration von New-SPEStandardScript

    $global:SPEvars = @{
        "LogToConsole" = $false;
        "LogToLogFile" = $false;
        "LogToULSFile" = $true;
        "ReportToFile" = $false;
        "ReportToULS" = $false;
        "UseInfoHeader" = $true;
        "RunAsAdmin" = $true;
        "ScriptFolder" = "C:\SPE_Scripts\";
        "LogFolder" = "C:\SPE_Scripts\Logs\";
        "ConfigXMLFile" = "C:\SPE_Scripts\SPEConfig.xml";
        "ULsHeader" = "Timestamp              	Process                                 	TID   	Area                          	Category                      	EventID	Level     	Message 	Correlation";
        "maxAgeOfULSFile" = New-TimeSpan -Minutes 15;
        "maxSizeOfULSFile" = 10MB;
        "maxSizeOfULSDirectory" = 1GB;
        "InfoHeaderWidth" = 54;
        "InfoHeaderSuperScription" = "Sams PowerShell Enhancements - Generator für SPE-Standard-Scripts";
        "InfoHeaderSubScription" = "Dieses Script erzeugt ein neues SPE-Standard-Script in den Ordner 'C:\SPE_Scripts'. Ist das erstellte Script das erste in diesem Ordner, wird automatisch ein Config-Script hinzugefügt.";
        "GivenBackGroundColor" = $Host.UI.RawUI.BackgroundColor;
        "InfoHeaderForeGroundColor" = "Green";
        "InfoHeaderBackGroundColor" = "DarkCyan";
        "DisplayForeGroundColor_Normal" = "Yellow";
        "DisplayForeGroundColor_Error" = "Red";
        "DisplayBackGroundColor_Normal" = "Blue";
        "DisplayBackGroundColor_Error" = "White";
        "DisplayFrameChar" = "#";
        "ActivateTestLoggingVerbose" = $true;
        "ActivateTestLoggingException" = $true;
        "ActivateTestLogging" = $true;
    }

    #endregion
#endregion

#region Functions for TextFile Manipulation

    #region Function Switch-SPEASCIIStringToCharInTextFile
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Switch-SPEASCIIStringToCharInTextFile {
        [CmdletBinding()]
        param
        (
            [Parameter(Position=0, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [String]
            $Path,
            [Parameter(Position=1, Mandatory=$true)]
		    [ValidateNotNullOrEmpty()]
            [System.Collections.ArrayList]
            $filterArrayList
        )

        begin {
        }

        process {
            if(get-item $Path)
            {
                $newFileLines = new-Object System.Collections.ArrayList
                $sr = New-Object System.IO.StreamReader $Path
                $lineCnt = 0
                while(!$sr.EndOfStream)
                {
                    $lineCnt++
                    $line = $sr.ReadLine()
                    $oldLine = $line
                    $writeNewLine = $false
                    if($line -ne "" -and $line -ne $null)
                    {
                        $writeNewLine = $true
                        $message = "Zeile :$lineCnt, "
                        foreach($filterPair in $filterArrayList){
                            $src = $filterPair.First
                            $trg = $filterPair.Second
                            $line = $line.Replace($src, $trg)
                        }
                        $newLine = $line
                    }
                    $newFileLines.Add($newline) | Out-Null
                }
                $sr.Close()
                foreach($line in $newFileLines)
                {
                    $line >> $Path
                }
            } else {
                if($global:ActivateTestLoggingException){Write-SPELogMessage -message "Fehler in Function 'Switch-SPEASCIIStringToCharInTextFile': Source-File konnte unter Pfad '$sourcePath' nicht gefunden werden."}
            }
        }

        end{
        }
    }
    #endregion
    #EndOfFunction

#endregion

#endregion 

#EndOfFile