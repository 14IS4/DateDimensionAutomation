SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_Map0To360Range

Description: Maps a given degree to a 0-360 degree range. This function is
			 used to populate the seasons for the yearly date load procedure. Do not delete!

*******************************************************************************************/

CREATE FUNCTION [dbo].[fn_EquinoxSolstice_Map0To360Range] (@Degrees FLOAT)

RETURNS FLOAT
AS

BEGIN

	DECLARE @D FLOAT = @Degrees

	WHILE (@D < 0)
	BEGIN
		SET @D = @D + 360
	END
	
	WHILE (@D > 360)
	BEGIN
		SET @D = @D - 360
	END

RETURN @D
END
