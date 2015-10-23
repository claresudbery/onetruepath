Write-Host "Loaded build-scripts." -ForegroundColor Green

function EnableNuGetPackageRestore()
{
    $env:EnableNuGetPackageRestore = $true;
}

function Ms-Build-Solution($config, $buildOutputDirectory, $buildEnvironment)
{
    Utils-Message "Starting build process" "Green";
    
    $MsBuild = Join-Path $env:systemroot $config.msbuild.version;
    $target = "/target:" + $config.msbuild.target;
    
    $verbosity = "/verbosity:" + $config.msbuild.verbosity;
    
    $configuration = "Configuration=" + $config.msbuild.configuration;
    $output_directory = "OutDir=""$buildOutputDirectory""";
    $build_environment = "BuildEnvironment=""$buildEnvironment""";
    $properties = "/property:"+ $configuration + "," + $output_directory + "," + $build_environment;

    $noLogo = "/nologo";
    $inParallel = "/maxcpucount";
    
    $command = @("/S", "/C", """""$MsBuild"" $noLogo $inParallel $target $verbosity $properties""");

    Write-Host "cmd.exe" $command;

    &"cmd.exe" $command;
}

EnableNuGetPackageRestore;