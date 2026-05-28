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

$subnets = @(
    [pscustomobject]@{
        name = "GatewaySubnet"
        cidr = "10.20.0.0/27"
        type = "gateway"
    },
    [pscustomobject]@{
        name = "Data"
        cidr = "10.20.0.32/27"
        type = "workload"
    },
    [pscustomobject]@{
        name = "Services"
        cidr = "10.20.0.64/27"
        type = "shared"
    }
)

$parameterObject = [pscustomobject]@{
    location               = $Location
    environment            = $Environment
    subscriptionName       = $SubscriptionName
    regionCode             = $RegionCode
    vnetName               = $VNetName
    landingZonesFromStageA = $landingZones
    stageAFileCreatedAtUtc = $stageAData.createdAtUtc
    subnets                = $subnets
}

New-Item -ItemType Directory -Path "./generated" -Force | Out-Null

$parameterFilePath = "./generated/parameter-file.json"

$parameterObject |
    ConvertTo-Json -Depth 20 |
    Set-Content -Path $parameterFilePath

$subnetValuesJson = $subnets | ConvertTo-Json -Compress -Depth 20

"parameter_file_path=$parameterFilePath" | Add-Content -Path $env:GITHUB_OUTPUT
"vnet_name=$VNetName" | Add-Content -Path $env:GITHUB_OUTPUT
"location=$Location" | Add-Content -Path $env:GITHUB_OUTPUT

"subnet_values_json<<EOF" | Add-Content -Path $env:GITHUB_OUTPUT
$subnetValuesJson | Add-Content -Path $env:GITHUB_OUTPUT
"EOF" | Add-Content -Path $env:GITHUB_OUTPUT

Write-Host "Stage B complete"
Write-Host "Subnets created:"
$subnets | ForEach-Object {
    Write-Host "- Name: $($_.name), CIDR: $($_.cidr), Type: $($_.type)"
}
Write-Host "Parameter file created: $parameterFilePath"
