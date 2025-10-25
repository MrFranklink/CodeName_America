-- ============================================================
-- SAFE DELETE ALL DATA - With Backup and Rollback Option
-- ============================================================
-- This version is SAFER as it uses a transaction
-- You can rollback if something goes wrong!
-- ============================================================

USE Banking_Detail;  -- Change to your database name
GO

PRINT '';
PRINT '============================================================';
PRINT 'SAFE DELETE ALL DATA (with rollback option)';
PRINT '============================================================';
PRINT '';

-- ============================================================
-- SAFETY CHECK: Confirm database name
-- ============================================================

DECLARE @CurrentDB VARCHAR(100) = DB_NAME();
PRINT 'Current Database: ' + @CurrentDB;
PRINT '';

IF @CurrentDB NOT IN ('Banking_Detail', 'Banking_Details')
BEGIN
    PRINT '?? ERROR: Wrong database! This script is for Banking_Detail only.';
    PRINT 'Aborting...';
    RETURN;
END

-- ============================================================
-- OPTION 1: Create Backup Before Deletion
-- ============================================================

PRINT 'Do you want to create a backup first? (recommended)';
PRINT '';
PRINT '-- To create backup, run this command in a new window:';
PRINT '-- BACKUP DATABASE Banking_Detail TO DISK = ''C:\Temp\Banking_Detail_Backup_' + 
      CONVERT(VARCHAR, GETDATE(), 112) + '.bak'' WITH INIT;';
PRINT '';
PRINT 'Press Ctrl+C to cancel, or wait 10 seconds to continue WITHOUT backup...';
WAITFOR DELAY '00:00:10';
PRINT '';

-- ============================================================
-- Begin Transaction (allows rollback)
-- ============================================================

BEGIN TRANSACTION;

PRINT '============================================================';
PRINT 'Transaction Started - You can ROLLBACK if needed!';
PRINT '============================================================';
PRINT '';

DECLARE @RowsDeleted INT = 0;
DECLARE @ErrorOccurred BIT = 0;

-- ============================================================
-- Disable Triggers
-- ============================================================

PRINT 'Disabling triggers...';

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Customer_Delete_Cascade_UserLogin')
    DISABLE TRIGGER trg_Customer_Delete_Cascade_UserLogin ON Customer;

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Employee_Delete_Cascade_UserLogin')
    DISABLE TRIGGER trg_Employee_Delete_Cascade_UserLogin ON Employee;

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Manager_Delete_Cascade_UserLogin')
    DISABLE TRIGGER trg_Manager_Delete_Cascade_UserLogin ON Manager;

PRINT '? Triggers disabled';
PRINT '';

-- ============================================================
-- Delete Data in Transaction
-- ============================================================

PRINT 'Deleting data...';
PRINT '';

BEGIN TRY
    -- Transaction Tables
    DELETE FROM SavingsTransaction;
    SET @RowsDeleted = @@ROWCOUNT;
    PRINT '? SavingsTransaction: ' + CAST(@RowsDeleted AS VARCHAR) + ' rows';

    DELETE FROM LoanTransaction;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? LoanTransaction: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    DELETE FROM FundTransfer;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? FundTransfer: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    PRINT '';

    -- Account Sub-Tables
    DELETE FROM SavingsAccount;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? SavingsAccount: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    DELETE FROM FixedDepositAccount;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? FixedDepositAccount: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    DELETE FROM LoanAccount;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? LoanAccount: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    PRINT '';

    -- Account Table
    DELETE FROM Account;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? Account: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    PRINT '';

    -- UserLogin
    DELETE FROM UserLogin;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? UserLogin: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    PRINT '';

    -- Entity Tables
    DELETE FROM Customer;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? Customer: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    DELETE FROM Employee;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? Employee: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    DELETE FROM Manager;
    SET @RowsDeleted = @RowsDeleted + @@ROWCOUNT;
    PRINT '? Manager: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

    PRINT '';
    PRINT '------------------------------------------------------------';
    PRINT 'Total rows deleted: ' + CAST(@RowsDeleted AS VARCHAR);
    PRINT '------------------------------------------------------------';

END TRY
BEGIN CATCH
    SET @ErrorOccurred = 1;
    PRINT '';
    PRINT '??? ERROR OCCURRED!';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT '';
END CATCH

-- ============================================================
-- Re-enable Triggers
-- ============================================================

PRINT '';
PRINT 'Re-enabling triggers...';

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Customer_Delete_Cascade_UserLogin')
    ENABLE TRIGGER trg_Customer_Delete_Cascade_UserLogin ON Customer;

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Employee_Delete_Cascade_UserLogin')
    ENABLE TRIGGER trg_Employee_Delete_Cascade_UserLogin ON Employee;

IF EXISTS (SELECT 1 FROM sys.triggers WHERE name = 'trg_Manager_Delete_Cascade_UserLogin')
    ENABLE TRIGGER trg_Manager_Delete_Cascade_UserLogin ON Manager;

PRINT '? Triggers re-enabled';
PRINT '';

-- ============================================================
-- Commit or Rollback?
-- ============================================================

IF @ErrorOccurred = 0
BEGIN
    PRINT '';
    PRINT '============================================================';
    PRINT '??  READY TO COMMIT';
    PRINT '============================================================';
    PRINT '';
    PRINT 'Review the deletion summary above.';
    PRINT '';
    PRINT 'OPTION 1: COMMIT (make changes permanent)';
    PRINT '  - Run: COMMIT TRANSACTION;';
    PRINT '';
    PRINT 'OPTION 2: ROLLBACK (undo all changes)';
    PRINT '  - Run: ROLLBACK TRANSACTION;';
    PRINT '';
    PRINT 'You have 30 seconds to decide...';
    PRINT 'After 30 seconds, will AUTO-COMMIT!';
    PRINT '';
    
    WAITFOR DELAY '00:00:30';
    
    COMMIT TRANSACTION;
    
    PRINT '';
    PRINT '??? COMMITTED! All data permanently deleted.';
    PRINT '';
    
    -- Reset Identity Seeds
    IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('SavingsTransaction'))
        DBCC CHECKIDENT ('SavingsTransaction', RESEED, 0);
    
    IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('LoanTransaction'))
        DBCC CHECKIDENT ('LoanTransaction', RESEED, 0);
    
    IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('FundTransfer'))
        DBCC CHECKIDENT ('FundTransfer', RESEED, 0);
    
    PRINT '? Identity seeds reset';
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT '';
    PRINT '??? ROLLED BACK! No changes made to database.';
    PRINT 'Check the error message above and fix the issue.';
END

PRINT '';
PRINT '============================================================';
PRINT 'SCRIPT COMPLETE';
PRINT '============================================================';
PRINT '';

GO
