DECLARE @Min int;
DECLARE @Max int;
SET @Max = 150;
SET @Min = 1;
WITH Sequence_ AS
	(SELECT @Min AS num 
	UNION ALL 
	SELECT num + 1 FROM Sequence_ 
	WHERE num + 1 <= @Max)
SELECT num FROM Sequence_ --OPTION(MAXRECURSION 150)---32767)
