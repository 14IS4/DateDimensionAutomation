SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_EclipticLatitude

Description: Calcuates the sun's latitudinal position at a given Julian Date. This function is
			 used to populate the seasons for the yearly date load procedure. Do not delete!
   
*******************************************************************************************/

ALTER FUNCTION [dbo].[fn_EquinoxSolstice_EclipticLatitude] (@JD FLOAT)

RETURNS FLOAT
AS

BEGIN

	DECLARE @Coefficients TABLE
	(
		Coefficients	VARCHAR(50) NOT NULL,
		A		VARCHAR(50) NOT NULL,
		B		VARCHAR(50) NOT NULL,
		C		VARCHAR(50) NOT NULL
	)

	DECLARE @CoefficientsRow TABLE
	(
		Coefficients	VARCHAR(50) NOT NULL,
		A		VARCHAR(50) NOT NULL,
		B		VARCHAR(50) NOT NULL,
		C		VARCHAR(50) NOT NULL,
		[Row]		INT NOT NULL
	)


	INSERT INTO @Coefficients
			(Coefficients, A, B, C)
	/*
		Constant Coefficients required for calculating Ecliptic Longitude
		
		**Note** Values are brought into variable table to circumvent the limitations of T-SQL. 
				 This mimicks a multi-dimensional array that we can loop through. The Julian Date that 
				 is brought in is required in the formulas so this data can not be consolidated.
				 Because it is a constant this will never require updating and must not be changed.
	*/				
	Values('g_B0EarthCoefficients', '280', '3.199', '84334.662'),
		('g_B0EarthCoefficients', '102', '5.422', '5507.553'),
		('g_B0EarthCoefficients', '80', '3.88', '5223.69'),
		('g_B0EarthCoefficients', '44', '3.7', '2352.87'),
		('g_B0EarthCoefficients', '32', '4', '1577.34'),
		('g_B1EarthCoefficients', '9', '3.9', '5507.55'),
		('g_B1EarthCoefficients', '6', '1.73', '5223.69'),
		('g_B2EarthCoefficients', '22378', '3.38509', '10213.28555'),
		('g_B2EarthCoefficients', '282', '0', '0'),
		('g_B2EarthCoefficients', '173', '5.256', '20426.571'),
		('g_B2EarthCoefficients', '27', '3.87', '30639.86'),
		('g_B3EarthCoefficients', '647', '4.992', '10213.286'),
		('g_B3EarthCoefficients', '20', '3.14', '0'),
		('g_B3EarthCoefficients', '6', '0.77', '20426.57'),
		('g_B3EarthCoefficients', '3', '5.44', '30639.86'),
		('g_B4EarthCoefficients', '14', '0.32', '10213.29')
	
	--Adding a row number to each of the levels of coefficients, a way to access each row individually during while loop
	INSERT INTO @CoefficientsRow (Coefficients, A, B, C, [Row])
	SELECT Coefficients, A, B, C, ROW_NUMBER() OVER(PARTITION BY Coefficients ORDER BY Coefficients) AS 'Row' FROM @Coefficients

	--Set variables for final return statement
	DECLARE @rho FLOAT = ((@JD - 2451545) / 365250)
	DECLARE @rhosquared FLOAT = @rho * @rho
	DECLARE @rhocubed FLOAT = @rhosquared * @rho
	DECLARE @rho4 FLOAT = @rhocubed * @rho
	DECLARE @rho5 FLOAT = @rho4 * @rho
	
	--Initialize variables for while loops
	DECLARE @i INT = 0
	DECLARE @j INT = 0
	DECLARE @Val FLOAT = 0.0
	DECLARE @B VARCHAR(50) = ''
	DECLARE @Limit INT = 0
	DECLARE @B0 FLOAT = 0.0
	DECLARE @B1 FLOAT = 0.0
	DECLARE @B2 FLOAT = 0.0
	DECLARE @B3 FLOAT = 0.0
	DECLARE @B4 FLOAT = 0.0

	--Loop through each level of coefficients, the coefficients are fixed so there will always be 0-4.
	WHILE (@i < 5)
	
	BEGIN
	
		SET @B = CASE WHEN @i = 0 THEN 'g_B0EarthCoefficients'
			      WHEN @i = 1 THEN 'g_B1EarthCoefficients'
			      WHEN @i = 2 THEN 'g_B2EarthCoefficients'
			      WHEN @i = 3 THEN 'g_B3EarthCoefficients'
			      WHEN @i = 4 THEN 'g_B4EarthCoefficients' END
		
		--Set limit for while loop		  
		SET @Limit = (SELECT COUNT(*) FROM @Coefficients WHERE Coefficients = @B)
		
		--Begin looping through all of the coefficients in a single level
		WHILE (@j < @Limit)

		BEGIN
			SET @Val = @Val + (
						SELECT	SUM(CO.A * COS(CO.B + (CO.C * @rho))) 
						FROM	
							(
								SELECT	CAST(A AS FLOAT) AS A,
									CAST(B AS FLOAT) AS B,
									CAST(C AS FLOAT) AS C
								FROM	@CoefficientsRow 
								WHERE	Coefficients = @B
								AND	[Row] = (@j+1)
							) AS CO
					  )

			SET @j = @j + 1
		END
	
		--Set variables for return
		IF @i = 0
			BEGIN
				SET @B0 = @Val
			END
			
		IF @i = 1
			BEGIN
				SET @B1 = @Val
			END
			
		IF @i = 2
			BEGIN
				SET @B2 = @Val
			END
			
		IF @i = 3
			BEGIN
				SET @B3 = @Val
			END
			
		IF @i = 4
			BEGIN
				SET @B4 = @Val
			END
	
		--Reinitialize variables for next run through the loop
		SET @Val = 0.0
		SET @j = 0
		SET @i = @i + 1	
	END

RETURN (((@B0 + (@B1 * @rho) + (@B2 * @rhosquared) + (@B3 * @rhocubed) + (@B4 * @rho4)) / 100000000.0)* 57.295779513082320876798154814105)
END

