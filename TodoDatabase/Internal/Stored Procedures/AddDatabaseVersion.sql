CREATE PROCEDURE [Internal].[AddDatabaseVersion]
    (
      @ReleaseNo VARCHAR(255)
    )
AS
    BEGIN
        BEGIN TRY
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

            If(@databasVersionId is null)
            BEGIN
                ---
                --- Add DB Version
                ---
                INSERT  INTO [Internal].[DatabaseVersion]
                        ( 
                          [Internal].[DatabaseVersion].[Year] ,
                          [Internal].[DatabaseVersion].[Month] ,
                          [Internal].[DatabaseVersion].[Day] ,
                          [Internal].[DatabaseVersion].[Revision]
                        )
                VALUES  ( 
                          @Year ,
                          @Month ,
                          @Day ,
                          @Rev 
                        );
            END
            ELSE
            BEGIN
                UPDATE [Internal].[DatabaseVersion] SET Modified = GETDATE() where Id = @databasVersionId
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
