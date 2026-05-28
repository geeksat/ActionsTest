param(
    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$SubscriptionName
)

$regionMap = @{
    'West Europe' = 'weu'
    'East US 2'   = 'eus2'
    'West US 3'   = 'wus3'
}

$regionCode = $regionMap[$Location]
if (-not $regionCode) {
    $regionCode = 'unk'
}

$landingZones = @(
    "hub-$regionCode"
    ("shared-$Environment").ToLower()
    "monitoring"
)

$lzCsv = $landingZones -join ','
$vnetName = "vnet-$($Environment.ToLower())-$regionCode-001"

$stageAObject = [pscustomobject]@{
    location         = $Location
    environment      = $Environment
    subscriptionName = $SubscriptionName
    regionCode       = $regionCode
    landingZones     = $landingZones
    vnetName         = $vnetName
    createdAtUtc     = (Get-Date).ToUniversalTime().ToString("o")
}

New-Item -ItemType Directory -Path "./generated" -Force | Out-Null

$stageAObject |
    ConvertTo-Json -Depth 10 |
    Set-Content -Path "./generated/stage-a-output.json"

"lz_array_csv=$lzCsv" | Add-Content -Path $env:GITHUB_OUTPUT
"vnet_name=$vnetName" | Add-Content -Path $env:GITHUB_OUTPUT
"region_code=$regionCode" | Add-Content -Path $env:GITHUB_OUTPUT

Write-Host "Stage A complete"
Write-Host "Landing Zones: $lzCsv"
Write-Host "VNet Name: $vnetName"
