USE HQ;
GO

/************************************************************************************
*
* Project:			HQ Assignment
* Object Type:	Ad-Hoc Script
* Author:				Fabrice Trarieux
* Created Date:	2016-05-08
*
* Description:	The purpose of this script is to perform the initial load of the table
*								bi_data.hotel_offers. Note that script is intended to be run only one
*								time. If you need to re-run it, it will truncate the table first to
*								avoid inserting multiple times the same data.
*
*								Please review the final result displaying the numbers of rows inserted
*
*	Important note:		Please note that to limit the duration of the process and the volume of data generated
*										I have limited (for the purposes of the assignment) to the month of November 2015. 
*										The total number of resulting rows is the cartesian product of 9861 hotels * 8760 hours
*										per year. Each year will generate 86,382,360 rows of data, this could end up to a monster
*										periodic snaphot table. If you would like to process the entire offers, please uncomment
*										the section below
*
*			Rows inserted in bi_data.hotel_offers (month of November 2015): 7,099,920
^
*			Execution time on my machine:  3 minutes 06 sec
**********************************************************************************************/

SET NOCOUNT ON;
GO


-- Variable declaration
DECLARE @Start_Date	AS DATETIME;
DECLARE @End_Date AS DATETIME;

-- Uncomment this section if you wish to process the full offers dataset
--SELECT
--	@Start_Date = CAST ( MIN ( offer_valid_from ) AS DATE )	-- cast to date to remove the time portion
--	,@End_Date	= CAST ( MAX ( offer_valid_to ) AS DATE ) -- cast to date to remove the time portion
--FROM
--	primary_data.offer
--WHERE
--	offer_valid_from > '2015-01-01' --'2013-01-01'
--	AND offer_valid_to < '2016-01-01';
-- SELECT @Start_Date, @End_Date;

-- to limit the process runtime for the purpose of the assignment
SET @Start_Date = '2015-11-01';
SET @End_Date		= '2015-12-01';

-- Truncate valid_offers table
TRUNCATE table [bi_data].[hotel_offers];

-- Helper to generate numbers from 0 to 9
WITH CTE_Num ( digit )
AS
(
	SELECT 0
	UNION ALL
	SELECT digit + 1 FROM CTE_Num WHERE digit < 9

),
-- Helper to generate numbers from 1 to 100000
CTE_Nums ( Number )
AS
(
	SELECT ROW_NUMBER () OVER ( ORDER BY d1.digit ) AS Number
	FROM CTE_Num AS D1
	CROSS JOIN CTE_Num AS D2
	CROSS JOIN CTE_Num AS D3
	CROSS JOIN CTE_Num AS D4
	CROSS JOIN CTE_Num AS D5
),
-- Helper to generate time series with 1 hour increment
CTE_Dates ( Calculated_Date, Calculated_Date2, Calculated_Time )
AS
(
	SELECT
		DATEADD ( HOUR, Number - 1, @Start_Date )
		,CAST ( DATEADD ( HOUR, Number - 1, @Start_Date ) AS DATE )
		,DATEPART ( HOUR, DATEADD ( HOUR, Number - 1, @Start_Date ) )
	FROM CTE_Nums
	WHERE Number <= DATEDIFF ( HOUR, @Start_Date, @End_Date )
),
-- Get the list of hotels, the assumption made is all 9861 hotels are always active
-- regardless the time period
CTE_Hotels ( hotel_id )
AS
(
	SELECT
		DISTINCT hotel_id
	FROM
		primary_data.offer
)

-- Generate data for each hotel, each day and each hour 
-- and put the result in a temp table
SELECT
	h.hotel_id
	,d.Calculated_Date
	,d.Calculated_Date2
	,d.Calculated_Time
	,0 AS [breakfast_included_flag]
	,0 AS [valid_offer_available_flag]
INTO #temp_hotel_offers	-- Create automatically a temp table
FROM
	CTE_Hotels h
	CROSS JOIN CTE_Dates d;

-- Create aggregate valid offers temp table
SELECT
	hotel_id
	,DATEADD ( HOUR, DATEPART ( HOUR, offer_valid_from ), CAST ( CAST ( offer_valid_from AS DATE ) AS DATETIME ) ) AS offer_valid_from_date
	,DATEADD ( HOUR, DATEPART ( HOUR, offer_valid_to ) + 1, CAST ( CAST ( offer_valid_to AS DATE ) AS DATETIME ) ) AS offer_valid_to_date
	,MAX ( breakfast_included_flag ) AS breakfast_included_flag
INTO #temp_aggregate_valid_offers
FROM
	primary_data.offer
WHERE
	valid_offer_flag			= 1
	AND offer_valid_from	>= @Start_Date
	AND offer_valid_to		< @End_Date
GROUP BY
	hotel_id
	,DATEADD ( HOUR, DATEPART ( HOUR, offer_valid_from ), CAST ( CAST ( offer_valid_from AS DATE ) AS DATETIME ) )
	,DATEADD ( HOUR, DATEPART ( HOUR, offer_valid_to ) + 1, CAST ( CAST ( offer_valid_to AS DATE ) AS DATETIME ) )


-- Update the valide_offer_available flag to 1 if at least one valid offer 
-- exists within the specific day and hour
UPDATE o
SET
	o.valid_offer_available_flag = 1
	, o.breakfast_included_flag =  ( SELECT MAX ( breakfast_included_flag ) 
																		FROM #temp_aggregate_valid_offers y
																		WHERE
																			o.hotel_id = y.hotel_id
																			AND Calculated_Date >= y.offer_valid_from_date
																			AND Calculated_Date < y.offer_valid_to_date )
FROM
	#temp_hotel_offers o
WHERE
EXISTS
(
	SELECT 1
	FROM
		#temp_aggregate_valid_offers x
	WHERE
		o.hotel_id = x.hotel_id
		AND Calculated_Date >= x.offer_valid_from_date
		AND Calculated_Date < x.offer_valid_to_date
);

-- Load data into bi_data.hotel_offers
INSERT INTO [bi_data].[hotel_offers]
(
	[hotel_id]
	,[date]
	,[hour]
	,[breakfast_included_flag]
	,[valid_offer_available_flag]
)
SELECT
	hotel_id
	,Calculated_Date2
	,Calculated_Time
	,breakfast_included_flag
	,valid_offer_available_flag
FROM
	#temp_hotel_offers;

-- Cleaning up
DROP TABLE #temp_hotel_offers;
DROP TABLE #temp_aggregate_valid_offers;

-- Return result
SELECT 'Rows inserted in bi_data.hotel_offers', COUNT(*) FROM bi_data.hotel_offers;
