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
            
            ---
            --- Get database verison from ReleraseNo in format YYYY.MM.DD.Rev
            ---
            DECLARE  @Year INT;
            DECLARE  @Month INT;
            DECLARE  @Day INT;
            DECLARE  @Rev INT;
            DECLARE @VERSION_ARRAY table ([Value] nvarchar(50), ARRAYINDEX int identity(1,1))

            insert into @VERSION_ARRAY ([Value])
            (
	            SELECT value  
	            FROM STRING_SPLIT(@ReleaseNo, '.')  
	            WHERE RTRIM(value) <> ''
            );

            Select @Year    = Parse( (Select [Value] from @VERSION_ARRAY where ARRAYINDEX = 1) AS INT)
            Select @Month   = Parse( (Select [Value] from @VERSION_ARRAY where ARRAYINDEX = 2) AS INT)
            Select @Day     = Parse( (Select [Value] from @VERSION_ARRAY where ARRAYINDEX = 3) AS INT)
            Select @Rev     = Parse( (Select [Value] from @VERSION_ARRAY where ARRAYINDEX = 4) AS INT)

            DECLARE @databasVersionId INT;
            Select @databasVersionId = (SELECT [Id] FROM [Internal].[DatabaseVersion] WHERE 
                                                    [Year] = @Year AND
                                                    [Month] = @Month AND
                                                    [Day] = @Day AND
                                                    [Revision] = @Rev );

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
