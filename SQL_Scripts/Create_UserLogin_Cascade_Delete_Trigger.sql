-- ============================================================
-- CREATE TRIGGERS: Auto-Delete UserLogin When Entity Deleted
-- ============================================================
-- This script creates triggers to automatically delete UserLogin records
-- when Employee, Customer, or Manager is deleted
-- ============================================================

USE Banking_Details;
GO

PRINT '';
PRINT '============================================================';
PRINT 'CREATING CASCADE DELETE TRIGGERS FOR USERLOGIN';
PRINT '============================================================';
PRINT '';

-- ============================================================
-- TRIGGER 1: Employee Deletion
-- ============================================================

-- Drop existing trigger if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Employee_Delete_Cascade_UserLogin')
BEGIN
    DROP TRIGGER trg_Employee_Delete_Cascade_UserLogin;
    PRINT 'Existing trigger dropped: trg_Employee_Delete_Cascade_UserLogin';
END
GO

-- Create trigger to cascade delete UserLogin when Employee is deleted
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
    
    -- Display count of deleted records (optional - for debugging)
    DECLARE @DeletedCount INT = @@ROWCOUNT;
    
    IF @DeletedCount > 0
    BEGIN
        PRINT CONCAT('Trigger: Deleted ', @DeletedCount, ' UserLogin record(s) for Employee deletion');
    END
END
GO

PRINT '? Trigger created: trg_Employee_Delete_Cascade_UserLogin';
PRINT '';

-- ============================================================
-- TRIGGER 2: Customer Deletion
-- ============================================================

-- Drop existing trigger if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Customer_Delete_Cascade_UserLogin')
BEGIN
    DROP TRIGGER trg_Customer_Delete_Cascade_UserLogin;
    PRINT 'Existing trigger dropped: trg_Customer_Delete_Cascade_UserLogin';
END
GO

-- Create trigger to cascade delete UserLogin when Customer is deleted
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
    
    -- Display count of deleted records (optional - for debugging)
    DECLARE @DeletedCount INT = @@ROWCOUNT;
    
    IF @DeletedCount > 0
    BEGIN
        PRINT CONCAT('Trigger: Deleted ', @DeletedCount, ' UserLogin record(s) for Customer deletion');
    END
END
GO

PRINT '? Trigger created: trg_Customer_Delete_Cascade_UserLogin';
PRINT '';

-- ============================================================
-- TRIGGER 3: Manager Deletion
-- ============================================================

-- Drop existing trigger if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_Manager_Delete_Cascade_UserLogin')
BEGIN
    DROP TRIGGER trg_Manager_Delete_Cascade_UserLogin;
    PRINT 'Existing trigger dropped: trg_Manager_Delete_Cascade_UserLogin';
END
GO

-- Create trigger to cascade delete UserLogin when Manager is deleted
CREATE TRIGGER trg_Manager_Delete_Cascade_UserLogin
ON Manager
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Delete UserLogin records where ReferenceID matches deleted Manager IDs
    DELETE ul
    FROM UserLogin ul
    INNER JOIN deleted d ON ul.ReferenceID = d.ManagerId
    WHERE ul.Role = 'MANAGER';
    
    -- Display count of deleted records (optional - for debugging)
    DECLARE @DeletedCount INT = @@ROWCOUNT;
    
    IF @DeletedCount > 0
    BEGIN
        PRINT CONCAT('Trigger: Deleted ', @DeletedCount, ' UserLogin record(s) for Manager deletion');
    END
END
GO

PRINT '? Trigger created: trg_Manager_Delete_Cascade_UserLogin';
PRINT '';

-- ============================================================
-- COMPLETION SUMMARY
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT 'ALL TRIGGERS CREATED SUCCESSFULLY';
PRINT '============================================================';
PRINT '';
PRINT 'The following triggers are now active:';
PRINT '';
PRINT '1. trg_Employee_Delete_Cascade_UserLogin';
PRINT '   - Table: Employee';
PRINT '   - Deletes UserLogin WHERE ReferenceID = Empid AND Role = EMPLOYEE';
PRINT '';
PRINT '2. trg_Customer_Delete_Cascade_UserLogin';
PRINT '   - Table: Customer';
PRINT '   - Deletes UserLogin WHERE ReferenceID = Custid AND Role = CUSTOMER';
PRINT '';
PRINT '3. trg_Manager_Delete_Cascade_UserLogin';
PRINT '   - Table: Manager';
PRINT '   - Deletes UserLogin WHERE ReferenceID = ManagerId AND Role = MANAGER';
PRINT '';
PRINT 'These triggers will automatically delete UserLogin records';
PRINT 'when their corresponding entity records are deleted.';
PRINT '============================================================';
PRINT '';

-- ============================================================
-- VERIFICATION: Check Triggers
-- ============================================================

PRINT 'Verifying trigger installation...';
PRINT '';

SELECT 
    t.name AS TriggerName,
    OBJECT_NAME(t.parent_id) AS TableName,
    t.type_desc AS TriggerType,
    CASE WHEN t.is_disabled = 0 THEN 'Enabled' ELSE 'Disabled' END AS Status
FROM sys.triggers t
WHERE t.name IN (
    'trg_Employee_Delete_Cascade_UserLogin',
    'trg_Customer_Delete_Cascade_UserLogin',
    'trg_Manager_Delete_Cascade_UserLogin'
)
ORDER BY OBJECT_NAME(t.parent_id);

PRINT '';
PRINT '============================================================';
PRINT 'INSTALLATION COMPLETE';
PRINT '============================================================';
PRINT '';

GO