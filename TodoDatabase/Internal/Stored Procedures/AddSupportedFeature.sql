CREATE PROCEDURE [Internal].[AddSupportedFeature]
    @ReleaseNo      NVARCHAR(255),
    @Key            NVARCHAR(255),
    @Description    NVARCHAR(2048) = NULL
AS
    BEGIN TRY

        -- only add a supported feature once
        IF EXISTS (SELECT [Key] FROM [Internal].[SupportedFeature] WHERE [Key] = @Key)
            Return 0

        BEGIN TRAN
	    DECLARE @databasVersionId BIGINT;
	    Select @databasVersionId = (SELECT dbVersion.Id FROM [dbo].[GetDatabaseVersionFromReleaseNo] (@ReleaseNo) as release
								    inner join [Internal].[DatabaseVersion] as dbVersion
									    on 
										    dbVersion.Major = release.Major AND
										    dbVersion.Minor = release.Minor AND
										    dbVersion.Patch = release.Patch AND
										    dbVersion.PreRelease = release.PreRelease)

        INSERT INTO [Internal].[SupportedFeature]
               ([DatabaseVersionId]
               ,[Key]
               ,[Description]
               )
         VALUES
               (
                @databasVersionId,
                @Key,
                @Description
               )
        COMMIT        
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
RETURN 0
