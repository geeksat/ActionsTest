param(
    [Parameter(Mandatory = $true)]
    [string]$Token,

    [Parameter(Mandatory = $true)]
    [string]$TargetOwner,

    [Parameter(Mandatory = $true)]
    [string]$TargetRepo,

    [Parameter(Mandatory = $true)]
    [string]$WorkflowFile,

    [Parameter(Mandatory = $true)]
    [string]$Ref,

    [Parameter(Mandatory = $true)]
    [string]$SourceRepo,

    [Parameter(Mandatory = $true)]
    [string]$SourceRunId,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$VNetName,

    [Parameter(Mandatory = $true)]
    [string]$SubnetsJson
)

$headers = @{
    Authorization = "Bearer $Token"
    Accept = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$body = @{
    ref = $Ref
    inputs = @{
        source_repo = $SourceRepo
        source_run_id = $SourceRunId
        location = $Location
        vnet_name = $VNetName
        subnets_json = $SubnetsJson
    }
} | ConvertTo-Json -Depth 20

Write-Host "Triggering workflow '$WorkflowFile' in '$TargetOwner/$TargetRepo' on ref '$Ref'"
Write-Host "Payload:"
Write-Host $body

Invoke-RestMethod `
    -Method POST `
    -Uri "https://api.github.com/repos/$TargetOwner/$TargetRepo/actions/workflows/$WorkflowFile/dispatches" `
    -Headers $headers `
    -Body $body `
    -ContentType "application/json"

Write-Host "Workflow dispatch sent successfully."
