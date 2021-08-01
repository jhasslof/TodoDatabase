SET @MigrationOrder         = 0;
SET @MigrationEnvironment   = 'all';
SET @MigrationName          = 'AddDatabaseUser';

-- We do not check user principal type as that vary between identity providers
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-database-principals-transact-sql?view=sql-server-ver15

DECLARE @UserIDProvider            NVARCHAR(255)
DECLARE @TodoSvcUser               NVARCHAR(255)
DECLARE @AddDatabaseUserTemplate   NVARCHAR(4000)

-- Assign migration script variables
SET @TodoSvcUser        = N'$(DbUserName)'

IF( N'$(ReleaseEnvironment)' = 'local' )
BEGIN
    SET @UserIDProvider     = ''
END
ELSE
BEGIN
    SET @UserIDProvider    = 'FROM EXTERNAL PROVIDER'
END

--Generate migration script
:r .\Templates\Template.AddDatabaseUser.sql
SELECT @MigrationScript = (SELECT FORMATMESSAGE(@AddDatabaseUserTemplate, @TodoSvcUser, @TodoSvcUser, @UserIDProvider, @TodoSvcUser, @TodoSvcUser, @TodoSvcUser))

--Add migration script to database
EXEC [Internal].[AddDatabaseVersionMigration] N'$(ReleaseNo)', N'$(ReleaseEnvironment)', @MigrationOrder, @MigrationEnvironment, @MigrationName, @MigrationScript;
