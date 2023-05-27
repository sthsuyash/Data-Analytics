/*
	Data Cleaning Project in SQL
*/

-- Create the database to import the dataset
CREATE DATABASE Housing;
---

-- Import the dataset in table using MS SQL Server import export

-- Select all data check the dataset
SELECT *
FROM Housing..Nashville;
---

-- Standarize Date Format
SELECT 
	SaleDate,
	CONVERT(date, SaleDate) AS UpdatedDate
FROM Housing..Nashville;
---

-- Update the SaleDate column datatype to date 
-- to only display the date
ALTER TABLE Housing..Nashville
ALTER COLUMN SaleDate date;
---

-- Populate Property Address Data

-- Check the NULL values
SELECT *
FROM Housing..Nashville
WHERE PropertyAddress IS NULL;

-- 
SELECT *
FROM Housing..Nashville
ORDER BY ParcelID;

-- UniqueID are different but ParcelID is repeating,
-- Since the PropertyAddress for same ParcelID tuples are same but with different UniqueID,
-- we can change the PropertyAddress of NULL to the corresponding ones by
-- Joining the table on self and then populating the null values where the uniqueIDs don't match
SELECT 
	--a.[UniqueID ],
	--b.[UniqueID ],
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM Housing..Nashville a
JOIN Housing..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL;

-- Populating
UPDATE b
SET PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM Housing..Nashville a
JOIN Housing..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress IS NULL;
---