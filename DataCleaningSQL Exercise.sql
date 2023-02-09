select *
from PortfolioProject.dbo.Housing

-- Standardizing the Date Format

select SaleDateConverted, Convert(Date, SaleDate)
From PortfolioProject.dbo.Housing

Update Housing
Set SaleDate = Convert(Date, SaleDate)

Alter TABLE Housing
ADD SaleDateConverted Date;

Update Housing
Set SaleDateConverted = Convert(Date, SaleDate)

-- Populating the property Address Data

select *
from PortfolioProject.dbo.Housing
--where PropertyAddress is null
Order by ParcelID

-- joined the ssame table to its self where the parcel id is the 
-- same but the unique ID is differnt it will populate the Property Addreess
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject.dbo.Housing a
Join PortfolioProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set propertyAddress = isnull(a.propertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.Housing a
Join PortfolioProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out the addrerss into seperate columns 

select PropertyAddress
from PortfolioProject.dbo.Housing
--where PropertyAddress is null
--Order by ParcelID

-- usings substring and CHAR index
-- This goes to the first value of propertyAdrress and going untill ','.
-- 
select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,Substring(propertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
 --CHARINDEX(',', PropertyAddress) -- specifies a position
  
from PortfolioProject.dbo.Housing

Alter TABLE Housing
ADD PropertySplitAddress Nvarchar(255);

Update Housing
Set PropertySplitAddress = Substring(propertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter TABLE Housing
ADD PropertySplitCity Nvarchar(255);

Update Housing
Set PropertySplitCity = Substring(propertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select * 
from PortfolioProject.dbo.Housing

-- Changing the owner Address

select OwnerAddress	
from PortfolioProject.dbo.Housing

-- Using Parse name
select
PARSENAME(replace(OwnerAddress, ',', '.'),3)
,PARSENAME(replace(OwnerAddress, ',', '.'),2)
,PARSENAME(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.Housing

Alter TABLE Housing
ADD OwnerSplitAddress Nvarchar(255);

Update Housing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3)

Alter TABLE Housing
ADD OwnerSplitCity Nvarchar(255);

Update Housing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2)
Alter TABLE Housing
ADD OwnerSplitState Nvarchar(255);

Update Housing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1)


-- Change Y and N into Yes and no in the 'Sold as Vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.Housing
group by SoldAsVacant
order by 2


Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  End
from PortfolioProject.dbo.Housing

update Housing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  Else SoldAsVacant
	  End

--Remove duplicates (Not a standard practice but useful none the less)

with RowNumCTE AS(
Select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				 SaleDate,
				 PropertyAddress,
				 LegalReference,
				 SalePrice
				 ORDER by 
					UniqueID
					) row_num

from PortfolioProject.dbo.Housing
--order by ParcelID
)
Delete
from RowNumCTE
where row_num > 1

-- Deleting unused columns 

Select * 
From PortfolioProject.dbo.Housing

Alter Table portfolioProject.dbo.Housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table portfolioProject.dbo.Housing
Drop Column SaleDate

