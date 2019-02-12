SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************************************************************** 
     
Procedure:	p_Output_dMonthdDateLoader

Description:	Loads the yearly dMonth and dDate tables setting holidays, seasons and business days

Author:		Kendrick Horeftis
Date:		08/04/2016

Output:		dbo.dMonth_automated
		dbo.dDate_automated

Input:		dbo.dMonth_automated
		dbo.dDate_automated


Updates:	Date        Author				Ticket (s)	Description 
----------  ----------- ---------			----------	--------------------------------------------------------- 

****************************************************************************************************************************************************/ 

ALTER PROCEDURE [dbo].[p_Output_dMonthdDateLoader]
	@RunDate DATETIME = NULL
AS

BEGIN TRY

	-----------------------------------------------------------------------
	--  Set logging parameters and @StartDate and @EndDate parameters    --
	-----------------------------------------------------------------------	
	
	DECLARE	@procName AS SYSNAME = OBJECT_NAME(@@PROCID)

	DECLARE @ProcBegin AS DATETIME = GETDATE()

	DECLARE @BlockName AS VARCHAR(100)
	DECLARE @BlockBegin AS DATETIME
	DECLARE @BlockEnd AS DATETIME
		
	----------------------------------------------------------------------------------
	--    Reassign variable if parameters were passed in the initial execute.      --
	----------------------------------------------------------------------------------
	
	DECLARE @StartDate DATE
	DECLARE @EndDate DATE
	
	IF @RunDate IS NOT NULL
		BEGIN
			SET @StartDate = DATEADD(YY, DATEDIFF(YY,0,@RunDate),0)
			SET @EndDate = DATEADD(YY, DATEDIFF(YY,0,@RunDate) + 1, -1)
		END
		
	IF @RunDate IS NULL
	BEGIN	
		SET @StartDate = DATEADD(YY, DATEDIFF(YY,0,GETDATE()),0)
		SET @EndDate = DATEADD(YY, DATEDIFF(YY,0,GETDATE()) + 1, -1)
	END
	
	DECLARE @MonthKey INT
	DECLARE @DateKey INT

	--Set First Day's of each season
	DECLARE @Spring DATE = dbo.fn_EquinoxSolstice_SpringEquinox(YEAR(@StartDate))
	DECLARE @Summer DATE = dbo.fn_EquinoxSolstice_SummerSolstice(YEAR(@StartDate))
	DECLARE @Fall	DATE = dbo.fn_EquinoxSolstice_AutumnalEquinox(YEAR(@StartDate))
	DECLARE @Winter DATE = dbo.fn_EquinoxSolstice_WinterSolstice(YEAR(@StartDate))
	
	--Set DateKey and MonthKey based off of the previous year
	SELECT	@DateKey = MAX(DateKey) + 1,
		@MonthKey = MAX(MonthKey) + 1
	FROM	dbo.dDate_automated
	WHERE	CalendarYear = YEAR(@StartDate) - 1
	
--------------------------------------------------------------------------------------------------------------------
	--Update logstats table with stored proc start time.
	INSERT dbo.LogStats(procname, description) VALUES (@procName, 'Start')
		
	------This goes at start of each block of logic----------------
	SET @BlockName = '1-Create and Load temp tables'
	SET @BlockBegin = GETDATE()
	INSERT INTO dbo.LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin, UserMsg1, UserMsg2)
	VALUES (@procName, @ProcBegin, @BlockName, @BlockBegin, @StartDate, 'MDLD')
--------------------------------------------------------------------------------------------------------------------
	
	----------------------------------------------------------------------------------
	--	Create Temp Tables for Holidays, Month & Date Data			--
	----------------------------------------------------------------------------------
	
	
	DECLARE @Holidays TABLE
	(
		HolidayDesc	VARCHAR(50) NOT NULL,
		FullDate	DATETIME NOT NULL
	)
	
	DECLARE @Date TABLE 
	(
		DateKey		INT NOT NULL,
		ValidFlag	INT NOT NULL,
		MonthKey	INT NULL,
		FullDate	DATETIME NOT NULL,
		WeekendDayFlag	SMALLINT NOT NULL,
		WeekNum		INT NOT NULL,
		DayDesc		VARCHAR(25) NOT NULL,
		WeekStartDate	DATETIME NOT NULL,
		CalendarYear	INT NOT NULL,
		CalendarMonth	INT NOT NULL,
		CalendarQtr	VARCHAR(2) NOT NULL
	)

	DECLARE @Month TABLE 
	(
		MonthKey	INT NOT NULL,
		ValidFlag	INT NOT NULL,
		FullDate	DATETIME NOT NULL,
		LongDesc	VARCHAR(20) NOT NULL,
		ShortDesc	VARCHAR(20) NOT NULL,
		MonthNum	INT NOT NULL,
		QuarterNum	INT NOT NULL,
		YearNum		INT NOT NULL,
		YearMonthNum	VARCHAR(20) NOT NULL
	)
	
	----------------------------------------------------------------------------------
	--		Populate Holidays for the current year				--
	----------------------------------------------------------------------------------


	--Calculate Holidays for the current year (Accounts for fixed holidays falling on Saturday or Sunday)
	INSERT INTO @Holidays
			(HolidayDesc, FullDate)
					
	SELECT	HolidayDesc,
		FullDate
	FROM	dbo.fn_Holidays(@StartDate)

	
	----------------------------------------------------------------------------------
	--		Calculates Month dates and MonthKey for the current year	--
	----------------------------------------------------------------------------------


	;WITH dMonth ( FullDate, MonthKey ) AS
	(
		SELECT	@StartDate AS FullDate, @MonthKey AS MonthKey
		UNION ALL
		SELECT	DATEADD(MM, 1, FullDate), MonthKey+1
		FROM	dMonth
		WHERE	FullDate < DATEADD(MM, -1, @EndDate)
	)

	INSERT INTO @Month	
			(MonthKey, ValidFlag, FullDate, LongDesc, ShortDesc, MonthNum, QuarterNum, YearNum, YearMonthNum)

	SELECT	MonthKey,
		1 AS ValidFlag,
		FullDate,
		DATENAME(MONTH,FullDate) AS LongDesc,
		LEFT(DATENAME(MONTH,FullDate),3) AS ShortDesc,
		MONTH(FullDate) AS MonthNum,
		DATEPART(QUARTER,FullDate) AS QuarterNum,
		YEAR(FullDate) AS YearNum,
		CONVERT(VARCHAR(4), YEAR(FullDate)) + RIGHT('0' + CONVERT(VARCHAR(2), MONTH(FullDate)),2) AS YearMonthNum
	
	FROM	dMonth


	----------------------------------------------------------------------------------
	--	Calculates full dates and DateKey for the current year			--
	----------------------------------------------------------------------------------


	;WITH dDate ( FullDate, DateKey ) AS
	(
		SELECT	@StartDate AS FullDate, @DateKey AS DateKey
		UNION ALL
		SELECT	DATEADD(DAY, 1, FullDate), DateKey+1
		FROM	dDate
		WHERE	FullDate < @EndDate
	)

	INSERT INTO @Date
			(DateKey, ValidFlag, MonthKey, FullDate, WeekendDayFlag, WeekNum,
			 DayDesc, WeekStartDate, CalendarYear, CalendarMonth, CalendarQtr)

	SELECT	DateKey,
		1 AS ValidFlag,
		NULL AS MonthKey,
		FullDate,
		CASE WHEN DATEPART(DW,FullDate) = 1 THEN 1 ELSE 0 END AS WeekendDayFlag,
		DATEPART(WK,FullDate) AS WeekNum,
		DATENAME(DW,FullDate) AS [DayDesc],
		DATEADD(DD, 1 - DATEPART(DW, FullDate), FullDate) AS WeekStartDate,
		YEAR(FullDate) AS CalendarYear,
		DATEPART(MONTH,FullDate) AS CalendarMonth,
		'Q' + CAST(DATEPART(QUARTER, FullDate) AS VARCHAR) AS CalendarQtr
			
	FROM	dDate OPTION (MaxRecursion 10000)

	--Add the MonthKey into the @Date table
	UPDATE	@Date
	SET	MonthKey = M.MonthKey
	FROM	@Date AS D
	JOIN	@Month AS M
	ON	D.CalendarMonth = M.MonthNum
	
	
--------------------------------------------------------------------------------------------------------------------
	------- This goes at the end of each block of logic -------------
	UPDATE dbo.LogStatsDetailed
	SET BlockEnd = GETDATE(), BlockDurMins = CAST(DATEDIFF(second,BlockBegin,GETDATE()) AS FLOAT)/60, 
		ProcDurMins = CAST(DATEDIFF(second,ProcBegin,GETDATE()) AS FLOAT)/60, rowcnt = @@rowcount
	WHERE ProcName = @ProcName
	AND BlockName = @BlockName
	AND BlockBegin = @BlockBegin
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
	------This goes at start of each block of logic----------------
	SET @BlockName = '2-Load data into dbo.dMonth'
	SET @BlockBegin = GETDATE()
	INSERT INTO dbo.LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin, UserMsg1, UserMsg2)
	VALUES (@procName, @ProcBegin, @BlockName, @BlockBegin, @StartDate, 'MDLD')
--------------------------------------------------------------------------------------------------------------------


	--Added so procedure can be re-ran if necessary
	DELETE FROM dbo.dMonth_automated WHERE YearNum = YEAR(@StartDate)
	
	INSERT INTO dbo.dMonth_automated
			(MonthKey, ValidFlag, FullDate, LongDesc, ShortDesc, MonthNum, QuarterNum, YearNum, YearMonthNum)

	SELECT	MonthKey,
		ValidFlag,
		FullDate,
		LongDesc,
		ShortDesc,
		MonthNum,
		QuarterNum,
		YearNum,
		YearMonthNum
			
	FROM	@Month
	
	
--------------------------------------------------------------------------------------------------------------------
	------- This goes at the end of each block of logic -------------
	UPDATE dbo.LogStatsDetailed
	SET BlockEnd = GETDATE(), BlockDurMins = CAST(DATEDIFF(second,BlockBegin,GETDATE()) AS FLOAT)/60, 
		ProcDurMins = CAST(DATEDIFF(second,ProcBegin,GETDATE()) AS FLOAT)/60, rowcnt = @@rowcount
	WHERE ProcName = @ProcName
	AND BlockName = @BlockName
	AND BlockBegin = @BlockBegin
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
	------This goes at start of each block of logic----------------
	SET @BlockName = '3-Load data into dbo.dDate'
	SET @BlockBegin = GETDATE()
	INSERT INTO dbo.LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin, UserMsg1, UserMsg2)
	VALUES (@procName, @ProcBegin, @BlockName, @BlockBegin, @StartDate, 'MDLD')
--------------------------------------------------------------------------------------------------------------------
	
	
	--Added so procedure can be re-ran if necessary
	DELETE FROM dbo.dDate_automated WHERE CalendarYear = YEAR(@StartDate)
	
	INSERT INTO dbo.dDate_automated
			(DateKey, ValidFlag, MonthKey, FullDate, BusinessDayFlag, WeekendDayFlag, HolidayFlag,
			 CorporateHolidayFlag, WeekNum, HolidayDesc, CorporateHolidayDesc, SeasonDesc, DayDesc,
			 WeekStartDate, BusDays_YTD, BusDays_MTD, BusDays_YTDRemain, BusDays_MTDRemain,
			 CalendarYear, CalendarMonth, CalendarQtr)

	SELECT	DateKey,
		ValidFlag,
		MonthKey,
		A.FullDate,
		CASE WHEN DATEPART(DW,A.FullDate) = 1 OR H.FullDate IS NOT NULL THEN 0 ELSE 1 END AS BusinessDayFlag,
		WeekendDayFlag,
		CASE WHEN H.FullDate IS NOT NULL THEN 1 ELSE 0 END AS HolidayFlag,
		CASE WHEN H.FullDate IS NOT NULL THEN 1 ELSE 0 END AS CorporateHolidayFlag,
		WeekNum,
		H.HolidayDesc,
		H.HolidayDesc AS CorporateHolidayDesc,
		CASE WHEN A.FullDate BETWEEN @Spring AND DATEADD(DD,-1,@Summer) THEN 'Spring' 
		     WHEN A.FullDate BETWEEN @Summer AND DATEADD(DD,-1,@Fall) THEN 'Summer'
	  	     WHEN A.FullDate BETWEEN @Fall AND DATEADD(DD,-1,@Winter) THEN 'Fall'
		     ELSE 'Winter' END AS SeasonDesc,
		DayDesc,
		WeekStartDate,
		NULL AS BusDays_YTD,
		NULL AS BusDays_YTDRemain,
		NULL AS BusDays_MTD,
		NULL AS BusDays_MTDRemain,
		CalendarYear,
		CalendarMonth,
		CalendarQtr
			
	FROM	@Date AS A

	LEFT JOIN @Holidays AS H
	ON	  A.FullDate = H.FullDate
	

--------------------------------------------------------------------------------------------------------------------
	------- This goes at the end of each block of logic -------------
	UPDATE dbo.LogStatsDetailed
	SET BlockEnd = GETDATE(), BlockDurMins = CAST(DATEDIFF(second,BlockBegin,GETDATE()) AS FLOAT)/60, 
		ProcDurMins = CAST(DATEDIFF(second,ProcBegin,GETDATE()) AS FLOAT)/60, rowcnt = @@rowcount
	WHERE ProcName = @ProcName
	AND BlockName = @BlockName
	AND BlockBegin = @BlockBegin
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
	------This goes at start of each block of logic----------------
	SET @BlockName = '4-Update BusDays_YTD'
	SET @BlockBegin = GETDATE()
	INSERT INTO dbo.LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin, UserMsg1, UserMsg2)
	VALUES (@procName, @ProcBegin, @BlockName, @BlockBegin, @StartDate, 'MDLD')
--------------------------------------------------------------------------------------------------------------------
	
	
	UPDATE	DDA
	
	SET	BusDays_YTD = YTD.BusDays_YTD
	
	FROM	dbo.dDate_automated AS DDA
	
	JOIN	
		(
			SELECT  FullDate,
				(
					SELECT	SUM(BusinessDayFlag)
					FROM	dbo.dDate
					WHERE	FullDate <= d1.FullDate
					AND	CalendarYear = YEAR(@StartDate)
				) AS BusDays_YTD
						   
			FROM	dbo.dDate_automated AS d1
			WHERE	d1.CalendarYear = YEAR(@StartDate)
		) AS YTD
	ON	DDA.FullDate = YTD.FullDate
	
	
--------------------------------------------------------------------------------------------------------------------
	------- This goes at the end of each block of logic -------------
	UPDATE dbo.LogStatsDetailed
	SET BlockEnd = GETDATE(), BlockDurMins = CAST(DATEDIFF(second,BlockBegin,GETDATE()) AS FLOAT)/60, 
		ProcDurMins = CAST(DATEDIFF(second,ProcBegin,GETDATE()) AS FLOAT)/60, rowcnt = @@rowcount
	WHERE ProcName = @ProcName
	AND BlockName = @BlockName
	AND BlockBegin = @BlockBegin
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
	------This goes at start of each block of logic----------------
	SET @BlockName = '5-Update BusDays_YTDRemain'
	SET @BlockBegin = GETDATE()
	INSERT INTO dbo.LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin, UserMsg1, UserMsg2)
	VALUES (@procName, @ProcBegin, @BlockName, @BlockBegin, @StartDate, 'MDLD')
--------------------------------------------------------------------------------------------------------------------
	
	
	UPDATE	DDA
	
	SET	BusDays_YTDRemain = YTDR.BusDays_YTDRemain
	
	FROM	dbo.dDate_automated AS DDA
	
	JOIN	
		(
			SELECT	FullDate, 
				(mx.MaxDays - dt.BusDays_YTD) As BusDays_YTDRemain
			FROM
				(
					SELECT	DISTINCT FullDate, 
						CalendarYear, 
						BusDays_YTD
					FROM	dbo.dDate_automated
					WHERE	CalendarYear = YEAR(@StartDate)
				) AS dt

			JOIN
				(
					SELECT	DISTINCT CalendarYear AS ModYear, 
						MAX(BusDays_YTD) AS MaxDays
					FROM	dbo.dDate_automated AS d
					WHERE	CalendarYear = YEAR(@StartDate)
					GROUP BY CalendarYear
				) AS mx
			ON	dt.CalendarYear = mx.ModYear
		) AS YTDR
	ON	DDA.FullDate = YTDR.FullDate
	
	
	
--------------------------------------------------------------------------------------------------------------------
	------- This goes at the end of each block of logic -------------
	UPDATE dbo.LogStatsDetailed
	SET BlockEnd = GETDATE(), BlockDurMins = CAST(DATEDIFF(second,BlockBegin,GETDATE()) AS FLOAT)/60, 
		ProcDurMins = CAST(DATEDIFF(second,ProcBegin,GETDATE()) AS FLOAT)/60, rowcnt = @@rowcount
	WHERE ProcName = @ProcName
	AND BlockName = @BlockName
	AND BlockBegin = @BlockBegin
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
	------This goes at start of each block of logic----------------
	SET @BlockName = '6-Update BusDays_MTD'
	SET @BlockBegin = GETDATE()
	INSERT INTO dbo.LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin, UserMsg1, UserMsg2)
	VALUES (@procName, @ProcBegin, @BlockName, @BlockBegin, @StartDate, 'MDLD')
--------------------------------------------------------------------------------------------------------------------
	
	
	UPDATE	DDA
	
	SET	BusDays_MTD = MTD.BusDays_MTD
	
	FROM	dbo.dDate_automated AS DDA
	
	JOIN	
		(
			SELECT  FullDate,
				(
					SELECT	SUM(BusinessDayFlag)
					FROM	dbo.dDate_automated
					WHERE	FullDate <= d1.FullDate
					AND	CalendarYear = YEAR(@StartDate)
					AND	CalendarMonth = MONTH(d1.FullDate)
				) AS BusDays_MTD
						   
			FROM	dbo.dDate_automated AS d1
			WHERE	d1.CalendarYear = YEAR(@StartDate)
			AND	d1.CalendarMonth IN (1,2,3,4,5,6,7,8,9,10,11,12)
		) AS MTD
	ON	DDA.FullDate = MTD.FullDate
	
	
--------------------------------------------------------------------------------------------------------------------
	------This goes at start of each block of logic----------------
	SET @BlockName = '7-Update BusDays_MTDRemain'
	SET @BlockBegin = GETDATE()
	INSERT INTO dbo.LogStatsDetailed (ProcName, ProcBegin, BlockName, BlockBegin, UserMsg1, UserMsg2)
	VALUES (@procName, @ProcBegin, @BlockName, @BlockBegin, @StartDate, 'MDLD')
--------------------------------------------------------------------------------------------------------------------
	
	
	UPDATE	DDA
	
	SET	BusDays_MTDRemain = MTDR.BusDays_MTDRemain
	
	FROM	dbo.dDate_automated AS DDA
	
	JOIN	
		(
			SELECT	FullDate, 
				(mx.MaxDays - dt.BusDays_MTD) As BusDays_MTDRemain
			FROM
				(
					SELECT	DISTINCT FullDate, 
						CalendarYear,
						CalendarMonth,
						BusDays_MTD
					FROM	dbo.dDate_automated
					WHERE	CalendarYear = YEAR(@StartDate)
				) AS dt

			JOIN
				(
					SELECT	DISTINCT CalendarYear AS ModYear,
						CalendarMonth AS ModMonth,
						MAX(BusDays_MTD) AS MaxDays
					FROM	dbo.dDate_automated AS d
					WHERE	CalendarYear = YEAR(@StartDate)
					GROUP BY CalendarYear, CalendarMonth
				) AS mx
			ON	dt.CalendarYear = mx.ModYear
			AND	dt.CalendarMonth = mx.ModMonth
			) AS MTDR
	ON		DDA.FullDate = MTDR.FullDate
	
	
--------------------------------------------------------------------------------------------------------------------
	------- This goes at the end of each block of logic -------------
	UPDATE dbo.LogStatsDetailed
	SET BlockEnd = GETDATE(), BlockDurMins = CAST(DATEDIFF(second,BlockBegin,GETDATE()) AS FLOAT)/60, 
		ProcDurMins = CAST(DATEDIFF(second,ProcBegin,GETDATE()) AS FLOAT)/60, rowcnt = @@rowcount
	WHERE ProcName = @ProcName
	AND BlockName = @BlockName
	AND BlockBegin = @BlockBegin
--------------------------------------------------------------------------------------------------------------------
	

	INSERT INTO dbo.LogStats(ProcName, Description) VALUES (@ProcName, 'Finish')


END TRY

BEGIN CATCH

	DECLARE @MSG VARCHAR(200)

	--If an error occurs the code in this CATCH block will run
	UPDATE dbo.LogStatsDetailed
	SET BlockEnd = GETDATE(), BlockDurMins = CAST(DATEDIFF(second,BlockBegin,GETDATE()) AS FLOAT)/60, 
	ProcDurMins = CAST(DATEDIFF(second,ProcBegin,GETDATE()) AS FLOAT)/60,
	Err_Num = ERROR_NUMBER(), Err_Severity = ERROR_SEVERITY(), Err_Line = ERROR_LINE(), Err_Msg = ERROR_MESSAGE()
	WHERE ProcName = @ProcName
	AND BlockName = @BlockName
	AND BlockBegin = @BlockBegin
	SET @MSG = @ProcName + ' - ' + ERROR_MESSAGE()
	RAISERROR (@MSG, 15, 1)
	RETURN

END CATCH
