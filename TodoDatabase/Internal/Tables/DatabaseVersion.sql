CREATE TABLE [Internal].[DatabaseVersion]
(
	[Id]			INT				IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Year]			INT				NOT NULL,
	[Month]			INT				NOT NULL,   
	[Day]			INT				NOT NULL,
	[Revision]		INT				NOT NULL,
	[Created]		DATETIME		DEFAULT (GETUTCDATE()) NOT NULL,
	[Modified]		DATETIME		NULL,
    CONSTRAINT [UC_DatabaseVersion] UNIQUE ([Year],[Month],[Day],[Revision])
)