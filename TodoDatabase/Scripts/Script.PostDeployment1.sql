/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/


USE [$(DatabaseName)]
GO

---
--- Add Database Release Version
---
EXEC [Internal].[AddDatabaseVersion] N'$(ReleaseNo)';

---
--- Add migrations to database
---
--- Override the following parameters in migrations
DECLARE @MigrationOrder			INT
DECLARE @MigrationEnvironment	NVARCHAR (255)
DECLARE @MigrationName			NVARCHAR (255)
DECLARE @MigrationScript		NVARCHAR (MAX)

--- By default a migration is used in all environments
SET @MigrationEnvironment = 'all'

--- Each migration script is responsible for adding a command to the table 'Internal.DatabaseVersionMigration'
--- by executing SP Internal.AddDatabaseVersionMigration
:r .\Migrations\Migration.0.all.AddDatabaseUser.sql
:r .\Migrations\Migration.1.local.AddTestData.sql
:r .\Migrations\Migration.2.all.AddFeatureTodoItems.sql

---
--- Apply migrations that is not already executed
---
EXEC [Internal].[ApplyDatabaseVersionMigrations]

GO