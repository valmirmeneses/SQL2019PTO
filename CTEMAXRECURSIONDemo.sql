DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate DATE = '2026-01-01';

WITH DateCTE AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(day, 1, DateValue)
    FROM DateCTE
    WHERE DATEADD(day, 1, DateValue) <= @EndDate
)
SELECT DateValue
FROM DateCTE
OPTION (MAXRECURSION 365);

DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate DATE = '2026-01-02';
WITH DateCTE AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(day, 1, DateValue)
    FROM DateCTE
    WHERE DATEADD(day, 1, DateValue) <= @EndDate
)
SELECT DateValue
FROM DateCTE
OPTION (MAXRECURSION 365);