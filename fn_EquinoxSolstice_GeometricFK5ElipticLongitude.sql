SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_GeometricFK5EclipticLongitude

Description: Converts the Geometric Ecliptic Longitude to the FK5 system at a given Julian Date. 
			 This function is used to populate the seasons for the yearly date load procedure. 
			 Do not delete!

*******************************************************************************************/

ALTER FUNCTION [dbo].[fn_EquinoxSolstice_GeometricFK5EclipticLongitude] (@JD FLOAT)

RETURNS FLOAT
AS

BEGIN
	
	--Functions GeometricEclipticLongitude and GeometricEclipticLatitude are not separate functions to minimize total number of functions. The Goal is to keep everything as consolidated as possible so as to minimize anything getting deleted/altered.
	DECLARE @Longitude FLOAT = dbo.fn_EquinoxSolstice_Map0To360Range((dbo.fn_EquinoxSolstice_Earth_LongLatRV(@JD, 1) + 180))
	DECLARE @Latitude FLOAT = (-1 * dbo.fn_EquinoxSolstice_Earth_LongLatRV(@JD,2))
	
	SET @Longitude = @Longitude + dbo.fn_EquinoxSolstice_CorrectionInLongitude(@Longitude, @Latitude, @JD)
	
	RETURN @Longitude
END
