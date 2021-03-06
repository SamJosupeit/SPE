#
# Modulmanifest für das Modul "SamsPowerShellEnhancements"
#
# Generiert von: Gaylord "Sam" Krieger
#
# Generiert am: 28.10.2015
#

@{

# Die diesem Manifest zugeordnete Skript- oder Binärmoduldatei.
RootModule = 'SPE.SharePoint.psm1' # ab PS-Version 3
#ModuleToProcess = 'SPE.SharePoint.psm1' # vor PS Version 3

# Die Versionsnummer dieses Moduls
ModuleVersion = '2.0'

# ID zur eindeutigen Kennzeichnung dieses Moduls
GUID = '3769bad3-617b-4773-ba31-1ed5f0ea1a82'

# Autor dieses Moduls
Author = 'Gaylord (Sam) Krieger'

# Unternehmen oder Hersteller dieses Moduls
CompanyName = ''

# Urheberrechtserklärung für dieses Modul
Copyright = '(c) 2015 Gaylord (Sam) Krieger. Alle Rechte vorbehalten.'

# Beschreibung der von diesem Modul bereitgestellten Funktionen
Description = 'This module provides a whole bunch of functions to get work with PowerShell done more easily. It is supposed to be used like some kind of framework to not invent the wheel over and over again for similar tasks. Because of this it will be actualized whenever new function are added.'

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
PowerShellVersion = '2.0'

# Der Name des für dieses Modul erforderlichen Windows PowerShell-Hosts
# PowerShellHostName = ''

# Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Hosts
# PowerShellHostVersion = ''

# Die für dieses Modul mindestens erforderliche Microsoft .NET Framework-Version
# DotNetFrameworkVersion = ''

# Die für dieses Modul mindestens erforderliche Version der CLR (Common Language Runtime)
# CLRVersion = ''

# Die für dieses Modul erforderliche Prozessorarchitektur ("Keine", "X86", "Amd64").
# ProcessorArchitecture = ''

# Die Module, die vor dem Importieren dieses Moduls in die globale Umgebung geladen werden müssen
 RequiredModules = @(
    "C:\SPE_Scripts\Modules\SPE.Common\SPE.Common.psd1"
 )

# Die Assemblys, die vor dem Importieren dieses Moduls geladen werden müssen
RequiredAssemblies = @(
".\sharepointdlls\Microsoft.SharePoint.Client.dll",
#"Microsoft.SharePoint.Client.Publishing.dll",
#"Microsoft.SharePoint.Client.Search.dll",
#"Microsoft.SharePoint.Client.Search.Applications.dll",
#"Microsoft.SharePoint.Client.Taxonomy.dll",
#"Microsoft.SharePoint.Client.UserProfiles.dll",
#"Microsoft.SharePoint.Client.WorkflowServices.dll",
".\sharepointdlls\Microsoft.SharePoint.Client.Runtime.dll"
)

# Die Skriptdateien (PS1-Dateien), die vor dem Importieren dieses Moduls in der Umgebung des Aufrufers ausgeführt werden.
# ScriptsToProcess = @()

# Die Typdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
# TypesToProcess = @()

# Die Formatdateien (.ps1xml), die beim Importieren dieses Moduls geladen werden sollen
# FormatsToProcess = @()

# Die Module, die als geschachtelte Module des in "RootModule/ModuleToProcess" angegebenen Moduls importiert werden sollen.
# NestedModules = @()

# Aus diesem Modul zu exportierende Funktionen
FunctionsToExport = '*'

# Aus diesem Modul zu exportierende Cmdlets
CmdletsToExport = '*'

# Die aus diesem Modul zu exportierenden Variablen
VariablesToExport = '*'

# Aus diesem Modul zu exportierende Aliase
AliasesToExport = '*'

# Liste aller Module in diesem Modulpaket
# ModuleList = @()

# Liste aller Dateien in diesem Modulpaket
# FileList = @()

# Die privaten Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen.
# PrivateData = ''

# HelpInfo-URI dieses Moduls
# HelpInfoURI = ''

# Standardpräfix für Befehle, die aus diesem Modul exportiert werden. Das Standardpräfix kann mit "Import-Module -Prefix" überschrieben werden.
# DefaultCommandPrefix = ''

}

