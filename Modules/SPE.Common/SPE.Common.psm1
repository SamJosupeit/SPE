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
# 2.1  | S.Krieger  | Erweiterungen                   ab | 24.11.2016 #  
######################################################################>
#endregion

#region new Functions
#endregion

#region Function Template
<#
Function Do-SPETemplate{
    [CmdletBinding()]
    param()
    Begin{
        $Logcst = "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand)"
    }
    Process{
        try{

        } catch {
	        $info = "put additional information here"
            lx -Stack $_ -Category -info $info
            $global:foundErrors = $true
        }
    }
    End{}
}
#>
#endregion

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
	            $info = "Function: $($MyInvocation.MyCommand) - " + $($SPEResources.("Get-SPEADUsersFromADContainerErrorInfo"))
	            Push-SPEException -Category "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)" -exMessage $exMessage -innerException $innerException -info $info
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

   
    #region Function Wait-SPEForKey
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Wait-SPEForKey
    {
        [CmdletBinding()]
        param()
        begin{}

        process {
			Write-Host $($SPEResources.("Wait-SPEForKey")) -ForegroundColor Green
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
                        $($SPEResources.("Get-SPECurrentUsersNames1")),
                        $($SPEResources.("Get-SPECurrentUsersNames2")),
                        $($SPEResources.("Get-SPECurrentUsersNames3"))
                    )
                    Wait-SPEForKey
                    $manualDisplayName = Show-SPEQuestion -text $($SPEResources.("Get-SPECurrentUsersNames4"))
                    $manualGivenName = Show-SPEQuestion -text $($SPEResources.("Get-SPECurrentUsersNames5"))
                    $manualSN = Show-SPEQuestion -text $($SPEResources.("Get-SPECurrentUsersNames6"))
                    $outObj | Add-Member -NotePropertyName "DisplayName" -NotePropertyValue $objUser.displayName
                    $outObj | Add-Member -NotePropertyName "GivenName" -NotePropertyValue $objUser.givenName
                    $outObj | Add-Member -NotePropertyName "SurName" -NotePropertyValue $objUser.sn
                    return $outObj

                }
                if($global:ActivateTestLoggingException)
                {
	                $exMessage = $_.Exception.Message
	                $innerException = $_.Exception.InnerException
	                $info = "Function: $($MyInvocation.MyCommand) - " + "Function: $($MyInvocation.MyCommand) - " + $($SPEResources.("Get-SPECurrentUsersNames7"))
	                Push-SPEException -Category "$($MyInvocation.MyCommand.ModuleName)_$($MyInvocation.MyCommand.Name)" -exMessage $exMessage -innerException $innerException -info $info
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
                throw (new-object ExecutionEngineException $($SPEResources.("Exit-SPEOnCtrlC")))
            }
        }
    }
    #endregion
    #EndOfFunction

    #region Function Reset-SPEModule
    <#
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Reset-SPEModule
    {
        [CmdletBinding()]
        param(
            [String]$ModuleName="SPE.Common"
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
    #>
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

    #region Function Edit-SPEScript
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Edit-SPEScript
    {
        [CmdletBinding()]
        param()
        Begin{
            $continue = $true;
            $path = "c:\spe_scripts";
            $folder = get-item $path;
            $scripts = $folder.GetFiles() | ?{$_.Extension -eq ".ps1"};
            $scriptsHT = new-object psobject
            $scriptCnt = 0
            foreach($script in $scripts)
            {
                $scriptsHT | Add-Member -MemberType NoteProperty -Name $($SPE_ChoiceChars[$scriptCnt]) -Value $script | Out-Null
                $scriptCnt++
            }
        }
        Process
        {
            do{
                Set-SPEFocusOnCurrentConsoleWindow
                clear
                $outputText = New-Object System.Collections.ArrayList
                $outputText.Add($($SPEResources.("Edit-SPEScript1"))) | out-null
                $outputText.Add("") | out-null
                $choices = "";
                for ($i = 0; $i -lt ($scripts.Length); $i++)
                {
                    $scriptName = $scripts[$i].Name
                    $newString = $SPE_ChoiceChars[$i] + " - $scriptName"
                    $outputText.Add($newString) | out-null
                    if($i -eq 0)
                    {
                        $choices += $SPE_ChoiceChars[$i]
                    } else {
                        $choices += "," + $SPE_ChoiceChars[$i]
                    }
                }
                $outputText.Add("") | out-null
                $outputText.Add($SPE_ChoiceChars[-6] + " - " + $($SPEResources.("Edit-SPEScript2"))) | Out-Null
                $outputText.Add($SPE_ChoiceChars[-5] + " - " + $($SPEResources.("Edit-SPEScript3"))) | Out-Null
                $outputText.Add($SPE_ChoiceChars[-4] + " - Config.xml") | Out-Null
                $outputText.Add($SPE_ChoiceChars[-3] + " - Resources.xml") | Out-Null
                $outputText.Add($SPE_ChoiceChars[-2] + " - " + $($SPEResources.("Edit-SPEScript4"))) | Out-Null
                $outputText.Add($SPE_ChoiceChars[-1] + " - " + $($SPEResources.("Edit-SPEScript5"))) | Out-Null
                $choices += "," + $SPE_ChoiceChars[-6] + "," + $SPE_ChoiceChars[-5] + "," + $SPE_ChoiceChars[-4] + "," + $SPE_ChoiceChars[-3] + "," + $SPE_ChoiceChars[-2] + "," + $SPE_ChoiceChars[-1] + ""
                $outputText.Add("") | out-null
                $outputText.Add($($SPEResources.("Edit-SPEScript6"))) | out-null
                $outputText.Add("") | out-null
                $toggle = $true
                foreach($line in $outputText){
                    if($toggle){
                        $color = "White"
                        $toggle = $false
                    } else {
                        $color = "Yellow"
                        $toggle = $true
                    }
                    Write-Host $line -ForegroundColor $color
                }
                $choice = Use-SPEChoice -Choices $choices
                if($choice -eq $SPE_ChoiceChars[-1]){
                    $continue = $false
                } elseif($choice -eq $SPE_ChoiceChars[-6]){
                    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe" "$path\Modules\SPE.Common\SPE.Common.psm1"
                } elseif($choice -eq $SPE_ChoiceChars[-5]){
                    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe" "$path\Modules\SPE.SharePoint\SPE.SharePoint.psm1"
                } elseif($choice -eq $SPE_ChoiceChars[-4]){
                    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe" "$path\SPEConfig.xml"
                } elseif($choice -eq $SPE_ChoiceChars[-3]){
                    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe" "$path\SPEResources.xml"
                } elseif($choice -eq $SPE_ChoiceChars[-2]){
                    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe" "$path\Modules\SPE.Common\SPE.Common.psm1,$path\Modules\SPE.SharePoint\SPE.SharePoint.psm1,$path\SPEConfig.xml,$path\SPEResources.xml"
                } else {
                    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe" ($scriptsHT.$choice.FullName)
                }
            }until($continue -eq $false)
        }
    }
    #endregion
    #EndOfFunction

    #region Function Start-SPEScript
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Start-SPEScript
    {
        [CmdletBinding()]
        param()
        Begin{
            $continue = $true;
            $path = "c:\spe_scripts";
            $folder = get-item $path;
            $scripts = $folder.GetFiles() | ?{$_.Extension -eq ".ps1"};
        }
        Process
        {
            do{
                clear
                $outputText = New-Object System.Collections.ArrayList
                $outputText.Add($($SPEResources.("Start-SPEScript1"))) | out-null
                $outputText.Add("") | out-null
                $choices = "";
                for ($i = 0; $i -lt ($scripts.Length); $i++)
                {
                    $scriptName = $scripts[$i].Name
                    $newString = $SPE_ChoiceChars[$i] + " - $scriptName"
                    $outputText.Add($newString) | out-null
                    if($i -eq 0)
                    {
                        $choices += $SPE_ChoiceChars[$i]
                    } else {
                        $choices += "," + $SPE_ChoiceChars[$i]
                    }
                }
                $outputText.Add($SPE_ChoiceChars[-1] + " - " + $($SPEResources.("Start-SPEScript2"))) | Out-Null
                $choices += "," + $SPE_ChoiceChars[-1]
                $outputText.Add("") | out-null
                $outputText.Add($($SPEResources.("Start-SPEScript3"))) | out-null
                $outputText.Add("") | out-null
                $toggle = $true
                foreach($line in $outputText){
                    if($toggle){
                        $color = "White"
                        $toggle = $false
                    } else {
                        $color = "Yellow"
                        $toggle = $true
                    }
                    Write-Host $line -ForegroundColor $color
                }
                $choice = Use-SPEChoice -Choices $choices
                if($choice -eq $SPE_ChoiceChars[-1]){
                    exit
                } else {
                    start-process powershell -ArgumentList ($scripts[$choice].FullName)
                    Write-Host $($SPEResources.("Start-SPEScript4"))
                    $continue = Select-SPEYN
                }
            }until($continue -eq $false)
        }
    }
    #endregion
    #EndOfFunction

    #region Function Set-SPEFocusOnCurrentConsoleWindow
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Set-SPEFocusOnCurrentConsoleWindow
    {
        [CmdletBinding()]
        param()
        Begin{}
        Process{
            Add-Type '
                using System;
                using System.Runtime.InteropServices;
                public class WindowControl {
                    [DllImport("user32.dll")]
                    [return: MarshalAs(UnmanagedType.Bool)]
                    public static extern bool SetForegroundWindow(IntPtr hWnd);
                }
            ';
            $windowHandle = Get-Process | ?{$_.Id -eq $PID} | Select-Object -ExpandProperty MainWindowHandle;
            if($windowHandle){
                sleep 1
                [WindowControl]::SetForegroundWindow(($windowHandle | Select-Object -First 1));
            }
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Get-SPEResource
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Get-SPEResource
    {
        [CmdletBinding()]
        param()
        Begin{
            $pathToResources = $SPEVars.ResourcesXMLFile
            [xml]$resources = Get-Content $pathToResources
            $curCulture = (Get-Culture).Name
            $cultureFallback = "en-US"
        }
        Process{
            #region get current culture or fallback (en-us)
            $cultureFound = $false
            foreach($cultureBlock in $resources.SPE_Resources.ChildNodes){
                if($cultureBlock.LocalName -eq $curCulture){
                    $culture = $curCulture
                    $cultureFound = $true
                    break
                }
            }
            if(!$cultureFound){
                $culture = $cultureFallback
            }
            #endregion

            #region process culture resources
            $resourcesObject = New-Object psobject
            foreach($resource in $resources.SPE_Resources.($culture).ChildNodes){
                $name = $resource.LocalName
                $value = $resource.InnerText
                $resourcesObject | Add-Member -NotePropertyName $name -NotePropertyValue $value
                $resource = $null
            }
            $resources = $null # just to release memory
            $global:SPEResources = $resourcesObject
            $resourcesObject = $null
            #endregion
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Get-SPELocalTime
    Function Get-SPELocalTime{
        [CmdletBinding()]
        param(
            $UTCTime
        )
        Begin{}
        Process{
            $LocalTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, [System.TimeZoneInfo]::Local)
            Return $LocalTime
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Compare-SPETimeStrings
    Function Compare-SPETimeStrings{
        [CmdletBinding()]
        param(
            [String]$DateTimeString1,
            [String]$DateTimeString2
        )
        Begin{}
        Process{
            #region convert String 1
            try{
                $DateTimeObject1 = [DateTime]$DateTimeString1
            } catch{
                try{
                    $DateTimeObject1 = [System.Convert]::ToDateTime($DateTimeString1)
                } catch {
                    return $null
                }
            }
            try{
                $UTCTime1 = Get-SPELocalTime -UTCTime $DateTimeObject1
            } catch {
                $UTCTime1 = $DateTimeObject1
            }
            #endregion
            #region convert String 2
            try{
                $DateTimeObject2 = [DateTime]$DateTimeString2
            } catch{
                try{
                    $DateTimeObject2 = [System.Convert]::ToDateTime($DateTimeString2)
                } catch {
                    return $null
                }
            }
            try{
                $UTCTime2 = Get-SPELocalTime -UTCTime $DateTimeObject2
            } catch {
                $UTCTime2 = $DateTimeObject2
            }
            #endregion
            #region compare and return
            return ($UTCTime1 -eq $UTCTime2)
            #endregion
        }
        End{}
    }
    #endregion
    #EndOfFunction

#endregion

#region Functions for PSRemoting
    
    #region Function Invoke-SPECommand
    Function Invoke-SPECommand{
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true, Position=0)][string]$Command,
            [System.Management.Automation.Runspaces.PSSession]$PSSession=$Global:Session
        )
        Begin{}
        Process{
            $scriptBlock = ConvertTo-SPEScriptblock -string $Command
            #$result = 
            Invoke-Command $PSSession $scriptBlock
            #return $result
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function ConvertTo-SPEScriptblock
    Function ConvertTo-SPEScriptblock  {
        [CmdletBinding()]
	    Param(
            [Parameter(Mandatory = $true)][string]$string 
        )
        Begin{}
        Process{
           $scriptBlock = [scriptblock]::Create($string)
           return $scriptBlock
        }
        End{}
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
            [Parameter(Position=0)]
            [int]$width,
            [Parameter(Position=1)]
            [int]$height
        )
        Begin{}
        Process{
		    $buffer = $Host.UI.RawUI.BufferSize
            if($width){
		        $buffer.Width = $width
            }
            if($height){
		        $buffer.Height = $height
            }
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
                    Show-SPETextLine -text $($($SPEResources.("Move-SPEFileSystemFolderToZIP1")) + " " + $Target + " " + $($SPEResources.("Move-SPEFileSystemFolderToZIP2")))
                    $OverwriteZIP = Select-SPEYN
                    if($OverwriteZIP){
                        Remove-Item -Path $Target -Force
                        [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceFolder, $Target, $compressionLevel, $True)
                    }
                } else {
                    Write-Host $($($SPEResources.("Move-SPEFileSystemFolderToZIP1")) + " " + $Target + " " + $($SPEResources.("Move-SPEFileSystemFolderToZIP2")))
                    $OverwriteZIP = Select-SPEYN
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
                if($global:ActivateTestLoggingException){
                    lm -message $($($SPEResources.("Edit-SPETextFileByFilterToNewFile1")) + $sourcePath + $($SPEResources.("Edit-SPETextFileByFilterToNewFile2"))) -category $($MyInvocation.MyCommand.Name)
                }
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
            [String]$lineNumber,
            [string]$exMessage,
            [string]$innerException,
            [string]$info,
            [string]$Category
            )
        begin {}
        process
        {
            #$Category = $Category + "_Line_" + $MyInvocation.ScriptLineNumber
            $global:foundErrors = $true
            $LogMessage = $SPEResources.("LogMessageTextInfo") + $info
            lm -message $LogMessage -Level "Unexpected" -category $Category
            if($site){
                $LogMessage = $SPEResources.("LogMessageTextSite") + $site
                lm -message $LogMessage -Level "Unexpected" -category $Category
            }
            if($web){
                $LogMessage = $SPEResources.("LogMessageTextWeb") + $web
                lm -message $LogMessage -Level "Unexpected" -category $Category
            }
            if($list){
                $LogMessage = $SPEResources.("LogMessageTextList") + $list
                lm -message $LogMessage -Level "Unexpected" -category $Category
            }
            $LogMessage = $SPEResources.("LogMessageTextExMessage") + $exMessage
            lm -message $LogMessage -Level "Unexpected" -category $Category
            $innerException.split([char]10) | foreach{
                $LogMessage = $SPEResources.("LogMessageTextInnerException") + $_.Replace([String][char]13,"")
                lm -message $LogMessage -Level "Unexpected" -category $Category
            }
            $pscmdletData = $PSCmdlet
            $callString = $SPEResources.("LogMessageTextOccured")
            if($pscmdletData.MyInvocation.ScriptName){
                $callScriptname = $pscmdletData.MyInvocation.ScriptName
                $callString += $SPEResources.("LogMessageTextScript") + "'$callScriptname' "
            }
            if($lineNumber){
                $callScriptLine = $pscmdletData.MyInvocation.ScriptLineNumber
                $callString += $SPEResources.("LogMessageTextLine") + "'$lineNumber' "
            }
            elseif($pscmdletData.MyInvocation.ScriptLineNumber){
                $callScriptLine = $pscmdletData.MyInvocation.ScriptLineNumber
                $callString += $SPEResources.("LogMessageTextLine") + "'$callScriptLine' "
            }
            $callString += $SPEResources.("LogMessageTextTryBlock")
            lm -message $callString -Level "Unexpected" -category $Category
        }
    }
    #endregion
    #EndOfFunction

	#region Function Write-SPELogException
    #.ExternalHelp SPE.Common.psm1-help.xml
    function Write-SPELogException
    {
        [CmdletBinding()]
        param
        (
            [psobject]$Stack,
            [string]$info,
            [string]$Category,
            [Guid]$CorrId=$global:CorrelationId
            )
        begin {}
        process
        {
            $lineNumber = $Stack.InvocationInfo.ScriptLineNumber
            $exMessage = $Stack.Exception.Message
            $innerException = $Stack = $Stack.Exception.InnerException
            #$Category = $Category + "_Line_" + $MyInvocation.ScriptLineNumber
            $global:foundErrors = $true
            $LogMessage = $SPEResources.("LogMessageTextInfo") + $info
            lm -message $LogMessage -Level "Unexpected" -category $Category -CorrelationId $CorrId
            $LogMessage = $SPEResources.("LogMessageTextExMessage") + $exMessage
            lm -message $LogMessage -Level "Unexpected" -category $Category -CorrelationId $CorrId
            $([Convert]::ToString($innerException)).split([char]10) | foreach{
                $LogMessage = $SPEResources.("LogMessageTextInnerException") + $_.Replace([String][char]13,"")
                lm -message $LogMessage -Level "Unexpected" -category $Category -CorrelationId $CorrId
            }
            $pscmdletData = $PSCmdlet
            $callString = $SPEResources.("LogMessageTextOccured")
            if($pscmdletData.MyInvocation.ScriptName){
                $callScriptname = $pscmdletData.MyInvocation.ScriptName
                $callString += $SPEResources.("LogMessageTextScript") + "'$callScriptname' "
            }
            if($lineNumber){
                $callScriptLine = $pscmdletData.MyInvocation.ScriptLineNumber
                $callString += $SPEResources.("LogMessageTextLine") + "'$lineNumber' "
            }
            elseif($pscmdletData.MyInvocation.ScriptLineNumber){
                $callScriptLine = $pscmdletData.MyInvocation.ScriptLineNumber
                $callString += $SPEResources.("LogMessageTextLine") + "'$callScriptLine' "
            }
            $callString += $SPEResources.("LogMessageTextTryBlock")
            lm -message $callString -Level "Unexpected" -category $Category -CorrelationId $CorrId
        }
    }
    #endregion
    #EndOfFunction
    
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

    #region Function New-SPEGuid
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function New-SPEGuid
    {
        [CmdletBinding()]
        param()
        Begin{}
        Process{
            $guid = [Guid]::NewGuid()
            return $guid
        }
        End{}
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
        param(
            [ValidateSet("VerboseEx","Verbose","Medium","High","Critical","Unexpected")]
            [String]$level = "VerboseEx",
            [ValidateSet("ListView","ViewField","ListField","Script","WebSite","SiteCollection","List","ListItem","misc","other")]
            [String]$area = "Script",
            [String]$category,
            [Guid]$CorrelationId = $global:CorrelationID,
            [String]$eventId = "0000",
            [String]$process = $Global:ScriptName,
            [String]$thread = "0x05BC",
            [String]$message
        )

        begin {
			Get-SPEOrSetLogFiles
            $levelInRange = Test-SPEMaxLogLevel -level $level
        }

        process {
            if($levelInRange){
                $strCorrelationId = $CorrelationId.Guid
                $CurrentTimeStamp = Get-SPECurrentTimeForULS
                if($global:LogToConsole){
                    if($global:UseInfoHeader)
                    {
                        if($level -match "Critical" -or $level -match "High" -or $level -match "Unexpected"){
                            Show-SPETextLine -text $message -fgColor $global:DisplayForeGroundColor_Error -bgColor $global:DisplayBackGroundColor_Error
                        } else {
                            Show-SPETextLine -text $message
                        }
                        Wait-SPEForKey

                    } else {
			            Write-Host $CurrentTimeStamp -NoNewline #Ausgabe des Log-Eintrags auf Console
				        if($level -match "Critical" -or $level -match "High"-or $level -match "Unexpected"){
                            Write-Host "$message" -ForegroundColor $global:DisplayForeGroundColor_Error -BackgroundColor $global:DisplayBackGroundColor_Error
                        } else {
                            Write-Host "$message" -ForegroundColor $global:DisplayForeGroundColor_Normal -BackgroundColor $global:DisplayBackGroundColor_Normal
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
                if($global:LogToSPList){
                    $currentMessage = New-Object psobject -Property @{
                        TimeStamp = $CurrentTimeStamp
                        Process = $Global:ScriptName # Default ist $process; Um aber im SPLog die Meldung einfacher zuordnen zu können, wird hier der ScriptName genommen
                        Thread = $thread
                        Area = $area
                        Category = $category
                        EventId = $eventId
                        Level = $level
                        Message = $message
                        CorrelationId = $strCorrelationId
                    }
                    $catchOutput = Write-SPELogMessageToSharePoint -MessageObject $currentMessage
                }
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

    #region Function Test-SPEMaxLogLevel
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Test-SPEMaxLogLevel
    {
        [CmdletBinding()]
        Param(
            [String]$level
        )
        Begin{}
        Process{
            $inRange = $false
            switch($level){
                "VerboseEx"{$levelId = 1;break}
                "Verbose"{$levelId = 2;break}
                "Medium"{$levelId = 3;break}
                "High"{$levelId = 4;break}
                "Critical"{$levelId = 5;break}
                "Unexpected"{$levelId = 6;break}
            }
            switch($MaxLogLevel){
                "VerboseEx"{$maxLevelId = 1;break}
                "Verbose"{$maxLevelId = 2;break}
                "Medium"{$maxLevelId = 3;break}
                "High"{$maxLevelId = 4;break}
                "Critical"{$maxLevelId = 5;break}
                "Unexpected"{$maxLevelId = 6;break}
            }
            if(Get-Variable -Name "MinLogLevel" -ErrorAction SilentlyContinue){
                switch($MinLogLevel){
                    "VerboseEx"{$minLevelId = 1;break}
                    "Verbose"{$minLevelId = 2;break}
                    "Medium"{$minLevelId = 3;break}
                    "High"{$minLevelId = 4;break}
                    "Critical"{$minLevelId = 5;break}
                    "Unexpected"{$minLevelId = 6;break}
                }
            } else {
                $minLevelId = 1
            }
            if($levelId -le $maxLevelId -and $levelId -ge $minLevelId){
                $inRange = $true
            }
            return $inRange
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
                    $LoglineDate = "# " + $($SPEResources.("New-SPELogFiles")) + $StringDateTime
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
                    $ReportlineFile = "# " + $($SPEResources.("New-SPEReportFiles1")) + $ScriptName + ".ps1"
                    $ReportlineDate = "# " + $($SPEResources.("New-SPEReportFiles2")) + $StringDateTime
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
            lm -message $message 
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
			    # $ChosenChoice = Read-Host $ChoiceShow
                Write-Host $choiceShow
                $ChosenChoice = [Console]::ReadKey($true).KeyChar.ToString()
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
					    Write-Host $($SPEResources.("Use-SPEChoice")) -foregroundcolor Red
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
            $choiceTrue = $($SPEResources.("Select-SPEYNTrue"))
            $choiceFalse = $($SPEResources.("Select-SPEYNFalse"))
            $choicesString = $choiceTrue + "," + $choiceFalse
		    $Ask = Use-SPEChoice $choicesString
		    switch ($Ask){
			    $choiceTrue {return $true}
			    $choiceFalse {return $false}
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
	   		$SPVOICE.Speak($text) | out-null
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
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText $($($SPEResources.("New-SPEInfoHeader1")) + $startTimeString) -Width $Width -char $Char)) | Out-Null
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText $($($SPEResources.("New-SPEInfoHeader2")) + $CurrentTimeString) -Width $Width -char $Char)) | Out-Null
            $outputArray.Add((Convert-SPETextToFramedBlock -InputText $($($SPEResources.("New-SPEInfoHeader3")) + $CurrentDiffTimeString) -Width $Width -char $Char)) | Out-Null
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
	            $(" $i " + $($SPEResources.("Wait-SPELoop")))
	            )
	            Start-Sleep -Seconds 1
	        }
	    }
	}
    #endregion
    #EndOfFunction

    #region Function Show-SPEDots
    Function Show-SPEDots{
        [CmdletBinding()]
        param(
            [String]$message
        )
        Begin{
        }
        Process{
            if($message){
                if($global:dots.Length -ge ($InfoHeaderWidth - 2)){
                    $global:dots = "."
                } else {
                    $global:dots += "."
                }
                Show-SPETextArray -textArray @($message,"",$global:dots)
            }
        }
        End{}
    }
    #endregion
    
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
            if(([xml]$CheckDocument = Get-Content -Path $FilePath -ErrorAction SilentlyContinue -Encoding UTF8 ) -eq $null)
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

    #region Function Convert-SPEStringToXMLElement
    Function Convert-SPEStringToXMLElement{
        [CmdletBinding()]
        param(
            [String]$string
        )
        Begin{}
        Process{
            try{
            $xmlDoc = New-Object System.Xml.XmlDocument
            $xmlDoc.LoadXml($string)
            return $xmlDoc.FirstChild
            } catch {
                return $null
            }

        }
        End{}
    }
    #endregion
    #EndOfFunction

#endregion

#region Functions for Text Manipulation

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
                if($global:ActivateTestLoggingException){lm -message "Fehler in Function 'Switch-SPEASCIIStringToCharInTextFile': Source-File konnte unter Pfad '$sourcePath' nicht gefunden werden."}
            }
        }

        end{
        }
    }
    #endregion
    #EndOfFunction

    #region Function Convert-SPEUmlaute
    Function Convert-SPEUmlaute {
    [CmdletBinding()]
        param(
            [string]$String
        )
        Begin{}
        Process{
            $UmlautObject = New-Object PSObject | Add-Member -MemberType NoteProperty -Name Name -Value $String -PassThru
            # hash tables are by default case insensitive
            # we have to create a new hash table object for case sensitivity 
            $characterMap = New-Object System.Collections.Hashtable
            $characterMap.ä = "ae"
            $characterMap.ö = "oe"
            $characterMap.ü = "ue"
            $characterMap.ß = "ss"
            $characterMap.Ä = "Ae"
            $characterMap.Ü = "Ue"
            $characterMap.Ö = "Oe"
            foreach ($property  in 'Name') { 
                foreach ($key in $characterMap.Keys) {
                    $UmlautObject.$property = $UmlautObject.$property -creplace $key,$characterMap[$key] 
                }
            }
            return $UmlautObject.Name
        }
        End{}
    }


#endregion
    #EndOfFunction

#endregion

#region Functions for Daily Work

    #region Function Open-SPECurrentWork
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Open-SPECurrentWork{
        [CmdletBinding()]
        param(
            [Switch]$WebsitesOnly,
            [Switch]$XmlFilesOnly,
            [Switch]$PsFilesOnly
        )
        Begin{
            $path = "C:\spe_Scripts"
            $testScriptName = Get-Variable -Name "ScriptName" -ErrorAction SilentlyContinue
            $resetConfig = $false
            if($testScriptName){
                $resetConfig = $true
            }
            $ConfigBlockName = "Open-SPECurrentWork"
            Get-SPEConfig -ScriptName $ConfigBlockName
            if(!$WebsitesOnly -and !$XmlFilesOnly -and !$PsFilesOnly){
                $WebsitesOnly = $true
                $XmlFilesOnly = $true
                $PsFilesOnly = $true
            }
        }
        Process{
            if($XmlFilesOnly){
                & $($paths.notepadPlusPlus) "-nosession"
                for($i = 0; $i -lt $xmlFilesToOpen.Length; $i++){
                    & $($paths.notepadPlusPlus) $xmlFilesToOpen[$i]
                }
            }
            if($WebsitesOnly){
                $navOpenInBackgroundTab = 0x1000;
                $IE = new-object -com internetexplorer.application
                for($i = 0; $i -lt $urlsToOpen.Length; $i++){
                    if($i -eq 0){
                        $IE.navigate2($urlsToOpen[$i])
                    } else {
                        $IE.navigate2($urlsToOpen[$i], $navOpenInBackgroundTab)
                    }
                }
                $IE.visible=$true
            }
            if($PsFilesOnly){
                $ps1FilesStr = ""
                for($i = 0; $i -lt $ps1FilesToOpen.Length; $i++){
                    if($i -eq 0){
                        $ps1FilesStr += $ps1FilesToOpen[$i]
                    } else {
                        $ps1FilesStr += "," + $ps1FilesToOpen[$i]
                    }
                }
                & $($paths.ISE) $ps1FilesStr 
                & $($paths.ULSViewer) $($paths.ULSViewerParams)
            }
        }
        End{
            if($resetConfig){
                Get-SPEConfig -ScriptName $testScriptName
            }
        }
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
                "UrlToLogWeb" = $global:UrlToLogWeb;
                "LogListName" = $global:LogListName;
                "MaxLogLevel" = $global:MaxLogLevel;
                "LogToSPList" = $global:LogToSPList;
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
                $global:UrlToLogWeb = $SPEvars.UrlToLogWeb;
                $global:LogListName = $SPEvars.LogListName;
                $global:MaxLogLevel = $SPEvars.MaxLogLevel;
                $global:LogToSPList = $SPEvars.LogToSPList;
            #endregion
        }
        Process
        {

            $global:starttime = get-date
            #region Abfragen
            Show-SPETextArray -textArray @($($SPEResources.("New-SPEStandardScript1")),"")
            Wait-SPEForKey

            $Input_ScriptName = Show-SPEQuestion -text $($SPEResources.("New-SPEStandardScript2"))
            $Input_Description = Show-SPEQuestion -text $($SPEResources.("New-SPEStandardScript3"))
            Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript4"))
            if(Select-SPEYN){
                $Input_Customer = Show-SPEQuestion -text $($SPEResources.("New-SPEStandardScript5"))
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
                    "MaxLogLevel" = $XMLConfigDoc.SPE_Config.Default.Logging.MaxLogLevel.Wert.ToString();
                    "LogToConsole" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToConsole.Wert.ToString();
                    "LogToLogFile" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToLogFile.Wert.ToString();
                    "LogToULSFile" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToULSFile.Wert.ToString();
                    "LogToSPList" = $XMLConfigDoc.SPE_Config.Default.Logging.LogToSPList.Wert.ToString();
                    "ReportToFile" = $XMLConfigDoc.SPE_Config.Default.Logging.ReportToFile.Wert.ToString();
                    "ReportToULS" = $XMLConfigDoc.SPE_Config.Default.Logging.ReportToULS.Wert.ToString();
                    "ActivateTestLoggingVerbose" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLoggingVerbose.Wert.ToString();
                    "ActivateTestLoggingException" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLoggingException.Wert.ToString();
                    "ActivateTestLogging" = $XMLConfigDoc.SPE_Config.Default.Logging.ActivateTestLogging.Wert.ToString();
                    "UrlToLogWeb" = $XMLConfigDoc.SPE_Config.Default.Logging.UrlToLogWeb.Wert.ToString();
                    "LogListName" = $XMLConfigDoc.SPE_Config.Default.Logging.LogListName.Wert.ToString();
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
            $line_Company        = Convert-SPETextToFramedBlock -InputText $($SPEResources.("CreatorsCompanyName")) -width 70 -char '#'
            $line_ScriptName     = Convert-SPETextToFramedBlock -InputText ($($SPEResources.("New-SPEStandardScript7")) + $Input_ScriptName + ".ps1") -width 70 -char '#'
            $line_Description    = Convert-SPETextToFramedBlock -InputText ($($SPEResources.("New-SPEStandardScript8")) + $Input_Description) -width 70 -char '#'
            $line_ConfigDescription = Convert-SPETextToFramedBlock -InputText ($($SPEResources.("New-SPEStandardScript9")) + "$Input_ScriptName.ps1'") -width 70 -char '#'
            $line_Customer       = Convert-SPETextToFramedBlock -InputText ($($SPEResources.("New-SPEStandardScript10")) + $Input_Customer) -width 70 -char '#'
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
                #region Logging
                Show-SPETextArray -textArray ($($SPEResources.("New-SPEStandardScrip11")),"",$($SPEResources.("New-SPEStandardScript12")),"",$($SPEResources.("New-SPEStandardScript13")))
                if(!(Select-SPEYN)){
                    #region Log to SharePoint-List
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript14"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.LogToSPList = '$true'
                        $hashParameterGroups.Logging.UrlToLogWeb = (Show-SPEQuestion -text $($SPEResources.("New-SPEStandardScript15"))).ToString()
                        $hashParameterGroups.Logging.LogListName = (Show-SPEQuestion -text $($SPEResources.("New-SPEStandardScript16"))).ToString()
                    } else {
                        $hashParameterGroups.Logging.LogToSPList = '$false'
                        $hashParameterGroups.Logging.UrlToLogWeb = ""
                        $hashParameterGroups.Logging.LogListName = ""
                    }
                    #endregion
                    #region Log to Console
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript17"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.LogToConsole = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToConsole = '$false'
                    }
                    #endregion
                    #region Log To File
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript18"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.LogToLogFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToLogFile = '$false'
                    }
                    #endregion
                    #region Log to ULS
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript19"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.LogToULSFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.LogToULSFile = '$false'
                    }
                    #endregion
                    #region Report to File
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript20"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.ReportToFile = '$true'
                    } else {
                        $hashParameterGroups.Logging.ReportToFile = '$false'
                    }
                    #endregion
                    #region Report to ULS
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript21"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.ReportToULS = '$true'
                    } else {
                        $hashParameterGroups.Logging.ReportToULS = '$false'
                    }
                    #endregion
                    #region Use Infoheader
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript22"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Display.UseInfoHeader = '$true'
                    } else {
                        $hashParameterGroups.Display.UseInfoHeader = '$false'
                    }
                    #endregion
                    #region ActivateTestLogging
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript23"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.ActivateTestLogging = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLogging = '$false'
                    }
                    #endregion
                    #region ActivateTestLoggingVerbose
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript24"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.ActivateTestLoggingVerbose = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLoggingVerbose = '$false'
                    }
                    #endregion
                    #region ActivateTestLoggingException
                    Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript25"))
                    if(Select-SPEYN){
                        $hashParameterGroups.Logging.ActivateTestLoggingException = '$true'
                    } else {
                        $hashParameterGroups.Logging.ActivateTestLoggingException = '$false'
                    }
                    #endregion
                } 
                #endregion
                #region TestModus aktivieren
                Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript26"))
                if(Select-SPEYN){
                    $hashParameterGroups.Scriptverhalten.TestModus = '$true'
                } else {
                    $hashParameterGroups.Scriptverhalten.TestModus = '$false'
                }
                #endregion
                #region RunAsAdmin aktivieren
                Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript27"))
                if(Select-SPEYN){
                    $hashParameterGroups.Scriptverhalten.RunAsAdmin = '$true'
                } else {
                    $hashParameterGroups.Scriptverhalten.RunAsAdmin = '$false'
                }
                #endregion
                #region Batch-File
                Show-SPETextLine -text $($SPEResources.("New-SPEStandardScript28"))
                if(Select-SPEYN){
                    $createBatchFile = $true
                } else {
                    $createBatchFile = $false
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
            #region Erzeugen der DOS-Batch-Datei
            if($createBatchFile){
                $batchCodeBase = @'
@ECHO OFF
"C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe" /ExecutionPolicy ByPass /NoProfile /command "& {cd c:\spe_scripts; c:\spe_scripts\[ScriptName]}"
'@
                $batchCode = $batchCodeBase.Replace("[ScriptName]",$Input_ScriptName)
                $batchPath = $scriptfilePath.Replace(".ps1",".bat")
                $batchCode > $batchPath
            }
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
            $xmlScriptNode.Logging.UrlToLogWeb.Wert = $hashParameterGroups.Logging.UrlToLogWeb
            $xmlScriptNode.Logging.LogListName.Wert = $hashParameterGroups.Logging.LogListName
            $xmlScriptNode.Logging.MaxLogLevel.Wert = $hashParameterGroups.Logging.MaxLogLevel
            $xmlScriptNode.Logging.LogToSPList.Wert = $hashParameterGroups.Logging.LogToSPList
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
            Show-SPETextLine -text $($($SPEResources.("New-SPEStandardScript29")) + $($Input_ScriptName + ".ps1") + $($SPEResources.("New-SPEStandardScript30")) + $StringWorkingDir + $($SPEResources.("New-SPEStandardScript31")))
            #endregion
            #region ISE öffnen
            & "c:\windows\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe" "c:\spe_scripts\speconfig.xml,$scriptfilePath"
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
            $global:UrlToLogWeb = $oldValues.UrlToLogWeb;
            $global:LogListName = $oldValues.LogListName;
            $global:MaxLogLevel = $oldValues.MaxLogLevel;
            $global:LogToSPList = $oldValues.LogToSPList;
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
                if($VariableBlockXML.LocalName -ne $($SPEResources.("SPEConfig1")))
                {
                    foreach($VariableXML in $VariableBlockXML.ChildNodes)
                    {
                        $commandString = $($VariableXML.($($SPEResources.("SPEConfig2"))))
                        if(![System.String]::IsNullOrEmpty($commandString)){
                            Set-SPEVariable -VariableName $VariableXML.LocalName -CommandString $commandString
                        }
                    }
                }
            }
            #endregion
            #region Auslesen und Schreiben der Script-spezifischen Variablen
            if($ScriptName -ne "Default")
            {
                foreach($VariableXML in $config.SPE_Config.($ScriptName).($($SPEResources.("SPEConfig1"))).ChildNodes)
                {
                    $commandString = $($VariableXML.($($SPEResources.("SPEConfig2"))))
                    if(![System.String]::IsNullOrEmpty($commandString)){
                        Set-SPEVariable -VariableName $VariableXML.LocalName -CommandString $commandString
                    }
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

    #region Function Update-SPEConfigVariable
    #.ExternalHelp SPE.Common.psm1-help.xml
    Function Update-SPEConfigVariable
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)][String]$Name,
            [Parameter(Mandatory=$false)][String]$Value,
            [Parameter(Mandatory=$false)][String]$Description
        )
        Begin{}
        Process{
            $pathToConfig = $SPEVars.ConfigXMLFile;
            [xml]$config = Get-Content $pathToConfig;
            if([String]::IsNullOrEmpty($Value)){
                if($config.SPE_Config.($ScriptName).($($SPEResources.("SPEConfig1"))).($Name) -ne $null){
                    $nodeToRemove = $config.SPE_Config.($ScriptName).($($SPEResources.("SPEConfig1"))).($Name)
                    $config.SPE_Config.($ScriptName).($($SPEResources.("SPEConfig1"))).RemoveChild($nodeToRemove)
                    $testVariable = Get-Variable -Name $Name -ErrorAction SilentlyContinue
                    if($testVariable){
                        Remove-Variable -Name $Name
                    }
                }
            } else {
                if($config.SPE_Config.($ScriptName).($($SPEResources.("SPEConfig1"))).($Name) -eq $null){
                    #Variable does not exist, create
                    $newXMLNode = $config.CreateElement($Name)
                    $newXMLNodeDesc = $config.CreateElement($($SPEResources.("SPEConfig3")))
                    if($Description){
                        $newXMLNodeDesc.InnerText = $Description
                    } else {
                        $newXMLNodeDesc.InnerText = $($SPEResources.("Update-SPEConfigVariable"))
                    }
                    $catchOut = $newXMLNode.AppendChild($newXMLNodeDesc)
                    $newXMLNodeValue = $config.CreateElement($($SPEResources.("SPEConfig2")))
                    $catchOut = $newXMLNode.AppendChild($newXMLNodeValue)
                    $config.SPE_Config.($ScriptName).($($SPEResources.("SPEConfig1"))).AppendChild($newXMLNode)
                }
                $config.SPE_Config.($ScriptName).($($SPEResources.("SPEConfig1"))).($Name).($($SPEResources.("SPEConfig2"))) = $Value
                $config.save($pathToConfig)
            }
            Get-SPEConfig -ScriptName $ScriptName
        }
        End{}
    }
    #endregion
    #EndOfFunction

    #region Function Add-SPENewFunctionToModule
    Function Add-SPENewFunctionToModule{
        [CmdletBinding()]
        param(
            [Parameter(Position=0, Mandatory=$true)]
            [String]$FunctionName,
            [Parameter(Position=1, Mandatory=$true)]
            [ValidateSet("SPE.Common","SPE.SharePoint","Scheduler.Common")]
            [String]$ModuleName
        )
        Begin{
            $SPE_ModuleFolder = "c:\SPE_Scripts\Modules"
$fTemplate = @'

    #region Function [FuncName]
    #.ExternalHelp [ModuleName].psm1-help.xml
    Function [FuncName]{
        [CmdletBinding()]
        param()
        Begin{}
        Process{}
        End{}
    }
    #endregion
    #EndOfFunction

'@
        }
        Process{
            $modulePath = "$SPE_ModuleFolder\$ModuleName\$ModuleName.psm1"
            #$modulePath = "C:\spe_scripts\tests\WFactivities\SPE.Common\SPE.Common.psm1"
            $fCode = $fTemplate.Replace("[FuncName]",$FunctionName).Replace("[ModuleName]",$ModuleName)
            $file = get-item $modulePath
            if($file -ne $null)
            {
                $curDate = (Get-SPECurrentTimeForULS).Replace(" ","_").Replace("/","_").Replace(":","_").Replace(".","_")
                Copy-Item -Path $modulePath -Destination $($ModulePath.Replace(".psm1",".psm1.$curDate.old"))
                $fileContent = Get-Content $modulePath
                $arraylist = New-Object System.Collections.ArrayList
                $arraylist.AddRange($fileContent)
                $stop = $false
                for($i = 0; $i -lt $arraylist.Count; $i++){
                    if($arraylist[$i] -match "#region new Functions" -and $arraylist[$i] -notmatch "-match"){
                        $fArray = $fCode.split([char]10)
                        $arraylist.InsertRange($i + 1, $fArray)
                    }
                }
                $arraylist > $modulePath
            }
        }
        End{}
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
            $global:dirCsv = $StringWorkingDir + "Csv\"
            $global:dirXml = $StringWorkingDir + "Xml\"
        #endregion
    #endregion
    #region Laden des SPEModule
        Import-Module -Name ".\Modules\SPE.Common\SPE.Common.psd1"
        Import-Module -Name ".\Modules\SPE.SharePoint\SPE.SharePoint.psd1"
    #endregion
    #region Laden der Config
        Get-SPEConfig -ScriptName $ScriptName
    #endregion
    #region Laden der Resources
        Get-SPEResource
    #endregion
    #region ConsoleTitle mit Scriptnamen versehen
    $oldConsoleTitle = Set-SPEConsoleTitle -newTitle $($SPEResources.("StandardScriptConsoleTitle") + $ScriptName)
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
	lm -message $($SPEResources.("StandardScriptHasStarted")) -level "High"
	Write-SPEReportMessage -level "High" -area "Script" -category "Started" -message $($SPEResources.("StandardScriptHasStarted")) -CorrelationId $scriptCorrId
	$global:scriptaborted = $false
	$global:foundErrors = $false
	#endregion


    #region Warnmeldungen

        #region Warnung, falls TestModus aktiviert ist
        if($TestModus -eq $true){
            lm -message $($SPEResources.("StandardScriptTestModeActive1"))
            lm -message $($SPEResources.("StandardScriptTestModeActive2"))
        }
        #endregion
        #region Warnung, falls Logging auf Console deaktiviert ist
        if(!$LogToConsole){
            Write-Host $($SPEResources.("StandardScriptLogToConsoleDeactivated")) -ForegroundColor DarkYellow
            if($LogToLogFile){
                Write-Host $($SPEResources.("StandardScriptLogToLogFileActivated")) -ForegroundColor DarkYellow
            }
            if($LogToULSFile){
                Write-Host $($SPEResources.("StandardScriptLogToULSFileActivated")) -ForegroundColor DarkYellow
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
            Wait-SPELoop -text $($SPEResources.("StandardScriptNeedToRunAsAdmin")) -time 10
            Stop-Process $PID
        }
    }
    #endregion

#endregion
Exit-SPEOnCtrlC
while($true)
{

#region Hauptprogramm !!! Hier kann gearbeitet werden !!!

    #region Beispiel für TRY-CATCH-Block mit Logmeldung
    try{
        #region Code
        #endregion
    } catch {
	    $exMessage = $_.Exception.Message
	    $innerException = $_.Exception.InnerException
	    $info = $($SPEResources.("StandardScriptGeneralErrorInScript")) + $ScriptName
        lx -Stack $_ -info $info -Category $ScriptName	    
        $global:foundErrors = $true
    }
    #endregion

#endregion
break
}
Trap [ExecutionEngineException]{
    lm -level High -CorrelationId $scriptCorrId -message $($SPEResources.("StandardScriptTerminatedByCtrlC"))
    $global:scriptaborted = $true
    #region Auszuführender Code nach manuellem Abbruch durch Ctrl-C
    if(!$DoNotDisplayConsole){
        Show-SPETextLine -text $($SPEResources.("StandardScriptTerminatedByCtrlC")) -fgColor Red -bgColor White
        $resetConsoleTitle = Set-SPEConsoleTitle -newTitle $oldConsoleTitle
        Wait-SPEForKey
    }
    continue
    #endregion
}

#region End of Script and opening of the script's logfile
	
	if($global:scriptaborted) {
        Out-SPESpeakText -text "Script aborted by control, c"
		Write-SPEReportMessage -level "Critical" -area "Script" -category "Aborted" -message $($SPEResources.("StandardScriptAborted")) -CorrelationId $scriptCorrId
		lm -level "Critical" -area "Script" -category "Aborted" -message $($SPEResources.("StandardScriptAborted")) -CorrelationId $scriptCorrId
    } elseif($global:foundErrors){
        Out-SPESpeakText -text "Script finished with errors. Check logfiles, please."
		Write-SPEReportMessage -level "High" -area "Script" -category "Stopped" -message $($SPEResources.("StandardScriptFinishedWithErrors")) -CorrelationId $scriptCorrId
		lm -level "High" -area "Script" -category "Stopped" -message $($SPEResources.("StandardScriptFinishedWithErrors")) -CorrelationId $scriptCorrId
	} else {
        Out-SPESpeakText -text "Script successfully finished"
		Write-SPEReportMessage -message $($SPEResources.("StandardScriptFinishedWithoutErrors")) -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
		lm -message $($SPEResources.("StandardScriptFinishedWithoutErrors")) -level "High" -area "Script" -category "Stopped" -CorrelationId $scriptCorrId
	}

	if($TestMode){
        Wait-SPEForKey
    }
    if($LogToSPList){
        if($Global:logWeb){
            $Global:logWeb = $null
        }
        if($Global:logList){
            $Global:logList = $null
        }
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
            <MaxLogLevel>
                <Beschreibung>Gibt das schärfste LogLevel an in der Reihenfolge: VerboseEx,Verbose,Medium,High,Critical,Unexpected</Beschreibung>
                <Wert>"Unexpected"</Wert>
            </MaxLogLevel>
            <MinLogLevel>
                <Beschreibung>Gibt das schwächste LogLevel an in der Reihenfolge: VerboseEx,Verbose,Medium,High,Critical,Unexpected</Beschreibung>
                <Wert>"VerboseEx"</Wert>
            </MinLogLevel>
            <LogToSPList>
                <Beschreibung>Aktiviert das Logging in eine SharePoint-Liste</Beschreibung>
                <Wert>$false</Wert>
            </LogToSPList>
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
            <UrlToLogWeb>
                <Beschreibung>URL zur Website, in der die Log-Liste für LogToSPList liegt</Beschreibung>
                <Wert>"https://no.logweb.configured"</Wert>
            </UrlToLogWeb>
            <LogListName>
                <Beschreibung>Name der SharePoint-Log-Liste</Beschreibung>
                <Wert>"LogList"</Wert>
            </LogListName>
            <SPLogMaxItems>
                <Beschreibung>Maximale Anzahl der Items in der SharePoint-Log-Liste</Beschreibung>
                <Wert>5000</Wert>
            </SPLogMaxItems>
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
        "LogToSPList" = $false;
        "MaxLogLevel" = "Unexpected";
        "UseInfoHeader" = $true;
        "RunAsAdmin" = $true;
        "ScriptFolder" = "C:\SPE_Scripts\";
        "LogFolder" = "C:\SPE_Scripts\Logs\";
        "ConfigXMLFile" = "C:\SPE_Scripts\SPEConfig.xml";
        "ResourcesXMLFile" = "C:\SPE_Scripts\SPEResources.xml";
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
        "UrlToLogWeb" = "LogList";
        "LogListName" = "http://no.logweb.configured";
    }

    #endregion

#endregion

#region vars
$Global:SPE_ChoiceChars = @(
    '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','#'
)
#endregion 

#region Load Resources
Get-SPEResource
#endregion

#region Aliasses
    Set-Alias ic Invoke-SPECommand
    Set-Alias lm Write-SPELogMessage
    Set-Alias choose Use-SPEChoice
    Set-Alias ns New-SPEStandardScript
    Set-Alias nf Add-SPENewFunctionToModule
    Set-Alias lx Write-SPELogException
#endregion

export-modulemember -alias * -function *

#EndOfFile
