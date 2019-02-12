SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_ApparentEclipticLongitude

Description: Finds the actual Ecliptic Longitude with corrections for Nutation and Abberation. 
		This function is used to populate the seasons for the yearly date load procedure. 
		Do not delete!
    
*******************************************************************************************/

ALTER FUNCTION [dbo].[fn_EquinoxSolstice_ApparentEclipticLongitude] (@JD FLOAT)

RETURNS FLOAT
AS

BEGIN

	DECLARE @Longitude FLOAT = dbo.fn_EquinoxSolstice_GeometricFK5EclipticLongitude(@JD)
	
	DECLARE @N FLOAT = dbo.fn_EquinoxSolstice_NutationInLongitude(@JD)
	
	--Apply the correction in longitude due to nutation
	SET @Longitude = @Longitude + (0 + (0/60) + (CASE WHEN @N < 0 THEN ABS(@N) ELSE @N END/3600))
	
	DECLARE @R FLOAT = dbo.fn_EquinoxSolstice_Earth_LongLatRV(@JD, 3)
	
	--Apply the correction in logitude due to aberration
	SET @Longitude = @Longitude - ((0 + (0/60) + (CASE WHEN (20.4898 / @R) < 0 THEN ABS(20.4898 / @R) ELSE (20.4898 / @R) END/3600)))
	
	RETURN @Longitude

END
