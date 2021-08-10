CREATE TABLE [Internal].[SupportedFeatures]
(
    [Id]                BIGINT              NOT NULL PRIMARY KEY, 
    [DatabaseVersionId] BIGINT              NOT NULL,
    [Key]               NVARCHAR(255)       NOT NULL,
    [Description]       NVARCHAR(2048)      NULL,
	[Created]		    DATETIME		    NOT NULL DEFAULT (GETUTCDATE()),
	[Modified]		    DATETIME		    NULL,
    CONSTRAINT [FK_SupportedFeatures_DatabaseVersion] FOREIGN KEY ([DatabaseVersionId]) REFERENCES [Internal].[DatabaseVersion] ([Id]),
    CONSTRAINT [UC_SupportedFeaturesKey] UNIQUE ([Key])
)
