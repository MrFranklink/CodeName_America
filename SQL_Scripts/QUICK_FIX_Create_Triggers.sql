-- ============================================================
-- QUICK FIX: Check and Create Triggers on Banking_Detail
-- ============================================================
-- This script checks if triggers exist and creates them if missing
-- ============================================================

-- ** IMPORTANT: Change database name to match YOUR database **
USE Banking_Detail;  -- Change this if your database name is different
GO

PRINT '============================================================';
PRINT 'STEP 1: Checking if triggers exist...';
PRINT '============================================================';
PRINT '';

-- Check if triggers exist
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Customer_Delete_Cascade_UserLogin')
    PRINT '? Customer trigger EXISTS'
ELSE
    PRINT '? Customer trigger MISSING';

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Employee_Delete_Cascade_UserLogin')
    PRINT '? Employee trigger EXISTS'
ELSE
    PRINT '? Employee trigger MISSING';

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Manager_Delete_Cascade_UserLogin')
    PRINT '? Manager trigger EXISTS'
ELSE
    PRINT '? Manager trigger MISSING';

PRINT '';
PRINT '============================================================';
PRINT 'STEP 2: Creating missing triggers...';
PRINT '============================================================';
PRINT '';

-- ============================================================
-- TRIGGER 1: Customer Deletion
-- ============================================================

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Customer_Delete_Cascade_UserLogin')
BEGIN
    DROP TRIGGER trg_Customer_Delete_Cascade_UserLogin;
    PRINT 'Dropped existing Customer trigger';
END
GO

CREATE TRIGGER trg_Customer_Delete_Cascade_UserLogin
ON Customer
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Delete UserLogin records where ReferenceID matches deleted Customer IDs
    DELETE ul
    FROM UserLogin ul
    INNER JOIN deleted d ON ul.ReferenceID = d.Custid
    WHERE ul.Role = 'CUSTOMER';
    
    DECLARE @DeletedCount INT = @@ROWCOUNT;
    
    IF @DeletedCount > 0
        PRINT CONCAT('Trigger: Deleted ', @DeletedCount, ' UserLogin record(s) for Customer');
END
GO

PRINT '? Customer trigger created';
PRINT '';

-- ============================================================
-- TRIGGER 2: Employee Deletion
-- ============================================================

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Employee_Delete_Cascade_UserLogin')
BEGIN
    DROP TRIGGER trg_Employee_Delete_Cascade_UserLogin;
    PRINT 'Dropped existing Employee trigger';
END
GO

CREATE TRIGGER trg_Employee_Delete_Cascade_UserLogin
ON Employee
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Delete UserLogin records where ReferenceID matches deleted Employee IDs
    DELETE ul
    FROM UserLogin ul
    INNER JOIN deleted d ON ul.ReferenceID = d.Empid
    WHERE ul.Role = 'EMPLOYEE';
    
    DECLARE @DeletedCount INT = @@ROWCOUNT;
    
    IF @DeletedCount > 0
        PRINT CONCAT('Trigger: Deleted ', @DeletedCount, ' UserLogin record(s) for Employee');
END
GO

PRINT '? Employee trigger created';
PRINT '';

-- ============================================================
-- TRIGGER 3: Manager Deletion
-- ============================================================

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Manager_Delete_Cascade_UserLogin')
BEGIN
    DROP TRIGGER trg_Manager_Delete_Cascade_UserLogin;
    PRINT 'Dropped existing Manager trigger';
END
GO

CREATE TRIGGER trg_Manager_Delete_Cascade_UserLogin
ON Manager
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Delete UserLogin records where ReferenceID matches deleted Manager IDs
    DELETE ul
    FROM UserLogin ul
    INNER JOIN deleted d ON ul.ReferenceID = d.ManagerID
    WHERE ul.Role = 'MANAGER';
    
    DECLARE @DeletedCount INT = @@ROWCOUNT;
    
    IF @DeletedCount > 0
        PRINT CONCAT('Trigger: Deleted ', @DeletedCount, ' UserLogin record(s) for Manager');
END
GO

PRINT '? Manager trigger created';
PRINT '';

-- ============================================================
-- VERIFICATION
-- ============================================================

PRINT '============================================================';
PRINT 'STEP 3: Verifying all triggers...';
PRINT '============================================================';
PRINT '';

SELECT 
    t.name AS TriggerName,
    OBJECT_NAME(t.parent_id) AS TableName,
    CASE WHEN t.is_disabled = 0 THEN 'Enabled ?' ELSE 'Disabled ?' END AS Status
FROM sys.triggers t
WHERE t.name IN (
    'trg_Customer_Delete_Cascade_UserLogin',
    'trg_Employee_Delete_Cascade_UserLogin',
    'trg_Manager_Delete_Cascade_UserLogin'
)
ORDER BY OBJECT_NAME(t.parent_id);

PRINT '';
PRINT '============================================================';
PRINT 'DONE! All triggers created successfully!';
PRINT '============================================================';
PRINT '';
PRINT 'Now try deleting a customer from your application.';
PRINT 'The UserLogin will be automatically deleted by the trigger.';
PRINT '';

GO
