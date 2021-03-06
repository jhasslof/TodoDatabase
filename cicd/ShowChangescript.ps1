[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)] [string] $ChangescriptFilePath
)
$ErrorActionPreference = 'Stop'

### Usage: Send in $(ChangeScript.SqlDeploymentOutputFile) as argument

Write-Host "changescript =  $ChangescriptFilePath"

# Convert SQL file to markdown code format
"``````sql`n  ##sql## `n``````" -replace '##sql##', (Get-Content -path $ChangescriptFilePath -Raw) | Set-Content -Path "$ChangescriptFilePath.md"

Write-Host "##vso[task.uploadsummary]$ChangescriptFilePath.md"