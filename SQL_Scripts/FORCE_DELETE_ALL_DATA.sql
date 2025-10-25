-- ============================================================
-- FORCE DELETE ALL TABLE DATA - Banking Application
-- ============================================================
-- ?? WARNING: This script will DELETE ALL DATA from all tables!
-- ?? This is IRREVERSIBLE! Use with extreme caution!
-- ?? Recommended: Backup your database first!
-- ============================================================

USE Banking_Detail;  -- Change to your database name
GO

PRINT '';
PRINT '============================================================';
PRINT '??  WARNING: FORCE DELETE ALL DATA';
PRINT '============================================================';
PRINT '';
PRINT 'This will DELETE ALL DATA from the following tables:';
PRINT '  - SavingsTransaction';
PRINT '  - LoanTransaction';
PRINT '  - FundTransfer';
PRINT '  - SavingsAccount';
PRINT '  - FixedDepositAccount';
PRINT '  - LoanAccount';
PRINT '  - Account';
PRINT '  - UserLogin';
PRINT '  - Customer';
PRINT '  - Employee';
PRINT '  - Manager';
PRINT '';
PRINT 'Press Ctrl+C to cancel, or wait 5 seconds to continue...';
WAITFOR DELAY '00:00:05';
PRINT '';

-- ============================================================
-- STEP 1: Disable All Triggers (to prevent cascade issues)
-- ============================================================

PRINT '============================================================';
PRINT 'STEP 1: Disabling all triggers...';
PRINT '============================================================';
PRINT '';

-- Disable triggers on Customer
IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Customer_Delete_Cascade_UserLogin')
BEGIN
    DISABLE TRIGGER trg_Customer_Delete_Cascade_UserLogin ON Customer;
    PRINT '? Disabled: trg_Customer_Delete_Cascade_UserLogin';
END

-- Disable triggers on Employee
IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Employee_Delete_Cascade_UserLogin')
BEGIN
    DISABLE TRIGGER trg_Employee_Delete_Cascade_UserLogin ON Employee;
    PRINT '? Disabled: trg_Employee_Delete_Cascade_UserLogin';
END

-- Disable triggers on Manager
IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Manager_Delete_Cascade_UserLogin')
BEGIN
    DISABLE TRIGGER trg_Manager_Delete_Cascade_UserLogin ON Manager;
    PRINT '? Disabled: trg_Manager_Delete_Cascade_UserLogin';
END

PRINT '';

-- ============================================================
-- STEP 2: Disable All Foreign Key Constraints
-- ============================================================

PRINT '============================================================';
PRINT 'STEP 2: Disabling all foreign key constraints...';
PRINT '============================================================';
PRINT '';

DECLARE @sql_disable NVARCHAR(MAX) = N'';

SELECT @sql_disable = @sql_disable + 
    'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + 
    QUOTENAME(OBJECT_NAME(parent_object_id)) + 
    ' NOCHECK CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.foreign_keys;

IF LEN(@sql_disable) > 0
BEGIN
    EXEC sp_executesql @sql_disable;
    PRINT '? All foreign key constraints disabled';
END
ELSE
BEGIN
    PRINT '? No foreign key constraints found';
END

PRINT '';

-- ============================================================
-- STEP 3: Delete Data (in correct order to avoid FK violations)
-- ============================================================

PRINT '============================================================';
PRINT 'STEP 3: Deleting all data...';
PRINT '============================================================';
PRINT '';

-- Transaction Tables (no dependencies)
BEGIN TRY
    DELETE FROM SavingsTransaction;
    PRINT '? Deleted SavingsTransaction: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting SavingsTransaction: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    DELETE FROM LoanTransaction;
    PRINT '? Deleted LoanTransaction: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting LoanTransaction: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    DELETE FROM FundTransfer;
    PRINT '? Deleted FundTransfer: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting FundTransfer: ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- Account Sub-Tables (child tables)
BEGIN TRY
    DELETE FROM SavingsAccount;
    PRINT '? Deleted SavingsAccount: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting SavingsAccount: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    DELETE FROM FixedDepositAccount;
    PRINT '? Deleted FixedDepositAccount: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting FixedDepositAccount: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    DELETE FROM LoanAccount;
    PRINT '? Deleted LoanAccount: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting LoanAccount: ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- Account Table (parent of all account types)
BEGIN TRY
    DELETE FROM Account;
    PRINT '? Deleted Account: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting Account: ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- UserLogin (references Customer, Employee, Manager)
BEGIN TRY
    DELETE FROM UserLogin;
    PRINT '? Deleted UserLogin: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting UserLogin: ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- Entity Tables
BEGIN TRY
    DELETE FROM Customer;
    PRINT '? Deleted Customer: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting Customer: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    DELETE FROM Employee;
    PRINT '? Deleted Employee: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting Employee: ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
    DELETE FROM Manager;
    PRINT '? Deleted Manager: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END TRY
BEGIN CATCH
    PRINT '? Error deleting Manager: ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- ============================================================
-- STEP 4: Re-enable Foreign Key Constraints
-- ============================================================

PRINT '============================================================';
PRINT 'STEP 4: Re-enabling foreign key constraints...';
PRINT '============================================================';
PRINT '';

DECLARE @sql_enable NVARCHAR(MAX) = N'';

SELECT @sql_enable = @sql_enable + 
    'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + 
    QUOTENAME(OBJECT_NAME(parent_object_id)) + 
    ' CHECK CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.foreign_keys;

IF LEN(@sql_enable) > 0
BEGIN
    EXEC sp_executesql @sql_enable;
    PRINT '? All foreign key constraints re-enabled';
END

PRINT '';

-- ============================================================
-- STEP 5: Re-enable All Triggers
-- ============================================================

PRINT '============================================================';
PRINT 'STEP 5: Re-enabling all triggers...';
PRINT '============================================================';
PRINT '';

-- Re-enable triggers on Customer
IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Customer_Delete_Cascade_UserLogin')
BEGIN
    ENABLE TRIGGER trg_Customer_Delete_Cascade_UserLogin ON Customer;
    PRINT '? Enabled: trg_Customer_Delete_Cascade_UserLogin';
END

-- Re-enable triggers on Employee
IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Employee_Delete_Cascade_UserLogin')
BEGIN
    ENABLE TRIGGER trg_Employee_Delete_Cascade_UserLogin ON Employee;
    PRINT '? Enabled: trg_Employee_Delete_Cascade_UserLogin';
END

-- Re-enable triggers on Manager
IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Manager_Delete_Cascade_UserLogin')
BEGIN
    ENABLE TRIGGER trg_Manager_Delete_Cascade_UserLogin ON Manager;
    PRINT '? Enabled: trg_Manager_Delete_Cascade_UserLogin';
END

PRINT '';

-- ============================================================
-- STEP 6: Reset Identity Seeds (if using IDENTITY columns)
-- ============================================================

PRINT '============================================================';
PRINT 'STEP 6: Resetting IDENTITY seeds...';
PRINT '============================================================';
PRINT '';

-- Reset SavingsTransaction identity (if exists)
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('SavingsTransaction'))
BEGIN
    DBCC CHECKIDENT ('SavingsTransaction', RESEED, 0);
    PRINT '? Reset SavingsTransaction identity to 0';
END

-- Reset LoanTransaction identity (if exists)
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('LoanTransaction'))
BEGIN
    DBCC CHECKIDENT ('LoanTransaction', RESEED, 0);
    PRINT '? Reset LoanTransaction identity to 0';
END

-- Reset FundTransfer identity (if exists)
IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('FundTransfer'))
BEGIN
    DBCC CHECKIDENT ('FundTransfer', RESEED, 0);
    PRINT '? Reset FundTransfer identity to 0';
END

PRINT '';

-- ============================================================
-- STEP 7: Verification - Count Remaining Rows
-- ============================================================

PRINT '============================================================';
PRINT 'STEP 7: Verifying deletion...';
PRINT '============================================================';
PRINT '';

DECLARE @TotalRows INT = 0;

DECLARE @RowCount INT;

SELECT @RowCount = COUNT(*) FROM SavingsTransaction;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'SavingsTransaction: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM LoanTransaction;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'LoanTransaction: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM FundTransfer;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'FundTransfer: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM SavingsAccount;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'SavingsAccount: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM FixedDepositAccount;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'FixedDepositAccount: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM LoanAccount;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'LoanAccount: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM Account;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'Account: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM UserLogin;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'UserLogin: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM Customer;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'Customer: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM Employee;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'Employee: ' + CAST(@RowCount AS VARCHAR) + ' rows';

SELECT @RowCount = COUNT(*) FROM Manager;
SET @TotalRows = @TotalRows + @RowCount;
PRINT 'Manager: ' + CAST(@RowCount AS VARCHAR) + ' rows';

PRINT '';
PRINT '------------------------------------------------------------';
PRINT 'Total rows remaining: ' + CAST(@TotalRows AS VARCHAR);
PRINT '------------------------------------------------------------';

IF @TotalRows = 0
BEGIN
    PRINT '';
    PRINT '??? SUCCESS! All data deleted from all tables!';
END
ELSE
BEGIN
    PRINT '';
    PRINT '?? WARNING: Some data remains. Check error messages above.';
END

PRINT '';
PRINT '============================================================';
PRINT 'DELETION COMPLETE';
PRINT '============================================================';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Verify all data is deleted (see counts above)';
PRINT '2. Create a new admin account:';
PRINT '   - Run: SQL_Scripts/CREATE_ADMIN_ACCOUNT.sql';
PRINT '3. Start fresh with clean database!';
PRINT '';

GO
