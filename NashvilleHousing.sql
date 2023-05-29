--Cleaning data in sql queries 
SELECT *
FROM PortfolioProject..NashvilleHousing

--Standarizing the Date format from datetime to date
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

SELECT SaleDate
FROM PortfolioProject..NashvilleHousing

--Populate Property Address data 
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
-- The data that are null points back to their reference. Every Property Address has a ParcelID
SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL 

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID
--If a Parcel ID is equal to a Property Address then the nulled property address should be filled depending on their Parcel ID. 
--Self Join is one way of resolving it. 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
--With the select statement above, property address data needs to be updated so there will no longer be null values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--Char index shows the position of the comma thus if we subtract it by 1 then the comma will be removed. 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) AS Address--, CHARINDEX(',', PropertyAddress)
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) AS City 
FROM PortfolioProject..NashvilleHousing
--Creating 2 new columns in the dataset to seperate the address
ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))

--Breaking out Owner's address into (Address, City, State)
--Instead of Substring, making use of Parsename instead. Parsename looks for period as a divider. Replace can simply sub the value of a comma to a period.
SELECT PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
FROM PortfolioProject..NashvilleHousing
--Creating 3 new columns in the dataset to seperate the owner's address
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

--Change Y and N to Yes and No in "Sold as Vacant" Field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--Remove Duplicates
WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
--After finding out the duplicate values, the data must be removed
WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

--Delete unused Columns
SELECT *
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

