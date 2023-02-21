/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[Nashville_Housing];
 
  --Cleaning data in SQL
  SELECT  * FROM Nashville_Housing;

  --Standardize date format
  SELECT SaleDate FROM Nashville_Housing;
  SELECT SaleDate,CONVERT(date,SaleDate) FROM Nashville_Housing;
  
  UPDATE Nashville_Housing
  SET SaleDate=CONVERT(date,SaleDate) 

  ALTER TABLE Nashville_Housing
  ADD SaleDateConverted DATE;

  UPDATE Nashville_Housing
  SET SaleDateConverted=CONVERT(date,SaleDate);

  --Populate Property Address data

  SELECT PropertyAddress FROM Nashville_Housing;
    SELECT * FROM Nashville_Housing
	WHERE PropertyAddress IS NULL;

 SELECT * FROM Nashville_Housing
	--WHERE PropertyAddress IS NULL;
	ORDER BY ParcelID;

 SELECT a.ParcelID,a.PropertyAddress,b.PropertyAddress,b.ParcelID,
 ISNULL(a.PropertyAddress,b.PropertyAddress) 
 FROM Nashville_Housing a
 JOIN Nashville_Housing b
 ON a.ParcelID=b.ParcelID
 AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL;

UPDATE a
SET a.PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM Nashville_Housing a
 JOIN Nashville_Housing b
 ON a.ParcelID=b.ParcelID
 AND a.[UniqueID ]<>b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL;

  --Breaking address column into(city,state,address)
  SELECT * FROM Nashville_Housing;
  SELECT SUBSTRING(PropertyAddress,1,10)
  
  FROM Nashville_Housing;
	--WHERE PropertyAddress IS NULL;
	--ORDER BY ParcelID;

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)  AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address1
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD PropertyAddressSplit NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertyAddressSplit=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);


ALTER TABLE Nashville_Housing
ADD PropertyAddressSplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET PropertyAddressSplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

SELECT OwnerAddress FROM Nashville_Housing;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) As City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) As State
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE Nashville_Housing
ADD OnwerSplitCity NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE Nashville_Housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashville_Housing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT * FROM Nashville_Housing;

 --change Y And N to YES and NO in sold as vacant column


SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No' 
ELSE SoldAsVacant END
FROM Nashville_Housing;

UPDATE Nashville_Housing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No' 
ELSE SoldAsVacant END
FROM Nashville_Housing;

SELECT SoldAsVacant,COUNT(SoldAsVacant) FROM Nashville_Housing
GROUP BY SoldAsVacant;
 SELECT * FROM Nashville_Housing;

  --Remove duplicates
  SELECT 
  ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                  PropertyAddress,
								  SalePrice,
								  SaleDate,
								  LegalReference
								  ORDER BY UniqueID
                                  )row_num,*
  FROM Nashville_Housing;

  WITH row_numbers AS
  (
  SELECT 
  ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                  PropertyAddress,
								  SalePrice,
								  SaleDate,
								  LegalReference
								  ORDER BY UniqueID
                                  )row_num,*
  FROM Nashville_Housing
  ) 
  DELETE  FROM row_numbers
  WHERE row_num>1
  --ORDER BY PropertyAddress;

  WITH row_numbers AS
  (
  SELECT 
  ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                  PropertyAddress,
								  SalePrice,
								  SaleDate,
								  LegalReference
								  ORDER BY UniqueID
                                  )row_num,*
  FROM Nashville_Housing
  ) 
  SELECT *  FROM row_numbers
  --WHERE row_num>1
  ORDER BY PropertyAddress;

  --Delete unused columns
  SELECT * FROM Nashville_Housing;

  ALTER TABLE Nashville_Housing
  DROP COLUMN [PropertyAddress],[OwnerAddress],[SaleDate],[TaxDistrict];

  
 