SET @MigrationOrder         = 1;
SET @MigrationEnvironment   = 'local';
SET @MigrationName          = 'AddTestData';

-- Bypass a preliminary clientside syntax check https://stackoverflow.com/questions/51790483/elastic-pool-not-recognised-by-visual-studio-database-project/51792185
SELECT @MigrationScript = ('
IF NOT EXISTS (SELECT 1 FROM [Todo].[TodoItem])
BEGIN
    SET IDENTITY_INSERT [Todo].[TodoItem] ON; 

	INSERT INTO [Todo].[TodoItem]
		(
			[TodoItemId],
			[Name],
			[IsComplete],
			[Created]
		)
		VALUES (1, ''Buy new phone'', 0, GetDate()),
			   (2, ''Go running'', 0, GetDate()),
			   (3, ''Code new demo'', 0, GetDate()),
			   (4, ''Make dinner'', 0, GetDate())

	SET IDENTITY_INSERT [Todo].[TodoItem] OFF;
END
')

EXEC [Internal].[AddDatabaseVersionMigration] N'$(ReleaseNo)', N'$(ReleaseEnvironment)', @MigrationOrder, @MigrationEnvironment, @MigrationName, @MigrationScript;
