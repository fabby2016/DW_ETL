USE HQ;
GO

/************************************************************************************
*
* Project:			HQ Assignment
* Object Type:	Ad-Hoc Script
* Author:				Fabrice Trarieux
* Created Date:	2016-05-08
*
* Description:	The purpose of this script is to create index for performance purposes
*
*								Please note that it may take a while to generate those indexes
*
*		Execution time on my machine: 2 minutes 27 sec
************************************************************************************/
SET NOCOUNT ON;
GO

ALTER TABLE bi_data.valid_offers 
   ADD CONSTRAINT PK_valid_offers_offer_id PRIMARY KEY ( offer_id );

CREATE NONCLUSTERED INDEX IX_valid_offers_price_usd
    ON bi_data.valid_offers ( price_usd );

ALTER TABLE bi_data.hotel_offers 
   ADD CONSTRAINT PK_hotel_offers_hotel_id PRIMARY KEY ( [hotel_id], [date]	,[hour] );