SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_SpringEquinox

Description: Finds the Julian Date for the Spring (Vernal) Equinox applying corrections down 
			 to an error of 0.86 of a second. 
			 This function is used to populate the seasons for the yearly date load procedure. 
			 Do not delete!

*******************************************************************************************/

ALTER FUNCTION [dbo].[fn_EquinoxSolstice_SpringEquinox] (@Year INT)

RETURNS DATETIME
AS

BEGIN

	DECLARE @Y FLOAT = (@Year - 2000) / 1000.0
	DECLARE @Ysquared FLOAT = @Y * @Y
	DECLARE @Ycubed FLOAT = @Ysquared * @Y
	DECLARE @Y4 FLOAT = @Ycubed * @Y

	DECLARE @JDE FLOAT = 2451623.80984 + (365242.37404 * @Y) + (0.05169 * @Ysquared) - (0.00411 * @Ycubed) - (0.00057 * @Y4)
	
	DECLARE @Correction FLOAT = 0.0
	DECLARE @SunLongitude FLOAT = dbo.fn_EquinoxSolstice_ApparentEclipticLongitude(@JDE)
	
	DO:
	
	SET @SunLongitude = dbo.fn_EquinoxSolstice_ApparentEclipticLongitude(@JDE)
	
	SET @Correction = 58 * SIN(-@SunLongitude * 0.017453292519943295769236907684886)
	
	SET @JDE = @JDE + @Correction
	
	IF ABS(@Correction) > 0.00001 --Corresponds to an error of 0.86 of a second
	BEGIN
		GOTO DO
	END
	
	RETURN dbo.fn_EquinoxSolstice_ConvertJDE(@JDE)

END
