-- ============================================================
-- DEBUG: Check UserLogin Deletion for Employee
-- ============================================================
-- This script helps diagnose why UserLogin records aren't being deleted
-- when employees are deleted
-- ============================================================

USE Banking_Details;
GO

PRINT '========================================';
PRINT 'DEBUGGING USERLOGIN DELETION ISSUE';
PRINT '========================================';
PRINT '';

-- Step 1: Check if there are any FOREIGN KEY constraints on UserLogin
PRINT 'Step 1: Checking Foreign Key Constraints on UserLogin table...';
PRINT '';

SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fkc 
    ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'UserLogin'
   OR OBJECT_NAME(fk.referenced_object_id) = 'UserLogin';

PRINT '';
PRINT '========================================';

-- Step 2: Check for TRIGGERS on UserLogin table
PRINT 'Step 2: Checking Triggers on UserLogin table...';
PRINT '';

SELECT 
    name AS TriggerName,
    OBJECT_NAME(parent_id) AS TableName,
    type_desc AS TriggerType,
    is_disabled AS IsDisabled
FROM sys.triggers
WHERE parent_id = OBJECT_ID('UserLogin');

PRINT '';
PRINT '========================================';

-- Step 3: Check for TRIGGERS on Employee table (that might interfere)
PRINT 'Step 3: Checking Triggers on Employee table...';
PRINT '';

SELECT 
    name AS TriggerName,
    OBJECT_NAME(parent_id) AS TableName,
    type_desc AS TriggerType,
    is_disabled AS IsDisabled
FROM sys.triggers
WHERE parent_id = OBJECT_ID('Employee');

PRINT '';
PRINT '========================================';

-- Step 4: List all current Employee records with their UserLogin records
PRINT 'Step 4: Current Employee-UserLogin mapping...';
PRINT '';

SELECT 
    e.Empid,
    e.EmployeeName,
    e.DeptId,
    ul.UserID,
    ul.UserName,
    ul.Role,
    ul.ReferenceID
FROM Employee e
LEFT JOIN UserLogin ul ON e.Empid = ul.ReferenceID
ORDER BY e.Empid;

PRINT '';
PRINT '========================================';

-- Step 5: Check if there are any orphaned UserLogin records (ReferenceID doesn't match any Employee)
PRINT 'Step 5: Checking for orphaned UserLogin records (Employee Role)...';
PRINT '';

SELECT 
    ul.UserID,
    ul.UserName,
    ul.ReferenceID,
    'ORPHAN - Employee does not exist' AS Issue
FROM UserLogin ul
WHERE ul.Role = 'EMPLOYEE'
  AND NOT EXISTS (SELECT 1 FROM Employee e WHERE e.Empid = ul.ReferenceID);

PRINT '';
PRINT '========================================';

-- Step 6: Test deletion simulation (does not actually delete)
PRINT 'Step 6: Simulating deletion for first employee...';
PRINT '';

DECLARE @TestEmpId VARCHAR(50);

SELECT TOP 1 @TestEmpId = Empid 
FROM Employee 
WHERE Empid IN (SELECT ReferenceID FROM UserLogin WHERE Role = 'EMPLOYEE')
ORDER BY Empid;

IF @TestEmpId IS NOT NULL
BEGIN
    PRINT 'Test Employee ID: ' + @TestEmpId;
    
    -- Check what would be deleted
    PRINT 'UserLogin records that SHOULD be deleted:';
    SELECT * FROM UserLogin WHERE ReferenceID = @TestEmpId;
    
    PRINT '';
    PRINT 'Employee record that would be deleted:';
    SELECT * FROM Employee WHERE Empid = @TestEmpId;
END
ELSE
BEGIN
    PRINT 'No employees with UserLogin records found for testing.';
END

PRINT '';
PRINT '========================================';
PRINT 'DIAGNOSTIC COMPLETE';
PRINT '========================================';
PRINT '';
PRINT 'RECOMMENDED ACTIONS:';
PRINT '1. If you see Foreign Keys blocking deletion, they need to be removed';
PRINT '2. If you see Triggers, check if they prevent deletion';
PRINT '3. If you see orphaned records, run cleanup script';
PRINT '';

GO
