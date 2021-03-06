#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Get-SPEConfig.ps1                                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

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
