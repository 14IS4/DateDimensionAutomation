SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_RadiusVector

Description: Calcuates the sun's radian vector at a given Julian Date. This function is
			 used to populate the seasons for the yearly date load procedure. Do not delete!
 
*******************************************************************************************/

CREATE FUNCTION [dbo].[fn_EquinoxSolstice_RadiusVector] (@JD FLOAT)

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
		Constant Coefficients required for calculating the radius vector
		
		**Note** Values are brought into variable table to circumvent the limitations of T-SQL. 
				 This mimicks a multi-dimensional array that we can loop through. The Julian Date that 
				 is brought in is required in the formulas so this data can not be consolidated.
				 Because it is a constant this will never require updating and must not be changed.
	*/				
	Values('g_R0EarthCoefficients', '100013989', '0', '0'),
		('g_R0EarthCoefficients', '1670700', '3.0984635', '6283.07585'),
		('g_R0EarthCoefficients', '13956', '3.05525', '12566.1517'),
		('g_R0EarthCoefficients', '3084', '5.1985', '77713.7715'),
		('g_R0EarthCoefficients', '1628', '1.1739', '5753.3849'),
		('g_R0EarthCoefficients', '1576', '2.8469', '7860.4194'),
		('g_R0EarthCoefficients', '925', '5.453', '11506.77'),
		('g_R0EarthCoefficients', '542', '4.564', '3930.21'),
		('g_R0EarthCoefficients', '472', '3.661', '5884.927'),
		('g_R0EarthCoefficients', '346', '0.964', '5507.553'),
		('g_R0EarthCoefficients', '329', '5.9', '5223.694'),
		('g_R0EarthCoefficients', '307', '0.299', '5573.143'),
		('g_R0EarthCoefficients', '243', '4.273', '11790.629'),
		('g_R0EarthCoefficients', '212', '5.847', '1577.344'),
		('g_R0EarthCoefficients', '186', '5.022', '10977.079'),
		('g_R0EarthCoefficients', '175', '3.012', '18849.228'),
		('g_R0EarthCoefficients', '110', '5.055', '5486.778'),
		('g_R0EarthCoefficients', '98', '0.89', '6069.78'),
		('g_R0EarthCoefficients', '86', '5.69', '15720.84'),
		('g_R0EarthCoefficients', '86', '1.27', '161000.69'),
		('g_R0EarthCoefficients', '65', '0.27', '17260.15'),
		('g_R0EarthCoefficients', '63', '0.92', '529.69'),
		('g_R0EarthCoefficients', '57', '2.01', '83996.85'),
		('g_R0EarthCoefficients', '56', '5.24', '71430.7'),
		('g_R0EarthCoefficients', '49', '3.25', '2544.31'),
		('g_R0EarthCoefficients', '47', '2.58', '775.52'),
		('g_R0EarthCoefficients', '45', '5.54', '9437.76'),
		('g_R0EarthCoefficients', '43', '6.01', '6275.96'),
		('g_R0EarthCoefficients', '39', '5.36', '4694'),
		('g_R0EarthCoefficients', '38', '2.39', '8827.39'),
		('g_R0EarthCoefficients', '37', '0.83', '19651.05'),
		('g_R0EarthCoefficients', '37', '4.9', '12139.55'),
		('g_R0EarthCoefficients', '36', '1.67', '12036.46'),
		('g_R0EarthCoefficients', '35', '1.84', '2942.46'),
		('g_R0EarthCoefficients', '33', '0.24', '7084.9'),
		('g_R0EarthCoefficients', '32', '0.18', '5088.63'),
		('g_R0EarthCoefficients', '32', '1.78', '398.15'),
		('g_R0EarthCoefficients', '28', '1.21', '6286.6'),
		('g_R0EarthCoefficients', '28', '1.9', '6279.55'),
		('g_R0EarthCoefficients', '26', '4.59', '10447.39'),
		('g_R1EarthCoefficients', '103019', '1.10749', '6283.07585'),
		('g_R1EarthCoefficients', '1721', '1.0644', '12566.1517'),
		('g_R1EarthCoefficients', '702', '3.142', '0'),
		('g_R1EarthCoefficients', '32', '1.02', '18849.23'),
		('g_R1EarthCoefficients', '31', '2.84', '5507.55'),
		('g_R1EarthCoefficients', '25', '1.32', '5223.69'),
		('g_R1EarthCoefficients', '18', '1.42', '1577.34'),
		('g_R1EarthCoefficients', '10', '5.91', '10977.08'),
		('g_R1EarthCoefficients', '9', '1.42', '6275.96'),
		('g_R1EarthCoefficients', '9', '0.27', '5486.78'),
		('g_R2EarthCoefficients', '4359', '5.7846', '6283.0758'),
		('g_R2EarthCoefficients', '124', '5.579', '12566.152'),
		('g_R2EarthCoefficients', '12', '3.14', '0'),
		('g_R2EarthCoefficients', '9', '3.63', '77713.77'),
		('g_R2EarthCoefficients', '6', '1.87', '5573.14'),
		('g_R2EarthCoefficients', '3', '5.47', '18849.23'),
		('g_R3EarthCoefficients', '145', '4.273', '6283.076'),
		('g_R3EarthCoefficients', '7', '3.92', '12566.15'),
		('g_R4EarthCoefficients', '4', '2.56', '6283.08')

	
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
	DECLARE @R VARCHAR(50) = ''
	DECLARE @Limit INT = 0
	DECLARE @R0 FLOAT = 0.0
	DECLARE @R1 FLOAT = 0.0
	DECLARE @R2 FLOAT = 0.0
	DECLARE @R3 FLOAT = 0.0
	DECLARE @R4 FLOAT = 0.0

	--Loop through each level of coefficients, the coefficients are fixed so there will always be 0-4.
	WHILE (@i < 5)
	
	BEGIN
	
		SET @R = CASE WHEN @i = 0 THEN 'g_R0EarthCoefficients'
			      WHEN @i = 1 THEN 'g_R1EarthCoefficients'
			      WHEN @i = 2 THEN 'g_R2EarthCoefficients'
			      WHEN @i = 3 THEN 'g_R3EarthCoefficients'
			      WHEN @i = 4 THEN 'g_R4EarthCoefficients' END
		
		--Set limit for while loop		  
		SET @Limit = (SELECT COUNT(*) FROM @Coefficients WHERE Coefficients = @R)
		
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
								WHERE	Coefficients = @R
								AND	[Row] = (@j+1)
							) AS CO
					  )

			SET @j = @j + 1
		END
	
		--Set variables for return
		IF @i = 0
			BEGIN
				SET @R0 = @Val
			END
			
		IF @i = 1
			BEGIN
				SET @R1 = @Val
			END
			
		IF @i = 2
			BEGIN
				SET @R2 = @Val
			END
			
		IF @i = 3
			BEGIN
				SET @R3 = @Val
			END
			
		IF @i = 4
			BEGIN
				SET @R4 = @Val
			END
	
		--Reinitialize variables for next run through the loop
		SET @Val = 0.0
		SET @j = 0
		SET @i = @i + 1	
	END

RETURN ((@R0 + (@R1 * @rho) + (@R2 * @rhosquared) + (@R3 * @rhocubed) + (@R4 * @rho4)) / 100000000.0)
END

