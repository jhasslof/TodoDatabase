CREATE TABLE [Internal].[DatabaseVersionMigration]
(
	[Id]                BIGINT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [DatabaseVersionId] BIGINT          NOT NULL,
    [IsApplied]         BIT             NOT NULL DEFAULT(0),
    [Order]             INT             NOT NULL,
    [Environment]       NVARCHAR (255)  NOT NULL,
    [Name]              NVARCHAR (255)  NOT NULL,
    [Command]           NVARCHAR (max)  NOT NULL,
    [ErrorMessage]      NVARCHAR (4000) NULL,
	[Created]		    DATETIME		NOT NULL DEFAULT (GETUTCDATE()),
    [Modified]		    DATETIME		NULL,
    CONSTRAINT [FK_DatabaseVersionMigration_DatabaseVersion] FOREIGN KEY ([DatabaseVersionId]) REFERENCES [Internal].[DatabaseVersion] ([Id]),
    CONSTRAINT [UC_DatabaseVersionMigration] UNIQUE ([Order])
)
