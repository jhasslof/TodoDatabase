/*
argument format: 
@ReleaseNo,@Key,@Description
*/

SET @AddSupportedFeatureTemplate ='
EXECUTE [Internal].[AddSupportedFeature] 
  ''%s'',
  ''%s'',
  ''%s''
'