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
*								bi_data.valid_offers. Note that script is intended to be run only one
*								time. If you need to re-run it, it will truncate the table first to
*								avoid inserting multiple times the same data.
*
*								Please review the final result displaying the numbers of rows inserted
*
*								Rows inserted in bi_data.valid_offers:		3,373,887
*
*								Execution time on my machine:  1 minute 43 sec
************************************************************************************/

SET NOCOUNT ON;
GO

-- Variable declaration
DECLARE @Currency_US_Id AS INT;

-- Retrieve Currency_Id for US$
SELECT @Currency_US_Id = id
FROM primary_data.lst_currency
WHERE code = 'USD';

-- If no US$ currency found, raise an error
IF @Currency_US_Id IS NULL
	RAISERROR (	'US currency id not found. The loading process has stopped',	-- Message text
							16,							-- Severity
							1								-- State
							);

-- Truncate valid_offers table
TRUNCATE TABLE bi_data.valid_offers;

-- Initial Load data of bi_data.valid_offers only for active offers
-- Loading 3,373,887 in 20 sec
INSERT INTO bi_data.valid_offers
(
	[offer_id]
	,[hotel_id]
	,[price_usd]
	,[original_price]
	,[original_currency_code]
	,[breakfast_included_flag]
	,[valid_from_date]
	,[valid_to_date]
)
SELECT
	o.id
	,o.hotel_id
	,CASE WHEN o.currency_id = @Currency_US_Id THEN o.sellings_price ELSE 0 END	-- if purchase in US$ copy the amount
	,o.sellings_price
	,c.code
	,o.breakfast_included_flag
	,o.offer_valid_from
	,o.offer_valid_to
FROM
	primary_data.offer o
	INNER JOIN primary_data.lst_currency c
		ON c.id = o.currency_id
WHERE
	o.valid_offer_flag = 1;	-- include only valid offer

IF @@ERROR <> 0 OR @@ROWCOUNT = 0
	RAISERROR (	'An error occured when loading valid_offers. The loading process has stopped',	-- Message text
							16,							-- Severity
							1								-- State
							);

-- Convert price in US$

-- Please note that some currencies don't have any US exchane rate in the primary_data.fx_rate
-- ie: currency_id = 10 (Indonesian Rupiah) have any US$ rate starting in 2015
-- In this case and for the purpose of this assignement, the converted price in US$ will be 0
-- In the real world, I will investigate the system and ask BA people or product owner some clarifications
UPDATE vo
	SET vo.price_usd = o.sellings_price * currency_rate
--SELECT top 10 o.sellings_price * currency_rate
FROM
	bi_data.valid_offers vo
	INNER JOIN primary_data.offer o
		ON o.id = vo.offer_id
			AND o.hotel_id = vo.hotel_id
	INNER JOIN primary_data.fx_rate r
		ON r.prim_currency_id = o.currency_id
			AND r.scnd_currency_id = @Currency_US_Id	-- get US$ exchange rate
			AND DATEDIFF ( dd, r.[date], o.insert_datetime ) = 0	-- get the US$ exchange rate when the offer was created
WHERE
	o.currency_id <> 1;	-- get offers with original purchase not made in US$

IF @@ERROR <> 0 OR @@ROWCOUNT = 0
	RAISERROR (	'An error occured when upddating valid_offers. The loading process has stopped',	-- Message text
							16,							-- Severity
							1								-- State
							);

SELECT 'Rows inserted in bi_data.valid_offers', COUNT(*) FROM bi_data.valid_offers;