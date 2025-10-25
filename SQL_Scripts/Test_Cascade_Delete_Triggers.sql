-- ============================================================
-- TEST SCRIPT: UserLogin Cascade Delete Triggers
-- ============================================================
-- This script tests that UserLogin records are automatically
-- deleted when Employee, Customer, or Manager is deleted
-- ============================================================

USE Banking_Detail;  -- Note: Your database is "Banking_Detail" not "Banking_Details"
GO

PRINT '';
PRINT '============================================================';
PRINT 'TESTING USERLOGIN CASCADE DELETE TRIGGERS';
PRINT '============================================================';
PRINT '';

-- ============================================================
-- SETUP: Create Test Data (using SHORT IDs that fit in VARCHAR(8))
-- ============================================================

PRINT 'Creating test data...';
PRINT '';

-- Test Employee (IDs shortened to fit VARCHAR(8))
DECLARE @TestEmpId VARCHAR(50) = 'TESTEMP1';  -- 8 characters
DECLARE @TestEmpUserID VARCHAR(50) = 'TESTUSR1';  -- 8 characters

-- Test Customer (IDs shortened to fit VARCHAR(8))
DECLARE @TestCustId VARCHAR(50) = 'TESTCUS1';  -- 8 characters
DECLARE @TestCustUserID VARCHAR(50) = 'TESTUSR2';  -- 8 characters

-- Test Manager (IDs shortened to fit VARCHAR(8))
DECLARE @TestMgrId VARCHAR(50) = 'TESTMGR1';  -- 8 characters
DECLARE @TestMgrUserID VARCHAR(50) = 'TESTUSR3';  -- 8 characters

-- Clean up any existing test data
DELETE FROM UserLogin WHERE UserID IN (@TestEmpUserID, @TestCustUserID, @TestMgrUserID);
DELETE FROM Employee WHERE Empid = @TestEmpId;
DELETE FROM Customer WHERE Custid = @TestCustId;
DELETE FROM Manager WHERE ManagerID = @TestMgrId;

PRINT 'Test data cleaned up.';
PRINT '';

-- ============================================================
-- TEST 1: Employee Deletion Triggers UserLogin Deletion
-- ============================================================

PRINT '------------------------------------------------------------';
PRINT 'TEST 1: Employee Deletion';
PRINT '------------------------------------------------------------';
PRINT '';

-- Insert test employee (PAN column uses lowercase 'an')
INSERT INTO Employee (Empid, EmployeeName, DeptId, Pan)
VALUES (@TestEmpId, 'Test Employee', 'DEPT01', 'TESTP0001E');

-- Insert test employee UserLogin
INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID)
VALUES (@TestEmpUserID, 'testemployee', 'TestPassword123', 'EMPLOYEE', @TestEmpId);

PRINT 'Created test Employee and UserLogin:';
SELECT e.Empid, e.EmployeeName, ul.UserID, ul.UserName, ul.Role
FROM Employee e
INNER JOIN UserLogin ul ON e.Empid = ul.ReferenceID
WHERE e.Empid = @TestEmpId;

PRINT '';
PRINT 'Deleting Employee...';

-- Delete the employee (trigger should delete UserLogin)
DELETE FROM Employee WHERE Empid = @TestEmpId;

PRINT '';
PRINT 'Checking if UserLogin was automatically deleted...';

-- Check if UserLogin still exists
IF EXISTS (SELECT 1 FROM UserLogin WHERE UserID = @TestEmpUserID)
BEGIN
    PRINT '❌ FAIL: UserLogin still exists after Employee deletion!';
    SELECT * FROM UserLogin WHERE UserID = @TestEmpUserID;
END
ELSE
BEGIN
    PRINT '✓ PASS: UserLogin was automatically deleted by trigger.';
END

PRINT '';

-- ============================================================
-- TEST 2: Customer Deletion Triggers UserLogin Deletion
-- ============================================================

PRINT '------------------------------------------------------------';
PRINT 'TEST 2: Customer Deletion';
PRINT '------------------------------------------------------------';
PRINT '';

-- Insert test customer (using correct column names: Custname, DOB, PhoneNumber)
INSERT INTO Customer (Custid, Custname, DOB, Pan, Address, PhoneNumber)
VALUES (@TestCustId, 'Test Customer', '1990-01-01', 'TESTC0001C', 'Test Address', '9999999999');

-- Insert test customer UserLogin
INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID)
VALUES (@TestCustUserID, 'testcustomer', 'TestPassword123', 'CUSTOMER', @TestCustId);

PRINT 'Created test Customer and UserLogin:';
SELECT c.Custid, c.Custname, ul.UserID, ul.UserName, ul.Role
FROM Customer c
INNER JOIN UserLogin ul ON c.Custid = ul.ReferenceID
WHERE c.Custid = @TestCustId;

PRINT '';
PRINT 'Deleting Customer...';

-- Delete the customer (trigger should delete UserLogin)
DELETE FROM Customer WHERE Custid = @TestCustId;

PRINT '';
PRINT 'Checking if UserLogin was automatically deleted...';

-- Check if UserLogin still exists
IF EXISTS (SELECT 1 FROM UserLogin WHERE UserID = @TestCustUserID)
BEGIN
    PRINT '❌ FAIL: UserLogin still exists after Customer deletion!';
    SELECT * FROM UserLogin WHERE UserID = @TestCustUserID;
END
ELSE
BEGIN
    PRINT '✓ PASS: UserLogin was automatically deleted by trigger.';
END

PRINT '';

-- ============================================================
-- TEST 3: Manager Deletion Triggers UserLogin Deletion
-- ============================================================

PRINT '------------------------------------------------------------';
PRINT 'TEST 3: Manager Deletion';
PRINT '------------------------------------------------------------';
PRINT '';

-- Insert test manager
INSERT INTO Manager (ManagerID, ManagerName, PAN)
VALUES (@TestMgrId, 'Test Manager', 'TESTM0001M');

-- Insert test manager UserLogin
INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID)
VALUES (@TestMgrUserID, 'testmanager', 'TestPassword123', 'MANAGER', @TestMgrId);

PRINT 'Created test Manager and UserLogin:';
SELECT m.ManagerID, m.ManagerName, ul.UserID, ul.UserName, ul.Role
FROM Manager m
INNER JOIN UserLogin ul ON m.ManagerID = ul.ReferenceID
WHERE m.ManagerID = @TestMgrId;

PRINT '';
PRINT 'Deleting Manager...';

-- Delete the manager (trigger should delete UserLogin)
DELETE FROM Manager WHERE ManagerID = @TestMgrId;

PRINT '';
PRINT 'Checking if UserLogin was automatically deleted...';

-- Check if UserLogin still exists
IF EXISTS (SELECT 1 FROM UserLogin WHERE UserID = @TestMgrUserID)
BEGIN
    PRINT '❌ FAIL: UserLogin still exists after Manager deletion!';
    SELECT * FROM UserLogin WHERE UserID = @TestMgrUserID;
END
ELSE
BEGIN
    PRINT '✓ PASS: UserLogin was automatically deleted by trigger.';
END

PRINT '';

-- ============================================================
-- TEST SUMMARY
-- ============================================================

PRINT '============================================================';
PRINT 'TEST SUMMARY';
PRINT '============================================================';
PRINT '';
PRINT 'All three triggers were tested:';
PRINT '  1. trg_Employee_Delete_Cascade_UserLogin';
PRINT '  2. trg_Customer_Delete_Cascade_UserLogin';
PRINT '  3. trg_Manager_Delete_Cascade_UserLogin';
PRINT '';
PRINT 'If you see ✓ PASS for all three tests, the triggers are';
PRINT 'working correctly and will automatically delete UserLogin';
PRINT 'records when their corresponding entities are deleted.';
PRINT '';
PRINT '============================================================';
PRINT '';

GO
