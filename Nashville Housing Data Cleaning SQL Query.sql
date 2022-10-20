/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Portfolio.dbo.[NashvilleHousing ]
--------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio.dbo.[NashvilleHousing ]

UPDATE [NashvilleHousing ]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [NashvilleHousing ]
ADD SaleDateConverted Date;

UPDATE [NashvilleHousing ]
SET SaleDateConverted = CONVERT(Date,SaleDate)


-------------------------------------------------------------------------------------------------------------------------------

--Filling missing 'Property Address' data

SELECT *
FROM Portfolio.dbo.[NashvilleHousing ] 
--WHERE PropertyAddress is null 
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.[NashvilleHousing ] a
JOIN Portfolio.dbo.[NashvilleHousing ] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio.dbo.[NashvilleHousing ] a
JOIN Portfolio.dbo.[NashvilleHousing ] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null 

-------------------------------------------------------------------------------------------------------------------------------

--Splitting 'Address' into separate Cloumns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio.dbo.[NashvilleHousing ]

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Portfolio.dbo.[NashvilleHousing ]

ALTER TABLE [NashvilleHousing ]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [NashvilleHousing ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [NashvilleHousing ]
ADD PropertySplitCity Nvarchar(255);

UPDATE [NashvilleHousing ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)as OwnerSplitState
FROM Portfolio.dbo.[NashvilleHousing ]


ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitState Nvarchar(255);

UPDATE [NashvilleHousing ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-------------------------------------------------------------------------------------------------------------------------------

--Chnage the 'Y' and 'N' to 'Yes' and 'No' respectively in 'SoldAsVacant' field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio.dbo.[NashvilleHousing ]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio.dbo.[NashvilleHousing ]

UPDATE Portfolio.dbo.[NashvilleHousing ]
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

FROM Portfolio.dbo.[NashvilleHousing ]
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns


SELECT *
FROM Portfolio.dbo.[NashvilleHousing ]

ALTER TABLE Portfolio.dbo.[NashvilleHousing ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate