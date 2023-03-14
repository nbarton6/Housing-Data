select *
from NashvilleHousing

--Standard Date Format

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

select saledateconverted, convert(date,saledate)
from NashvilleHousing

--Populate Property Address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Individual Columns

select propertyaddress
from NashvilleHousing

select
substring(propertyaddress,1,charindex(',',propertyaddress)-1) as Address
,SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress,1,charindex(',',propertyaddress)-1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyaddress))

Select OwnerAddress
from NashvilleHousing

Select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

--Remove Duplicates

With RowNumCTE as (
Select*,
ROW_NUMBER() over(
Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) row_num
from NashvilleHousing
)
Delete
from RowNumCTE
where row_num > 1

