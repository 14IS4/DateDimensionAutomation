SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/********************************************************************************************
   Function: fn_EquinoxSolstice_NutationInLongitude

Description: Calcuates the sun's latitudinal position at a given Julian Date. This function is
			 used to populate the seasons for the yearly date load procedure. Do not delete!

*******************************************************************************************/

ALTER FUNCTION [dbo].[fn_EquinoxSolstice_NutationInLongitude] (@JD FLOAT)

RETURNS FLOAT
AS

BEGIN

	DECLARE @Coefficients TABLE
	(
		Coefficients	VARCHAR(50) NOT NULL,
		D		VARCHAR(50) NOT NULL,
		M		VARCHAR(50) NOT NULL,
		MPrime		VARCHAR(50) NOT NULL,
		F		VARCHAR(50) NOT NULL,
		omega		VARCHAR(50) NOT NULL,
		sincoeff1	VARCHAR(50) NOT NULL,
		sincoeff2	VARCHAR(50) NOT NULL,
		cosceff1	VARCHAR(50) NOT NULL,
		coscoeff2	VARCHAR(50) NOT NULL
	)

	DECLARE @CoefficientsRow TABLE
	(
		Coefficients	VARCHAR(50) NOT NULL,
		D		VARCHAR(50) NOT NULL,
		M		VARCHAR(50) NOT NULL,
		MPrime		VARCHAR(50) NOT NULL,
		F		VARCHAR(50) NOT NULL,
		omega		VARCHAR(50) NOT NULL,
		sincoeff1	VARCHAR(50) NOT NULL,
		sincoeff2	VARCHAR(50) NOT NULL,
		cosceff1	VARCHAR(50) NOT NULL,
		coscoeff2	VARCHAR(50) NOT NULL,
		[Row]		INT NOT NULL
	)


	INSERT INTO @Coefficients
			(Coefficients, D, M, MPrime, F, omega, sincoeff1, sincoeff2, cosceff1, coscoeff2)
	/*
		Constant Coefficients required for calculating Longitudinal Nutations
		
		**Note** Values are brought into variable table to circumvent the limitations of T-SQL. 
				 This mimicks a multi-dimensional array that we can loop through. The Julian Date that 
				 is brought in is required in the formulas so this data can not be consolidated.
				 Because it is a constant this will never require updating and must not be changed.
	*/				
	Values('g_NutationCoefficients', '0', '0', '0', '0', '1', '-171996', '-174.2', '92025', '8.9'),
		('g_NutationCoefficients', '-2', '0', '0', '2', '2', '-13187', '-1.6', '5736', '-3.1'),
		('g_NutationCoefficients', '0', '0', '0', '2', '2', '-2274', '-0.2', '977', '-0.5'),
		('g_NutationCoefficients', '0', '0', '0', '0', '2', '2062', '0.2', '-895', '0.5'),
		('g_NutationCoefficients', '0', '1', '0', '0', '0', '1426', '-3.4', '54', '-0.1'),
		('g_NutationCoefficients', '0', '0', '1', '0', '0', '712', '0.1', '-7', '0'),
		('g_NutationCoefficients', '-2', '1', '0', '2', '2', '-517', '1.2', '224', '-0.6'),
		('g_NutationCoefficients', '0', '0', '0', '2', '1', '-386', '-0.4', '200', '0'),
		('g_NutationCoefficients', '0', '0', '1', '2', '2', '-301', '0', '129', '-0.1'),
		('g_NutationCoefficients', '-2', '-1', '0', '2', '2', '217', '-0.5', '-95', '0.3'),
		('g_NutationCoefficients', '-2', '0', '1', '0', '0', '-158', '0', '0', '0'),
		('g_NutationCoefficients', '-2', '0', '0', '2', '1', '129', '0.1', '-70', '0'),
		('g_NutationCoefficients', '0', '0', '-1', '2', '2', '123', '0', '-53', '0'),
		('g_NutationCoefficients', '2', '0', '0', '0', '0', '63', '0', '0', '0'),
		('g_NutationCoefficients', '0', '0', '1', '0', '1', '63', '0.1', '-33', '0'),
		('g_NutationCoefficients', '2', '0', '-1', '2', '2', '-59', '0', '26', '0'),
		('g_NutationCoefficients', '0', '0', '-1', '0', '1', '-58', '-0.1', '32', '0'),
		('g_NutationCoefficients', '0', '0', '1', '2', '1', '-51', '0', '27', '0'),
		('g_NutationCoefficients', '-2', '0', '2', '0', '0', '48', '0', '0', '0'),
		('g_NutationCoefficients', '0', '0', '-2', '2', '1', '46', '0', '-24', '0'),
		('g_NutationCoefficients', '2', '0', '0', '2', '2', '-38', '0', '16', '0'),
		('g_NutationCoefficients', '0', '0', '2', '2', '2', '-31', '0', '13', '0'),
		('g_NutationCoefficients', '0', '0', '2', '0', '0', '29', '0', '0', '0'),
		('g_NutationCoefficients', '-2', '0', '1', '2', '2', '29', '0', '-12', '0'),
		('g_NutationCoefficients', '0', '0', '0', '2', '0', '26', '0', '0', '0'),
		('g_NutationCoefficients', '-2', '0', '0', '2', '0', '-22', '0', '0', '0'),
		('g_NutationCoefficients', '0', '0', '-1', '2', '1', '21', '0', '-10', '0'),
		('g_NutationCoefficients', '0', '2', '0', '0', '0', '17', '-0.1', '0', '0'),
		('g_NutationCoefficients', '2', '0', '-1', '0', '1', '16', '0', '-8', '0'),
		('g_NutationCoefficients', '-2', '2', '0', '2', '2', '-16', '0.1', '7', '0'),
		('g_NutationCoefficients', '0', '1', '0', '0', '1', '-15', '0', '9', '0'),
		('g_NutationCoefficients', '-2', '0', '1', '0', '1', '-13', '0', '7', '0'),
		('g_NutationCoefficients', '0', '-1', '0', '0', '1', '-12', '0', '6', '0'),
		('g_NutationCoefficients', '0', '0', '2', '-2', '0', '11', '0', '0', '0'),
		('g_NutationCoefficients', '2', '0', '-1', '2', '1', '-10', '0', '5', '0'),
		('g_NutationCoefficients', '2', '0', '1', '2', '2', '-8', '0', '3', '0'),
		('g_NutationCoefficients', '0', '1', '0', '2', '2', '7', '0', '-3', '0'),
		('g_NutationCoefficients', '-2', '1', '1', '0', '0', '-7', '0', '0', '0'),
		('g_NutationCoefficients', '0', '-1', '0', '2', '2', '-7', '0', '3', '0'),
		('g_NutationCoefficients', '2', '0', '0', '2', '1', '-7', '0', '3', '0'),
		('g_NutationCoefficients', '2', '0', '1', '0', '0', '6', '0', '0', '0'),
		('g_NutationCoefficients', '-2', '0', '2', '2', '2', '6', '0', '-3', '0'),
		('g_NutationCoefficients', '-2', '0', '1', '2', '1', '6', '0', '-3', '0'),
		('g_NutationCoefficients', '2', '0', '-2', '0', '1', '-6', '0', '3', '0'),
		('g_NutationCoefficients', '2', '0', '0', '0', '1', '-6', '0', '3', '0'),
		('g_NutationCoefficients', '0', '-1', '1', '0', '0', '5', '0', '0', '0'),
		('g_NutationCoefficients', '-2', '-1', '0', '2', '1', '-5', '0', '3', '0'),
		('g_NutationCoefficients', '-2', '0', '0', '0', '1', '-5', '0', '3', '0'),
		('g_NutationCoefficients', '0', '0', '2', '2', '1', '-5', '0', '3', '0'),
		('g_NutationCoefficients', '-2', '0', '2', '0', '1', '4', '0', '0', '0'),
		('g_NutationCoefficients', '-2', '1', '0', '2', '1', '4', '0', '0', '0'),
		('g_NutationCoefficients', '0', '0', '1', '-2', '0', '4', '0', '0', '0'),
		('g_NutationCoefficients', '-1', '0', '1', '0', '0', '-4', '0', '0', '0'),
		('g_NutationCoefficients', '-2', '1', '0', '0', '0', '-4', '0', '0', '0'),
		('g_NutationCoefficients', '1', '0', '0', '0', '0', '-4', '0', '0', '0'),
		('g_NutationCoefficients', '0', '0', '1', '2', '0', '3', '0', '0', '0'),
		('g_NutationCoefficients', '0', '0', '-2', '2', '2', '-3', '0', '0', '0'),
		('g_NutationCoefficients', '-1', '-1', '1', '0', '0', '-3', '0', '0', '0'),
		('g_NutationCoefficients', '0', '1', '1', '0', '0', '-3', '0', '0', '0'),
		('g_NutationCoefficients', '0', '-1', '1', '2', '2', '-3', '0', '0', '0'),
		('g_NutationCoefficients', '2', '-1', '-1', '2', '2', '-3', '0', '0', '0'),
		('g_NutationCoefficients', '0', '0', '3', '2', '2', '-3', '0', '0', '0'),
		('g_NutationCoefficients', '2', '-1', '0', '2', '2', '-3', '0', '0', '0')

	
	--Adding a row number to each of the levels of coefficients, a way to access each row individually during while loop
	INSERT INTO @CoefficientsRow (Coefficients, D, M, MPrime, F, omega, sincoeff1, sincoeff2, cosceff1, coscoeff2, [Row])
	SELECT Coefficients, D, M, MPrime, F, omega, sincoeff1, sincoeff2, cosceff1, coscoeff2, ROW_NUMBER() OVER(PARTITION BY Coefficients ORDER BY Coefficients) AS 'Row' FROM @Coefficients

	--Set variables for final return statement
	DECLARE @T FLOAT = ((@JD - 2451545) / 365250)
	DECLARE @Tsquared FLOAT = @T * @T
	DECLARE @Tcubed FLOAT = @Tsquared * @T
	
	--Initialize variables for while loops
	DECLARE @i INT = 0
	DECLARE @Val FLOAT = 0.0
	
	DECLARE @argument FLOAT = 0.0
	DECLARE @radargument FLOAT = 0.0
	
	DECLARE @D FLOAT = dbo.fn_EquinoxSolstice_Map0To360Range(297.85036 + (445267.111480 * @T) - (0.0019142 * @Tsquared) + @Tcubed / 189474)
	DECLARE @M FLOAT = dbo.fn_EquinoxSolstice_Map0To360Range(357.52772 + (35999.050340 * @T) - (0.0001603 * @Tsquared) - @Tcubed / 300000)
	DECLARE @MPrime FLOAT = dbo.fn_EquinoxSolstice_Map0To360Range(134.96298 + (477198.867398 * @T) + (0.0086972 * @Tsquared) + @Tcubed / 56250)
	DECLARE @F FLOAT = dbo.fn_EquinoxSolstice_Map0To360Range(93.27191 + (483202.017538 * @T) - (0.0036825 * @Tsquared) + @Tcubed / 327270)
	DECLARE @omega FLOAT = dbo.fn_EquinoxSolstice_Map0To360Range(125.04452 - (1934.136261 * @T) + (0.0020708 * @Tsquared) + @Tcubed / 450000)
		
	--Set limit for while loop		  
	DECLARE @Limit INT = (SELECT COUNT(*) FROM @Coefficients WHERE Coefficients = 'g_NutationCoefficients')
	
	--Begin looping through all of the coefficients in a single level
	WHILE (@i < @Limit)

	BEGIN
	
		SET @argument = @argument + (
						SELECT	SUM((AR.D * @D) + (AR.M * @M) + (AR.Mprime * @Mprime) + (AR.F * @F) + (AR.omega * @omega))
						FROM
							(
								SELECT	CAST(D AS FLOAT) AS D,
									CAST(M AS FLOAT) AS M,
									CAST(MPrime AS FLOAT) AS MPrime,
									CAST(F AS FLOAT) AS F,
									CAST(omega AS FLOAT) AS omega
								FROM	@CoefficientsRow
								WHERE	[Row] = (@i+1)
							) AS AR
					    )
									
		SET @radargument = @radargument + (@argument * 0.017453292519943295769236907684886)
	
		SET @Val = @Val + (
					SELECT	SUM((CO.sincoeff1 + CO.sincoeff2 * @T) * SIN(@radargument) * 0.0001)
					FROM
						(
							SELECT	CAST(sincoeff1 AS FLOAT) AS sincoeff1,
								CAST(sincoeff2 AS FLOAT) AS sincoeff2
							FROM	@CoefficientsRow
							WHERE	[Row] = (@i+1)
						) AS CO
				  )

		--Re-initialize variables
		SET @argument = 0.0
		SET @radargument = 0.0
		SET @i = @i + 1
	END

RETURN @Val
END

