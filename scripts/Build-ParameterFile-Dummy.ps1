param(
    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$SubscriptionName,

    [Parameter(Mandatory = $true)]
    [string]$FinalLZArrayCsv,

    [Parameter(Mandatory = $true)]
    [string]$VNetName,

    [Parameter(Mandatory = $true)]
    [string]$RegionCode,

    [Parameter(Mandatory = $true)]
    [string]$StageAFilePath
)

if (-not (Test-Path $StageAFilePath)) {
    throw "Stage A file not found: $StageAFilePath"
}

$stageAData = Get-Content $StageAFilePath -Raw | ConvertFrom-Json
$landingZones = $FinalLZArrayCsv -split ',' | ForEach-Object { $_.Trim() }

$parameterObject = [pscustomobject]@{
    location               = $Location
    environment            = $Environment
    subscriptionName       = $SubscriptionName
    regionCode             = $RegionCode
    vnetName               = $VNetName
    landingZonesFromStageA = $landingZones
    stageAFileCreatedAtUtc = $stageAData.createdAtUtc
    subnets                = @(
        @{
            name = "GatewaySubnet"
            cidr = "10.0.0.0/27"
        },
        @{
            name = "Data"
            cidr = "10.0.0.32/27"
        },
        @{
            name = "Services"
            cidr = "10.0.0.64/27"
        }
    )
}

New-Item -ItemType Directory -Path "./generated" -Force | Out-Null

$parameterFilePath = "./generated/parameter-file.json"
$parameterObject |
    ConvertTo-Json -Depth 10 |
    Set-Content -Path $parameterFilePath

"parameter_file_path=$parameterFilePath" | Add-Content -Path $env:GITHUB_OUTPUT

Write-Host "Stage B complete"
Write-Host "Received landing zones: $($landingZones -join ', ')"
Write-Host "Parameter file created: $parameterFilePath"
