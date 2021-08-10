CREATE PROCEDURE [Internal].[AddDatabaseVersion]
    (
      @ReleaseNo VARCHAR(255)
    )
AS
    BEGIN
        BEGIN TRY
            BEGIN TRAN;

            DECLARE @databasVersionId BIGINT;
            Select @databasVersionId = (SELECT dbVersion.Id FROM [dbo].[GetDatabaseVersionFromReleaseNo] (@ReleaseNo) as release
                                        inner join [Internal].[DatabaseVersion] as dbVersion
	                                        on 
		                                        dbVersion.Major = release.Major AND
		                                        dbVersion.Minor = release.Minor AND
		                                        dbVersion.Patch = release.Patch AND
		                                        dbVersion.PreRelease = release.PreRelease)

            If(@databasVersionId is null)
            BEGIN
                ---
                --- Add DB Version
                ---
                INSERT  INTO [Internal].[DatabaseVersion]
                        ( 
                          [Internal].[DatabaseVersion].[Major] ,
                          [Internal].[DatabaseVersion].[Minor] ,
                          [Internal].[DatabaseVersion].[Patch] ,
                          [Internal].[DatabaseVersion].[PreRelease]
                        )
                 (SELECT release.[Major], release.[Minor], release.[Patch], release.[PreRelease] FROM [dbo].[GetDatabaseVersionFromReleaseNo] (@ReleaseNo) as release);
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
