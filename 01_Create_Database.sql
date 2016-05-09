USE [master]
GO

/************************************************************************************
*
* Project:			HQ Assignment
* Object Type:	Ad-Hoc Script
* Author:				Fabrice Trarieux
* Created Date:	2016-05-07
*
* Description:	The purpose of this script is to create the database called HQ
*
*
************************************************************************************/

CREATE DATABASE [HQ]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HQ', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\HQ.mdf' , SIZE = 4096KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'HQ_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\HQ_log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
GO

