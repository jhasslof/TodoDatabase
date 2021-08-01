# TodoDatabase

To build and deploy a local test database, examine and run the script
```powershell
.\TodoDatabase\Scripts\Test-db.ps1
```

To add custom code and/or data to your database upgrades examine and modify:
```
.\TodoDatabase\Scripts\Script.PostDeployment1.sql
```

Current database version:
```
SELECT * FROM [Internal].[DatabaseVersion]
```

Database custom migration steps and status
```
SELECT count(*) AS MigrationsApplied FROM [Internal].[DatabaseVersionMigration]
```
