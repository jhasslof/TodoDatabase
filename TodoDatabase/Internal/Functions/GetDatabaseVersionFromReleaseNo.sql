CREATE FUNCTION [dbo].[GetDatabaseVersionFromReleaseNo]
(
    @ReleaseNo VARCHAR(255)
)
RETURNS @returntable TABLE
(
    [Major]         INT,
    [Minor]         INT,
    [Patch]         INT,
    [PreRelease]    VARCHAR(255)
)
AS
BEGIN
    ---
    --- Get database verison from ReleraseNo in format SEMVER v2.0.0
    --- Ref: https://semver.org/spec/v2.0.0.html#backusnaur-form-grammar-for-valid-semver-versions
    ---
    --- Valid Versions:
    /*
    SELECT * FROM [GetDatabaseVersionFromReleaseNo] ('2021.08.1-RC')
    union
    SELECT * FROM [GetDatabaseVersionFromReleaseNo] ('2021.08.1-RC.2021.08.01.1')
    union
    SELECT * FROM [GetDatabaseVersionFromReleaseNo] ('2021.08.1-0.3.7')
    union
    SELECT * FROM [GetDatabaseVersionFromReleaseNo] ('2021.08.1-x.7.z.92')
    union
    SELECT * FROM [GetDatabaseVersionFromReleaseNo] ('1.2.3-alpha+001')
    union
    SELECT * FROM [GetDatabaseVersionFromReleaseNo] ('1.2.3-beta+exp.sha.5114f85')

    Major	Minor	Patch	PreRelease
    1	    2	    3	    alpha+001
    1	    2	    3	    beta+exp.sha.5114f85
    2021	8	    1	    0.3.7
    2021	8	    1	    RC
    2021	8	    1	    RC.2021.08.01.1
    2021	8	    1	    x.7.z.92
    */
    ---
    --- Only build info is not supported here.
    --- Hence this version INVALID: 
    --- SELECT * FROM [dbo].[GetDatabaseVersionFromReleaseNo] ('1.2.3+20130313144700')
    ---
    ---

    DECLARE @Major          INT;
    DECLARE @Minor          INT;
    DECLARE @Patch          INT;

    DECLARE @PatchToParse   VARCHAR(255);
    DECLARE @PreRelease     VARCHAR(255);


    DECLARE @MAJOR_MINOR_ARRAY  table ([Value] nvarchar(255), ARRAYINDEX int identity(1,1))
    insert into @MAJOR_MINOR_ARRAY ([Value])
    (
	    SELECT value  
	    FROM STRING_SPLIT(@ReleaseNo, '.')  
	    WHERE RTRIM(value) <> ''
    );

    Select @Major           = Parse( (Select [Value] from @MAJOR_MINOR_ARRAY where ARRAYINDEX = 1) AS INT)
    Select @Minor           = Parse( (Select [Value] from @MAJOR_MINOR_ARRAY where ARRAYINDEX = 2) AS INT)
    Select @PatchToParse    = (Select [Value] from @MAJOR_MINOR_ARRAY where ARRAYINDEX = 3)

    if (@PatchToParse LIKE '%-%') 
    BEGIN
            --- This is a pre-release and may have build info. 
            DECLARE @PATCH_ARRAY  table ([Value] nvarchar(255), ARRAYINDEX int identity(1,1))
            insert into @PATCH_ARRAY ([Value])
            (
	            SELECT value  
	            FROM STRING_SPLIT(@PatchToParse, '-')  
	            WHERE RTRIM(value) <> ''
            );
            select @Patch = Parse( (Select [Value] from @PATCH_ARRAY where ARRAYINDEX = 1) AS INT)

            DECLARE @PRERELEASE_ARRAY  table ([Value] nvarchar(255), ARRAYINDEX int identity(1,1))
            insert into @PRERELEASE_ARRAY ([Value])
            (
	            SELECT value  
	            FROM STRING_SPLIT(@ReleaseNo, '-')  
	            WHERE RTRIM(value) <> ''
            );

            Select @PreRelease  = (Select [Value] from @PRERELEASE_ARRAY where ARRAYINDEX = 2)
    END
    ELSE
    BEGIN
            select @Patch = Parse( (SELECT @PatchToParse) AS INT)
    END

    INSERT @returntable
    SELECT @Major, @Minor, @Patch, @PreRelease
    RETURN
END
