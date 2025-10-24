-- EMERGENCY FIX: Check and Fix SavingsAccount Balance Column
-- This fixes the DbUpdateException when updating balance

USE Banking_Details;
GO

PRINT '=== Checking SavingsAccount Balance Column ===';
PRINT '';

-- Check 1: Current column definition
PRINT '?? Current Balance Column Definition:';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
  NUMERIC_PRECISION,
    NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SavingsAccount' 
  AND COLUMN_NAME = 'Balance';

PRINT '';

-- Check 2: Sample data to see current values
PRINT '?? Sample Balance Values:';
SELECT TOP 5
    SBAccountID,
    Customerid,
    Balance,
    LEN(CAST(Balance AS VARCHAR(50))) AS 'Length',
    CASE 
        WHEN Balance > 1000000 THEN '?? Large balance'
        WHEN Balance < 0 THEN '? Negative!'
        ELSE '? OK'
    END AS 'Status'
FROM SavingsAccount
ORDER BY Balance DESC;

PRINT '';

-- Check 3: See if there are any constraints
PRINT '?? Constraints on SavingsAccount:';
SELECT 
    name AS 'Constraint Name',
    definition AS 'Definition'
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('SavingsAccount');

PRINT '';

-- The Fix: Ensure Balance column can handle large values
PRINT '?? Applying Fix...';
PRINT '';

-- Check if Balance column is too small (e.g., DECIMAL(10,2) instead of DECIMAL(18,2))
DECLARE @DataType NVARCHAR(50);
DECLARE @Precision INT;
DECLARE @Scale INT;

SELECT 
    @DataType = DATA_TYPE,
    @Precision = NUMERIC_PRECISION,
 @Scale = NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SavingsAccount' 
  AND COLUMN_NAME = 'Balance';

PRINT 'Current: ' + @DataType + '(' + CAST(@Precision AS VARCHAR) + ',' + CAST(@Scale AS VARCHAR) + ')';

IF @Precision < 18 OR @Scale < 2
BEGIN
  PRINT '? Balance column is too small!';
  PRINT '   Changing to DECIMAL(18,4) for better precision...';
    
    -- Alter column to handle larger values and more precision
    ALTER TABLE SavingsAccount
    ALTER COLUMN Balance DECIMAL(18,4);
    
    PRINT '? Balance column updated to DECIMAL(18,4)';
END
ELSE
BEGIN
    PRINT '? Balance column is already large enough: ' + @DataType + '(' + CAST(@Precision AS VARCHAR) + ',' + CAST(@Scale AS VARCHAR) + ')';
    
    -- Still increase precision for safety
  ALTER TABLE SavingsAccount
    ALTER COLUMN Balance DECIMAL(18,4);
    
    PRINT '? Increased precision to DECIMAL(18,4) for extra safety';
END

PRINT '';

-- Check 4: Verify fix
PRINT '?? Updated Column Definition:';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
  NUMERIC_SCALE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SavingsAccount' 
  AND COLUMN_NAME = 'Balance';

PRINT '';
PRINT '? Fix Complete!';
PRINT '';
PRINT '?? Now try closing the FD account again.';
PRINT '   The balance update should work now.';
GO
