CREATE TABLE [Internal].[DatabaseVersion]
(
	[Id]			BIGINT			NOT NULL PRIMARY KEY IDENTITY(1,1),
	[Major]			INT				NOT NULL,
	[Minor]			INT				NOT NULL,   
	[Patch]			INT				NOT NULL,
	[PreRelease]    VARCHAR(255)	NOT NULL DEFAULT(''),
	[Created]		DATETIME		NOT NULL DEFAULT (GETUTCDATE()),
	[Modified]		DATETIME		NULL,
    CONSTRAINT [UC_DatabaseVersion] UNIQUE ([Major],[Minor],[Patch],[PreRelease])
)