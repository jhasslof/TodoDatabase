[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$sqlAccessToken = ((az account get-access-token --resource=https://database.windows.net/) | ConvertFrom-Json).accessToken
Write-Host "##vso[task.setvariable variable=GetSqlAccessToken.sqlAccessToken]$sqlAccessToken"