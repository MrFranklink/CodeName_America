-- ========================================
-- MASTER MIGRATION SCRIPT
-- Banking Application - All Database Changes
-- Run this on a fresh database to apply all fixes
-- ========================================

USE Banking_Detail;
GO

PRINT '====================================================';
PRINT '  BANKING APP - DATABASE MIGRATION SCRIPT';
PRINT '  Version: 1.0 - December 2024';
PRINT '====================================================';
PRINT '';

-- ========================================
-- STEP 1: Add Approval Workflow Columns
-- ========================================
PRINT 'STEP 1: Adding approval workflow columns...';

-- Check if columns exist before adding
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'OpenedBy')
BEGIN
    ALTER TABLE Account ADD OpenedBy VARCHAR(20) NULL;
    PRINT '  + Added OpenedBy column';
END
ELSE
    PRINT '  - OpenedBy column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'OpenedByRole')
BEGIN
    ALTER TABLE Account ADD OpenedByRole VARCHAR(20) NULL;
    PRINT '  + Added OpenedByRole column';
END
ELSE
    PRINT '  - OpenedByRole column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'ApprovedBy')
BEGIN
    ALTER TABLE Account ADD ApprovedBy VARCHAR(20) NULL;
    PRINT '  + Added ApprovedBy column';
END
ELSE
    PRINT '  - ApprovedBy column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'RejectionReason')
BEGIN
    ALTER TABLE Account ADD RejectionReason VARCHAR(500) NULL;
    PRINT '  + Added RejectionReason column';
END
ELSE
    PRINT '  - RejectionReason column already exists';

PRINT '';

-- ========================================
-- STEP 2: Fix MaturityAmount Precision
-- ========================================
PRINT 'STEP 2: Fixing FixedDepositAccount MaturityAmount precision...';

-- Get current precision
DECLARE @CurrentPrecision INT, @CurrentScale INT;
SELECT 
    @CurrentPrecision = NUMERIC_PRECISION,
    @CurrentScale = NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount' AND COLUMN_NAME = 'MaturityAmount';

IF @CurrentPrecision < 28
BEGIN
    ALTER TABLE FixedDepositAccount
    ALTER COLUMN MaturityAmount DECIMAL(28,8) NULL;
    PRINT '  + Increased MaturityAmount precision to DECIMAL(28,8)';
END
ELSE
    PRINT '  - MaturityAmount precision already correct (28,8)';

PRINT '';

-- ========================================
-- STEP 3: Fix SavingsAccount Balance
-- ========================================
PRINT 'STEP 3: Ensuring SavingsAccount Balance column...';

-- Check if Balance column exists
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SavingsAccount') AND name = 'Balance')
BEGIN
    ALTER TABLE SavingsAccount ADD Balance DECIMAL(18,2) NULL;
    PRINT '  + Added Balance column to SavingsAccount';
    
    -- Set initial balance from transactions
    UPDATE sa
    SET Balance = (
        SELECT ISNULL(SUM(
            CASE 
                WHEN st.Transactiontype IN ('DEPOSIT', 'INITIAL DEPOSIT', 'TRANSFER_CREDIT', 'FD_MATURITY') THEN st.Amount
                WHEN st.Transactiontype IN ('WITHDRAW', 'WITHDRAWAL', 'TRANSFER_DEBIT', 'LOAN_PAYMENT') THEN -st.Amount
                ELSE 0
            END
        ), 0)
        FROM SavingsTransaction st
        WHERE st.SBAccountID = sa.SBAccountID
    )
    FROM SavingsAccount sa;
    
    PRINT '  + Calculated balances from transaction history';
END
ELSE
    PRINT '  - Balance column already exists';

PRINT '';

-- ========================================
-- STEP 4: Add FD_MATURITY Transaction Type
-- ========================================
PRINT 'STEP 4: Adding FD_MATURITY transaction type...';

-- Drop ALL existing transaction type constraints (handles any constraint name)
DECLARE @ConstraintName NVARCHAR(200);
DECLARE @SQL NVARCHAR(500);

-- Find all check constraints on Transactiontype column
DECLARE constraint_cursor CURSOR FOR
SELECT cc.name
FROM sys.check_constraints cc
INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
WHERE t.name = 'SavingsTransaction'
    AND cc.definition LIKE '%Transactiontype%';

OPEN constraint_cursor;
FETCH NEXT FROM constraint_cursor INTO @ConstraintName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER TABLE SavingsTransaction DROP CONSTRAINT ' + QUOTENAME(@ConstraintName);
    EXEC sp_executesql @SQL;
    PRINT '  + Dropped constraint: ' + @ConstraintName;
    
    FETCH NEXT FROM constraint_cursor INTO @ConstraintName;
END;

CLOSE constraint_cursor;
DEALLOCATE constraint_cursor;

-- Create new constraint with FD_MATURITY
ALTER TABLE SavingsTransaction
ADD CONSTRAINT CK_SavingsTransaction_Transactiontype
CHECK (Transactiontype IN (
    'DEPOSIT',
    'WITHDRAW',
    'WITHDRAWAL',
    'INITIAL DEPOSIT',
    'TRANSFER_DEBIT',
    'TRANSFER_CREDIT',
    'LOAN_PAYMENT',
    'FD_MATURITY'
));

PRINT '  + Added FD_MATURITY to allowed transaction types';
PRINT '';

-- ========================================
-- STEP 5: Recalculate FD Maturity Amounts
-- ========================================
PRINT 'STEP 5: Recalculating Fixed Deposit maturity amounts...';

DECLARE @UpdatedCount INT;

UPDATE fd
SET MaturityAmount = 
    CAST(
        fd.Amount * 
        POWER(
            CAST((1 + fd.FD_ROI / 100.0) AS FLOAT), 
            CAST(DATEDIFF(MONTH, fd.StartDate, fd.EndDate) / 12.0 AS FLOAT)
        )
        AS DECIMAL(28,8)
    )
FROM FixedDepositAccount fd
WHERE (fd.MaturityAmount IS NULL OR fd.MaturityAmount = 0)
    AND fd.Amount IS NOT NULL 
    AND fd.Amount > 0;

SET @UpdatedCount = @@ROWCOUNT;

IF @UpdatedCount > 0
    PRINT '  + Recalculated maturity for ' + CAST(@UpdatedCount AS VARCHAR) + ' FD account(s)';
ELSE
    PRINT '  - All FD accounts already have valid maturity amounts';

PRINT '';

-- ========================================
-- STEP 6: Verification
-- ========================================
PRINT 'STEP 6: Verifying all changes...';
PRINT '';

-- Count columns
DECLARE @ApprovalCols INT;
SELECT @ApprovalCols = COUNT(*)
FROM sys.columns
WHERE object_id = OBJECT_ID('Account')
    AND name IN ('OpenedBy', 'OpenedByRole', 'ApprovedBy', 'RejectionReason');

PRINT '  Approval Columns: ' + CAST(@ApprovalCols AS VARCHAR) + '/4';

-- Check MaturityAmount precision
SELECT @CurrentPrecision = NUMERIC_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount' AND COLUMN_NAME = 'MaturityAmount';

PRINT '  MaturityAmount Precision: ' + CAST(@CurrentPrecision AS VARCHAR) + ' (should be 28)';

-- Check FD maturity amounts
DECLARE @NullMaturity INT;
SELECT @NullMaturity = COUNT(*)
FROM FixedDepositAccount
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;

PRINT '  FDs with NULL maturity: ' + CAST(@NullMaturity AS VARCHAR) + ' (should be 0)';

-- Check transaction type constraint
DECLARE @HasFDMaturity INT;
SELECT @HasFDMaturity = COUNT(*)
FROM sys.check_constraints cc
INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
WHERE t.name = 'SavingsTransaction'
    AND cc.name = 'CK_SavingsTransaction_Transactiontype'
    AND cc.definition LIKE '%FD_MATURITY%';

PRINT '  FD_MATURITY in constraint: ' + CASE WHEN @HasFDMaturity > 0 THEN 'YES' ELSE 'NO' END;

PRINT '';

-- ========================================
-- FINAL SUMMARY
-- ========================================
PRINT '====================================================';
PRINT '  MIGRATION COMPLETE!';
PRINT '====================================================';
PRINT '';
PRINT 'All database changes have been applied successfully!';
PRINT '';
PRINT 'Next Steps:';
PRINT '  1. Update Entity Framework model in Visual Studio';
PRINT '     (Right-click Model1.edmx > Update Model from Database)';
PRINT '  2. Rebuild solution';
PRINT '  3. Test application';
PRINT '';
PRINT 'Migration completed on: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';

GO
