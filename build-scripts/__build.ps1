param (
    # Mode is the environment - maps each environment on config.json
    [parameter(Mandatory=$false, position=0)]
    [string]$mode,
    # Action -  echo, build, tests, integration_tests, archive, package, deploy
    [parameter(Mandatory=$true, position=1)]
    [string]$action,
    # serverGroup - used only for deploy action; name of the server group defined in the config.json
    [parameter(Mandatory=$false, position=2)]
    [string]$serverGroup
)

# DO NOT CHANGE ANYTHING BEYOND THIS POINT IF YOU DONT KNOW WHAT YOU ARE DOING #

$ErrorActionPreference = "Stop"

$scriptLocation = Split-Path $MyInvocation.MyCommand.Path

Get-ChildItem $scriptLocation | Where `
    { $_.Name -notlike '__*' -and $_.Name -like '*.ps1'} | ForEach `
    { . $_.FullName }
    
Utils-Message "Scripts Loaded." "white";

$baseLocation = Join-Path $scriptLocation "..\" | Resolve-Path;

Push-Location $baseLocation;

#
# Parameters validation
#

if(!$mode)
{
    $mode = "debug";
    Utils-Message "No mode passed in, using $mode." "Yellow";
}

if(!$action)
{
    $action = "build";
    Utils-Message "No action passed in, using $action." "Yellow";
}

if($action -eq "deploy" -and [string]::IsNullOrEmpty($serverGroup))
{
    Utils-Message "If you are selecting to deploy your must specify a server group '-serverGroup' to deploy too." "Red";

    return;
}

Write-Host "Arguments: $mode, $action, $serverGroup" ([System.Environment]::NewLine);

try
{
    #
    # actions
    #

    function Action-Echo($config)
    {
        Utils-Message "That Guy: Okay, let's work on your execu-speak: I'm worried about ""blank""." "cyan";

        Utils-Message "Fry: Don't you worry about ""blank"". Let me worry about ""blank""." "cyan";

        Utils-Message "That Guy: Good. I also would have accepted, ""Blank? Blank? You're not looking at the big picture!""" "cyan";
        
        Write-Host "https://www.youtube.com/watch?v=BAeTf8px0mE" ([System.Environment]::NewLine) -ForegroundColor Gray
    }

    function Action-Build($config)
    {
        $buildOutputDirectory = Join-Path $baseLocation "build";

        Ms-Build-Solution $config $buildOutputDirectory $mode;
    }

    function Action-Tests($generalConfig, $testConfig)
    {
        Rake-Tools-Load $generalConfig;

        Nunit-Run-Tests $testConfig;
    }

    function Action-Package($config)
    {
        $packageOutputDirectory = Join-Path $baseLocation "deploy";

        MsDeploy-Create-Package $config $packageOutputDirectory;
    }

    function Action-MsDeploy-Archive($config)
    {
        $outputFolder = Join-Path $baseLocation "deploy\archive";

        Utils-Create-Folder $outputFolder;
    
        MsDeploy-Create-Archive $config $outputFolder;
    }

    function Action-Deploy($config)
    {
        $packageFile = Join-Path $baseLocation "deploy\package.zip";

        if(!(Utils-File-Exists $packageFile))
        {
            Utils-Message "Package file does not exist. Run the action 'package' before trying it again." "red";

            return;
        }

        $configurationFile = Join-Path $baseLocation "deploy\configuration.zip";

        if(!(Utils-File-Exists $configurationFile))
        {
            Utils-Message "Configuration file does not exist. Run the action 'package' before trying it again." "red";

            return;
        }
    
        MsDeploy-Deploy-Package $config $packageFile $configurationFile $serverGroup;
    }

    $_jsonConfig = Config-Get-Json-Config(Join-Path $baseLocation "config.json");

    $config = Config-Get-Json-Section $mode $_jsonConfig

    if($action -eq "echo")
    {
        Action-Echo $config;   
    }

    if($action -eq "build")
    {
        Action-Build $config;   
    }

    if($action -eq "tests")
    {
        Action-Tests $config $config.nunit.unit_tests;   
    }

    if($action -eq "integration_tests")
    {
        Action-Tests $config $config.nunit.integration_tests;   
    }

    if ($action -eq "package")
    {
        Action-Package $config;
    }

    if ($action -eq "deploy")
    {
        Action-Deploy $config;
    }

    if ($action -eq "archive")
    {
        Action-MsDeploy-Archive $config;
    }
}
finally
{
    Pop-Location;

    if($LASTEXITCODE -eq $null)
    {
        #some times last exit code is null so setting it to zero eg success
        $LASTEXITCODE = 0;
    }

    if($LASTEXITCODE -ne 0)
    {
        Write-Host;
        Write-Host "T.T Build Failed something is broken. what did you do?" ([System.Environment]::NewLine) -ForegroundColor red;
    }

    Write-Host "Exit-code: " $LASTEXITCODE -ForegroundColor green;    
	exit $LASTEXITCODE;
}