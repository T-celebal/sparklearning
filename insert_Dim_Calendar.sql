CREATE PROC [metadata].[insert_Dim_Calendar] AS 
	
BEGIN 
	         
SET NOCOUNT ON
TRUNCATE TABLE   gold.Dim_Calendar
DECLARE @CurrentDate DATE = '2006-01-01'
DECLARE @EndDate DATE = '2024-12-31'
WHILE @CurrentDate < @EndDate
BEGIN
INSERT INTO  [gold].[Dim_Calendar] (
[DateKey],
[Date],
[Day],
[DaySuffix],
[Weekday],
[WeekDayName],
[WeekDayName_Short],
[WeekDayName_FirstLetter],
[DOWInMonth],
[DayOfYear],
[WeekOfMonth],
[WeekOfYear],
[Month],
[MonthName],
[MonthName_Short],
[MonthName_FirstLetter],
[Quarter],
[QuarterName],
[Year],
[MMYYYY],
[MonthYear],
[IsWeekend],
[IsHoliday],
[FirstDateofYear],
[LastDateofYear],
[FirstDateofQuater],
[LastDateofQuater],
[FirstDateofMonth],
[LastDateofMonth],
[FirstDateofWeek],
[LastDateofWeek]
)
SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
DATE = @CurrentDate,
Day = DAY(@CurrentDate),
[DaySuffix] = CASE
WHEN DAY(@CurrentDate) = 1
OR DAY(@CurrentDate) = 21
OR DAY(@CurrentDate) = 31
THEN 'st'
WHEN DAY(@CurrentDate) = 2
OR DAY(@CurrentDate) = 22
THEN 'nd'
WHEN DAY(@CurrentDate) = 3
OR DAY(@CurrentDate) = 23
THEN 'rd'
ELSE 'th'
END,
WEEKDAY = DATEPART(dw, @CurrentDate),
WeekDayName = DATENAME(dw, @CurrentDate),
WeekDayName_Short = UPPER(LEFT(DATENAME(dw, @CurrentDate), 3)),
WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 1),
[DOWInMonth] = DAY(@CurrentDate),
[DayOfYear] = DATENAME(dy, @CurrentDate),
[WeekOfMonth] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1,
[WeekOfYear] = DATEPART(wk, @CurrentDate),
[Month] = MONTH(@CurrentDate),
[MonthName] = DATENAME(mm, @CurrentDate),
[MonthName_Short] = UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
[MonthName_FirstLetter] = LEFT(DATENAME(mm, @CurrentDate), 1),
[Quarter] = DATEPART(q, @CurrentDate),
[QuarterName] = CASE
WHEN DATENAME(qq, @CurrentDate) = 1
THEN 'First'
WHEN DATENAME(qq, @CurrentDate) = 2
THEN 'second'
WHEN DATENAME(qq, @CurrentDate) = 3
THEN 'third'
WHEN DATENAME(qq, @CurrentDate) = 4
THEN 'fourth'
END,
[Year] = YEAR(@CurrentDate),
[MMYYYY] = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2) + CAST(YEAR(@CurrentDate) AS VARCHAR(4)),
[MonthYear] = CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
[IsWeekend] = CASE
WHEN DATENAME(dw, @CurrentDate) = 'Sunday'
OR DATENAME(dw, @CurrentDate) = 'Saturday'
THEN 1
ELSE 0
END,
[IsHoliday] = 0,
[FirstDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE),
[LastDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-31' AS DATE),
[FirstDateofQuater] = DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0),
[LastDateofQuater] = DATEADD(dd, - 1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)),
[FirstDateofMonth] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)) + '-01' AS DATE),
[LastDateofMonth] = EOMONTH(@CurrentDate),
[FirstDateofWeek] = DATEADD(dd, - (DATEPART(dw, @CurrentDate) - 1), @CurrentDate),
[LastDateofWeek] = DATEADD(dd, 7 - (DATEPART(dw, @CurrentDate)), @CurrentDate)
 
 
 
SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END
 
 
 
--Update Holiday information
UPDATE gold.Dim_Calendar
SET [IsHoliday] = 1,
[HolidayName] = 'Christmas'
WHERE [Month] = 12
AND [DAY] = 25
 
 
 
UPDATE gold.Dim_Calendar
SET SpecialDays = 'Valentines Day'
WHERE [Month] = 2
AND [DAY] = 14
 
 
 
--Update current date information
UPDATE gold.Dim_Calendar
SET CurrentYear = DATEDIFF(yy, GETDATE(), DATE),
CurrentQuater = DATEDIFF(q, GETDATE(), DATE),
CurrentMonth = DATEDIFF(m, GETDATE(), DATE),
CurrentWeek = DATEDIFF(ww, GETDATE(), DATE),
CurrentDay = DATEDIFF(dd, GETDATE(), DATE)
  
end