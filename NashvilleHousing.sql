--Cleaning data in SQL for data NashvilleHousing

select *
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------

--Standardise SaleDate

select SaleDateConverted, Convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing 
SET SaleDate = Convert(Date,SaleDate)

Alter table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing 
SET SaleDateConverted = Convert(Date,SaleDate)

--------------------------------------------------------------------------------------------

--Populate Property Address Data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select tab1.ParcelID, tab1.PropertyAddress, tab2.ParcelID, tab2.PropertyAddress,
	ISNULL(tab1.PropertyAddress,tab2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing tab1
JOIN PortfolioProject.dbo.NashvilleHousing tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID] <> tab2.[UniqueID]
where tab1.PropertyAddress is null

Update tab1
SET PropertyAddress = ISNULL(tab1.PropertyAddress,tab2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing tab1
JOIN PortfolioProject.dbo.NashvilleHousing tab2
	on tab1.ParcelID = tab2.ParcelID
	AND tab1.[UniqueID] <> tab2.[UniqueID]
where tab1.PropertyAddress is null

--------------------------------------------------------------------------------------------

--Breaking address into individual columns (address, city, state)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

--splitting the address and the city by the use of substring
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

--adding new columns for splitting the address and the city
Alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

Alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

--crosschecking the above queries
select *
from PortfolioProject.dbo.NashvilleHousing


--separating owner address
select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


--altering the table and adding more columns to split the combined data

Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--crosschecking the above queries
select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------

--Change Y and N as Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

--using case statement here
select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
from PortfolioProject.dbo.NashvilleHousing

--updating the table's column now
update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant=case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

	 
--crosschecking the above queries
select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------

--Removing Duplicates

with RowNumCTE as(
Select *,
	ROW_NUMBER() Over(
	PARTITION by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					)row_num
	from PortfolioProject.dbo.NashvilleHousing
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress


--crosschecking the above queries
select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------

--Delete unused columns

select *
from PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



--------------------------------------------------------------------------------------------

--replacing all the NULL values as 0


--the easy way but has to be done for each column separately
UPDATE PortfolioProject.dbo.NashvilleHousing
set OwnerName = 0
where OwnerName is Null

UPDATE PortfolioProject.dbo.NashvilleHousing
set Acreage = 0
where Acreage is Null

UPDATE PortfolioProject.dbo.NashvilleHousing
set LandValue = 0
where LandValue is Null


UPDATE PortfolioProject.dbo.NashvilleHousing
set BuildingValue = 0
where BuildingValue is Null

UPDATE PortfolioProject.dbo.NashvilleHousing
set TotalValue = 0
where TotalValue is Null

UPDATE PortfolioProject.dbo.NashvilleHousing
set YearBuilt = 0
where YearBuilt is Null

UPDATE PortfolioProject.dbo.NashvilleHousing
set Bedrooms = 0
where Bedrooms is Null


UPDATE PortfolioProject.dbo.NashvilleHousing
set FullBath = 0
where FullBath is Null

UPDATE PortfolioProject.dbo.NashvilleHousing
set HalfBath = 0
where HalfBath is Null
UPDATE PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = 0
where OwnerSplitAddress is Null
UPDATE PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = 0
where OwnerSplitCity is Null

UPDATE PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = 0
where OwnerSplitState is Null

Select * 
from PortfolioProject.dbo.NashvilleHousing



