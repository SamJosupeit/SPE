#region Script-Header mit Funktionserklärung und Versionsverlauf
<######################################################################
# MT AG - 40882 Ratingen                                              #
# Powershell-Script                                                   #
# #####################################################################
# Name:     Functions_TextOutput.ps1                                  #
# Funktion: Dieses Script dient der globalen Bereitstellung von       #
#           Textausgabe bezogenenen Functions.                        #
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
    )

    begin {
    }

    process {
    }
}
#endregion

#region Functions

	#region Function Speak-Text
	Function Speak-Text
	{
        <#
        .SYNOPSIS
        Gibt den angegebenen Text auditiv aus
        .DESCRIPTION
        Gibt den angegebenen Text auditiv aus
        .EXAMPLE
        Speak-Text -text "Hallo Welt"
        .PARAMETER text
        Der zu sprechende Text
        #>
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

    #region Function Create-InfoHeader
    Function Create-InfoHeader
    {
        <#
        .SYNOPSIS
        Diese Function erzeugt den InfoHeader, der mit einer SuperScription-, einer SubScription- und einer TimeStamp-Zeile versehen ist.
        .DESCRIPTION
        Diese Function erzeugt den InfoHeader, der mit einer SuperScription-, einer SubScription- und einer TimeStamp-Zeile versehen ist. Der InfoHeader wird durch den Parameter Width in der Breite definiert. Der damit erzeugte InfoHeader wird von den Display-Functions genutzt, um eine einheitliche Ausgabe in der console zu ermöglichen.
        .EXAMPLE
        $ArrayHeader = Create-InfoHeader
        foreach($line in $ArrayHeader)
        {
            Write-Host $line -ForegroundColor $global:InfoHeaderForeGroundColor -BackgroundColor $global:InfoHeaderBackGroundColor
        }

        Das entspricht dem Code, wie er von der Function "Display-InfoHeader" ausgeführt wird
        .PARAMETER SuperScription
        Überschrift des InfoHeaders, z.B. "Firmenname, Anschrift"; Wenn dieser Parameter nicht gesetzt ist, wird standardmäßig $global:InfoHeaderSuperScription verwendet
        .PARAMETER SubScription
        Unterschrift des Infoheaders mit z.B. erläuterndem Text; Wenn dieser Parameter nicht gesetzt ist, wird standardmäßig $global:InfoHeaderSubScription verwendet
        .PARAMETER Width
        Breite des InfoHeaders in Anzahl der Zeichen; Wenn dieser Parameter nicht gesetzt ist, wird standardmäßig $global:InfoHeaderWidth verwendet
        .PARAMETER Char
        Character, der als Zeichen-Symbol für die Linien ausgegeben wird.; Wenn dieser Parameter nicht gesetzt ist, wird standardmäßig $global:DisplayFrameChar verwendet
        #>
        [CmdletBinding()]
        param
        (
            [String]$SuperScription = $global:InfoHeaderSuperScription,
            [String]$SubScription = $global:InfoHeaderSubScription.$ScriptName,
            [String]$Width = $global:InfoHeaderWidth,
            [Char]$Char = $global:DisplayFrameChar
        )

        begin {}

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
            $ArraySuperScription = Convert-TextToFramedBlock -Width $Width -InputText $SuperScription -char $Char
            foreach($StringSuperScription in $ArraySuperScription)
            {
                $outputArray.Add($StringSuperScription) | Out-Null
            }
            $outputArray.Add($separatorEmpty) | Out-Null
            $outputArray.Add($separatorFilled) | Out-Null
            $outputArray.Add($separatorEmpty) | Out-Null
            $ArraySubScription = Convert-TextToFramedBlock -Width $Width -InputText $SubScription -char $Char
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
            $outputArray.Add((Convert-TextToFramedBlock -InputText "Start  : $startTimeString" -Width $Width -char $Char)) | Out-Null
            $outputArray.Add((Convert-TextToFramedBlock -InputText "Aktuell: $CurrentTimeString" -Width $Width -char $Char)) | Out-Null
            $outputArray.Add((Convert-TextToFramedBlock -InputText "Dauer  : $CurrentDiffTimeString" -Width $Width -char $Char)) | Out-Null
            return $outputArray
        }
    }
    #endregion
	    
    #region Function Display-InfoHeader
   	Function Display-InfoHeader
    {
        <#
        .SYNOPSIS
        Nutzt den durch die Function Create-InfoHeader erzeugten InfoHeader und stellt diesen farblich eingefärbt dar
        .DESCRIPTION
        Nutzt den durch die Function Create-InfoHeader erzeugten InfoHeader und stellt diesen farblich eingefärbt dar
        .EXAMPLE
        Display-InfoHeader
        ergibt z.B.:
        #########################################
        #                                       #
        # MT AG Ratingen                        #
        #                                       #
        #########################################
        #                                       #
        # Das ist ein Powershell-Script, das    #
        # eine ganz bestimmte Funktion erfüllen #
        # soll.                                 #
        #                                       #
        #########################################
        # 25.11.2014 13:39:17                   #
        #>
        [CmdletBinding()]
        param
        (
        )

        begin {
        }

        process {
            clear
            $ArrayHeader = Create-InfoHeader
            foreach($line in $ArrayHeader)
            {
                Write-Host $line -ForegroundColor $global:InfoHeaderForeGroundColor -BackgroundColor $global:InfoHeaderBackGroundColor
            }
        }
    }
    #endregion

	#region Function Display-Question
   	Function Display-Question
    {
        <#
        .SYNOPSIS
        Gibt die angegebene Frage mit einem InfoHeader aus. Gleichzeitig wird der String auf die Breite des InfoHeaders zurecht gebrochen.
        .DESCRIPTION
        Gibt die angegebene Frage mit einem InfoHeader aus und wartet dann auf eine [STRING]-Eingabe, die in eine Variable umgeleitet werden kann. Gleichzeitig wird der String auf die Breite des InfoHeaders zurecht gebrochen.
        .EXAMPLE
        $zahl = Ask-Question -text "Wieviel?"
        .PARAMETER text
        Text der als Frage ausgegeben wird
        #>
        [CmdletBinding()]
        param
        ([String]$text)

        begin {
        }

        process {
            Display-InfoHeader
            foreach($line in (Convert-TextToFramedBlock -Width $global:InfoHeaderWidth -InputText $text -char $global:DisplayFrameChar))
            {
                Write-Host $line -ForegroundColor $global:DisplayForeGroundColor_Normal
            }
            $antwort = Read-Host
            return $antwort
        }
    }
    #endregion
    
    #region Function Display-TextLine
    Function Display-TextLine
    {
        <#
        .SYNOPSIS
        Gibt den angegebenen Text-String mit einem InfoHeader aus
        .DESCRIPTION
        Gibt den angegebenen Text-String mit einem InfoHeader aus. Gleichzeitig wird der String auf die Breite des InfoHeaders zurecht gebrochen.
        .EXAMPLE
        Display-TextLine -text "Das ist ein Text"
        .PARAMETER text
        Der darzustellende Text als STRING
        .NOTES
        Diese Function kann nur einen einfachen String verarbeiten. Um mehrzeilige Ausgaben zu erhalten, muss die Function Display-TextArray genutzt werden.
        Nach der Ausgabe kann direkt weiterer Code verarbeitet werden.
        #>
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
            Display-InfoHeader
            foreach($line in (Convert-TextToFramedBlock -Width $global:InfoHeaderWidth -InputText $text -char $global:DisplayFrameChar))
            {
                Write-Host $line -ForegroundColor $fgColor
            }
        }
    }
    #endregion
    
    #region Function Display-TextArray
    Function Display-TextArray
    {
        <#
        .SYNOPSIS
        Gibt das angegebene Text-Array mit einem InfoHeader aus
        .DESCRIPTION
        Gibt das angegebene Text-Array mit einem InfoHeader aus. Gleichzeitig wird der Text auf die Breite des InfoHeaders zurecht gebrochen.
        .EXAMPLE
        Display-TextArray -text ("Das ist ein Text","der aus mehreren","Blöcken besteht")
        .PARAMETER textArray
        Der darzustellende Text als STRING-ARRAY
        .NOTES
        Anders als die Function "Display-TextLine" kann diese Function ein Array von einfachen Text-Strings verarbeiten, um mehrzeilige, bzw. block-artige Ausgaben zu erhalten.
        Nach der Ausgabe kann direkt weiterer Code verarbeitet werden.
        #>
        [CmdletBinding()]
        param
        ([String[]]$textArray)

        begin {
        }

        process {
            Display-InfoHeader
            foreach($block in $textArray)
            {
                foreach($line in (Convert-TextToFramedBlock -Width $global:InfoHeaderWidth -InputText $block -char $global:DisplayFrameChar))
                {
                    Write-Host $line -ForegroundColor $global:DisplayForeGroundColor_Normal
                }
            }
        }
    }
    #endregion
    
    #region Function Convert-StringToBlock
    function Convert-StringToBlock
    {
        <#
        .SYNOPSIS
        Konvertiert den als "Content" angegebenen STRING in einen mehrzeiligen Textblock mit der Weite "Width"
        .DESCRIPTION
        Konvertiert den als "Content" angegebenen STRING in einen mehrzeiligen Textblock mit der Weite "Width"
        .EXAMPLE
        $BlockText = Convert-StringToBlock -Content $InputText -Width ($width - 2)
        .PARAMETER Content
        Text-String der zu einem Block konvertiert werden soll
        .PARAMETER Width
        Breite des resultierenden Blocks
        #>
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

    #region Function Convert-TextToFramedBlock
    function Convert-TextToFramedBlock
    {
        <#
        .SYNOPSIS
        Konvertiert den als "Content" angegebenen STRING für die Ausgabe passend zum InfoHeader, so dass der STRING in die Breite des InfoHeaders gebrochen und diesem optisch angeglichen wird.
        .DESCRIPTION
        Konvertiert den als "Content" angegebenen STRING für die Ausgabe passend zum InfoHeader, so dass der STRING in die Breite des InfoHeaders gebrochen und diesem optisch angeglichen wird.
        .EXAMPLE
        $ArraySuperScription = Convert-TextToFramedBlock -Width $Width -InputText $SuperScription -char $Char
        .PARAMETER width
        Breite des resultierenden Blocks inkl. beginnendem und abschliessendem Char je Zeile
        .PARAMETER InputText
        Text als STRING, der zum Block konvertierte werden soll
        .PARAMETER char
        Beginnendes und abschliessendes Char je Block-Zeile
        .NOTES
        Diese Function ist eine Hilfs-Function für die Display-Functions
        #>
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
        
            $BlockText = Convert-StringToBlock -Content $InputText -Width ($width - 4)

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

	#region Function Convert-DiffTimeToString
	function Convert-DiffTimeToString
	{
        <#
        .SYNOPSIS
        Konvertiert die angegebene TIMESPAN in einen STRING
        .DESCRIPTION
        Konvertiert die angegebene TIMESPAN in einen STRING
        .EXAMPLE
        $DiffTimeString = Convert-DiffTimeToString -difftime [TIMESPAN]
        .PARAMETER difftime
        Zeitdifferenz als TIMESPAN
        #>
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

	#region Function Wait-Loop
	Function Wait-Loop
	{
	    <#
	    .SYNOPSIS
	    Zeigt einen fortlaufenden Counter an
	    .DESCRIPTION
	    Zeigt einen fortlaufenden Counter an, der mit den gegebenen Parametern versehen wird.
	    .EXAMPLE
	    Wait-Loop -time [INT]ZeitInSekunden -text TextArray
	    .PARAMETER time
	    Zeit in Sekunden
	    .PARAMETER text
	    Anzuzeigender Text
	    #>
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
	            Display-TextArray -textArray (
	            $text,
	            " $i seconds to go."
	            )
	            Start-Sleep -Seconds 1
	        }
	    }
	}
	#endregion

    #region MTLogo
    Function MTLogo{
        #  0. Zeile
        Write-Host "                                                  " -BackgroundColor Black
        #  1. Zeile
        Write-Host " " -BackgroundColor Black -NoNewline
        Write-Host " " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "           " -NoNewline -BackgroundColor Black
        Write-Host " " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "           " -NoNewline -BackgroundColor Black
        Write-Host " " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "           " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor Blue  -BackgroundColor White   -NoNewline
        Write-Host "      " -BackgroundColor Black
        #  2. Zeile
        Write-Host " " -BackgroundColor Black -NoNewline
        Write-Host "   " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "         " -NoNewline -BackgroundColor Black
        Write-Host "   " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "         " -NoNewline -BackgroundColor Black
        Write-Host "   " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "         " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor Blue  -BackgroundColor White   -NoNewline
        Write-Host "      " -BackgroundColor Black
        #  3. Zeile
        Write-Host " " -BackgroundColor Black -NoNewline
        Write-Host "     " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "       " -NoNewline -BackgroundColor Black
        Write-Host "     " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "       " -NoNewline -BackgroundColor Black
        Write-Host "     " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "       " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor Blue  -BackgroundColor White   -NoNewline
        Write-Host "      " -BackgroundColor Black
        #  4. - 6. Zeile
        for($i = 0;$i -le 2;$i++){
            Write-Host " " -BackgroundColor Black -NoNewline
            Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
            Write-Host "     " -NoNewline -BackgroundColor Black
            Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
            Write-Host "     " -NoNewline -BackgroundColor Black
            Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
            Write-Host "     " -NoNewline -BackgroundColor Black
            Write-Host "    " -ForegroundColor Blue  -BackgroundColor White   -NoNewline
            Write-Host "        " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
            Write-Host " " -BackgroundColor Black
        }
        #  7. - 11. Zeile
        for($i = 0;$i -le 3;$i++){
            Write-Host " " -BackgroundColor Black -NoNewline
            Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
            Write-Host "     " -NoNewline -BackgroundColor Black
            Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
            Write-Host "     " -NoNewline -BackgroundColor Black
            Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
            Write-Host "     " -NoNewline -BackgroundColor Black
            Write-Host "       " -ForegroundColor Blue  -BackgroundColor White   -NoNewline
            Write-Host "      " -BackgroundColor Black
        }
        #  13. Zeile
        Write-Host " " -BackgroundColor Black -NoNewline
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "     " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "     " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "       " -NoNewline -BackgroundColor Black
        Write-Host "     " -ForegroundColor Blue  -BackgroundColor White   -NoNewline
        Write-Host "      " -BackgroundColor Black
        #  14. Zeile
        Write-Host " " -BackgroundColor Black -NoNewline
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "     " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "     " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "         " -NoNewline -BackgroundColor Black
        Write-Host "   " -ForegroundColor Blue  -BackgroundColor White   -NoNewline
        Write-Host "      " -BackgroundColor Black
        #  15. Zeile
        Write-Host " " -BackgroundColor Black -NoNewline
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "     " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "     " -NoNewline -BackgroundColor Black
        Write-Host "       " -ForegroundColor White   -BackgroundColor Blue  -NoNewline
        Write-Host "           " -NoNewline -BackgroundColor Black
        Write-Host " " -ForegroundColor Blue  -BackgroundColor White   -NoNewline
        Write-Host "      " -BackgroundColor Black
        #  letzte Zeile
        Write-Host "                                                  " -BackgroundColor Black
    }
    #endregion

#endregion