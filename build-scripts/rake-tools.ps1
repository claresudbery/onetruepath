Write-Host "Loaded rake-tools." -ForegroundColor Green

function Rake-Tools-Load($config)
{
    $parentFolder = Resolve-Path "..\";
    $checkoutDirectory = Join-Path $parentFolder "rake-tools";

    if(!(Test-Path -Path $checkoutDirectory))
    {
        Utils-Message "Missing rake tools - fetching." "Yellow";

        $svn = "svn.exe";
        $action = "checkout";
        $svnPath = "svn://dev.laterooms.com/build.Delivery/rake-tools";
    
        $quiet = "--quiet";
        $nonInteractive = "--non-interactive";

        $command = @("/S", "/C", """""$svn"" $action, $svnPath, $checkoutDirectory, $quiet, $nonInteractive""");

        Write-Host "cmd.exe" $command;

        &"cmd.exe" $command;

        Utils-Message "Rake tools checkout finally finish - doing things that matter now.";
    }
    else
    {
        Utils-Message "Rake tools found, doing things that matter now.";
    }
}