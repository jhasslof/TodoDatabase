SET @MigrationOrder         = 2;
SET @MigrationEnvironment   = 'all';
SET @MigrationName          = 'AddFeatureTodoItems';

DECLARE @Key                            nvarchar(255)
DECLARE @Description                    nvarchar(2048)
DECLARE @AddSupportedFeatureTemplate    NVARCHAR(4000)

-- Assign migration script variables
SET @Key = 'todo.db-TodoItems'
SET @Description = 'Can return set of TodoItems'

--Generate migration script
:r .\Templates\Template.AddSupportedFeature.sql
SELECT @MigrationScript = (SELECT FORMATMESSAGE(@AddSupportedFeatureTemplate, N'$(ReleaseNo)', @Key, @Description))

--Add migration script to database
EXEC [Internal].[AddDatabaseVersionMigration] N'$(ReleaseNo)', N'$(ReleaseEnvironment)', @MigrationOrder, @MigrationEnvironment, @MigrationName, @MigrationScript;
