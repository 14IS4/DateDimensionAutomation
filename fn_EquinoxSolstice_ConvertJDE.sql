SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_ConvertJDE

   Description: Converts the Julian Date to Gregorian Calendar Date.
			 This function is used to populate the seasons for the yearly date load procedure. 
			 Do not delete!
			 
   Note: This function just like Unix Time has a limitation from the 32-bit signed integer.
			 To account for this I have started at the turn of the century instead of 1-1-1970.
			 The current limit for the signed 32-bit integer is 68 years. That means this function
			 will stop working in 2068. It is very unlikely that this function will need to go past
			 2068 though so it should be a non-issue.
			 
			 Year 2038 Problem: https://en.wikipedia.org/wiki/Year_2038_problem
    
*******************************************************************************************/

CREATE FUNCTION [dbo].[fn_EquinoxSolstice_ConvertJDE] (@JD FLOAT)

RETURNS DATETIME
AS

BEGIN

	--2451544.5 is the Julian Date for 01-01-2000
	DECLARE @BaseDate FLOAT = (@JD - 2451544.5) * 86400
	
	DECLARE @FormattedTime DATETIME = DATEADD(S, @BaseDate, '2000-01-01 00:00:00.000')
	
	RETURN @FormattedTime

END
