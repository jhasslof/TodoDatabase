CREATE TABLE [Internal].[DatabaseVersionMigration]
(
	[Id]                INT             IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [DatabaseVersionId] INT             NOT NULL,
    [IsApplied]         BIT             DEFAULT(0) NOT NULL,
    [Order]             INT             NOT NULL,
    [Environment]       NVARCHAR (255)  NOT NULL,
    [Name]              NVARCHAR (255)  NOT NULL,
    [Command]           NVARCHAR (max)  NOT NULL,
    [ErrorMessage]      NVARCHAR (4000) NULL,
	[Created]		    DATETIME		DEFAULT (GETUTCDATE()) NOT NULL,
    [Modified]		    DATETIME		NULL,
    CONSTRAINT [FK_DatabaseVersionMigration_DatabaseVersion] FOREIGN KEY ([DatabaseVersionId]) REFERENCES [Internal].[DatabaseVersion] ([Id]),
    CONSTRAINT [UC_DatabaseVersionMigration] UNIQUE ([Order])
)
