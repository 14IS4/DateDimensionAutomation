SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_Holidays

  Description: Calculates the corporate holidays for the given year. Function accounts for fixed
			 holidays landing on the weekend. For holidays that fall on Saturday they will be
			 calculated to the previous Friday and holidays that fall on Sunday will be
			 calucated to the following Monday.

*******************************************************************************************/

CREATE FUNCTION [dbo].[fn_Holidays] (@StartDate DATETIME)

RETURNS @Holidays TABLE (
	HolidayDesc VARCHAR(25) NOT NULL,
	FullDate DATETIME NOT NULL
)
AS

BEGIN

	--Calculate Holidays for the current year (Accounts for fixed holidays falling on Saturday or Sunday)
	INSERT INTO @Holidays
			(HolidayDesc, FullDate)
					
	SELECT	'New Years Day' AS HolidayDesc,
		CASE WHEN DATEPART(DW,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '01-01' AS DATETIME)) = 1 THEN DATEADD(DD,1,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '01-01' AS DATETIME))
		     WHEN DATEPART(DW,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '01-01' AS DATETIME)) = 7 THEN DATEADD(DD,-1,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '01-01' AS DATETIME))
		     ELSE CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '01-01' AS DATETIME) END AS FullDate
			
	UNION ALL		
			
	SELECT	'Martin Luther King Day' AS HolidayDesc,
		dbo.dateCalc(3, 2, DATEADD(YEAR, DATEDIFF(YEAR, 0, @StartDate), 0), @@DATEFIRST) AS FullDate

	UNION ALL		
			
	SELECT	'Memorial Day' AS HolidayDesc,
		DATEADD(DD, -7, (dbo.dateCalc(1, 2, DATEADD(MM, 5, DATEADD(YEAR, DATEDIFF(YEAR, 0, @StartDate), 0)), @@DATEFIRST))) AS FullDate

	UNION ALL		
			
	SELECT	'Independence Day' AS HolidayDesc,
		CASE WHEN DATEPART(DW,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '07-04' AS DATETIME)) = 1 THEN DATEADD(DD,1,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '07-04' AS DATETIME))
		     WHEN DATEPART(DW,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '07-04' AS DATETIME)) = 7 THEN DATEADD(DD,-1,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '07-04' AS DATETIME))
		     ELSE CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '07-04' AS DATETIME) END AS FullDate

	UNION ALL

	SELECT	'Labor Day' AS HolidayDesc,
		dbo.dateCalc(1, 2, DATEADD(MM, 8, DATEADD(YEAR, DATEDIFF(YEAR, 0, @StartDate), 0)), @@DATEFIRST) AS FullDate
			
	UNION ALL

	SELECT	'Thanksgiving' AS HolidayDesc,
		dbo.dateCalc(4, 5, DATEADD(MM, 10, DATEADD(YEAR, DATEDIFF(YEAR, 0, @StartDate), 0)), @@DATEFIRST) AS FullDate
			
	UNION ALL

	SELECT	'Day After Thanksgiving' AS HolidayDesc,
		DATEADD(DD, 1, dbo.dateCalc(4, 5, DATEADD(MM, 10, DATEADD(YEAR, DATEDIFF(YEAR, 0, @StartDate), 0)), @@DATEFIRST)) AS FullDate
			
	UNION ALL		
			
	SELECT	'Christmas Day' AS HolidayDesc,
		CASE WHEN DATEPART(DW,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '12-25' AS DATETIME)) = 1 THEN DATEADD(DD,1,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '12-25' AS DATETIME))
		     WHEN DATEPART(DW,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '12-25' AS DATETIME)) = 7 THEN DATEADD(DD,-1,CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '12-25' AS DATETIME))
		     ELSE CAST(CAST(DATEPART(YYYY, @StartDate) AS VARCHAR) + '-' + '12-25' AS DATETIME) END AS FullDate
	
	RETURN

END
