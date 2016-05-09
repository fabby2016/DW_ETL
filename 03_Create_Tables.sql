USE HQ;
GO

/************************************************************************************
*
* Project:			HQ Assignment
* Object Type:	Ad-Hoc Script
* Author:				Fabrice Trarieux
* Created Date:	2016-05-07
*
* Description:	The purpose of this script is to create necessary tables for the assignment
*
*									- primary_data.lst_currency
*									- primary_data.fx_rate
*									- primary_data.offer
*									- bi_data.valid_offers
*									- bi_data.hotel_offers 
*
************************************************************************************/

SET NOCOUNT ON;
GO

-- Create heap table primary_data.lst_currency
IF OBJECT_ID ( N'primary_data.lst_currency' ) IS NOT NULL DROP TABLE primary_data.lst_currency;
GO

CREATE TABLE primary_data.lst_currency
(
	[id]			INT						NOT NULL,
	[code]		VARCHAR(50)		NOT NULL,
	[name]		VARCHAR(100)	NOT NULL
) ON [PRIMARY]
GO


-- Create heap table primary_data.fx_rate
IF OBJECT_ID ( N'primary_data.fx_rate' ) IS NOT NULL DROP TABLE primary_data.fx_rate;
GO

CREATE TABLE primary_data.fx_rate
(
	[id]									INT				NOT NULL,
	[prim_currency_id]		INT				NOT NULL,
	[scnd_currency_id]		INT				NOT NULL,
	[date]								DATE			NOT NULL,
	[currency_rate]				FLOAT			NOT NULL
) ON [PRIMARY]
GO

-- Create heap table primary_data.offer
IF OBJECT_ID ( N'primary_data.offer' ) IS NOT NULL DROP TABLE primary_data.offer;
GO

CREATE TABLE primary_data.offer
(
	[id]												INT					NOT NULL,
	[hotel_id]									INT					NOT NULL,
	[currency_id]								SMALLINT		NOT NULL,
	[source_system_code]				VARCHAR(50) NOT NULL,
	[available_cnt]							SMALLINT		NOT NULL,
	[sellings_price]						FLOAT				NOT NULL,
	[checkin_date]							DATE				NOT NULL,
	[checkout_date]							DATE				NOT NULL,
	[valid_offer_flag]					TINYINT			NOT NULL,
	[offer_valid_from]					DATETIME		NOT NULL,
	[offer_valid_to]						DATETIME		NOT NULL,
	[breakfast_included_flag]		TINYINT			NOT NULL,
	[insert_datetime]						DATETIME		NOT NULL
) ON [PRIMARY]
GO

-- Create table bi_data.valid_offers
IF OBJECT_ID ( N'bi_data.valid_offers' ) IS NOT NULL DROP TABLE bi_data.valid_offers;
GO

CREATE TABLE bi_data.valid_offers
(
	[offer_id]								INT					NOT NULL,
	[hotel_id]								INT					NOT NULL,
	[price_usd]								FLOAT				NOT NULL,
	[original_price]					FLOAT				NOT NULL,
	[original_currency_code]	VARCHAR(35) NOT NULL,
	[breakfast_included_flag]	TINYINT			NOT NULL,
	[valid_from_date]					DATETIME		NOT NULL,
	[valid_to_date]						DATETIME		NOT NULL
) ON [PRIMARY]
GO

-- Create table bi_data.hotel_offers 
IF OBJECT_ID ( N'bi_data.hotel_offers ' ) IS NOT NULL DROP TABLE bi_data.hotel_offers ;
GO

CREATE TABLE bi_data.hotel_offers 
(
	[hotel_id]										INT				NOT NULL,
	[date]												DATE			NOT NULL,
	[hour]												TINYINT		NOT NULL,
	[breakfast_included_flag]			TINYINT		NOT NULL,
	[valid_offer_available_flag]	TINYINT		NOT NULL
) ON [PRIMARY]
GO
