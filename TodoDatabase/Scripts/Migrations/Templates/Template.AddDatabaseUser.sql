/*
argument format: 
user,user,provider,user,user,user
*/

SET @AddDatabaseUserTemplate ='
    IF NOT EXISTS (SELECT [name] FROM [sys].[database_principals] WHERE [name] = ''%s'')
    BEGIN
        CREATE USER [%s] %s
        ALTER ROLE db_datareader ADD MEMBER [%s]
        ALTER ROLE db_datawriter ADD MEMBER [%s]
        grant execute to [%s]
    END'