SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_Earth_LongLatRV

Description: Calcuates the sun's longitudinal/Latitudinal position and Radius Vector at a given 
			 Julian Date. This function is used to populate the seasons for the yearly date load
			 procedure. Do not delete!
			 
			 Function handles all three of the calculations that require earth coefficients.
			 To choose between each of the functions use the @EQ variable to pass in an integer
			 between 1-3
			 
			 1 - EclipticLongitude
			 2 - EclipticLatitude
			 3 - RadiusVector

*******************************************************************************************/

ALTER FUNCTION [dbo].[fn_EquinoxSolstice_Earth_LongLatRV] (@JD FLOAT, @EQ INT)

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

	--If EclipticLongitude is selected insert values into @Coefficients
	IF @EQ = 1
	BEGIN

		INSERT INTO @Coefficients
				(Coefficients, A, B, C)
		/*
			Constant Coefficients required for calculating Ecliptic Longitude
			
			**Note** Values are brought into variable table to circumvent the limitations of T-SQL. 
					 This mimicks a multi-dimensional array that we can loop through. The Julian Date that 
					 is brought in is required in the formulas so this data can not be consolidated.
					 Because it is a constant this will never require updating and must not be changed.
		*/				
		Values('g_L0EarthCoefficients', '175347046', '0', '0'),
			('g_L0EarthCoefficients', '3341656', '4.6692568', '6283.07585'),
			('g_L0EarthCoefficients', '34894', '4.6261', '12566.1517'),
			('g_L0EarthCoefficients', '3497', '2.7441', '5753.3849'),
			('g_L0EarthCoefficients', '3418', '2.8289', '3.5231'),
			('g_L0EarthCoefficients', '3136', '3.6277', '77713.7715'),
			('g_L0EarthCoefficients', '2676', '4.4181', '7860.4194'),
			('g_L0EarthCoefficients', '2343', '6.1352', '3930.2097'),
			('g_L0EarthCoefficients', '1324', '0.7425', '11506.7698'),
			('g_L0EarthCoefficients', '1273', '2.0371', '529.691'),
			('g_L0EarthCoefficients', '1199', '1.1096', '1577.3435'),
			('g_L0EarthCoefficients', '990', '5.233', '5884.927'),
			('g_L0EarthCoefficients', '902', '2.045', '26.298'),
			('g_L0EarthCoefficients', '857', '3.508', '398.149'),
			('g_L0EarthCoefficients', '780', '1.179', '5223.694'),
			('g_L0EarthCoefficients', '753', '2.533', '5507.553'),
			('g_L0EarthCoefficients', '505', '4.583', '18849.228'),
			('g_L0EarthCoefficients', '492', '4.205', '775.523'),
			('g_L0EarthCoefficients', '357', '2.92', '0.067'),
			('g_L0EarthCoefficients', '317', '5.849', '11790.629'),
			('g_L0EarthCoefficients', '284', '1.899', '796.288'),
			('g_L0EarthCoefficients', '271', '0.315', '10977.079'),
			('g_L0EarthCoefficients', '243', '0.345', '5486.778'),
			('g_L0EarthCoefficients', '206', '4.806', '2544.314'),
			('g_L0EarthCoefficients', '205', '1.869', '5573.143'),
			('g_L0EarthCoefficients', '202', '2.458', '6069.777'),
			('g_L0EarthCoefficients', '156', '0.833', '213.299'),
			('g_L0EarthCoefficients', '132', '3.411', '2942.463'),
			('g_L0EarthCoefficients', '126', '1.083', '20.775'),
			('g_L0EarthCoefficients', '115', '0.645', '0.98'),
			('g_L0EarthCoefficients', '103', '0.636', '4694.003'),
			('g_L0EarthCoefficients', '102', '0.976', '15720.839'),
			('g_L0EarthCoefficients', '102', '4.267', '7.114'),
			('g_L0EarthCoefficients', '99', '6.21', '2146.17'),
			('g_L0EarthCoefficients', '98', '0.68', '155.42'),
			('g_L0EarthCoefficients', '86', '5.98', '161000.69'),
			('g_L0EarthCoefficients', '85', '1.3', '6275.96'),
			('g_L0EarthCoefficients', '85', '3.67', '71430.7'),
			('g_L0EarthCoefficients', '80', '1.81', '17260.15'),
			('g_L0EarthCoefficients', '79', '3.04', '12036.46'),
			('g_L0EarthCoefficients', '75', '1.76', '5088.63'),
			('g_L0EarthCoefficients', '74', '3.5', '3154.69'),
			('g_L0EarthCoefficients', '74', '4.68', '801.82'),
			('g_L0EarthCoefficients', '70', '0.83', '9437.76'),
			('g_L0EarthCoefficients', '62', '3.98', '8827.39'),
			('g_L0EarthCoefficients', '61', '1.82', '7084.9'),
			('g_L0EarthCoefficients', '57', '2.78', '6286.6'),
			('g_L0EarthCoefficients', '56', '4.39', '14143.5'),
			('g_L0EarthCoefficients', '56', '3.47', '6279.55'),
			('g_L0EarthCoefficients', '52', '0.19', '12139.55'),
			('g_L0EarthCoefficients', '52', '1.33', '1748.02'),
			('g_L0EarthCoefficients', '51', '0.28', '5856.48'),
			('g_L0EarthCoefficients', '49', '0.49', '1194.45'),
			('g_L0EarthCoefficients', '41', '5.37', '8429.24'),
			('g_L0EarthCoefficients', '41', '2.4', '19651.05'),
			('g_L0EarthCoefficients', '39', '6.17', '10447.39'),
			('g_L0EarthCoefficients', '37', '6.04', '10213.29'),
			('g_L0EarthCoefficients', '37', '2.57', '1059.38'),
			('g_L0EarthCoefficients', '36', '1.71', '2352.87'),
			('g_L0EarthCoefficients', '36', '1.78', '6812.77'),
			('g_L0EarthCoefficients', '33', '0.59', '17789.85'),
			('g_L0EarthCoefficients', '30', '0.44', '83996.85'),
			('g_L0EarthCoefficients', '30', '2.74', '1349.87'),
			('g_L0EarthCoefficients', '25', '3.16', '4690.48'),
			('g_L1EarthCoefficients', '628331966747', '0', '0'),
			('g_L1EarthCoefficients', '206059', '2.678235', '6283.07585'),
			('g_L1EarthCoefficients', '4303', '2.6351', '12566.1517'),
			('g_L1EarthCoefficients', '425', '1.59', '3.523'),
			('g_L1EarthCoefficients', '119', '5.796', '26.298'),
			('g_L1EarthCoefficients', '109', '2.966', '1577.344'),
			('g_L1EarthCoefficients', '93', '2.59', '18849.23'),
			('g_L1EarthCoefficients', '72', '1.14', '529.69'),
			('g_L1EarthCoefficients', '68', '1.87', '398.15'),
			('g_L1EarthCoefficients', '67', '4.41', '5507.55'),
			('g_L1EarthCoefficients', '59', '2.89', '5223.69'),
			('g_L1EarthCoefficients', '56', '2.17', '155.42'),
			('g_L1EarthCoefficients', '45', '0.4', '796.3'),
			('g_L1EarthCoefficients', '36', '0.47', '775.52'),
			('g_L1EarthCoefficients', '29', '2.65', '7.11'),
			('g_L1EarthCoefficients', '21', '5.43', '0.98'),
			('g_L1EarthCoefficients', '19', '1.85', '5486.78'),
			('g_L1EarthCoefficients', '19', '4.97', '213.3'),
			('g_L1EarthCoefficients', '17', '2.99', '6275.96'),
			('g_L1EarthCoefficients', '16', '0.03', '2544.31'),
			('g_L1EarthCoefficients', '16', '1.43', '2146.17'),
			('g_L1EarthCoefficients', '15', '1.21', '10977.08'),
			('g_L1EarthCoefficients', '12', '2.83', '1748.02'),
			('g_L1EarthCoefficients', '12', '3.26', '5088.63'),
			('g_L1EarthCoefficients', '12', '5.27', '1194.45'),
			('g_L1EarthCoefficients', '12', '2.08', '4694'),
			('g_L1EarthCoefficients', '11', '0.77', '553.57'),
			('g_L1EarthCoefficients', '10', '1.3', '6286.6'),
			('g_L1EarthCoefficients', '10', '4.24', '1349.87'),
			('g_L1EarthCoefficients', '9', '2.7', '242.73'),
			('g_L1EarthCoefficients', '9', '5.64', '951.72'),
			('g_L1EarthCoefficients', '8', '5.3', '2352.87'),
			('g_L1EarthCoefficients', '6', '2.65', '9437.76'),
			('g_L1EarthCoefficients', '6', '4.67', '4690.48'),
			('g_L2EarthCoefficients', '52919', '0', '0'),
			('g_L2EarthCoefficients', '8720', '1.0721', '6283.0758'),
			('g_L2EarthCoefficients', '309', '0.867', '12566.152'),
			('g_L2EarthCoefficients', '27', '0.05', '3.52'),
			('g_L2EarthCoefficients', '16', '5.19', '26.3'),
			('g_L2EarthCoefficients', '16', '3.68', '155.42'),
			('g_L2EarthCoefficients', '10', '0.76', '18849.23'),
			('g_L2EarthCoefficients', '9', '2.06', '77713.77'),
			('g_L2EarthCoefficients', '7', '0.83', '775.52'),
			('g_L2EarthCoefficients', '5', '4.66', '1577.34'),
			('g_L2EarthCoefficients', '4', '1.03', '7.11'),
			('g_L2EarthCoefficients', '4', '3.44', '5573.14'),
			('g_L2EarthCoefficients', '3', '5.14', '796.3'),
			('g_L2EarthCoefficients', '3', '6.05', '5507.55'),
			('g_L2EarthCoefficients', '3', '1.19', '242.73'),
			('g_L2EarthCoefficients', '3', '6.12', '529.69'),
			('g_L2EarthCoefficients', '3', '0.31', '398.15'),
			('g_L2EarthCoefficients', '3', '2.28', '553.57'),
			('g_L2EarthCoefficients', '2', '4.38', '5223.69'),
			('g_L2EarthCoefficients', '2', '3.75', '0.98'),
			('g_L3EarthCoefficients', '289', '5.844', '6283.076'),
			('g_L3EarthCoefficients', '35', '0', '0'),
			('g_L3EarthCoefficients', '17', '5.49', '12566.15'),
			('g_L3EarthCoefficients', '3', '5.2', '155.42'),
			('g_L3EarthCoefficients', '1', '4.72', '3.52'),
			('g_L3EarthCoefficients', '1', '5.3', '18849.23'),
			('g_L3EarthCoefficients', '1', '5.97', '242.73'),
			('g_L4EarthCoefficients', '114', '3.142', '0'),
			('g_L4EarthCoefficients', '8', '4.13', '6283.08'),
			('g_L4EarthCoefficients', '1', '3.84', '12566.15'),
			('g_L5EarthCoefficients', '1', '3.14', '0')
			
	END --END EclipticLongitude
	
	--If EclipticLatitude is selected insert values into @Coefficients
	IF @EQ = 2
	BEGIN

		INSERT INTO @Coefficients
				(Coefficients, A, B, C)
		/*
			Constant Coefficients required for calculating Ecliptic Latitude
			
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
			
	END --END EclipticLatitude
	
	--If RadiusVector is selected insert values into @Coefficients
	IF @EQ = 3
	BEGIN

		INSERT INTO @Coefficients
				(Coefficients, A, B, C)
		/*
			Constant Coefficients required for calculating RadiusVector
			
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
			
	END --END RadiusVector
	
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
	DECLARE @L VARCHAR(50) = ''
	DECLARE @Limit INT = 0
	DECLARE @L0 FLOAT = 0.0
	DECLARE @L1 FLOAT = 0.0
	DECLARE @L2 FLOAT = 0.0
	DECLARE @L3 FLOAT = 0.0
	DECLARE @L4 FLOAT = 0.0
	DECLARE @L5 FLOAT = 0.0

	DECLARE @LMT INT = (SELECT COUNT(DISTINCT Coefficients) FROM @Coefficients)

	--Loop through each level of coefficients.
	WHILE (@i < @LMT)
	
	BEGIN
	
		SET @L = (SELECT DISTINCT(Coefficients) FROM @CoefficientsRow WHERE Coefficients LIKE '%' + CAST(@i AS VARCHAR) + '%')
		
		--Set limit for while loop		  
		SET @Limit = (SELECT COUNT(*) FROM @Coefficients WHERE Coefficients = @L)
		
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
								WHERE	Coefficients = @L
								AND	[Row] = (@j+1)
							) AS CO
					 )

			SET @j = @j + 1
		END
	
		--Set variables for return
		IF @i = 0
			BEGIN
				SET @L0 = @Val
			END
			
		IF @i = 1
			BEGIN
				SET @L1 = @Val
			END
			
		IF @i = 2
			BEGIN
				SET @L2 = @Val
			END
			
		IF @i = 3
			BEGIN
				SET @L3 = @Val
			END
			
		IF @i = 4
			BEGIN
				SET @L4 = @Val
			END
			
		IF @i = 5
			BEGIN
				SET @L5 = @Val
			END
	
		--Reinitialize variables for next run through the loop
		SET @Val = 0.0
		SET @j = 0
		SET @i = @i + 1	
	END
	
	DECLARE @FinalVal FLOAT = 0.0
	
	--Set the final return value based off of which function was selected
	IF @EQ = 1
	BEGIN
		SET @FinalVal = dbo.fn_EquinoxSolstice_Map0To360Range((((@L0 + (@L1 * @rho) + (@L2 * @rhosquared) + (@L3 * @rhocubed) + (@L4 * @rho4) + (@L5 * @rho5)) / 100000000.0) * 57.295779513082320876798154814105))
	END
	
	IF @EQ = 2
	BEGIN
		SET @FinalVal = (((@L0 + (@L1 * @rho) + (@L2 * @rhosquared) + (@L3 * @rhocubed) + (@L4 * @rho4)) / 100000000.0)* 57.295779513082320876798154814105)
	END
	
	IF @EQ = 3
	BEGIN
		SET @FinalVal = ((@L0 + (@L1 * @rho) + (@L2 * @rhosquared) + (@L3 * @rhocubed) + (@L4 * @rho4)) / 100000000.0)
	END

RETURN @FinalVal
END
