#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Export-SPECsv.ps1                                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

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
