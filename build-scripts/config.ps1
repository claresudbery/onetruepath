Write-Host "Loaded config." -ForegroundColor Green

function Config-Get-Json-Config($fileName)
{
    return Get-Content $fileName | Out-String | ConvertFrom-Json
}

function Config-Get-Json-Section($name, $json)
{
    return $json.psobject.Properties[$name].Value;
}