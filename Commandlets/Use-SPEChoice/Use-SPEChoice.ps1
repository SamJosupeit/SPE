#region Script-Header with Description and Versioning
<######################################################################
# Powershell-Script-File                                              #
#######################################################################
# Name:        Use-SPEChoice.ps1                                      #
# ################################################################### #
# # Versions:                                                       # #
# ################################################################### #
# Ver. | Author     | Changes                            | Date       #
# ################################################################### #
# 0.1  | S.Krieger  | Splitted from ModuleFile           | 18.01.2016 #
######################################################################>
#endregion

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
