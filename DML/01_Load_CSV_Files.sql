USE HQ;
GO

/************************************************************************************
*
* Project:			HQ Assignment
* Object Type:	Ad-Hoc Script
* Author:				Fabrice Trarieux
* Created Date:	2016-05-08
*
* Description:	The purpose of this script is to load the 3 CSV files into the related
*								table. Please note that if you re-run this script to reload the files
*								it will truncate first the tables to avoid inserting multiple times the
*								the same files.
*
*								Please note that this script refers to a folder path that contains the CSV
*								and format files (.fmt). Feel free to modify this path if needed.
*
*								Please review the final result displaying the numbers of rows inserted
*	
*								Inserted rows in lst_currency:	24
*								Inserted rows in fx_rate:				114,625
*								Inserted rows in offer:					5,290,816
*
*								Execution time on my machine: 2 minutes
************************************************************************************/
SET NOCOUNT ON;
GO

-- Truncate primary_data.lst_currency
TRUNCATE TABLE primary_data.lst_currency;

-- Load lst_currency CSV file into primary_data.lst_currency
INSERT INTO primary_data.lst_currency WITH ( TABLOCK )	-- to minimize logging
(
	[id]
	,[code]
	,[name]
)
SELECT
	[id]
	,REPLACE ( REPLACE ( [code], '"', '' ), 'NULL', 'UNKN' )
	,REPLACE ( REPLACE ( [name], '"', '' ), 'NULL', 'Unknown' )
FROM 
	OPENROWSET ( BULK 'C:\HQ_Data_Source\lst_currency.csv'
							, FORMATFILE = 'C:\HQ_Data_Source\lst_currency.fmt' 
							, FIRSTROW = 2 ) AS F;

IF @@ERROR <> 0 OR @@ROWCOUNT = 0
	RAISERROR (	'lst_currency file not loaded. The loading process has stopped',	-- Message text
							16,							-- Severity
							1								-- State
							);

-- Truncate primary_data.fx_rate table
TRUNCATE TABLE primary_data.fx_rate;

-- Load fx_rate CSV file into primary_data.fx_rate
INSERT INTO primary_data.fx_rate WITH ( TABLOCK )	-- to minimize logging
(
	[id]
	,[prim_currency_id]
	,[scnd_currency_id]
	,[date]
	,[currency_rate]
)
SELECT
	[id]
	,[prim_currency_id]
	,[scnd_currency_id]
	,CAST ( REPLACE ( [date], '"', '' ) AS DATE )
	,CAST ( [currency_rate] AS FLOAT )
FROM 
	OPENROWSET ( BULK 'C:\HQ_Data_Source\fx_rate.csv'
							, FORMATFILE = 'C:\HQ_Data_Source\fx_rate.fmt' 
							, FIRSTROW = 2 ) AS F;

IF @@ERROR <> 0 OR @@ROWCOUNT = 0
	RAISERROR (	'fx_rate file not loaded. The loading process has stopped',	-- Message text
							16,							-- Severity
							1								-- State
							);

-- Truncate primary_data.offer table
TRUNCATE TABLE primary_data.offer;

-- Load offer CSV file into primary_data.offer

-- Please note that the CSV file contains 2 offers with hotel_id = NULL
-- I excluded those 2 rows for the purpose of this assignment
-- offer_id: 888373, insert_datetime: 2013-06-25 01:15:12
-- offer_id: 896710, insert_datetime: 2013-07-03 01:15:02
-- Loading time: 5,290,816 rows loaded in 39sec

INSERT INTO primary_data.offer WITH ( TABLOCK )	-- to minimize logging
(
	[id]
	,[hotel_id]
	,[currency_id]
	,[source_system_code]
	,[available_cnt]
	,[sellings_price]
	,[checkin_date]
	,[checkout_date]
	,[valid_offer_flag]
	,[offer_valid_from]
	,[offer_valid_to]
	,[breakfast_included_flag]
	,[insert_datetime]
)
SELECT
	[id]
	,[hotel_id]
	,ISNULL ( [currency_id], -1 )
	,[source_system_code]
	,CASE WHEN [available_cnt] < 0 THEN 0 ELSE ISNULL ( [available_cnt], 0 ) END
	,[sellings_price]
	,[checkin_date]
	,[checkout_date]
	,REPLACE ( [valid_offer_flag], -1, 0 )
	,[offer_valid_from]
	,[offer_valid_to]
	,REPLACE ( [breakfast_included_flag], -1, 0 )
	,[insert_datetime]
FROM 
	OPENROWSET ( BULK 'C:\HQ_Data_Source\offer.csv'
							, FORMATFILE = 'C:\HQ_Data_Source\offer.fmt' 
							, FIRSTROW = 1 ) AS F
WHERE
	[id] > 0
	AND [hotel_id] > 0;	-- exlude the row with id = -1

IF @@ERROR <> 0 OR @@ROWCOUNT = 0
	RAISERROR (	'offer file not loaded. The loading process has stopped',	-- Message text
							16,							-- Severity
							1								-- State
							);

-- Return result
SELECT 'Inserted rows in lst_currency:', COUNT(*) FROM primary_data.lst_currency UNION ALL
SELECT 'Inserted rows in fx_rate:', COUNT(*) FROM primary_data.fx_rate UNION ALL
SELECT 'Inserted rows in offer:', COUNT(*) FROM primary_data.offer;
