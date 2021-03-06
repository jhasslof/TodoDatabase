[CmdletBinding()]
param(
	[parameter(Mandatory = $false)][string]$ReleaseNo="1.2.1-RC.2021.08.01.1",
	[parameter(Mandatory = $false)][string]$ReleaseEnvironment="local",
	[parameter(Mandatory = $false)][bool]$RunBuild=$True
)

# WARNING: Administrator rights are required to install packages
#
# UPGRADE LOCALDB SQL to 2019 https://medium.com/cloudnimble/upgrade-visual-studio-2019s-localdb-to-sql-2019-da9da71c8ed6
# sqllocaldb stop MSSQLLocalDB
# sqllocaldb delete MSSQLLocalDB
# Run test-db.ps1 again

$ErrorActionPreference = "Stop"

function Initialize(){
	$isDacInPath = ${env:path} | select-string '\\Microsoft\\SQLDB\\DAC\\150'
	if([String]::IsnullOrEmpty($isDacInPath)) {
		write-host "add DAC to path"
		if(-not (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\150"))
		{
			throw "Missing folder ...\Microsoft\SQLDB\DAC\150"
		}
		${env:path} += ';C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\150'
	}

	$isMsbuildInPath = ${env:path} | select-string 'MSBuild\\Current\\Bin'
	if([String]::IsnullOrEmpty($isMsbuildInPath)) {
		write-host "add msbuild to path"
		iiif(-not (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin"))
		{
			throw "Missing folder ...\MSBuild\Current\Bin"
		}
		${env:path} += ';C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin'
	}

	if (-not (Get-Module -ListAvailable -Name SqlServer)) {
		write-host "Install module SqlServer"
		Install-module SqlServer -Confirm:$False -Force
	}
}

function Test-LocalDbLoginExists([string] $loginName){
	try{
		$found = (Invoke-Sqlcmd -Query "SELECT count([Name]) AS Found FROM [master].[sys].[syslogins] WHERE [NAME] = '$loginName'"  -ServerInstance "(localdb)\MSSQLLocalDB" -Database "master"  | Select-Object -expand Found)
		return ($found -gt 0)
	}
	catch{
		write-host "error"
		return $False
	}
}

function Set-LocalDbLogins([string[]] $localDbLogin){
	write-host "Check if LocalDb login exists"
	foreach($login in $localDbLogin){
		write-host "testing $login"
		if(-not (Test-LocalDbLoginExists $login)){
			write-host "sp_addlogin '$login'"
			Invoke-Sqlcmd -Query "exec sp_addlogin '$login', 'P2ssw0rd!'" -ServerInstance "(localdb)\MSSQLLocalDB" -Database "master"
		}
	}
}

function Test-DbExists([string] $databaseName){
	try{
		$connString = "Data Source=(localdb)\MSSQLLocalDB;Database=""$databaseName"";Integrated Security=true;"
		$conn = New-Object System.Data.SqlClient.SqlConnection $connString

		$conn.Open()
		if($conn.State -eq "Open")
		{
			Write-Host "Test connection successful"
			$conn.Close()
			return $True
		}
	}
	catch{
		return $False
	}
}

Initialize
[string]   	$repoRoot = "$PSScriptRoot\..\.."
[string]   	$projName = "TodoDatabase"
[string]	$databaseName = "$projName-$ReleaseEnvironment"
[string]	$databaseUser = "todoSvcUser-$ReleaseEnvironment"
[string[]] 	$localDbLogins = @($databaseUser)

try{
	# Build dacpac
	if($RunBuild){
		msbuild (Join-Path $repoRoot $projName $projName.sqlproj) /p:Configuration=Debug
	}
	# Create/Update DB and Apply Migrations
	Set-LocalDbLogins $localDbLogins
	push-location (Join-Path $repoRoot $projName "bin\Debug\")
	sqlpackage.exe /Action:Publish /SourceFile:".\$projName.dacpac" /TargetServerName:"(localdb)\MSSQLLocalDB" /TargetDatabaseName:$databaseName /Variables:ReleaseNo=$ReleaseNo /Variables:ReleaseEnvironment=$ReleaseEnvironment /Variables:DbUserName=$databaseUser

	# Assert result
	Write-Host "`nTest database connection"
	Write-Host "--------------------------"
	if(-not (Test-DbExists $databaseName)) { throw "DB Missing!"}

	Write-Host "`nDatabase Versions"
	Write-Host "-------------------"
    Invoke-Sqlcmd -Query "SELECT * FROM [Internal].[DatabaseVersion]" -ServerInstance "(localdb)\MSSQLLocalDB" -Database $databaseName | FORMAT-TABLE

	write-Host "`nValidate all migrations applied"
	Write-Host "----------------------------------"
	$ExpectedMigrationsApplied = 4
    $MigrationsApplied = (Invoke-Sqlcmd -Query "SELECT count(*) AS MigrationsApplied FROM [Internal].[DatabaseVersionMigration] WHERE IsApplied = 1" -ServerInstance "(localdb)\MSSQLLocalDB" -Database $databaseName | Select-Object -expand MigrationsApplied)
	
	if($ExpectedMigrationsApplied -ne $MigrationsApplied) {
		Write-Host "`nCheck for error messages in DatabaseVersionMigration --> ErrorMessage"
		Write-Host "-----------------------------------------------------------------------"
		Invoke-Sqlcmd -Query "SELECT Name, ErrorMessage FROM [Internal].[DatabaseVersionMigration] WHERE ErrorMessage is not null" -ServerInstance "(localdb)\MSSQLLocalDB" -Database $databaseName  | FORMAT-TABLE
	
		throw "Expected $ExpectedMigrationsApplied migrations applied. Fund $MigrationsApplied migrations applied"
	}
	Write-host "Migrations OK."
}
finally{
	pop-location
}