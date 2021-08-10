CREATE PROCEDURE [Internal].[AddDatabaseVersionMigration]
    (
      @ReleaseNo VARCHAR(255),
      @ReleaseEnvironment  NVARCHAR (255),
      @Order        INT,
      @Environment  NVARCHAR (255),
      @Name         NVARCHAR (255),
      @Command      NVARCHAR (max)
    )
AS
    BEGIN
        BEGIN TRY
            
            -- Only add migration matching release environment
            IF ( ('ALL' <> UPPER(@Environment)) AND (UPPER(@ReleaseEnvironment) <> UPPER(@Environment)) )
                RETURN;
            
            -- Only add new migrations
            IF EXISTS (SELECT 1 FROM [Internal].[DatabaseVersionMigration] WHERE [Order] = @Order)
                RETURN

            BEGIN TRAN;
            
            DECLARE @databasVersionId BIGINT;
            Select @databasVersionId = (SELECT dbVersion.Id FROM [dbo].[GetDatabaseVersionFromReleaseNo] (@ReleaseNo) as release
                                        inner join [Internal].[DatabaseVersion] as dbVersion
	                                        on 
		                                        dbVersion.Major = release.Major AND
		                                        dbVersion.Minor = release.Minor AND
		                                        dbVersion.Patch = release.Patch AND
		                                        dbVersion.PreRelease = release.PreRelease)

            IF NOT EXISTS (SELECT [Id] FROM [Internal].[DatabaseVersionMigration] WHERE [DatabaseVersionId] = @databasVersionId AND [Order] = @Order)
            BEGIN
                --- A migration is immutable. Can only be added, not changed.
                INSERT  INTO [Internal].[DatabaseVersionMigration]
                        ( 
                          [DatabaseVersionId],
                          [Order],
                          [Environment],
                          [Name],
                          [Command]
                        )
                VALUES  ( 
                          @databasVersionId ,
                          @Order ,
                          @Environment ,
                          @Name,
                          @Command
                        );
            END
            COMMIT;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK;

            DECLARE @errMsg NVARCHAR(4000) ,
                @errSeverity INT;
            SELECT  @errMsg = ERROR_MESSAGE() ,
                    @errSeverity = ERROR_SEVERITY();
            RAISERROR(@errMsg, @errSeverity, 1);
        END CATCH;
    END;	
