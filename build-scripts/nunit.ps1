Write-Host "Loaded nunit." -ForegroundColor Green

function Nunit-Run-Tests($testConfig)
{
    Utils-Message "Running tests.";

    $nunit_console = Resolve-Path $testConfig.nunit_console_location;
    $nunit_project_file = Resolve-Path $testConfig.nunit_project_file;
    $noLogo = "/nologo";
    $noDots = "/nodots";
    $process = "/process=Separate";
    $domain = "/domain=Multiple";
    $exclude = "/exclude=WiP";
	
	$reportLocation = $testConfig.nunit_xml_output;

    $xml = "/xml=""$reportLocation""";

    $command = @("/S", "/C", """""$nunit_console"" ""$nunit_project_file"" $process $domain $noLogo $noDots $exclude $xml""");

    Write-Host "cmd.exe" $command;

    &"cmd.exe" $command;
}