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

-- Normalizing Address column
-- Separate into (Address, City)

SELECT PropertyAddress
FROM Housing..Nashville;

-- SUBSTRING(column, starting index to search from, number of characters from the index)
-- CHARINDEX('text', column) => returns the length at which the text is found in that column
-- -1 after the length as we want to exclude the last comma

-- CTE
WITH CTE_Address AS (
    SELECT
        PropertyAddress,
        CHARINDEX(',', PropertyAddress) AS index_of_comma
    FROM Housing..Nashville
)
-- SELECT * FROM CTE_Address;
SELECT
    SUBSTRING(PropertyAddress, 1, index_of_comma - 1) AS Address,
	SUBSTRING(PropertyAddress, index_of_comma + 1, LEN(PropertyAddress)) AS Addd
FROM CTE_Address;

-- Now add the splitted tables

-- Add Splitted Address
ALTER TABLE Housing..Nashville
ADD PropertySplitAddress NVARCHAR(255);

-- Update the column to fill the values
UPDATE Housing..Nashville
SET PropertySplitAddress = SUBSTRING(
								PropertyAddress, 
								1, 
								CHARINDEX(',', PropertyAddress) - 1
							);

ALTER TABLE Housing..Nashville
ADD PropertySplitCity NVARCHAR(255);

-- Update the column to fill the values
UPDATE Housing..Nashville
SET PropertySplitCity = SUBSTRING(
							PropertyAddress,
							CHARINDEX(',', PropertyAddress) + 1,
							LEN(PropertyAddress)
						);

SELECT * FROM Housing..Nashville;

-- Another way:
SELECT
	PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2) AS SplitAddress,
	PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1) AS SplitCity
FROM Housing..Nashville;
---

-- Normalize OwnerAddress column
-- Separate into (Address, City, State)

SELECT OwnerAddress
FROM Housing..Nashville;

-- Using PARSENAME
-- only useful with periods(.)
-- So replace the ',' in address with '.' by REPLACE
-- Selects from backwards, the comma separated values
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS SplitAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS SplitCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS SplitState
FROM Housing..Nashville;

-- Now, update the table to add the columns and their values
ALTER TABLE Housing..Nashville
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE Housing..Nashville
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE Housing..Nashville
ADD OwnerSplitState NVARCHAR(255);

UPDATE Housing..Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE Housing..Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE Housing..Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM Housing..Nashville;
---

-- Change the 'Sold as Vacant' field info
-- 'Y' for Yes
-- 'N' for No
SELECT
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant) AS Count
FROM Housing..Nashville
GROUP BY SoldAsVacant;

--
SELECT 
	SoldAsVacant,
	CASE SoldAsVacant
		WHEN 'Y' THEN 'Yes'
		WHEN 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Housing..Nashville;

-- OR
/* 
SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Housing..Nashville;
*/

-- update the column
UPDATE Housing..Nashville
SET SoldAsVacant = CASE SoldAsVacant
						WHEN 'Y' THEN 'Yes'
						WHEN 'N' THEN 'No'
					ELSE SoldAsVacant
					END;
---

-- Get rid of Duplicates

-- partition our data
WITH RowNumCTE AS(
	SELECT 
		*,
		ROW_NUMBER() OVER (
			PARTITION BY 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			ORDER BY UniqueID
		) AS RowNum
	FROM Housing..Nashville
)
--SELECT *
DELETE
FROM RowNumCTE
WHERE RowNum > 1;
--ORDER BY PropertyAddress;
---

-- Delete Unused columns

-- not usually used in raw data to delete
SELECT *
FROM Housing..Nashville;

ALTER TABLE Housing..Nashville
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;
---