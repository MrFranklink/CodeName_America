-- ============================================================================
-- Add Approval Workflow Columns to Account Table
-- ============================================================================
-- Purpose: Support manager approval/rejection workflow for Loan and FD accounts
-- Date: 2025-01-16
-- ============================================================================

USE Banking_Details;
GO

PRINT '=== Adding Approval Workflow Columns to Account Table ===';
PRINT '';

-- Check if columns already exist before adding
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('Account') 
               AND name = 'RejectionReason')
BEGIN
    ALTER TABLE Account
    ADD RejectionReason NVARCHAR(500) NULL;
    PRINT '? Added RejectionReason column';
END
ELSE
BEGIN
    PRINT '??  RejectionReason column already exists';
END

IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('Account') 
               AND name = 'ApprovedBy')
BEGIN
    ALTER TABLE Account
    ADD ApprovedBy VARCHAR(10) NULL;
    PRINT '? Added ApprovedBy column';
END
ELSE
BEGIN
    PRINT '??  ApprovedBy column already exists';
END

IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('Account') 
               AND name = 'ApprovalDate')
BEGIN
    ALTER TABLE Account
    ADD ApprovalDate DATETIME NULL;
    PRINT '? Added ApprovalDate column';
END
ELSE
BEGIN
    PRINT '??  ApprovalDate column already exists';
END

PRINT '';
PRINT '=== Verifying New Columns ===';
PRINT '';

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Account'
  AND COLUMN_NAME IN ('RejectionReason', 'ApprovedBy', 'ApprovalDate')
ORDER BY COLUMN_NAME;

PRINT '';
PRINT '=== Update Complete ===';
PRINT 'New columns added to support approval workflow:';
PRINT '  - RejectionReason NVARCHAR(500) NULL';
PRINT '  - ApprovedBy VARCHAR(10) NULL';
PRINT '  - ApprovalDate DATETIME NULL';
PRINT '';
PRINT '??  IMPORTANT: Update your Entity Framework model to include these columns!';
PRINT '   1. Open Model1.edmx in Visual Studio';
PRINT '   2. Right-click ? Update Model from Database';
PRINT '   3. Select the Account table';
PRINT '   4. Rebuild the project';

GO
