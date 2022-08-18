-------------------------------------------------------------------------------------------
-- Look at the data


select *
from housing_data






-------------------------------------------------------------------------------------------
-- Standardize Date Format


select SaleDate
from housing_data


update housing_data
set SaleDate = convert(date, SaleDate)







-------------------------------------------------------------------------------------------
-- Populate Property Address Data


select *
from housing_data
where PropertyAddress is null
order by ParcelID


-- Find duplicates in ParcelID
select ParcelID, count(*)
from housing_data
group by ParcelID
having count(ParcelID) >1
order by ParcelID


-- Some cells in PropertyAddress are null
-- Want to replace them with the information given by a different row with the same ParcelID
select a.PArcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from housing_data a
join housing_data b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


update a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from housing_data a
join housing_data b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null









-------------------------------------------------------------------------------------------
-- Break up PropertyAddress into Individual Columns (Address, City, State)


select PropertyAddress
from housing_data


-- Get data that we want
SELECT substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
    substring(PropertyAddress, charindex(',', PropertyAddress) + 2, len(PropertyAddress)) as Address
from housing_data


-- Create two new columns
alter table housing_data
add Address nvarchar(255)
update housing_data
set Address = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)


alter table housing_data
add City nvarchar(255)
update housing_data
set City = substring(PropertyAddress, charindex(',', PropertyAddress) + 2, len(PropertyAddress))


-- Do the same for owner address using parsename
select OwnerAddress
from housing_data


select parsename(replace(OwnerAddress, ', ','.'), 3),
parsename(replace(OwnerAddress, ', ','.'), 2),
parsename(replace(OwnerAddress, ', ','.'), 1)
from housing_data


-- Create columns and enter data
alter table housing_data
add OwnerAddress_split nvarchar(255)
update housing_data
set OwnerAddress_split = parsename(replace(OwnerAddress, ', ','.'), 3)


alter table housing_data
add OwnerCity nvarchar(255)
update housing_data
set OwnerCity = parsename(replace(OwnerAddress, ', ','.'), 2)


alter table housing_data
add OwnerState nvarchar(255)
update housing_data
set OwnerState = parsename(replace(OwnerAddress, ', ','.'), 1)










-------------------------------------------------------------------------------------------
-- Change SoldAsVacant to Yes No instead of Y and N


select distinct(SoldAsVacant), count(SoldAsVacant)
from housing_data
group by SoldAsVacant
order by 2


-- use CASE statement to replace
select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end
from housing_data


-- update table
update housing_data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end









-------------------------------------------------------------------------------------------
-- Remove Duplicants


-- identify duplicate rows, use CTE
with dup (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, row_num)
as (

select PropertyAddress, PropertyAddress, SalePrice, SaleDate, LegalReference,
    ROW_NUMBER() over (
    partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    order by UniqueID
) as row_num
from housing_data
--order by UniqueID 
)

select *
from dup
where row_num > 1


-- Look at a specific row to verify the code is correct and it is indeed a duplicate
select *,
    ROW_NUMBER() over (
    partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    order by UniqueID
) as row_num
from housing_data
where LegalReference = '20150205-0010843'


-- delete duplicates using the same code as above
with dup (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, row_num)
as (

select PropertyAddress, PropertyAddress, SalePrice, SaleDate, LegalReference,
    ROW_NUMBER() over (
    partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    order by UniqueID
) as row_num
from housing_data
--order by UniqueID 
)

delete
from dup
where row_num > 1









-------------------------------------------------------------------------------------------
-- Delete Unused Columns


-- remove columns that are not useful
alter TABLE housing_data
drop column OwnerAddress, TaxDistrict, PropertyAddress


select *
from housing_data







-------------------------------------------------------------------------------------------
-- Convert SalePrice to int Instead of nvarchar


-- look for dollar signs and commas in SalePrice
select SalePrice, TRY_PARSE(replace(SalePrice, '$', '') as int)
from housing_data
where SalePrice like '%$%'
    or SalePrice like '%,%'


-- remove dollar signs and commas from all values in SalePrice
update housing_data
set SalePrice = TRY_PARSE(replace(SalePrice, '$', '') as int)


-- convert SalePrice to int
alter table housing_data
alter COLUMN SalePrice int