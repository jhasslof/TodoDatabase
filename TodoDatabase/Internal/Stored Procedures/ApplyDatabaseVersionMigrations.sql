CREATE PROCEDURE [Internal].[ApplyDatabaseVersionMigrations]
AS
    BEGIN
        BEGIN TRY
            DECLARE @nextOrderToExecure INT

            --Get first migration to run
            SELECT @nextOrderToExecure = MIN([Order]) from [Internal].[DatabaseVersionMigration] where IsApplied = 0

            WHILE  @nextOrderToExecure is not null
            BEGIN
                BEGIN TRAN -- One transaction per migration
                
                DECLARE @migrationCommand NVARCHAR(MAX)
                Select  @migrationCommand = (Select [Command] from [Internal].[DatabaseVersionMigration] where [Order] = @nextOrderToExecure)
                -- https://developercommunity.visualstudio.com/content/problem/824096/warning-in-vs2019-object-does-not-exist-sp-execute.html
                -- Installed Version 16.8.4, but still get warning SQL71502
                EXEC sp_executesql @migrationCommand
                UPDATE DatabaseVersionMigration set IsApplied = 1, ErrorMessage = NULL, Modified = GETDATE() where [Order] = @nextOrderToExecure

                COMMIT
                -- Get next migration to run
                SELECT @nextOrderToExecure = MIN([Order]) from [Internal].[DatabaseVersionMigration] where IsApplied = 0
            END
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK;

            DECLARE @errMsg NVARCHAR(4000) ,
                @errSeverity INT;
            SELECT  @errMsg = ERROR_MESSAGE() ,
                    @errSeverity = ERROR_SEVERITY();
            BEGIN TRAN
                UPDATE [Internal].[DatabaseVersionMigration] set ErrorMessage = @errMsg, Modified = GETDATE() where [Order] = @nextOrderToExecure
            COMMIT
            RAISERROR(@errMsg, @errSeverity, 1);
        END CATCH;
    END