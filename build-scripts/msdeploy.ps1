Write-Host "Loaded msdeploy." -ForegroundColor Green

#
# dot-line script helpers
#
function Get-MSWebDeployInstallPath(){
     return (get-childitem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select -last 1).GetValue("InstallPath")
}

function Load-Configuration
{
    $webDeploy = Get-MSWebDeployInstallPath
    $env:Path += (";" + $webDeploy)
}

#
# Archive local iis app with all the configuration 
# Not really used in the release process
#
function MsDeploy-Create-Archive($config, $outputDirectory)
{    
    Utils-Message "Starting archive process.";

    $sync = "-verb:sync";
    $disableRule = "-disableRule=IISConfigFrom64To32";
    $source = "-source:appHostConfig=" + $config.msdeploy.application_name + ",encryptPassword='creat10n'";
    $enableLink = "-enableLink:AppPoolExtension";
    $destination = "-dest:archivedir=""$outputDirectory"",encryptPassword='creat10n'";
    $params = '-declareParam:name="ApplicationPool",defaultValue="' + $name + '",kind=DeploymentObjectAttribute,scope=appHostConfig,match="application/@applicationPool"';
    
    $command = @("/S", "/C", """""msdeploy.exe"" $sync $disableRule $source $enableLink $destination $params""");

    Write-Host "cmd.exe" $command;

    &"cmd.exe" $command;
}

#
# Package functions
#
function MsDeploy-Create-Package($config, $outputDirectory)
{
    Utils-Message "Starting package build process." "Green";
    
    MSDeploy-Create-Content-Package $config $outputDirectory;

    MSDeploy-Create-Configuration-Package $config $outputDirectory;
}

function MSDeploy-Create-Content-Package($config, $outputDirectory)
{
    Utils-Message "Creating content package." "Green";
    
    $declaredParamFilePath = MSDeploy-Create-DeclaredParam-File $config;
    
    $fullBuildPath = Resolve-Path $config.msdeploy.content_directory;

    $contentZip = Join-Path $outputDirectory "package.zip";
    
    $sync = "-verb:sync";
    $disableRule = "-disableRule=IISConfigFrom64To32";
    $contentPath = "-source:contentPath=""$fullBuildPath"",encryptPassword='creat10n'";
    $package = "-dest:package=""$contentZip"",encryptPassword='creat10n'";
    $declareParamFile = "-declareParamFile:""$declaredParamFilePath""";

    $command = @("/S", "/C", """""msdeploy.exe"" $sync $disableRule $contentPath $package $declareParamFile""");

    Write-Host "cmd.exe" $command;

    &"cmd.exe" $command;

    #"C:/_git/rake-tools/msdeploy-3.0/msdeploy.exe" 
    #-verb:sync -source:contentPath="C:/_git/hotel-details-api/build/_PublishedWebsites",encryptPassword="creat10n"
    #-dest:package="C:/_git/hotel-details-api/build-artifacts/content-package.zip",encryptPassword="creat10n"
    #-declareParamFile:"C:/_git/hotel-details-api/parameters/declared-parameters.xml"
}

function MSDeploy-Create-Configuration-Package($config, $outputDirectory)
{
    Utils-Message "Creating configuration package." "Green";
    
    $declaredParamFilePath = MSDeploy-Create-DeclaredParam-File $config;
    
    $configurationPath = Resolve-Path ".\deploy\configuration";
    $configurationZip = Join-Path $outputDirectory "configuration.zip";
    
    $sync = "-verb:sync";
    $disableRule = "-disableRule=IISConfigFrom64To32";
    $archiveDir = "-source:archiveDir=""$configurationPath"",encryptPassword='creat10n'";
    $package = "-dest:package=""$configurationZip"",encryptPassword='creat10n'";
    $declareParamFile = "-declareParamFile:""$declaredParamFilePath""";

    $command = @("/S", "/C", """""msdeploy.exe"" $sync $disableRule $archiveDir $package $declareParamFile""");

    Write-Host "cmd.exe" $command;

    &"cmd.exe" $command;

    #step 3
    #"C:/Program Files (x86)/Go Agent/pipelines/rake-tools/msdeploy-3.0/msdeploy.exe" 
    #-verb:sync 
    #-source:archiveDir="C:/Program Files (x86)/Go Agent/pipelines/HotelDetails.API-CI/config-management",encryptPassword="creat10n" 
    #-dest:package="C:/Program Files (x86)/Go Agent/pipelines/HotelDetails.API-CI/build-artifacts/config-management.zip",encryptPassword="creat10n" 
    #-declareParamFile:"C:/Program Files (x86)/Go Agent/pipelines/HotelDetails.API-CI/parameters/declared-parameters.xml"
}

#
# Deploy functions
#
function MsDeploy-Deploy-Package($config, $packageFile, $configurationFile, $serverGroupName)
{
    Utils-Message "Starting deployment process.";

    $serverGroup = $config.msdeploy.server_groups | Where-Object {  $_.name -eq $serverGroupName };

    if(!$serverGroup)
    {
        Utils-Message "Server group '$serverGroupName' is not present in the config file." "red";

        return;
    }

    $setParamFilePath = MSDeploy-Create-SetParam-File $config;

    foreach($server in $serverGroup.servers)
    {
        MsDeploy-Deploy-Content-Package $config $server $packageFile $setParamFilePath;

        MsDeploy-Deploy-Configuration-Package $config $server $configurationFile $setParamFilePath;
    }
}

function MsDeploy-Deploy-Content-Package($config, $server, $packageFile, $setParamFilePath)
{
    $contentDirectory = $config.msdeploy.parameters.installation_directory;

    $sync = "-verb:sync";
    $disableRule = "-disableRule=IISConfigFrom64To32";
    $source = "-source:package=""$packageFile"",encryptPassword=creat10n";
    $destination = "-dest:contentPath=""$contentDirectory"",encryptPassword='creat10n',computerName=" + $server;
    $setParamFile = "-setParamFile:""$setParamFilePath""";

    Utils-Message "Deploying content to '$server'" "Yellow";

    $command = @("/S", "/C", """""msdeploy.exe"" $sync $disableRule $source $destination $setParamFile""");

    Write-Host "cmd.exe" $command;

    &"cmd.exe" $command;

    # DEPLOY
    #"C:/Program Files (x86)/Go Agent/pipelines/rake-tools/msdeploy-3.0/msdeploy.exe" 
    #-verb:sync -source:package="C:/Program Files (x86)/Go Agent/pipelines/HotelDetails.API-CI/build-artifacts/content-package.zip",encryptPassword="creat10n" 
    #-dest:contentPath="d:\TLRGrp.HotelDetails.API\Applications\HotelDetails.API\v1.0",encryptPassword="creat10n",computerName="qa15.ad.laterooms.com" 
    #-setParamFile:"C:/Program Files (x86)/Go Agent/pipelines/HotelDetails.API-CI/parameters/parameters-ci.v1.0.0.59.xml"
}

function MsDeploy-Deploy-Configuration-Package($config, $server, $configurationFile, $setParamFilePath)
{
    $sync = "-verb:sync";
    $disableRule = "-disableRule=IISConfigFrom64To32";
    $source = "-source:package=""$configurationFile"",encryptPassword=creat10n";
    $destination = "-dest:auto,encryptPassword='creat10n',computerName=" + $server;
    $setParamFile = "-setParamFile:""$setParamFilePath""";

    Utils-Message "Deploying configuration to '$server'" "Yellow";

    $command = @("/S", "/C", """""msdeploy.exe"" $sync $disableRule $source $destination $setParamFile""");

    Write-Host "cmd.exe" $command;

    &"cmd.exe" $command;

    # DEPLOY
    #"C:/Program Files (x86)/Go Agent/pipelines/rake-tools/msdeploy-3.0/msdeploy.exe" 
    #-verb:sync 
    #-source:package="C:/Program Files (x86)/Go Agent/pipelines/HotelDetails.API-Live/build-artifacts/config-management.zip",encryptPassword="creat10n" 
    #-dest:auto,encryptPassword="creat10n",computerName="TELWEB101P.tlrg.org:89" 
    #-setParamFile:"C:/Program Files (x86)/Go Agent/pipelines/HotelDetails.API-Live/parameters/parameters-telfordlive.red.v1.0.0.7.xml"
}

#
# Helper functions
#
function MSDeploy-Create-SetParam-File($config)
{
    $filePath = Join-Path "deploy" $config.msdeploy.templates.set_parameters | Resolve-Path;

    $string = Get-Content $filePath | Out-String;

    $string = $string.Replace("{{application_name}}", $config.msdeploy.application_name);

    foreach($property in $config.msdeploy.parameters.psobject.Properties)
    {
        $string = $string.Replace("{{" + $property.Name + "}}", $property.Value);
    }

    $outFile = Join-Path ".\deploy" "set-parameters.xml";
    
    $null = New-Item -Path $outFile -Force -ItemType File;

    $null = Set-Content -Path $outFile -Value $string -Encoding UTF8 -Force;

    return $outFile | Resolve-Path;
}

function MSDeploy-Create-DeclaredParam-File($config)
{
    $filePath = Join-Path "deploy" $config.msdeploy.templates.declared_parameters | Resolve-Path;

    $string = Get-Content $filePath | Out-String;

    $string = $string.Replace("{{application_name}}", $config.msdeploy.application_name);

    foreach($property in $config.msdeploy.parameters.psobject.Properties)
    {
        $string = $string.Replace("{{" + $property.Name + "}}", $property.Value);
    }

    $outFile = Join-Path ".\deploy" "declared-parameters.xml";
    
    $null = New-Item -Path $outFile -Force -ItemType File;

    $null = Set-Content -Path $outFile -Value $string -Encoding UTF8 -Force;

    return $outFile | Resolve-Path;
}

#
# adds msdeploy to PATH environment variable
#
Load-Configuration