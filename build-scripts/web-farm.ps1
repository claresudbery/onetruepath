# Import module silently push output to null;
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration") > $null

#Ensures it able to connect regardless of the certificate on the server
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true };

Import-Module webadministration -ErrorAction Stop;

Write-Host "Loaded web-farm scripts." -ForegroundColor Green

$farmName = "Test-Farm"

Function Web-Farm-Change-Node-Status($address, $status, $disable)
{
    #status can be "Start", "Drain", "ForcefulStop", "GracefulStop"
    $computer = gc env:computername
    $iis    = [Microsoft.Web.Administration.ServerManager]::OpenRemote($computer.ToLower())

    #Get app host configuration file and the webfarms section within it
    $conf            = $iis.GetApplicationHostConfiguration()
    $webFarmsSection = $conf.GetSection("webFarms")
    $webFarms        = $webFarmsSection.GetCollection()
    $farm            = $webFarms | Where-Object { $_.GetAttributeValue("name") -eq $farmName }

    $node = $farm.GetCollection() | Where-Object { $_.GetAttributeValue("address") -eq $address }

    $arrObject = $node.GetChildElement("applicationRequestRouting")

    #Change the node status
    Write-Host "Changing status for node $nodeAddress to $status"
    $setStateMethod     = $arrObject.Methods["SetState"]
    $setStateMethodInst = $setStateMethod.CreateInstance()
    $newStateProp       = $setStateMethodInst.Input.Attributes[0].Value = $status
    $setStateMethodInst.Execute()

    $node.SetAttributeValue("enabled", $disable)

    $iis.CommitChanges()
}

function Web-Farm-Get-Node-By-Status($farm, [bool]$status)
{
    $nodes = $farm.GetCollection()

    return ($nodes | Where-Object { $_.GetAttributeValue("enabled") -eq $status }).GetAttributeValue("address")
}

Function Web-Farm-Switch-Sites()
{
    $computer = gc env:computername
    $iis    = [Microsoft.Web.Administration.ServerManager]::OpenRemote($computer.ToLower())

    #Get app host configuration file and the webfarms section within it
    $conf            = $iis.GetApplicationHostConfiguration()
    $webFarmsSection = $conf.GetSection("webFarms")
    $webFarms        = $webFarmsSection.GetCollection()
    $farm            = $webFarms | Where-Object { $_.GetAttributeValue("name") -eq $farmName }

    $nodes = $farm.GetCollection()

    $runningNodeAddress = Web-Farm-Get-Node-By-Status $farm $True
    
    $stoppedNodeAddress = Web-Farm-Get-Node-By-Status $farm $False

    Web-Farm-Change-Node-Status $stoppedNodeAddress "Start" $True

    Web-Farm-Change-Node-Status $runningNodeAddress "Drain" $True

    Write-Host "Waiting 10 secs for connections to drain..."

    Start-Sleep -s 10

    Web-Farm-Change-Node-Status $runningNodeAddress "GracefulStop" $False
}
