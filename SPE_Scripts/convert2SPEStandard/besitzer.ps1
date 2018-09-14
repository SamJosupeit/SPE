# -------------------------------------------------------------------------------------------------------------------------------------- #
# Nachfolgendes Script liest alle Mitglieder der Sharepoint Gruppe Besitzer, in allen SiteCollections aus und schreibt diese in ein .csv #
# -------------------------------------------------------------------------------------------------------------------------------------- #
$url = "https://intranet.mt-ag.com"
$webapp = Get-SPWebApplication -Identity $url

$Groups = @(
    "Owner","Besitzer",
    "Member","Mitglieder",
    "Visitor","Besucher"
)

foreach($site in $webapp.Sites) 
{
    foreach($web in $site.AllWebs)
    {
	    $SiteUrl = $web.Url.Replace("/","") # -replace "([/])$","";
#	    if ($Credentials) {
#		    $SPService = New-WebServiceProxy -Uri ($SiteUrl + "/_vti_bin/UserGroup.asmx?WDSL") -Credential $Credentials
#	    }
#	    else 
#	    {
#		    $SPService = New-WebServiceProxy -Uri ($SiteUrl + "/_vti_bin/UserGroup.asmx?WDSL") -UseDefaultCredential
#	    }
#	    $SPService.Url = $SiteUrl + "/_vti_bin/UserGroup.asmx?WDSL"
	    $WebGroups = $web.Groups #$SPService.GetGroupCollectionFromWeb().Groups;

	    $WebGroups | ForEach-Object 
	    {
		    $GroupName = $_.Name;
            $useGroup = $false
            foreach($Group in $Groups){
                if($Group -match $GroupName)
                {
                    $useGroup = $true
                }
            }

			if($useGroup)
			{
		        $GroupMembers = $SPService.GetUserCollectionFromGroup($_.Name).Users;
		        $GroupMembers.User | ForEach-Object 
		        {
				    New-Object PSObject -Property @{"WebSite" = $SiteUrl; "Group" = $GroupName; "Name" = $_.Name; "User" = $_.LoginName; "UserID" = $_.ID; "EMail" = $_.Email}| Export-Csv C:\$GroupName.csv -Append
			    }
		    }
	    }
        $web.Dispose()
    }
    $site.Dispose()
}
#Anmerkung Sam
#$web.Groups 
#$web.SiteGroups
#
#$Web.AssociatedGroups
