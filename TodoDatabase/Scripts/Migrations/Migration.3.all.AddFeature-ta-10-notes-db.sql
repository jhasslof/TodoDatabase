SET @MigrationOrder         = 3;
SET @MigrationEnvironment   = 'all';
SET @MigrationName          = 'AddFeature-ta-10-notes-db';

-- Assign migration script variables
SET @FeatureFlagKey = 'ta-10-notes-db'
SET @FeatureFlagDescription = 'Add Notes column on TodoItem'

--Generate migration script
:r .\Templates\Template.AddSupportedFeature.sql
SELECT @MigrationScript = (SELECT FORMATMESSAGE(@AddSupportedFeatureTemplate, N'$(ReleaseNo)', @FeatureFlagKey, @FeatureFlagDescription))

--Add migration script to database
EXEC [Internal].[AddDatabaseVersionMigration] N'$(ReleaseNo)', N'$(ReleaseEnvironment)', @MigrationOrder, @MigrationEnvironment, @MigrationName, @MigrationScript;
