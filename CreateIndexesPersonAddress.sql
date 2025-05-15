USE AdventureWorks;
GO

-- Step 1: Drop existing indexes (excluding primary key constraint)
DROP INDEX IF EXISTS IX_Address_StateProvinceID ON Person.Address;
DROP INDEX IF EXISTS IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode ON Person.Address;
DROP INDEX IF EXISTS IX_Address_PostalCode ON Person.Address;
-- Add more DROP statements here if other indexes exist

-- Step 2: Recreate indexes
CREATE NONCLUSTERED INDEX IX_Address_StateProvinceID
ON Person.Address (StateProvinceID);

CREATE NONCLUSTERED INDEX IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode
ON Person.Address (AddressLine1, AddressLine2, City, StateProvinceID, PostalCode);

CREATE NONCLUSTERED INDEX IX_Address_PostalCode
ON Person.Address (PostalCode);
