-- Cleaning Data in  SQl Queries

select * 
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format
select SaleDateConverted, cONVERT (date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
Set SaleDate=convert (DAte,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted=convert (DAte,SaleDate)

-- populate property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out address into individual columns(Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
 
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address

from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)


Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
Set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))


select * from 
PortfolioProject.dbo.NashvilleHousing





select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 from 
PortfolioProject.dbo.NashvilleHousing



Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
Set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from 
PortfolioProject.dbo.NashvilleHousing

-- Change Y and N to Yes and No in 'Sold as vacant' field

select distinct (soldasvacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select soldasvacant,
case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant=case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end

--Remove Duplicates
with RowNumCTE as(
select *,
	row_number() over(
	Partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by 
					uniqueid
					) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by parcelid
)
delete
from RowNumCTE
where row_num >1
--order by PropertyAddress

with RowNumCTE as(
select *,
	row_number() over(
	Partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by 
					uniqueid
					) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by parcelid
)
select *
from RowNumCTE
where row_num >1


-- Delete Unused Columns

select * 
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict,propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column saledate


