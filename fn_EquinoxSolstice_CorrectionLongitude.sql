SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_CorrectionInLongitude

   Description: Applies a forumulaic algorithm to correct longitude to the EclipticLongitude function. 
			 This function is used to populate the seasons for the yearly date load procedure. 
			 Do not delete!

*******************************************************************************************/

ALTER FUNCTION [dbo].[fn_EquinoxSolstice_CorrectionInLongitude] (@Longitude FLOAT, @Latitude FLOAT, @JD FLOAT)

RETURNS FLOAT
AS

BEGIN

	DECLARE @T FLOAT = ((@JD - 2451545) / 36525)
	DECLARE @Ldash FLOAT = @Longitude - (1.397 * @T) - (0.00031 * @T * @T)
	
	--Convert to Radians
	SET @Ldash = (@Ldash * 0.017453292519943295769236907684886)
	SET @Latitude = (@Latitude * 0.017453292519943295769236907684886)
	
	DECLARE @Val FLOAT = -0.09033 + 0.03916*(COS(@Ldash) + SIN(@Ldash)) * TAN(@Latitude)
	
	--DMSToDegrees
	RETURN 0 + (0/60) + (CASE WHEN @VAL < 0 THEN ABS(@Val) ELSE @Val END/3600)

END
