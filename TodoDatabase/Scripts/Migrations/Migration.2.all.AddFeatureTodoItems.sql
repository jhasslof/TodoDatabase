SET @MigrationOrder         = 2;
SET @MigrationEnvironment   = 'all';
SET @MigrationName          = 'AddFeatureTodoItems';

-- Assign migration script variables
SET @FeatureFlagKey = 'todo.db-TodoItems'
SET @FeatureFlagDescription = 'Can return set of TodoItems'

--Generate migration script
:r .\Templates\Template.AddSupportedFeature.sql
SELECT @MigrationScript = (SELECT FORMATMESSAGE(@AddSupportedFeatureTemplate, N'$(ReleaseNo)', @FeatureFlagKey, @FeatureFlagDescription))

--Add migration script to database
EXEC [Internal].[AddDatabaseVersionMigration] N'$(ReleaseNo)', N'$(ReleaseEnvironment)', @MigrationOrder, @MigrationEnvironment, @MigrationName, @MigrationScript;
