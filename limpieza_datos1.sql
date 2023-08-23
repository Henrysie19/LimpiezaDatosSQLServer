------------------------------------------------------------------------------------------------
-- Limpiar datos con SQL Queries

select *
from dbo.NashvilleHousing
------------------------------------------------------------------------------------------
-- Estandarizar el formato FechaVenta (Saledate)

select SaleDate, CONVERT(date,SaleDate)
from dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

-- Mostremos el Alter Table

--select SaleDateConverted
--from dbo.NashvilleHousing

-- Show PropertyAddress
select *
from dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

/*El principal problema que detectamos, son los duplicados en los datos; como el del ParcelID y EL Property Address
	creamos un Join duplicando la base de datos, especificando que, a.ParcelID = b.ParcelID*/ 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From dbo.NashvilleHousing a
Join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
----------------------------------------------------------------------------------------------------------------
-- Separa el Property Address en columnas individuales [dirección(address) City(ciudad), State(estado)]
select PropertyAddress
from dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Adress
from dbo.NashvilleHousing

/* COMENTARIO CODE: El Substring requiere de tres argumentos, seleccionar la columna,
	desde que parte comenzara a extraer los caracteres de la columna, y hasta donde terminara la columna,
	y si le ponen -1 o +1 sera por detras de ese caracter o por delante de ese caracter.
	Luego se creó otro substring para que separe el estado en una columna aparte. */

ALTER TABLE NashvilleHousing
add Ciudad_Dir NVARCHAR(250);

update NashvilleHousing
set Ciudad_Dir = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )

ALTER TABLE NashvilleHousing
add Estado NVARCHAR(250);

update NashvilleHousing
set Estado = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 
----------------------------------------------------------------------------------------------------------------
-- Ahora separaremos el OwnersAddress con otra funcion llamada PARSENAME
/* PARSENAME pide argumentos similaresa al SUBSTRING, solo que este es mas fácil y comodo. solo es combinarla 
	con la función replace y sleccionar la columna, dividirla entre los caratcteres que en este caso son ',' y '.' 
	y luego escoger la posicion de los caracaters a mostrar */

Select OwnerAddress
from NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
add Owner_Direccion NVARCHAR(250);

update NashvilleHousing
set Owner_Direccion = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
add Owner_Ciudad NVARCHAR(250);

update NashvilleHousing
set Owner_Ciudad = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
add Owner_Estado NVARCHAR(250);

update NashvilleHousing
set Owner_Estado = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
---------------------------------------------------------------------------------
-- Cambiar Y and N a Si o no en la columna "SoldAsVacant"

/* iniciamos revisando los characteres que tiene la columna y 
    Posteriormente corregimos las Y y N por si y no */

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
Group By SoldAsVacant
Order By SoldAsVacant


Select SoldAsVacant
, Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
--------------------------------------------------------------------------------
-- eliminar duplicados

With RowNumCTE AS(
Select *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
from NashvilleHousing
)
Select *
From RowNumCTE
Where row_num >1
-- Order By PropertyAddress

select *
from dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------
-- Eliminar  columnas inutiles

select *
from dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate