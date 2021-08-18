CREATE TABLE [Todo].[TodoItem]
(
    [TodoItemId]    BIGINT          NOT NULL PRIMARY KEY IDENTITY(1,1), 
    [Name]          NVARCHAR(255)   NOT NULL, 
    [IsComplete]    BIT             NOT NULL DEFAULT 0, 
    [Created]       DATETIME        NOT NULL DEFAULT GetDate(),
    [Notes]         NVARCHAR(2048)  NULL  
)
