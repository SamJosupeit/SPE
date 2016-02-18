#
# Modulmanifest für das Modul "SamsPowerShellEnhancements"
#
# Generiert von: Gaylord "Sam" Krieger
#
# Generiert am: 28.10.2015
#

@{

# Die diesem Manifest zugeordnete Skript- oder Binärmoduldatei.
#RootModule = 'SPE.SharePoint.psm1' # ab PS-Version 3
ModuleToProcess = 'SPE.SharePoint.psm1' # vor PS Version 3

# Die Versionsnummer dieses Moduls
ModuleVersion = '1.2'

# ID zur eindeutigen Kennzeichnung dieses Moduls
GUID = '3769bad3-617b-4773-ba31-1ed5f0ea1a82'

# Autor dieses Moduls
Author = 'Gaylord (Sam) Krieger'

# Unternehmen oder Hersteller dieses Moduls
CompanyName = 'MT AG Ratingen'

# Urheberrechtserklärung für dieses Modul
Copyright = '(c) 2015 Gaylord (Sam) Krieger. Alle Rechte vorbehalten.'

# Beschreibung der von diesem Modul bereitgestellten Funktionen
Description = 'This module provides a whole bunch of function to get work with PowerShell done more easily. It is supposed to be used like some kind of framework to not invent the wheel over and over again for similar tasks. Because of this it will be actualized whenever new function are added.'

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
# RequiredModules = @()

# Die Assemblys, die vor dem Importieren dieses Moduls geladen werden müssen
RequiredAssemblies = @(
"Microsoft.BusinessData.dll",
"microsoft.ceres.analysisengine.shared.dll",
"microsoft.ceres.common.utils.dll",
"microsoft.ceres.common.wcfutils.dll",
"microsoft.ceres.contentengine.services.dll",
"microsoft.ceres.coreservices.services.dll",
"microsoft.ceres.evaluation.datamodel.dll",
"microsoft.ceres.evaluation.datamodel.types.dll",
"microsoft.ceres.evaluation.operators.dll",
"microsoft.ceres.evaluation.processing.dll",
"microsoft.ceres.nlpbase.wordbreaker.dll",
"microsoft.ceres.searchcore.admin.dll",
"Microsoft.IdentityModel.dll",
"Microsoft.Office.Access.Server.dll",
"Microsoft.Office.Access.Services.dll",
"Microsoft.Office.Access.Services.MOSS.dll",
"Microsoft.Office.Access.Services.Moss.Upgrade.dll",
"Microsoft.Office.DocumentManagement.dll",
"Microsoft.Office.Education.Institution.dll",
"Microsoft.Office.Excel.Server.MossHost.dll",
"Microsoft.Office.Excel.WebUI.Internal.dll",
"Microsoft.Office.Excel.WebUI.Mobile.dll",
"Microsoft.Office.InfoPath.dll",
"Microsoft.Office.InfoPath.Server.dll",
"Microsoft.Office.Policy.dll",
"Microsoft.Office.SecureStoreService.dll",
"Microsoft.Office.Server.Chart.dll",
"Microsoft.Office.Server.dll",
"Microsoft.Office.Server.PowerPoint.dll",
"Microsoft.Office.Server.Search.Administration.MSSITLB.dll",
"Microsoft.Office.Server.Search.Applications.dll",
"Microsoft.Office.Server.Search.dll",
"Microsoft.Office.Server.Search.Etw.dll",
"Microsoft.Office.Server.Search.Native.dll",
"Microsoft.Office.Server.Search.PowerShell.dll",
"Microsoft.Office.Server.UI.dll",
"Microsoft.Office.Server.UserProfiles.dll",
"Microsoft.Office.Server.UserProfiles.Synchronization.dll",
"Microsoft.Office.Server.WebAnalytics.dll",
"Microsoft.Office.Server.WorkManagement.dll",
"Microsoft.Office.TranslationServices.dll",
"Microsoft.Office.TranslationServices.MachineTranslation.dll",
"Microsoft.Office.Visio.Server.dll",
"Microsoft.Office.Web.Common.dll",
"Microsoft.Office.Web.Conversion.Framework.dll",
"Microsoft.Office.Web.Conversion.ViewerInterface.dll",
"Microsoft.Office.Word.Server.dll",
"Microsoft.PerformancePoint.Scorecards.BIMonitoringService.dll",
"Microsoft.PerformancePoint.Scorecards.Client.dll",
"Microsoft.PerformancePoint.Scorecards.Script.dll",
"Microsoft.PerformancePoint.Scorecards.ServerCommon.dll",
"Microsoft.PerformancePoint.Scorecards.Upgrade.dll",
"Microsoft.SharePoint.Client.dll",
"Microsoft.SharePoint.Client.Runtime.dll",
"Microsoft.SharePoint.Client.ServerRuntime.dll",
"Microsoft.SharePoint.dll",
"Microsoft.SharePoint.intl.dll",
"Microsoft.SharePoint.Library.dll",
"microsoft.sharepoint.portal.dll",
"Microsoft.SharePoint.Portal.Upgrade.dll",
"Microsoft.SharePoint.Powershell.dll",
"Microsoft.SharePoint.Publishing.dll",
"Microsoft.SharePoint.Search.dll",
"Microsoft.SharePoint.Search.Extended.Administration.dll",
"Microsoft.SharePoint.Security.dll",
"Microsoft.SharePoint.Taxonomy.dll",
"Microsoft.SharePoint.Translation.dll",
"Microsoft.SharePoint.WorkflowServices.dll",
"Microsoft.SharePoint.WorkflowServicesBase.dll",
"Microsoft.Web.Constraint.dll",
"SMDiagnostics.dll",
"System.AddIn.Contract.dll",
"System.Design.dll",
"System.Drawing.dll",
"System.IdentityModel.dll",
"System.Runtime.Serialization.dll",
"System.ServiceModel.Activation.dll",
"System.ServiceModel.dll",
"System.Web.ApplicationServices.dll",
"System.Web.DataVisualization.dll",
"System.Web.dll",
"System.Web.Extensions.dll",
"System.Web.Mobile.dll",
"System.Web.Services.dll",
"System.Xml.Linq.dll"
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

