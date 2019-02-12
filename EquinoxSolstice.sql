--Set Julian Date
--er.jsc.nasa.gov/seh/math16.thml

DECLARE @Y INT = DATEPART(YYYY,GETUTCDATE()) --I
DECLARE @M INT = DATEPART(MM,GETUTCDATE()) --J
DECLARE @D INT = DATEPART(DD,GETUTCDATE()) --K

DECLARE @JD DECIMAL(18,2) = @D - 32075 + 1461 * (@Y + 4800 + (@M - 14) / 12) / 4 + 367 * (@M - 2 - (@M - 14) / 12 * 12) / 12 - 3 * ((@Y + 4900 + (@M - 14) / 12) / 100) / 4

DECLARE @rho DECIMAL(18,2) = ((@JD - 2451545) / 365250)
DECLARE @rhosquared DECIMAL(18,2) = @rho * @rho
DECLARE @rhocubed DECIMAL(18,2) = @rhosquared * @rho
DECLARE @rho4 DECIMAL(18,2) = @rhocubed * @rho
DECLARE @rho5 DECIMAL(18,2) = @rho4 * @rho

DECLARE @i INT = 0
DECLARE @SQLL VARCHAR(1000) = ''
DECLARE @L0 DECIMAL(18,2) = 0.0
DECLARE @L1 DECIMAL(18,2) = 0.0
DECLARE @L2 DECIMAL(18,2) = 0.0
DECLARE @L3 DECIMAL(18,2) = 0.0
DECLARE @L4 DECIMAL(18,2) = 0.0
DECLARE @L5 DECIMAL(18,2) = 0.0

WHILE (@i < 6)

BEGIN

	SET @SQLL = 'SET @L' + CAST(@i AS VARCHAR) + ' = @L' + CAST(@i AS VARCHAR) + ' dbo.fn_EquinoxSolstice_EclipticLongitude(@JD,@i)'
	
	EXEC(@SQLL)
	
	SET @i = @i + 1
	
END

DECLARE @LVal DECIMAL(18,2) = ((@L0 + (@L1 * @rho) + (@L2 * @rhosquared) + (@L3 * @rhocubed) + (@L4 * @rho4) + (@L5 * @rho5)) / 100000000.0)

DECLARE @j INT = 0
DECLARE @SQLB VARCHAR(1000) = ''
DECLARE @B0 DECIMAL(18,2) = 0.0
DECLARE @B1 DECIMAL(18,2) = 0.0
DECLARE @B2 DECIMAL(18,2) = 0.0
DECLARE @B3 DECIMAL(18,2) = 0.0
DECLARE @B4 DECIMAL(18,2) = 0.0

WHILE (@j < 5)

BEGIN

	SET @SQLB = 'SET @B' + CAST(@j AS VARCHAR) + ' = @B' + CAST(@j AS VARCHAR) + ' dbo.fn_EquinoxSolstice_EclipticLatitude(@JD,@j)'
	
	EXEC(@SQLB)
	
	SET @j = @j + 1
	
END

DECLARE @BVal DECIMAL(18,2) = ((@B0 + (@B1 * @rho) + (@B2 * @rhosquared) + (@B3 * @rhocubed) + (@B4 * @rho4)) / 100000000.0)

SELECT @LVal AS LVal, @BVal AS BVal
