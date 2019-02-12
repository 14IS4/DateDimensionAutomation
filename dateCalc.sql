/*************************************************************************************************\
Description:	Returns a date for a given day based off of week number in the month.
		@Date variable should be passed in as the begining the month.
		The easiest way to do this is to find the first day of the year
		and then do a DATEADD by month. 
		Ex for November: DATEADD(MM, 10, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0))
		Function accounts for @@DATEFIRST being set to any number 1-7.

@userWeekDay Definition -	1 = Sunday
				2 = Monday
				3 = Tuesday
				4 = Wednesday
				5 = Thursday
				6 = Friday
				7 = Saturday
							
@DateFirst - Please pass in @@DATEFIRST environment variable
\************************************************************************************************/

CREATE FUNCTION dbo.dateCalc (@weekNum INT, @userWeekDay INT, @Date DATETIME, @DateFirst INT)
RETURNS DATETIME AS
BEGIN
	RETURN DATEADD(DD,((@userWeekDay + (7 - @DateFirst)) - (DATEPART(DW,@Date))) + (@weekNum - CASE WHEN ((@userWeekDay + (7 - @DateFirst)) - (DATEPART(DW,@Date))) >= 0 THEN 1 ELSE 0 END) * 7,@Date)
END
GO
