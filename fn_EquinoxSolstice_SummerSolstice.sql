SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_SummerSolstice

Description: Finds the Julian Date for the Summer Solstice applying corrections down 
			 to an error of 0.86 of a second. 
			 This function is used to populate the seasons for the yearly date load procedure. 
			 Do not delete!

*******************************************************************************************/

ALTER FUNCTION [dbo].[fn_EquinoxSolstice_SummerSolstice] (@Year INT)

RETURNS DATETIME
AS

BEGIN

	DECLARE @Y FLOAT = (@Year - 2000) / 1000.0
	DECLARE @Ysquared FLOAT = @Y * @Y
	DECLARE @Ycubed FLOAT = @Ysquared * @Y
	DECLARE @Y4 FLOAT = @Ycubed * @Y

	DECLARE @JDE FLOAT = 2451716.25401 + (365241.62603 * @Y) + (0.00325 * @Ysquared) - (0.00888 * @Ycubed) - (0.00030 * @Y4)
	
	DECLARE @Correction FLOAT = 0.0
	DECLARE @SunLongitude FLOAT = dbo.fn_EquinoxSolstice_ApparentEclipticLongitude(@JDE)
	
	DO:
	
	SET @SunLongitude = Odbo.fn_EquinoxSolstice_ApparentEclipticLongitude(@JDE)
	
	SET @Correction = 58 * SIN((90 - @SunLongitude) * 0.017453292519943295769236907684886)
	
	SET @JDE = @JDE + @Correction
	
	IF ABS(@Correction) > 0.00001 --Corresponds to an error of 0.86 of a second
	BEGIN
		GOTO DO
	END
	
	RETURN dbo.fn_EquinoxSolstice_ConvertJDE(@JDE)

END
